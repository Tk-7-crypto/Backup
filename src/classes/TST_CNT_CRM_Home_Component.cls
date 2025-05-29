@isTest
public class TST_CNT_CRM_Home_Component {
    
    @testSetup
    static void setUpTestData() {
        CSM_QI_News__c news = new CSM_QI_News__c();
        news.Announcements__c = 'Announcements';
        news.Mode__c = 'Published';
        news.Module__c = 'CRM';
        news.Profile__c = 'CSMS User';
        insert news;
    }
    
    @isTest
    static void testGetData() { 
        List<CSM_QI_News__c> listOfRecord = new List<CSM_QI_News__c> ();
        
        Test.startTest();
            listOfRecord = CNT_CRM_Home_Component.getData('CSMS User','Announcements__c');
        Test.stopTest(); 
        
        System.assertEquals(listOfRecord.size() > 0, true, 'Record fetched successfully');
    }
    
    @isTest
    static void testHasEditPermission() {
        Boolean hasPermission;
        
        Test.startTest();
            hasPermission = CNT_CRM_Home_Component.hasEditPermission('Announcements__c');
        Test.stopTest(); 
        
        System.assertEquals(hasPermission, true, 'Has Edit Permission');
    }


}