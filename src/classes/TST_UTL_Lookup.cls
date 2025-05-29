@isTest
private class TST_UTL_Lookup{
    
    @isTest
    public static void testMethod1() {
        Test.startTest();
        UTL_Lookup.serializeWithoutNamespace(null);
        UTL_Lookup.convertObjectToMap(null);
        String a = UTL_Lookup.NAMESPACE;
        Test.stopTest();
    }
}