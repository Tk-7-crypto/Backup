@isTest
public class TST_SLT_Template_Data {
	
    @isTest
    static void testSelectTemplateDataByName() {
        insert new Template_Data__c(Name = CON_CPQ.TEST_USER, Migration_Id__c = 'TD-01');
        Test.startTest();
            SLT_Template_Data obj = new SLT_Template_Data();
            List<Template_Data__c> testTemplateDataList = obj.selectTemplateDataByName(CON_CPQ.TEST_USER);
            obj.getSObjectType();
            obj.getSObjectFieldList();
        Test.stopTest();
    }

    @isTest
    static void testGetTemplateDataByCondition() {
        insert new Template_Data__c(Name = CON_CPQ.TEST_USER, Migration_Id__c = 'TD-01');
        Test.startTest();
        	new SLT_Template_Data().getTemplateDataByCondition('Name = \'' + CON_CPQ.TEST_USER + '\'', new Set<String>{'Name'});
        Test.stopTest();
    }
}
