/*
 * Version       : 1.0
 * Description   : Test Class for SLT_CSM_QI_News
 */
@isTest
private class TST_SLT_CSM_QI_News {
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        CSM_QI_News__c csmnews = new CSM_QI_News__c(Name='testName', News__c='testNews', Mode__c='Published',Module__c='CRM',Type__c='News');
        insert csmnews;
    }
    
    /**
     * This method used to get all CSM_QI_News__c
     */    
    @IsTest
    static void testSelectAllNews() {
        List<CSM_QI_News__c> csmnews = new  List<CSM_QI_News__c>();
        Test.startTest();
        csmnews = new SLT_CSM_QI_News().selectAllNews(new Set<String>{'Id', 'Name','CreatedDate','LastModifiedDate' ,'News__c','Mode__c'});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = csmnews.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testSelectNewsByModule() {
        List<CSM_QI_News__c> csmnews = new  List<CSM_QI_News__c>();
        Test.startTest();
        csmnews = new SLT_CSM_QI_News().selectNewsByModule(new Set<String>{'Id', 'Name'},'CRM','News');
        Test.stopTest();
        System.assertEquals(1, csmnews.size());
    }
}