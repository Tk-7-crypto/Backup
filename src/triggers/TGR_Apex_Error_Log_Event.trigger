/**
 * @author Vlad Tyazhov
 * Trigger for Apex_Error_Log_Event__e Event.
 * Used in triggers to insert Apex_Error_Log__c records (even if DML failed).
 */
trigger TGR_Apex_Error_Log_Event on Apex_Error_Log_Event__e (after insert) {
    List<Apex_Error_Log__c> logRecordsToInsert = new List<Apex_Error_Log__c>();

    for (Apex_Error_Log_Event__e logEvent : Trigger.new) {
        logRecordsToInsert.add(new Apex_Error_Log__c(
                Record_Id__c = logEvent.Record_Id__c,
                Object__c = logEvent.Object__c,
                Error_Message__c = logEvent.Error_Message__c,
                Record_Processed__c = false,
                Running_User__c = logEvent.Running_User__c != null ? logEvent.Running_User__c : UserInfo.getUserId(),
                Source_Module__c = logEvent.Source_Module__c
        ));
    }

    insert logRecordsToInsert;
}