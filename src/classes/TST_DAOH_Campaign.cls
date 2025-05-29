/**
* This test class is used to test all methods in Campaign Helper.
* version : 1.0
*/
@isTest
public class TST_DAOH_Campaign {
    
    @testSetup
    static void dataSetup() {
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=1; i <= 8; i++)
            campaignList.add(new Campaign(Name = 'camp-'+i, ParentId = null, NoOfMQLs__c = i));
        Test.startTest();
        insert campaignList;
        Test.stopTest();
    }
    
    static testMethod void testm1() {
        Campaign cmp = UTL_TestData.createCampaign();
        insert cmp;
        delete cmp;
    }
    
    static void testCreateCampaignHierarchy(){
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        List<Campaign> campaignList = [Select Id,Name, Parents_Hierarchy__c, ParentId,MQLS_in_Hierarchy__c From Campaign];
        for(Campaign campaign : campaignList)
            campaignMap.put(campaign.Name, campaign);
        
        campaignMap.put('camp-5', new Campaign(Id =campaignMap.get('camp-5').Id, Name = 'camp-5', ParentId =campaignMap.get('camp-3').Id, Parents_Hierarchy__c = '', MQLS_in_Hierarchy__c = 5   ));
        campaignMap.put('camp-6', new Campaign(Id =campaignMap.get('camp-6').Id, Name = 'camp-6', ParentId =campaignMap.get('camp-3').Id, Parents_Hierarchy__c = '', MQLS_in_Hierarchy__c = 6  ));
        campaignMap.put('camp-4', new Campaign(Id =campaignMap.get('camp-4').Id, Name = 'camp-4', ParentId =campaignMap.get('camp-2').Id, Parents_Hierarchy__c = '', MQLS_in_Hierarchy__c = 4   ));
        campaignMap.put('camp-2', new Campaign(Id =campaignMap.get('camp-2').Id, Name = 'camp-2', ParentId =campaignMap.get('camp-1').Id, Parents_Hierarchy__c = '', MQLS_in_Hierarchy__c = 20   ));
        campaignMap.put('camp-3', new Campaign(Id =campaignMap.get('camp-3').Id, Name = 'camp-3', ParentId =campaignMap.get('camp-2').Id, Parents_Hierarchy__c = '', MQLS_in_Hierarchy__c = 14   ));
        campaignMap.put('camp-8', new Campaign(Id =campaignMap.get('camp-8').Id, Name = 'camp-8', ParentId =campaignMap.get('camp-7').Id, Parents_Hierarchy__c = '', MQLS_in_Hierarchy__c = 8   ));
        campaignMap.put('camp-1', new Campaign(Id =campaignMap.get('camp-1').Id,  MQLS_in_Hierarchy__c = 21   ));   
        campaignMap.put('camp-7', new Campaign(Id =campaignMap.get('camp-7').Id,  MQLS_in_Hierarchy__c = 7   ));
        update campaignMap.values();
    }
    
    @isTest
    static void testupdateParentHierarchy(){
        testCreateCampaignHierarchy();
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        List<Campaign> updateCampaign = new List<Campaign>();
        List<Campaign> campaignList = [Select Id,Name, Parents_Hierarchy__c, ParentId,MQLS_in_Hierarchy__c From Campaign];
        for(Campaign campaign : campaignList)
            campaignMap.put(campaign.Name, campaign);
        Campaign campaign;
        campaign = campaignMap.get('camp-2');
        campaign.ParentId = Null;
        updateCampaign.add(campaign);
        
        campaign = campaignMap.get('camp-7');
        campaign.ParentId = campaignMap.get('camp-2').Id;
        updateCampaign.add(campaign);
        Test.startTest();       
        update updateCampaign;
        Test.stopTest(); 
    }
    
    @isTest
    static void testupdateParentHierarchy1(){
        testCreateCampaignHierarchy();
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        List<Campaign> updateCampaign = new List<Campaign>();
        List<Campaign> campaignList = [Select Id,Name, Parents_Hierarchy__c, ParentId,MQLS_in_Hierarchy__c From Campaign];
        for(Campaign campaign : campaignList)
            campaignMap.put(campaign.Name, campaign);
        Campaign campaign;
        campaign = campaignMap.get('camp-2');
        campaign.ParentId = campaignMap.get('camp-8').Id;
        updateCampaign.add(campaign);
        
        campaign = campaignMap.get('camp-5');
        campaign.ParentId = campaignMap.get('camp-7').Id;
        updateCampaign.add(campaign);
        Test.startTest();       
        update updateCampaign;
        Test.stopTest();
    }
    
    @isTest
    static void testCountMQlInHirearchy(){
        testCreateCampaignHierarchy();
        List<Campaign> campaignList = [Select Id,Name, Parents_Hierarchy__c, NoOfMQLs__c, ParentId,MQLS_in_Hierarchy__c From Campaign Where Name = 'camp-6'];
        for(Campaign campaign : campaignList){
            campaign.NoOfMQLs__c = 3;
        }
        Test.startTest();
        update campaignList;
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteCampaign(){
        testCreateCampaignHierarchy();
        List<Campaign> deleteCampaignList = new List<Campaign>();
        List<Campaign> campaignList = [Select Id,Name, Parents_Hierarchy__c, NoOfMQLs__c, ParentId,MQLS_in_Hierarchy__c From Campaign];
        for(Campaign campaign : campaignList){
            if(campaign.Name == 'camp-2' || campaign.Name == 'camp-1' || campaign.Name == 'camp-7'){
                deleteCampaignList.add(campaign);
            }
        }
        
        Test.startTest();
        delete deleteCampaignList;
        Test.stopTest();
        
    }
    
    @isTest
    static void testDeleteCampaign1(){
        testCreateCampaignHierarchy();
        List<Campaign> deleteCampaignList = new List<Campaign>();
        List<Campaign> campaignList = [Select Id,Name, Parents_Hierarchy__c, NoOfMQLs__c, ParentId,MQLS_in_Hierarchy__c From Campaign];
        for(Campaign campaign : campaignList){
            if(campaign.Name == 'camp-1' || campaign.Name == 'camp-5')
                deleteCampaignList.add(campaign);
        }
        Test.startTest();
        delete deleteCampaignList;
        Test.stopTest();
    }
    
    @isTest
    static void testParentHierarchy(){
        testCreateCampaignHierarchy();
        List<Campaign> campaignList = [Select Id,Name, Parents_Hierarchy__c, NoOfMQLs__c, ParentId,MQLS_in_Hierarchy__c From Campaign];
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        for(Campaign campaign : campaignList)
            campaignMap.put(campaign.Name, campaign);
        
        Insert new Campaign(Name = 'test', ParentId = campaignMap.get('camp-7').Id);
        campaignMap.get('camp-1').Parents_Hierarchy__c = Null;
        Update campaignMap.get('camp-1');
        update campaignMap.get('camp-2');
        campaignMap.get('camp-2').ParentId = Null;
        campaignMap.get('camp-2').MQLS_in_Hierarchy__c = Null;
       // campaignMap.get('camp-2').NoOfMQLs__c = Null;
        
        update campaignMap.get('camp-2');
        delete campaignMap.get('camp-2');
    }
}