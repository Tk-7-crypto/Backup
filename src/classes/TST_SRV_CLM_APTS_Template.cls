@isTest
private class TST_SRV_CLM_APTS_Template {
    
    @isTest
    private static void testGetTemplatesShouldReturnList() {
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c(Name='Test Template');
        insert template;
        Set<String> fields = new Set<String>{'Id'};
        
        Test.startTest();
            List<Apttus__APTS_Template__c> templateList = SRV_CLM_APTS_Template.getTemplates(fields, '', 1);
        Test.stopTest();

        System.assertNotEquals(0, templateList.size(), 'Template list is empty when not expected.');
    }
}