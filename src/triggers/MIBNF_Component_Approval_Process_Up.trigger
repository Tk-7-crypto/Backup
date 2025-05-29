//  Trigger to complete approval workflow for BNFs which have been updated
//  by Informatica interface after IDOC has been created and fed into SAP
//  April 1, 2011 - Anjali Salecha - Capture Approval Logs whenever the BNF status is modified.

trigger MIBNF_Component_Approval_Process_Up on MIBNF_Component__c (after update)
{
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        Map<Id,MIBNF_Component__c> BNF_Map = new Map<Id,MIBNF_Component__c>([select Id,BNF_Status__c,SAP_SD_Error_Message__c,
                                                                             SAP_SD_Error_Group__c,RA_Rejection_Count__c,Rejection_Reasons_Multi__c, Comp_Revenue_Analyst__r.owner.type from MIBNF_Component__c 
                                                                             where Id in :Trigger.newMap.keySet()]);
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
        for (MIBNF_Component__c BNF:BNF_Map.values())
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
        List<MIBNF_Approval_Log__c> approvalLogList = new List<MIBNF_Approval_Log__c> ();
        List<MIBNF_Rejection_Reason__c> RejectionReasonList = new List<MIBNF_Rejection_Reason__c>();  // Added By : Himanshu Parashar : 30 Nov 2012 : MIBNF Rejection reasons changes
        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        if(bnfSetting.MIBNF_Submission_Template_ID__c != null){
           emailTemplates = [Select id from EmailTemplate where id =:bnfSetting.MIBNF_Submission_Template_ID__c];        
        }
            // Check if the BNF status has been changed
        for(MIBNF_Component__c bnf : Trigger.new) {
            MIBNF_Component__c oldBNF = Trigger.oldMap.get(bnf.id);
            
            //in this case BNF status has been changed
            if(oldBNF.BNF_Status__c != bnf.BNF_Status__c ) {
                
                // updated by dheeraj kumar 13 April 2017
                if((bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED')|| bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED')) && BNF_Map.get(bnf.id).Comp_Revenue_Analyst__r.owner.type == 'Queue') {
                    // send email
                    System.debug('Sending mail to bnf Current RA Email'+ BNF.id);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                    
                    String[] toAddresses = new String[] {bnf.Current_RA_Email__c};  
                        mail.setToAddresses(toAddresses);
                    mail.setTargetObjectId(UserInfo.getUserId());
                    mail.setSaveAsActivity(false);
                    mail.setTreatTargetObjectAsRecipient(false);
                    String EMAIL_TEMPLATE_NAME = 'MIBNF Approvals submitted_notification';
                    if(emailTemplates != null && emailTemplates.size()>0 ){
                        mail.setTemplateId(emailTemplates[0].id);
                        mail.setWhatId(bnf.id);
                        //if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        //}
                    }
                }
                //create the new Log object here
                Boolean ReSubmission = (bnf.RA_Rejection_Count__c > 0 ? true:false);
                Id Submitter = null;
                MIBNF_Approval_Log__c logObj = new MIBNF_Approval_Log__c( BNF_Status__c = bnf.BNF_Status__c,
                                                                         BNF__c = bnf.id, Re_Submission__c=ReSubmission);
                // Issue-10712 updated on 11 April 2017
                // updated   Issue-10024 start 24 Feb 2017
                // updated by dheeraj Kumar 20 April 2017
                //if(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') == bnf.BNF_Status__c || MDM_Defines.BnfStatus_Map.get('RA_REJECTED') == bnf.BNF_Status__c  || MDM_Defines.BnfStatus_Map.get('REASSIGNED') == bnf.BNF_Status__c) {
                if(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') == bnf.BNF_Status__c || MDM_Defines.BnfStatus_Map.get('RA_REJECTED') ==  bnf.BNF_Status__c) {
                    if(oldBNF.First_RA__C != null) {
                        logObj.Revenue_Analyst__c = oldBNF.First_RA__C;
                    } else {
                        logObj.Revenue_Analyst__c = oldBNF.Comp_Revenue_Analyst__c; 
                    }
                } else {
                    logObj.Revenue_Analyst__c = oldBNF.Comp_Revenue_Analyst__c; 
                }
                
                // updated   Issue-10024 end 24 Feb 2017
                if(MDM_Defines.BnfStatus_Map.get('SUBMITTED') == bnf.BNF_Status__c ) {
                    logObj.Submitter__c = UserInfo.getUserId();
                } else {
                    
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
                if (bnf.Rejection_Reasons_Multi__c != null && (bnf.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('REJECTED') ||
                                                               bnf.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('LO_REJECTED') || bnf.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('RA_REJECTED')
                                                              ))
                {
                    //String FormattedRejectionReasons = bnf.Rejection_Reasons__c.replace('[','');
                    //FormattedRejectionReasons = FormattedRejectionReasons.replace(']','');            
                    List<String> RejectionReasonMultiSelect = bnf.Rejection_Reasons_Multi__c.split('\\|');
                    for (String Reason:RejectionReasonMultiSelect)
                    {
                        RejectionReasonList.add(new MIBNF_Rejection_Reason__c(BNF__c=bnf.Id,Rejection_Reason__c=Reason));
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
                    
                    //Added By : Himanshu Parashar : 30 Nov 2012 : Rejection reason changes
                    if (RejectionReasonList.size() > 0)   
                    {
                        Map <Id,Id>BNF_Approval_Log_Id_Map = new Map<Id,Id>();
                        for (MIBNF_Approval_Log__c log:approvalLogList)
                        {
                            BNF_Approval_Log_Id_Map.put(log.BNF__c,log.Id);
                        }
                        for (MIBNF_Rejection_Reason__c B:RejectionReasonList)
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
                for(MIBNF_Approval_Log__c al :approvalLogList) {
                    htmlBodyStr += '<tr><td>'+ al.BNF_Status__c + '</td><td>'+ al.BNF__c + '</td><td>'+ al.Re_Submission__c + '</td><td>'+ al.Submitter__c + '</td><td>'+ al.Approver__c + '</td><td>'+ al.Comments__c + '</td><td>'+ al.Rejection_Reason__c + '</td></tr>' ;
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
                String[] toAddresses = new String[] {'sduncan@uk.imshealth.com.qi.devxab'};           
                    mail.setToAddresses(toAddresses);
                // mail.setOrgWideEmailAddressId('0D270000000PAzY');
                mail.setSubject('Error creating MIBNF approval Logs');
                mail.setHtmlBody('<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500">' + 
                                 '<tr><td>*** Error creating BNF approval Logs ***<br>' + 
                                 '<br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5">' + 
                                 '<tr><td>Error Mesage:</td><td>' + ex.getMessage() +'</td></tr>' + 
                                 '</table></p>' + 
                                 '<tr><td><table>' + 
                                 '<th>Status</th><th>MI BNF</th><th>Is Resubmission</th><th>Submitter</th><th>Approver</th><th>Comments</th><th>Rejection Reason</th>' +
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
    }
}