@isTest
private class TST_UTL_Guid{    
    @isTest
    public static void testMethod1() {
        Test.startTest();
        UTL_Guid.newGuid();
        UTL_Guid.getCharAtIndex('test',1);
        string guid = UTL_Guid.Guid;
        Test.stopTest();
    }
}