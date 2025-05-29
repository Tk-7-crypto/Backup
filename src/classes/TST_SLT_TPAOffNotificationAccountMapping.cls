@isTest(seeAllData = false)
public class TST_SLT_TPAOffNotificationAccountMapping {
    @isTest
    static void testSLT_TPAOffNotificationAccountMapping() {
        String testId = 'asedhnwaedqw345';
        SLT_TPAOffNotificationAccountMapping.instance.selectByFilter(new Set<String>(), 'name = \'test\' ');
        SLT_TPAOffNotificationAccountMapping.instance.selectFieldsSetById(new Set<String>(), new Set<Id>());
        SLT_TPAOffNotificationAccountMapping.instance.selectById(new Set<Id>());
        SLT_TPAOffNotificationAccountMapping.instance.selectByFilterOnly('name = \'test\' ');
    }
}