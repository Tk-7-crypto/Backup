/**
 * This test class is test the LoadCRMSampleData.
 */ 
@isTest
private class TST_LoadCRMSampleData {
    
    @isTest
    static void testCreateSampleData(){
        Test.startTest();
          LoadCRMSampleData.createSampleData(20);
        Test.stopTest();
        List<Opportunity> opp = [Select Id From Opportunity Where Name like 'Test Opportunity%'];
        System.debug('opp ' + opp.size() );
        System.assertEquals(opp.size(), 20);
    }
    
    @isTest
    static void testAbortedApexBatch(){
        Test.startTest();
          LoadCRMSampleData.abortedApexBatch();
        Test.stopTest();
        List<AsyncApexJob> batchList = [SELECT Id, Status FROM AsyncApexJob Where Status != 'Aborted'];
        System.assertEquals(batchList.size(), 0);
    }
    
    @isTest()
    static void testCustomSetting(){
        Test.startTest();
         LoadCRMSampleData.modifyCustomSettings();
        Test.stopTest();
        
        Mulesoft_Integration_Control__c mulesoftField = Mulesoft_Integration_Control__c.getOrgDefaults();
        System.assert( mulesoftField.Suppress_Outbound_Messages__c);
    }
    
}