/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_CSMNews
 */
@isTest
private class  TST_CNT_CSM_CSMNews {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        CSM_QI_News__c csmnews = new CSM_QI_News__c(Name='testName', News__c='testNews', Mode__c='Published', Module__c='CRM',Type__c='News');
        insert csmnews;
    }
    
    /**
     * This method used to get all CSM_QI_News__c
     */    
    @IsTest
    static void testGetCSMNews() {
        List<CSM_QI_News__c> csmnews = new  List<CSM_QI_News__c>();
        Test.startTest();
        csmnews = CNT_CSM_CSMNews.getUnuseCSMNews();  
        Test.stopTest();
        Integer expected = 1;
        Integer actual = csmnews.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testGetCSMNewsByModule() {
        List<CSM_QI_News__c> csmnews = new  List<CSM_QI_News__c>();
        Test.startTest();
        csmnews = CNT_CSM_CSMNews.getCSMNews('CRM','News');  
        Test.stopTest();
        System.assertEquals(1,csmnews.size());
    }

    @IsTest
    static void testGetUserPermissionSets() {
        List<PermissionSet> p = new  List<PermissionSet>();
        Test.startTest();
        p = CNT_CSM_CSMNews.getUserPermissionSets();  
        Test.stopTest();
    }
}