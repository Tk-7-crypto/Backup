@isTest
private class TST_OptionsWrapper {
    
    @isTest
    private static void testOptionsWrapperShouldSetFields() {
        Test.startTest();
            OptionsWrapper optionsWrapper = new OptionsWrapper('Test','Test');
        Test.stopTest();

        System.assertEquals('Test',optionsWrapper.label, 'The value is not same when expected');
        System.assertEquals('Test',optionsWrapper.value, 'The value is not same when expected');
    }

}