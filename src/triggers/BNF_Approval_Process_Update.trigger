//  Trigger to complete approval workflow for BNFs which have been updated
//  by Informatica interface after IDOC has been created and fed into SAP
//  April 1, 2011 - Anjali Salecha - Capture Approval Logs whenever the BNF status is modified.
trigger BNF_Approval_Process_Update on BNF2__c (after update)
{
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_BNF_Trigger__c) {
        Map<Id,BNF2__c> BNF_Map = new Map<Id,BNF2__c>([select Id,BNF_Status__c,SAP_SD_Error_Message__c,
                                                       SAP_SD_Error_Group__c,RA_Rejection_Count__c,Rejection_Reasons_Multi__c, Revenue_Analyst__r.owner.type
                                                       from BNF2__c 
                                                       where Id in :Trigger.newMap.keySet()]);
        Set<Id> opportunityIdsSetForBNF = new Set<Id>();
        for(BNF2__c bnfRecord : Trigger.new){
            if(bnfRecord.BNF_Status__c != Trigger.oldMap.get(bnfRecord.id).BNF_Status__c) {
                opportunityIdsSetForBNF.add(bnfRecord.Opportunity__c);
            }
        }
        if(opportunityIdsSetForBNF.size() > 0) {
            Map<Id,Opportunity> opportunityToUpdateMap = new Map<Id,Opportunity>();
            Set<String> bnfFieldsSet = new Set<String>{'Id','BNF_Status__c', 'Revenue_Analyst_del__c'};
                for(Integer i=2;i<=10;i++){
                    bnfFieldsSet.add('Revenue_Analyst_User_'+i+'__c');
                }
            Map<Id, Opportunity> opportunityMap = new SLT_Opportunity().selectByIdWithBNF(opportunityIdsSetForBNF, new Set<String>{'Id'},bnfFieldsSet);
            Map<Id,Set<String>> oppIdToIdMap = new Map<Id,Set<String>>();
            Set<Id> revenueAnalaystUserIdsSet = new Set<Id>();
            for(Id mapId : opportunityMap.keySet()){
                Opportunity currentOpp = opportunityMap.get(mapId);
                List<Sobject> sobjList = currentOpp.getSObjects(CON_CRM.OPPORTUNITY_BNF_RELATIONSHIP);
                List<BNF2__c> bnfRecordsList = new List<BNF2__c>();
                if(sobjList != null && sobjList.size() > 0){
                    bnfRecordsList = (List<BNF2__c>)sobjList;
                }
                if(bnfRecordsList.size() > 0){
                    Boolean isAnyBnfApproved = false;
                    Boolean isAnyBnfSubmitted = false;
                    Integer approvedBnfCount = 0;
                    Set<String> bnfRecordsApprovalList = new Set<String>();
                    for(BNF2__c bnfRecord : bnfRecordsList ){
                        if(bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED')){
                            isAnyBnfApproved = true;
                            approvedBnfCount++;
                        }else if(bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CREATED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING')  || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_PENDING') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED')){
                            isAnyBnfSubmitted = true;
                            if(Trigger.newMap.containsKey(bnfRecord.Id)){
                                if(bnfRecord.get('Revenue_Analyst_del__c') != null && bnfRecord.get('Revenue_Analyst_del__c') != ''){
                                    bnfRecordsApprovalList.add(String.valueOf(bnfRecord.get('Revenue_Analyst_del__c')));
                                    revenueAnalaystUserIdsSet.add(String.valueOf(bnfRecord.get('Revenue_Analyst_del__c')));
                                }
                                for(Integer i=2;i<=10;i++){
                                    if(bnfRecord.get('Revenue_Analyst_User_'+i+'__c') != null && bnfRecord.get('Revenue_Analyst_User_'+i+'__c') != ''){
                                        bnfRecordsApprovalList.add(String.valueOf(bnfRecord.get('Revenue_Analyst_User_'+i+'__c')));
                                        revenueAnalaystUserIdsSet.add(String.valueOf(bnfRecord.get('Revenue_Analyst_User_'+i+'__c')));
                                    }
                                }
                            }
                        }
                    }
                    currentOpp.Is_Any_BNF_Approved__c = isAnyBnfApproved;
                    currentOpp.Is_Any_BNF_Submitted__c = isAnyBnfSubmitted;
                    currentOpp.Approved_BNF_Count__c = approvedBnfCount;
                    if(bnfRecordsApprovalList.size() > 0){
                        oppIdToIdMap.put(currentOpp.Id, bnfRecordsApprovalList);
                    }
                    opportunityToUpdateMap.put(currentOpp.Id,currentOpp);
                }
            }
            if(oppIdToIdMap.size() > 0){
                Map<Id, User> reveneuAnayalsytUsersMap = new SLT_User().selectByUserId(revenueAnalaystUserIdsSet,new Set<String>{'Id','LI_User_Id__c'});
                for(Id oppId : oppIdToIdMap.keySet()){
                    Opportunity currentOpp = opportunityMap.get(oppId);
                    Set<String> raUsersId = new Set<String>();
                    for(String raId : oppIdToIdMap.get(oppId)){
                        if(reveneuAnayalsytUsersMap.containsKey(raId)){
                            raUsersId.add(reveneuAnayalsytUsersMap.get(raId).LI_User_Id__c);
                        }
                    }
                    currentOpp.Current_Approvers__c = JSON.serialize(raUsersId);  
                    opportunityToUpdateMap.put(currentOpp.Id,currentOpp);
                }
            }
            if(opportunityToUpdateMap.size() > 0){
                CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
                CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
                CON_CRM.updateSkipValidation = true;
                update opportunityToUpdateMap.values();
                CON_CRM.updateSkipValidation = false;
            }
        }
        Map<Id,ProcessInstanceWorkitem> ProcessInstanceWorkitem_Map = new Map<Id,ProcessInstanceWorkitem>();
        List<ProcessInstanceWorkitem> workItemList = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId,
                                                      ProcessInstance.CreatedById, ActorId 
                                                      from ProcessInstanceWorkitem  where 
                                                      ProcessInstance.Status = 'Pending' and 
                                                      ProcessInstance.TargetObjectId in :Trigger.newMap.keySet()];
        
        for (ProcessInstanceWorkitem  P: workItemList )
        {
            ProcessInstanceWorkitem_Map.put(P.ProcessInstance.TargetObjectId,P);
        }   
        
        system.debug('BNF Map size: '+ BNF_Map.size().format());
        system.debug('ProcessInstanceWorkitem_Map = ' + ProcessInstanceWorkitem_Map);
        for (BNF2__c BNF:BNF_Map.values())
        {           
            //  Update approval process when status is changed
            if (BNF_Map.get(BNF.Id).BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') && Trigger.oldMap.get(BNF.ID).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') || 
                BNF_Map.get(BNF.Id).BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED') && Trigger.oldMap.get(BNF.ID).BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED'))      
            {
                if (ProcessInstanceWorkitem_Map.containsKey(BNF.Id))
                {
                    system.debug ('ProcessInstance Id (1): ' + ProcessInstanceWorkitem_Map.get(BNF.Id) );
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments(BNF.SAP_SD_Error_Message__c);
                    req2.setAction('Reject');
                    req2.setWorkitemId(ProcessInstanceWorkitem_Map.get(BNF.Id).Id);                             
                    Approval.ProcessResult result2 = Approval.process(req2);
                }
            }
            else if (BNF_Map.get(BNF.Id).BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED'))      
            {
                if (ProcessInstanceWorkitem_Map.containsKey(BNF.Id))
                {
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Order/Contract created in SAP');
                    req2.setAction('Approve');
                    req2.setWorkitemId(ProcessInstanceWorkitem_Map.get(BNF.Id).Id);
                    // Submit the request for approval
                    Approval.ProcessResult result2 = Approval.process(req2);
                }
            }
        }
        
        //query all workitems
        List<ProcessInstanceWorkitem> piWorkItemList = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId,
                                                        ProcessInstance.CreatedById, ActorId, ProcessInstance.Status 
                                                        from ProcessInstanceWorkitem  where  
                                                        ProcessInstance.TargetObjectId in : Trigger.newMap.keySet() ];
        
        //map of BNf id and its pending work item
        Map<Id,ProcessInstanceWorkItem> BNFWorkItemMap = new Map<Id,ProcessInstanceWorkItem> ();
        
        for(ProcessInstanceWorkitem piw : piWorkItemList) {
            BNFWorkItemMap.put(piw.ProcessInstance.TargetObjectId, piw);
        }
        
        //Capture approval logs here - begin
        //List of new Log object to be inserted
        List<BNF_Approval_Log__c> approvalLogList = new List<BNF_Approval_Log__c> ();
        List<BNF_Rejection_Reason__c> RejectionReasonList = new List<BNF_Rejection_Reason__c>();
        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        if(bnfSetting.BNF_Submission_Template_ID__c != null){
            emailTemplates = [Select id from EmailTemplate where id =:bnfSetting.BNF_Submission_Template_ID__c];
        }
        // Check if the BNF status has been changed
        for(BNF2__c bnf : Trigger.new) {
            BNF2__c oldBNF = Trigger.oldMap.get(bnf.id);
            
            //in this case BNF status has been changed
            if(oldBNF.BNF_Status__c != bnf.BNF_Status__c ) {
                // updated by dheeraj kumar 13 April 2017
                if((bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') ||bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') ||  bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') ||  bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED')) && BNF_Map.get(bnf.id).Revenue_Analyst__r.owner.type == 'Queue')  {
                    // send email
                    System.debug('Sending mail to bnf Current RA Email'+ BNF.id);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                    
                    String[] toAddresses = new String[] {bnf.Current_RA_Email__c};
                    mail.setToAddresses(toAddresses);
                    mail.setTargetObjectId(UserInfo.getUserId());
                    mail.setSaveAsActivity(false);
                    mail.setTreatTargetObjectAsRecipient(false);
                    String EMAIL_TEMPLATE_NAME = 'MDM BNF Approvals: New BNF record submitted notify vf';
                    if(emailTemplates != null && emailTemplates.size()>0){
                        mail.setTemplateId(emailTemplates[0].id);
                        mail.setWhatId(bnf.id);
                        //if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        //}
                    }
                }
                
                
                //create the new Log object here
                
                Boolean ReSubmission = (oldBNF.RA_Rejection_Count__c > 0 ? true:false);
                Id Submitter = null;
                BNF_Approval_Log__c logObj = new BNF_Approval_Log__c( BNF_Status__c = bnf.BNF_Status__c,
                                                                     Purchase_BNF__c = bnf.id, Re_Submission__c=ReSubmission);
                system.debug('BNF Status is = ' + bnf.BNF_Status__c);
                // updated   Issue-10024 start 24 Feb 2017
                // Updated for Issue-10712 
                //if(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') == bnf.BNF_Status__c || MDM_Defines.BnfStatus_Map.get('RA_REJECTED') == bnf.BNF_Status__c || MDM_Defines.BnfStatus_Map.get('REASSIGNED') == bnf.BNF_Status__c) {
                if(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') == bnf.BNF_Status__c || MDM_Defines.BnfStatus_Map.get('RA_REJECTED') == bnf.BNF_Status__c) {
                    if(oldBNF.First_RA__C != null) {
                        logObj.Revenue_Analyst__c = oldBNF.First_RA__C;
                    } else {
                        logObj.Revenue_Analyst__c = oldBNF.Revenue_Analyst__c;
                    }
                    // added by dheeraj kumar 11 April 2017
                } else {
                    logObj.Revenue_Analyst__c = oldBNF.Revenue_Analyst__c;
                }
                // updated  Issue-10024 end 24 Feb 2017. 
                if(MDM_Defines.BnfStatus_Map.get('SUBMITTED') == bnf.BNF_Status__c ) {
                    logObj.Submitter__c = UserInfo.getUserId();
                } else {
                    System.debug('inside else if block');
                    ProcessInstanceWorkitem workItem = BNFWorkItemMap.get(bnf.id);
                    System.debug('workItem = ' + workItem );
                    if( workItem != null ) {
                        system.debug('workItem.ProcessInstance.CreatedById = ' + workItem.ProcessInstance.CreatedById);
                        logObj.Submitter__c = workItem.ProcessInstance.CreatedById;
                    }
                    logObj.Approver__c = UserInfo.getUserId();
                    logObj.Comments__c=bnf.SAP_SD_Error_Message__c;
                    logObj.Rejection_Reasons_Multi__c=bnf.Rejection_Reasons_Multi__c;
                } 
                approvalLogList.add(logObj);
                
                // update by Himanshu parashar : 11 dec 2012 : MIS Issue -01405
                // update by Himanshu parashar : 13 sep 2013 : MIS Issue -02741
                if (bnf.Rejection_Reasons_Multi__c != null && (bnf.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('REJECTED') ||
                                                               bnf.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('LO_REJECTED') || bnf.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('RA_REJECTED')
                                                              ))
                {
                    //String FormattedRejectionReasons = bnf.Rejection_Reasons_Multi__c.replace('[','');
                    //FormattedRejectionReasons = FormattedRejectionReasons.replace(']','');            
                    List<String> RejectionReasonMultiSelect = bnf.Rejection_Reasons_Multi__c.split('\\|');
                    for (String Reason:RejectionReasonMultiSelect)
                    {
                        RejectionReasonList.add(new BNF_Rejection_Reason__c(BNF__c=bnf.Id,Rejection_Reason__c=Reason));
                    }
                }
            }        
        }
        
        if(approvalLogList.size() > 0 ){
            try{
                
                if(!MDM_Defines.StopBNFTriggerExecution)
                {
                    insert approvalLogList;
                    MDM_Defines.StopBNFTriggerExecution=true;  
                    
                    if (RejectionReasonList.size() > 0)
                    {
                        Map <Id,Id>BNF_Approval_Log_Id_Map = new Map<Id,Id>();
                        for (BNF_Approval_Log__c log:approvalLogList)
                        {
                            BNF_Approval_Log_Id_Map.put(log.Purchase_BNF__c,log.Id);
                        }
                        for (BNF_Rejection_Reason__c B:RejectionReasonList)
                        {
                            B.BNF_Approval_Log__c = BNF_Approval_Log_Id_Map.get(B.BNF__c);
                        }
                        insert RejectionReasonList;
                        
                    }
                    
                    
                }
                
            } catch(Exception ex) {
                system.debug('error creating approval logs' + ex.getmessage());
                //send an email in case of exception
                String htmlBodyStr = '';
                for(BNF_Approval_Log__c al :approvalLogList) {
                    htmlBodyStr += '<tr><td>'+ al.BNF_Status__c + '</td><td>'+ al.Purchase_BNF__c + '</td><td>'+ al.Re_Submission__c + '</td><td>'+ al.Submitter__c + '</td><td>'+ al.Approver__c + '</td><td>'+ al.Comments__c + '</td><td>'+ al.Rejection_Reason__c + '</td></tr>' ;
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
                String[] toAddresses = new String[] {'sduncan@uk.imshealth.com.qi.devxab'};           
                    mail.setToAddresses(toAddresses);
                // mail.setOrgWideEmailAddressId('0D270000000PAzY');
                mail.setSubject('Error creating BNF approval Logs');
                mail.setHtmlBody('<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500">' + 
                                 '<tr><td>*** Error creating BNF approval Logs ***<br>' + 
                                 '<br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5">' + 
                                 '<tr><td>Error Mesage:</td><td>' + ex.getMessage() +'</td></tr>' + 
                                 '</table></p>' + 
                                 '<tr><td><table>' + 
                                 '<th>Status</th><th>Purchase BNF</th><th>Is Resubmission</th><th>Submitter</th><th>Approver</th><th>Comments</th><th>Rejection Reason</th>' +
                                 //'<tr><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>' +
                                 htmlBodyStr + 
                                 '</table></td></tr>' + 
                                 
                                 '</td></tr>' + 
                                 '</table>');
                if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
            
        }
        
        //Added By kapil Jain on 03/Oct/2013 against the ER-0122 ----------------  START HERE 
        Map<ID,BNF2__c> oldBnfMap = Trigger.oldMap;
        Map<ID,BNF2__c> newBnfMap = Trigger.newMap;
        set<ID> opportunityIdSet = new set<ID>(); 
        
        for(ID bnfId:newBnfMap.keySet())
        {
            BNF2__c newBnf = newBnfMap.get(bnfId);
            BNF2__c oldBnf = oldBnfMap.get(bnfId);
            
            if(newBnf.BNF_Status__c != oldBnf.BNF_Status__c && newBnf.BNF_Status__c == 'SAP Contract Confirmed')
                opportunityIdSet.add(newBnf.Opportunity__c);
        }
        
        if(opportunityIdSet.size() > 0){
            //Psa_BatchToReIntegrateFailedPods.reIntegrateFailedPoDs(opportunityIdSet);
        }
        //Added By kapil Jain on 03,Oct2013 against the ER-0122 ----------------  END HERE
    }
}