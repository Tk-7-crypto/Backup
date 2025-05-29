@isTest
public class TST_FileWrapper {
    
    @isTest
    private static void testFileWrapper() {
         
        Test.startTest();
            FileWrapper fw = new FileWrapper('test1', 'test2', 'test3');
        Test.stopTest();
        
        Assert.areEqual('test1', fw.title, 'The value must be assigned');
    }
}