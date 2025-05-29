@isTest
public class TST_CNT_CRM_List_View {
    
    @testSetup
    static void setUpTestData() {
        Campaign cmp = UTL_TestData.createCampaign();
        cmp.IsActive = true;
        cmp.Marketing_Lead__c = UserInfo.getName();
        insert cmp;
    }
    
    
    @isTest
    static void testGetMyCampaign() {
        List<Campaign> listOfRecord = new List<Campaign> ();
        Test.startTest();
        listOfRecord = CNT_CRM_List_View.getMyCampaign();
        Test.stopTest(); 
        System.assertEquals(listOfRecord.size() > 0, true);
    }
    
    @isTest
    static void testGetMetadata() {
        Test.startTest();
        CNT_CRM_List_View.getMetadata('Campaign','Id,Name, StartDate, Channel__c','Id != null');
        Test.stopTest(); 
    }
}