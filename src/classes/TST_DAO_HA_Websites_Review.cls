@isTest
public class TST_DAO_HA_Websites_Review {
	@testSetup static void setup() {
        UTL_PSA_TestData.createHAWebsite();
    }
    testmethod static void testSignalTrigger() {
        Test.startTest();
        HA_Websites_Review__c ha = [select id from HA_Websites_Review__c limit 1];
        update ha;
        delete ha;
        Test.stopTest();
        
    }
}
