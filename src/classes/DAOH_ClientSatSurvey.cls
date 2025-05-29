/*
 * Version       : 1.0
 * Description   : This Apex class is service class for Client Sat Survey Trigger
 */
public class DAOH_ClientSatSurvey {
    /**
    * This method is used to check survey has billable project
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */
    public static void validateSurvey_HasBillableProject(List<Client_Sat_Survey__c> newSurveyList) {
        Set<Id> oppId = new Set<Id>();
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Opportunity__c != null){
                oppId.add(cs.Opportunity__c);
            }
        }
        Map<Id,Opportunity> oppMap = new SLT_Opportunity().getMapOfOpportunitiesWithProjectsById(oppId);
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Opportunity__c != null && oppMap.get(cs.Opportunity__c) != null && oppMap.get(cs.Opportunity__c).Proxy_Projects__r.size() > 0){
                boolean hasBillable = false;
                for(Proxy_Project__c  project : oppMap.get(cs.Opportunity__c).Proxy_Projects__r){
                    if(project.Is_Project_Billable__c){
                        hasBillable = true;
                        break;
                    }
                }
                if(!hasBillable) {
                    cs.addError(CON_Qualtrics.OPPORTUNITY_ATLEAST_HAVE_ONE_BILLABLE_PROJECT_ERROR_MSG);                    
                }
            }
        }
    }

    /**
    * This method is used to update initiation status of survey
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id, Client_Sat_Survey__c> oldMap
    * @return void
    */    
    public static void updateSurvey_InitiationStatus(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMap) {
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(cs.Id).Send_Survey__c != CON_Qualtrics.SEND_SURVEY_NO))){
                if(cs.Don_t_Send_Survey_Reason__c == CON_Qualtrics.DECLINED ){
                    cs.Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_DECLINED_PENDING_MGR_APPROVAL;
                }else if(cs.Don_t_Send_Survey_Reason__c  == CON_Qualtrics.DELAYED){
                    cs.Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_DELAYED_PENDING_APPROVAL;
                }
            }
            if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_YES && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(cs.Id).Send_Survey__c != CON_Qualtrics.SEND_SURVEY_YES))) {
                cs.Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_APPROVED;                
                resetApproversDetail(cs);
            }
        }    
    }
    
    /**
    * This method is used to set surevy fields
    * @params List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMap
    * @return void
    */  
	public static void setClientSatSurveyFields(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMap) {
        Set<Id> oppIdSet = new Set<Id>();
        List<Client_Sat_Survey__c> filteredSurveyList = new List<Client_Sat_Survey__c>();
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(Trigger.isInsert && cs.Survey_Recipient_1__c == null){
                cs.Survey_Recipient_1__c = Survey_Setting__c.getInstance().Default_Survey_Recipient__c;
            }
            if(cs.Opportunity__c != null && (Trigger.isInsert || (Trigger.isUpdate && cs.Opportunity__c != oldMap.get(cs.Id).Opportunity__c))){
                oppIdSet.add(cs.Opportunity__c);
                filteredSurveyList.add(cs);
            }
        }    
        if(oppIdSet.size() > 0){
            Map<Id, Opportunity> oppIdMap = new SLT_Opportunity().getOpportunityById(oppIdSet,new Set<String>{'AccountId', 'Is_Survey_Eligible_for_Non_RDS__c', 'is_Survey_Eligible_for_RDS_Manual__c', 'is_Survey_eligible_for_RDS_Auto__c','Principle_inCharge__c'});
            for(Client_Sat_Survey__c cs : filteredSurveyList){
                if(oppIdMap.get(cs.Opportunity__c).AccountId != null){
                    cs.Account__c = oppIdMap.get(cs.Opportunity__c).AccountId;
                }
            }
        }
    }
    /**
    * This method is used to validate survey exists or not
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */     
   /* public static void validateSurvey_SurveyExists(List<Client_Sat_Survey__c> newSurveyList) {
        Set<Id> oppIdSet = new Set<Id> ();
        Date Date6Back = Date.today().addMonths(-6);
        for(Client_Sat_Survey__c cs : newSurveyList) {
            if(cs.Opportunity__c != null)
                oppIdSet.add(cs.Opportunity__c);
        }
        if(!oppIdSet.isEmpty() ) {
            Map<Id, opportunity> oppIdToOppMap = new Map<Id, opportunity>();
            oppIdToOppMap= new Map<Id, Opportunity>(new SLT_Opportunity().getOpportunityWithClientSatByoppId(oppIdSet, Date6Back));
            
            oppIdSet.clear();
            if(!oppIdToOppMap.isEmpty()){
                for(opportunity opp : oppIdToOppMap.values()){  
                    if(opp.Client_Sat_Surveys__r.size() >0 ) { 
                        oppIdSet.add(opp.Id);
                    }  
                }
                for(Client_Sat_Survey__c newCS : newSurveyList) {
                    if(oppIdSet.contains(newCS.Opportunity__c) && !(oppIdToOppMap.get(newCS.Opportunity__c).is_Survey_eligible_for_RDS_Manual__c && oppIdToOppMap.get(newCS.Opportunity__c).Client_Sat_Surveys__r[0].Survey_Type__c == CON_Qualtrics.ONGOING && newCS.Survey_Type__c == CON_Qualtrics.END_OF_ENGAGEMENT)) {
                        newCS.addError(CON_Qualtrics.SURVEY_HAS_ALREADY_BEEN_CREATED_WITHIN_LAST_6_MONTHS_ERROR_MSG);
                    }
                }
            }
        } 
    }*/

    /**
    * This method is used to update opportunity codes on survey
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */    
    public static void updateSurvey_OpportunityProductCodes(List<Client_Sat_Survey__c> newSurveyList) {
        Set<Id> oppIdSet = new Set<Id>();
        for(Client_Sat_Survey__c cs : newSurveyList){
            oppIdSet.add(cs.Opportunity__c);
        }
        if(!oppIdSet.isEmpty()){
            List<OpportunityLineItem> oppLines;
            oppLines = new SLT_OpportunityLineItems().selectOLIByOpportunityId(oppIdSet);
            Map<id, String> oppProdCodeMap = new Map<id, String>();
            
            if(!oppLines.isEmpty()){
                for(OpportunityLineItem oli : oppLines) {
                    String prodCode = oppProdCodeMap.get(oli.OpportunityId);
                    if(prodCode == null || (prodCode != null && !prodCode.contains(oli.PricebookEntry.Product2.Global_Product_Code__c))){
                        prodCode = (prodCode == null) ? oli.PricebookEntry.Product2.Global_Product_Code__c : (prodCode + '; ' + oli.PricebookEntry.Product2.Global_Product_Code__c);
                            oppProdCodeMap.put(oli.OpportunityId, prodCode);
                    }
                }
            }
            for(Client_Sat_Survey__c cs : newSurveyList){
                cs.Opportunity_Product_Codes__c = oppProdCodeMap.get(cs.Opportunity__c);
            }
        }
    }

    /**
    * This method is used to filter declined surveys
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id, Client_Sat_Survey__c> oldMapOfSurveys
    * @return Set<Client_Sat_Survey__c>
    */    
    public static Set<Client_Sat_Survey__c> filterSurvey_DeclinedSurveys(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMapOfSurveys) {
        Set<Client_Sat_Survey__c> declinedCSSet = new Set<Client_Sat_Survey__c> ();
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO && (Trigger.Isinsert || cs.Send_Survey__c != oldMapOfSurveys.get(cs.Id).Send_Survey__c )){
                declinedCSSet.add(cs);
            }
        }
        return declinedCSSet;
    }

    /**
    * This method is used to submit surveys for approval
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id, Client_Sat_Survey__c> oldMapOfSurveys
    * @return void
    public static void submitForApproval(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMapOfSurveys) {
        List<Approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest> ();
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO && (Trigger.isInsert || (Trigger.isUpdate && oldMapOfSurveys.get(cs.id).Send_Survey__c != cs.Send_Survey__c))){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(cs.id);
                approvalList.add(req1);
            }
        }
        //if(approvalList.size() > 0)
            //Approval.process(approvalList, false);        
    }
    
    /**
    * This method is used to reassign approval request by updated workiteminstance on Client sat survey.
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id, Client_Sat_Survey__c> oldMapOfSurveys
    * @return void    
    public static void reassignApprovalRequest(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMapOfSurveys){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                ProcessInstanceWorkitem.SobjectType
                    }
        );
        
        Boolean toCommit = false;
        Set<Id> csDeclinedIdSet = new Set<Id>();
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Need_Escalation__c && cs.Need_Escalation__c != oldMapOfSurveys.get(cs.Id).Need_Escalation__c){
                cs.Need_Escalation__c = false;
                csDeclinedIdSet.add(cs.ID);   
            }
            
        }
        if(csDeclinedIdSet.size() > 0){
            List<ProcessInstanceWorkitem> processInstanceWorkItemList =  new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetId(csDeclinedIdSet);
            Map<Id, List<ProcessInstanceWorkitem>> targetObjectIdToWorkItemMap = new Map<Id, List<ProcessInstanceWorkitem>>();
            for(ProcessInstanceWorkitem processInstworkItem : processInstanceWorkItemList){
                if(targetObjectIdToWorkItemMap.containsKey(processInstworkItem.processInstance.TargetObjectId)){
                    targetObjectIdToWorkItemMap.get(processInstworkItem.processInstance.TargetObjectId).add(processInstworkItem); 
                }else{
                    targetObjectIdToWorkItemMap.put(processInstworkItem.processInstance.TargetObjectId, new List<ProcessInstanceWorkitem>{processInstworkItem}); 
                }
            }
            List<GroupMember> reassignGroupMember = new SLT_Groups().getGroupMembersByGroupName(new Set<String>{'Decline Survey Reassign Group'});
            Id userId = null;
            if(reassignGroupMember[0].UserOrGroupId.getSObjectType() == User.sObjectType){
                userId =  reassignGroupMember[0].UserOrGroupId;
            } 
            if(userId != null){
                for(ID targetobjectId : targetObjectIdToWorkItemMap.keySet()){
                    if(targetObjectIdToWorkItemMap.get(targetobjectId).size() > 0){
                        for(Integer i = 0 ; i < targetObjectIdToWorkItemMap.get(targetobjectId).size(); i++){
                            if(i == 0){
                                ProcessInstanceWorkitem processInstanceWorkItemUpdated = targetObjectIdToWorkItemMap.get(targetobjectId).get(i);
                                processInstanceWorkItemUpdated.ActorId = userId;
                                uow.registerDirty(processInstanceWorkItemUpdated);
                                toCommit = true;
                            }else if(i > 0) {
                                uow.registerDeleted(targetObjectIdToWorkItemMap.get(targetobjectId).get(i));
                            }
                        }
                    } 
                }
                if(toCommit) {
                    try {
                        uow.commitWork();
                    } catch(DmLException ex) {
                        throw ex;
                    } 
                }
            }
        }
	}
    **/

    /**
    * This method is used to create contact for incoming client sat survey recipient value in intake process
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id, Client_Sat_Survey__c> oldMapOfSurveys
    * @return void
    */ 
    public static void createContactForIntakeSolution(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMapOfSurveys){
        List<Client_Sat_Survey__c> cslistEmailChanged = new List<Client_Sat_Survey__c>();
        Set<String> emailIdSet = new Set<String>();
        Map<Id, Map<String, Contact>> contactToCsMap = new Map<Id, Map<String, Contact>>();
        Boolean isSurveyRecipientEmailValueChanged;
        List<Client_Sat_Survey__c> csListToInsertContactValue = new List<Client_Sat_Survey__c>();
        for(Client_Sat_Survey__c cs : newSurveyList){
            Client_Sat_Survey__c oldCs = oldMapOfSurveys.get(cs.id);
            isSurveyRecipientEmailValueChanged = false;
            for(Integer i = 1; i <= 3; i++){
                String surveyRecipientNumber = String.ValueOf(i);
                String surveyRecipientEmail = String.ValueOf(cs.get('Survey_Recipient_'+surveyRecipientNumber+'_Email__c'));
                String oldSurveyRecipientEmail = String.ValueOf(oldCs.get('Survey_Recipient_'+surveyRecipientNumber+'_Email__c'));
                String surveyRecipientFirstName = String.ValueOf(cs.get('Survey_Recipient_'+surveyRecipientNumber+'_First_Name__c'));
                String surveyRecipientLastName = String.ValueOf(cs.get('Survey_Recipient_'+surveyRecipientNumber+'_Last_Name__c'));
                String surveyRecipientJobTitle = String.ValueOf(cs.get('Survey_Recipient_'+surveyRecipientNumber+'_Job_Title__c'));
                
                if(surveyRecipientEmail != oldSurveyRecipientEmail){
                    if((surveyRecipientEmail == null || surveyRecipientEmail == '') ){
                        if(surveyRecipientNumber != '1'){
                            cs.put('Survey_Recipient_'+surveyRecipientNumber+'__c', null);
                            cs.put('Survey_Recipient_'+surveyRecipientNumber+'_First_Name__c', '');
                            cs.put('Survey_Recipient_'+surveyRecipientNumber+'_Last_Name__c', '');
                            cs.put('Survey_Recipient_'+surveyRecipientNumber+'_Job_Title__c', '');
                        }
                    }else if(surveyRecipientFirstName != null && surveyRecipientLastName != null && surveyRecipientJobTitle != null){
                        isSurveyRecipientEmailValueChanged = true;
                        emailIdSet.add(surveyRecipientEmail);
                    }
                } 
            }
            if(isSurveyRecipientEmailValueChanged){
                cslistEmailChanged.add(cs);
            }
        }
        
        if(cslistEmailChanged.size() > 0){
            List<Contact> existingContactList = new SLT_Contact().selectByEmailIdSet(emailIdSet);
            Map<String, Id> existingContactMap = new Map<String, Id>();
            List<Contact> contactToInsert = new List<Contact>();
            
            for(Contact cont : existingContactList){
                existingContactMap.put(cont.email, cont.id);
            }
            
            for(Client_Sat_Survey__c cs : cslistEmailChanged){
                Map<String, Contact> contactToEmail = new Map<String, Contact>();
                for(Integer i = 1; i <= 3; i++){
                    String surveyRecipientNumber = String.ValueOf(i);
                    String surveyRecipientEmail = String.ValueOf(cs.get('Survey_Recipient_'+surveyRecipientNumber+'_Email__c'));
                    String surveyRecipientFirstName = String.ValueOf(cs.get('Survey_Recipient_'+surveyRecipientNumber+'_First_Name__c'));
                    String surveyRecipientLastName = String.ValueOf(cs.get('Survey_Recipient_'+surveyRecipientNumber+'_Last_Name__c'));
                    String surveyRecipientJobTitle = String.ValueOf(cs.get('Survey_Recipient_'+surveyRecipientNumber+'_Job_Title__c'));
                    
                    if(emailIdSet.contains(surveyRecipientEmail)) {
                        if(existingContactMap.keySet().contains(surveyRecipientEmail) ){
                            cs.put('Survey_Recipient_'+surveyRecipientNumber+'__c', existingContactMap.get(surveyRecipientEmail));
                        }else{
                            Contact newContact = createContactHelper(surveyRecipientEmail, surveyRecipientFirstName, surveyRecipientLastName, surveyRecipientJobTitle, cs.Account__c);
                            contactToInsert.add(newContact);
                            contactToEmail.put('Survey_Recipient_'+surveyRecipientNumber+'__c', newContact);
                        }
                    }
                    
                } 
                if(contactToEmail.size() > 0){
                    csListToInsertContactValue.add(cs);
                    contactToCsMap.put(cs.id,contactToEmail);
                }
            }
            
            if(contactToInsert.size() > 0){
                try{
                    insert contactToInsert;
                } catch(Exception ex) {
                    for(Client_Sat_Survey__c cs : cslistEmailChanged) {
                        cs.addError(ex.getMessage());
                    }
                }
            }
            
            for(Client_Sat_Survey__c cs : csListToInsertContactValue){
                Map<String,Contact> contactToEmailMap = contactToCsMap.get(cs.id);
                for(Integer i = 1; i <= 3; i++){
                    String surveyRecipientNumber = String.ValueOf(i);
                    if(contactToEmailMap.containsKey('Survey_Recipient_'+surveyRecipientNumber+'__c') ){
                        Contact surveyRecipient = contactToEmailMap.get('Survey_Recipient_'+surveyRecipientNumber+'__c');
                        cs.put('Survey_Recipient_'+surveyRecipientNumber+'__c', surveyRecipient.Id); 
                    }
                }
            }   
        }
    }
    
    
    public static Contact createContactHelper(String surveyRecipientEmail, String surveyRecipientFirstName, String surveyRecipientLastName, String jobTitle, Id accId){
        Contact newContact = new Contact();
        newContact.Email = surveyRecipientEmail;
        newContact.FirstName = surveyRecipientFirstName;
        newContact.LastName = surveyRecipientLastName;
        newContact.Title = jobTitle;
        newContact.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
        newContact.AccountId = accId;
        return newContact;
    }
    
    
    /**
    * This method is used to query opp details and update declined survey approver 1, 2 and 3 (contact lookups) on survey
    * @params Set<Client_Sat_Survey__c> csSet
    * @return void
    */    
    public static void updateSurvey_DeclinedSurveyApproversContact(Set<Client_Sat_Survey__c> csList) {
        Set<Id> oppIdSet = new Set<Id> ();
        for(Client_Sat_Survey__c cs : csList) {
            oppIdSet.add(cs.Opportunity__c);
        }
        Set<String> oppFieldSet = new Set<String>{'Name', 'Line_of_Business__c', 'Business_Unit__c','Main_Delivery_Country__c','Is_this_IQVIA_Biotech__c',
            'Is_Survey_Eligible_for_Non_RDS__c', 'Is_Survey_Eligible_for_RDS_Auto__c', 'Is_Survey_Eligible_for_RDS_Manual__c','ZREP_Amount__c',
            'Principle_inCharge__r.Salesforce_User__r.PeopleSoft_Product_Offering_Segment__c',
            'Principle_inCharge__r.Salesforce_User__r.PeopleSoft_Product_Offering_Type__c',
            'Principle_inCharge__r.Salesforce_User__r.PeopleSoft_Product_COE__c', 
            'Principle_inCharge__r.Salesforce_User__r.WD_Profit_Center_Hierarchy_Level_5__c',
            'Principle_inCharge__r.Salesforce_User__r.User_Country__c'
            };
                
        Map<Id, Opportunity> oppListWithPICdetails = new SLT_Opportunity().getOpportunityById(oppIdSet, oppFieldSet); 

        for(Client_Sat_Survey__c cs :csList ){
            Opportunity opp = oppListWithPICdetails.get(cs.Opportunity__c);
            setApproversDetail(cs, opp);
        }
    }
    
    /**
    * This method is used to set declined survey approver approver 1, 2 and 3
    * @params Client_Sat_Survey__c cs
    * @params Opportunity opp 
    * @return void
    */  
    public static void setApproversDetail(Client_Sat_Survey__c cs, Opportunity opp){
        List<DeclinedSurveyApproverGroup__c> filterDeclinedApproverGroupList;
        filterDeclinedApproverGroupList =  getdeclinedApproverContactsList(opp);
        if(filterDeclinedApproverGroupList != null && filterDeclinedApproverGroupList.size() > 0){
            setApprovers(filterDeclinedApproverGroupList, cs);
        } else if(filterDeclinedApproverGroupList == null || filterDeclinedApproverGroupList.size() == 0){
            setDefaultApprovers(cs);
        }
    }
    
    /**
    * This method is used to filter declined survey approvers group list for survey
    * @params List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList
    * @params Opportunity opp
    * @return List<DeclinedSurveyApproverGroup__c>
    */    
    public static List<DeclinedSurveyApproverGroup__c> getdeclinedApproverContactsList(Opportunity opp){        
        
        Set<String> RdsCoreLOBs = new Set<String>{'Clinical', 'Data Sciences', 'Early Clinical Development', 'Connected Devices','Patient & DCT Solutions'};
        Set<String> oppBU = new Set<String>{opp.Business_Unit__c, CON_Qualtrics.ALL};
        Set<String> oppMainDeliveryCountry = new Set<String>{opp.Main_Delivery_Country__c, CON_Qualtrics.ALL};
        Set<String> oppLOB = new Set<String>{opp.Line_of_Business__c, CON_Qualtrics.ALL};
        Set<String> nonRDSLOBs = new Set<String>{'Medical Affairs','Tech & Data'};
        if( ( opp.Is_Survey_Eligible_for_RDS_Auto__c || opp.Is_Survey_Eligible_for_RDS_Manual__c ) && RdsCoreLOBs.Contains(opp.Line_of_Business__c) && opp.Is_this_IQVIA_Biotech__c == 'Yes'){
            return new SLT_DeclinedSurveyApproverGroup().getDeclinedSurveyApproverRDSOrderByPriorityYes(oppBU, oppLOB);
        }else if(opp.Is_Survey_Eligible_for_RDS_Auto__c || opp.Is_Survey_Eligible_for_RDS_Manual__c){
            return new SLT_DeclinedSurveyApproverGroup().getDeclinedSurveyApproverRDSOrderByPriority(oppBU, oppLOB ); 	
        } else if(opp.Is_Survey_Eligible_for_Non_RDS__c && nonRDSLOBs.contains(opp.Line_of_Business__c)) {
            return new SLT_DeclinedSurveyApproverGroup().getDeclinedSurveyApprovernonRDSWithLOBset(oppBU, nonRDSLOBs);
        } else if(opp.Is_Survey_Eligible_for_Non_RDS__c){
            if(opp.Principle_inCharge__c != null && opp.Principle_inCharge__r.Salesforce_User__c != null){
                Set<String> PIC_productOfferingSegment = new Set<String>{opp.Principle_inCharge__r.Salesforce_User__r.PeopleSoft_Product_Offering_Segment__c, CON_Qualtrics.ALL};
                Set<String> PIC_productOfferingType = new Set<String>{opp.Principle_inCharge__r.Salesforce_User__r.PeopleSoft_Product_Offering_Type__c, CON_Qualtrics.ALL};
                Set<String> PIC_ProductCOE = new Set<String>{opp.Principle_inCharge__r.Salesforce_User__r.PeopleSoft_Product_COE__c, CON_Qualtrics.ALL};
                Set<String> PIC_BU = new Set<String>{opp.Principle_inCharge__r.Salesforce_User__r.WD_Profit_Center_Hierarchy_Level_5__c, CON_Qualtrics.ALL};
                Set<String> PIC_userCntry = new Set<String>{opp.Principle_inCharge__r.Salesforce_User__r.User_Country__c, CON_Qualtrics.ALL};
                return new SLT_DeclinedSurveyApproverGroup().getDeclinedSurveyApproverNonRDSOrderByPriority(PIC_productOfferingSegment, PIC_productOfferingType, PIC_ProductCOE, PIC_BU, PIC_userCntry, oppBU, oppMainDeliveryCountry);
            }
        }
        return null;
    }
    
    /**
    * This method is used to set declined survey approvers according to the filtered declined approver list
    * @params List<DeclinedSurveyApproverGroup__c> filterDeclinedApproverGroupList
    * @params Client_Sat_Survey__c cs
    * @return void
    */  
    public static void setApprovers(List<DeclinedSurveyApproverGroup__c> filterDeclinedApproverGroupList, Client_Sat_Survey__c cs){
        resetApproversDetail(cs);
        if(filterDeclinedApproverGroupList.get(0).Declined_SurveyApprover_1__c != null){
            cs.Declined_SurveyApprover_1__c = filterDeclinedApproverGroupList.get(0).Declined_SurveyApprover_1__c;
        }
        if(filterDeclinedApproverGroupList.get(0).Declined_SurveyApprover_2__c != null){
            cs.Declined_SurveyApprover_2__c = filterDeclinedApproverGroupList.get(0).Declined_SurveyApprover_2__c;
        }
        
        if(filterDeclinedApproverGroupList.get(0).Declined_SurveyApprover_3__c != null){
            cs.Declined_SurveyApprover_3__c = filterDeclinedApproverGroupList.get(0).Declined_SurveyApprover_3__c;
        }
        if(filterDeclinedApproverGroupList.get(0).Decline_Survey_Approver_Email__c != null){
            cs.Decline_Survey_Approver_Email__c = filterDeclinedApproverGroupList.get(0).Decline_Survey_Approver_Email__c;
        }
        system.debug(filterDeclinedApproverGroupList.get(0).Priority__c);
    }
    
    /**
    * This method is used to reset declined survey approvers to null
    * @params Client_Sat_Survey__c cs
    * @return void
    */  
    public static void resetApproversDetail(Client_Sat_Survey__c cs){
        cs.Declined_SurveyApprover_1__c = null;
        cs.Declined_SurveyApprover_2__c = null;
        cs.Declined_SurveyApprover_3__c = null;
        cs.Decline_Survey_Approver_Email__c = null;
    }
    
    /**
    * This method is used to set default declined survey approvers
    * @params List<DeclinedSurveyApproverGroup__c> filterDeclinedApproverGroupList
    * @params Client_Sat_Survey__c cs
    * @return void
    */
    public static void setDefaultApprovers(Client_Sat_Survey__c cs){
        CS_Config__c csConfig = CS_Config__c.getInstance();
        if(csConfig != null && csConfig.CS_Admin_Contact_Ids__c != null){
            List<Id> approverIds = csConfig.CS_Admin_Contact_Ids__c.trim().split(',');
            for(Integer i = 0; i < approverIds.size(); i++){
                if(i < 3){
                    cs.put('Declined_SurveyApprover_'+(i+1)+'__c', approverIds[i]);
                }
            }
        }
    }
    /**
    * This method is used to update opportunity codes on survey
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */    
    public static void updateSurvey_OpportunityRecord(List<Client_Sat_Survey__c> newSurveyList) {
        List<Opportunity> oppListNonSurveyExist;
        Set<String> oppFieldSet = new Set<String>{'Is_Survey_Exist__c', 'Id', 'Survey_Recipient__c'};
        String Condition = 'Is_Survey_Exist__c = false';    
        Map<Id, Client_Sat_Survey__c> oppIdToSurveyMap = new Map<Id, Client_Sat_Survey__c>();
        Boolean toCommit = false;
        for(Client_Sat_Survey__c cs : newSurveyList){
            oppIdToSurveyMap.put(cs.Opportunity__c, cs);
        }
        
        if(oppIdToSurveyMap.size() > 0){
            oppListNonSurveyExist = new SLT_Opportunity().getOpportunityWithNonExistingsurvey(oppIdToSurveyMap.keyset(), oppFieldSet, Condition);
            if(!oppListNonSurveyExist.isEmpty()){
                for(Opportunity opp : oppListNonSurveyExist) {
                    opp.Is_Survey_Exist__c = true;
                    toCommit = true;
                }
            }
            if(toCommit){
                UTL_ExecutionControl.stopTriggerExecution = true;
                Database.SaveResult[] sr = Database.update(oppListNonSurveyExist, false);
                for(Integer i = 0; i < sr.size(); i++) {
                    Id oppId = oppListNonSurveyExist.get(i).Id;
                    if(!sr[i].isSuccess()) {
                        String msgStr = null;
                        Client_Sat_Survey__c cs = oppIdToSurveyMap.get(oppId);
                        Database.Error[] err = sr[i].getErrors();
                        cs.addError(err[0].getMessage());
                    }
                }
                UTL_ExecutionControl.stopTriggerExecution = false;
            }
        }
    }
    
    /**
    * This method is used to set SurveyPIC field
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */    
    public static void setSurveyPIC(List<Client_Sat_Survey__c> newSurveyList) {
        Map<Id, Client_Sat_Survey__c> oppIdToSurveyMap = new Map<Id, Client_Sat_Survey__c>();
        Map<Id, Opportunity> oppMap;
        Map<Id, Opportunity> oppIdToOpportunitywithSurveyMap;
        Set<String> LOBSet1 = new Set<String>{'Clinical','Data Sciences', 'Early Clinical Development', 'Connected Devices', 'Safety & Med Info', 'Regulatory & Drug Development Solutions','Patient & DCT Solutions'};
        Set<String> LOBSet2 = new Set<String>{'Outcome','RWLP'};
        List<Client_Sat_Survey__c> needToUpdateList = new List<Client_Sat_Survey__c>();
        List<Client_Sat_Survey__c> needToUpdateListProxyProject = new List<Client_Sat_Survey__c>();
        //List<Agreement_Extension__c> agrExtList = new List<Agreement_Extension__c>();
        Map<Id, Apttus__APTS_Agreement__c> oppIdToAgrMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id, Id> oppIdToContactId = new Map<Id, Id>();
        Set<Id> contractRecordTypeSet1 = new Set<Id>{CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL};
        //Set<Id> contractRecordTypeSet2 = new Set<Id>{CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL};
        Set<Id> opportunityIdsProxyProject = new Set<Id>{};
        Map<Id,Proxy_Project__c> proxyProjectMap = new Map<Id,Proxy_Project__c>();
        Set<Id> opportunityIds = new Set<Id>{};
        
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Opportunity__c != null) {
                opportunityIds.add(cs.Opportunity__c);
            }
        }
        if(opportunityIds.size() > 0 ) {
            proxyProjectMap= new SLT_proxy_Project().getProxyProjectByOppIDAndRecordTypeName(opportunityIds, 'Engagement', new Set<String>{'ID','Name','Delivery_PIC_Name__c','Delivery_PIC_User_Country__c','Project_Start_Date__c','Project_End_Date__c','Opportunity__c','Delivery_PIC_Email__c','Delivery_PIC_EmployeeNumber__c'});
        }
        for(Client_Sat_Survey__c cs : newSurveyList) {
            if(cs.Opportunity__c != null && cs.Opportunity_ZREP_Product_Count__c > 0 && proxyProjectMap.containsKey(cs.Opportunity__c)) {
                needToUpdateListProxyProject.add(cs);
            }
            else if(cs.Opportunity__c != null && cs.Line_of_Business__c == 'Clinical' && cs.Opportunity_PIC__c != null ){
                needToUpdateList.add(cs);
                oppIdToContactId.put(cs.Opportunity__c, cs.Opportunity_PIC__c);
            }
            else if(cs.Opportunity__c != null && (LOBSet1.contains(cs.Line_of_Business__c) || LOBSet2.contains(cs.Line_of_Business__c))) {
                oppIdToSurveyMap.put(cs.Opportunity__c, cs);
            }
            else if(cs.Opportunity__c != null) {
                needToUpdateList.add(cs);
                oppIdToContactId.put(cs.Opportunity__c, cs.Opportunity_PIC__c);
            }
        }
        if(oppIdToSurveyMap.size() > 0) {
            oppMap = new SLT_Opportunity().getOpportunityWithContractsWithFilter(oppIdToSurveyMap.keySet(), LOBSet1, contractRecordTypeSet1, LOBSet2);
            //agrExtList = new SLT_Agreement_Extension(false, false).getAgreementExtByOpps(null, oppIdToSurveyMap.keySet(), new Set<String>{'Agreement__r.Apttus__Related_Opportunity__c', 'IQVIA_Project_Manager_Con__c', 'CreatedDate'});
            List<Apttus__APTS_Agreement__c> agrList = new SLT_APTS_Agreement(false, false).getAgreementsByOppIds(oppIdToSurveyMap.keySet(), new Set<String>{'Apttus__Related_Opportunity__c', 'IQVIA_Project_Manager_Con__c', 'CreatedDate'} , LOBSet1, LOBSet2 );
            for(Apttus__APTS_Agreement__c agr : agrList) {
                if(!oppIdToAgrMap.containsKey(agr.Apttus__Related_Opportunity__c)) {
                    oppIdToAgrMap.put(agr.Apttus__Related_Opportunity__c, agr);
                }
            }
            oppIdToOpportunitywithSurveyMap = new Map<Id, Opportunity>(new SLT_Opportunity().getLastSurveyOfOpportunity(oppIdToSurveyMap.keySet()));
            for(Client_Sat_Survey__c cs : oppIdToSurveyMap.values()) {
                Id iqviaProjectManager = NULL;
                DateTime createdDate = NULL;
                Id relatedRecordId = NULL;
                Client_Sat_Survey__c existingSurvey = NULL;
                Contract ctrt = NULL;
                //Agreement_Extension__c agrExt = NULL;
                Apttus__APTS_Agreement__c agr = NULL;

                if(oppIdToOpportunitywithSurveyMap.get(cs.Opportunity__c).Client_Sat_Surveys__r.size() > 0) {
                    existingSurvey = oppIdToOpportunitywithSurveyMap.get(cs.Opportunity__c).Client_Sat_Surveys__r[0];
                }
                
                if(oppIdToAgrMap.containsKey(cs.Opportunity__c)){
                    agr =  oppIdToAgrMap.get(cs.Opportunity__c);
                }
                
                if(oppMap.get(cs.Opportunity__c).Contracts__r.size() > 0) {
                    ctrt = oppMap.get(cs.Opportunity__c).Contracts__r[0];
                }
                
                if((ctrt != NULL && agr != NULL && ctrt.CreatedDate <= agr.CreatedDate) || (ctrt == NULL && agr != NULL)) {
                    relatedRecordId = agr.id;
                    iqviaProjectManager = agr.IQVIA_Project_Manager_Con__c;
                    createdDate = agr.CreatedDate;
                }
                else if((ctrt != NULL && agr != NULL && ctrt.CreatedDate > agr.CreatedDate) || (ctrt != NULL && agr == NULL)) {
                    relatedRecordId = ctrt.id;
                    iqviaProjectManager = ctrt.IQVIA_Project_Manager_Contact__c;
                    createdDate = ctrt.CreatedDate;
                }
                
                
                
                if(relatedRecordId != NULL){
                    if(existingSurvey == NULL || (existingSurvey != NULL && existingSurvey.Survey_Send_Date__c < createdDate)) {
                        oppIdToContactId.put(cs.Opportunity__c, iqviaProjectManager);
                        cs.Related_Contract_Id__c = relatedRecordId;
                    } else {
                        oppIdToContactId.put(cs.Opportunity__c, existingSurvey.Survey_PIC__c);
                        cs.Related_Contract_Id__c = existingSurvey.Related_Contract_Id__c;
                    }
                }else if(existingSurvey != null){
                    oppIdToContactId.put(cs.Opportunity__c, existingSurvey.Survey_PIC__c);
                    cs.Related_Contract_Id__c = existingSurvey.Related_Contract_Id__c;
                }else{ 
                    oppIdToContactId.put(cs.Opportunity__c, cs.Opportunity_PIC__c);
                }
                needToUpdateList.add(cs);
            }
        }
        if(needToUpdateListProxyProject.size() > 0){
            updateSurveyPICFieldsFromProxyProject(needToUpdateListProxyProject, proxyProjectMap);
        }
        if(needToUpdateList.size() > 0){
            updateSurveyPICFields(needToUpdateList, oppIdToContactId);
        }
    }
    
    public static void updateSurveyPICFields(List<Client_Sat_Survey__c> needToUpdateList, Map<Id, Id> oppIdToContactId) {
        Map<Id, Contact> contactMap = new SLT_Contact().selectByContactId(new Set<Id>(oppIdToContactId.values()), new Set<String>{'Id', 'Name','Email', 'FirstName', 'LastName', 'EmployeeNumber__c', 'Country__c' });
        for(Client_Sat_Survey__c cs  : needToUpdateList) {
            Contact updateFrom = contactMap.get(oppIdToContactId.get(cs.Opportunity__c));
            if(updateFrom != null){
                cs.Survey_PIC__c = updateFrom.Id;
                cs.Survey_PIC_Name__c = updateFrom.Name;
                cs.Survey_PIC_Email__c = updateFrom.Email;
                cs.Survey_PIC_Email1__c = updateFrom.Email;
                cs.Survey_PIC_First_Name__c = updateFrom.FirstName;
                cs.Survey_PIC_Last_Name__c = updateFrom.LastName;
                cs.Survey_PIC_EmployeeNumber__c = updateFrom.EmployeeNumber__c;
                cs.PIC_Country__c = updateFrom.Country__c;
            }
        }
    }
    
    public static void updateSurveyPICFieldsFromProxyProject(List<Client_Sat_Survey__c> needToUpdateList, Map<Id, Proxy_Project__c> proxyProjectMap) {
        for(Client_Sat_Survey__c cs  : needToUpdateList) {
            Proxy_Project__c proxyProject = proxyProjectMap.get(cs.Opportunity__c);
            if(proxyProject != null){
                cs.Survey_PIC_Name__c = proxyProject.Delivery_PIC_Name__c ;
                cs.Survey_PIC_Email__c = proxyProject.Delivery_PIC_Email__c;
                cs.Survey_PIC_Email1__c = proxyProject.Delivery_PIC_Email__c;
                cs.Survey_PIC_First_Name__c = (proxyProject.Delivery_PIC_Name__c == null ? '': proxyProject.Delivery_PIC_Name__c.SubStringBefore(' '));
                cs.Survey_PIC_Last_Name__c = (proxyProject.Delivery_PIC_Name__c == null ? '': proxyProject.Delivery_PIC_Name__c.SubStringAfter(' '));
                cs.Survey_PIC_EmployeeNumber__c = proxyProject.Delivery_PIC_EmployeeNumber__c;
                cs.PIC_Country__c = proxyProject.Delivery_PIC_User_Country__c;
                cs.Related_Contract_Id__c = proxyProject.Id;
            }
        }
    }
    
    /**
    * This method is used to update SurveyPIC field when Survey pic on survey is updated
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id,Client_Sat_Survey__c> oldMap
    * @return void
    */
    public static void setSurveyPICFields(List<Client_Sat_Survey__c> newList, Map<Id,Client_Sat_Survey__c> oldMap){
        Map<Id,Id> surveyPICDataToUpdate = new Map<Id,Id>();
        List<Client_Sat_Survey__c> surveyToUpdate = new List<Client_Sat_Survey__c>();
        for(Client_Sat_Survey__c cs : newList){
            if(cs.Survey_PIC__c != oldMap.get(cs.id).Survey_PIC__c){
                surveyPICDataToUpdate.put(cs.Opportunity__c, cs.Survey_PIC__c);
                surveyToUpdate.add(cs);
            }
        }
        if(surveyToUpdate.size() > 0){
            updateSurveyPICFields(surveyToUpdate, surveyPICDataToUpdate);
        }
    }


    /**
    * This method is used to set SurveyPIC field
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */    
    public static void resetOppFields(List<Client_Sat_Survey__c> newList) {
        Integer intakeSurveyDelay = 0;
        if(Survey_Setting__c.getInstance() != null && Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c != null) {
            intakeSurveyDelay = (Integer) Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c;   
        }
        Date todayDate = System.today().addDays(intakeSurveyDelay);
        Boolean toCommit = false;
        Map<Id,Client_Sat_Survey__c> oppIdToSurveyMap = new Map<Id,Client_Sat_Survey__c>();
        Map<Id, Opportunity> oppEligiblityData = new Map<Id, Opportunity>();
        List<Opportunity> oppListNonSurveyExist = new List<Opportunity>();
        for(Client_Sat_Survey__c cs : newList){
            if(cs.Survey_Send_Date__c >= System.today() || (cs.Send_Survey__c == null && cs.Survey_Send_Date__c < System.today())){
                oppIdToSurveyMap.put(cs.Opportunity__c, cs);
            }
        }
        Set<String> lineOfBusiness = new Set<String>{'Clinical','Data Sciences','Early Clinical Development','Connected Devices','Patient & DCT Solutions'};
            Map<Id,Proxy_Project__c> proxyProjectMap = new Map<Id,Proxy_Project__c>();
        
        if(oppIdToSurveyMap.Size() > 0){
            proxyProjectMap= new SLT_proxy_Project().getProxyProjectByOppIDAndRecordTypeName(oppIdToSurveyMap.keyset(), 'Engagement', new Set<String>{'ID','Name','Opportunity__c','Project_Start_Date__c', 'Project_End_Date__c'});
        }
        
        if(oppIdToSurveyMap.size() > 0){
            oppEligiblityData = new SLT_Opportunity().getOpportunityById(oppIdToSurveyMap.keyset(), new Set<String>{'Upcoming_Survey_Send_Date__c','Next_Survey_Send_Date__c','Expected_Project_Start_Date__c','ZREP_Product_Count__c','Line_of_Business__c','Is_Survey_Eligible_for_RDS_Auto__c', 'Is_Survey_Eligible_for_RDS_Manual__c', 'Is_Survey_Eligible_for_Non_RDS__c' , 'Expected_Project_End_Date__c' , 'Contract_End_Date__c'});
            if(oppEligiblityData.size() > 0 ){
                for(Client_Sat_Survey__c cs : oppIdToSurveyMap.values()){
                    Date nearestFutureDate;
                    Date endDate;
                    Integer interval;
                    
                    Opportunity opp = oppEligiblityData.get(cs.Opportunity__c);
                    if(opp.Is_Survey_Eligible_for_RDS_Auto__c || opp.Is_Survey_Eligible_for_RDS_Manual__c){
                        if(!lineOfBusiness.contains(opp.Line_of_Business__c)){
                            endDate = opp.Contract_End_Date__c;
                        }else if(lineOfBusiness.contains(opp.Line_of_Business__c)){
                            endDate = opp.Expected_Project_End_Date__c;
                        }
                        
                        nearestFutureDate = cs.Survey_Send_Date__c.addMonths(6);
                        
                        if(opp.ZREP_Product_Count__c > 0 && proxyProjectMap.size() > 0 && (proxyProjectMap.containsKey(opp.id))) {
                            endDate = proxyProjectMap.get(opp.id).Project_End_Date__c;
                        }
                        
                        interval = 6;
                        while(nearestFutureDate < todayDate) {
                            nearestFutureDate = nearestFutureDate.addMonths(interval);
                        }
                        
                        if(nearestFutureDate >= endDate) {
                            nearestFutureDate = endDate;
                        }
                        
                        if(opp.Upcoming_Survey_Send_Date__c < todayDate && opp.Next_Survey_Send_Date__c < todayDate ){
                            opp.Upcoming_Survey_Send_Date__c = nearestFutureDate;
                            opp.Next_Survey_Send_Date__c = nearestFutureDate;
                        }
                        
                        toCommit = true;
                        oppListNonSurveyExist.add(opp);
                        
                    }else if(opp.Is_Survey_Eligible_for_Non_RDS__c){
                        nearestFutureDate = cs.Survey_Send_Date__c.addMonths(12);
                        endDate = opp.Contract_End_Date__c;
                        
                        if(opp.ZREP_Product_Count__c > 0 && proxyProjectMap.size() > 0 && (proxyProjectMap.containsKey(opp.id))) {
                            endDate = proxyProjectMap.get(opp.id).Project_End_Date__c;
                        }
                        
                        interval = 12;
                        while(nearestFutureDate < todayDate) {
                            nearestFutureDate = nearestFutureDate.addMonths(interval);
                        }
                        
                        if(nearestFutureDate >= endDate) {
                            nearestFutureDate = endDate;
                        }
                        
                        if(opp.Upcoming_Survey_Send_Date__c < todayDate && opp.Next_Survey_Send_Date__c < todayDate ){
                            opp.Upcoming_Survey_Send_Date__c = nearestFutureDate;
                            opp.Next_Survey_Send_Date__c = nearestFutureDate;
                        }
                        toCommit = true;
                        oppListNonSurveyExist.add(opp);
                    }
                }
            }
            if(toCommit){
                UTL_ExecutionControl.stopTriggerExecution = true;
                Database.SaveResult[] sr = Database.update(oppListNonSurveyExist, false);
                for(Integer i = 0; i < sr.size(); i++) {
                    Id oppId = oppListNonSurveyExist.get(i).Id;
                    if(!sr[i].isSuccess()) {
                        String msgStr = null;
                        Client_Sat_Survey__c cs = oppIdToSurveyMap.get(oppId);
                        Database.Error[] err = sr[i].getErrors();
                        cs.addError(err[0].getMessage());
                    }
                }
                UTL_ExecutionControl.stopTriggerExecution = false;
            }
        }
    }
    
    /**
    * This method is used to restrict edit access
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */
    public static void validateSurveyLocked(List<Client_Sat_Survey__c> newSurveyList, Map<Id,Client_Sat_Survey__c> oldMap) {
        User userDetail = new SLT_User().selectByUserId(new Set<Id>{UserInfo.getUserId()}, new Set<String>{'ID', 'EmployeeNumber', 'Profile.Name'}).values()[0];
        CS_Config__c csConfig = CS_Config__c.getInstance();
        List<Client_Sat_Survey__c> csList = new List<Client_Sat_Survey__c>();

        if(userDetail.Profile.Name != null && !userDetail.Profile.Name.contains(CON_CRM.SYSTEM_ADMIN_PROFILE) && !(csConfig != null && csConfig.Is_Admin_User__c )){
            for(Client_Sat_Survey__c cs : newSurveyList){
                if(!((cs.Survey_EM_EmployeeNumber__c!= null && cs.Survey_EM_EmployeeNumber__c.isNumeric() && userDetail.EmployeeNumber.equals(cs.Survey_EM_EmployeeNumber__c) ) ||(cs.Survey_PIC_EmployeeNumber__c!= null && cs.Survey_PIC_EmployeeNumber__c.isNumeric() && userDetail.EmployeeNumber.equals(cs.Survey_PIC_EmployeeNumber__c)) || (userDetail.id == cs.Opportunity_Owner__c))){
                    cs.addError(CON_Qualtrics.NOT_ALLOWED_TO_MODIFY_RECORD);
                  }else if(oldMap.get(cs.id).Survey_Initiation_Status__c == 'Survey Declined, Pending Mgr Approval' || oldMap.get(cs.id).Survey_Initiation_Status__c == 'Survey Delayed, Pending Approval'){
                      cs.addError(CON_Qualtrics.RECORD_PENDING_FOR_APPROVAL);
                  }
            }
        }
    }
}