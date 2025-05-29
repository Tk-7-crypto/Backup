@isTest
public class TST_CNT_CRM_LookupMobile {
    
    @testSetup
    static void setUpTestData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
    }
    
    @isTest
    static void testFetchLookUpValues() {
        List <sObject> objectList = new List<sObject> ();
        
        Test.startTest();
        	objectList = CNT_CRM_LookupMobile.fetchLookUpValues('test','Account',' Id != null ');
        Test.stopTest(); 
        
        System.assertEquals(objectList.size() > 0, true);
    }
    
}