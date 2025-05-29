@isTest
public class TST_CPQ_CustomExceptionClass {
    
    @isTest
    public static void testCPQ_CustomException() {
        Test.startTest();
            CPQ_CustomException customException = new CPQ_CustomException();
            Boolean flag = customException.isFlag;
        Test.stopTest();
        
        System.assertEquals(flag, false);
    }
}