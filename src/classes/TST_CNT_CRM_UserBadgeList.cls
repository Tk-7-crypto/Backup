@isTest
public class TST_CNT_CRM_UserBadgeList {
    
    @testSetup
    static void setUpTestData() {
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance(UserInfo.getUserId());
        ac.UserBadge_StatusSelected__c = '["Assigned", "Completed", "In-Progress"]';
        upsert ac;
    }
    
    @isTest
    static void testGetMetaData() {
        Map<String, Object> returnMap = new Map<String,Object>();
        Test.startTest();
        	returnMap = CNT_CRM_UserBadgeList.getMetaData();
        Test.stopTest();
        System.assertEquals(new List<String>{'Assigned','Completed', 'In-Progress'}, returnMap.get('status'));
    }
    
    @isTest
    static void testSetMetaData() {
        Test.startTest();
        	CNT_CRM_UserBadgeList.setMetaData('["Assigned", "Completed"]');
        Test.stopTest();
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance();
        System.assertEquals('["Assigned", "Completed"]', ac.UserBadge_StatusSelected__c);
    }
    
    @isTest
    static void testGetAllData() {
        trailheadapp__Badge__c badge = new trailheadapp__Badge__c();
        badge.Name = 'TestR';
        badge.trailheadapp__Description__c = 'TestR';
        badge.trailheadapp__URL__c = 'https://google.com';
        badge.trailheadapp__Icon__c= 'https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png';
        badge.trailheadapp__API_Name__c = 'TestR';
        badge.trailheadapp__Archived__c = false;
        badge.trailheadapp__Namespace__c = 'IQVIA';
        insert badge;
        
        trailheadapp__User_Badge__c userBadge = new trailheadapp__User_Badge__c();
        userBadge.trailheadapp__Badge__c = badge.Id;
        userBadge.trailheadapp__User__c = UserInfo.getUserId();
        userBadge.trailheadapp__Status__c = 'Assigned';
        userBadge.trailheadapp__Archived__c = false;
        userBadge.trailheadapp__Assigned_Date__c = System.now();
        insert userBadge;
        
        List<trailheadapp__User_Badge__c> listofUserBadge= new List<trailheadapp__User_Badge__c>();
        Test.startTest();
        	listofUserBadge = CNT_CRM_UserBadgeList.getUserBadgeList();
        Test.stopTest();
        System.assertEquals(true ,listofUserBadge.size() > 0);
    }
    
}