/**
* This test class is used to test all methods in SLT_OWF_Assignment_Setting.
* version : 1.0
*/
@isTest
private class TST_SLT_OWF_Assignment_Setting {
     
	/**
    * This test method used to cover basic methods
    */
    static testMethod void testGetOWFAssignmentSettingRecords(){
        SLT_OWF_Assignment_Setting sltAssignmentSetting = new SLT_OWF_Assignment_Setting();
        Test.startTest();
        List<OWF_Assignment_Setting__mdt> assignmentSettingList = sltAssignmentSetting.getOWFAssignmentSettingRecords(new Set<String> {'Id'});
        Test.stopTest();
		
		//Checking Size
        system.assert(assignmentSettingList.size()>0);  
    }
}