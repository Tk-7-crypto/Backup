@isTest
private class TST_SLT_Campaign {
   @isTest
    static void testSelectById(){
        Campaign camp = new Campaign(Name = 'camp');
        Test.startTest();
        Insert camp;
        new SLT_Campaign().selectById(new Set<Id>{camp.Id});
        Test.stopTest();
    }
    
    @isTest
    static void testgetCampaignByHierarchy(){
        Campaign camp = new Campaign(Name = 'camp', Parents_Hierarchy__c = 'test');
        Test.startTest();
        Insert camp;
        new SLT_Campaign().getchildCampaignsByparentHierarchy(new Set<String>{'test'});
        Test.stopTest();
    }

    @isTest
    static void testGetCampaignListByName() {
        Campaign camp = new Campaign(Name = 'camp');
        insert camp;
        Set<String> campNameSet = new Set<String>();
        campNameSet.add('camp');
        String orderBy = 'CreatedDate';
        Map<String, Id> campMap = new Map<String, Id>();
        Test.startTest();
        campMap = new SLT_Campaign().getCampaignListByName(campNameSet, orderBy);
        Test.stopTest();	
    }
}