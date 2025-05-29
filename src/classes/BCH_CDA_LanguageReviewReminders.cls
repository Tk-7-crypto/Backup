global class BCH_CDA_LanguageReviewReminders implements Database.Batchable<sObject> {
    String query;
    Date todayDate;

    //Constructor
    global BCH_CDA_LanguageReviewReminders() {
        todayDate = Date.today();
    }

    global Database.QueryLocator start(Database.BatchableContext bC) {
        String fieldStr = UTL_CDAUtility.getObjectFieldStr('CDA_Request__c');        
        fieldStr += ', Owner.Name, Owner.Email, CreatedBy.Name, CreatedBy.Email'; // to fetch record owner detail
        query = 'SELECT ' + fieldStr + '';
        query += ' FROM CDA_Request__c';
        query += ' WHERE Status__c = \'' + UTL_CDAUtility.STATUS_LANGUAGE_REVIEW + '\'';
        query += ' AND RecordType.Name != \''+UTL_CDAUtility.historicalDataRecordType+'\'';
        
        return Database.getQueryLocator(query);
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    global void execute(Database.BatchableContext bC, List<sObject> scope) {
        List<CDA_Request__c> cdaRequestList = (List<CDA_Request__c>)scope;
        Integer dayDiff = 0;
        String templateName = '';
        Map <Id, CDA_Request__c> cdaIdToCdaRequestForPrimaryReminderMap = new Map <Id, CDA_Request__c>();
        Map <Id, CDA_Request__c> cdaIdToCdaRequestForSecondaryReminderMap = new Map <Id, CDA_Request__c>();

        for(CDA_Request__c cdaRequest : cdaRequestList) {
            Integer daysInterval = UTL_CDAUtility.languageReviewReminderPrimaryDaysInterval;
            templateName = UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER;
            Date sentForLanguageReviewDate;
            if(cdaRequest.Date_Sent_for_Language_Review__c != null) {
                sentForLanguageReviewDate = date.newinstance(cdaRequest.Date_Sent_for_Language_Review__c.year(), cdaRequest.Date_Sent_for_Language_Review__c.month(), cdaRequest.Date_Sent_for_Language_Review__c.day());
            }

            system.debug('####cdaRequest.Name = ' + cdaRequest.Name + '|||' + '####sentForLanguageReviewDate = ' + sentForLanguageReviewDate);

            if(sentForLanguageReviewDate != null) {
                dayDiff = sentForLanguageReviewDate.daysBetween(todayDate);
            }

            system.debug('####dayDiff = ' + dayDiff + '|||' + '####daysInterval b4= ' + daysInterval + '|||' + '####Math.mod(dayDiff, daysInterval): ' + Math.mod(dayDiff, daysInterval));

            if((dayDiff != 0 && Math.mod(dayDiff, daysInterval) >= 0) || Test.isRunningTest()) {
                if(dayDiff == UTL_CDAUtility.languageReviewReminderPrimaryDaysInterval) {
                    cdaIdToCdaRequestForPrimaryReminderMap.put(cdaRequest.id, cdaRequest);
                } else if(dayDiff > UTL_CDAUtility.languageReviewReminderPrimaryDaysInterval) {
                    cdaIdToCdaRequestForSecondaryReminderMap.put(cdaRequest.id, cdaRequest);
                }
            }
        }
        system.debug('####cdaIdToCdaRequestForPrimaryReminderMap: '+cdaIdToCdaRequestForPrimaryReminderMap + '|||' + '####cdaIdToCdaRequestForSecondaryReminderMap: '+cdaIdToCdaRequestForSecondaryReminderMap);
       
        String devEmails = UTL_CDAUtility.devEmails;
        List<string> bccAddress;
        if(devEmails != null) {
            bccAddress = devEmails.split(';');
        }
        String toWhom = UTL_CDAUtility.LEGAL_POC;
        SRV_CDA_CDARequest.isReminder = true;
        if(cdaIdToCdaRequestForPrimaryReminderMap.size() > 0) {
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestForPrimaryReminderMap, toWhom, bccAddress, templateName);
        }
        if(cdaIdToCdaRequestForSecondaryReminderMap.size() > 0) {
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestForSecondaryReminderMap, toWhom, bccAddress, templateName);
        }
        SRV_CDA_CDARequest.isReminder = false;
    }

    global void finish(Database.BatchableContext bC) {}
}
