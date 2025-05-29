/**
 * This test class is used to test all methods in Resource Setting service class
 * version : 1.0
 */
@isTest
private class TST_SLT_OWF_Resource_Setting {
	
	/**
    * This method is used to test the getOWFResourceSettingRecords method
    */
    static testMethod void testGetOWFResourceSettingRecords()
	{
        Set<String> fieldSet = new Set<String>{'Sub_Group__c','Estimated_Fees__c'};
        List<OWF_Resource_Setting__mdt> owfResourceSettingList = new SLT_OWF_Resource_Setting(false, false).getOWFResourceSettingRecords(fieldSet);
        owfResourceSettingList = new SLT_OWF_Resource_Setting().getOWFResourceSettingRecords(fieldSet);
		
		//Checking Size
        system.assert(owfResourceSettingList.size()>0);
    }
}