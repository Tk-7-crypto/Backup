@isTest
private with sharing class TST_CNT_CSM_DocQCForm {
    @TestSetup
    static void makeData(){
        Case newCase1 = UTL_TestData.createCase();
        insert newCase1;
    }
    
    @isTest
    static void testGetDependentValuesByControllingValue() {
        Test.startTest();
            Map<String, List<String>> result = CNT_CSM_DocQCForm.getDependentValuesByControllingValue('CSM_R_D_Form__c', 'Remediation_Points__c');
        Test.stopTest();

        Assert.areEqual(true, result.keySet().size() > 0, 'result should not be null or empty');
    }
    
    @isTest
    static void testConvert(){
         Test.startTest();
            List<CNT_CSM_DocQCForm.FieldWrapper> result = CNT_CSM_DocQCForm.Convert();
        Test.stopTest();
    }
    
    @isTest
    static void testsaveRecord() {
        Case myCase = [SELECT Id FROM Case limit 1];
        List<CNT_CSM_DocQCForm.FieldWrapper> wrapVarList = new List<CNT_CSM_DocQCForm.FieldWrapper>();
        CNT_CSM_DocQCForm.FieldWrapper wrapVar = new CNT_CSM_DocQCForm.FieldWrapper();
        wrapVar.SectionName = 'Cover Page';
        wrapVar.RemediationPoints = 'Incorrect/Missing Logo';
        wrapVar.numberOfErrors = '35';
        wrapVarList.add(wrapVar);
        String jsonVar = JSON.serialize(wrapVarList);
        
        
        Test.startTest();
        CNT_CSM_DocQCForm.saveRecord(jsonVar, myCase.Id, jsonVar);
        Test.stopTest();
    }

}