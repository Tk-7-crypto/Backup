/**
* Author: Sunny Bansal
* Since: September 1, 2015
* Name: TPA_ManualTriggerReportControllerTest
* Description: Test class of controller class TPA_ManualTriggerReportController
*        Added under ER-2181
**/
@isTest
(seeAllData = false)
private class TST_CNT_TPA_ManualTriggerReport
{
    public static TPA_Request__c agg;

    private static testmethod void insertUpdateTest()
    {
        
        Test.startTest();
        
        CNT_TPA_ManualTriggerReport controller = new CNT_TPA_ManualTriggerReport();
        Date fromDate =  (Date.today().addDays(-50));
        String strFromDate = fromDate.format();
        Date toDate = Date.today().addDays(-10);
        String strToDate = toDate.format();
        
        String conditions = '{"fromDate" : "' + strFromDate + '", "toDate" : "' + strToDate + '" , "countries" : "USA;"}';
        CNT_TPA_ManualTriggerReport.searchRequest(null,conditions);
        Test.stopTest();
    }
    
    @TestSetup
    static void setupTestData() {
        
        UTL_TPA_SetupTestData.createTPACountryCodeData('C','USA', 'US;U.S.;USA;United States Of America;U.S;U.S.A;United States;U.S.A.');
        Address__c TestAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Account',9999);
        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(TestAccount.Id);
        tpaRequest.Manual_Trigger_Reasons__c = 'Prescriber Level Data Included; Total selected uses more than three';
        tpaRequest.Client_Contact_Territory__c = 'United States';
        update tpaRequest;
        Test.setCreatedDate(tpaRequest.id,  Date.today().addDays(-20));
    }
    
}