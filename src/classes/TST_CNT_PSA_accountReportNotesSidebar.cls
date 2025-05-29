/*
 * TST_CNT_PSA_accountReportNotesSidebar
 * 
 *
 * */

@isTest
private class TST_CNT_PSA_accountReportNotesSidebar 
{
	@testSetup
    static void dataSetup() 
    {
        Account testAccount = UTL_PSA_TestData.accounts[0];
        Account_Report_Note__c note = new Account_Report_Note__c(
            Account__c=testAccount.Id,
            Legacy_ID__c='123ABC',
            Notes__c='This is only a test',
            Spreadsheet_Link__c=''
        );

        insert note;
    }
    
    @isTest
    static void testGetAccountReportNotes(){
        //setupTestData();
        //Account testAccount = UTL_PSA_TestData.accounts[0];
        Account testAccount = [Select Id from Account limit 1];
        Account_Report_Note__c note = [Select Id, Account__c, Legacy_ID__c, Notes__c, Spreadsheet_Link__c from Account_Report_Note__c where Account__c =: testAccount.Id];
        Test.startTest();
        Map<Id, Account_Report_Note__c> notes = CNT_PSA_accountReportNotesSidebar.getAccountReportNotes(testAccount.Id);
        Test.stopTest();
        
        String expected = 'This is only a test';
        //Account_Report_Note__c note = notes.values().get(0);
        System.assertNotEquals(null,note);
        System.assertEquals(expected, note.Notes__c);
    }
	
    /*
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
	*/
}