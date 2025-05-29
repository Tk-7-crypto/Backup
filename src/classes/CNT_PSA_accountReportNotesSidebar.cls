public with sharing class CNT_PSA_accountReportNotesSidebar {
    @AuraEnabled(cacheable=true)
    public static Map<Id, Account_Report_Note__c> getAccountReportNotes(Id accountId){
        return new SLT_Account_Report_Note().getAccountReportNotesByAccountId(accountId);
    }
}