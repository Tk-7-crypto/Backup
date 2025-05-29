@isTest
private class TST_SLT_Apttus_APTS_Template {

    @isTest
    private static void testGetSObjectFieldListShouldReturnList() {
        
        Test.startTest();
            List<Schema.SObjectField> fieldList = new SLT_Apttus_APTS_Template(true, true).getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(null, fieldList, 'Field list is null when not expected.');
    }

    @isTest
    private static void testGetSObjectTypeShouldReturnSObjectType() {
        Test.startTest();
            Schema.SObjectType type = new SLT_Apttus_APTS_Template().getSObjectType();
        Test.stopTest();

        System.assertEquals(type, Apttus__APTS_Template__c.sObjectType, 'SObject types are not matched when not expected.');
    }

    @isTest
    private static void testGetTemplatesShouldReturnList() {
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c(Name='Test template');
        insert template;
        Set<String> fields = new Set<String>{'Id'};

        Test.startTest();
            List<Apttus__APTS_Template__c> templateList = new SLT_Apttus_APTS_Template().getTemplates(fields, '', 1);
        Test.stopTest();

        System.assertNotEquals(0, templateList.size(), 'Template list is empty when not expected.');
    }
}