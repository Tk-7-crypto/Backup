/**
 * This test class tests all methods in the Account Report Note selector
 */
@isTest
private class TST_SLT_Account_Report_Note {

    @isTest
    static void testGetSObjectFieldList(){
        Test.startTest();
        List<Schema.SOBjectField> fieldNames = new SLT_Account_Report_Note().getSObjectFieldList();
        Test.stopTest();
    }

    @isTest
    static void testGetSObjectFieldSet(){
        Test.startTest();
        Set<String> fieldNames = new SLT_Account_Report_Note().getSObjectFieldSet();
        Test.stopTest();
    }

    @isTest
    static void testGetAccountReportNotesByAccountId(){
        setupTestData();
        Account testAccount = UTL_PSA_TestData.accounts[0];
        Test.startTest();
        Map<Id, Account_Report_Note__c> notes = new SLT_Account_Report_Note().getAccountReportNotesByAccountId(testAccount.Id);
        Test.stopTest();
        String expected = 'This is only a test';
        Account_Report_Note__c note = notes.values().get(0);
        System.assertNotEquals(null,note);
        System.assertEquals(expected, note.Notes__c);
    }

    static void setupTestData(){
        Account testAccount = UTL_PSA_TestData.accounts[0];
        Account_Report_Note__c note = new Account_Report_Note__c(
            Account__c=testAccount.Id,
            Legacy_ID__c='123ABC',
            Notes__c='This is only a test',
            Spreadsheet_Link__c=''
        );

        insert note;
    }
}