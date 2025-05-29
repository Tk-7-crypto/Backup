/**
 * This is used to test CNT_CDA_CustomLandingComnt and UTL_CDA_PaginationWrapper classes methods.
 * version: 1.0
 */
@isTest(seeAllData=false)
public class TST_CNT_CDA_CustomLandingComnt {    
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
    
    public static testMethod void testGetCDARequests() {
        String pageNumber = '1';
        String currnetPagesCount = '5';
        String sortField = 'CDA_Id__c';
        String sortDirection = 'ASC';
        Map<String, String> searchMap = null;
        Boolean isNegotiatorTab = true;
        
        Test.startTest();
        
        CNT_CDA_CustomLandingComnt.getCDARequests(pageNumber, currnetPagesCount, sortField, sortDirection, searchMap, isNegotiatorTab);
        CNT_CDA_CustomLandingComnt.isNegotiator();
        CNT_CDA_CustomLandingComnt.isSystemDown();
        CNT_CDA_CustomLandingComnt.isCurrentUserAllowedOnSystemDown();
        Test.stopTest();
    }
    
    public static testmethod void testGetPageCountInfo() {
        String pageCountInfo = '1';
        Map<String, String> searchMap = null;
        Boolean isNegotiatorTab = true;
        
        Test.startTest();
        
        CNT_CDA_CustomLandingComnt.getPageCountInfo(pageCountInfo, searchMap, isNegotiatorTab);
        
        Test.stopTest();
    }
    
    public static testmethod void testGetPageCountChange() {
        String pageNumber= '1';
        String currnetPagesCount = '5';
        String totalPages = '5';
        String totalRecords = '3';
        
        Test.startTest();
        
        CNT_CDA_CustomLandingComnt.getPageCountChange(pageNumber, currnetPagesCount, totalPages, totalRecords);
        
        pageNumber= '4';
        CNT_CDA_CustomLandingComnt.getPageCountChange(pageNumber, currnetPagesCount, totalPages, totalRecords);
        
        pageNumber= '2';
        CNT_CDA_CustomLandingComnt.getPageCountChange(pageNumber, currnetPagesCount, totalPages, totalRecords);
        
        Test.stopTest();
    }
    
    public static testmethod void testGetDependentOptionsImpl() {
        Test.startTest();
        
        CNT_CDA_CustomLandingComnt.getDependentOptionsImpl('CDA_Request__c', 'QuintilesIMS_Business__c', 'CDA_Id__c');
        
        Test.stopTest();
    }
}