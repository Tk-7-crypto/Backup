@IsTest
private class TST_SLT_KBTranslationSetting {
    
    @IsTest
    private static void testGetSObjectFieldList() {
        Test.startTest();
            List<Schema.SObjectField> fieldSet = new SLT_KBTranslationSetting().getSObjectFieldList();
        Test.stopTest();
        
        System.assertEquals(true, fieldSet != null, 'Should get field set');
    }
   
    @IsTest
    private static void testGetSObjectType() {
        Test.startTest();
            Schema.SObjectType sObjectType = new SLT_KBTranslationSetting().getSObjectType();
        Test.stopTest();
        
        System.assertEquals(true, sObjectType != null, 'Should get sobject type');
    }
    
    @IsTest
    private static void testGetDisclaimerByLanguage() {
        Test.startTest();
            Map<String, String> disclaimerByLanguage = new SLT_KBTranslationSetting().getDisclaimerByLanguage();
        Test.stopTest();
        
        System.assertEquals(true, disclaimerByLanguage != null, 'Should get Disclaimer by language map');
    }
}