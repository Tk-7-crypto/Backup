@isTest(seeAllData = false)
public class TST_SLT_TPAAMAContractsAttachments {
    @isTest
    static void testSLT_TPAAMAContractsAttachments() {
        String condition = 'Contract_Attachment_Name__c = \'test\' ';
        SLT_TPAAMAContractsAttachments.instance.selectByFilterWithLimit(condition, 1);
        SLT_TPAAMAContractsAttachments.instance.selectByFilter(new Set<String>{'Contract_Attachment_Name__c'}, condition);
        SLT_TPAAMAContractsAttachments.instance.selectByFilterOnly(condition);
    }

}