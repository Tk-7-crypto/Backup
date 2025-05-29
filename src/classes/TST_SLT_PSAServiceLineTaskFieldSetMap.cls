/*
 * Version       : 1.0
 * Description   : Test Class for SLT_PSAServiceLineTaskFieldSetMapping
 * Note: The name of the test class has been truncated, or it would be too long for SFDC rules
 */
@isTest
private class TST_SLT_PSAServiceLineTaskFieldSetMap {

    @isTest
    static void testFieldSet(){
        Test.startTest();
        SLT_PSAServiceLineTaskFieldSetMapping selector = new SLT_PSAServiceLineTaskFieldSetMapping();
        Integer fieldCount = selector.fieldSet.size();
        selector.fieldSet = new Set<String>();
        Test.stopTest();
        System.assertEquals(fieldCount,selector.fieldSet.size());
    }

    @isTest
    static void testGetSObjectType(){
        Test.startTest();
        Schema.SObjectType type = new SLT_PSAServiceLineTaskFieldSetMapping().getSObjectType();
        Test.stopTest();
        System.assertEquals(PSA_Service_Line_Task_Field_Set_Mapping__mdt.sObjectType, type);
    }

    @isTest
    static void getSObjectFieldList(){
        Test.startTest();
        Schema.SObjectField [] fieldList = new SLT_PSAServiceLineTaskFieldSetMapping().getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(null, fieldList);
    }

    @isTest
    static void testGetFieldSetMappingsByCode(){
        Test.startTest();
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> mappings = new SLT_PSAServiceLineTaskFieldSetMapping().getFieldSetMappingsByCode('PVA1');
        Test.stopTest();
        System.assertNotEquals(0,mappings.size());
    }

    @isTest
    static void testGetTaskFieldSetMappings(){
        Test.startTest();
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> taskMappings = new SLT_PSAServiceLineTaskFieldSetMapping().getTaskFieldSetMappings('Task',null,'PVA','Service Line');
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> deliverableMappings = new SLT_PSAServiceLineTaskFieldSetMapping().getTaskFieldSetMappings('Deliverable','PVA1',null,'Service Line');
        Test.stopTest();
        System.assertNotEquals(0,taskMappings.size());
        System.assertNotEquals(0,deliverableMappings.size());
    }
}
