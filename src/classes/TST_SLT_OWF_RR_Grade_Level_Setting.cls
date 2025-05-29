/**
* This test class is used to test all methods in SLT_OWF_RR_Grade_Level_Setting.
* version : 1.0
*/
@isTest
private class TST_SLT_OWF_RR_Grade_Level_Setting {
    
    /**
    * This test method used to cover basic methods
    */
    static testMethod void testGetOWFResourceRequestGradeLevelSettingRecords()
	{
        SLT_OWF_RR_Grade_Level_Setting sltOWFRRGradeLevelSettingRecords = new SLT_OWF_RR_Grade_Level_Setting(false, false);
        Set<String> fieldSet =new Set<String>{'RFP_Ranking__c','Grade_Level_Contribution__c'};
        Test.startTest();
        List<OWF_RR_Grade_Level_Setting__mdt> assignmentSettingList = sltOWFRRGradeLevelSettingRecords.getOWFResourceRequestGradeLevelSettingRecords(fieldSet);
        Test.stopTest();
		
        //Checking Size
        system.assert(assignmentSettingList.size()>0);
    }
}