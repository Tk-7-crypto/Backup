global class BCH_TPA_Commercial_Review implements Database.Batchable<sObject>, Database.Stateful{
    List<Messaging.SingleEmailMessage> mailListToBeSend;
    List<TPA_Commercial_Review__c> tpaCommercialReviewList = new List<TPA_Commercial_Review__c>();
    Boolean BatchForExpire = false;
    public Boolean includeTestDataOnly{
        get{
            if(includeTestDataOnly == null) {
                includeTestDataOnly =  false;
            }
            return includeTestDataOnly;
        }
        set;
    } 
    
    global BCH_TPA_Commercial_Review(){
    }

    global BCH_TPA_Commercial_Review(Boolean forExpire){
        BatchForExpire = forExpire;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date todayDate = System.now().date();
        Date preDay = System.now().date().addDays(-1);
        String query = '';
        if(!BatchForExpire) {
            query = 'Select Id,vendor_language__c,TP_Processor_Email__c,TPA_Assigned_TP_Processor__r.Initials__c,TPA_Assigned_TP_Processor__r.Is_Active__c,Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c,Request_Status__c,In_Pending_IQVIA_Review_of_Voided_Env__c,(Select Id From Purposes__r),(Select Id, Status__c,Receiver_s_Email__c,TP_US_Email__c,TP_Country_Email__c,Action_Needed_By__c,Manual_Review_Reason__c, Is_ReviewForm_Acknowledged__c,CreatedDate,Last_Reminder_Sent_Date__c,Action__c from TPA_Commercial_Reviews__r) from TPA_Request__c where Request_Status__c in (\'Pending IQVIA Review of Voided Envelope\',\'Awaiting Account Mgmt Communication\',\'' + UTL_TPA.AWAITING_CLIENT_CONFIRMATION + '\',\'Awaiting Client Modification\',\'Awaiting Final Review\',\'In Review By IQVIA\',\'Pending Vendor AMA Fee Acknowledgement\',\'Pending - Vendor Declined AMA Fees\',\'TPA Approved Awaiting AMA Approval\',\'Pending Vendor Response on Data Destruction from Prior TPAs\',\'Hold for TPA non-compliance\') ';
        }
        else{
            query = 'select id,Commercial_Owner_Email__c, Temporary_Commercial_Owner_Email__c, Out_of_Office_Leave_Start_Date__c,Out_of_Office_Leave_End_Date__c from TPA_Assigned_TP_Processor__c where Is_Commercial_Owner__c = true and Out_of_Office_Leave_Start_Date__c <= :todayDate and Out_of_Office_Leave_End_Date__c =  :preDay';
        }
        if(includeTestDataOnly && !BatchForExpire){
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objList){
        Set<Id> PurIds;
        for(sObject sObj : objList){
            if(!BatchForExpire) {
            PurIds  = new Set<Id>();
            TPA_Request__c reqObj = (TPA_Request__c)sObj;
            for(TPA_Purpose__c purpose : reqObj.Purposes__r){
                PurIds.add(purpose.Id);
            }
            List<TPA_Commercial_Review__c> tcrObjs = new List<TPA_Commercial_Review__c>();
            List<TPA_Commercial_Review__c> tcrObjsSec = new List<TPA_Commercial_Review__c>();
            List<TPA_Commercial_Review__c> tcrObjsForSecReviwe = new List<TPA_Commercial_Review__c>();
            List<TPA_Commercial_Review__c> tcrObjsForAddSecReviwe = new List<TPA_Commercial_Review__c>();
            
            for(TPA_Commercial_Review__c tcrObj : reqObj.TPA_Commercial_Reviews__r){
                Date createdDate = Date.newInstance(tcrObj.CreatedDate.year(), tcrObj.CreatedDate.month(), tcrObj.CreatedDate.day());
                Date reminderDate = tcrObj.Last_Reminder_Sent_Date__c;
                Integer daysDiff = 0;
                if(reminderDate != null){
                    daysDiff = reminderDate.daysBetween(Date.today());
                }
                else{
                    daysDiff = createdDate.daysBetween(Date.today());
                }
                if( ((!tcrObj.Is_ReviewForm_Acknowledged__c && tcrObj.status__c == 'Awaiting Review') || tcrObj.action__c == 'Under Validation')  && tcrObj.Status__c !='Combination Approved' && tcrObj.Status__c !='Combination Approved and Future Approved' && tcrObj.Action__c !='Complete' && ( ( daysDiff >= 2 && Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4 ) || Test.isRunningTest() )){
                    tcrObj.Last_Reminder_Sent_Date__c = Date.today();
                    if(tcrObj.Manual_Review_Reason__c == 'Offering Requires Secondary Commercial Review' || tcrObj.Manual_Review_Reason__c.contains('Vendor - Use Secondary Review by')
                        || tcrObj.Manual_Review_Reason__c.contains('Vendor - Use - Offering Secondary Review by')){
                        tcrObjsSec.add(tcrObj);
                    }
                    else if(tcrObj.Manual_Review_Reason__c == 'Vendor Requires Secondary Review') {
                        tcrObjsForSecReviwe.add(tcrObj);
                    }
                    else if(UTL_TPA.isManualReviewAddHoc(tcrObj.Manual_Review_Reason__c)){
                        tcrObjsForAddSecReviwe.add(tcrObj);
                    }
                    else {
                        tcrObjs.add(tcrObj);
                    }
                }   
            }
            if(tcrObjs.size() > 0 || tcrObjsSec.size() > 0 || tcrObjsForSecReviwe.size() > 0 || tcrObjsForAddSecReviwe.size() > 0){
                SRV_TPA_TPARequest.tpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqObj.Id);
                SRV_TPA_TPARequest.isReminderForCommercialOwner = true;
                if(!Test.isRunningTest() && tcrObjs.size() > 0){
                    SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
                }
                tpaCommercialReviewList.addAll(tcrObjs);
                if(tcrObjsSec.size() > 0){
                    SRV_TPA_TPARequest.reminderSecOfferingMailRequired = true;
                }
                if(tcrObjsSec.size() > 0 || tcrObjsForSecReviwe.size() > 0 || tcrObjsForAddSecReviwe.size() > 0){
                    SRV_TPA_TPARequest.isSecComReview = true;
                    if(tcrObjsForAddSecReviwe.size() > 0){
                        SRV_TPA_TPARequest.sendLegalReviewMail = true;
                    }
                    if(!Test.isRunningTest()){
                        SRV_TPA_TPARequest.sendApprovalMailToCommericialOwnerForBulk();
                    }
                }
                SRV_TPA_TPARequest.isReminderForCommercialOwner = false;
                SRV_TPA_TPARequest.isSecComReview = false;
                SRV_TPA_TPARequest.sendLegalReviewMail = false;
                tpaCommercialReviewList.addAll(tcrObjsSec);
                tpaCommercialReviewList.addAll(tcrObjsForSecReviwe);
                tpaCommercialReviewList.addAll(tcrObjsForAddSecReviwe);
            }
            if(reqObj.Request_Status__c == 'Pending IQVIA Review of Voided Envelope' && reqObj.In_Pending_IQVIA_Review_of_Voided_Env__c != null){
                Date lastReminderDate = reqObj.In_Pending_IQVIA_Review_of_Voided_Env__c;
                Integer diff = reqObj.In_Pending_IQVIA_Review_of_Voided_Env__c.daysBetween(Date.today());
                if((Math.mod(diff,5) == 0 && Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4) || Test.isRunningTest()){
                    sendReminderToTPPRocessorAboutVoidedEnvelope(reqObj);
                }
            } 
        }   
        }
        if(objList != null && objList.size()> 0 && BatchForExpire) {
            sendExpirationMail(objList);
        }
        if(!BatchForExpire && tpaCommercialReviewList.size() > 0){
            update tpaCommercialReviewList;
            tpaCommercialReviewList = new List<TPA_Commercial_Review__c>();
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    public void sendReminderToTPPRocessorAboutVoidedEnvelope(TPA_Request__c reqObj){
        List<String> toAddress = new List<String>();
        String emailBody;
        String subjectText;
        if(reqObj.TP_Processor_Email__c != null) {
            toAddress.add(reqObj.TP_Processor_Email__c);
        }
        string vendorLanguage = (reqObj.vendor_language__c != null && reqObj.vendor_language__c != '') ? reqObj.vendor_language__c : 'English';
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Reminder to TP Pro of Void' + vendorLanguage).Translated_Template_Id__c;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        if(templateID != '' && templateID != null) {  
            try {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqObj.Id);
            } catch(Exception exp) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, exp.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + exp.getLineNumber() + ':::BCH_TPA_Commercial_Review:::sendReminderToTPPRocessorAboutVoidedEnvelope:::', reqObj.Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);    
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjectText = emailNotToSend.getSubject();
        }
        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            SRV_TPA_TPARequest.assignedTPProcessorName = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, null, 'SendEmail', null, reqObj.Id, null, subjectText, FALSE, emailBody, TRUE, TRUE, reqObj); 
        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
    }

    public static void sendExpirationMail(List<sObject> objList){
        String templateID;
        List<Workflow_Email_Record__c> lstEmailWorkflowToSend = new List<Workflow_Email_Record__c>();
        
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Temp Comm Owner Expiration email'+'English').Translated_Template_Id__c;

        for(sObject sObj : objList){
            toAddresses = new List<String>();
            ccAddresses = new List<String>();
            TPA_Assigned_TP_Processor__c assignedTPProcessorObj = (TPA_Assigned_TP_Processor__c)sobj;
            if(templateID != '' && templateID != null) {   
                if(assignedTPProcessorObj.Commercial_Owner_Email__c != null) {
                    ccAddresses.add(assignedTPProcessorObj.Commercial_Owner_Email__c);
                }
                if(assignedTPProcessorObj.Temporary_Commercial_Owner_Email__c != null) {
                    ccAddresses.add(assignedTPProcessorObj.Temporary_Commercial_Owner_Email__c);
                }
                
                try{
                    if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()){
                        System.debug('in Temp Comm Owner Expiration Email send: ');
                        Workflow_Email_Record__c objWorkFlowEmail = SRV_TPA_TPARequest.sendBulkEmailThroughWorkfloww(toAddresses, ccAddresses, 'SendEmail', templateID, assignedTPProcessorObj.Id, null, '', FALSE, '', False, False, null);
                        if(objWorkFlowEmail != null){
                            lstEmailWorkflowToSend.add(objWorkFlowEmail);
                        }
                    }
                }
                catch(Exception e){
                    System.debug('Email Failed: ' + e.getMessage());
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::BCH_TPA_Commercial_Review:::sendExpirationMail', assignedTPProcessorObj != null ? assignedTPProcessorObj.Id : ''));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                }
            }
        }

        if(lstEmailWorkflowToSend != null && lstEmailWorkflowToSend.size() > 0){
            try {
                insert lstEmailWorkflowToSend;
                System.debug('lstEmailWorkflowToSend inserted successfully');
            } catch(Exception e) {
                System.debug('lstEmailWorkflowToSend Following Exception Occue In IF---------> ' + e);
            }
        }


       
    }
    
}
