@isTest(seeAllData = false)
public class TST_SLT_TPAOfferingNotificationMapping {
    @isTest
    static void testSLT_TPAOfferingNotificationMapping() {
        String testId = 'asedhnwaedqw345';
        SLT_TPAOfferingNotificationMapping.instance.selectByFilter(new Set<String>(), 'name = \'test\' ');
        SLT_TPAOfferingNotificationMapping.instance.getTPAOfferingNotificationMappingDataById(testId, new Set<String>());
        SLT_TPAOfferingNotificationMapping.instance.selectWithLineItems(new Set<String>(), new Set<String>());
    }
}