global class BCH_CSM_AutoDeleteEmailMessage implements Database.Batchable<sObject>{
    global String[] errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> recordType = new List<String>{'ActivityPlan','RandDCase','VirtualTrialsCase'};
        Integer PIILastNDaysValue  = 10;
        CSM_Case_Details_Global_Setting__c customSetting = CSM_Case_Details_Global_Setting__c.getInstance('AutoDeleteEmailMessage_PII_LastNDays');
        if (customSetting != null && customSetting.Number__c != null) {
            PIILastNDaysValue = customSetting.Number__c.intValue();
        }
        String query = 'select id,Subject,Parent.LastModifiedDate,PII_Data_Identified__c from EmailMessage where ParentId != null and ((parent.isClosed = true and parent.RecordTypeName__c = \'ConnectedDevicePatient\' and parent.ClosedDate != null and parent.ClosedDate < LAST_N_DAYS:1) OR (((Parent.Origin=\'Voicemail\' and parent.Los__c !=\'Sandoz Lab\' and parent.Los__c !=\'Sandoz Feedback\' and parent.LastModifiedDate <=LAST_N_DAYS:1) or PII_Data_Identified__c=true) and parent.RecordTypeName__c in :recordType and parent.status !=\'New\' and parent.LastModifiedDate = LAST_N_DAYS:' + PIILastNDaysValue + ' ))';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EmailMessage> ems){
        List<Id> emIds = new List<Id>();
        Map<Id,boolean> emIdMap = new Map<Id,boolean>();
        List<Activity__c> actUpd = new List<Activity__c>();
        List<Activity__c> actDel = new List<Activity__c>();
        for(EmailMessage e : ems){
            if(e.PII_Data_Identified__c){
                emIdMap.put(e.Id,e.PII_Data_Identified__c);
            }
            emIds.add(e.Id);
        }
        List<Activity__c> actList = Database.query('select id,Description__c,EmailMessageId__c from Activity__c where EmailMessageId__c in :emIds');
        try {
            if(!ems.isEmpty()){
                delete ems;
            }
            if(!actList.isEmpty()){
                for(Activity__c a : actList){
                    if(emIdMap.containsKey(a.EmailMessageId__c)){
                        a.Description__c ='This content has been deleted by PII batch process';
                        a.EmailMessageId__c = null;
                        actUpd.add(a);
                    }else{
                        actDel.add(a);
                    }
                }
                if(!actUpd.isEmpty()){
                    update actUpd;
                }
                if(!actDel.isEmpty()){
                    delete actDel;
                }
            }
        } catch(Exception e) {
            errors.add(e.getLineNumber()+' - ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        if(!errors.isEmpty()) {
            string allstring = string.join(errors,',');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during BCH_CSM_AutoDeleteEmailMessage batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(allstring);
            
            try{
                Messaging.sendEmail(new Messaging.Email[] { mail });
            } catch(Exception e) {
                
            }
        }

    }
    
}