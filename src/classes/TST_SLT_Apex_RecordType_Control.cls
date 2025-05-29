/*
 * Version       : 1.0
 * Description   : This Apex class is  to test SLT_Apex_RecorType_Control
 */
@isTest
private class TST_SLT_Apex_RecordType_Control {


/**
 * This method used to test get field list of sobject
 * @return  List<Schema.SObjectField>
 */
@IsTest
static void testSObjectFieldList() {
	//setupTestData();
	Test.startTest();
	SLT_Apex_RecordType_Control sltRR = new SLT_Apex_RecordType_Control();
	List<Schema.SObjectField> sltARSObjectFieldlist = sltRR.getSObjectFieldList();
	Test.stopTest();
	//System.assertNotEquals(0,sltARSObjectFieldlist.size());
}

/**
 * This method used to test set up type of sobject
 * @return  Schema.SObjectType
 */

@IsTest
static void testGetSObject () {
	//setupTestData();
	Test.startTest();
	Apex_RecordType_Control__mdt sltRR = new Apex_RecordType_Control__mdt();
	Schema.SObjectType ss= sltRR.getSObjectType();
	Test.stopTest();
	System.assertNotEquals(null,ss);

}




@IsTest
static void testGetRecordTypeControls() {
	//setupTestData();
	Test.startTest();
	SLT_Apex_RecordType_Control sltRR = new SLT_Apex_RecordType_Control();
	pse__Project_Task__c pts = new  pse__Project_Task__c();
	String objectType = pts.getSObjectType().getDescribe().getName();
	List<Apex_RecordType_Control__mdt> sltARSObjectFieldlist = sltRR.getRecordTypeControls(objectType);
	Test.stopTest();
	System.assertNotEquals(0,sltARSObjectFieldlist.size());
}

/**
 * This returns a map of methods to list of recordtypes for the object
 */

@IsTest
static void testGetRecordTypeControlMap() {
	//setupTestData();
	Test.startTest();
	SLT_Apex_RecordType_Control sltRR = new SLT_Apex_RecordType_Control();
	pse__Project_Task__c pts = new  pse__Project_Task__c();
	String objectType = pts.getSObjectType().getDescribe().getName();
	Map<String, Set<String> > sltARSObjectFieldMap = sltRR.getRecordTypeControlMap(objectType);
	Test.stopTest();
	Set<String> stringset = sltARSObjectFieldMap.get('addPricingTaskTemplateTasks');
	System.assertEquals('RDS_Deliverable_Task',new list<String>(stringset) [0]);

}
}