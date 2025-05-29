/**
* This test class is used to test all methods in SLT_OWF_ReBidFieldMapping.
* version : 1.0
*/
@isTest
private class TST_SLT_OWF_ReBidFieldMapping {

    /**
    * This test method used to cover basic methods
    */
    static testMethod void testGetReBidFieldMapping()
	{
        SLT_OWF_ReBidFieldMapping sltRebidFieldMapping = new SLT_OWF_ReBidFieldMapping(false, false);
        Test.startTest();
        List<OWF_ReBidFieldMapping__mdt> assignmentSettingList = sltRebidFieldMapping.getReBidFieldMapping();
        Test.stopTest();
		
		//Checking Size
        system.assert(assignmentSettingList.size()>0);
    }
}