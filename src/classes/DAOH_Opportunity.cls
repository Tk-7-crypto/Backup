/**
 * This is Opportunity trigger handler class.
 * version : 1.0
 */
public class DAOH_Opportunity {
    
    /** 
     * This method is used to set OpportunityNumber.
     * @params  newList List<Opportunity>
     * @return  void
     */
    public static void setOpportunityNumber(List<Opportunity> newList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SobjectType
            }
        );
        
        Map<Id,Opportunity_Extension__c> oppIdToOppExtMap = createOpportunityExtension(newList);
        
        Boolean toCommit = false;
        for(Opportunity opp : newList) {
            Opportunity oppToUpdate = new Opportunity();
            if(oppIdToOppExtMap.containsKey(opp.Id)){
                oppToUpdate.Opportunity_Extension__c = oppIdToOppExtMap.get(opp.Id).Id;
                oppToUpdate.Id = opp.Id;
                toCommit = true;
            }
            if(opp.Opportunity_Number__c == null){
                oppToUpdate.Opportunity_Number__c = opp.Opportunity_Auto_Number__c;
                oppToUpdate.Id = opp.Id;
                toCommit = true;
            }
            if(opp.Ultimate_Parent_Opportunity_Number__c == null){
                oppToUpdate.Ultimate_Parent_Opportunity_Number__c = opp.Opportunity_Auto_Number__c;
                oppToUpdate.Id = opp.Id;
                toCommit = true;
            }
            if(opp.Mulesoft_External_Id__c == null){
                oppToUpdate.Mulesoft_External_Id__c = opp.Id;
                oppToUpdate.Id = opp.Id;
                toCommit = true;
            }
            if(toCommit) {
                uow.registerDirty(oppToUpdate);
            }
        }
        if(toCommit) {
            try {
                UTL_ExecutionControl.stopTriggerExecution = true;
                uow.commitWork();
                UTL_ExecutionControl.stopTriggerExecution = false;
            } catch(DmLException ex) {
                UTL_ExecutionControl.stopTriggerExecution = false;
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    Opportunity actualRecord = (Opportunity)Trigger.newMap.get(ex.getDmlId(i));
                    actualRecord.addError(ex.getDmlMessage(i));
                }
            } 
        }

    }
    
    /**
     * Method to create Opportunity_Extension record
     * @param List<Opportunity> newList
     * @return Map<Id,Opportunity_Extension__c>
     */
    private static Map<Id,Opportunity_Extension__c> createOpportunityExtension(List<Opportunity> newList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { Opportunity_Extension__c.SobjectType } );
        List<Opportunity_Extension__c> oppExtList = new List<Opportunity_Extension__c>();
        Map<Id,Opportunity_Extension__c> oppIdToOppExtMap = new Map<Id,Opportunity_Extension__c>();
        for(Opportunity opp: newList){
            oppExtList.add(new Opportunity_Extension__c(Opportunity__c = opp.Id, BNF_Count__c = 0));
        }
        if(oppExtList.size() > 0){
            uow.registerNew(oppExtList);
            uow.commitWork();
            for(Opportunity_Extension__c oppExt :oppExtList){
                oppIdToOppExtMap.put(oppExt.Opportunity__c, oppExt);
            }
        }
        return oppIdToOppExtMap;
    }
    
    /**
     * This method is used to set timeStamp values according to current stageName.
     * @params  newList List<Opportunity>
     * @params  oldMap Map<Id, Opportunity>
     * @return  void
     */
    public static void setTimeStampBasedOnStage(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Map<String, String> oppTimeStampFieldMap = new Map<String, String> {
            CON_CRM.IDENTIFYING_OPP_STAGE => '',
            CON_CRM.QUALIFYING_OPP_STAGE  => 'X2_Qualifying_Oportunity_Stage_Entry__c',
            CON_CRM.DEVELOPING_PROP_STAGE => 'X3_Developing_Proposal_Stage_Entry__c',
            CON_CRM.DELIVERING_PROP_STAGE => 'X4_Delivering_Proposal_Stage_Entry__c',
            CON_CRM.FINALIZING_DEAL_STAGE => 'X5_Finalizing_Deal_Stage_Entry__c',
            CON_CRM.RECEIVED_ATP_STAGE    => 'X6_Received_ATP_LOI_Stage_Entry__c',
            CON_CRM.CLOSED_WON_STAGE      => 'X7a_Closed_Won_Stage_Entry__c',
            CON_CRM.CLOSED_LOST_STAGE     => 'X7b_Closed_Lost_Stage_Entry__c'
        };

        for(Opportunity opp : newList) {
            if(opp.stageName != null && oppTimeStampFieldMap.containsKey(opp.stageName)) {
                String timeStampField = oppTimeStampFieldMap.get(opp.stageName);
                if(timeStampField != '' && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(opp.Id).get(timeStampField) == null))) {
                    opp.put(timeStampField, System.now().dateGmt());
                }
            }
            if(opp.stageName == CON_CRM.IN_HAND_STAGE && opp.In_Hand_Stage_Entry__c == null) {
                opp.In_Hand_Stage_Entry__c = Date.today();
                opp.In_Hand_Stage_Entry_DateTime__c = System.now().dateGmt();
            }
        }
    }
    
    /**
     * This method is used to validate Opportunity Based on Stage Criteria.
     * @params  newMap Map<Id, Opportunity>
     * @params  oldMap Map<Id, Opportunity>
     * @return  void
     */
    public static void validateOpportunitiesBasedOnStage(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Legacy_Org_Link__c legacyLinkSetting = Legacy_Org_Link__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            String errorMessageString = '';
            if(Trigger.isExecuting) {
                Set<Id> oppIdSet = new Set<Id>();
                for(Opportunity opp : newMap.values()) {
                    if(opp.StageName != oldMap.get(opp.Id).StageName) {
                        oppIdSet.add(opp.Id);
                    }
                    if(opp.StageName != oldMap.get(opp.Id).StageName && opp.RD_Product_Count__c > 0 && opp.Number_of_line_items__c == 0 && 
                       (opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE ||opp.StageName == CON_CRM.RECEIVED_ATP_STAGE || opp.StageName == CON_CRM.CLOSED_WON_STAGE)
                       && opp.Awarded_Date__c != null) {
                           //opp.CloseDate = opp.Awarded_Date__c;
                       }
                }            
                if(oppIdSet.size() > 0) {
                    // ESPSFDCQI-54 - Start
                    Map<Id, OpportunityContactRole> contactRoleIdToContactRoleMap = new SLT_OpportunityContactRoles().selectByOpportunityId(oppIdSet);
                    Set<Id> oppIdswithOppContactRolesSet = new Set<Id>();
                    for(OpportunityContactRole oppContactRole : contactRoleIdToContactRoleMap.values()) {
                        oppIdswithOppContactRolesSet.add(oppContactRole.OpportunityId);
                    }
                    // ESPSFDCQI-211 - Start
                    // ESPSFDCQI-598 - Start : Added one more field "Product_Material_Type__c" in the oliFieldSet
                    // ESPSFDCQI-12083 - Start : Added more fields "Local product code, ProductName and Total Price" in the oliFieldSet
                    //ESPSFDCQI-17333 - start - added one more field Product_Group__c 
                    Set<String> oliFieldSet = new Set<String> {'Id', 'OpportunityId', 'Hierarchy_Level__c', 'Offering_Group_Code__c', 'PricebookEntry.Product2.Material_Type__c','Is_Survey_Eligible__c','PricebookEntry.Product2.Local_Product_Code__c','PricebookEntry.Product2.Name','TotalPrice','Product2.Product_Group__c'};
                        Map<Id, OpportunityLineItem> oliIdToLineItemMap = new SLT_OpportunityLineItems().selectByOpportunityId(oppIdSet, oliFieldSet);
                    Set<Id> oppIdswithOppLineItemsSet = new Set<Id>();
                    Set<Id> oppIdswithMaterialLevelProductSet = new Set<Id>();
                    Set<Id> oppIdswithNoMaterialLevelProductSet = new Set<Id>();
                    Set<Id> oppIdwithZREPZPUBProductSet = new Set<Id>();
                    Set<Id> oppIdwithLQProduct = new Set<Id>();
                    Set<Id> oppIdwithRWLPPortfolioProductSet = new Set<Id>();
                    String localProductCode;
                    Set<String> csmsLOB = new Set<String>{'Commercial Solutions','Health Engagement & Communication'};
                    // ESPSFDCQI-598 - Start
                    //Set<Id> oppIdswithZREPMaterialTypeProductSet = new Set<Id>();
                    // ESPSFDCQI-598 - End
                    Set<Id> oppWithClosedLostStageSet = new Set<Id>();
                    for(OpportunityLineItem oppLineItem : oliIdToLineItemMap.values()) {
                        oppIdswithOppLineItemsSet.add(oppLineItem.OpportunityId);
                        Opportunity opp = newMap.get(oppLineItem.OpportunityId);
                        localProductCode= oppLineItem.PricebookEntry.Product2.Local_Product_Code__c;
                        // ESPSFDCQI-598 - Start
                        if(opp.StageName != CON_CRM.IDENTIFYING_OPP_STAGE && opp.StageName != CON_CRM.CLOSED_LOST_STAGE && opp.StageName != oldMap.get(opp.Id).StageName){
                            if(oppLineItem.Hierarchy_Level__c == CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI || oppLineItem.Offering_Group_Code__c == CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND) {
                                oppIdswithMaterialLevelProductSet.add(oppLineItem.OpportunityId);
                            }
                            if(oppLineItem.Hierarchy_Level__c != CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI) {
                                oppIdswithNoMaterialLevelProductSet.add(oppLineItem.OpportunityId);
                            }
                        }
                        /*if(opp.Survey_Recipient__c == null && (opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE || opp.StageName == CON_CRM.RECEIVED_ATP_STAGE || opp.StageName == CON_CRM.CLOSED_WON_STAGE)){
                            if(oppLineItem.PricebookEntry.Product2.Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZREP ){
                                oppIdswithZREPMaterialTypeProductSet.add(oppLineItem.OpportunityId);
                            }
                        }*/
                        if(oppLineItem.PricebookEntry.Product2.Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZREP) {
                            oppIdwithZREPZPUBProductSet.add(oppLineItem.OpportunityId);
                        }
                        if(oppLineItem.PricebookEntry.Product2.Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZPUB && oppLineItem.Is_Survey_Eligible__c){
                            oppIdwithZREPZPUBProductSet.add(oppLineItem.OpportunityId);
                        }
                        if(opp.stageName == CON_CRM.CLOSED_WON_STAGE && csmsLOB.contains(opp.Line_of_Business__c) && opp.CSMS_Product__c > 0){
                            //oppIdwithZREPZPUBProductSet.add(oppLineItem.OpportunityId);
                        }
                        if(opp.StageName != oldMap.get(opp.Id).StageName && oppLineItem.pricebookEntry.Product2.Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI && oppLineItem.Hierarchy_Level__c == CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI) {
                            oppIdwithLQProduct.add(oppLineItem.OpportunityId);
                        }
                        if((opp.Line_of_Business__c != oldMap.get(opp.Id).Line_of_Business__c || opp.StageName != oldMap.get(opp.Id).StageName) && opp.Line_of_Business__c == 'RWLP'){
                            if(oppLineItem.Product2.Product_Group__c == 'Real World Late Phase') {
                                oppIdwithRWLPPortfolioProductSet.add(oppLineItem.OpportunityId);
                            }
                        }
                    }
                    
                    //12083
                    Set<String> localProductCodesSet = new Set<String>();
                    List<String> emailNotificationRecepientsList = new List<String>();
                    List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
                    Set<Id> accountsIdSet = new Set<Id>();   
                    for(Id opportunityId : oppIdSet) {
                        Opportunity opp = newMap.get(opportunityId);
                        
                        if(opp.stageName != CON_CRM.CLOSED_LOST_STAGE && (!oppIdswithOppContactRolesSet.contains(opportunityId))) {
                            if(errorMessageString.length() == 0) {
                                errorMessageString = System.Label.CRM_CL0001_IDENTIFYING_OPP_STAGE_ERROR;
                            }else {
                                errorMessageString = errorMessageString + '\n' + System.Label.CRM_CL0001_IDENTIFYING_OPP_STAGE_ERROR;
                            }                    
                        }
                        
                        
                        String profileName = UTL_CRM.getCurrentUserProfileName();
                        //12083
                        Deal_Desk_Approval_Setting__mdt ddas = Deal_Desk_Approval_Setting__mdt.getAll().values();
                        if (ddas.Local_Product_Code__c != null) { 
                            localProductCodesSet = new Set<String>(ddas.Local_Product_Code__c.split(','));
                            emailNotificationRecepientsList = new List<String>(ddas.Email_Notification_Recipients__c.split(','));
                        }
                        
                        if(opp.StageName != oldMap.get(opp.Id).StageName && localProductCodesSet.contains(localProductCode) ){
                            
                            if(profileName == 'Tech Solutions User' ){                          
                                if( ((oldMap.get(opp.Id).StageName == CON_CRM.IDENTIFYING_OPP_STAGE || oldMap.get(opp.Id).StageName == CON_CRM.QUALIFYING_OPP_STAGE || oldMap.get(opp.Id).StageName == CON_CRM.DEVELOPING_PROP_STAGE) && (opp.StageName == CON_CRM.DELIVERING_PROP_STAGE || opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE || opp.StageName == CON_CRM.RECEIVED_ATP_STAGE || opp.StageName == CON_CRM.CLOSED_WON_STAGE) || (oldMap.get(opp.Id).StageName == CON_CRM.DELIVERING_PROP_STAGE && (opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE || opp.StageName == CON_CRM.RECEIVED_ATP_STAGE || opp.StageName == CON_CRM.CLOSED_WON_STAGE))) && opp.Deal_Desk_Status__c !='Approved Pricing' ){
                                    if(errorMessageString.length() == 0) {
                                        errorMessageString = System.Label.CRM_CL0045_OPP_STAGE3_DEAL_DESK_ERROR;
                                    }else {
                                        errorMessageString = errorMessageString + '\n'+ System.Label.CRM_CL0045_OPP_STAGE3_DEAL_DESK_ERROR; 
                                    }
                                    
                                }
                            }else if(profileName != 'Tech Solutions User' && opp.StageName == CON_CRM.CLOSED_WON_STAGE ){                                   
                                //send email Notification
                                accountsIdSet.add(opp.AccountId);	
                                Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accountsIdSet, new Set<String>{'Id','Name','Category__c','ParentId','Parent.Name'});
                                String emailBody = 'Dear Deal Desk user,<br/><br/>';
                                emailBody += 'This is to inform you that a new Opportunity with a product of interest is being advanced to stage 7a in SFDC as below.<br/><br/>';
                                emailBody += 'Opportunity Record: ' +URL.getOrgDomainUrl().toExternalForm() + '/' + opp.Id+  '<br/><br/>';
                                emailBody += 'Client: ' +accountMap.get(opp.AccountId).Name+ '<br/><br/>';
                                emailBody += 'Total Opportunity Amount: '+opp.CurrencyIsoCode+' ' +opp.Amount+ '<br/><br/>';
                                emailBody += 'Product Information:'+ '<br/><br/>';
                                emailBody += '<table style="border-collapse: collapse;border: 0.1px solid black;">';
                                emailBody += '<colgroup span="2"></colgroup><colgroup span="2"></colgroup>';  
                                emailBody += '<tr><th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">Product '+ '</th>';
                                emailBody += '<th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">Amount ( '+opp.CurrencyIsoCode+' )'+'</th></tr>';
                                for(OpportunityLineItem oppLineItem : oliIdToLineItemMap.values()){
                                    emailBody += '<tr><td colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">'+ oppLineItem.PricebookEntry.Product2.Name + '</td>'  ;
                                    emailBody += '<td colspan="2" scope="colgroup" style="text-align:right;border-collapse: collapse;border: 0.1px solid black;">' + oppLineItem.TotalPrice  + '</td></tr>';
                                }
                                emailBody += '</table>' + '<br/><br/>';
                                emailBody += 'Best Regards,';
                                
                                UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                                message.toEmails = emailNotificationRecepientsList;
                                message.whatId = opp.Id;
                                
                                message.subject = 'An opportunity is being advanced to 7a with a product of interest - ['+ accountMap.get(opp.AccountId).Name +'] ['+ opp.Opportunity_Number__c +']';
                                message.staticContent = emailBody;
                                messageList.add(message);
                                
                                if(messageList.size()>0){
                                    UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
                                }
                            }
                        }
                        // end 12083
                        if(opp.stageName != CON_CRM.CLOSED_LOST_STAGE && !oppIdswithOppLineItemsSet.contains(opportunityId) && !(opp.stageName == CON_CRM.IDENTIFYING_OPP_STAGE && (profileName.contains(CON_CRM.SYS_ADMIN) || profileName.equals(CON_CRM.IQVIA_SF_PLATFORM_PROFILE) || profileName.equals(CON_CRM.COMMERCIAL_OPERATION_PROFILE)))) {
                            if(errorMessageString.length() == 0) {
                                errorMessageString = System.Label.CRM_CL0002_OPP_LINE_ITEM_ERROR;
                            }else {
                                errorMessageString = errorMessageString + '\n'+ System.Label.CRM_CL0002_OPP_LINE_ITEM_ERROR;
                            }
                        }

                        if(!oppIdswithMaterialLevelProductSet.contains(opportunityId) && (opp.StageName != CON_CRM.IDENTIFYING_OPP_STAGE && opp.StageName != CON_CRM.QUALIFYING_OPP_STAGE && opp.StageName != CON_CRM.CLOSED_LOST_STAGE)) {
                            if(errorMessageString.length() == 0) {
                                errorMessageString = System.Label.CRM_CL0003_QUALIFYING_OPP_STAGE_ERROR;
                            }else {
                                errorMessageString = errorMessageString + '\n' +System.Label.CRM_CL0003_QUALIFYING_OPP_STAGE_ERROR;
                            }        
                        }
                        
                        if(oppIdswithNoMaterialLevelProductSet.contains(opportunityId) && (opp.StageName != CON_CRM.IDENTIFYING_OPP_STAGE && opp.StageName != CON_CRM.QUALIFYING_OPP_STAGE && opp.StageName != CON_CRM.DEVELOPING_PROP_STAGE && opp.StageName != CON_CRM.CLOSED_LOST_STAGE)) {
                            if(errorMessageString.length() == 0) {
                                errorMessageString = System.Label.CRM_CL0004_DEVELOPING_PROPOSAL_STAGE_ERROR;
                            } else {
                                errorMessageString = errorMessageString + '\n' + System.Label.CRM_CL0004_DEVELOPING_PROPOSAL_STAGE_ERROR;
                            }
                        }
                        
                        /*if(oppIdswithZREPMaterialTypeProductSet.contains(opportunityId) && opp.Survey_Recipient__c == null && (opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE || opp.StageName == CON_CRM.RECEIVED_ATP_STAGE || opp.StageName == CON_CRM.CLOSED_WON_STAGE)){
                            errorMessageString = errorMessageString + '\n' + System.Label.CL0008_SURVEY_RECIPIENT_REQUIRED_ERROR;
                        }*/
                        
                        if(opp.LQ_User_Save_Timestamp__c == null && oppIdwithLQProduct.contains(opportunityId)) {
                            //errorMessageString = errorMessageString + '\n' + System.Label.CRM_CL0015_RECORD_UPDATE_ERROR_15 + ' https://' + legacyLinkSetting.Legacy_Quintiles_URL__c + '/' + opp.LQ_Opportunity_id__c + ' ' +System.Label.CRM_CL0016_RECORD_UPDATE_ERROR_16;
                        } else if(opp.LQ_User_Save_Timestamp__c != null && oppIdwithLQProduct.contains(opportunityId) && !Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c) {
                            opp.LQ_User_Save_Timestamp__c = null;
                        }
                        
                        if(errorMessageString.length() > 0) {
                            opp.addError(errorMessageString);
                        }
                        if(opp.stageName == CON_CRM.CLOSED_LOST_STAGE) {
                            oppWithClosedLostStageSet.add(opp.Id);
                        }
                    }
                    // ESPSFDCQI-1830 - Start
                    if(oppWithClosedLostStageSet.size() > 0) {
                        Set<Id> oppIdWithProxyProjectSet = new Set<Id>();
                        Set<String> fieldSet = new Set<String>{'Id', 'LI_Record_Id__c', 'Opportunity__c', 'Project_Status__c', 'Record_Type_Name__c'};
                        List<Proxy_Project__c> proxyProjectList = new SLT_Proxy_Project().selectByFilter(oppWithClosedLostStageSet, fieldSet);
                        for(Proxy_Project__c proxyProject : proxyProjectList) {
                            if(proxyProject.Project_Status__c == 'In Progress (At Risk)' || proxyProject.Project_Status__c == 'In Progress') {
                                oppIdWithProxyProjectSet.add(proxyProject.Opportunity__c);
                            }
                        }
                        for(Id oppId : oppIdWithProxyProjectSet) {
                            Opportunity opp = newMap.get(oppId);
                            opp.addError(System.label.CRM_CL0020_CLOST_LOST_PROJECT_ERROR);
                        }
                    }
                    // ESPSFDCQI-1830 - End
                    for(Id opportunityId : oppIdwithZREPZPUBProductSet) {
                        Opportunity oppRecord = newMap.get(opportunityId);
                        if(oppRecord.Principle_inCharge__c == NULL && (oppRecord.StageName == CON_CRM.DELIVERING_PROP_STAGE || oppRecord.StageName ==
                        CON_CRM.FINALIZING_DEAL_STAGE || oppRecord.StageName == CON_CRM.RECEIVED_ATP_STAGE || oppRecord.StageName == CON_CRM.CLOSED_WON_STAGE)) {
                           oppRecord.Principle_inCharge__c.addError(System.Label.CRM_CL0008_PIC_ERROR + CON_CRM.SINGLE_SPACE + oppRecord.StageName);                                                 
                        }
                    }
                    //ESPSFDCQI-17333 - End
                    for(Id opportunityId : oppIdwithRWLPPortfolioProductSet) {
                        Opportunity oppRecord = newMap.get(opportunityId);
                        if(oppRecord.EvidenceStrategy_Lead__c == NULL && (oppRecord.StageName == CON_CRM.DELIVERING_PROP_STAGE || oppRecord.StageName ==
                        CON_CRM.FINALIZING_DEAL_STAGE || oppRecord.StageName == CON_CRM.RECEIVED_ATP_STAGE || oppRecord.StageName == CON_CRM.CLOSED_WON_STAGE)) {
                            oppRecord.EvidenceStrategy_Lead__c.addError(System.Label.CRM_CL0055_EvidenceStrategyLead_Validation_Error_Stage_4_RWLP);                                                 
                        }
                    }
                }
            }
        }
    }  
    
    /**
     * This method is used to update Outbound Message Deletion Queue
     * @params  List<Opportunity> deleteList
     * @return  void
     */
    public static void createOutboundMessageDeletionQueue(List<Opportunity> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
            }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Opportunity opp : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            if(opp.LI_Opportunity_Id__c != null) {
                outBound.LI_Id__c = opp.LI_Opportunity_Id__c;
            }
            if(opp.LQ_Opportunity_Id__c != null) {
                outBound.LQ_Id__c = opp.LQ_Opportunity_Id__c;
            }
            outBound.SObjectType__c = CON_CRM.OPPORTUNITY_OBJECT;
            outBound.RecordID__c = opp.Id;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
    
    /**
     * This method is used to set Mulesoft Integration Fields on Opportunity.
     * @param newList List<Opportunity>
     */
    public static void setStandardPriceBookId(List<Opportunity> newList) {
        Set<String> fieldSet = new Set<String>{'Id'};
        List<Pricebook2> pbList = new SLT_PriceBook2().getStandardPriceBook(fieldSet);
        if(pbList.size() > 0) {
            for(Opportunity opp : newList) {
                opp.Pricebook2Id = pbList[0].Id;
            }
        }
    }
    
    /**
     * This method is used to set MuleSoft Sync Fields
     * @params  List<Opportunity> newList
     * @params  Map<Id, Opportunity> oldMap
     * @return  void
     */
    public static void setMuleSoftSyncFields(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Legacy_Org_Link__c legacyLinkSetting = Legacy_Org_Link__c.getInstance();
        List<Schema.FieldSetMember> oppFieldMemberList = Schema.SObjectType.Opportunity.fieldSets.Mulesoft_Synced_Fields.getFields();
        if(!CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN){
            // Set global variable to prevent trigger running twice (before update and after insert)
            CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = true;
            List<Mulesoft_Opportunity_Sync__c> mulesoftOppSyncList = new List<Mulesoft_Opportunity_Sync__c>();   
            Map<String, Mulesoft_Opportunity_Sync__c> oppIdToMulesoftOppSyncMap = new Map<String, Mulesoft_Opportunity_Sync__c>();
            if(Trigger.isUpdate) {
                List<Mulesoft_Opportunity_Sync__c> existingMulesoftOppSyncList = new SLT_MulesoftOpportunitySync().selectByOppIds(oldMap.keySet());
                for(Mulesoft_Opportunity_Sync__c oppsync : existingMulesoftOppSyncList) {
                    oppIdToMulesoftOppSyncMap.put(oppsync.Opportunity__c, oppsync);
                }              
            }
            for(Opportunity newOpp : newList) {
                if(newOpp.Opportunity_Sharing_Business_Unit__c != CON_CRM.LOB_Avacare){             
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Completed
                    //  LQ_Mulesoft_Sync_Status__c: Completed
                    //==========================================
                    //  if update is coming from Mulesoft as result of action in either of the legacy orgs
                    if(newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI || CON_CRM.TEMP_UPDATE_TYPE_MULESOFT_SLAVE == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI ) {
                        //  allow Mulesoft update to complete
                        //  i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                        //  and to set the Mulesoft_update_GUID__c from the other org 
                        Mulesoft_Opportunity_Sync__c mos = new Mulesoft_Opportunity_Sync__c();
                        mos.Mulesoft_LI_Incoming_Update_GUID__c = newOpp.Mulesoft_LI_Incoming_Update_GUID__c;
                        mos.LI_Mulesoft_Sync_Status__c = newOpp.LI_Mulesoft_Sync_Status__c;
                        mos.LI_Mulesoft_Sync_Timestamp__c = newOpp.LI_Mulesoft_Sync_Timestamp__c;
                        mos.LI_Mulesoft_Error_Message__c = newOpp.LI_Mulesoft_Error_Message__c;  
                        mos.Opportunity__c = newOpp.Id;
                        mos.LI_Opportunity_Id__c = newOpp.LI_Opportunity_Id__c;
                        mos.Legacy_IMS_Opportunity_Number__c = newOpp.Legacy_IMS_Opportunity_Number__c;
                        mulesoftOppSyncList.add(mos);  
                    } else if(newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ || CON_CRM.TEMP_UPDATE_TYPE_MULESOFT_SLAVE == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ ){
                        Mulesoft_Opportunity_Sync__c mos = new Mulesoft_Opportunity_Sync__c();
                        mos.Mulesoft_LQ_Incoming_Update_GUID__c = newOpp.Mulesoft_LQ_Incoming_Update_GUID__c;
                        mos.LQ_Mulesoft_Sync_Status__c = newOpp.LQ_Mulesoft_Sync_Status__c;
                        mos.LQ_Mulesoft_Sync_Timestamp__c = newOpp.LQ_Mulesoft_Sync_Timestamp__c;
                        mos.LQ_Mulesoft_Error_Message__c = newOpp.LQ_Mulesoft_Error_Message__c;
                        mos.Opportunity__c = newOpp.Id;
                        mos.LQ_Opportunity_Id__c = newOpp.LQ_Opportunity_Id__c;
                        mos.Legacy_Quintiles_Opportunity_Number__c  = newOpp.Legacy_Quintiles_Opportunity_Number__c ;
                        mulesoftOppSyncList.add(mos);
                    } else if(newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER && !Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c) {
                        String fieldAPI = '';
                        Mulesoft_Opportunity_Sync__c mos = new Mulesoft_Opportunity_Sync__c();
                        for(Schema.FieldSetMember sf : oppFieldMemberList) {
                            fieldAPI = sf.getFieldPath();
                            if((trigger.isInsert || !oppIdToMulesoftOppSyncMap.containsKey(newOpp.Id) || (trigger.isUpdate && newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI))) && mulesoftSetting.Enable_Opportunity_Sync_Validation__c) {
                                if((trigger.isInsert || (trigger.isUpdate && newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI))) && mulesoftSetting.Enable_Opportunity_Sync_Validation__c) {
                                    mos.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
                                    mos.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
                                }
                                mos.LI_Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
                                mos.LQ_Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
                                mos.LI_Mulesoft_Sync_Timestamp__c = null;
                                mos.LI_Mulesoft_Error_Message__c = null; 
                                mos.LQ_Mulesoft_Sync_Timestamp__c = null;
                                mos.LQ_Mulesoft_Error_Message__c = null;
                                mos.LQ_Opportunity_Id__c = newOpp.LQ_Opportunity_Id__c;
                                mos.LI_Opportunity_Id__c = newOpp.LI_Opportunity_Id__c;
                                mos.Opportunity__c = newOpp.Id;
                                mulesoftOppSyncList.add(mos);
                                break;
                            }
                        }
                    }
                }
            }
            if(mulesoftOppSyncList.size() > 0){
                upsert mulesoftOppSyncList Opportunity__c;
            }
        }
    }

    /**
     * This method is used to set MuleSoft Sync Process
     * @params  List<Opportunity> newList
     * @params  Map<Id, Opportunity> oldMap
     * @return  void
     */
    public static void setMuleSoftSyncMechanism(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Legacy_Org_Link__c legacyLinkSetting = Legacy_Org_Link__c.getInstance();
        List<Schema.FieldSetMember> oppFieldMemberList = Schema.SObjectType.Opportunity.fieldSets.Mulesoft_Synced_Fields.getFields();
        if(mulesoftSetting.Enable_Opportunity_Sync_Validation__c && !CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN) {
            // Set global variable to prevent trigger running twice (before update and after insert)
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = true;
            List<Mulesoft_Opportunity_Sync__c> mulesoftOppSyncList = new List<Mulesoft_Opportunity_Sync__c>();
            
            Map<String, Mulesoft_Opportunity_Sync__c> oppIdToMulesoftOppSyncMap = new Map<String, Mulesoft_Opportunity_Sync__c>();
            if(trigger.isUpdate) {
                List<Mulesoft_Opportunity_Sync__c> existingMulesoftOppSyncList = new SLT_MulesoftOpportunitySync().selectByOppIds(oldMap.keySet());            
                for(Mulesoft_Opportunity_Sync__c oppsync : existingMulesoftOppSyncList) {
                    oppIdToMulesoftOppSyncMap.put(oppsync.Opportunity__c, oppsync);
                }
            }
                        
            for(Opportunity newOpp : newList) {
                if(newOpp.Opportunity_Sharing_Business_Unit__c != CON_CRM.LOB_Avacare){
                    //Updating update type to User when it is blank for old records.
                    if(String.isBlank(newOpp.Update_Type__c)){
                        newOpp.Update_Type__c = CON_CRM.UPDATE_TYPE_USER;
                    }
                    
                    //Updating the mulesoft status from blank to completed when update is initiated from legacy orgs.
                    if (trigger.isUpdate && oppIdToMulesoftOppSyncMap.containsKey(newOpp.Id) && String.isBlank(oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c)) {
                        oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
                    }
                    if (trigger.isUpdate && oppIdToMulesoftOppSyncMap.containsKey(newOpp.Id) && String.isBlank(oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c)) {
                        oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED;
                    }
                    if (trigger.isUpdate && newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_FORCE_UPDATE_LI){
                        //allow the udpate in all cases
                    }
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Completed
                    //  LQ_Mulesoft_Sync_Status__c: Completed
                    //==========================================
                    else if(trigger.isInsert || !oppIdToMulesoftOppSyncMap.containsKey(newOpp.Id) || (oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED )) {
                            
                        //  if update is coming from Mulesoft as result of action in either of the legacy orgs
                        if(newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI || newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ) {
                            //  allow Mulesoft update to complete
                            //  i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                            //  and to set the Mulesoft_update_GUID__c from the other org           
                        } else if(newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            newOpp.Send_Mulesoft_Outbound_Msg__c = false;
                            String fieldAPI = '';
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                fieldAPI = sf.getFieldPath();
                                if(trigger.isInsert || (trigger.isUpdate && newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI))) {
                                    newOpp.Send_Mulesoft_Outbound_Msg__c = true;
                                    break;
                                }
                            }
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);             
                        }
                    }
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Completed
                    //  LQ_Mulesoft_Sync_Status__c: Pending
                    //==========================================            
                    else if(Trigger.isUpdate && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED 
                        && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_PENDING) {
                        //  if update is coming from user check if any synced fields are being updated
                        if(newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            newOpp.Send_Mulesoft_Outbound_Msg__c = false;
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                String fieldAPI = sf.getFieldPath();
                                if (newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI)) {
                                    newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_1);
                                    break;
                                }
                            }
                            // else allow the update (by doing nothing further in the trigger)             
                        }                    
                        //  if update is coming from Mulesoft as result of action in legacy IMS org trhow error that LQ Mulesoft sync is still pending
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI) {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_1);          
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);         
                        }
                    } 
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Completed
                    //  LQ_Mulesoft_Sync_Status__c: Failed
                    //==========================================
                    //  If LQ sync status is failed we need to wait for successful update from LQ org before allowing any further user or LI SLAVE updates
                    else if (Trigger.isUpdate && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED 
                        && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED ) {       
                        //  if update is coming from user check if any synced fields are being updated
                        if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            //newOpp.Send_Mulesoft_Outbound_Msg__c = false;
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                String fieldAPI = sf.getFieldPath();
                                //  If opp.LQ_Opportunity_Id__c is null, then insert on legacy org failed
                                if (newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI)) {
                                    //  If opp.LQ_Opportunity_Id__c is null, then insert on legacy org failed
                                    if(oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Opportunity_Id__c == null) {
                                        newOpp.addError('Insert of record in legacy Quintiles org failed.  The error from the legacy Quintiles org is: "'+ oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Error_Message__c + '".  Please contact CRM Support asking for manual Mulesoft syncing of the record at <a href="https://iqvia--crm.lightning.force.com/' + newOpp.Id + '">  https://iqvia--crm.lightning.force.com/' + newOpp.Id + '</a>', false);     
                                        break;
                                    }
                                    // else update on legacy org failed                                
                                    else {
                                        newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_13 + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Error_Message__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + legacyLinkSetting.Legacy_Quintiles_URL__c + CON_CRM.FORWARDSLASH + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Opportunity_Id__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_3);          
                                        break;
                                    }
                                }
                            }  
                            // else allow the update (by doing nothing further in the trigger) 
                        }
                        //  if update is coming from Mulesoft as part of slave update from legacy IMS org
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI) {  
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_13 + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Error_Message__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_2+ legacyLinkSetting.Legacy_Quintiles_URL__c + CON_CRM.FORWARDSLASH + newOpp.LQ_Opportunity_Id__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_3);           
                        } 
                        //  else if the update is coming from LQ org to correct the error
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ) {
                            //  Allow the update
                            //  i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                            //  and to set the Mulesoft_update_GUID__c from the other org          
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);
                        }  
                        
                    }  
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Pending
                    //  LQ_Mulesoft_Sync_Status__c: Completed
                    //==========================================
                    //  If LI sync status is pending we need to wait for successful talkback update from LI org before allowing any further user or LI SLAVE updates                
                    else if (Trigger.isUpdate && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_PENDING 
                        && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED ) {
                        //  if update is coming from user check if any synced fields are being updated
                        if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            newOpp.Send_Mulesoft_Outbound_Msg__c = false;                        
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                String fieldAPI = sf.getFieldPath();
                                if (newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI)) {
                                    newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_2);     
                                    break;
                                }
                            }
                            // else allow the update (by doing nothing further in the trigger)
                        }
                        //  if update is coming from Mulesoft as result of action in legacy IMS org trhow error that LQ Mulesoft sync is still pending
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ) {  
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_1);          
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);         
                        }                    
                    }
                    
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Pending
                    //  LQ_Mulesoft_Sync_Status__c: Pending
                    //==========================================
                    //  else if both orgs are still pending we need to wait for both talkback interfaces to complete
                    else if (Trigger.isUpdate && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_PENDING 
                    && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_PENDING ) {
                        //  if update is coming from user check if any synced fields are being updated
                        if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            newOpp.Send_Mulesoft_Outbound_Msg__c = false;
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                String fieldAPI = sf.getFieldPath();
                                if (newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI)) {
                                    newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_3);             
                                    break;
                                }
                            }
                            // else allow the update (by doing nothing further in the trigger)         
                        }
                        //  if update is coming from Mulesoft as result of action in legacy IMS  or legacy Quintiles org trhow error that LQ Mulesoft sync is still pending
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ) {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_3);       
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);       
                        }
                    }                
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Pending
                    //  LQ_Mulesoft_Sync_Status__c: Failed
                    //==========================================
                    //  else if LI is pending and LQ has an error we need to wait for LI talkback and LQ slave update to correct the error                
                    else if (Trigger.isUpdate && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_PENDING 
                    && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED ) {      
                        //  if update is coming from user check if any synced fields are being updated
                        if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            newOpp.Send_Mulesoft_Outbound_Msg__c = false;
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                String fieldAPI = sf.getFieldPath();
                                if (newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI)) {
                                    //  If opp.LQ_Opportunity_Id__c is null, then insert on legacy org failed
                                    if(oppIdToMulesoftOppSyncMap.get(newOpp.id).LQ_Opportunity_Id__c == null) {
                                        newOpp.addError('Cannot update record while Legacy IMS Mulesoft sync is pending and insert of record in legacy Quintiles org failed.  The error from the legacy Quintiles org is: "' + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Error_Message__c + '".  Please contact CRM Support asking for manual Mulesoft syncing of the record at <a href="https://iqvia--crm.lightning.force.com/' + newOpp.Id + '">  https://iqvia--crm.lightning.force.com/' + newOpp.Id + '</a>', false);
                                        break;
                                    }
                                    // else update on legacy org failed
                                    else {
                                        newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_11 + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Error_Message__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + legacyLinkSetting.Legacy_Quintiles_URL__c + CON_CRM.FORWARDSLASH + newOpp.LQ_Opportunity_Id__c + System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_12);
                                        break;
                                    }
                                }
                            }
                            // else allow the update (by doing nothing further in the trigger)         
                        }  
                        //  else if the update is coming from LQ org to correct the error
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ) {  
                            //  Allow the update
                            //  i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                            //  and to set the Mulesoft_update_GUID__c from the other org          
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);         
                        }      
                    }                
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Failed
                    //  LQ_Mulesoft_Sync_Status__c: Completed
                    //==========================================
                    //  If LI sync status is failed we need to wait for successful update from LI org before allowing any further user or LQ SLAVE updates                
                    else if (Trigger.isUpdate && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED 
                    && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED ) {
                        //  if update is coming from user check if any synced fields are being updated
                        if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            newOpp.Send_Mulesoft_Outbound_Msg__c = false;
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                String fieldAPI = sf.getFieldPath();
                                if (newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI)) {
                                    //  If opp.LQ_Opportunity_Id__c is null, then insert on legacy org failed
                                    if(oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Opportunity_Id__c == null){
                                        newOpp.addError('Cannot update record due to failed insert of record in legacy IMS org.  The error from the legacy IMS org is: "' + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Error_Message__c + '".  Please contact CRM Support asking for manual Mulesoft syncing of the record at <a href="https://iqvia--crm.lightning.force.com/' + newOpp.Id + '">  https://iqvia--crm.lightning.force.com/' + newOpp.Id + '</a>', false);
                                        break;
                                    }
                                    else {
                                        newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_10 + '"' + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Error_Message__c + '." ' + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + ' https://' + legacyLinkSetting.Legacy_IMS_URL__c + CON_CRM.FORWARDSLASH + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Opportunity_Id__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_3);
                                        break;
                                    }                 
                                }
                            }
                            // else allow the update (by doing nothing further in the trigger)
                        }
                        //  if update is coming from Mulesoft as part of slave update from legacy Quintiles org
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ) {  
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_10 + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Error_Message__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + legacyLinkSetting.Legacy_IMS_URL__c + CON_CRM.FORWARDSLASH + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Opportunity_Id__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_3);                               
                        }
                        //  else if the update is coming from LI org to correct the error
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI ) {  
                            //  Allow the update
                            //  i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                            //  and to set the Mulesoft_update_GUID__c from the other org          
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);
                        }          
                    }                
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Failed
                    //  LQ_Mulesoft_Sync_Status__c: Pending
                    //==========================================
                    //  If LI sync status is failed we need to wait for successful update from LI org
                    //  If LQ sync status is pending, we need to wait for talkback
                    else if (Trigger.isUpdate && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED 
                    && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_PENDING ) {
                        //  if update is coming from user check if any synced fields are being updated
                        if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            newOpp.Send_Mulesoft_Outbound_Msg__c = false;
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                String fieldAPI = sf.getFieldPath();
                                if (newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI)) {
                                    //  If opp.LQ_Opportunity_Id__c is null, then insert on legacy org failed
                                    if(oppIdToMulesoftOppSyncMap.get(newOpp.id).LI_Opportunity_Id__c == null) {
                                        newOpp.addError('Cannot update record while legacy Quintiles Mulesoft sync is pending and failed insert of record in legacy IMS org.  The error from the legacy IMS org is: "' + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Error_Message__c + '".  Please contact CRM Support asking for manual Mulesoft syncing of the record at <a href="https://iqvia--crm.lightning.force.com/' + newOpp.Id + '">  https://iqvia--crm.lightning.force.com/' + newOpp.Id + '</a>', false);
                                        break;
                                    }
                                    else {
                                        newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_14 + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Error_Message__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + legacyLinkSetting.Legacy_IMS_URL__c + '/' + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Opportunity_Id__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_3);
                                        break;
                                    }
                                }
                            }
                            // else allow the update (by doing nothing further in the trigger)
                        }
                        //  else if the update is coming from LI org to correct the error
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI) { 
                            //  Allow the update
                            //  i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                            //  and to set the Mulesoft_update_GUID__c from the other org          
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);
                        }  
                    }                                
                    //==========================================
                    //  LI_Mulesoft_Sync_Status__c: Failed
                    //  LQ_Mulesoft_Sync_Status__c: Failed
                    //==========================================
                    //  If both legacy orgs have failed we need to wait for successful slave updates from both legacy orgs                
                    else if (Trigger.isUpdate && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED 
                    && oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED ) {
                        //  if update is coming from user check if any synced fields are being updated
                        if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_USER) {
                            newOpp.Send_Mulesoft_Outbound_Msg__c = false;
                            for(Schema.FieldSetMember sf : oppFieldMemberList) {
                                String fieldAPI = sf.getFieldPath();
                                if (newOpp.get(fieldAPI) != oldMap.get(newOpp.Id).get(fieldAPI)) {
                                    //  If opp.LI_Opportunity_Id__c is null, then insert on legacy org failed
                                    if(oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Opportunity_Id__c == null) {
                                        newOpp.addError('Cannot update record due failed insert of record in legacy IMS org.  The error from the legacy IMS org is: "' + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Error_Message__c + '".  Please contact CRM Support asking for manual Mulesoft syncing of the record at <a href="https://iqvia--crm.lightning.force.com/' + newOpp.Id + '">  https://iqvia--crm.lightning.force.com/' + newOpp.Id + '</a>', false);    
                                        break;
                                    }
                                    //  If opp.LQ_Opportunity_Id__c is null, then insert on legacy org failed
                                    if(oppIdToMulesoftOppSyncMap.get(newOpp.id).LQ_Opportunity_Id__c == null) {
                                        newOpp.addError('Cannot update record due failed insert of record in legacy Quintiles org.  The error from the legacy Quintiles org is: "' + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Error_Message__c + '".  Please contact CRM Support asking for manual Mulesoft syncing of the record at <a href="https://iqvia--crm.lightning.force.com/' + newOpp.Id + '">  https://iqvia--crm.lightning.force.com/' + newOpp.Id + '</a>',false);
                                        break;
                                    }
                                    if(oppIdToMulesoftOppSyncMap.get(newOpp.id).LQ_Opportunity_Id__c != null && oppIdToMulesoftOppSyncMap.get(newOpp.id).LI_Opportunity_Id__c != null) {
                                        newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_7 + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Mulesoft_Error_Message__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + legacyLinkSetting.Legacy_IMS_URL__c + CON_CRM.FORWARDSLASH + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LI_Opportunity_Id__c + System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_8 + oppIdToMulesoftOppSyncMap.get(newOpp.Id).LQ_Mulesoft_Error_Message__c + System.Label.CRM_CL0013_RECORD_UPDATE_ERROR_2 + legacyLinkSetting.Legacy_Quintiles_URL__c + CON_CRM.FORWARDSLASH + oppIdToMulesoftOppSyncMap.get(newOpp.Id).Lq_Opportunity_Id__c + System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_9);    
                                        break;
                                    }
                                }
                            }
                            // else allow the update (by doing nothing further in the trigger)
                        }  
                        //  else if the update is coming from LI org to correct the error
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LI) {  
                            //  Allow the update
                            //  i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                            //  and to set the Mulesoft_update_GUID__c from the other org          
                        }
                        //  else if the update is coming from LQ org to correct the error
                        else if (newOpp.Update_Type__c == CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE_LQ) {  
                            //  Allow the update
                            //  i.e do nothing further in this trigger and allow Mulesoft to set Mulesoft_Sync_Status = Complete
                            //  and to set the Mulesoft_update_GUID__c from the other org          
                        } else {
                            newOpp.addError(System.Label.CRM_CL0014_RECORD_UPDATE_ERROR_6 + newOpp.Update_Type__c);
                        } 
                    } 
                    CON_CRM.TEMP_UPDATE_TYPE_MULESOFT_SLAVE = newOpp.Update_Type__c;
                    //  Reset Update_Type__c so that any updates will have "USER" unless Mulesoft specifically sets this field
                    newOpp.Update_Type__c = CON_CRM.UPDATE_TYPE_USER;
                }
            }
        }       
    }
    
    /**
     * This method is used to set opportunity number during create and clone.
     * @params  newList List<Opportunity>
     * @return  void
     */
    public static void setClonedOpportunitiesNumerBlank(List<Opportunity> newList) {    
        for(Opportunity opp : newList) {
            if(!(Mulesoft_Integration_Control__c.getInstance().Allow_Opportunity_Number_Override__c)) {
                opp.Opportunity_Number__c = CON_CRM.EMPTY_STRING;
            }
        }
    }
    
    /**
     * This method is used to reset LI and LQ AccountId if account is updated.
     * @params  Map<Id, Opportunity> newMap
     * @params  Map<Id, Opportunity> oldMap
     * @return  void
     */
    public static void resetLegacyAccountId(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {    
        for(Opportunity opp : newMap.values()) {
            if (opp.AccountId != oldMap.get(opp.Id).AccountId) {
                opp.LI_Account_Id__c = null;
                opp.LQ_Account_Id__c = null;
            }
        }
    }
    
    /**
    * This method is used to validate BNF For opportunity Update.
    * @params  newMap Map<Id, Opportunity>
    * @params  oldMap Map<Id, Opportunity>
    * @return  void
    */
    public static void validationForProxyBNFApproval(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c && !CON_CRM.updateSkipValidation) {
            Set<String> fieldSet = new Set<String>{'Id','BNF_Status__c','Opportunity__c' ,'Revenue_Analyst_del__c','Revenue_Analyst_User_2__c','Revenue_Analyst_User_3__c','Revenue_Analyst_User_4__c',
                'Revenue_Analyst_User_5__c','Revenue_Analyst_User_6__c','Revenue_Analyst_User_7__c','Revenue_Analyst_User_8__c','Revenue_Analyst_User_9__c','Revenue_Analyst_User_10__c'};
                    Map<id, List<BNF2__c>> BNFMap = new Map<id, List<BNF2__c>>();
            List<BNF2__c> BNFList = new List<BNF2__c>();
            if(Trigger.isExecuting) {
                Set<Id> oppIdSet = new Set<Id>();
                for(Opportunity opp : newMap.values()) {
                    oppIdSet.add(opp.Id);             
                }
                String filterCondition = CON_CRM.OPPORTUNITY_API +' IN :oppIdSet '+ CON_CRM.AND_LOGIC + CON_CRM.RECORD_TYPE_NAME_API + ' IN (\''+ CON_CRM.SAP_SD_INTEGRATED +'\',\''+ CON_CRM.MIBNF + '\') ' + CON_CRM.AND_LOGIC + '(not ' + CON_CRM.BNF_STATUS_API  + ' IN (\'' + CON_CRM.STATUS_NEW +'\',\'' + CON_CRM.REJECTED   +'\',\''+ CON_CRM.RA_REJECTED  +'\',\''+ CON_CRM.SAP_CONTRACT_CONFIRMED  + '\',\''+ CON_CRM.LQ_REJECTEDQ +'\'))';
                BNFList = new SLT_BNF().selectByFilter(oppIdSet, fieldSet, filterCondition);
                if(BNFList.size() > 0){
                    for(BNF2__c BNF : BNFList) {
                        if(!BNFMap.containsKey(BNF.Opportunity__c)) {
                            BNFMap.put(BNF.Opportunity__c, new List<BNF2__c>());
                        }
                        BNFMap.get(BNF.Opportunity__c).add(BNF);
                    }
                    Map<Id, Set<Id>> oppIdToRevenueAnalystUsersSet = new Map<Id, Set<Id>>();
                    for(Id oppId : BNFMap.keySet()) {
                        List<BNF2__c> bnfsList = BNFMap.get(oppId);
                        Set<Id> userIds = new Set<Id>();
                        for(BNF2__c bnfObj : bnfsList) {
                            String count = 'del';
                            Integer countInt = 1;
                            while(countInt < 11) {
                                Object userId = bnfObj.get('Revenue_Analyst_'+ count +'__c');
                                if(userId != null) {
                                    userIds.add((Id)userId);
                                }
                                countInt++;
                                count =  'User_' + String.valueOf(countInt);
                            }
                        }
                        oppIdToRevenueAnalystUsersSet.put(oppId, userIds);
                    }
                    for(Opportunity opp : newMap.values()) {
                        if(BNFMap.containsKey(opp.id) && BNFMap.get(opp.id).size() > 0 && !oppIdToRevenueAnalystUsersSet.get(opp.Id).contains(UserInfo.getUserId())) {
                            opp.addError(System.Label.CRM_CL0015_RECORD_UPDATE_ERROR);    
                        }
                    }
                }else{
                    Set<String> fieldSetOfMIBNF = new Set<String>{'Id', 'Opportunity__c', 'BNF_Status__c', 'Comp_Revenue_Analyst__c', 'Comp_Revenue_Analyst_user_10__c', 'Comp_Revenue_Analyst_user_2__c', 'Comp_Revenue_Analyst_user_3__c', 'Comp_Revenue_Analyst_user_4__c',
                                'Comp_Revenue_Analyst_user_5__c', 'Comp_Revenue_Analyst_user_6__c', 'Comp_Revenue_Analyst_user_7__c', 'Comp_Revenue_Analyst_user_8__c', 'Comp_Revenue_Analyst_user_9__c', 'Comp_Revenue_Analyst_user__c'};
                    Map<id, List<MIBNF_Component__c>> MIBNFMap = new Map<id, List<MIBNF_Component__c>>();
                    List<MIBNF_Component__c> MIBNFList = new List<MIBNF_Component__c>();
                    filterCondition = CON_CRM.OPPORTUNITY_API +' IN :oppIdSet ' + CON_CRM.AND_LOGIC + '(not ' + CON_CRM.BNF_STATUS_API  + ' IN (\'' + CON_CRM.STATUS_NEW +'\',\'' + CON_CRM.REJECTED   +'\',\''+ CON_CRM.RA_REJECTED  +'\',\''+ CON_CRM.SAP_CONTRACT_CONFIRMED  + '\',\''+ CON_CRM.LQ_REJECTEDQ +'\'))';
                    MIBNFList = new SLT_MIBNF_Component().selectByFilter(oppIdSet, fieldSetOfMIBNF, filterCondition);
                    for(MIBNF_Component__c BNF : MIBNFList) {
                        if(!MIBNFMap.containsKey(BNF.Opportunity__c)) {
                            MIBNFMap.put(BNF.Opportunity__c, new List<MIBNF_Component__c>());
                        }
                        MIBNFMap.get(BNF.Opportunity__c).add(BNF);
                    }
                    Map<Id, Set<Id>> oppIdToRevenueAnalystUsersSet = new Map<Id, Set<Id>>();
                    for(Id oppId : MIBNFMap.keySet()) {
                        List<MIBNF_Component__c> bnfsList = MIBNFMap.get(oppId);
                        Set<Id> userIds = new Set<Id>();
                        for(MIBNF_Component__c bnfObj : bnfsList) {
                            String count = 'user';
                            Integer countInt = 1;
                            while(countInt < 11) {
                                Object userId = bnfObj.get('Comp_Revenue_Analyst_'+ count +'__c');
                                if(userId != null) {
                                    userIds.add((Id)userId);
                                }
                                countInt++;
                                count =  'User_' + String.valueOf(countInt);
                            }
                        }
                        oppIdToRevenueAnalystUsersSet.put(oppId, userIds);
                    }
                    for(Opportunity opp : newMap.values()) {
                        if(MIBNFMap.containsKey(opp.id) && MIBNFMap.get(opp.id).size() > 0 && !oppIdToRevenueAnalystUsersSet.get(opp.Id).contains(UserInfo.getUserId())) {
                            opp.addError(System.Label.CRM_CL0015_RECORD_UPDATE_ERROR);    
                        }
                    }
                }
            }
        }
    }
    
    /**
    * This method is used to prevent stage change of Opportunity for Proxy PA.
    * @params  newMap Map<Id, Opportunity>
    * @params  oldMap Map<Id, Opportunity>
    * @return  void
    */
    public static void validationOnOppForProxyPA(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(Trigger.isExecuting && !mulesoftSetting.Ignore_Validation_Rules__c) {
            Map<Id, Proxy_Pricing_Assistant__c> oppIdToProxyPAMap = new Map<Id, Proxy_Pricing_Assistant__c>();
            Set<String> fieldSet = new Set<String>{'Id', 'PA_Status__c', 'LI_Record_Id__c', 'Opportunity__c'};
                Set<Id> changedOppIds = new Set<Id>(); 
                For(Opportunity opp : newMap.values()){
                    if(opp.PA_Required__c && (opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE || opp.StageName == CON_CRM.RECEIVED_ATP_STAGE || opp.StageName == CON_CRM.CLOSED_WON_STAGE)){
                        changedOppIds.add(opp.Id);
                    }
                }
            
            List<Proxy_Pricing_Assistant__c> proxyBNFList = new List<Proxy_Pricing_Assistant__c>();
            if(changedOppIds.size() > 0){
                proxyBNFList = new SLT_ProxyPricingAssistant().selectByOpportunityIds(changedOppIds, fieldSet);
            }
            
            if(proxyBNFList.Size()>0){
                for (Proxy_Pricing_Assistant__c ppaRecord : proxyBNFList) {
                	oppIdToProxyPAMap.put(ppaRecord.Opportunity__c, ppaRecord);
                }
            }
            
            for (Opportunity newopp : newMap.values()) {
                if (newopp.PA_Required__c && (newOpp.StageName == CON_CRM.FINALIZING_DEAL_STAGE || newOpp.StageName == CON_CRM.RECEIVED_ATP_STAGE || newOpp.StageName == CON_CRM.CLOSED_WON_STAGE)) {
                    if (oppIdToProxyPAMap.containsKey(newopp.Id)) {
                        if(oppIdToProxyPAMap.get(newopp.Id).PA_Status__c != CON_CRM.PA_STATUS_APPROVED) {
                            newopp.addError(System.Label.CRM_CL0016_PROXY_PA_ERROR);
                        }
                    } else {
                        newopp.addError(System.Label.CRM_CL0016_PROXY_PA_ERROR2);
                    }
                }
            }
        }
    }

    /**
    * This method is used to populate Probabilty on opportunity based on OpportunityLineItem.
    * @params  newMap Map<Id, Opportunity>
    * @params  oldMap Map<Id, Opportunity>
    * @return  void
    */
    public static void populateProbabiltyOnOpportunity(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        if(Trigger.isExecuting) {
            Set<Id> oppIdSet = new Set<Id>();
            Boolean hasRNDProducts = false;
            Boolean hasNonRdsProducts = false;
            for(Opportunity opp : newMap.values()) {
                oppIdSet.add(opp.Id);   
            }            
            if(oppIdSet.size() > 0) {
                Set<String> oliFieldSet = new Set<String> {'Id', 'OpportunityId', 'PricebookEntry.Product2.Offering_Group_Code__c'};
                Set<String> oppFieldSet = new Set<String> {'Id', 'Probability', 'Path_Probability__c'};
                Map<Id, Opportunity> oppIdToLineItemMap = new SLT_Opportunity(true, false).selectByIdWithOpportuntiyLineItem(oppIdSet, oppFieldSet, oliFieldSet);
                for(Id opportunityId : oppIdToLineItemMap.keySet()) {
                    hasRNDProducts = false;
                    hasNonRdsProducts = false;
                    if(oppIdToLineItemMap.containsKey(opportunityId)) {
                        for(OpportunityLineItem oli : oppIdToLineItemMap.get(opportunityId).OpportunityLineItems) {
                            if (oli.PricebookEntry.Product2.Offering_Group_Code__c != null && oli.PricebookEntry.Product2.Offering_Group_Code__c == CON_CRM.PRODUCT_OFFERING_GROUP_CODE) {
                                hasRNDProducts = true;
                            }
                            if (oli.PricebookEntry.Product2.Offering_Group_Code__c != null && oli.PricebookEntry.Product2.Offering_Group_Code__c != CON_CRM.PRODUCT_OFFERING_GROUP_CODE) {
                                hasNonRdsProducts = true;
                            }
                        }
                    }
                    if (hasRNDProducts && !hasNonRdsProducts && oppIdToLineItemMap.containsKey(opportunityId)) {
                        if (newMap.get(opportunityId).Path_Probability__c == CON_CRM.VERBAL) {
                            newMap.get(opportunityId).Probability = CON_CRM.PERCENTAGE_VERBAL;
                        }
                        else if (newMap.get(opportunityId).Path_Probability__c == CON_CRM.CONFIDENT) {
                            newMap.get(opportunityId).Probability = CON_CRM.PERCENTAGE_CONFIDENT;
                        }
                        else if (newMap.get(opportunityId).Path_Probability__c == CON_CRM.POTENTIAL) {
                            newMap.get(opportunityId).Probability = CON_CRM.PERCENTAGE_POTENTIAL;
                        }
                        else if (newMap.get(opportunityId).Path_Probability__c == CON_CRM.ADVANCE_TO_POTENTIAL) {
                            newMap.get(opportunityId).Probability = CON_CRM.PERCENTAGE_ADVANCE_TO_POTENTIAL;
                        }
                        else if (newMap.get(opportunityId).Path_Probability__c == CON_CRM.ON_HOLD_FUNDING) {
                            newMap.get(opportunityId).Probability = CON_CRM.PERCENTAGE_ON_HOLD_FUNDING;
                        }
                        else if (newMap.get(opportunityId).Path_Probability__c == CON_CRM.ON_HOLD_DELAYED) {
                            newMap.get(opportunityId).Probability = CON_CRM.PERCENTAGE_ON_HOLD_DELAYED;
                        }
                    }
                }
            }
        }
    }
    
    /**
    * This method is used to validate Proxy SCM Agreement For opportunity Update.
    * @params  newMap Map<Id, Opportunity>
    * @params  oldMap Map<Id, Opportunity>
    * @return  void
    */
    /*
    public static void validationForProxySCMAgreement(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            Set<String> fieldSet = new Set<String>{'Id','Apttus_Status_c__c','LI_Record_Id__c','Opportunity__c','Record_Type_Name__c'};
            Map<id,List<Proxy_SCM_Agreement__c>> proxySCMAgreementMap = new Map<id,List<Proxy_SCM_Agreement__c>>();
            List<Proxy_SCM_Agreement__c> proxySCMAgreementList = new List<Proxy_SCM_Agreement__c>();
            if(Trigger.isExecuting) {
                Set<Id> oppIdSet = new Set<Id>();
                for(Opportunity opp : newMap.values()) {
                    If(opp.StageName != oldMap.get(opp.id).StageName || opp.Contract_End_Date__c != oldMap.get(opp.id).Contract_End_Date__c || opp.Contract_Start_Date__c != oldMap.get(opp.id).Contract_Start_Date__c || opp.AccountId != oldMap.get(opp.id).AccountId ){
                        oppIdSet.add(opp.Id); 
                    }
                                
                }
                String filterCondition = CON_CRM.OPPORTUNITY_API +' IN :oppIdSet '+ CON_CRM.AND_LOGIC + CON_CRM.AGREEMENT_RECORD_TYPE_NAME_API + ' IN (\''+ CON_CRM.SOW_AGREEMENT_RECORD_TYPE + '\') ' + CON_CRM.AND_LOGIC + ' ' + CON_CRM.AGREEMENT_STATUS_API  + ' IN (\'' + CON_CRM.ACTIVATED + '\')';
                if(oppIdSet.Size() > 0){
                    proxySCMAgreementList = new SLT_ProxySCMAgreement().selectByFilter(oppIdSet, fieldSet, filterCondition);
                }
                
                if(proxySCMAgreementList.Size() > 0){
                    for(Proxy_SCM_Agreement__c scmAgreement : proxySCMAgreementList) {
                        if(!proxySCMAgreementMap.containsKey(scmAgreement.Opportunity__c)) {
                            proxySCMAgreementMap.put(scmAgreement.Opportunity__c, new List<Proxy_SCM_Agreement__c>());
                        }
                        proxySCMAgreementMap.get(scmAgreement.Opportunity__c).add(scmAgreement);
                    } 
                }
                
                if(proxySCMAgreementMap.size() > 0){
                    for(Opportunity opp : newMap.values()) {
                        if( proxySCMAgreementMap.containsKey(opp.id) && proxySCMAgreementMap.get(opp.id).size() > 0) {
                            if(newMap.get(opp.id).StageName != oldMap.get(opp.id).StageName && newMap.get(opp.id).StageName == CON_CRM.CLOSED_LOST_STAGE) {
                                opp.addError(System.Label.CRM_CL0017_PROXY_AGREEMENT_ERROR1);    
                            }
                            else if(newMap.get(opp.id).Contract_Start_Date__c != oldMap.get(opp.id).Contract_Start_Date__c) {
                                opp.addError(System.Label.CRM_CL0017_PROXY_AGREEMENT_ERROR2);    
                            }
                            else if(newMap.get(opp.id).Contract_End_Date__c != oldMap.get(opp.id).Contract_End_Date__c) {
                                opp.addError(System.Label.CRM_CL0017_PROXY_AGREEMENT_ERROR3);    
                            }
                            else if(newMap.get(opp.id).AccountId != oldMap.get(opp.id).AccountId) {
                                opp.addError(System.Label.CRM_CL0017_PROXY_AGREEMENT_ERROR4);    
                            }
                        }                   
                    }   
                }  
            }
        }
    }
	*/
    
    /**
    * This method is used to populate Fields on opportunity.
    * @params  List<Opportunity> newList
    * @return  void
    */
    public static void setOppFields(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        
        Set<String> opp1To4StageSet = new Set<String>();
        opp1To4StageSet.add(CON_CRM.IDENTIFYING_OPP_STAGE);
        opp1To4StageSet.add(CON_CRM.QUALIFYING_OPP_STAGE);
        opp1To4StageSet.add(CON_CRM.DEVELOPING_PROP_STAGE);
        opp1To4StageSet.add(CON_CRM.DELIVERING_PROP_STAGE);
        opp1To4StageSet.add(CON_CRM.CLOSED_LOST_STAGE);
        
        Set<String> opp5To7aStageSet = new Set<String>();
        opp5To7aStageSet.add(CON_CRM.FINALIZING_DEAL_STAGE);
        opp5To7aStageSet.add(CON_CRM.RECEIVED_ATP_STAGE);
        opp5To7aStageSet.add(CON_CRM.CLOSED_WON_STAGE);
        
        Map<Id, Opportunity> opportunityWithLineItemMap = null;
        if(Trigger.isUpdate) {
            String oliCondition = 'Product_Material_Type__c != \'ZQUI\'';
            Set<String> oppFieldSet = new Set<String>{'Id'};
            Set<String> oliFieldSet = new Set<String>{'Id', 'Delivery_Country__c'};
            opportunityWithLineItemMap = new SLT_Opportunity().selectByIdWithOpportuntiyLineItemFilter(oldMap.keySet(), oppfieldSet, oliFieldSet, oliCondition, 1);
        }
        for(Opportunity opp : newList) {
            
            /* ESPSFDCQI - 17406 
             Copy Binary_Decision__c to Sales_Leadership_Binary_Decision__c if Sales_Leadership_Binary_Decision__c is not null */
            
            if (opp.Binary_Decision__c != null && opp.Sales_Leadership_Binary_Decision__c == null) {
                opp.Sales_Leadership_Binary_Decision__c = opp.Binary_Decision__c;
            }
			
            if(opp.Line_of_Business__c == 'Avacare'){
                opp.Opportunity_Sharing_Business_Unit__c = 'Avacare';
            }else if((new Set<String>{'EPG','EPG Collaborative','EPG IME'}).Contains(opp.Owner_User_Type__c)){
                opp.Opportunity_Sharing_Business_Unit__c = opp.Owner_User_Type__c ;
            } else {
                opp.Opportunity_Sharing_Business_Unit__c = 'IQVIA';
            }
            if(opp.Requires_Deal_Desk_Approval__c == 'No' && (Trigger.isInsert || Trigger.isUpdate && opp.Requires_Deal_Desk_Approval__c != oldMap.get(opp.Id).Requires_Deal_Desk_Approval__c)){
                   opp.Deal_Desk_Status__c = 'NA';
            }
            if(opp.StageName == CON_CRM.IDENTIFYING_OPP_STAGE || opp.StageName == CON_CRM.QUALIFYING_OPP_STAGE || opp.StageName == CON_CRM.DEVELOPING_PROP_STAGE || opp.StageName == CON_CRM.DELIVERING_PROP_STAGE) {
                opp.Reopen_Awarded_Opp_Approval__c = null;
            }
            if(Trigger.isUpdate && opp.Parent_Opportunity__c != oldMap.get(opp.Id).Parent_Opportunity__c && opp.Parent_Opportunity__c == NULL) {
                opp.Ultimate_Parent_Opportunity_Number__c = opp.Opportunity_Auto_Number__c;
            }
            Set<String> stageSet = new Set<String>{CON_CRM.RECEIVED_ATP_STAGE, CON_CRM.CLOSED_WON_STAGE, CON_CRM.CLOSED_LOST_STAGE, CON_CRM.IN_HAND_STAGE};
            if(trigger.isInsert || (trigger.isUpdate && oldMap.get(opp.Id).stageName != opp.stageName)) {
                if(opp.stageName == CON_CRM.RECEIVED_ATP_STAGE || opp.stageName == CON_CRM.CLOSED_WON_STAGE || opp.stageName == CON_CRM.IN_HAND_STAGE){
                    opp.Forecast_Category__c = CON_CRM.CLOSED_FORECAST_CATEGORY;
                }
                else if(opp.stageName == CON_CRM.CLOSED_LOST_STAGE) {
                    opp.Forecast_Category__c = CON_CRM.OMITTED_FORECAST_CATEGORY;
                }
                else if(oldMap != null && stageSet.contains(oldMap.get(opp.Id).stageName) && !stageSet.contains(opp.stageName)){
                    opp.Forecast_Category__c = CON_CRM.PIPELINE_FORECAST_CATEGORY;
                }
            }
            if(opp.Forecast_Category__c != null) {
                if(opp.Forecast_Category__c == CON_CRM.ON_TRACK) {
                    opp.ForecastCategoryName = CON_CRM.BEST_CASE;
                } else {
                    opp.ForecastCategoryName = opp.Forecast_Category__c;
                }
            }
            if(trigger.isUpdate) {
                /*Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
                Set<Id> idSet = new Set<Id>{UserInfo.getUserId()};
                Set<String> fieldSet = new Set<String>{'Profile.Name'};
                Map<Id, User> idUserMap = new SLT_User().selectByUserId(idSet, fieldSet);
                String profileName = idUserMap.get(UserInfo.getUserId()).Profile.Name;*/
                //  Check if opp is being closed and actual_close_date__c is currently null
                if(oldMap.get(opp.Id).IsClosed != opp.IsClosed && opp.IsClosed && opp.Actual_Close_Date__c == null) {
                    opp.Actual_Close_Date__c = system.today();
                }
                //  Check if opp is being re-opened by user who is not operations, sys admin or mulesoft
                /*if (oldMap.get(opp.Id).IsClosed != opp.IsClosed && opp.IsClosed == FALSE 
                    && !profileName.containsIgnoreCase(CON_CRM.SYSTEM_ADMIN_PROFILE) 
                    && !profileName.containsIgnoreCase(CON_CRM.COMMERCIAL_OPERATION_PROFILE)
                    && !mulesoftSetting.Is_Mulesoft_User__c) {
                    opp.Actual_Close_Date__c = null;
                }*/
                if(opp.StageName != oldMap.get(opp.id).StageName && opp.StageName == CON_CRM.IN_HAND_STAGE && opp.In_Hand_Stage_Entry__c == null) {
                    opp.In_Hand_Stage_Entry__c = System.today();   
                    opp.In_Hand_Stage_Entry_DateTime__c = System.now();
                }
                // Populate Main_Delivery_Country__c on Update
                if(opportunityWithLineItemMap.containsKey(opp.Id) && opportunityWithLineItemMap.get(opp.Id).OpportunityLineItems.size() > 0) {
                    String deliveryCountry = opportunityWithLineItemMap.get(opp.Id).OpportunityLineItems[0].Delivery_Country__c;
                    if(deliveryCountry != null && Delivery_Country_Mapping__c.getValues(deliveryCountry) != null) {
                        if(Delivery_Country_Mapping__c.getValues(deliveryCountry).Main_Delivery_Country__c != null) {
                            opp.Main_Delivery_Country__c = Delivery_Country_Mapping__c.getValues(deliveryCountry).Main_Delivery_Country__c;
                        }
                        if(Delivery_Country_Mapping__c.getValues(deliveryCountry).Business_Unit__c != null) {
                            opp.Business_Unit__c = Delivery_Country_Mapping__c.getValues(deliveryCountry).Business_Unit__c;
                        }
                    }
                }
                // Set RM Sync Date field on Opportunity:ESPSFDCQI-16014
                if(opp.StageName != oldMap.get(opp.id).StageName &&( ((opp1To4StageSet.contains(oldMap.get(opp.id).StageName) && oldMap.get(opp.id).StageName != CON_CRM.CLOSED_LOST_STAGE ) && (opp5To7aStageSet.contains(opp.StageName) || opp.StageName == CON_CRM.IN_HAND_STAGE) ) ||
                   ( (oldMap.get(opp.id).StageName == CON_CRM.FINALIZING_DEAL_STAGE || oldMap.get(opp.id).StageName == CON_CRM.RECEIVED_ATP_STAGE) && (opp.StageName == CON_CRM.CLOSED_WON_STAGE || opp.StageName == CON_CRM.IN_HAND_STAGE) ) )){
                    opp.RM_Sync_Date__c = System.now();
                }
                //Deal Desk Re-Open of Opportunity fix
                Set<String> oppReopenStageSet = new Set<String>();
                oppReopenStageSet.add(CON_CRM.CLOSED_WON_STAGE);
                oppReopenStageSet.add(CON_CRM.CLOSED_LOST_STAGE);
                oppReopenStageSet.add(CON_CRM.IN_HAND_STAGE);
                
                if(opp.StageName != oldMap.get(opp.Id).StageName && (oppReopenStageSet.contains(oldMap.get(opp.Id).StageName) && !oppReopenStageSet.contains(opp.StageName))){
                    opp.Deal_Desk_Status__c = 'Open';
                    opp.Deal_Desk_Initial_Approval_Date__c = null;
                    opp.Deal_Desk_Submitter__c = null;
                } 
            }
            if((Trigger.isInsert &&  opp.Transferred_to_Field_Sales__c) || opp.Transferred_to_Field_Sales__c && opp.Transferred_to_Field_Sales__c != oldMap.get(opp.Id).Transferred_to_Field_Sales__c) {
                opp.Transferred_to_Field_Sales_Date__c = System.now();
            }
            if(Trigger.isInsert && opp.Actual_Close_Date__c == null && (opp.StageName == CON_CRM.CLOSED_WON_STAGE || opp.StageName == CON_CRM.CLOSED_LOST_STAGE || opp.StageName == CON_CRM.IN_HAND_STAGE)) {
                opp.Actual_Close_Date__c = System.today();
            }
            if ((Trigger.isInsert && opp.Advanced_Plan__c != null) || (Trigger.isUpdate && opp.Advanced_Plan__c != oldMap.get(opp.Id).Advanced_Plan__c)) {
                opp.Advance_Plan_last_update_date__c = System.today();
            }

            if(Trigger.isBefore){
                if(opp.Line_of_Business__c == null){
                    if(opp.Current_User_Profile__c == 'RWS User'){								
                        opp.Line_of_Business__c = 'Outcome';
                    }									  
                }
                
                if(opp.Line_of_Business__c == 'Outcome' || opp.Line_of_Business__c == 'RWLP' || opp.Line_of_Business__c == 'Medical Affairs' || opp.Line_of_Business__c == 'Tech & Data'){
                   // To auto populate Awarded Date in case of LOB = 'Outcome' && if Awarded date is not set already  
                    if(Trigger.isInsert && opp5To7aStageSet.contains(opp.StageName) && opp.Awarded_Date__c==null){
                        opp.Awarded_Date__c =  System.today();
                    }
    
                    // To auto populate Awarded Date in case of LOB = 'Outcome' && if Awarded date is not set already
                    if(Trigger.isUpdate && opp.StageName != oldMap.get(opp.id).StageName && opp5To7aStageSet.contains(opp.StageName) && opp.Awarded_Date__c==null){
                        opp.Awarded_Date__c =  System.today();
                    }
                    
                    if(opp.Is_this_IQVIA_Biotech__c == null){
                        opp.Is_this_IQVIA_Biotech__c = 'No';
                    }
                    
                    if(Trigger.isInsert){
                        if(opp.Phase_P__c == null){
                        	opp.Phase_P__c = 'Phase 4';
                        }
                        if(opp.Global_project_unit__c == null){
                            if(opp.Line_of_Business__c == 'RWLP'){
                        		opp.Global_project_unit__c = 'Late Phase';
                            } else if(opp.Line_of_Business__c == 'Medical Affairs'){
                                opp.Global_project_unit__c = 'Medical Affairs';
                            } else if(opp.Line_of_Business__c == 'Tech & Data'){
                                opp.Global_project_unit__c = 'Tech and Data'; 
                            }
                        }
                        if(opp.FSP__c == null){
                        	opp.FSP__c = 'No';
                        }
                        if(opp.US_government_fully_or_partially_funded__c == null && opp.Line_of_Business__c == 'Tech & Data'){
                            opp.US_government_fully_or_partially_funded__c = 'No';
                        }
                    }
					
                    if(Trigger.isUpdate && opp.Line_of_Business__c != oldMap.get(opp.id).Line_of_Business__c){
                        if(opp.Phase_P__c == null && opp.Phase_P__c == oldMap.get(opp.id).Phase_P__c){
                            opp.Phase_P__c = 'Phase 4';
                        }
                        if(opp.Global_project_unit__c == null && opp.Global_project_unit__c == oldMap.get(opp.id).Global_project_unit__c && opp.Line_of_Business__c != 'Tech & Data'){
                            opp.Global_project_unit__c = 'Late Phase';
                        } else if(opp.Global_project_unit__c == null && opp.Global_project_unit__c == oldMap.get(opp.id).Global_project_unit__c && opp.Line_of_Business__c == 'Tech & Data'){
                            opp.Global_project_unit__c = 'Tech and Data';
                        }
                        if(opp.FSP__c == null && opp.FSP__c == oldMap.get(opp.id).FSP__c){
                            opp.FSP__c = 'No';
                        }
                        if(opp.US_government_fully_or_partially_funded__c == null && opp.US_government_fully_or_partially_funded__c == oldMap.get(opp.id).US_government_fully_or_partially_funded__c && opp.Line_of_Business__c == 'Tech & Data'){
                            opp.US_government_fully_or_partially_funded__c = 'No';
                        }
                    }
                }
                
				//set Must win opportunity for RWLP line of business - ESPSFDCQI-16378
                if(opp.Line_of_Business__c == 'RWLP' && (Trigger.isInsert || Trigger.isUpdate) && opp.Amount_In_USD__c >= 1000000){
                    opp.Must_Win_Opportunity__c = true;
                }
                else if(opp.Line_of_Business__c == 'RWLP' && (Trigger.isInsert || Trigger.isUpdate) && opp.Amount_In_USD__c < 1000000){
                    opp.Must_Win_Opportunity__c = false;
                }
				
				//set must win opportunity for Medical Affairs Line of business ESPSFDCQI-17270
                if(opp.Line_of_Business__c == 'Medical Affairs' && (Trigger.isInsert || Trigger.isUpdate) && opp.Amount_In_USD__c >= 200000){
                    opp.Must_Win_Opportunity__c = true;
                }
                else if(opp.Line_of_Business__c == 'Medical Affairs' && (Trigger.isInsert || Trigger.isUpdate) && opp.Amount_In_USD__c < 200000){
                    opp.Must_Win_Opportunity__c = false;
                }
                
                //set must win for Tech & Data line of business
                if(opp.Line_of_Business__c == 'Tech & Data' && (Trigger.isInsert || Trigger.isUpdate) && opp.Amount_In_USD__c >= 1000000){
                    opp.Must_Win_Opportunity__c = true;
                }
                else if(opp.Line_of_Business__c == 'Tech & Data' && (Trigger.isInsert || Trigger.isUpdate) && opp.Amount_In_USD__c < 1000000){
                    opp.Must_Win_Opportunity__c = false;
                }
                
                if(Trigger.isInsert){
                    if(opp.Line_of_Business__c != 'Clinical Technology' && opp.Will_be_Contracted_via_CO__c == null){
                        opp.Will_be_Contracted_via_CO__c = 'No';
                    }
                }
                
                // To remove Awarded_Date__c if LOB is updated to anything from 'Outcome' in stage 1-4 & 7b
                if(Trigger.isUpdate && opp.Line_of_Business__c != oldMap.get(opp.id).Line_of_Business__c && (oldMap.get(opp.id).Line_of_Business__c == 'Outcome' || oldMap.get(opp.id).Line_of_Business__c == 'RWLP' || oldMap.get(opp.id).Line_of_Business__c == 'Medical Affairs' || oldMap.get(opp.id).Line_of_Business__c == 'Tech & Data') && opp1To4StageSet.contains(opp.stageName)){
                    opp.Awarded_Date__c = null;
                }
                
                if(opp.Line_of_Business__c == 'Outcome' || opp.Line_of_Business__c == 'IT Services' || opp.Line_of_Business__c == 'RWLP' || opp.Line_of_Business__c == 'Medical Affairs' || opp.Line_of_Business__c == 'Tech & Data'){

                    if((Trigger.isInsert && opp.Path_Probability__c == null) || (Trigger.isUpdate && opp.Probability != oldMap.get(opp.id).Probability && opp.Path_Probability__c == oldMap.get(opp.id).Path_Probability__c)) {
                        if(opp.Probability <= 25){
                            opp.Path_Probability__c = 'Advance to Potential';
                        }else if(opp.Probability <= 50){
                            opp.Path_Probability__c = 'Potential';
                        }else if(opp.Probability <= 90){
                            opp.Path_Probability__c = 'Confident';
                        }else{
                            opp.Path_Probability__c = 'Verbal';
                        }
                    }

                }
                List<Schema.FieldSetMember> partnerFieldSet = Schema.SObjectType.Opportunity.fieldSets.Opportunity_Partner_Field_Set.getFields();
                for(Schema.FieldSetMember fsm : partnerFieldSet){
                    if((Trigger.isInsert && opp.get(fsm.getFieldPath()) != null) || (Trigger.isUpdate && opp.get(fsm.getFieldPath()) != oldMap.get(opp.id).get(fsm.getFieldPath()))){
                        opp.Partner_Fields_Last_Modified_Date__c = System.today();
                        opp.Partner_Fields_Last_Modified_By__c = UserInfo.getUserId();
                        break;
                    }
                }
            }
            
            /*if(Trigger.isInsert) {
                List<User> userList = new SLT_User().selectById(new Set<Id>{UserInfo.getUserId()});
                if(userList[0].User_Country__c != null){
                    opp.Main_Delivery_Country__c = userList[0].User_Country__c;
                } 
            }*/
            opp.Real_World_Categories_Text__c = opp.Real_World_Categories__c; //ESPSFDCQI-8524
        }
    }
    
    
    /**
     * This method is used to PA validation.
     * @params  Map<Id, Opportunity> newMap
     * @params  Map<Id, Opportunity> oldMap
     * @return  void
     */
    /*public static void excludePACheck(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        //  Exclude mulesoft and sys admin profiles from teh validation
        Set<Id> idSet = new Set<Id>{UserInfo.getUserId()};
        Set<String> fieldSet = new Set<String>{'Profile.Name'};
        Map<Id, User> idUserMap = new SLT_User().selectByUserId(idSet, fieldSet);
        String profileName = idUserMap.get(UserInfo.getUserId()).Profile.Name;
        if(!mulesoftSetting.Ignore_Validation_Rules__c && !profileName.containsIgnoreCase(CON_CRM.SYSTEM_ADMIN_PROFILE)) {
            //  Get a map of all Proxy_Project records related to the opp
            Map<Id,Proxy_Project__c> ProxyProject_Map = new Map<Id,Proxy_Project__c>();
            //  Find if there is at least 1 billable project related to the opportunity
            idSet = new Set<Id>(newMap.keyset());
            fieldSet = new Set<String>{'Id', 'Project_Status__c', 'Record_Type_Name__c', 'Opportunity__c'};
            for(Proxy_Project__c prx : new SLT_Proxy_Project().selectByFilter(idSet, fieldSet)){
                ProxyProject_Map.put(prx.Opportunity__c, prx);
            }         
            for (Opportunity opp : newMap.values()){          
                //  If Proxy_Project exists and user is attempting to change the Exclude_From_Pricing_Assistant__c field, then throw an error
                if (ProxyProject_Map.containsKey(opp.Id)){
                    if (opp.Exclude_from_Pricing_Assistant__c != oldMap.get(opp.Id).Exclude_from_Pricing_Assistant__c){
                        //This validtion run only for sys admin in li so commenting for now
                        //opp.addError(SYSTEM.LABEL.CRM_CL0018_PROXY_PROJECT_ERROR);
                    }
                }
            }
        }
    }
*/
    
    /**
     * This method is used to set Bid Team Split.
     * @params  newList List<Opportunity>
     * @params  oldMap Map<Id, Opportunity>
     * @return  void
     */
    public static void setBidTeamSplit(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        // Bid team splits must not be re-calculated when Mulesoft updates come in.  For Mulesoft updates the values must be taken as is.
        if (mulesoftSetting.Is_Mulesoft_User__c == false){     
            // Check whether current user has permissions to update split fields (operations do have update permissions, sales do not)
            Schema.DescribeFieldResult dfr = Opportunity.Principal_In_Charge_Split__c.getDescribe();
            Boolean UserCanUpdateSplit = dfr.isUpdateable();
            for(Opportunity opp : newList) {
                Map<Integer, Id> bidTeamNewMap = new Map<Integer, Id>();
                Map<Integer, Decimal> bidTeamSplitNewMap = new Map<Integer, Decimal>();
                Map<Integer, Id> bidTeamOldMap = new Map<Integer, Id>();
                Map<Integer, Decimal> bidTeamSplitOldMap = new Map<Integer, Decimal>();
                
                bidTeamNewMap.put(1, opp.Principle_inCharge__c);
                bidTeamSplitNewMap.put(1, opp.Principal_In_Charge_Split__c);
                
                bidTeamNewMap.put(2, opp.BidTeam_2__c);
                bidTeamSplitNewMap.put(2, opp.Bid_Team_2_Split__c);
                
                bidTeamNewMap.put(3, opp.BidTeam_3__c);
                bidTeamSplitNewMap.put(3, opp.Bid_Team_3_Split__c);
                
                bidTeamNewMap.put(4, opp.BidTeam_4__c);
                bidTeamSplitNewMap.put(4, opp.Bid_Team_4_Split__c);
                
                bidTeamNewMap.put(5, opp.BidTeam_5__c);
                bidTeamSplitNewMap.put(5, opp.Bid_Team_5_Split__c);
                
                bidTeamNewMap.put(6, opp.BidTeam_6__c);
                bidTeamSplitNewMap.put(6, opp.Bid_Team_6_Split__c);
                
                bidTeamNewMap.put(7, opp.BidTeam_7__c);
                bidTeamSplitNewMap.put(7 ,opp.Bid_Team_7_Split__c);
                
                bidTeamNewMap.put(8, opp.BidTeam_8__c);
                bidTeamSplitNewMap.put(8, opp.Bid_Team_8_Split__c);
                
                if(trigger.IsUpdate) {
                    bidTeamOldMap.put(1, oldmap.get(opp.Id).Principle_inCharge__c);
                    bidTeamSplitOldMap.put(1, oldmap.get(opp.Id).Principal_In_Charge_Split__c);
                    
                    bidTeamOldMap.put(2, oldmap.get(opp.Id).BidTeam_2__c);
                    bidTeamSplitOldMap.put(2, oldmap.get(opp.Id).Bid_Team_2_Split__c);
                    
                    bidTeamOldMap.put(3, oldmap.get(opp.Id).BidTeam_3__c);
                    bidTeamSplitOldMap.put(3, oldmap.get(opp.Id).Bid_Team_3_Split__c);
                    
                    bidTeamOldMap.put(4, oldmap.get(opp.Id).BidTeam_4__c);
                    bidTeamSplitOldMap.put(4, oldmap.get(opp.Id).Bid_Team_4_Split__c);
                    
                    bidTeamOldMap.put(5, oldmap.get(opp.Id).BidTeam_5__c);
                    bidTeamSplitOldMap.put(5, oldmap.get(opp.Id).Bid_Team_5_Split__c);
                    
                    bidTeamOldMap.put(6, oldmap.get(opp.Id).BidTeam_6__c);
                    bidTeamSplitOldMap.put(6, oldmap.get(opp.Id).Bid_Team_6_Split__c);
                    
                    bidTeamOldMap.put(7, oldmap.get(opp.Id).BidTeam_7__c);
                    bidTeamSplitOldMap.put(7, oldmap.get(opp.Id).Bid_Team_7_Split__c);
                    
                    bidTeamOldMap.put(8, oldmap.get(opp.Id).BidTeam_8__c);
                    bidTeamSplitOldMap.put(8, oldmap.get(opp.Id).Bid_Team_8_Split__c);
                }
                
                //Boolean bidTeamMemberChanged = false;
                Boolean recalculateSplits = false;
                Integer bitTeamMemberCount = 0;
                Decimal totalSplitAmount = 0;
                for(Integer i = 0; i <= 8; i++){
                    //  Check if BT member has been changed or opp is being inserted
                    if (trigger.isInsert || bidTeamNewMap.get(i) != bidTeamOldMap.get(i)){
                        //  If new BT member is non-null
                        if (bidTeamNewMap.get(i) != null){
                            //  Check if split is null or if bid team member has been changed by Sales User who does not have permission to update splits
                            if (bidTeamSplitNewMap.get(i) == null || !UserCanUpdateSplit){
                                recalculateSplits = true;
                            }
                        }
                        //  If new BT member is null and split is non-null, then ensure splits are recalculated
                        if (bidTeamNewMap.get(i) == null && bidTeamSplitNewMap.get(i)  != null){
                            recalculateSplits = true;
                        }              
                    }
                    //  Count the number of Bid Team members on the opportunity
                    if (bidTeamNewMap.get(i) != null){
                        bitTeamMemberCount++;
                    }  
                    //  Add all split amounts to get the total split
                    if (bidTeamSplitNewMap.get(i) != null){
                        totalSplitAmount += bidTeamSplitNewMap.get(i);
                    }
                }
                if (recalculateSplits == false){
                    if (totalSplitAmount > 100){
                        //  Add the error to the PIC split field to draw the users' attention to the section where all splits are maintained
                        opp.Principal_In_Charge_Split__c.addError(System.Label.CRM_CL0019_BID_TEAM_ERROR);
                    }
                }
                else if (recalculateSplits == true){
                    //  First set all splits to null
                    opp.Principal_In_Charge_Split__c = null;
                    opp.Bid_Team_2_Split__c = null;
                    opp.Bid_Team_3_Split__c = null;
                    opp.Bid_Team_4_Split__c = null;
                    opp.Bid_Team_5_Split__c = null;
                    opp.Bid_Team_6_Split__c = null;
                    opp.Bid_Team_7_Split__c = null;
                    opp.Bid_Team_8_Split__c = null;
                    if (bitTeamMemberCount == 1){
                        opp.Principal_In_Charge_Split__c = 100;
                    }
                    else if (bitTeamMemberCount == 2){
                        opp.Principal_In_Charge_Split__c = 50;
                        opp.Bid_Team_2_Split__c  = 50;
                    }
                    else if (bitTeamMemberCount == 3){
                        opp.Principal_In_Charge_Split__c = 33.34;
                        opp.Bid_Team_2_Split__c  = 33.33;
                        opp.Bid_Team_3_Split__c  = 33.33;
                    }
                    else if (bitTeamMemberCount == 4){
                        opp.Principal_In_Charge_Split__c = 25;
                        opp.Bid_Team_2_Split__c  = 25;
                        opp.Bid_Team_3_Split__c  = 25;
                        opp.Bid_Team_4_Split__c  = 25;
                    }
                    else if (bitTeamMemberCount == 5){
                        opp.Principal_In_Charge_Split__c = 20;
                        opp.Bid_Team_2_Split__c  = 20;
                        opp.Bid_Team_3_Split__c  = 20;
                        opp.Bid_Team_4_Split__c  = 20;
                        opp.Bid_Team_5_Split__c  = 20;
                    }
                    else if (bitTeamMemberCount == 6){
                        opp.Principal_In_Charge_Split__c = 16.70;
                        opp.Bid_Team_2_Split__c  = 16.66;
                        opp.Bid_Team_3_Split__c  = 16.66;
                        opp.Bid_Team_4_Split__c  = 16.66;
                        opp.Bid_Team_5_Split__c  = 16.66;
                        opp.Bid_Team_6_Split__c  = 16.66;
                    }
                    else if (bitTeamMemberCount == 7){
                        opp.Principal_In_Charge_Split__c = 14.32;
                        opp.Bid_Team_2_Split__c  = 14.28;
                        opp.Bid_Team_3_Split__c  = 14.28;
                        opp.Bid_Team_4_Split__c  = 14.28;
                        opp.Bid_Team_5_Split__c  = 14.28;
                        opp.Bid_Team_6_Split__c  = 14.28;
                        opp.Bid_Team_7_Split__c  = 14.28;
                    }
                    else if (bitTeamMemberCount == 8){
                        opp.Principal_In_Charge_Split__c = 12.5;
                        opp.Bid_Team_2_Split__c  = 12.5;
                        opp.Bid_Team_3_Split__c  = 12.5;
                        opp.Bid_Team_4_Split__c  = 12.5;
                        opp.Bid_Team_5_Split__c  = 12.5;
                        opp.Bid_Team_6_Split__c  = 12.5;
                        opp.Bid_Team_7_Split__c  = 12.5;
                        opp.Bid_Team_8_Split__c  = 12.5;
                    }              
                }
            }
        }
    }
    
    /**
     * This method is check has LQ Material Products
     * @params  newMap Map<Id, Opportunity>
     * @return  void
     */
    public static void hasLQMaterialProducts(Map<Id, Opportunity> newMap) {
        /*Map<Id, OpportunityLineItem> idToOLIMap = new Map<Id, OpportunityLineItem>();
        List<OpportunityLineItem> lqOLIList = new List<OpportunityLineItem>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp : newMap.values()) {
            opp.Show_LQ_Error__c = false;
            oppIdSet.add(opp.Id);
        }
        Set<String> fieldSet = new Set<String>{'Id', 'OpportunityId','pricebookEntry.Product2.Material_Type__c', 'pricebookEntry.Product2.Hierarchy_Level__c'};
        idToOLIMap = new SLT_OpportunityLineItems().selectByOpportunityId(oppIdSet, fieldSet);
        for(OpportunityLineItem oli : idToOLIMap.values()) {
            if(oli.pricebookEntry.Product2.Material_Type__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZQUI && oli.pricebookEntry.Product2.Hierarchy_Level__c == CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI) {
                lqOLIList.add(oli);
            }
        }
        for(OpportunityLineItem oli : lqOLIList) {
            Opportunity opp = newMap.get(oli.OpportunityId);
            if(opp.LQ_User_Save_Timestamp__c == null) {
                //opp.Show_LQ_Error__c = true;
            }
        }*/
    }
    
    /**
    * This method is used to reset the trigger execution variables based on the change in new list size.
    * @params  List<OpportunityLineItem> oliList
    * @return  void
    */
    public static void resetTriggerExecutionFlag(List<Opportunity> oppList) {
        if(CON_CRM.OPP_NEW_LIST_OLD_COUNT == 0) {
            CON_CRM.OPP_NEW_LIST_OLD_COUNT = oppList.size();
        }
        if(CON_CRM.OPP_NEW_LIST_OLD_COUNT != oppList.size()) {
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
            CON_CRM.OPP_NEW_LIST_OLD_COUNT = oppList.size();
        }
    }
    
    /**
     * This method is used to validate the opportunity on Insert.
     * @param newList List<Opportunity>
     */
    public static void validateOpportunity(List<Opportunity> newList) {
        String profileName = newList[0].Current_User_Profile__c;
        if(profileName != NULL){
            for(Opportunity opp : newList) {
                if(!profileName.containsIgnoreCase(CON_CRM.SYSTEM_ADMIN_PROFILE) && !profileName.containsIgnoreCase(CON_CRM.COMMERCIAL_OPERATION_PROFILE) && !FeatureManagement.checkPermission(CON_CRM.CP_COMMERCIAL_OPS_USER)){
                    if(opp.stageName == CON_CRM.FINALIZING_DEAL_STAGE && !CON_CRM.IS_CLONE_OPPORTUNITY_FLOW) {
                        opp.addError(System.Label.CRM_CL0024_OPP_INSERT_ERROR);
                    }
                }
            }
        }
    }
    
    /**
     * This method is used to submit the unvalidated accounts
     * @param newList List<Opportunity>
     * @return  void
     */
    public static void submitUnvalidatedAccounts(List<Opportunity> newList,Map<id,Opportunity> oldMap) {
        Set<Id> accIdSet = new Set<Id>();
        for(Opportunity newOpp : newList) {
            if(Trigger.isInsert || (Trigger.isUpdate && (newOpp.AccountId != oldMap.get(newOpp.Id).AccountId))){
                accIdSet.add(newOpp.AccountId);
            }
        }
        if(accIdSet.size() > 0){
        Set<String> fieldSet = new Set<String>{'Id', 'MDM_Validation_Status__c'};
        Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accIdSet, fieldSet);
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for (Account acc : accountMap.values()) {
            if(acc.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED) {
                Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
                submitRequest.setComments('Submitting request for approval');
                submitRequest.setObjectId(acc.Id);
                requests.add(submitRequest); 
                }
            }
        try {
            if(requests.size() > 0) {
                Approval.ProcessResult[] processResults = Approval.process(requests, true);
                }
            } catch(System.DmlException e) {
                System.debug('Exception Is ' + e.getMessage());
            }
        }
    }

    // Method to Calculate OLI Project_Awarded_Price__c, Signed_Contract_Price__c and LIG Total_Project_Awarded_Price__c, Total_Signed_Contract_Price__c 
    public static void processProjectAwardedAndSignedPrice(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap, Boolean isBefore) {
        Map<Id, Opportunity> oppIdToOppWithLineItemMap = new Map<Id, Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> opp5To7aStageSet = new Set<String>();
        opp5To7aStageSet.add(CON_CRM.FINALIZING_DEAL_STAGE);
        opp5To7aStageSet.add(CON_CRM.RECEIVED_ATP_STAGE);
        opp5To7aStageSet.add(CON_CRM.CLOSED_WON_STAGE);
        Set<String> opp1To4StageSet = new Set<String>();
        opp1To4StageSet.add(CON_CRM.IDENTIFYING_OPP_STAGE);
        opp1To4StageSet.add(CON_CRM.QUALIFYING_OPP_STAGE);
        opp1To4StageSet.add(CON_CRM.DEVELOPING_PROP_STAGE);
        opp1To4StageSet.add(CON_CRM.DELIVERING_PROP_STAGE);
        opp1To4StageSet.add(CON_CRM.CLOSED_LOST_STAGE);
        Set<String> opp1To6StageSet = new Set<String>();
        opp1To6StageSet.add(CON_CRM.IDENTIFYING_OPP_STAGE);
        opp1To6StageSet.add(CON_CRM.QUALIFYING_OPP_STAGE);
        opp1To6StageSet.add(CON_CRM.DEVELOPING_PROP_STAGE);
        opp1To6StageSet.add(CON_CRM.DELIVERING_PROP_STAGE);
        opp1To6StageSet.add(CON_CRM.FINALIZING_DEAL_STAGE);
        opp1To6StageSet.add(CON_CRM.RECEIVED_ATP_STAGE);
        opp1To6StageSet.add(CON_CRM.CLOSED_LOST_STAGE);
        
        Set<Id> oppStage5Set = new Set<Id>();
        
        for(Opportunity opp : newOpportunityList) {
            String oldStageName = oldOpportunityMap.get(opp.Id).stageName;
            
            // To remove Awarded_Date__c
            if(opp1To4StageSet.contains(opp.stageName) && opp5To7aStageSet.contains(oldStageName)) {
                if(opp.Line_of_Business__c != 'Outcome' || opp.StageName == CON_CRM.CLOSED_LOST_STAGE){
                    opp.Awarded_Date__c = null;
                }
            }
            
            // To remove Signed_Contract_Date__c
            if(opp1To6StageSet.contains(opp.stageName) && oldStageName == CON_CRM.CLOSED_WON_STAGE) {
                opp.Signed_Contract_Date__c = null;
            } else if(opp.stageName != oldStageName && opp.StageName == CON_CRM.CLOSED_WON_STAGE && opp.Signed_Contract_Date__c == null){
                opp.Signed_Contract_Date__c = Date.Today();
            }
        }
        Double totalAwardedValue = 0;
        Double totalSignedValue = 0;
        fflib_SObjectUnitOfWork oliUOW = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] { OpportunityLineItem.SObjectType }
        );
        /*fflib_SObjectUnitOfWork oppUOW = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] { Opportunity.SObjectType }
        );*/
        Set<Id> ownerIdSet = new Set<Id>();
        for(Opportunity opp : newOpportunityList) {
            String oldStageName = oldOpportunityMap.get(opp.Id).stageName;
            
            // To calculate Project_Awarded_Price__c, Total_Project_Awarded_Price__c, Signed_Contract_Price__c, Total_Signed_Contract_Price__c
            if(opp.stageName != oldStageName && opp5To7aStageSet.contains(opp.stageName)) {
                oppIdSet.add(opp.Id);
            }
            // To remove Project_Awarded_Price__c, Total_Project_Awarded_Price__c, Awarded_Date__c
            if(opp1To4StageSet.contains(opp.stageName) && opp5To7aStageSet.contains(oldStageName)) {
                oppIdSet.add(opp.Id);
            }
            // To remove Signed_Contract_Price__c, Total_Signed_Contract_Price__c, Signed_Contract_Date__c
            if(opp1To6StageSet.contains(opp.stageName) && oldStageName == CON_CRM.CLOSED_WON_STAGE) {
                oppIdSet.add(opp.Id);
            }
            // To calculate Total_Project_Awarded_Price__c
            if(opp.Amount != oldOpportunityMap.get(opp.Id).Amount && opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE && opp.StageName == oldStageName){
                oppStage5Set.add(opp.Id);                    
            }
            
            if(opp.OwnerId != oldOpportunityMap.get(opp.id).OwnerId) {
                ownerIdSet.add(opp.OwnerId);
                ownerIdSet.add(oldOpportunityMap.get(opp.id).OwnerId);
            }
            oppIdSet.addAll(oppStage5Set);
        }
        Set<Id> oppOliUpdateSet = new Set<Id>();
        Map<Id, User> IdtoUserMap = new Map<Id, User>();
        if(ownerIdSet.size() > 0) {
            IdtoUserMap = new SLT_User().selectByUserId(ownerIdSet, new Set<String>{'Id', 'User_Country__c'});
            for(Opportunity opp : newOpportunityList) {
                if(opp.OwnerId != oldOpportunityMap.get(opp.id).OwnerId && IdtoUserMap.get(opp.OwnerId).User_Country__c != IdtoUserMap.get(oldOpportunityMap.get(opp.id).OwnerId).User_Country__c 
                   && (IdtoUserMap.get(opp.OwnerId).User_Country__c == 'USA' || IdtoUserMap.get(oldOpportunityMap.get(opp.id).OwnerId).User_Country__c == 'USA')) {
                       oppOliUpdateSet.add(opp.Id);
                   }
            }
        }
        oppIdSet.addAll(oppOliUpdateSet);
        if(oppIdSet.size() > 0){
            // query all opp + oli + olig where OLI.Offering_Group_Code__c = 'GPRDSX' and  Opp Stage is changed and moving to Stage 5, 6 or 7a
            Set<String> oliFieldSet = new Set<String> {'Id', 'OpportunityId', 'Signed_Contract_Price__c', 'Project_Awarded_Price__c', 'TotalPrice', 'Opp_Stage_on_Insert__c', 'Offering_Group_Code__c','Offering_Segment_Code__c','Product_Material_Type__c','Product_Group__c','Unit_Name__c', 'Is_Product_Survey_Eligible__c', 'Is_Survey_Eligible__c'};
            Set<String> oppFieldSet = new Set<String> {'Id', 'Total_Project_Awarded_Price__c', 'Total_Signed_Contract_Price__c', 'StageName', 'Signed_Contract_Date__c', 'Awarded_Date__c'};
            oppIdToOppWithLineItemMap = new SLT_Opportunity().selectByIdWithOpportuntiyLineItem(oppIdSet, oppFieldSet, oliFieldSet);
            Boolean isStageChange;
            Map<Id, Boolean> oliIdtoIsSurveyEligibleMap = new Map<Id, Boolean>();
            for(Opportunity opp : newOpportunityList) {
                isStageChange = false;
                String oldStageName = oldOpportunityMap.get(opp.Id).stageName;
                // To calculate Project_Awarded_Price__c, Total_Project_Awarded_Price__c, Signed_Contract_Price__c, Total_Signed_Contract_Price__c
                if(opp.stageName != oldStageName && opp5To7aStageSet.contains(opp.stageName) || oppStage5Set.contains(opp.Id)) {
                    if(opp.stageName != oldStageName) {
                        isStageChange = true;
                    }
                    totalSignedValue = 0;
                    totalAwardedValue = 0;
                    Opportunity dbmsOpp = oppIdToOppWithLineItemMap.get(opp.Id);
                    for(OpportunityLineItem oli : dbmsOpp.OpportunityLineItems) {
                        Boolean toCommit = false;
                        // To make sure we are checking for offering group code(GPRDSX) or offering segment code(GPRWSA) products
                        // as part of Product Hiearchy update 2025 Material Type(ZQUI) and Unit Name(ecoa) will cover under offering group code(GPRDSX) so removing
                        if(oli.Offering_Group_Code__c == CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND || oli.Offering_Segment_Code__c == CON_CRM.OFFERING_SEGMENT_CODE_GLOBAL_RWS) {
                            if(opp.Line_of_Business__c == CON_CRM.LOB_Q2_Solutions){
                                // for Q2 Solutions: TPAP calulcate only on moving Stage to (5-7a) if Awarded_Date is not Blank and TPAP is null products added/update/removed at stage 5 will not update TPAP for Q2.
                                if(opp.Awarded_Date__c != null && opp.Total_Project_Awarded_Price__c == null && isStageChange) {
                                    if(oli.Project_Awarded_Price__c != oli.TotalPrice) {
                                        oli.Project_Awarded_Price__c = oli.TotalPrice;
                                        toCommit = true;
                                    }
                                    totalAwardedValue += oli.TotalPrice;
                                }
                            }else{
                                // TPAP Calculate on moving Stage to (5-7a) if Awarded_Date is in Current Month and TPAP is null or Existing products price update/removed at stage 5
                                if(opp.Awarded_Date__c != null && opp.Awarded_Date__c.month() == Date.today().month() && ((opp.Total_Project_Awarded_Price__c == null && isStageChange) || (oli.Project_Awarded_Price__c != null && oppStage5Set.contains(opp.Id)))) {
                                    if(oli.Project_Awarded_Price__c != oli.TotalPrice) {
                                        oli.Project_Awarded_Price__c = oli.TotalPrice;
                                        toCommit = true;
                                    }
                                    totalAwardedValue += oli.TotalPrice;
                                }
                            }
                            if(opp.stageName == CON_CRM.CLOSED_WON_STAGE && opp.Signed_Contract_Date__c != null && opp.Signed_Contract_Date__c.month() == Date.today().month() && opp1To6StageSet.contains(oli.Opp_Stage_on_Insert__c)) {
                                if(oli.Signed_Contract_Price__c != oli.TotalPrice) {
                                    oli.Signed_Contract_Price__c = oli.TotalPrice;
                                    toCommit = true;
                                }
                                totalSignedValue += oli.TotalPrice;
                            }
                            if(toCommit) {
                                oliUOW.registerDirty(oli);
                            }
                        }
                    }
                    Boolean toCommit = false;
                    if((totalAwardedValue != 0 || (oppStage5Set.contains(opp.Id) && opp.Line_of_Business__c != CON_CRM.LOB_Q2_Solutions)) && opp.Total_Project_Awarded_Price__c != totalAwardedValue && opp.Awarded_Date__c != null && (opp.Awarded_Date__c.month() == Date.today().month() || opp.Line_of_Business__c == CON_CRM.LOB_Q2_Solutions)) {
                        opp.Total_Project_Awarded_Price__c = totalAwardedValue;
                        toCommit = true;
                    }
                    // To make sure it not get updated at stage 5 and 6
                    if(totalSignedValue != 0 && opp.Total_Signed_Contract_Price__c != totalSignedValue) {
                        opp.Total_Signed_Contract_Price__c = totalSignedValue;
                        toCommit = true;
                    }
                    // To make sure we only hit update when there is change in value
                    if(toCommit) {
                        //oppUOW.registerDirty(opp);
                    }
                    //}
                }
                // To remove Project_Awarded_Price__c, Total_Project_Awarded_Price__c, Awarded_Date__c
                if(opp1To4StageSet.contains(opp.stageName) && (oldStageName == CON_CRM.FINALIZING_DEAL_STAGE || oldStageName == CON_CRM.RECEIVED_ATP_STAGE)) {
                    if(oppIdToOppWithLineItemMap.containsKey(opp.Id)){
                        Opportunity dbmsOpp = oppIdToOppWithLineItemMap.get(opp.Id);
                        for(OpportunityLineItem oli : dbmsOpp.OpportunityLineItems) {
                            if(oli.Project_Awarded_Price__c != null){
                                oli.Project_Awarded_Price__c = null;
                                oliUOW.registerDirty(oli);
                            }
                        }
                        if(opp.Total_Project_Awarded_Price__c != null){
                            opp.Total_Project_Awarded_Price__c = null;
                            //oppUOW.registerDirty(opp);
                        }
                    }
                }
                // To remove Signed_Contract_Price__c, Total_Signed_Contract_Price__c, Signed_Contract_Date__c
                else if(opp1To6StageSet.contains(opp.stageName) && oldStageName == CON_CRM.CLOSED_WON_STAGE) {
                    if(oppIdToOppWithLineItemMap.containsKey(opp.Id)){
                        Opportunity dbmsOpp = oppIdToOppWithLineItemMap.get(opp.Id);
                        for(OpportunityLineItem oli : dbmsOpp.OpportunityLineItems) {
                            if(oli.Project_Awarded_Price__c != null || oli.Signed_Contract_Price__c != null){
                                if(opp1To4StageSet.contains(opp.stageName)) {
                                    oli.Project_Awarded_Price__c = null;
                                }
                                oli.Signed_Contract_Price__c = null;
                                oliUOW.registerDirty(oli);
                            }
                        }
                        if(opp.Total_Project_Awarded_Price__c != null || opp.Total_Signed_Contract_Price__c != null) {
                            if(opp1To4StageSet.contains(opp.stageName)) {
                                opp.Total_Project_Awarded_Price__c = null;
                            }
                            opp.Total_Signed_Contract_Price__c = null;
                            //oppUOW.registerDirty(opp);
                        }
                    }
                }
                else if(oppOliUpdateSet.contains(opp.Id)) {
                    Boolean isCountryUSA = IdtoUserMap.get(opp.OwnerId).User_Country__c == 'USA';
                    for(OpportunityLineItem oli : oppIdToOppWithLineItemMap.get(opp.Id).OpportunityLineItems) {
                        if(((oli.Is_Product_Survey_Eligible__c && oli.Product_Material_Type__c == 'ZPUB')|| oli.Product_Material_Type__c == 'ZREP') && ((isCountryUSA) || (!isCountryUSA && oli.Unit_Name__c != 'Payer' && oli.Unit_Name__c != 'Provider'))){
                            if(!oli.Is_Survey_Eligible__c) {
                                oliIdtoIsSurveyEligibleMap.put(oli.Id, true);
                            }
                            //oli.Is_Survey_Eligible__c = true;
                        }else{
                            if(oli.Is_Survey_Eligible__c) {
                                oliIdtoIsSurveyEligibleMap.put(oli.Id, false);
                            }
                            //oli.Is_Survey_Eligible__c = false;
                        }
                        //oliUOW.registerDirty(oli); 
                    }
                }
            }
            UTL_ExecutionControl.stopTriggerExecution = true;
            oliUOW.commitWork();
            //oppUOW.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
            if(oliIdtoIsSurveyEligibleMap.size() > 0) {
                updateOpportunityLineItemFuture(oliIdtoIsSurveyEligibleMap);
            }
        }
    }
    
    @future
    public static void updateOpportunityLineItemFuture(Map<Id, Boolean> oliIdtoIsSurveyEligibleMap){
        fflib_SObjectUnitOfWork oliUOW = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] { OpportunityLineItem.SObjectType }
        );
        String msgStr = '';
        for(Id oliId : oliIdtoIsSurveyEligibleMap.KeySet()) {
            oliUOW.registerDirty(new OpportunityLineItem(Id = oliId, Is_Survey_Eligible__c = oliIdtoIsSurveyEligibleMap.get(oliId))); 
            msgStr += '<br/><br/>--Opportunity Line Item Id----' + oliId + '-----Is_Survey_Eligible__c----'+ oliIdtoIsSurveyEligibleMap.get(oliId) + '<br/>';
        }
        UTL_ExecutionControl.stopTriggerExecution = true;
        try {
            oliUOW.commitWork();
        }catch(Exception ex) {
            List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
            Survey_Setting__c ss = Survey_Setting__c.getOrgDefaults();
            List<String> toAddresses = new List<String>();
            if(ss.Survey_Error_Email_Ids__c != NULL && ss.Survey_Error_Email_Ids__c != '' ) {
                toAddresses.addAll(ss.Survey_Error_Email_Ids__c.split(','));
            }
            String body ='<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Line Item Survey Field Sync Is_Survey_Eligible__c Failed ***<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Message:</td><td>'+ msgStr +'</td></tr></table></p></td></tr></table>';
            UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
            message.toEmails = toAddresses;
            message.subject = 'Opportunity Line Item Survey Field Is_Survey_Eligible__c Sync Failed';
            message.staticContent = body;
            messageList.add(message);
            UTL_CRM_SendEmail.MODULE_NAME = 'CRM';
            UTL_CRM_SendEmail.MODULE_ALERT_NAME = 'CRM_01_SendEmail';
            if(toAddresses.size() > 0)
            UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
        }
        UTL_ExecutionControl.stopTriggerExecution = false;
        
    }
    
    /**
    * This method is used validate the bid team members selected on the opportunity.
    * @params  List<Opportunity> newList
    * @params  Map<Id, Opportunity> oldMap
    * @return  void
    */
    /*public static void validateBidTeamMembers(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        String userProfile = UTL_CRM.getCurrentUserProfileName();
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!userProfile.equalsIgnoreCase(CON_CRM.SYSTEM_ADMIN_PROFILE) && !mulesoftSetting.Ignore_Validation_Rules__c) {
            Set<Id> conIdSet = new Set<Id>();
            for(Opportunity opp : newList) {
                if(opp.Principle_inCharge__c != null && (oldMap == null || oldMap.get(opp.Id).Principle_inCharge__c != opp.Principle_inCharge__c)) {
                    conIdSet.add(opp.Principle_inCharge__c);
                }
                if(opp.BidTeam_2__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_2__c != opp.BidTeam_2__c)) {
                    conIdSet.add(opp.BidTeam_2__c);
                }
                if(opp.BidTeam_3__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_3__c != opp.BidTeam_3__c)) {
                    conIdSet.add(opp.BidTeam_3__c);
                }
                if(opp.BidTeam_4__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_4__c != opp.BidTeam_4__c)) {
                    conIdSet.add(opp.BidTeam_4__c);
                }
                if(opp.BidTeam_5__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_5__c != opp.BidTeam_5__c)) {
                    conIdSet.add(opp.BidTeam_5__c);
                }
                if(opp.BidTeam_6__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_6__c != opp.BidTeam_6__c)) {
                    conIdSet.add(opp.BidTeam_6__c);
                }
                if(opp.BidTeam_7__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_7__c != opp.BidTeam_7__c)) {
                    conIdSet.add(opp.BidTeam_7__c);
                }
                if(opp.BidTeam_8__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_8__c != opp.BidTeam_8__c)) {
                    conIdSet.add(opp.BidTeam_8__c);
                } 
            }
            if(conIdSet.size () > 0) {
                Set<String> fieldSet = new Set<String>{'Salesforce_User__r.PIC_Eligible__c', 'RecordTypeId'};
                    Map<Id, Contact> idContactMap = new SLT_Contact().selectByContactId(conIdSet, fieldSet);
                
                for(Opportunity opp : newList) {
                    if(opp.Principle_inCharge__c != null && (oldMap == null || oldMap.get(opp.Id).Principle_inCharge__c != opp.Principle_inCharge__c) 
                       && idContactMap.containsKey(opp.Principle_inCharge__c) 
                       && idContactMap.get(opp.Principle_inCharge__c).RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID
                       && idContactMap.get(opp.Principle_inCharge__c).Salesforce_User__r.PIC_Eligible__c == false) {
                           opp.addError(System.label.CRM_CL0025_OPP_PIC_ERROR);
                       }
                    if(opp.BidTeam_2__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_2__c != opp.BidTeam_2__c) 
                       && idContactMap.containsKey(opp.BidTeam_2__c) 
                       && idContactMap.get(opp.BidTeam_2__c).RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID
                       && idContactMap.get(opp.BidTeam_2__c).Salesforce_User__r.PIC_Eligible__c == false) {
                           opp.addError(System.label.CRM_CL0026_OPP_BID_TEAM_ERROR);
                       }
                    if(opp.BidTeam_3__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_3__c != opp.BidTeam_3__c) 
                       && idContactMap.containsKey(opp.BidTeam_3__c) 
                       && idContactMap.get(opp.BidTeam_3__c).RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID
                       && idContactMap.get(opp.BidTeam_3__c).Salesforce_User__r.PIC_Eligible__c == false) {
                           opp.addError(System.label.CRM_CL0026_OPP_BID_TEAM_ERROR);
                       }
                    if(opp.BidTeam_4__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_4__c != opp.BidTeam_4__c) 
                       && idContactMap.containsKey(opp.BidTeam_4__c) 
                       && idContactMap.get(opp.BidTeam_4__c).RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID
                       && idContactMap.get(opp.BidTeam_4__c).Salesforce_User__r.PIC_Eligible__c == false) {
                           opp.addError(System.label.CRM_CL0026_OPP_BID_TEAM_ERROR);
                       }
                    if(opp.BidTeam_5__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_5__c != opp.BidTeam_5__c) 
                       && idContactMap.containsKey(opp.BidTeam_5__c) 
                       && idContactMap.get(opp.BidTeam_5__c).RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID
                       && idContactMap.get(opp.BidTeam_5__c).Salesforce_User__r.PIC_Eligible__c == false) {
                           opp.addError(System.label.CRM_CL0026_OPP_BID_TEAM_ERROR);
                       }
                    if(opp.BidTeam_6__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_6__c != opp.BidTeam_6__c) 
                       && idContactMap.containsKey(opp.BidTeam_6__c) 
                       && idContactMap.get(opp.BidTeam_6__c).RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID
                       && idContactMap.get(opp.BidTeam_6__c).Salesforce_User__r.PIC_Eligible__c == false) {
                           opp.addError(System.label.CRM_CL0026_OPP_BID_TEAM_ERROR);
                       }
                    if(opp.BidTeam_7__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_7__c != opp.BidTeam_7__c) 
                       && idContactMap.containsKey(opp.BidTeam_7__c) 
                       && idContactMap.get(opp.BidTeam_7__c).RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID
                       && idContactMap.get(opp.BidTeam_7__c).Salesforce_User__r.PIC_Eligible__c == false) {
                           opp.addError(System.label.CRM_CL0026_OPP_BID_TEAM_ERROR);
                       }
                    if(opp.BidTeam_8__c != null && (oldMap == null || oldMap.get(opp.Id).BidTeam_8__c != opp.BidTeam_8__c) 
                       && idContactMap.containsKey(opp.BidTeam_8__c) 
                       && idContactMap.get(opp.BidTeam_8__c).RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID
                       && idContactMap.get(opp.BidTeam_8__c).Salesforce_User__r.PIC_Eligible__c == false) {
                           opp.addError(System.label.CRM_CL0026_OPP_BID_TEAM_ERROR);
                       }
                }
            }
        }
    }
	
	*/
    
    /**
     * This method is used to send email on update of Line Item Group.
     * @params  newList List<Opportunity>
     * @params  oldMap Map<Id, Opportunity>
     * @return  void 
     */
    public static void sendEmails(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Mulesoft_Integration_Control__c mulesoft = Mulesoft_Integration_Control__c.getInstance();
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
        if(!mulesoft.Ignore_Validation_Rules__c || mulesoft.Is_Mulesoft_User__c){
            for(Opportunity opp : newList){
                if(opp.InterventionType__c != null && opp.InterventionType__c != oldMap.get(opp.id).InterventionType__c){
                    oppIdSet.add(opp.id);
                }
            }
            if(oppIdSet != null && oppIdSet.size() > 0){
                for(EmailTemplate em : [Select id, DeveloperName from EmailTemplate where DeveloperName = 'OPP_ET02_CRM_Stem_Cell_Included' OR DeveloperName = 'OPP_ET01_CRM_BioSimilar_Opp_Awarded_Alert']) {
                    emailTemplateMap.put(em.DeveloperName, em);                   
                }
                Set<String> oppFieldSet = new Set<String>{'Id', 'Name', 'Owner.Email', 'OwnerId'};
                Map<Id, Opportunity> oppIdToOppMap = new SLT_Opportunity().getOpportunityById(oppIdSet, oppFieldSet);
                for(Opportunity opp :oppIdToOppMap.values()){
                    String str = opp.OwnerId;
                    if(str.StartsWith('005')){
                        ownerIdSet.add(opp.OwnerId);
                    }
                }
                Set<String> contactFieldSet = new Set<String>{'Id', 'Salesforce_User__c'};
                List<Contact> contactList = new SLT_Contact().selectBySalesforceUserIdList(ownerIdSet, contactFieldSet);
                Map<Id, Id> contactOwnerIdToContactMap = new Map<Id, Id>();
                for(Contact con :contactList){
                    contactOwnerIdToContactMap.put(con.Salesforce_User__c, con.id);
                }
                List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
                for(Opportunity opp : newList){
                    if(opp.InterventionType__c == 'Cell and Gene Therapy' && oldMap.get(opp.id).InterventionType__c != 'Cell and Gene Therapy') {
                        if(contactOwnerIdToContactMap.containsKey(oppIdToOppMap.get(opp.id).Owner.id) && emailTemplateMap.containsKey('OPP_ET02_CRM_Stem_Cell_Included'))
                        {
                            UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                            message.toEmails = new List<String>{ oppIdToOppMap.get(opp.id).Owner.Email };
                            message.toUserIds = new List<Id>{contactOwnerIdToContactMap.get(oppIdToOppMap.get(opp.id).Owner.id)};
                            message.targetObjectId = contactOwnerIdToContactMap.get(oppIdToOppMap.get(opp.id).Owner.id);
                            message.whatId = opp.id;
                            message.templateId = emailTemplateMap.get('OPP_ET02_CRM_Stem_Cell_Included').Id;
                            messageList.add(message);
                        }
                    }
                    else if(opp.InterventionType__c == 'Biosimilar' && oldMap.get(opp.id).InterventionType__c != 'Biosimilar'
                            && (oppIdToOppMap.get(opp.id).name.contains('biosimilar') || oppIdToOppMap.get(opp.id).name.contains('biosimilar') 
                                || oppIdToOppMap.get(opp.id).name.contains('Biobetter') || oppIdToOppMap.get(opp.id).name.contains('Bio'))) {
                                    Set<Id> userIdSet = new Set<Id>();
                                    List<String> emailSet = new List<String>();
                                    for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where group.developername='BioSimilar_Opp_Alert_Group']){
                                        userIdSet.add(gm.UserOrGroupId);
                                    }
                                    Set<String> userFieldSet = new Set<String>{'Id', 'Email'};
                                    Map<Id, User> idUserMap = new SLT_User().selectByUserId(userIdSet, userFieldSet);
                                    for(User user : idUserMap.values()){
                                        emailSet.add(user.Email);
                                    }
                                    if(contactOwnerIdToContactMap.containsKey(oppIdToOppMap.get(opp.id).Owner.id) && emailTemplateMap.containsKey('OPP_ET01_CRM_BioSimilar_Opp_Awarded_Alert'))
                                    {
                                        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                                        message.toEmails = (List<String>)emailSet;
                                        message.toUserIds = new List<Id>{contactOwnerIdToContactMap.get(oppIdToOppMap.get(opp.id).Owner.id)};
                                        message.targetObjectId = contactOwnerIdToContactMap.get(oppIdToOppMap.get(opp.id).Owner.id);
                                        message.whatId = opp.id;
                                        message.templateId = emailTemplateMap.get('OPP_ET01_CRM_BioSimilar_Opp_Awarded_Alert').Id;
                                        messageList.add(message);
                                    }
                                }
                } 
                
                if(messageList.size()>0){
                    UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
                }
            }
        }
    }
    
    public static void updateConversionRate(List<Opportunity> newList) {
        Set<String> SetOfCurrencyIsoCode = new Set<String>();
        for (Opportunity Opp:newList)
        {
            if(Opp.CurrencyIsoCode != 'USD'){
                SetOfCurrencyIsoCode.add(Opp.CurrencyIsoCode);
            }
        }
        Map<String,Double> CurrencyConversionRate_Map = new Map<String,Double>();
        if(SetOfCurrencyIsoCode.size() > 0){
            List<CurrencyType> listCurrencyType = new SLT_CurrencyType().getAllCurrencyTypeByIsoCode(SetOfCurrencyIsoCode);
            for(CurrencyType currType : listCurrencyType) {
                CurrencyConversionRate_Map.put(currType.IsoCode, currType.ConversionRate);
            }
        }
            for (Opportunity Opp : newList){
                if(Opp.CurrencyIsoCode == 'USD'){
                    Opp.Conversion_Rate_To_USD__c = 1;
                }else{
                    Opp.Conversion_Rate_To_USD__c = 1/CurrencyConversionRate_Map.get(Opp.CurrencyIsoCode);
                }
            }
    }

    /**
     * This method is used to update lead status when a converted opportunity is closed.
     * @params  newList List<opportunity>
     * @params  oldMap Map<Id, opportunity>
     * @return  void 
     */    
    public static void updateLeadStatusOnClose (List<Opportunity> newList, Map<Id, Opportunity> oldMap){ 
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        
        for (Opportunity opp: newList){
            if(opp.IsClosed && ! oldMap.get(opp.Id).IsClosed){
                    oppMap.put(opp.Id, opp); 
            }
        }
        
        if(oppMap.size() > 0){
            List<Lead> closedOppLeadList = new List<Lead>();
            for(Lead led: new SLT_Lead().selectByConvertedOppId(oppMap.keySet())){
                if(oppMap.get(led.ConvertedOpportunityId).IsWon){
                    led.status = CON_PEP.S_PEP_LED_CLOSED_WON;
                    closedOppLeadList.add(led);
                }
                else if (!oppMap.get(led.ConvertedOpportunityId).IsWon){
                    led.status = CON_PEP.S_PEP_LED_CLOSED_LOST;
                    closedOppLeadList.add(led);
                }
            }

            if(closedOppLeadList.size()>0){
                Database.update(closedOppLeadList);
            }
            
        }
    }
    /**
     * 4367-> This method is used to check for Opportunity with stagename '5-finalising deal' and Is this Iqvia Biotech is True
     * @params  newList List<opportunity>
     * @params  oldMap Map<Id, opportunity>
     * @return  void 
     */ 
    public static void notifyUsersOnStage5(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        //Set<Id> ligIdsSet = new Set<Id>();
        Set<Id> accountsIdSet = new Set<Id>();
        Set<Id> ownersIdSet = new Set<Id>();
        List<Opportunity> biotechFilteredOppList = new List<Opportunity>();
        for(Opportunity opp : newList){
            if(opp.StageName != oldMap.get(opp.id).StageName && opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE && opp.Is_this_IQVIA_Biotech__c == CON_CRM.YES_STRING){
                biotechFilteredOppList.add(opp);
                accountsIdSet.add(opp.AccountId);
                ownersIdSet.add(opp.OwnerId);
            }
            if(opp.StageName != oldMap.get(opp.id).StageName && opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE && opp.Next_Gen_Status__c != CON_CRM.OPPORTUNITY_NEXT_GEN_STATUS_NOT_SUPPORTED && opp.Next_Gen_Request_Type__c != null && opp.Next_Gen_Request_Type__c.contains(CON_CRM.OPPORTUNITY_NEXT_GEN_REQUEST_TYPE_SALES_SUPPORT)){
                accountsIdSet.add(opp.AccountId);
                ownersIdSet.add(opp.OwnerId);
            }
        }
        //if(ligIdsSet.size() > 0 || accountsIdSet.size() > 0 || ownersIdSet.size() > 0 ){
        if(accountsIdSet.size() > 0 || ownersIdSet.size() > 0 ){
            //Set<String> fieldsSet = new Set<String>{'Id','RWE_Study__c','Global_project_unit__c','Expected_Project_Start_Date__c','Potential_Services__c','Total_Project_Awarded_Price__c','Expected_Project_Start_Date__c'};
            Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accountsIdSet, new Set<String>{'Id','Name','Category__c','ParentId','Parent.Name'});
            Map<Id, User> usersMap = new SLT_User().selectByUserId(ownersIdSet,new Set<String>{'Id','Full_User_Name__c','Email'});
            List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
            IQVIA_Biotech_Opportunity_User__c usersEmailFromSetting = IQVIA_Biotech_Opportunity_User__c.getInstance();
            if(usersEmailFromSetting != null){
                List<String> recipientUsersEmail = new List<String>();
                List<String> toCCAddress = new List<String>();
                if(usersEmailFromSetting.Recipients_Users_Email__c != null && usersEmailFromSetting.Recipients_Users_Email__c != ''){
                    recipientUsersEmail = (usersEmailFromSetting.Recipients_Users_Email__c).split(',');
                }
                if(usersEmailFromSetting.CC_Users_Email__c != null  && usersEmailFromSetting.CC_Users_Email__c != ''){
                    toCCAddress = (usersEmailFromSetting.CC_Users_Email__c).split(',');
                }
                if(recipientUsersEmail.size() > 0 || toCCAddress.size() > 0){
                    for(Opportunity opp : biotechFilteredOppList){
                        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        String emailBody = 'Notification of Outcome of IQVIA Biotech Proposal - Finalizing Deal<br/>';
                        emailBody += 'Account Name: ' +accountMap.get(opp.AccountId).Name+ '<br/>';
                        emailBody += 'Category: ' +fetchNullValue(accountMap.get(opp.AccountId).Category__c)+  '<br/>';
                        emailBody += 'Opportunity Name: ' +opp.Name+  '<br/>';
                        emailBody += 'Opportunity Owner: ' +usersMap.get(opp.OwnerId).Full_User_Name__c+  '<br/>';
                        emailBody += 'Opportunity Number: ' +opp.Opportunity_Number__c+  '<br/>';
                        emailBody += 'Legacy Quintiles Opportunity Number: ' +fetchNullValue(String.valueOf(opp.Legacy_Quintiles_Opportunity_Number__c))+  '<br/>';
                        emailBody += 'Amount (converted): ' +opp.Amount_In_USD__c+  '<br/>';
                        emailBody += 'Link to Opportunity: ' +URL.getOrgDomainUrl().toExternalForm() + '/' + opp.Id+  '<br/><br/>';
                        emailBody += 'To use the above link please make sure you are already logged into IQVIA CRM. <br/><br/>';
                        emailBody += 'Drug Classification: ' +fetchNullValue(opp.Drug_Classification__c)+  '<br/>';
                        emailBody += 'Indication: ' +fetchNullValue(opp.Indication_List__c)+  '<br/>';
                        emailBody += 'Therapy Area: ' +fetchNullValue(opp.TherapyArea__c)+  '<br/>';
                        emailBody += 'Phase: ' +fetchNullValue(opp.Phase_P__c)+  '<br/>';
                        //emailBody += 'RWE Study: ' +fetchNullValue(opp.RWE_Study__c)+  '<br/>';
                        emailBody += 'Global Project Unit: ' +fetchNullValue(opp.Global_project_unit__c)+  '<br/>';
                        emailBody += 'Expected Project Start Date: ' +fetchNullValue(String.valueOf(opp.Expected_Project_Start_Date__c))+  '<br/>';
                        emailBody += 'Potential Regions: ' +fetchNullValue(opp.Potential_Regions__c)+  '<br/>';
                        
                        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                        message.toEmails = recipientUsersEmail;
                        message.ccEmails = toCCAddress;
                        message.whatId = opp.Id;
                        
                        if(!(recipientUsersEmail.contains(usersMap.get(opp.OwnerId).Email) || toCCAddress.contains(usersMap.get(opp.OwnerId).Email))){
                            message.toUserIds = new List<Id>{opp.OwnerId};
                        }
                        message.subject = 'Notification of Outcome of IQVIA Biotech Proposal - Finalizing Deal';
                        message.staticContent = emailBody;
                        messageList.add(message);
                    }
                }
            }
            
            if(messageList.size()>0)
                UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
        }
    }
    /*
    Method is used to raplace null with blank
    */
    public static String fetchNullValue(String param){
        String returnVal = '';
        if(param != null){
            returnVal = param;
        }
        return returnVal;
    }
    
    public static void notifyUserOnStage5And7b(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        //Set<Id> ligIdsSet = new Set<Id>();
        Set<Id> accountsIdSet = new Set<Id>();
        Set<Id> ownersIdSet = new Set<Id>();
        List<Opportunity> filteredOpportunityList = new List<Opportunity>();
        Set<String> lineOfBusinessList = new Set<String>{   'Clinical',
                                                            'Data Sciences',
                                                            'Early Clinical Development',
                                                            'Connected Devices',
                                                            'Safety & Med Info'
                                                        };
        Set<String> lossTypeList = new Set<String>{'Stopped', 'Duplicate Opportunity'};                                                    
        for(Opportunity opp : newList){
            if( ((opp.StageName != oldMap.get(opp.id).StageName && opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE) || (opp.StageName != oldMap.get(opp.id).StageName && opp.StageName == CON_CRM.CLOSED_LOST_STAGE)) && lineOfBusinessList.contains(opp.Line_of_Business__c) && !lossTypeList.contains(opp.Loss_Type__c)){
                accountsIdSet.add(opp.AccountId);
                ownersIdSet.add(opp.OwnerId);
                filteredOpportunityList.add(opp);
            }
        }
        if(filteredOpportunityList.size() > 0){
            //Set<String> fieldsSet = new Set<String>{'Id','RWE_Study__c','Global_project_unit__c','Expected_Project_Start_Date__c','Potential_Services__c','Total_Project_Awarded_Price__c'};
            Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accountsIdSet, new Set<String>{'Id','Name','Category__c','ParentId','Parent.Name'});
            Map<Id, User> usersMap = new SLT_User().selectByUserId(ownersIdSet,new Set<String>{'Id','Full_User_Name__c','Email'});
            Email_Notification_To_User__c usersEmailFromSetting = Email_Notification_To_User__c.getInstance();
            if(usersEmailFromSetting != null){
                List<String> accountIdsList = new List<String>();
                Set<String> accountIds = new Set<String>();
                List<String> toUsersIds = new List<String>();
                if(usersEmailFromSetting.Account_Ids__c != null && usersEmailFromSetting.Account_Ids__c != ''){
                    accountIdsList = (usersEmailFromSetting.Account_Ids__c).split(',');
                    accountIds.addAll(accountIdsList);
                }
                if(usersEmailFromSetting.User_Ids__c != null  && usersEmailFromSetting.User_Ids__c != ''){
                    toUsersIds = (usersEmailFromSetting.User_Ids__c).split(',');
                }
                if(toUsersIds.size() > 0){
                    List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
                    
                    for(Opportunity opp : filteredOpportunityList){
                        if(accountIds.contains(accountMap.get(opp.AccountId).ParentId)){
                            String subject = '';
                            String emailBody = 'Notification of Outcome of Bid: '+opp.StageName +'<br/>';
                            emailBody += 'Opportunity Owner: ' +usersMap.get(opp.OwnerId).Full_User_Name__c+  '<br/>';
                            emailBody += 'Account Name: ' +accountMap.get(opp.AccountId).Name+ '<br/>';
                            emailBody += 'Category: ' +fetchNullValue(accountMap.get(opp.AccountId).Category__c)+  '<br/>';
                            emailBody += 'Is this IQVIA Biotech: '+fetchNullValue(opp.Is_this_IQVIA_Biotech__c) +'<br/>';
                            if(opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE){
                                emailBody += 'Total Project Awarded Price: '+fetchNullValue(String.valueOf(opp.Total_Project_Awarded_Price__c)) +'<br/>';
                                emailBody += 'Opportunity Name: ' +opp.Name+  '<br/>';
                                emailBody += 'Opportunity Link: ' +URL.getOrgDomainUrl().toExternalForm() + '/' + opp.Id+  '<br/>';
                                emailBody += 'Note: To use the above link please make sure you are already logged into IQVIA CRM. <br/><br/>';
                                emailBody += '<b>Opportunity Information:</b><br/>';
                                emailBody += 'Indication: ' +fetchNullValue(opp.Indication_List__c)+  '<br/>';
                                emailBody += 'Therapy Area: ' +fetchNullValue(opp.TherapyArea__c)+  '<br/>';
                                emailBody += 'Phase: ' +fetchNullValue(opp.Phase_P__c)+  '<br/>';
                                emailBody += 'Expected Project Start Date: ' +fetchNullValue(String.valueOf(opp.Expected_Project_Start_Date__c))+  '<br/>';
                                emailBody += 'Primary Win Reason: ' + fetchNullValue(opp.Primary_Win_Reason__c) +  '<br/>';
                                emailBody += 'Primary Win Reason Detail: ' + fetchNullValue(opp.Primary_Win_Reason_Detail__c) +  '<br/>';
                                subject = accountMap.get(opp.AccountId).Parent.Name+ ' Opportunity in Stage 5';
                            }else if(opp.StageName == CON_CRM.CLOSED_LOST_STAGE){
                                emailBody += 'Amount (converted): ' +opp.Amount_In_USD__c+  '<br/>';
                                emailBody += 'Opportunity Name: ' +opp.Name+  '<br/>';
                                emailBody += 'Opportunity Link: ' +URL.getOrgDomainUrl().toExternalForm() + '/' + opp.Id+  '<br/>';
                                emailBody += 'Note: To use the above link please make sure you are already logged into IQVIA CRM. <br/><br/>';
                                emailBody += '<b>Opportunity Information:</b><br/>';
                                emailBody += 'Indication: ' +fetchNullValue(opp.Indication_List__c)+  '<br/>';
                                emailBody += 'Therapy Area: ' +fetchNullValue(opp.TherapyArea__c)+  '<br/>';
                                emailBody += 'Phase: ' +fetchNullValue(opp.Phase_P__c)+  '<br/>';
                                emailBody += 'Primary Loss Reason: ' + fetchNullValue(opp.Primary_Loss_Reason__c) +  '<br/>';
                                emailBody += 'Primary Loss Reason Detail: ' + fetchNullValue(opp.Primary_Loss_Reason_Detail__c) +  '<br/>';
                                emailBody += 'Potential Competitor 1: ' +  fetchNullValue(opp.Potential_Competitor_1__c)+  '<br/>';
                                subject = accountMap.get(opp.AccountId).Parent.Name+ ' Opportunity is Closed Lost';
                            }
                            emailBody += '**This information has been sent to you via the IQVIA CRM System ** <br/>';
                            
                            UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                            message.toUserIds = toUsersIds;
                            message.whatId = opp.Id;
                            message.subject = subject;
                            message.staticContent = emailBody;
                            messageList.add(message);
                        }
                    }
                    if(messageList.size()>0){
                        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
                    }
                }
            }
            
        }
        
    }
    
    /**
     * This method is used to get Opportunity Id mapped with Opportunity Team Members' Id.
     * @params  oppidSet Set<Id> 
     * @return  Map<Id,List<String>>
     */ 
    public static Map<Id,List<String>> getOppMapWithOppTeamMembers(Set<Id> oppidSet){
        Set<String> oppfieldSet = new Set<String>{'id','name'};
        Set<String> oppTeamMemberFieldSet = new Set<String>{'id','name','UserId','OpportunityId'};
                    
        Database.QueryLocator oppList = new SLT_Opportunity().getOpportunityWithOpportunityTeamMember(oppfieldSet,oppidSet,oppTeamMemberFieldSet);
        Database.QueryLocatorIterator oppListIterator = oppList.iterator();
        Map<Id,List<String>> oppMapWithOppTeamMember = new  Map<Id,List<Id>>();
        while(oppListIterator.hasNext()){
            Opportunity opp =  (Opportunity)oppListIterator.next();
            List<String> oppTeamMemberEmailList = new List<String>();
            for(OpportunityTeamMember oppteamMember : opp.OpportunityTeamMembers) {
                oppTeamMemberEmailList.add(oppteamMember.UserId);
            }
            oppMapWithOppTeamMember.put(opp.id,oppTeamMemberEmailList);
        }       
        return oppMapWithOppTeamMember;
    }
    
    public static void validateOpportunityForStage(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            Set<Id> oppIdSet = new Set<Id>();
            Set<Id> OppIdSetMovedToStage5 = new Set<Id>();
            Map<Id,Opportunity> idToOppMap = new Map<Id,Opportunity>();
            Set<String> stage5to7a = new set<String> {CON_CRM.FINALIZING_DEAL_STAGE, CON_CRM.RECEIVED_ATP_STAGE, CON_CRM.CLOSED_WON_STAGE};
            for (Opportunity opp : newList ) {
                if (opp.StageName != oldMap.get(opp.Id).StageName && (opp.StageName == CON_CRM.CLOSED_WON_STAGE || opp.StageName == CON_CRM.IN_HAND_STAGE)) {
                    oppIdSet.add(opp.Id);
                    idToOppMap.put(opp.Id, opp);
                }
                if(opp.StageName != oldMap.get(opp.Id).StageName && stage5to7a.contains(opp.StageName)){
                    OppIdSetMovedToStage5.add(Opp.Id);
                }
            }
            if (oppIdSet.size() > 0) {
                Set<String> oliFieldSet = new Set<String> {'Id','OpportunityId'};
                Set<Id> oppIdsSet = new Set<Id>();
                String filterCondition = 'AND Product_Material_Type__c = \'' + CON_CRM.PRODUCT_MATERIAL_TYPE_ZREP + '\' AND TotalPrice > 0 AND Wbsrelementcode__c = null';
                List<OpportunityLineItem> oliList = new SLT_OpportunityLineItems().selectByOpportunityIdandFilterCondition(oppIdSet, oliFieldSet, filterCondition);
                for (OpportunityLineItem oli : oliList) {
                    oppIdsSet.add(oli.OpportunityId);
                }
                for (Id oppId : oppIdsSet) {
                    idToOppMap.get(oppId).addError(System.Label.CRM_CL0032_RECORD_UPDATE_ERROR);
                }
            }
            if(OppIdSetMovedToStage5.size() > 0){
                String errorMsg = 'This opportunity contains one or more active/planned PSA projects where the related opportunity product has been deleted. Please go to PSA and connect the affected project to another services product on this opportunity using the button "Connect Project with Opp Product". If the project is in stage "Planned" and is no longer needed, please cancel the project by updating the project stage to "Canceled"';
                Set<String> fieldSet = new Set<String>{'Id', 'Opportunity__c'};
                List<Proxy_Project__c> PlannedProject = new SLT_Proxy_Project().getPlannedProjectByOppId(OppIdSetMovedToStage5, fieldSet);
                for(Proxy_Project__c pp:PlannedProject ){
                    Trigger.newMap.get(pp.Opportunity__c).addError(errorMsg);
                }
            }
        }
    }

    /**
     * This method is used to get send mail to Closed Opportunity of parent account owned by Christoph Catta.
     * @params  List<Opportunity> newList
     * @return   Map<Id,Opportunity> oldMap
     */ 
    public static void sendMailToClosedOppUser(List<Opportunity> newList, Map<Id,Opportunity> oldMap) {
        Map<Id, Opportunity> closedOppMap = new Map<Id,Opportunity>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp : newList) {
            if(opp.StageName != oldMap.get(opp.Id).StageName && (opp.StageName == CON_CRM.CLOSED_LOST_STAGE || opp.StageName == CON_CRM.CLOSED_WON_STAGE) && oldMap.get(opp.Id).Actual_Close_Date__c == null && opp.AccountId != null) {
                accountIdSet.add(opp.AccountId);
                oppList.add(opp);
            }
        }
        Account_Setting__c accSetting = Account_Setting__c.getInstance();
        List<String> parentAccountMDMIDs = new List<String>();
        if(accSetting != null  && accSetting.Christoph_Catta_Parent_Account_MDMIDs__c != null){
            parentAccountMDMIDs = accSetting.Christoph_Catta_Parent_Account_MDMIDs__c.split(',');
        }
        if(oppList.size() > 0 && parentAccountMDMIDs != null) {
            Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accountIdSet, new Set<String>{'Name', 'Owner.EmployeeNumber', 'Owner.Email', 'OwnerId', 'Parent.MDMID__c'});
            for (Opportunity opp : oppList) {
                if(accountMap.get(opp.AccountId).Owner.EmployeeNumber == accSetting.Christoph_Catta_Employee_Number__c && opp.AccountId != null && parentAccountMDMIDs.contains(accountMap.get(opp.AccountId).Parent.MDMID__c) ) {
                    closedOppMap.put(opp.Id, opp); 
                }
            }
            if(closedOppMap.values().size() > 0) {
                EmailTemplate templateForClosedOpp = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName('OPP_ET10_CRM_Opportunity_Is_Closed', new Set<String> {'Id','DeveloperName'})[0];
                List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
                for(Opportunity opp : closedOppMap.values()) {
                    UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                    message.toUserIds = new List<String>{accountMap.get(opp.AccountId).OwnerId};
                    message.templateId = templateForClosedOpp.Id;
                    message.whatId = opp.Id;
                    message.targetObjectId = accountMap.get(opp.AccountId).OwnerId;
          			messageList.add(message);
                }
                if(!Test.isRunningTest()) {
                    if(messageList.size() > 0){
             			UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList); 
                    }
                }                
            }            
        }
    }
    
    
    /**
     * This method is used to set Parent Opportunity Number to Parent Number
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     */ 
    public static void setParentNumber(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SobjectType
            }
        );
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<Id> parentOppIdSet = new Set<Id>();
            for (Opportunity opp : newList) {
                if((Trigger.isInsert && opp.Parent_Opportunity__c != null) || (Trigger.isUpdate && opp.Parent_Opportunity__c != oldMap.get(opp.Id).Parent_Opportunity__c)) {
                    parentOppIdSet.add(opp.Parent_Opportunity__c);
                }    
            }
            if (parentOppIdSet.size() > 0) {
                Set<String> fieldSet = new Set<String>{'Id', 'Name', 'Opportunity_Number__c', 'Legacy_Quintiles_Opportunity_Number__c'};
                Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
                oppMap = new SLT_Opportunity().getOpportunityById(parentOppIdSet, fieldSet);
                for(Opportunity opp : newList) {
                    if (opp.Parent_Opportunity__c != null && (Trigger.isInsert || opp.Parent_Opportunity__c != oldMap.get(opp.Id).Parent_Opportunity__c)) {
                        opp.Parent_Number__c = oppMap.get(opp.Parent_Opportunity__c).Opportunity_Number__c;
                        if (oppMap.get(opp.Parent_Opportunity__c).Legacy_Quintiles_Opportunity_Number__c != null) {
                            opp.Parent_Number__c += ' ' + oppMap.get(opp.Parent_Opportunity__c).Legacy_Quintiles_Opportunity_Number__c;
                        }
                    } else if (opp.Parent_Opportunity__c == null && Trigger.isUpdate && opp.Parent_Opportunity__c != oldMap.get(opp.Id).Parent_Opportunity__c) {
                        opp.Parent_Number__c = null;
                    }  
                }    
            }
        } else {
            Set<String> fieldSet = new Set<String>{'Id', 'Name', 'Parent_Number__c'};
            Set<String> parentOppIdSet = new Set<String>();    
            for (Opportunity opp : newList) {
                parentOppIdSet.add(opp.Id);
            }
            List<Opportunity> oppList = new SLT_Opportunity().getOpportunityByParentId(fieldSet, parentOppIdSet);
            for (Opportunity opp : oppList) {
                opp.Parent_Number__c = null;
            }
            if (oppList.size() > 0) {
                uow.registerDirty(oppList);
                uow.commitWork();    
            }
        }
    }
    
    /**
     * This method is used to set Path Probability to 'Verbal' when an Opportunity is moved to 7a. Closed Won
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     */ 
    public static void setPathProbabilityOnClosedWonOpp(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Opportunity> closedWonOppList = new List<Opportunity>();
        for(Opportunity opp : newList) {
            if(trigger.isUpdate && oldMap.get(opp.Id).stageName != opp.stageName && (opp.stageName == CON_CRM.CLOSED_WON_STAGE || opp.stageName == CON_CRM.IN_HAND_STAGE)){
                opp.Path_Probability__c = CON_CRM.VERBAL;
            }
        }
    }  
    
    /**
     * This method is used to set Lead source fields
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     * ESPSFDCQI-6015
     */ 
    public static void setLeadSourceFields(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> oppIdsSet = new Set<Id>();
        List<Opportunity> filteredOppList = new List<Opportunity>();
        for(Opportunity opp : newList) {
            if(trigger.isUpdate && (String.isBlank(opp.Lead_Source_Most_Recent__c) || String.isBlank(opp.Lead_Source_Detail_Most_Recent__c))){
                oppIdsSet.add(opp.Id);
                filteredOppList.add(opp);
            }
        }
        Map<Id,OpportunityContactRole> oppToContactRoleMap = new Map<Id,OpportunityContactRole>();  // using this map we will assign one contactrole record to one opportunity
        List<OpportunityContactRole> ocrList =  new SLT_OpportunityContactRoles().selectByOpportunityId(oppIdsSet,new Set<String>{'ContactId','Contact.Name','Contact.Lead_Source_Most_Recent__c','Contact.Lead_Source_Detail_Most_Recent_Detail__c','OpportunityId'});
        for(OpportunityContactRole ocr : ocrList){
            if(! oppToContactRoleMap.containsKey(ocr.OpportunityId)){
                oppToContactRoleMap.put(ocr.OpportunityId, ocr);
            }
        }
        if(oppToContactRoleMap.size() > 0){
            for(Opportunity opp : filteredOppList) {
                if(oppToContactRoleMap.containsKey(opp.Id)){
                    if(String.isBlank(opp.Lead_Source_Most_Recent__c) && !String.isBlank(String.valueOf(oppToContactRoleMap.get(opp.Id).Contact.Lead_Source_Most_Recent__c))){
                        opp.Lead_Source_Most_Recent__c = String.valueOf(oppToContactRoleMap.get(opp.Id).Contact.Lead_Source_Most_Recent__c);
                    }
                    if(String.isBlank(opp.Lead_Source_Detail_Most_Recent__c) && !String.isBlank(String.valueOf(oppToContactRoleMap.get(opp.Id).Contact.Lead_Source_Detail_Most_Recent_Detail__c))){
                        opp.Lead_Source_Detail_Most_Recent__c = String.valueOf(oppToContactRoleMap.get(opp.Id).Contact.Lead_Source_Detail_Most_Recent_Detail__c);
                    }
                }
            }
        }
    }
    /**
     * 3232-> This method is used to Notify child opportunity owners when parent opportunity move stage 6 and more
     * @params  newList List<opportunity>
     * @params  oldMap Map<Id, opportunity>
     * @return  void 
     */ 
    public static void notifyChildOppOwner(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<String> parentOppIdSet = new Set<String>();
        for(Opportunity opp : newList){
            if(opp.StageName != oldMap.get(opp.id).StageName && (opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE || opp.StageName == CON_CRM.RECEIVED_ATP_STAGE || opp.StageName == CON_CRM.CLOSED_WON_STAGE || opp.StageName == CON_CRM.CLOSED_LOST_STAGE)){
                parentOppIdSet.add(opp.Id);
            }
        }
        if(parentOppIdSet.size() > 0){
            List<Opportunity> childOppList = new SLT_Opportunity().getOpportunityByParentId(new Set<String>{'Id','Name','OwnerId','Owner.Name','StageName','Parent_Opportunity__c','Parent_Opportunity__r.StageName','Parent_Opportunity__r.Name'}, parentOppIdSet);
            if(childOppList.size() > 0){
                List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
                for(Opportunity opp : childOppList){
                    String emailBody = 'Hello '+opp.Owner.Name +',<br/><br/>';
                    String subject = opp.Parent_Opportunity__r.Name+' has been updated to '+opp.Parent_Opportunity__r.StageName;
                    emailBody += 'You are being notified of a change to '+opp.Parent_Opportunity__r.Name+' because you are listed as the owner on a related opportunity.<br/>';
                    emailBody += 'Parent Opportunity Link: <a href="'+URL.getOrgDomainUrl().toExternalForm()+'/'+opp.Parent_Opportunity__c+'">'+opp.Parent_Opportunity__r.Name+'</a><br/>';
                    emailBody += 'Parent Opportunity Stage: ' +opp.Parent_Opportunity__r.StageName+  '<br/>';
                    emailBody += 'Your Opportunity Link: <a href="'+URL.getOrgDomainUrl().toExternalForm()+'/'+opp.Id+'">'+opp.Name+'</a><br/>';

                    UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                    message.toUserIds = new List<String>{opp.OwnerId};
                    message.whatId = opp.Id;
                    message.subject = subject;
                    message.staticContent = emailBody;
                    messageList.add(message);
                }
                if(messageList.size()>0){
             		UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
                }
            }
        }
    }
 
    /**
     * 16937-> This method will send email to Current and New Opp owners when the Owner is changed on the Opportunity
     * @params  newList List<opportunity>
     * @params  oldMap Map<Id, opportunity>
     * @return  void 
     */ 
    public static void sendMailWhenOppOwnerIsChanged(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        Set<Id> OwnerIdSet = new Set<Id>();
        Map<Id, User> IdtoUserMap = new Map<Id, User>();
        
        for(Opportunity opp : newList){
            if(opp.OwnerId != oldMap.get(opp.Id).OwnerId){
                OwnerIdSet.add(opp.OwnerId); 
                OwnerIdSet.add(oldMap.get(opp.Id).OwnerId);
            }
        } 
        
        if(OwnerIdSet.size() > 0){
            IdtoUserMap = new SLT_User().selectByUserId(OwnerIdSet, new Set<String>{'Name','isActive'});  
        }
        
        for(Opportunity opp : newList){
            if(opp.OwnerId != oldMap.get(opp.Id).OwnerId){
                String subject ='Update on Opportunity ' + opp.Opportunity_Number__c + ' Ownership';                    
                String emailBody = 'Dear '+ IdtoUserMap.get(oldMap.get(opp.Id).OwnerId).Name +',<br/><br/>';
                emailBody += 'Please be advised that the ownership of the opportunity '+opp.Name+',Opportunity Number - '+ opp.Opportunity_Number__c +' has been reassigned.<br/>';
                emailBody += 'The new opportunity owner is '+ IdtoUserMap.get(opp.OwnerId).Name +'<br/><br/><br/>';
                emailBody += 'You can view the details of the opportunity here. '+ URL.getOrgDomainUrl().toExternalForm() + '/' + opp.Id +'<br/><br/><br/>';
                emailBody += 'Please feel free to reach to the new opportunity owner if you have any questions.<br/><br/><br/>';
                emailBody += 'Thank you. <br/><br/>';
                emailBody += 'CRM Team <br/><br/>';
                
                
                UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                if(IdtoUserMap.get(oldMap.get(opp.Id).OwnerId).isActive){
                    message.toUserIds = new List<String>{opp.OwnerId,oldMap.get(opp.id).OwnerId};
                }else{
                     message.toUserIds = new List<String>{opp.OwnerId}; 
                }
                message.whatId = opp.Id;
                message.subject = subject;
                message.staticContent = emailBody;
                messageList.add(message);                    
            }
            if(messageList.size()>0)
                UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);                
        }        
    }
    
    public static void sendWinLossAlertMail(Set<Id> oppIdRomaniaSet, Set<Id> oppIdGermanySet){
        
        Set<String> emailFieldSet = new Set<String> {'Id','Subject','DeveloperName'};
        Set<String> cgmFieldSet = new Set<String> {'Id','Member.Email','CollaborationGroup.Name','CollaborationRole'};
                
        List<EmailTemplate> emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(CON_CRM.etName, emailFieldSet);
        
        String whereCondtion = 'CollaborationGroup.Name = \''+CON_CRM.cgName+'\' OR CollaborationGroup.Name = \''+CON_CRM.cgName2+'\'';
        List<CollaborationGroupMember> chatterGroupMemeber = new SLT_CollaborationGroupMember().selectCollaborationGroupMemberByWhereCondtion(whereCondtion, cgmFieldSet);
        
        List<String> emailAdressRomania = New List<String>();
        List<String> emailAdressGermany = New List<String>();
        for(CollaborationGroupMember cgm : chatterGroupMemeber){
            if(cgm.CollaborationRole != CON_CRM.admin){
                if(cgm.CollaborationGroup.Name == CON_CRM.cgName){
                    emailAdressRomania.add(cgm.Member.Email);
                }else if(cgm.CollaborationGroup.Name == CON_CRM.cgName2){
                    emailAdressGermany.add(cgm.Member.Email);
            	}                
            }
        }
        
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        if(emailAdressRomania.size() > 0) {
            for(Id targetObjectId : oppIdRomaniaSet) {
                UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                message.targetObjectId = UserInfo.getUserId();
                message.templateId = emailTemplate[0].Id;
                message.whatId = targetObjectId;
                message.toEmails = emailAdressRomania;
                messageList.add(message);
            }            
        }
        if(emailAdressGermany.size() > 0) {
            for(Id targetObjectId : oppIdGermanySet) {
                UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                message.targetObjectId = UserInfo.getUserId();
                message.isTargetObjectAsRecipient = false;
                message.templateId = emailTemplate[0].Id;
                message.whatId = targetObjectId;
                message.toEmails = emailAdressGermany;
                messageList.add(message);            
            }            
        }
        if(messageList.size()>0){
            UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
        }
    }
	
    /*
     * This Method send Email
    */
    public static void winLossAlertEmail(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        
        Set<String> oliFieldSet = new Set<String> {'Id','OpportunityId','Delivery_Country__c'};
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, OpportunityLineItem> newOppProductMap = new Map<Id, OpportunityLineItem>();
        
        Set<Id> oppIdRomaniaSet = new Set<Id>();
        Set<Id> oppIdGermanySet = new Set<Id>();
        
        Set<Id> oppIdRomaniaSet2 = new Set<Id>();
        Set<Id> oppIdGermanySet2 = new Set<Id>();
        
        
        for(Opportunity opp : newList){
            if(opp.StageName != oldMap.get(opp.id).StageName  && 
               (opp.StageName == CON_CRM.RECEIVED_ATP_STAGE || opp.StageName ==CON_CRM.CLOSED_WON_STAGE || opp.StageName == CON_CRM.CLOSED_LOST_STAGE)
              ){
                    oppIdSet.add(opp.ID);
                    oppList.add(opp);
                }
        }
        if(oppIdSet.size() > 0){
            
            newOppProductMap = new SLT_OpportunityLineItems().selectByOpportunityId(oppIdSet, oliFieldSet);          
            for(OpportunityLineItem oli : newOppProductMap.values()){            
                if(oli.Delivery_Country__c == CON_CRM.Delivery_Country_Romania){
                    oppIdRomaniaSet.add(oli.OpportunityId);                
                }
                else if(oli.Delivery_Country__c == CON_CRM.Delivery_Country_Germany){
                    oppIdGermanySet.add(oli.OpportunityId);                
                }            
            }
            
            for(Opportunity opp : oppList){
                if((opp.Amount_In_USD__c > 15000 && oppIdRomaniaSet.contains(opp.Id)) || (opp.Amount_In_USD__c > 100000 && oppIdGermanySet.contains(opp.Id))){
                    if(oppIdRomaniaSet.contains(opp.Id)){
                        oppIdRomaniaSet2.add(opp.Id);
                    }
                    if(oppIdGermanySet.contains(opp.Id)){
                        oppIdGermanySet2.add(opp.Id);
                    }
                }
            }
            if(oppIdRomaniaSet2.size() > 0 || oppIdGermanySet2.size() > 0 ){
                sendWinLossAlertMail(oppIdRomaniaSet2, oppIdGermanySet2);                
            }
        }       
    }
	
    /**
     * This method is used to set Stage Last Changed Date whenever an Opportunity is changed.
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     */ 
    public static void setStageLastChangesDate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for(Opportunity opp : newList){
            if(opp.StageName != oldMap.get(opp.id).StageName){
                opp.Stage_Last_Changed_Date__c = System.today();
            }
        }
    }
    
    /**
    * This method is used to set Competitor Picklist Value whenever an Opportunity's Competitor fields are changed.
    * @params List<Opportunity> newList
    * @params Map<Id, Opportunity> oldMap
    * @return void
    */ 
    public static void updateSalesSpotCompetitor(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<Id> competitorIdSet = new Set<Id>();
        for(Opportunity opp : newList) {
            if(Trigger.isInsert ||
               (Trigger.isUpdate && (opp.Potential_Competitor_1__c != oldMap.get(opp.id).Potential_Competitor_1__c ||
                                     opp.Potential_Competitor_2__c != oldMap.get(opp.id).Potential_Competitor_2__c ))) {
                                         opp.SalesSpot_Competitor__c = null;
                                         if(opp.Potential_Competitor_1__c != null) {
                                             competitorIdSet.add(opp.Potential_Competitor_1__c);
                                         }
                                         if(opp.Potential_Competitor_2__c != null) {
                                             competitorIdSet.add(opp.Potential_Competitor_2__c);
                                         }
                                     }
        }
        if(competitorIdSet.size() > 0) { 
            SLT_Competitor compSelector = new SLT_Competitor();
            Set<String> fieldSet = new Set<String>{'Id','Name','SalesSpot_Enabled__c'};
            Set<String> salesSpotCompSet = new Set<String>();
            List<String> salesSpotCompList = new List<String>();
            Map<Id, Competitor__c> competitorIdToCompetitorMap = compSelector.selectSalesSpotCompetitorById(competitorIdSet, fieldSet);
            for(Opportunity opp : newList) {
                if(competitorIdToCompetitorMap.containsKey(opp.Potential_Competitor_1__c)) {
                    salesSpotCompSet.add(competitorIdToCompetitorMap.get(opp.Potential_Competitor_1__c).Name);
                }
                if(competitorIdToCompetitorMap.containsKey(opp.Potential_Competitor_2__c)) {
                    salesSpotCompSet.add(competitorIdToCompetitorMap.get(opp.Potential_Competitor_2__c).Name);
                }
                salesSpotCompList.addAll(salesSpotCompSet);
                if(salesSpotCompSet.size() == 1) {
                    opp.SalesSpot_Competitor__c = salesSpotCompList[0];
                } else if(salesSpotCompSet.size() == 2) {
                    opp.SalesSpot_Competitor__c = salesSpotCompList[0] + ';' + salesSpotCompList[1];
                }           
            }           
        }
    }

    /**
     * This method is used to send the email alerts on credit Assessment.
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     */ 
    public static void creditAssessmentCheck(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<String> accFieldSet = new Set<String> {'Id','Parent.Category__c','Date_Risk_Expiry_Date__c','Global_Date_Risk_Assessed__c', 'AccountCountry__c', 'Name'};
        Set<Id> accIdSet = new Set<Id>();
        Set<String> accCountrySet = new Set<String>();
                
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        List<credit_control_Threshold__c> creditControlThresholdList = new List<credit_control_Threshold__c>();
        
        for(Opportunity opp : newList){
            if(opp.StageName != oldMap.get(opp.id).StageName || opp.Amount_In_USD__c != oldMap.get(opp.id).Amount_In_USD__c || CON_CRM.isUpdateFromRevenueSchedule){
                if((opp.StageName == CON_CRM.DEVELOPING_PROP_STAGE || opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE)){
                    if(opp.AccountId != null){
                        oppMap.put(opp.Id, opp);
                        accIdSet.add(opp.AccountId);                       
                    }                        
                } 
            }
        }
        if(accIdSet.size() > 0){
            accMap = new SLT_Account().getAccountsWithAccountIdAndWhereCondtion(accIdSet, accFieldSet, CON_CRM.ACCOUNT_MDM_CATEGORY_LARGE_PHARMA);
            if(accMap.size() > 0){
                accIdSet = new Set<Id>();
                for(Account acc: accMap.values()){
                    accIdSet.add(acc.Id);
                    accCountrySet.add(acc.AccountCountry__c);
                }
                creditControlThresholdList = new SLT_Credit_Control_Threshold().getCreditControlThresholdByAccountId(accIdSet, accCountrySet);
                if(creditControlThresholdList.size() > 0){                    
                    getCreditAssesmentOpportunity(oppMap, creditControlThresholdList, accMap);
                }                	
            }            
        }
    }
    
    public static void getCreditAssesmentOpportunity(Map<Id, Opportunity> newOppMap, List<Credit_control_Threshold__c> creditControlThresholdList, Map<Id, Account> accMap){
        Map<String, Decimal> creditControlMap = new Map<String, Decimal>();
        Map<Opportunity, List<CreditControlWrapper>> oppToCreditControlWrapperMap = new Map<Opportunity, List<CreditControlWrapper>>();
        for (Credit_control_Threshold__c cc : creditControlThresholdList) {
            String Key = '';
            if (cc.Account__c == null && cc.Country__c == null && cc.Business_Unit__c == null) {
                creditControlMap.put('Global', cc.Threshold_value_USD__c);
            } else {
                if (cc.Account__c != null) {
                    key = cc.Account__c;
                }
                if (cc.Country__c != null) {
                    key += cc.Country__c;
                }
                if (cc.Business_Unit__c != null) {
                    key += cc.Business_Unit__c;
                }
            }
            creditControlMap.put(key, cc.Threshold_value_USD__c);
        }
        
        for(Opportunity opp : newOppMap.values()){
            String key = '';
            String businessUnit = '';
            Double buAmountValue = 0;
            if(accMap.containsKey(opp.AccountId)){
                oppToCreditControlWrapperMap.put(opp, new List<CreditControlWrapper>());
                key = opp.AccountId;
                if (creditControlMap.containsKey(key)) {
                    CreditControlWrapper creditWrapper = new CreditControlWrapper();
                    creditWrapper.heirarchyLevel = 'Account';
                    creditWrapper.heirarchyLevelThreshold = creditControlMap.get(key);
                    if (opp.Amount_In_USD__c >= creditControlMap.get(key)) {
                        creditWrapper.isThresholdExceed = true;
                        oppToCreditControlWrapperMap.get(opp).add(creditWrapper);
                    }
                } else {
                    Key = accMap.get(opp.AccountId).AccountCountry__c;
                    if (creditControlMap.containsKey(key)) {
                        CreditControlWrapper creditWrapper = new CreditControlWrapper();
                        creditWrapper.heirarchyLevel = 'Country';
                        creditWrapper.heirarchyLevelThreshold = creditControlMap.get(key);
                        if (opp.Amount_In_USD__c >= creditControlMap.get(key)) {
                            creditWrapper.isThresholdExceed = true;
                            oppToCreditControlWrapperMap.get(opp).add(creditWrapper);
                        }
                    } else {
                        key = 'Global';
                        if (creditControlMap.containsKey(key)) {
                            CreditControlWrapper creditWrapper = new CreditControlWrapper();
                            creditWrapper.heirarchyLevel = 'Global';
                            creditWrapper.heirarchyLevelThreshold = creditControlMap.get(key);
                            if (opp.Amount_In_USD__c >= creditControlMap.get(key)) {
                                creditWrapper.isThresholdExceed = true;
                                oppToCreditControlWrapperMap.get(opp).add(creditWrapper);
                            }
                        }
                    }
                }
                for (Integer index = 1; index <= 6; index++) {
                    key = '';
                    businessUnit = '';
                    buAmountValue = 0;
                    if (index == 1) {
                        if (opp.CSMS_Product__c > 0 && opp.CSMS_Product_Amount__c > 0) {
                            businessUnit = 'CSMS';
                            buAmountValue = opp.CSMS_Product_Amount__c;    
                        }
                    } else if (index == 2) {
                        if (opp.GMI_Product_Count__c > 0 && opp.GMI_Product_Amount__c > 0) {
                            businessUnit = 'GMI';
                            buAmountValue = opp.GMI_Product_Amount__c;    
                        }
                    } else if (index == 3) {
                        if (opp.Q2_Product_Count__c > 0 && opp.Q2_Product_Amount__c > 0) {
                            businessUnit = 'Q2';
                            buAmountValue = opp.Q2_Product_Amount__c;    
                        }
                    } else if (index == 4) {
                        if ((opp.RD_Product_Count__c - opp.Q2_Product_Count__c) > 0 && (opp.RD_Product_Amount__c - opp.Q2_Product_Amount__c) > 0) {
                            businessUnit = 'RDS';
                            buAmountValue = opp.RD_Product_Amount__c - opp.Q2_Product_Amount__c;    
                        }
                    } else if (index == 5) {
                        if (opp.RWAS_Product_Count__c > 0 && opp.RWAS_Product_Amount__c > 0) {
                            businessUnit = 'RWS';
                            buAmountValue = opp.RWAS_Product_Amount__c;    
                        }
                    } else if (opp.Commercial_Tech_Product_Count__c > 0 && opp.Tech_Analytic_Product_Amount__c > 0) {
                        businessUnit = 'TCS';
                        buAmountValue = opp.Tech_Analytic_Product_Amount__c;    
                    }
                    
                    if (buAmountValue > 0) {                              
                        Key = opp.AccountId + businessUnit;
                        if (creditControlMap.containsKey(key)) {
                            CreditControlWrapper creditWrapper = new CreditControlWrapper();
                            creditWrapper.businessAmount = buAmountValue;
                            creditWrapper.businessThreshold = creditControlMap.get(key);
                            creditWrapper.businessheirarchyLevel = 'Account';
                            creditWrapper.businessUnit = businessUnit;
                            if (buAmountValue >= creditControlMap.get(key)) {
                                oppToCreditControlWrapperMap.get(opp).add(creditWrapper);
                            }
                        } else {
                            Key = accMap.get(opp.AccountId).AccountCountry__c + businessUnit;
                            if (creditControlMap.containsKey(key)) {
                                CreditControlWrapper creditWrapper = new CreditControlWrapper();
                                creditWrapper.businessAmount = buAmountValue;
                                creditWrapper.businessThreshold = creditControlMap.get(key);
                                creditWrapper.businessheirarchyLevel = 'Country';
                                creditWrapper.businessUnit = businessUnit;
                                if (buAmountValue >= creditControlMap.get(key)) {
                                    oppToCreditControlWrapperMap.get(opp).add(creditWrapper);
                                }
                            } else {
                                Key = businessUnit;
                                if (creditControlMap.containsKey(key)) {
                                    CreditControlWrapper creditWrapper = new CreditControlWrapper();
                                    creditWrapper.businessAmount = buAmountValue;
                                    creditWrapper.businessThreshold = creditControlMap.get(key);
                                    creditWrapper.businessheirarchyLevel = 'Global';
                                    creditWrapper.businessUnit = businessUnit;
                                    if (buAmountValue >= creditControlMap.get(key)) {
                                        oppToCreditControlWrapperMap.get(opp).add(creditWrapper);
                                    }
                                }
                            }
                        }
                    } 
                }
                if (oppToCreditControlWrapperMap.get(opp).size() == 0) {
                    oppToCreditControlWrapperMap.remove(opp);
                }
            }
        }
        if(oppToCreditControlWrapperMap.size() > 0) {
            sendCreditAssessmentCheckEmail(oppToCreditControlWrapperMap, accMap);    
        }
    }
    
    public static void sendCreditAssessmentCheckEmail(Map<Opportunity, List<CreditControlWrapper>> oppToCreditControlWrapperMap, Map<Id,Account> accMap){
        List<IQVIA_Sandbox_Name__c> sandboxes = IQVIA_Sandbox_Name__c.getall().values();
        Set<String> sandboxNames = new Set<String>();
        for(IQVIA_Sandbox_Name__c s : sandboxes){
            sandboxNames.add(s.Sandbox_Name__c);
        }
        System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());
		String sandboxName = domain.getSandboxName();
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        for(Opportunity opp : oppToCreditControlWrapperMap.KeySet()) {
            List<CreditControlWrapper> cctWrapperList = oppToCreditControlWrapperMap.get(opp);
            String subject = 'Credit Assessment Needed for ' + accMap.get(opp.AccountId).Name;
            String emailBody = 'Please note that a risk assessment for ' + opp.Name + ' is required by policy '; 
            emailBody += 'and should be requested ASAP to prevent any delays in contracting. ';  
            emailBody += 'A risk assessment can be requested through VIA at the following link: ';
            emailBody += 'https://quintiles.service-now.com/via?id=sc_cat_item&sys_id=4f8a8ae91b75d91076bfdb1dbc4bcb96. ';
            emailBody += 'This is due to the fact that the amount of the opportunity has exceeded the following threshold(s):';
            emailBody += '<br/><br/>';
            emailBody += '<table style="border-collapse: collapse;border: 0.1px solid black;width:100%">';
            emailBody += '<colgroup span="2"></colgroup><colgroup span="2"></colgroup>';            
            Integer counter = 0;
            if (cctWrapperList[0].businessUnit != '') {
                emailBody += '<tr><th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">Opportunity Total Amount :<br/>' + opp.Amount_In_USD__c + '</th>';
                emailBody += '<th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">Opportunity Threshold :<br/>N/A' + '</th>';
            }
            for (CreditControlWrapper ccw : cctWrapperList) {
                if (ccw.businessUnit == '') {
                    if (ccw.isThresholdExceed) {
                        emailBody += '<tr><th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;"><font color="red">Opportunity Total Amount :<br/>' + opp.Amount_In_USD__c + '</font></th>';
                        emailBody += '<th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;"><font color="red">Opportunity Threshold(' + ccw.heirarchyLevel + ') : <br/>' + ccw.heirarchyLevelThreshold + '</font></th>';
                        
                    } else {
                        emailBody += '<tr><th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">Opportunity Total Amount :<br/>' + opp.Amount_In_USD__c + '</th>';
                        emailBody += '<th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">Opportunity Threshold(' + ccw.heirarchyLevel + ') :<br/>' + ccw.heirarchyLevelThreshold + '</th>';
                    }    
                }
                else {
                    if (counter == 0) {
                        emailBody += '<tr><th scope="col" style="border-collapse: collapse;border: 0.1px solid black;">BU</th>';
                        emailBody += '<th scope="col" style="border-collapse: collapse;border: 0.1px solid black;">BU Total Amount</th>';
                        emailBody += '<th scope="col" style="border-collapse: collapse;border: 0.1px solid black;">BU Threshold</th>';
                        emailBody += '<th scope="col" style="border-collapse: collapse;border: 0.1px solid black;">BU Heirarchy Level</th></tr>';    
                        counter++;
                    }
                    emailBody += '<tr><td scope="col" style="border-collapse: collapse;border: 0.1px solid black;text-align: center;"><font color="red">' + ccw.businessUnit + '</font></td>';
                    emailBody += '<td scope="col" style="border-collapse: collapse;border: 0.1px solid black;text-align: center;"><font color="red">' + ccw.businessAmount.toPlainString()  +'</font></td>';
                    emailBody += '<td scope="col" style="border-collapse: collapse;border: 0.1px solid black;text-align: center;"><font color="red">' + ccw.businessThreshold + '</font></td>';
                    emailBody += '<td scope="col" style="border-collapse: collapse;border: 0.1px solid black;text-align: center;"><font color="red">' + ccw.businessheirarchyLevel + '</font></td>';
                    emailBody += '</tr>';    
                }
            }
            emailBody += '</table>';
            List<String> emailList = new List<String>();
            emailList.add(opp.Owner_Email__c);
            semail.setWhatId(opp.Id);
            semail.setSubject(subject);
            semail.setHtmlBody(emailBody);
            semail.setToAddresses(emailList);
            if(sandboxNames.contains(sandboxName) || String.isBlank(sandboxName)){
                OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: CON_CRM.CREDIT_ASSESSMENT_EMAIL];
                if(owea.size() > 0){
                    semail.setOrgWideEmailAddressId(owea.get(0).Id); 
                } 
            }     
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
    }

    /**
     * This method is used to set next Survey Send Date or upcoming survey date whenever an Opportunity contract start date or Expected project start date is changed.
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     */ 
    public static void stampedSurveySentDates(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Integer intakeSurveyDelay = 0;
        if(Survey_Setting__c.getInstance() != null && Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c != null) {
            intakeSurveyDelay = (Integer) Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c;   
        }
        Date todayDate = System.today().addDays(intakeSurveyDelay);
        Map<Id,Opportunity> changedOppMap = new Map<Id,Opportunity>();
        For(Opportunity opp : newList){
            if(!opp.Is_Survey_Exist__c  && (opp.stageName == CON_CRM.CLOSED_WON_STAGE || opp.stageName == CON_CRM.IN_HAND_STAGE)){
                if(!changedOppMap.containsKey(opp.id)){
                    changedOppMap.put(opp.id,opp);
                }
            } else if(opp.stageName != oldMap.get(opp.Id).stageName && !(opp.stageName == CON_CRM.CLOSED_WON_STAGE || opp.stageName == CON_CRM.IN_HAND_STAGE)){
                opp.Next_Survey_Send_Date__c = null;
                opp.Upcoming_Survey_Send_Date__c = null;
            }
        }
        Map<Id,Proxy_Project__c> proxyProjectMap = new Map<Id,Proxy_Project__c>();
        if(changedOppMap.Size() > 0){
            proxyProjectMap= new SLT_proxy_Project().getProxyProjectByOppIDAndRecordTypeName(changedOppMap.keyset(), 'Engagement', new Set<String>{'ID','Name','Opportunity__c','Project_Start_Date__c', 'Project_End_Date__c'});
        }
        Set<String> lineOfBusiness = new Set<String>{'Clinical','Data Sciences','Early Clinical Development','Connected Devices','Patient & DCT Solutions'};    
            
            if(changedOppMap.Size() > 0){
                for(Id opp : changedOppMap.keyset()){
                    Boolean isUpdate = false;
                    Date nearestFutureDate;
                    Date endDate;
                    Integer interval;
                    if(changedOppMap.get(opp).Contract_Start_Date__c != null && (changedOppMap.get(opp).Contract_Start_Date__c != oldMap.get(opp).Contract_Start_Date__c || changedOppMap.get(opp).stageName != oldMap.get(opp).stageName)){
                        if(changedOppMap.get(opp).Is_Survey_Eligible_for_RDS_Auto__c && !lineOfBusiness.contains(changedOppMap.get(opp).Line_of_Business__c) ){
                            isUpdate = true;
                            nearestFutureDate = changedOppMap.get(opp).Contract_Start_Date__c.addMonths(6);
                            endDate = changedOppMap.get(opp).Contract_End_Date__c; 
                            
                            if(changedOppMap.get(opp).ZREP_Product_Count__c > 0 && proxyProjectMap.size() > 0 && (proxyProjectMap.containsKey(opp))) {
                                nearestFutureDate = proxyProjectMap.get(opp).Project_Start_Date__c.addMonths(6);
                                endDate = proxyProjectMap.get(opp).Project_End_Date__c;
                            }
                            interval = 6;
                            while(nearestFutureDate < todayDate) {
                                nearestFutureDate = nearestFutureDate.addMonths(interval);   
                            }
                            if(nearestFutureDate >= endDate) {
                                nearestFutureDate = endDate;
                            }
                        } else if(changedOppMap.get(opp).Is_Survey_Eligible_for_Non_RDS__c){
                            isUpdate = true;
                            nearestFutureDate = changedOppMap.get(opp).Contract_Start_Date__c.addMonths(12);
                            endDate = changedOppMap.get(opp).Contract_End_Date__c;
                            if(changedOppMap.get(opp).ZREP_Product_Count__c > 0 && proxyProjectMap.size() > 0 && (proxyProjectMap.containsKey(opp))) {
                                nearestFutureDate = proxyProjectMap.get(opp).Project_Start_Date__c.addMonths(12);
                                endDate = proxyProjectMap.get(opp).Project_End_Date__c;
                            }
                            interval = 12;        
                            while(nearestFutureDate < todayDate) {
                                nearestFutureDate = nearestFutureDate.addMonths(interval);   
                            }
                            Date Date6more = nearestFutureDate.addMonths(6);
                            if(Date6more >= endDate){
                                nearestFutureDate = endDate;
                            }
                        }
                    }
                    if(changedOppMap.get(opp).Expected_Project_Start_Date__c != null && ((changedOppMap.get(opp).Expected_Project_Start_Date__c != oldMap.get(opp).Expected_Project_Start_Date__c) || (changedOppMap.get(opp).stageName != oldMap.get(opp).stageName))){
                        if(changedOppMap.get(opp).Is_Survey_Eligible_for_RDS_Auto__c  && lineOfBusiness.contains(changedOppMap.get(opp).Line_of_Business__c) ){
                            isUpdate = true;
                            nearestFutureDate = changedOppMap.get(opp).Expected_Project_Start_Date__c.addMonths(6);
                            endDate = changedOppMap.get(opp).Expected_Project_End_Date__c;
                            if(changedOppMap.get(opp).ZREP_Product_Count__c > 0 && proxyProjectMap.size() > 0 && (proxyProjectMap.containsKey(opp))) {
                                nearestFutureDate = proxyProjectMap.get(opp).Project_Start_Date__c.addMonths(6);
                                endDate = proxyProjectMap.get(opp).Project_End_Date__c;
                            }
                            interval = 6;                   
                            while(nearestFutureDate < todayDate) {
                                nearestFutureDate = nearestFutureDate.addMonths(interval);
                            }
                            if(nearestFutureDate >= endDate) {
                                nearestFutureDate = endDate;
                            }
                        }
                    }
                    
                    if(isUpdate){
                        //while(nearestFutureDate < todayDate) {
                        //nearestFutureDate = nearestFutureDate.addMonths(interval);
                        //}
                        changedOppMap.get(opp).Next_Survey_Send_Date__c = nearestFutureDate;
                        changedOppMap.get(opp).Upcoming_Survey_Send_Date__c = nearestFutureDate;
                    }
                }
            }
    }

    /**
     * This method is used to update survey fields when opp fields are changed; a future method is called.
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     */ 
    public static void updateSurveyFields(List<Opportunity> newList, Map<Id, Opportunity> oldMap){ 
        Map<Id, String> oppIdMapWithFieldsChanged = new Map<Id, String>();
        Set<String> oppfieldsToUpdate = new Set<String>{'Principle_inCharge__c', 'Survey_PIC__c', 'BidTeam_2__c', 'Survey_Recipient__c',
            'Survey_Recipient_2__c','Survey_Recipient_3__c'};
        String fieldsChanged;
        String COMMA = ',';
        for(Opportunity opp : newList){
            fieldsChanged = '';
            if((opp.StageName == CON_CRM.CLOSED_WON_STAGE || opp.StageName == CON_CRM.IN_HAND_STAGE) && (opp.Is_Survey_Eligible_for_RDS_Auto__c || opp.Is_Survey_Eligible_for_RDS_Manual__c || opp.Is_Survey_Eligible_for_Non_RDS__c)){
                for(String oppField : oppfieldsToUpdate){
                    if(opp.get(oppField) != oldMap.get(opp.id).get(oppField)) {
                        fieldsChanged += oppField + COMMA;
                    }
                }
                if(!String.isEmpty(fieldsChanged)){
                    oppIdMapWithFieldsChanged.put(opp.id, fieldsChanged);
                }
            }
        } 
        if(oppIdMapWithFieldsChanged.size() > 0){
            updateSurveyFieldFuture(oppIdMapWithFieldsChanged);
        }
    }
    
    /**
     * This method is a future method to update survey fields when Opportunity fields are changed
     * @params Map<Id, String> oppWithFields
     * @return  void
     */
    @future
    public static void updateSurveyFieldFuture(Map<Id, String> oppWithFields){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Client_Sat_Survey__c.SobjectType});
        List<Opportunity> oppList = new SLT_Opportunity().getLatestSurveyOfOpportunity(oppWithFields.keyset());
        List<String> fieldset = new List<String>();
        Boolean toCommit = false;
        for(Opportunity opp: oppList){
            List<Client_Sat_Survey__c> latestSurvey = opp.Client_Sat_Surveys__r;
            if(latestSurvey.size() > 0){
                Client_Sat_Survey__c cs = latestSurvey[0];
                fieldset = oppWithFields.get(opp.id).split(',');
                if(fieldset.size() > 0){
                    if(fieldset.contains('Principle_inCharge__c') && cs.Related_Contract_Id__c == null && !(opp.Line_of_Business__c == 'Health Engagement & Communication' || opp.Line_of_Business__c == 'Commercial Solutions')){
                        cs.Survey_PIC__c = opp.Principle_inCharge__c;
                        cs.Survey_PIC_Name__c = opp.Principle_inCharge__r.Salesforce_user__r.Name;
                        cs.Survey_PIC_Email__c = opp.Principle_inCharge__r.Salesforce_user__r.Email;
                        cs.Survey_PIC_Email1__c = opp.Principle_inCharge__r.Salesforce_user__r.Email;
                        cs.Survey_PIC_First_Name__c = opp.Principle_inCharge__r.Salesforce_user__r.FirstName;
                        cs.Survey_PIC_Last_Name__c = opp.Principle_inCharge__r.Salesforce_user__r.LastName;
                        cs.Survey_PIC_EmployeeNumber__c = opp.Principle_inCharge__r.Salesforce_user__r.EmployeeNumber;
                        cs.PIC_Country__c = opp.Principle_inCharge__r.Salesforce_user__r.User_Country__c;   
                    }
                    if(fieldset.contains('Survey_PIC__c') && ( opp.Line_of_Business__c == 'Clinical' || ( cs.Related_Contract_Id__c == null && (opp.Line_of_Business__c == 'Health Engagement & Communication' || opp.Line_of_Business__c == 'Commercial Solutions' )))){
                        cs.Survey_PIC__c = opp.Survey_PIC__c;
                        cs.Survey_PIC_Name__c = opp.Survey_PIC__r.Salesforce_user__r.Name;
                        cs.Survey_PIC_Email__c = opp.Survey_PIC__r.Salesforce_user__r.Email;
                        cs.Survey_PIC_Email1__c = opp.Survey_PIC__r.Salesforce_user__r.Email;
                        cs.Survey_PIC_First_Name__c = opp.Survey_PIC__r.Salesforce_user__r.FirstName;
                        cs.Survey_PIC_Last_Name__c = opp.Survey_PIC__r.Salesforce_user__r.LastName;
                        cs.Survey_PIC_EmployeeNumber__c = opp.Survey_PIC__r.Salesforce_user__r.EmployeeNumber;
                        cs.PIC_Country__c = opp.Survey_PIC__r.Salesforce_user__r.User_Country__c; 
                    }
                    if(fieldset.contains('BidTeam_2__c')){
                        cs.Survey_EM__c = opp.BidTeam_2__c;
                        cs.Survey_EM_Name__c = opp.BidTeam_2__r.Salesforce_User__r.Name;
                        cs.Survey_EM_Email__c = opp.BidTeam_2__r.Salesforce_User__r.Email;
                        cs.Survey_EM_Email1__c = opp.BidTeam_2__r.Salesforce_User__r.Email;
                        cs.Survey_EM_EmployeeNumber__c = opp.BidTeam_2__r.Salesforce_User__r.EmployeeNumber;
                    }
                    if(fieldset.contains('Survey_Recipient__c')){
                        cs.Survey_Recipient_1__c = opp.Survey_Recipient__c;
                    }
                    if(fieldset.contains('Survey_Recipient_2__c')){
                        cs.Survey_Recipient_2__c = opp.Survey_Recipient_2__c;
                    }
                    if(fieldset.contains('Survey_Recipient_3__c')){
                        cs.Survey_Recipient_3__c = opp.Survey_Recipient_3__c;
                    }
                    toCommit = true;
                    uow.registerDirty(cs);
                }
            }  
        }
        if(toCommit){
            UTL_ExecutionControl.stopTriggerExecution = true;
            uow.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
    
    /**
     * This method is used to validate whether the user has sufficient privileges to freeze/unfreeze the Opportunity.
     * It also notifies the opportunity owner when the opportunity got freezed.
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     */ 
    public static void setFreezeUnfreezeOpp(Map<Id,Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Boolean isSuperUser = false;
        Set<Id> groupIdSet = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        Credit_Control_Groups__c cs = Credit_Control_Groups__c.getOrgDefaults();
        if (cs.Group_Names__c != null) { 
            Set<String> groupNameSet = new Set<String>(cs.Group_Names__c.split(','));
            Id userId = UserInfo.getUserId();
            List<GroupMember> groupMemberList = new List<GroupMember>();
            groupMemberList = new SLT_GroupMember().getGroupMembersByUserAndGroupNameSet(userId, groupNameSet);
            for (GroupMember gm : groupMemberList) {
                if(gm.Group.Name == CON_CRM.SUPER_CREDIT_CONTROL_ADMIN_GROUP) {
                    isSuperUser = true;
                    break;
                }
            }
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> oppIdSet = new Set<Id>();
            for (Opportunity opp : newMap.values()) {
                if ((Trigger.isInsert && opp.Is_Frozen__c != null) || (Trigger.isUpdate && opp.Is_Frozen__c != oldMap.get(opp.Id).Is_Frozen__c)) {
                    if (groupMemberList.size() == 0) {
                        opp.addError(System.Label.CRM_CL0036_Opportunity_Is_Frozen_Update_Error);
                    } else if (isSuperUser) {
                        if(opp.Is_Frozen__c == CON_CRM.OPP_IS_FROZEN) { 
                            oppList.add(opp);	
                        }  
                    } else {
                        accountIdSet.add(opp.AccountId);
                        oppIdSet.add(opp.Id);
                    }
                }
            }
            Map<Id, Account> accountMap = new Map<Id, Account>();
            Set<String> fieldSet = new Set<String>{'Id', 'Global_Risk_Rating__c'};
            if (accountIdSet.size() > 0) {
                accountMap = new SLT_Account().selectAccountByIdAndRiskRating(fieldSet, accountIdSet, CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL);
                for (Id oppId : oppIdSet) {
                    if(accountMap.containsKey(newMap.get(oppId).AccountId)) {
                        newMap.get(oppId).addError(System.Label.CRM_CL0036_Opportunity_Is_Frozen_Update_Error_2);
                    } else if(newMap.get(oppId).Is_Frozen__c == CON_CRM.OPP_IS_FROZEN) {
                        oppList.add(newMap.get(oppId));
                    }
                }
            }
            if (oppList.size() > 0) {
                notifyOppOwnerOnOppFreeze(oppList);
            }
        }
    }
    
    /**
     * Mail send to Opportunity Owner
     * @params List<Opportunity> oppList
     * @return  void
     */ 
    public static void notifyOppOwnerOnOppFreeze(List<Opportunity> oppList) {
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        Set<String> emailFieldSet = new Set<String> {'Id', 'Subject', 'DeveloperName'};
        List<EmailTemplate> emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(CON_CRM.ET_OPPORTUNITY_IS_FREEZE, emailFieldSet);
        for(Opportunity opp : oppList) {
            UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
            message.targetObjectId = UserInfo.getUserId();
            message.templateId = emailTemplate[0].Id;
            message.whatId = opp.Id;
            message.toUserIds = new List<Id>{opp.OwnerId};
            messageList.add(message);
        }        
        if(messageList.size() > 0) {
            UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);    
        }
    }
    
    public static void updateRWSTriageLastModified(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        if(Trigger.isUpdate) {
            for(Opportunity opp : newList){
                if (opp.Add_to_RWS_Triage_Tracking__c != oldMap.get(opp.id).Add_to_RWS_Triage_Tracking__c ||
                    opp.Real_World_Triage_Categories__c != oldMap.get(opp.id).Real_World_Triage_Categories__c ||
                    opp.What_is_the_Client_Problem__c != oldMap.get(opp.id).What_is_the_Client_Problem__c ||
                    opp.Business_Use_Case__c != oldMap.get(opp.id).Business_Use_Case__c ||
                    opp.Priority_Explanation__c != oldMap.get(opp.id).Priority_Explanation__c ||
                    opp.Pipeline_Insight__c != oldMap.get(opp.id).Pipeline_Insight__c ||
                    opp.Budget_Insight__c != oldMap.get(opp.id).Budget_Insight__c ||
                    opp.Client_Contact_Insight__c != oldMap.get(opp.id).Client_Contact_Insight__c ||
                    opp.Is_there_a_regulatory_purpose__c != oldMap.get(opp.id).Is_there_a_regulatory_purpose__c ||
                    opp.Triage_Priority__c != oldMap.get(opp.id).Triage_Priority__c ||
                    opp.Submitted_to_PACE__c != oldMap.get(opp.id).Submitted_to_PACE__c) {
                        opp.RWS_Triage_Last_Modified__c = System.now();
                }
            }
        }else if(Trigger.isInsert){
            for(Opportunity opp : newList){
                if (opp.Add_to_RWS_Triage_Tracking__c != false || opp.Real_World_Triage_Categories__c != null || opp.What_is_the_Client_Problem__c != null || 
                    opp.Business_Use_Case__c != null || opp.Priority_Explanation__c != null || opp.Pipeline_Insight__c != null ||
                    opp.Budget_Insight__c != null || opp.Client_Contact_Insight__c != null || opp.Is_there_a_regulatory_purpose__c != null ||
                    opp.Triage_Priority__c != null || opp.Submitted_to_PACE__c != null) {
                        opp.RWS_Triage_Last_Modified__c = System.now();
                }
            }
        }
    }
    
    //ESPSFDCQI-8422 : Additional Mandatory fields for OUTCOME LOB && ESPSFDCQI-16670 RWLP new validations && ESPSFDCQI-17608
    public static void validateOppForRWS(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> oppIdsForRWLP = new Set<Id>();
        Set<String> oppFromSecondStageSet = new Set<String>{CON_CRM.DEVELOPING_PROP_STAGE,CON_CRM.DELIVERING_PROP_STAGE,
            CON_CRM.FINALIZING_DEAL_STAGE, CON_CRM.RECEIVED_ATP_STAGE, CON_CRM.CLOSED_WON_STAGE};
        Set<String> oppFromThirdStageSet = new Set<String>{CON_CRM.DELIVERING_PROP_STAGE,
                    CON_CRM.FINALIZING_DEAL_STAGE, CON_CRM.RECEIVED_ATP_STAGE, CON_CRM.CLOSED_WON_STAGE};
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            for(Opportunity opp : newList){
                if(opp.StageName != oldMap.get(opp.Id).StageName && oppFromSecondStageSet.contains(opp.StageName) && (opp.Line_of_Business__c == 'Tech & Data' || (opp.Line_of_Business__c == 'Outcome' && opp.Hybrid_Study__c == false)) &&
                   (opp.Research_Study_Classification__c == null || opp.Indication_List__c == null || Opp.Drug_Product_Name__c == null || opp.FPI_Date__c == null)){
                       oppIds.add(opp.Id);
                   } else if(opp.StageName != oldMap.get(opp.Id).StageName && oppFromThirdStageSet.contains(opp.StageName) && opp.Line_of_Business__c == 'RWLP' &&
                   (opp.Research_Study_Classification__c == null || opp.FPI_Date__c == null)){
                       oppIdsForRWLP.add(opp.Id);
                   }
            }
            if(oppIds.size() > 0 ){
                AggregateResult[] results = new SLT_OpportunityLineItems().getOLICountGroupByOpp(oppIds);
                for(AggregateResult ar : results){
                    decimal count = (decimal)ar.get('recordCount');
                    Id oppId = (Id)ar.get('OpportunityId');
                    if(count > 0){
                        String errorMessage = '';
                        Opportunity actualRecord = (Opportunity)Trigger.newMap.get(oppId);
                        if(actualRecord.Indication_List__c == null){
                            errorMessage = errorMessage + 'Indication, ';
                            //actualRecord.Indication_List__c.adderror('Complete this field.');
                        }
                        if(actualRecord.FPI_Date__c == null){
                            errorMessage = errorMessage + 'FPI Date, ';
                            //actualRecord.FPI_Date__c.adderror('Complete this field.');
                        }
                        if(actualRecord.Research_Study_Classification__c == null){
                            errorMessage = errorMessage + 'Research Study Classification, ';
                            //actualRecord.Research_Study_Classification__c.adderror('Complete this field.');
                        }
                        if(actualRecord.Drug_Product_Name__c == null){
                            errorMessage = errorMessage + 'Drug Classification/Product Name, ';
                            //actualRecord.Drug_Product_Name__c.adderror('Complete this field.');
                        }
                        errorMessage = errorMessage.substring(0,errorMessage.length()-2);
                        errorMessage = errorMessage + ' are mandatory for OUTCOME or TECH & DATA Line of Business and the selected products.';
                        actualRecord.adderror(errorMessage);
                    }
                }
            } else if(oppIdsForRWLP.size() > 0 ){
                AggregateResult[] results = new SLT_OpportunityLineItems().getOLICountGroupByOpp(oppIdsForRWLP);
                for(AggregateResult ar : results){
                    decimal count = (decimal)ar.get('recordCount');
                    Id oppId = (Id)ar.get('OpportunityId');
                    if(count > 0){
                        String errorMessage = '';
                        Opportunity actualRecord = (Opportunity)Trigger.newMap.get(oppId);
                        if(actualRecord.FPI_Date__c == null){
                            errorMessage = errorMessage + 'FPI Date, ';
                        }
                        if(actualRecord.Research_Study_Classification__c == null){
                            errorMessage = errorMessage + 'Research Study Classification, ';
                        }
                        errorMessage = errorMessage.substring(0,errorMessage.length()-2);
                        errorMessage = errorMessage + ' are mandatory for RWLP Line of Business and the selected products.';
                        actualRecord.adderror(errorMessage);
                    }
                }
            }
        }
    }
    
    public static void updateSalesProgram(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        UTL_SalesProgram.updateSalesProgram(newList, oldMap);
    }

    /*
     * This method is used to notify the PIC user When it removed from PIC.
     * @params List<Opportunity> newList
     * @params Map<Id, Opportunity> oldMap
     * @return  void
     */ 
    public static void sendEmailToRemovePICUser(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();     
        Map<Opportunity,Id> opportunityWithPICIdMap = new map<Opportunity,Id>();
        for(Opportunity opp : newList){
            if(opp.Principle_inCharge__c != oldMap.get(opp.Id).Principle_inCharge__c && oldMap.get(opp.Id).Principle_inCharge__c != Null){
                opportunityWithPICIdMap.put(opp,  oldMap.get(opp.Id).Principle_inCharge__c);
            }
        }
        
        if(opportunityWithPICIdMap.size() > 0){
            Map<Id,Contact> picContact = new SLT_Contact().selectByContactId(new Set<Id>(opportunityWithPICIdMap.values()), new Set<String>{'Email'});
            EmailTemplate emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName('OPP_ET14_CRM_PIC_is_Change', new Set<String> {'Id','DeveloperName'})[0];
            for(Opportunity opp : opportunityWithPICIdMap.keySet()){
                if(picContact.get(opportunityWithPICIdMap.get(opp)).Email != Null){
                    UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                    message.targetObjectId = UserInfo.getUserId();
                    message.templateId = emailTemplate.Id;
                    message.whatId = opp.Id;
                    message.toEmails = new List<String>{picContact.get(opportunityWithPICIdMap.get(opp)).Email};
                    messageList.add(message);
                }
            }
        }
         
         if(messageList.size() > 0) {
            UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);    
        }
    }
    
    public static void logSaveTime(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        if(newList.size() == 1){
            Opportunity opp = newList.get(0);
            UTL_TimeTracker.logSaveTime(opp.Id.getSObjectType().getDescribe().getName(), opp.Id);
        }
    }
    
    public class CreditControlWrapper {
        public String businessUnit = '';
        public Decimal businessAmount = 0;
        public Decimal businessThreshold = 0;
        public String businessheirarchyLevel = '';
        public Boolean isThresholdExceed = false;
        public Decimal heirarchyLevelThreshold = 0;
        public String heirarchyLevel = '';
    }
    
    public static void updateLast_Modified_By_USER(List<Opportunity> newList){
        
        boolean isSystemUser = false;
        String userId = UserInfo.getUserId();
        string userIds;
        User_Permissions__c userPermission = User_Permissions__c.getOrgDefaults();
        if(userPermission != null)
        	userIds = userPermission.System_Users_Id__c;        
        
        List<String> userIdsList = new List<String>();
        
        if(userIds != null)
        	userIdsList = userIds.split(',');
        
        if(userIdsList.size() > 0 && userIdsList.contains(userId)){
            isSystemUser = true;
        }        
        if(!isSystemUser){
            for(Opportunity opp : newList){
                opp.Last_Modified_By_USER__c = userId;
                opp.Last_Modified_Date_USER__c = system.now();
            }
        }        
    }
    
    /**
     * This method is used to populated Global project unity based on criteria if Value is Null .
     * @params List<Opportunity> newList
     * @return  void
     */ 
    public static void updateGPU(List<Opportunity> newList, Map<Id, Opportunity> oldMap){ 
        
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> indicationIdSet = new Set<Id>();
        
        for(Opportunity opp : newList){
            accIdSet.add(opp.AccountId);
            if(opp.Indication_List__c != Null){
                indicationIdSet.add(opp.Indication_List__c);
            }
        }
        
            SLT_Account sltAccount = new SLT_Account();
            final String parentAccName_LocalCompaniesInChina = 'LOCAL COMPANIES IN CHINA';
        	final String parentAccName_Biogen = 'Biogen';
            final String parentAccName_MerckKGAA = 'MERCK KGAA';
            final String parentAccName_Johnson = 'JOHNSON & JOHNSON';
            final String parentAccName_GileadSciences = 'Gilead Sciences';
            final String parentAccName_Roche = 'Roche';
            final String parentAccName_BoehringerIngelheim = 'Boehringer Ingelheim';
            final String parentAccName_GlaxoSmithKline = 'GlaxoSmithKline';
            final String parentAccName_DaiichiSankyoGroup = 'Daiichi Sankyo Group';
            final String parentAccName_BioNTech = 'BioNTech';
            final String parentAccName_NovoNordisk = 'Novo Nordisk';
            
        	final Set<String> accCountrySet1 = new Set<String>{'CN', 'SG', 'KR', 'JP', 'IN', 'TW','AU', 'NZ'};
            final Set<String> accCountrySet2 = new Set<String>{'AU', 'NZ'};
        	final Set<String> identifiedBusinessSet = new Set<String>{'Cenduit', 'Clintec', 'GCE Solutions',	'Genae'};
        	final Set<String> indicationSetForCardiovascular = new Set<String>{'Com molybdoflavoprotein enzyme', 'Wolman\'s disease', 'Delay in puberty'};
        	final Set<String> indicationSetForCentralNervous = new Set<String>{'Alzheimer\'s disease', 'Amyotrophic lateral sclerosis', 'Autistic disorder', 'Bipolar disorder', 'Bipolar I disorder', 'Cerebral hemorrhage', 'Com molybdoflavoprotein enzyme', 'Dementia', 'Depressive disorder', 'Drug abuse', 'Insomnia', 'Low blood pressure', 'Major depressive disorder', 'Migraine', 'Multiple sclerosis', 'Narcolepsy','Neuropathic pain','Neuropathy', 'Pain', 'Parkinson\'s disease', 'Post poliomyelitis syndrome', 'Respiratory tract congestion', 'Schizophrenia', 'Seizure disorder', 'Sleep apnea', 'Sleep disorder' };
        	final Set<String> indicationSetForGastroenterology = new Set<String>{'Bowel dysfunction', 'Crohn\'s disease', 'Disease of liver', 'Erosive esophagitis', 'Gastroenteritis', 'Inflammatory bowel disease', 'Nonalcoholic steatohepatitis', 'Short bowel syndrome', 'Ulcerative colitis'};
        	final Set<String> indicationSetForWomenHealth = new Set<String>{'Ankylosing spondylitis', 'Arthritis', 'Atopic dermatitis', 'Autoimmune vasculitis', 'Dermatophytosis', 'Lupus erythematosus', 'Lupus nephritis', 'Menopausal syndrome', 'Nocturia', 'Osteoarthritis', 'Osteopenia','Psoriasis', 'Psoriatic arthritis', 'Rheumatoid arthritis'};
        	final Set<String> indicationSetForInternalMedicine = new Set<String>{'Blood disease', 'Fabry\'s disease', 'Hemolytic Anemia', 'Hemolytic uremic syndrome', 'Hemophilia', 'Paroxysmal nocturnal hemogluria', 'Sickle cell disease', 'Thrombocytopenic disorder'};
        	final Set<String> indicationSet = new Set<String>{'Blood disease', 'Hemolytic Anemia', 'Hemophilia', 'Paroxysmal nocturnal hemogluria', 'Sickle cell disease', 'Thrombocytopenic disorder', 'Hemolytic uremic syndrome'};
            final Set<String> therapyAreaForGIIWH = new Set<String>{'Dermatology', 'Gastrointestinal', 'Gynecology/Women\'s Health', 'Hepatology', 'Immunology', 'Rheumatology', 'Women\'s Health / Sexual Health'};
            final Set<String> therapyAreaForInternalMedicine  = new Set<String>{'Allergy', 'Infectious Disease', 'Medical Genetics', 'Ophthalmology', 'Orthopedics', 'Respiratory'};
            final Set<String> fieldSet = new Set<String>{'Id', 'Name', 'ParentId', 'AccountCountry__c', 'Category__c', 'RecordTypeId'};
            Boolean isIdentifiedBusiness;
            Map<Id, Id> accWithParentAccId = new Map<Id, Id>();
            Map<Id, Indication_List__c> indicationListMap = new Map<Id, Indication_List__c>();
            Map<Id, Account> accMap = new Map<Id, Account>();
            Map<Id, Account> parentAccMap = new Map<Id, Account>();
            
            if(indicationIdSet.size() > 0){
                indicationListMap = new SLT_IndicationList().selectById(indicationIdSet);
            }
            if(accIdSet.size() > 0){
                accMap = sltAccount.selectByAccountId(accIdSet,fieldSet);
            }
            
            for(Account acc : accMap.values()){
                if(acc.ParentId != Null){
                    accWithParentAccId.put(acc.Id,acc.ParentId);
                }
            }
            
            if(accWithParentAccId.size() > 0){
                parentAccMap = sltAccount.selectByAccountId(new Set<Id>(accWithParentAccId.values()),fieldSet);
            }
            
            
            for(Opportunity opp : newList){
                if(opp.Identified_Business__c == Null){
                    isIdentifiedBusiness = false;
                }else{
                    isIdentifiedBusiness = isStringContain(identifiedBusinessSet, opp.Identified_Business__c);
                }
                if(trigger.isInsert || (trigger.isUpdate && (opp.AccountId != oldMap.get(opp.Id).AccountId ||
				                                             opp.Line_of_Business__c != oldMap.get(opp.Id).Line_of_Business__c || 
                                                             opp.Identified_Business__c != oldMap.get(opp.Id).Identified_Business__c || 
                                                             opp.Is_this_IQVIA_Biotech__c != oldMap.get(opp.Id).Is_this_IQVIA_Biotech__c ||
                                                             opp.FSP__c != oldMap.get(opp.Id).FSP__c ||
                                                             opp.Indication_List__c != oldMap.get(opp.Id).Indication_List__c ||
                                                             opp.CurrencyIsoCode != oldMap.get(opp.Id).CurrencyIsoCode))){
                if(opp.Line_of_Business__c == CON_CRM.LOB_Core_Clinical){
                    if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_Biogen){
                        opp.Global_project_unit__c = CON_CRM.GPU_Biogen;
                    } 
                    else if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_Johnson){
                        opp.Global_project_unit__c = CON_CRM.GPU_Johnson;
                    }  
                    else if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_GileadSciences){
                        opp.Global_project_unit__c = CON_CRM.GPU_Gilead;
                    }  
                    else if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_Roche){
                        opp.Global_project_unit__c = CON_CRM.GPU_Roche;
                    }  
                    else if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_BoehringerIngelheim){
                        opp.Global_project_unit__c = CON_CRM.GPU_BoehringerIngelheim;
                    }  
                    else if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_GlaxoSmithKline){
                        opp.Global_project_unit__c = CON_CRM.GPU_GlaxoSmithKline;
                    }  
                    else if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_DaiichiSankyoGroup){
                        opp.Global_project_unit__c = CON_CRM.GPU_DaiichiSankyo;
                    }  
                    else if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_BioNTech){
                        opp.Global_project_unit__c = CON_CRM.GPU_BioNTech;
                    }  
                    else if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_NovoNordisk){
                        opp.Global_project_unit__c = CON_CRM.GPU_NovoNordisk;
                    } 
                    else if(opp.Is_this_IQVIA_Biotech__c == CON_CRM.No_String){
                        if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_MerckKGAA && parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.RecordTypeId == CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID){
                            opp.Global_project_unit__c = CON_CRM.GPU_MerckKGaA;
                        }else if(!isIdentifiedBusiness && parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name != parentAccName_Biogen && opp.CurrencyIsoCode != CON_CRM.opp_CurencyCode_JPY){
                            if((opp.TherapyArea__c == CON_CRM.Therapy_Area_Oncology || opp.TherapyArea__c == CON_CRM.Therapy_Area_Hematology) && !indicationSet.contains(indicationListMap.get(opp.Indication_List__c)?.Name)){
                                opp.Global_project_unit__c = CON_CRM.GPU_Oncology;
                            }else if(accMap.get(opp.AccountId).Category__c != CON_CRM.ACCOUNT_CATEGORY_LARGE_EBP && accMap.get(opp.AccountId).Category__c != CON_CRM.ACCOUNT_CATEGORY_SMALL_EBP && accMap.get(opp.AccountId).Category__c != 'EBP EMERGING BIOPHARMA' && opp.FSP__c != CON_CRM.YES_STRING){   
                                if((opp.TherapyArea__c == CON_CRM.Therapy_Area_Endocrinology || opp.TherapyArea__c == CON_CRM.Therapy_Area_Cardiovascular || opp.TherapyArea__c == CON_CRM.Therapy_Area_Nephrology) && 
                                    indicationListMap.get(opp.Indication_List__c)?.Name != 'Lupus nephritis'){
                                       opp.Global_project_unit__c = CON_CRM.GPU_Cardiovascular_Renal_Metabolic;
                                   }else if(indicationListMap.get(opp.Indication_List__c)?.Name == 'Sleep apnea' || (opp.TherapyArea__c == CON_CRM.Therapy_Area_Neurology || opp.TherapyArea__c == CON_CRM.Therapy_Area_Psychiatry && 
                                       indicationListMap.get(opp.Indication_List__c)?.Name != 'Fabry\'s disease')){
                                       opp.Global_project_unit__c = CON_CRM.GPU_CentralNervousSystem;
                                   }else if(therapyAreaForGIIWH.contains(opp.TherapyArea__c) || indicationListMap.get(opp.Indication_List__c)?.Name == 'Lupus nephritis' || indicationListMap.get(opp.Indication_List__c)?.Name == 'Urinary tract infection'){
                                       opp.Global_project_unit__c = CON_CRM.GPU_GI_IWH;
                                   }else if(therapyAreaForInternalMedicine.contains(opp.TherapyArea__c) || indicationSetForInternalMedicine.contains(indicationListMap.get(opp.Indication_List__c)?.Name)){
                                       opp.Global_project_unit__c = CON_CRM.GPU_InternalMedicine;
                                   }
                            } 
                        }
                    } 
                }else if(opp.Line_of_Business__c == CON_CRM.LOB_EarlyClinicalDevelopment && opp.Is_this_IQVIA_Biotech__c == CON_CRM.No_String
                         && !isIdentifiedBusiness && opp.CurrencyIsoCode != CON_CRM.opp_CurencyCode_JPY && accMap.get(opp.AccountId).Category__c != CON_CRM.ACCOUNT_CATEGORY_LARGE_EBP && accMap.get(opp.AccountId).Category__c != CON_CRM.ACCOUNT_CATEGORY_SMALL_EBP && 
                         accMap.get(opp.AccountId).Category__c != 'EBP EMERGING BIOPHARMA' && opp.FSP__c != CON_CRM.YES_STRING){
                             opp.Global_project_unit__c = CON_CRM.GPU_EarlyClinicalDevelopment;
                }else if(opp.Line_of_Business__c == CON_CRM.LOB_RegulatoryDrugDevelopment){
                		opp.Global_project_unit__c = CON_CRM.GPU_RADDS;
                }else if(opp.Line_of_Business__c == CON_CRM.LOB_Clinical_Technology){
                    	opp.Global_project_unit__c = CON_CRM.GPU_Clinical_Technology;
                }else if(opp.Line_of_Business__c == CON_CRM.LOB_Data_Science){
                    if(parentAccMap.get(accWithParentAccId.get(opp.AccountId))?.Name == parentAccName_Johnson){
                        opp.Global_project_unit__c = CON_CRM.GPU_Johnson;
                    }
                }
            }
        }
    }
    
    /**
     * This method is used to check string is match with list or not. .
     * @params availableStringSet
     * @params strCheck
     * @return  Boolean
     */
    private static Boolean isStringContain(Set<String> availableStringSet, String strCheck){
        for(String availableString : availableStringSet){
            if(strCheck.contains(availableString)){
                return true;
            }
        }
        return false;
    }
	
	/**********************************************************************************************
    * @Author:      Razia Khan
    * @Date:        11/03/2022
    * @Description: IQVIACBEX-1804:This method is responsible for sending the new and old field values for further
    *               implementation of sync logic between Salesforce and Unity using mulesoft as 
    *               middleware.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    public static void setUnityFlagSyncMechanism(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        CNT_RFP_IntakeUnityFlagSync.processSyncLogic(CON_CBEx.OPPORTUNITY_OBJECT, newMap, oldMap);
    }
   
    /**
     * This method is restore opportunity owner when running account territory rule
     * @params List<Opportunity> newList
     * @params Map<id, Opportunity> OldMap
     * @return  void
     */
    public static void RestoreOpportunityOwnerChange_On_AccountTerritoryUpdate (List<Opportunity> newList, Map<id, Opportunity> OldMap) {
        String userId;
        Organization_Default__c securityConfig = Organization_Default__c.getOrgDefaults();
        if(securityConfig.Enable_Territory_Rule_Run__c){
            userId = securityConfig.UserID__c != null ? securityConfig.UserID__c : '';
            for (Opportunity opp : newList) {
                if((opp.ownerID != OldMap.get(opp.Id).ownerID) && opp.LastModifiedById == userId){
                    opp.ownerID = OldMap.get(opp.Id).ownerID;
                }
            }
        }
    }
    
    /**
     * This method is used for updation Pricing Tool Recommended field of opportunity
     * @params List<Opportunity> newList
     * @params Map<id, Opportunity> OldMap
     * @return  void
     */
    
    public static void updatePricingToolRecommended(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Map<Id, String> pricingToolMap = new Map<Id, String>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Opportunity opportunityRecord : newList) { 
            if((opportunityRecord.Main_Delivery_Country__c!= oldMap.get(opportunityRecord.Id).Main_Delivery_Country__c || 
                opportunityRecord.Business_Unit__c!= oldMap.get(opportunityRecord.Id).Business_Unit__c || 
                opportunityRecord.PA_Required__c!= oldMap.get(opportunityRecord.Id).PA_Required__c || 
                opportunityRecord.Amount!= oldMap.get(opportunityRecord.Id).Amount) || 
                (DAOH_OpportunityLineItem.isZeroAmountProduct)){
                if(DAOH_OpportunityLineItem.isZeroAmountProduct) {
                    DAOH_OpportunityLineItem.isZeroAmountProduct = false;
                }
                oppList.add(opportunityRecord);
            }
        }
        if(oppList.size() > 0){
            pricingToolMap = getPricingTools(oppList);
            for(Opportunity oppNeedsToUpdate : oppList){
                if(pricingToolMap.containsKey(oppNeedsToUpdate.Id) && 
                    oppNeedsToUpdate.Pricing_Tool_Recommended__c != pricingToolMap.get(oppNeedsToUpdate.Id)){
                    oppNeedsToUpdate.Pricing_Tool_Recommended__c = pricingToolMap.get(oppNeedsToUpdate.Id);
                }
        	}            
        }        
    }
    
    public static Map<Id,String> getPricingTools(List<Opportunity> oppList){
        
        Map<Id,Boolean> hasProductFromExclusionListMap = new Map<Id,Boolean>();
        Map<Id,String> pricingToolMap = new  Map<Id,String>();
        Boolean hasProductFromExclusionList = false;
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp : oppList){
            oppIdSet.add(opp.Id);
        }
        Set<String> oppFieldSet = new Set<String> {'Id', 'Name', 'Business_Unit__c', 'Main_Delivery_Country__c','PA_Required__c','Pricing_Tool_Recommended__c'};
        Set<String>  oliFieldSet = new Set<String> {'Id', 'Product_Name__c', 'ProductCode' , 'Unit_Name__c', 'COE_Name__c', 'Offering_Group__c','Offering_Type__c','Hierarchy_Level__c', 'product2.Regional_Product__c', 'Product2.Regional_Product_Code__c','OpportunityId'};
        Map<Id, Opportunity> oppIdToOppWithLineItemMap =new SLT_Opportunity().selectByIdWithOpportuntiyLineItem(oppIdSet, oppFieldSet, oliFieldSet);
        if(oppIdToOppWithLineItemMap.size() > 0){
            for(Opportunity opp : oppList){
                for(OpportunityLineItem oli : oppIdToOppWithLineItemMap.get(opp.Id).OpportunityLineItems) {
                    if (!hasProductFromExclusionListMap.containsKey(oli.OpportunityId) && (oli.Offering_Type__c == 'Commercial Engagement Services' || oli.COE_Name__c == 'Global Marketing Services' || oli.COE_Name__c == 'Core Information Offerings' || oli.COE_Name__c == 'Global Market Insights' ||
                        oli.COE_Name__c == 'Gbl Payer Provider & Real World Networks' || oli.Offering_Group__c == 'Research & Development Solutions' || (oli.Product2.Regional_Product__c == 'MOLECULES' && oli.Product2.Regional_Product_Code__c == 'L81833')) && oli.Hierarchy_Level__c == 'Material') {
                        hasProductFromExclusionListMap.put(oli.OpportunityId, true);
                        break;
                    }
                }
                if(oppIdToOppWithLineItemMap.get(opp.Id).opportunityLineItems.size() == 0){
                    pricingToolMap.put(opp.Id,'');
                }
                else if (opp.Business_Unit__c == 'Latin America' || opp.Main_Delivery_Country__c == 'Latin America Regional') {
                    if(opp.PA_Required__c) {                    
                        pricingToolMap.put(opp.Id,'Pricing Assistant');
                    } else {
                        if (!hasProductFromExclusionListMap.containsKey(opp.Id)) {                  
                            pricingToolMap.put(opp.Id, 'Pricing Template');
                        } else {
                            pricingToolMap.put(opp.Id,'');
                        }
                    }
                }            
                else{
                    pricingToolMap.put(opp.Id,'');
                }
            }
        }
        return pricingToolMap;        
    }
	
    public static void setRareDiseaseFieldValue(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<String> setOfLOB = new Set<String>{'Clinical', 'Clinical Technology', 'Connected Devices', 'Data Sciences', 'Early Clinical Development', 'Patient & DCT Solutions', 'Q2 Solutions', 'Regulatory & Drug Development Solutions', 'Safety & Med Info'};
        Set<String> setOfStage =  new Set<String>{CON_CRM.IDENTIFYING_OPP_STAGE, CON_CRM.QUALIFYING_OPP_STAGE, CON_CRM.DEVELOPING_PROP_STAGE, CON_CRM.DELIVERING_PROP_STAGE, CON_CRM.FINALIZING_DEAL_STAGE, CON_CRM.RECEIVED_ATP_STAGE};
        Set<Id> setOfIndicationList = new Set<Id>();
        List<Opportunity> listOfFilterdOpp = new List<Opportunity>();
        
        for(Opportunity opp: newList){
            if((Trigger.isInsert || (Trigger.isUpdate && (opp.Indication_List__c != oldMap.get(opp.id).Indication_List__c))) && setOfStage.contains(opp.StageName) && setOfLOB.contains(opp.Line_of_Business__c) && opp.Indication_List__c != null){
                setOfIndicationList.add(opp.Indication_List__c);
                listOfFilterdOpp.add(opp);
            }
        }
        
        if(setOfIndicationList.size() > 0){
            Map<Id,Indication_List__c> indicationMap = new SLT_IndicationList().selectById(setOfIndicationList);
            for(Opportunity opp:listOfFilterdOpp){
                if(indicationMap.containsKey(Opp.Indication_List__c)){
                    opp.Rare_Disease__c = indicationMap.get(Opp.Indication_List__c).Rare_Disease__c;
                }
            }
        }
    }
    
    public static void awardedBidMandatory(List<Opportunity> newList , Map<id,Opportunity> oldMap){
        
        Set<Id> oppStageChangeSet = new Set<Id>();
        Boolean clinicalAwarderBidCheck = false;
        Map<Id,List<Bid_History__c>> bidHistoryOnOpportunityMap = new Map<Id,List<Bid_History__c>>();
        List<Bid_History__c> bidHistoryWithClinicalRecordTypeList = new List<Bid_History__c>();
		
        Set<String> oppOldStageSet = new Set<String>{CON_CRM.DEVELOPING_PROP_STAGE, CON_CRM.DELIVERING_PROP_STAGE};
        Set<String> oppNewStageSet = new Set<String>{CON_CRM.FINALIZING_DEAL_STAGE, CON_CRM.RECEIVED_ATP_STAGE};   
        for(Opportunity opp : newList){
            if(opp.StageName != oldMap.get(opp.id).StageName && oppOldStageSet.contains(oldMap.get(opp.id).StageName) && oppNewStageSet.contains(opp.StageName)){
                oppStageChangeSet.add(opp.Id);
            }
        }
        
        if(oppStageChangeSet.size() > 0 && !oppStageChangeSet.isEmpty()){
            bidHistoryWithClinicalRecordTypeList = new SLT_Bid_History(false,false).getAwardedClinicalBidOnOpportunity(oppStageChangeSet,new Set<String>{'Id','RecordTypeId','Name','Is_Study_Awarded__c','Bid_History_Related_Opportunity__c','Bid_Stopped__c'});
        }
        
        if(bidHistoryWithClinicalRecordTypeList.size() > 0){
            for(Bid_History__c bid : bidHistoryWithClinicalRecordTypeList){
                if(bidHistoryOnOpportunityMap.containsKey(bid.Bid_History_Related_Opportunity__c)){
                    bidHistoryOnOpportunityMap.get(bid.Bid_History_Related_Opportunity__c).add(bid);
                }
                else{
                    bidHistoryOnOpportunityMap.put(bid.Bid_History_Related_Opportunity__c,new List<Bid_History__c>{bid});
                }
            }
            
            if(bidHistoryOnOpportunityMap.size() > 0){
                for(Id opp : oppStageChangeSet){
                    clinicalAwarderBidCheck = false;
                    for(Bid_History__c bid : bidHistoryOnOpportunityMap.get(opp)){
                        if(bid.Bid_Stopped__c != 'Yes'){
                            if(bid.Is_Study_Awarded__c == 'Yes'){
                                clinicalAwarderBidCheck = false;
                                break;
                            }
                            else{
                                clinicalAwarderBidCheck = true;
                            }
                        }
                    }
                    if(clinicalAwarderBidCheck == True ){
                        trigger.newMap.get(opp).addError(System.Label.CRM_SELECT_AWARD_BID_ERROR);
                    }
                }
            }
        }
    }
    
    public static void setLostDateToday(List<Opportunity>newList , Map<id,Opportunity> oldMap){
        for(Opportunity opp : newList){
            if(((Trigger.isInsert && opp.StageName == CON_CRM.CLOSED_LOST_STAGE) || (opp.StageName == CON_CRM.CLOSED_LOST_STAGE && oldMap.get(opp.id).StageName != CON_CRM.CLOSED_LOST_STAGE)) && opp.Lost_Date__c == null){
                opp.Lost_Date__c = system.today();
            }
        }
    }
	
	/**
	* This method is used for updation of Box Folder URL field of opportunity when LOB is changed and LOB = Q2 solutions, Under ESPSFDCQI-15808
	* @params Map<ID,Opportunity> newOppMap
	* @params Map<id, Opportunity> OldMap
	* @return  void
	*/
    public static void setBoxFolderURLonOpp(Map<ID,Opportunity> newOppMap, Map<Id, Opportunity> oldMap){        
        Set<Id> filteredOppIdSet = new Set<Id>();
        for(Opportunity opp : newOppMap.values()){
            if((opp.Line_of_Business__c != oldMap.get(opp.id).Line_of_Business__c) && opp.Line_of_Business__c == CON_CRM.LOB_Q2_Solutions && opp.Box_Folder_Url__c == null){
                filteredOppIdSet.add(opp.Id);
            }
        }
        String condition = 'box__Record_ID__c IN: boxRecordIds AND box__Object_Name__c = \'Opportunity\' AND box__CollaborationID__c = null AND box__Folder_ID__c != Null';
        Set<String> frupFieldSet = new Set<String>{'ID','box__Object_Name__c','box__CollaborationID__c','box__Folder_ID__c','box__Record_ID__c'};
        if(filteredOppIdSet.size() > 0){
            List<box__FRUP__c> frupRecordsList = new SLT_FRUP(false,false).getFRUPRecordsByBoxRecordId(filteredOppIdSet,frupFieldSet,condition);
            String folderURL = Box_End_Point__c.getOrgDefaults().End_Point__c;
            folderURL += '/folder/';
            if(frupRecordsList.size() > 0){
                for(box__FRUP__c frupOpp : frupRecordsList){
                    String boxFolderURL = folderURL + frupOpp.box__Folder_ID__c;
                    if(filteredOppIdSet.contains(frupOpp.box__Record_ID__c)){
                        Opportunity opp = newOppMap.get(frupOpp.box__Record_ID__c);
                        opp.Box_Folder_Url__c = boxFolderURL;
                    }
                } 
            }
        }
    }
    
    /**
     * Method to calculate Opportunity sharing(OpportunityShare record)
     * @params Map<ID,Opportunity> newOppMap
     * @params Map<id, Opportunity> OldMap
     */
    public static void setSharing(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        UTL_Sharing.setSharing(newList, oldMap, 'Opportunity');
    }
    
    /**
     * method to set Last_Sharing_Calculation_Timestamp__c if sharing set calculated
     * @param List<Opportunity> newList
     * @param Map<Id, Opportunity> oldMap
     */
    public static void setLastSharingCalculationTimestamp(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Boolean isFieldToUpdate = true;
        Set<Id> recordIdSet = new Set<Id>();
        if(Trigger.isUpdate) {
            recordIdSet = UTL_Sharing.checkFieldSetValueChange(newList, oldMap, 'Opportunity', 'SHR_Parent_FieldSet');
            if(recordIdSet.size() == 0) {
                isFieldToUpdate = false;
            }
        }
        if(isFieldToUpdate) {
            for(Opportunity opp :newList) {
                if (Trigger.isInsert || recordIdSet.contains(opp.Id)) {
                    opp.Last_Sharing_Calculation_Timestamp__c = System.Now();    
                }
            }   
        }
    }
    
    /**
     * method to set Last_Manual_Sharing_Execution__c date if Run_Sharing__c gets true
     * @param List<Opportunity> newList
     * @param Map<Id, Opportunity> oldMap
     */
    public static void setLastManualSharingFieldUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for (Opportunity opp : newList) {
            if(opp.Run_Sharing__c) {
                opp.Run_Sharing__c = false;
                opp.Last_Manual_Sharing_Execution__c = System.now();
            }
        }
    }
    
    /**
     * method to put Validations for Related Site Submission on Opportunity
     * @param List<Opportunity> newList
     * @param Map<Id, Opportunity> oldMap
     */
    public static void avacareOppValidations(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Map<Id,Opportunity> oppAvacareStageChangeMap = new Map<Id, Opportunity>();
        Map<Id,String> oppToErrorMsgMap = new Map<Id,String>();
        Set<String> oppStage1To3 = new Set<String>{CON_CRM.IDENTIFYING_OPP_STAGE,CON_CRM.QUALIFYING_OPP_STAGE,CON_CRM.DEVELOPING_PROP_STAGE};
        Set<String> oppStage = new Set<String>{CON_CRM.DELIVERING_PROP_STAGE,CON_CRM.FINALIZING_DEAL_STAGE,CON_CRM.RECEIVED_ATP_STAGE,CON_CRM.CLOSED_WON_STAGE,CON_CRM.CLOSED_LOST_STAGE};
        Map<Opportunity, List<Site_Submission__c>> oppToSiteSubmissionMap = new Map<Opportunity, List<Site_Submission__c>>();
        for(Opportunity opp : newList){
            if(opp.StageName!= oldMap.get(opp.id).StageName && oppStage.contains(opp.StageName) && opp.Line_of_Business__c == CON_CRM.LOB_Avacare) {
                oppAvacareStageChangeMap.put(opp.id, opp);
            }
        }
        List<Site_Submission__c> siteSubmissionList = new List<Site_Submission__c>();
        Set<String> fieldsToQuery = new Set<String>{'id','Status__c','Opportunity__c','PSV_Scheduled_for__c','Site_Selection_Notification__c'};
        if(!oppAvacareStageChangeMap.isEmpty()){
            siteSubmissionList = new SLT_SiteSubmission().getSiteSubmissionByOppId(oppAvacareStageChangeMap.keySet(), fieldsToQuery);
        }

        if(!siteSubmissionList.isEmpty()){
            for(Site_Submission__c site : siteSubmissionList){
                Opportunity relatedOpp = oppAvacareStageChangeMap.containsKey(site.Opportunity__c) ?  oppAvacareStageChangeMap.get(site.Opportunity__c) : null;
                
                if(!oppToSiteSubmissionMap.containskey(relatedOpp)){
                    oppToSiteSubmissionMap.put(relatedOpp, new List<Site_Submission__c>());
                }
                oppToSiteSubmissionMap.get(relatedOpp).add(site);
            }
        }
            
            Set<String> siteSubmissionStatus = new Set<String>{'Lost - FQ not received/submitted','Lost','Study Declined','Selected - Study on hold','Selected - Study Terminated (Sponsor)',
                'Selected - Withdrawn (Avacare)','Selected - Withdrawn (Sponsor/CRO)','Awarded - Withdrawn (Avacare)',
                'Awarded - Withdrawn (Sponsor/CRO)','Awarded - Study Terminated (Sponsor)'};
                    
            for(id opp : oppAvacareStageChangeMap.keySet() ){
                
                
                if(oppToSiteSubmissionMap.containsKey(oppAvacareStageChangeMap.get(opp))){
                    List<Site_Submission__c> tempSiteSub = oppToSiteSubmissionMap.get(oppAvacareStageChangeMap.get(opp));
                    // For Opportunities Moving to Stage 7b. Closed Lost
                    if(oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.CLOSED_LOST_STAGE){
                        Boolean statusFlag = false; 
                        for(Site_Submission__c siteSub : tempSiteSub){
                            if(!siteSubmissionStatus.Contains(siteSub.Status__c)){
                                statusFlag = true;
                                break;
                            }
                        }
                        if(statusFlag){
                            oppToErrorMsgMap.put(opp, System.Label.CRM_CL0052_Avacare_Validation_Error_Stage_7b);
                        }
                    }
                    
                    //For Opportunity Moving to Stage 4. Delivering Proposal 
                    if(oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.DELIVERING_PROP_STAGE && oppStage1To3.contains(oldMap.get(opp).StageName)){
                        Boolean statusFlag = true;
                        for(Site_Submission__c siteSub : tempSiteSub){
                            if(siteSub.PSV_Scheduled_for__c != null){
                                statusFlag = False;
                                break;
                            }
                        }
                        if(statusFlag){
                            oppToErrorMsgMap.put(opp, System.Label.CRM_CL0053_Avacare_Validation_Error_Stage_4);
                        }
                    }
                    
                    // For Opportunity Moving to Stage 5. Finalizing Deal or 6. Received ATP/LOI
                    if((oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.FINALIZING_DEAL_STAGE || oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.RECEIVED_ATP_STAGE || oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.CLOSED_WON_STAGE ) && ( oppStage1To3.contains(oldMap.get(opp).StageName) || oldMap.get(opp).StageName == CON_CRM.DELIVERING_PROP_STAGE)){
                        Boolean statusFlag = true;
                        for(Site_Submission__c siteSub : tempSiteSub){
                            if(siteSub.Site_Selection_Notification__c != null){
                                statusFlag = False;
                                break;
                            }
                        }
                        if(statusFlag){
                            oppToErrorMsgMap.put(opp, System.Label.CRM_CL0054_Avacare_Validation_Error_Stage_5);
                        }
                    }
                }else{
                    if(oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.DELIVERING_PROP_STAGE && !(oppToSiteSubmissionMap.containsKey(oppAvacareStageChangeMap.get(opp))) && oppStage1To3.contains(oldMap.get(opp).StageName) ){
                        oppToErrorMsgMap.put(opp, System.Label.CRM_CL0053_Avacare_Validation_Error_Stage_4);
                    }
                    if(( oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.FINALIZING_DEAL_STAGE || oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.RECEIVED_ATP_STAGE || oppAvacareStageChangeMap.get(opp).StageName == CON_CRM.CLOSED_WON_STAGE ) && !(oppToSiteSubmissionMap.containsKey(oppAvacareStageChangeMap.get(opp))) && ( oppStage1To3.contains(oldMap.get(opp).StageName) || oldMap.get(opp).StageName == CON_CRM.DELIVERING_PROP_STAGE) ){
                        oppToErrorMsgMap.put(opp, System.Label.CRM_CL0054_Avacare_Validation_Error_Stage_5);
                    }   
                }
            }
        
        if(!oppToErrorMsgMap.isEmpty()){
            for(Id opp : oppAvacareStageChangeMap.KeySet()){
                if(oppToErrorMsgMap.containsKey(opp)){
                    oppAvacareStageChangeMap.get(opp).addError(oppToErrorMsgMap.get(opp));
                }
            }  
        }
    }
    
    /** 
     * method to add Default Drug Product for Avacare Opportunity
     * @param List<Opportunity> newList
     * @return void
     */
    public static void addDefaultDrugProductforAvacare(List<Opportunity> newList){
        Set<Id> avacareOpportunityIds = new Set<Id>();
        Boolean toCommit = false;
        fflib_SObjectUnitOfWork UOW = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] { Drug_Product_Name__c.SObjectType }
        );
        
        for(Opportunity opp: newList){
            if(opp.Line_of_Business__c == 'Avacare'){
                avacareOpportunityIds.add(opp.Id);
            }
        }
        if(avacareOpportunityIds.size() > 0){
            List<Drug_Product__c> dp = new SLT_DrugProduct().getAvacareDrugProduct();
            if(dp.size() > 0){
                for(Id OppId: avacareOpportunityIds){
                    UOW.registerNew( new Drug_Product_Name__c(Opportunity__c = OppId, Drug_Product__c = dp[0].Id));
                    toCommit = true;
                }
            }
        }
        
        if(toCommit){
            uow.commitWork();
        }
    }
    
    /** 
     * method to Dry Update Related Site Submission to update Risk Adjusted Opportunity Estimate
     * @param List<Opportunity> newList
     * @param Map<Id, Opportunity> oldMap
     */
    public static void getSiteSubUpdateByOpprtunity(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<id> oppIdSet = new Set<id>();
        for(Opportunity opp : newList){
            if(opp.Line_of_Business__c == CON_CRM.LOB_Avacare && ((opp.Indication_List__c != oldMap.get(opp.id).Indication_List__c) || (opp.Phase_P__c != oldMap.get(opp.id).Phase_P__c) || (opp.InterventionType__c != oldMap.get(opp.id).InterventionType__c))){
                oppIdSet.add(opp.id);
            }
        }
        
        if(!oppIdSet.isEmpty()){
            if(UTL_Validate.isFutureCallAllowed()){
                getSiteSubUpdateByOppFuture(oppIdSet);
            }
        }
    }
	
    /** 
     * Future method getSiteSubUpdateByOpprtunity
     * @param Set<Id> oppIdSet
     */
    
    @future
    public static void getSiteSubUpdateByOppFuture(Set<Id> oppIdSet){
        List<Site_submission__c> siteOppList = new List<Site_submission__c>();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { Site_submission__c.SobjectType } );
        Boolean toCommit = false;
        siteOppList = new SLT_SiteSubmission().getSiteSubmissionByOppId(oppIdSet , New Set<String>{'Name'});
        if(!siteOppList.isEmpty()){
            toCommit = true;
            uow.registerDirty(siteOppList);
        }
        if(toCommit){
            uow.commitWork();
        }
    }
    
    /** 
    * Method to Throw Validation on EMEA Opportunity on which Either IQVIA Quote is not Present or IQVIA Quote's QLI and OLI are not in Synced and Quote is not on Accepted Stage
    * @param List<Opportunity> newList
    * @param Map<Id, Opportunity> oldMap
    */
    public static void emeaIqviaQuoteError(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<String> Stage5to7Set = new Set<String>{CON_CRM.FINALIZING_DEAL_STAGE,CON_CRM.RECEIVED_ATP_STAGE,CON_CRM.CLOSED_WON_STAGE,CON_CRM.IN_HAND_STAGE};
        Set<Id> OppIds = new Set<Id>();
        Set<Opportunity> OppSet = new Set<Opportunity>();
        Map<id,String> oppIdToErrorMsgMap = new Map<Id,String>();
        Map<String, IQVIA_Account_Country_Region_Mapping__mdt> iqviaCountryMetadata = IQVIA_Account_Country_Region_Mapping__mdt.getAll();
        Map<String,String> emeaRegionCountryMapping = new Map<String,String>();
        for(String icmtd : iqviaCountryMetadata.keyset()){
            if(iqviaCountryMetadata.get(icmtd).Region__c == CON_CRM.EMEA){
                emeaRegionCountryMapping.put(iqviaCountryMetadata.get(icmtd).Country__c, iqviaCountryMetadata.get(icmtd).Country_Name__c);
            }
        }
        emeaRegionCountryMapping.put('GB','UK');
        For(Opportunity opp : newList){
            if((Trigger.isInsert || (Trigger.isUpdate && opp.StageName != oldMap.get(opp.id).StageName)) && Stage5to7Set.contains(opp.StageName) && emeaRegionCountryMapping.keySet().contains(opp.Account_Country__c) && emeaRegionCountryMapping.values().contains(opp.User_Country__c)){
                OppIds.add(opp.id);
                OppSet.add(opp);
            }
        }
        
        if(!OppIds.IsEmpty()){
            oppIdToErrorMsgMap = CPQ_QuoteUtilityWO.validateQuoteSyncWithOpportunities(OppIds);
        }
        //This Validation will Work after April 2025 Release (ESPSFDCQI-17520)
        if(!oppIdToErrorMsgMap.IsEmpty()){
            for(Opportunity opp : OppSet){
                if(oppIdToErrorMsgMap.containsKey(opp.id) && (oppIdToErrorMsgMap.get(opp.id) != 'Error:NonEMEAEligibleOpportunity' && oppIdToErrorMsgMap.get(opp.id) != 'Success' ) && UTL_GLOBAL.getCurrentReleaseVersion() >= CON_GLOBAL.RELEASE_APR_2025 && !(opp.Exclude_IQVIA_Quote_Sync__c) ){
                    opp.addError('Please make sure this opportunity has a Primary and Accepted IQVIA Quote record and ensure Quote Line Item and Opportunity Product are in sync before advancing the opportunity stage.');
                }
            }
        }
    }
    
    /** 
     * This method is used to throw validation if user tries to uncheck Exclude_IQVIA_Quote_Sync__c CheckBox.
     * Requirement ESPSFDCQI-17609
     * @params  newList List<Opportunity>
     * @params  Map<Id, Opportunity> oldMap
     * @return  void
     */
    public static void checkExcludeIQVIAQuoteSync(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        for(Opportunity opp : newList){
            if(oldMap.get(opp.id).Exclude_IQVIA_Quote_Sync__c != opp.Exclude_IQVIA_Quote_Sync__c && opp.Exclude_IQVIA_Quote_Sync__c == False && UTL_GLOBAL.getCurrentReleaseVersion() >= CON_GLOBAL.RELEASE_APR_2025){
                opp.addError('You cannot uncheck the Exclude IQVIA Quote Sync Field once it is checked');
            }
        }
    }
    
    /**
     * method to Check and uncheck the Is_US_BU_Opportunity__c Field to determine if the Opportunity is US BU
     * Requirement ESPSFDCQI-17647
     * @param List<Opportunity> newList
     * @param Map<Id, Opportunity> oldMap
     */
    public static void isUSBUOpportunity(List<Opportunity> newList, Map<Id, Opportunity> oldMap){ 
        For(Opportunity opp : newList){
            if( opp.Opportunity_Owner_Region__c != 'USA/Canada' || opp.USBU_Products__c == 0){
                opp.IQVIA_Opportunity_Type__c = 'None';
                opp.Is_USBU_Opportunity__c = false;
            }else if( opp.Opportunity_Owner_Region__c == 'USA/Canada' && opp.USBU_Products__c != 0){
                opp.IQVIA_Opportunity_Type__c = 'USBU';
                opp.Is_USBU_Opportunity__c = true;   
            }
        }
    }
    
    /**
     * Method to Add Default Opportunity Product on the Avacare Opportunity
     * Requirement ESPSFDCQI-17825
     * @param List<Opportunity> newList
     */
    public static void addDefaultOLIAvacare(List<Opportunity> newList){
        Map<id,String> avacareOppMap = new Map<id,String>();
        for(Opportunity opp : newList){
            if(opp.Line_of_Business__c == 'Avacare' && opp.RD_Product_Count__c == 0){
                avacareOppMap.put(opp.id,opp.CurrencyIsoCode);
            }
        }
        if(avacareOppMap.size() > 0 ){
            addDefaultOLIAvacareFuture(avacareOppMap);
        }
    }
    
    @future
    public static void addDefaultOLIAvacareFuture(Map<id,String> oppMap){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                OpportunityLineItem.SObjectType
            }
        );
        Map<id,Opportunity> oppDetailMap = new SLT_opportunity().getOpportunityById(oppMap.keyset(), new Set<String>{'RD_Product_Count__c'});
        List<OpportunityLineItem> oppLineitemList = new List<OpportunityLineItem>();
        Map<String,Id> pbe = new Map<String,Id>();
        // Product code of Avacare Product = Q_112941
        for(PricebookEntry pb : (new SLT_PriceBookEntry().getPricebookEntriesForProductList(new Set<String>{'Q_112941'} , new Set<String>{'id','Product2Id','CurrencyIsoCode'} , oppMap.values()))){
            if(!(pbe.containsKey(pb.CurrencyIsoCode))){
                pbe.put(pb.CurrencyIsoCode,pb.id);
            }
        }
        
        for(Id oppId : oppMap.keyset()){
            if(oppDetailMap.get(oppId).RD_Product_Count__c == 0 ){
                OpportunityLineItem oppOli = new OpportunityLineItem();
                
                oppOli.PricebookEntryId = pbe.get(oppMap.get(oppId));
                oppOli.UnitPrice = 0;
                oppOli.Sale_Type__c = 'New';
                oppOli.Delivery_Country__c = 'USA';
                oppOli.Revenue_Type__c = 'Ad Hoc';
                oppOli.OpportunityId = oppId;
                oppOli.Quantity = 1;
                oppLineitemList.add(oppOli);                
            }
        }
        
        if(oppLineitemList.size() > 0){
            uow.registerNew(oppLineitemList);
            uow.commitWork();
        }
    }
    
    /**
     * Method to update Sales Price of Opportunity Products on the Avacare Opportunity
     * Requirement ESPSFDCQI-17825
     * @param List<Opportunity> newList
     * @param Map<Id, Opportunity> oldMap
     */
    public static void updateSalePriceAvacareProduct(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                OpportunityLineItem.SObjectType
            }
        );
        Map<id,Opportunity> avacareOppMap = new Map<id,Opportunity>();
        List<OpportunityLineItem> OpptoOLIList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oliToUpdateList = new List<OpportunityLineItem>();
        for(Opportunity opp : newList){
            if(opp.Line_of_Business__c == 'Avacare' && opp.RD_Product_Count__c != 0 && (((opp.StageName != oldMap.get(opp.id).StageName) && (new set<String>{CON_CRM.DEVELOPING_PROP_STAGE,CON_CRM.DELIVERING_PROP_STAGE,CON_CRM.FINALIZING_DEAL_STAGE,CON_CRM.RECEIVED_ATP_STAGE,CON_CRM.CLOSED_WON_STAGE}).contains(opp.StageName)) || (oldmap.get(opp.id).Feasibility_Enrollment_Goal_Sum__c != opp.Feasibility_Enrollment_Goal_Sum__c || oldMap.get(opp.id).TherapyArea__c != opp.TherapyArea__c || oldMap.get(opp.id).InterventionType__c != opp.InterventionType__c || oldMap.get(opp.id).Avacare_Enrollment_Goal__c != opp.Avacare_Enrollment_Goal__c || oldMap.get(opp.id). PPC_Actual__c != opp.PPC_Actual__c ))){
                avacareOppMap.put(opp.id,opp);
            }
        }
        
        if(avacareOppMap.size() > 0 ){
            // Product code of Avacare Product = Q_112941
            OpptoOLIList = new SLT_OpportunityLineItems().getOLIByOppIdAndProductCode(avacareOppMap.keyset(),  new Set<String>{'Id','UnitPrice','OpportunityId','ProductCode'} , new Set<String>{'Q_112941'});
            if(OpptoOLIList.size() > 0){
                double ppcEstimate = 0;
                double ppcActual = 0;
                for( OpportunityLineItem oli : OpptoOLIList ){
                    OpportunityLineItem tempOli = new OpportunityLineItem();
                    if((new Set<String>{CON_CRM.DEVELOPING_PROP_STAGE,CON_CRM.DELIVERING_PROP_STAGE,CON_CRM.FINALIZING_DEAL_STAGE}.contains(avacareOppMap.get(oli.OpportunityId).StageName))){
                        if(avacareOppMap.get(oli.OpportunityId).PPC_Estimate__c != null){
                            ppcEstimate = avacareOppMap.get(oli.OpportunityId).PPC_Estimate__c;
                        }
                        tempOli.UnitPrice = avacareOppMap.get(oli.OpportunityId).Feasibility_Enrollment_Goal_Sum__c * ppcEstimate ;
                    }else{
                        if(avacareOppMap.get(oli.OpportunityId).PPC_Actual__c != null){
                            ppcActual = avacareOppMap.get(oli.OpportunityId).PPC_Actual__c;
                        }
                        tempOli.UnitPrice = (avacareOppMap.get(oli.OpportunityId).Feasibility_Enrollment_Goal_Sum__c + avacareOppMap.get(oli.OpportunityId).Avacare_Enrollment_Goal__c) * ppcActual ;
                    }
                    tempOli.id = oli.Id;
                    oliToUpdateList.add(tempOli);
                }
            }
        }
        if(oliToUpdateList.size() > 0){
            uow.registerDirty(oliToUpdateList);
            uow.commitWork();
        }
    }
}
