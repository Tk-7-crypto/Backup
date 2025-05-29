/**
 * This is used to test CNT_CDA_RequestEditScreen and UTL_CDA_RequestEditWrapper classes methods.
 * version: 1.0
 */
@isTest(seeAllData=false)
public class TST_CNT_CDA_RequestEditScreen {
    /** 
     * This method is used to setup test data for all test methods. 
     */
    @testSetup
    public static void testSetupData() {
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        
        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;
        
        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw); 
        insert testQiLegalEntity;
        
        CDA_Request__c cdaRequest = testSetup.setupTestDataForCustomer(testQiLegalEntity); 
    }
    
    public static testmethod void testGetDependentOptionsImpl() {
        Test.startTest();
        
        CNT_CDA_RequestEditScreen.getDependentOptionsImpl('CDA_Request__c', 'QuintilesIMS_Business__c', 'CDA_Id__c');
        
        Test.stopTest();
    }
    
    public static testmethod void testGetCdaAccountInfo() {
        Test.startTest();
        
        CNT_CDA_RequestEditScreen.getCdaAccountInfo(new TST_CDA_SetupData().cdaAccount.Id);
        
        Test.stopTest();
    }
    
    public static testmethod void testGetQiLegalEntityInfo() {
        Test.startTest();
        
        QI_Legal_Entity__c testQiLegalEntity = [SELECT Id FROM QI_Legal_Entity__c LIMIT 1];
        
        CNT_CDA_RequestEditScreen.getQiLegalEntityInfo(testQiLegalEntity.Id);
        
        Test.stopTest();
    }
    
    public static testmethod void testGetRequestEditDefaultValues() {
        Test.startTest();
        
        CDA_Request__c cdaRequest = [SELECT Id FROM CDA_Request__c LIMIT 1];
        
        CNT_CDA_RequestEditScreen.getRequestEditDefaultValues(cdaRequest.Id);
        
        Test.stopTest();
    }
    
    public static testmethod void testSaveRequest() {
        Test.startTest();
        
        CDA_Request__c cdaRequest = [SELECT Id FROM CDA_Request__c LIMIT 1];
        cdaRequest = SRV_CDA_CDARequest.getCDARequest(cdaRequest.Id);
        
        CNT_CDA_RequestEditScreen.saveRequest(cdaRequest);
        
        cdaRequest.Status__c = UTL_CDAUtility.STATUS_AWAITINGREQSUB;
        
        CNT_CDA_RequestEditScreen.saveRequest(cdaRequest);
        
        Test.stopTest();
    }
}