@isTest
public class TST_DAOH_PSA_HA_Websites_Review {
	@testSetup static void setup() {
        UTL_PSA_TestData.createHAWebsite();
    }
    testmethod static void testSignalTrigger() {
        Test.startTest();
        HA_Websites_Review__c ha = [select id from HA_Websites_Review__c limit 1];
        delete ha;
        Test.stopTest();
        
    }
}
