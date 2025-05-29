/**
* Author : Babita Dadarwal
* Name    : BCH_TPA_ManageDraftRequests
* Date   : 13 Feb 2017
* ER     : 3433
* Description : Class to manage In Draft requests.
*/

global class BCH_TPA_ManageDraftRequests implements Database.Batchable<sObject>, Database.Stateful {
    public Date todayDate;
    public Boolean includeTestDataOnly{
		get{
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}

    global BCH_TPA_ManageDraftRequests ()
    {
         //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_ManageDraftRequests');
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //Query all in draft requests
        string query = 'select Id, Name, CreatedDate, LastModifiedDate, ClientContact__r.Email, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Client_Language__c, Client_Address__c, Client_Address__r.Name, Client_First_Name__c, Data_Access_End_Date__c, ';
        query += 'Client_Address__r.TPAOtherEmailIds__c';
        query += ' from TPA_Request__c where Request_Status__c = \'Client Draft\' ';
        if(includeTestDataOnly){
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }
        
        if(Test.isRunningTest()){
            query += ' limit 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bC, List<sObject> objList)  {
        if(todayDate == null) {
            todayDate = Date.Today();
        }
        //List<TPA_Request__c> reqListToDelete = new List<TPA_Request__c>();
        List<TPA_Request__c> reqListToUpdate = new List<TPA_Request__c>();
        
        for(sobject sobj : objList) {
            TPA_Request__c requestObj = (TPA_Request__c)sobj;
            
            string query = 'select Id, Name, CreatedDate, LastModifiedDate, ClientContact__r.Email, Owner.Type, Owner.Email, Client_TPA_Representative_Email__c, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Client_Language__c, Client_Address__c, Client_Address__r.Name, Client_First_Name__c, Data_Access_End_Date__c, ';
            query += 'Client_Address__r.TPAOtherEmailIds__c, Client_Request_Submission__c'; 
            query += ' from TPA_Request__c where Request_Status__c = \'Client Draft\' and Id = \'' + requestObj.Id + '\'';            
            if(Test.isRunningTest()){
                query += ' limit 1';
            }
            List<sObject> sobjList = Database.query(query);
            if(sobjList == null || sobjList.size() == 0) {
                continue;
            }
            else {
                requestObj = (TPA_Request__c)sobjList[0];
            }
            
            DateTime CreatedDateTime = requestObj.LastModifiedDate; 
            DateTime ClientSubmission = requestObj.Client_Request_Submission__c;
            
            if(ClientSubmission.format('EEE') == 'Sat'){
                ClientSubmission = ClientSubmission.addDays(2);
            }else if(ClientSubmission.format('EEE') == 'Sun'){
                ClientSubmission = ClientSubmission.addDays(1);
            }
            
            CreatedDateTime = CreatedDateTime.addHours(requestObj.LastModifiedDate.hour()); 
            CreatedDateTime = CreatedDateTime.addMinutes(requestObj.LastModifiedDate.minute()); 
            CreatedDateTime = CreatedDateTime.addSeconds(requestObj.LastModifiedDate.second());
            Date createdDate = date.newinstance(CreatedDateTime.year(), CreatedDateTime.month(), CreatedDateTime.day());
            Integer dayDiff = createdDate.daysBetween(todayDate);
            
            system.debug('In TPA_Batch_ManageDraftRequests : sendMail() : requestObj.Name = ' + requestObj.Name + 'requestObj.CreatedDate = ' + requestObj.createdDate + 'CreatedDateTime = ' + CreatedDateTime + 'todayDate = ' + todayDate + 'dayDiff = ' + dayDiff);
            
            if(requestObj.Client_Address__c !=null && requestObj.Client_Address__r.Name.containsIgnoreCase('Test_'))
            {
                if(Test.isRunningTest()) {
                    sendMail(requestObj);
                    requestObj.Request_Status__c = 'Draft Closed';
                    //reqListToDelete.add(requestObj);
                    reqListToUpdate.add(requestObj);
                    SRV_TPA_TPARequest.sendClosedRequestMail(requestObj, false);
                    SRV_TPA_TPARequest.updateActivityHistory(requestObj.Id, 'Request Draft Closed', true);
                }
                if(dayDiff > 1) {
                    //reqListToDelete.add(requestObj);
                    requestObj.Request_Status__c = 'Draft Closed';
                    reqListToUpdate.add(requestObj);
                    SRV_TPA_TPARequest.sendClosedRequestMail(requestObj, false);
                    SRV_TPA_TPARequest.updateActivityHistory(requestObj.Id, 'Request Draft Closed', true);
                }
                else if(dayDiff == 0)  {
                    sendMail(requestObj);
                }
            }
            else {
                if(dayDiff > 45) {
                    //reqListToDelete.add(requestObj);
                    requestObj.Request_Status__c = 'Draft Closed';
                    reqListToUpdate.add(requestObj);
                    SRV_TPA_TPARequest.sendClosedRequestMail(requestObj, false);
                    SRV_TPA_TPARequest.updateActivityHistory(requestObj.Id, 'Request Draft Closed', true);
                }
                else if(Math.mod(ClientSubmission.date().daysBetween(Date.today()),7) == 0) {
                    sendMail(requestObj);
                }
            }
        }
        
        if(reqListToUpdate.size() > 0) {
            try {
                update reqListToUpdate;
            }
            catch(Exception e) {
                System.debug('Failed: In Draft Request Updation failed.' + e.getMessage());
            }
        }
    }
    
    public static void sendMail(TPA_Request__c request) {
        
        String subjText = '';
        String emailBody = '';
        List<String> toAddressesList = new List<String>();
        toAddressesList.add(request.ClientContact__r.Email);

        if(request.Client_TPA_Representative_Email__c != null && request.Client_TPA_Representative_Email__c != ''){
            toAddressesList.add(request.Client_TPA_Representative_Email__c);
        }

        if(request.Owner.Type != null && request.Owner.Type == 'Queue' && request.Owner.Email != null){
            toAddressesList.add(request.Owner.Email);
        }
        
        List<String> ccAddressesList = new List<String>();
        ccAddressesList.add(request.TP_Processor_Email__c);
        ccAddressesList = UTL_TPA_Multilingual.ccList(request.Client_Address__r.TPAOtherEmailIds__c, ccAddressesList);

        List<TPA_Contact__c> addContactsList = SRV_TPA_TPARequest.getContactsForRequest(request.id);
        
        for(TPA_Contact__c addContacts : addContactsList){
            ccAddressesList.add(addContacts.Email__c);
        }
        
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
		String emailType = 'Weekday Draft Reminder Mail';
        string clientLanguage = 'English';
        string templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get(emailType + clientLanguage).Translated_Template_Id__c;
        if(templateId != null) {        
            try {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, request.Id);
            } catch(Exception exp) {
            }
            emailBody = emailNotToSend.getHTMLBody();
            subjText = emailNotToSend.getSubject();
            
            Date submissionDate = request.Client_Request_Submission__c.date();
            
            submissionDate = submissionDate.addDays(45);
            
            emailBody = emailBody.replace('PORTAL_URL', '<div style="font-size:13px;font-family:arial;"><a href = \'' + UTL_TPA.TPA_ClientCOM_URL + '\'>Link to portal</a></div>');
            emailBody = emailBody.replace('DRAFT_CLOSE', submissionDate.format());
        }
        try{
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddressesList, ccAddressesList, 'inClientDraftNotification', null, request.Id, null, subjText, FALSE, emailBody, TRUE, TRUE, request);
        }catch(exception e){
            System.debug('WeekDay Draft TPA Request Mail Exception:' + e);
        }
       
    }
    
    global void finish(Database.BatchableContext bC)
    {
        
    }
}
