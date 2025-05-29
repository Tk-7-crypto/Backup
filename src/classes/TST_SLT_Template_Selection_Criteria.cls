@isTest
public class TST_SLT_Template_Selection_Criteria {

    @isTest
    private static void testGetSObjectFieldListShouldReturnList() {
        Test.startTest();
            List<Schema.SObjectField> fieldList = new SLT_Template_Selection_Criteria(true, true).getSObjectFieldList();
        Test.stopTest();
        
        System.assertNotEquals(null, fieldList, 'Field list is null when not expected.');
    }

    @isTest
    private static void testGetSObjectTypeShouldReturnSObjectType() {
        Test.startTest();
            Schema.SObjectType type = new SLT_Template_Selection_Criteria().getSObjectType();
        Test.stopTest();
        System.assertEquals(type, Template_Selection_Criteria__c.sObjectType, 'SObject types are not matched when not expected.');
    }

    @isTest
    private static void testGetTemplateSelectionCriteriaListShouldReturnList() {
        Template_Selection_Criteria__c template = new Template_Selection_Criteria__c(Name='Test template');
        insert template;
        
        Set<String> fields = new Set<String>{'Id'};
        Test.startTest();
            List<Template_Selection_Criteria__c> templateList = new SLT_Template_Selection_Criteria().getTemplateSelectionCriteriaList(fields, '');
        Test.stopTest();
        System.assertNotEquals(0, templateList.size(), 'Template list is empty when not expected.');
    }
}