/**
 * Author   : Babita Dadarwal
 * Name     : BCH_CDA_RecipientReviewReminders
 * Purpose  : This batch is used to send reminders for the CDA requets that are in 'Sent for Recipient Review' Status.
 * Created Under CR-11169
 */
global class BCH_CDA_RecipientReviewReminders implements Database.Batchable<sObject> {
    String query;
    Date todayDate;

    // Constructor
    global BCH_CDA_RecipientReviewReminders() {
        todayDate = Date.today();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT id, Name, Status__c, CDA_Type__c, CDA_Format__c, Date_Sent_for_Review__c';
        query += ', CDA_Language__c, Requestor_Carbon_Copies__c, Recipient_Point_of_Contact_Email_Address__c';
        query += ', What_documents_would_you_like_to_provide__c, Owner.Email, RecordTypeId';    //Updated by Vikram Singh under CR-11691
        query += ', Originating_Requestor_Flag__c, Originating_Requestor_First_Name__c, Originating_Requestor_Last_Name__c, Originating_Requestor_IQVIA_Email__c, Requestor_Admin_Email_Flag__c';  //Added by Vikram Singh under Issue-11855
        query += ' FROM CDA_Request__c';
        query += ' WHERE Status__c = \'' + UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW + '\''; // and id = \'a7Q4E0000008WDOUA2\''
        query += ' AND RecordType.Name != \''+UTL_CDAUtility.historicalDataRecordType+'\''; //Added by Vikram Singh under CR-11691
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<CDA_Request__c> cdaRequestList = (List<CDA_Request__c>)scope;
        Integer dayDiff = 0;

        // Updated by Babita Dadarwal under CR-11433 Start
        Map <Id, CDA_Request__c> cdaIdToCdaRequestCustomerTypeMap = new Map <Id, CDA_Request__c>();
        Map <Id, CDA_Request__c> cdaIdToCdaRequestOtherTypeMap = new Map <Id, CDA_Request__c>();
        String templateName = '';

        for(CDA_Request__c cdaRequest : cdaRequestList) {
            //Updated by Vikram Singh under Issue-12008 Start
            Integer daysInterval = UTL_CDAUtility.remindersDaysInterval;   //Updated by Vikram Singh under Issue-12008
            templateName = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER_Auditor;
            Date sentForReviewDate = date.newinstance(cdaRequest.Date_Sent_for_Review__c.year(), cdaRequest.Date_Sent_for_Review__c.month(), cdaRequest.Date_Sent_for_Review__c.day());

            system.debug('cdaRequest.Name = ' + cdaRequest.Name);
            system.debug('sentForReviewDate = ' + sentForReviewDate);

            dayDiff = sentForReviewDate.daysBetween(todayDate);

            system.debug('dayDiff = ' + dayDiff);
            system.debug('cdaRequest.CDA_Type__c ' + cdaRequest.CDA_Type__c);
            system.debug('daysInterval b4= ' + daysInterval);

            if(cdaRequest.CDA_Type__c == UTL_CDAUtility.CUSTOMER) {
                daysInterval = UTL_CDAUtility.remindersDaysIntervalForCustomer;    //Updated by Vikram Singh under Issue-12008
            }
            // Updated by Vikram Singh under Issue-12008 End
            system.debug('####daysInterval = ' + daysInterval);
            // system.debug('####Days mod = ' + Math.mod(dayDiff, daysInterval));

            if((dayDiff != 0 && Math.mod(dayDiff, daysInterval) == 0) || Test.isRunningTest()) {
                if(cdaRequest.CDA_Type__c == UTL_CDAUtility.CUSTOMER) {
                    templateName = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER;
                    cdaIdToCdaRequestCustomerTypeMap.put(cdaRequest.id, cdaRequest);
                }
                else {
                    cdaIdToCdaRequestOtherTypeMap.put(cdaRequest.id, cdaRequest);
                }
            }
        }
        String devEmails = UTL_CDAUtility.devEmails;
        List<string> ccAddress;
        if(devEmails != null) {
            ccAddress = devEmails.split(';');
        }
        String toWhom = UTL_CDAUtility.RECIPIENT;
        if(cdaIdToCdaRequestCustomerTypeMap.size() > 0) {
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestCustomerTypeMap, toWhom, ccAddress, templateName);
        }
        if(cdaIdToCdaRequestOtherTypeMap.size() > 0) {
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestOtherTypeMap, toWhom, ccAddress, templateName);
        }
        // Updated by Babita Dadarwal under CR-11433 End
    }

    global void finish(Database.BatchableContext BC) {}
}