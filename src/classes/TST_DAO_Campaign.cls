/**
* This test class is used to test all methods in DAO Campaign.
* version : 1.0
*/
@isTest
public class TST_DAO_Campaign {
    static testMethod void testm1() {
        Campaign cmp = UTL_TestData.createCampaign();
        insert cmp;
        delete cmp;
    }
    
    static testMethod void updateCall(){
       Campaign cmp = UTL_TestData.createCampaign();
        insert cmp; 
        Campaign campaign = [Select Id, Name From Campaign Limit 1];
        campaign.Name = 'camp-test';
        Test.startTest();
        update campaign;
        Test.stopTest();
    }
}