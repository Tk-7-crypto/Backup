global class BCH_TPA_Business_Rule_Notification implements Database.Batchable<sObject>,Database.Stateful {
    Date todayDate;
    public Boolean includeTestDataOnly {
		get {
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}

    global BCH_TPA_Business_Rule_Notification() {
         todayDate = Date.today();
         //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_Business_Rule_Notification');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //String query = 'Select Id, Name, TP_Processor_Email__c, TP_Processor_Name__c, Related_TPA_Request__c, data_access_end_date__c from TPA_Request__c where recordtype.name = \'cpc\' and related_tpa_request__c != null and Related_TPA_Request__r.Request_Status__c = \'In Review By IMS\' and Related_TPA_Request__r.Is_Submitted__c = true and Is_Potential_Vendor_Case__c = true and Service_Provider_Address__c != null and TP_Processor_Email__c != null and Id=\'a3S180000004LWJ\'';
        String query = 'Select Id, Name, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, TP_Processor_Name__c,  data_access_end_date__c from TPA_Request__c where  (Request_Status__c = \''+Label.TPA_In_Review_By_IMS_Status+'\' or Request_Status__c = \'' +Label.TPA_In_Review_By_IQVIA_Status+'\' ) and Is_Submitted__c = true and Is_Potential_Vendor_Case__c = true and Service_Provider_Address__c != null and TP_Processor_Email__c != null';
        if(includeTestDataOnly){
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }
        if(Test.isRunningTest())
            query += ' limit 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objList)
    {
        for(sobject sobj : objList)
        {
            TPA_Request__c agrObj = (TPA_Request__c)sobj;
            if(agrObj.data_access_end_date__c >= todayDate)
            {
                List<string> recipients = new List<string>();
                recipients.add(agrObj.TP_Processor_Email__c);
                if(TPA_Settings__c.getInstance().TPA_Batch_Mail_Ids__c != null)
                    for(string strObj: TPA_Settings__c.getInstance().TPA_Batch_Mail_Ids__c.split(','))
                        recipients.add(strObj);                    
                sendMail(agrObj, recipients, '');
            }            
        }
    }
    
    public void sendMail(TPA_Request__c reqObj, List<string> toRecipients, string mailSubject)
    {
        try
        {
            List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage(); 
            String preferredLanguage = 'English'; //To-Do: identify whether to use client language or vendor language here. as of now default language is english.
            //emailNotToSend.setTemplateId(UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Business Rule'+preferredLanguage).Translated_Template_Id__c);
            toRecipients.add('neha.bansal@metacube.com');
            String templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Business Rule'+preferredLanguage).Translated_Template_Id__c;
            String initials = '';
            String globalTPProcessorInitials = '';
            
            try
            {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, reqObj.Id);
            }
            catch(Exception e) 
            {
                System.debug('Email Failed: ' + e.getMessage());
            }
            
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setCharset('UTF-8');    
            emailToSend.setToAddresses(toRecipients);
            emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
            emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
            //emailToSend.setSubject(emailNotToSend.getSubject());
            if(reqObj.TPA_Assigned_TP_Processor__r.Is_Active__c){
                initials = reqObj.TPA_Assigned_TP_Processor__r.Initials__c;
            }
            if(reqObj.Co_Assigned_Global_TP_Processor__r.Is_Active__c){
                globalTPProcessorInitials = reqObj.Co_Assigned_Global_TP_Processor__r.Initials__c;
            }
            emailToSend.setSubject(SRV_TPA_TPARequest.setEmailInitials(initials, globalTPProcessorInitials, emailNotToSend.getSubject()));
            
            emailToSend.setTargetObjectId(UTL_TPA.emailTargetContactId);
            emailToSend.setTreatTargetObjectAsRecipient(false);
            emailToSend.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
            emailToSend.setSaveAsActivity(true); 
            msgListToBeSend.add(emailToSend);
            try
            {
                if(msgListToBeSend != null && msgListToBeSend.size() > 0 && UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) { 
                    Messaging.sendEmail(msgListToBeSend);
                }
            }
            catch(Exception e) 
            {
                System.debug('Email Failed: ' + e.getMessage());
            }
            
        }        
        catch(System.EmailException emlEx) 
        {
            System.debug('Email Failed: ' + emlEx);
        }
        catch(Exception e) 
        {
            System.debug('An exception occurred: ' + e.getMessage());
        }        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
}
