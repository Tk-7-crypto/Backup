@isTest(seeAllData=false)
public class TST_UTL_TPA_AMA { 
  
    private static UTL_TPA_AMA utilObj;
   
    /**
    * Setup test data required to run tests in a data independent fashion
    */    
    @testSetup static void setup() {
    
    }
    
    @isTest static void testcases1(){
        
        utilObj =  new UTL_TPA_AMA();
        
        test.startTest();
        String inputString = 'bahg;njhj';
        String inputString1 = '';
        String outputString = '';
        outputString = UTL_TPA_AMA.getValidStringOnlyWordChar(inputString);
        System.assertEquals('bahgnjhj', outputString);
        outputString = UTL_TPA_AMA.getValidStringOnlyWordChar(inputString1);
        UTL_TPA_AMA.getTruncatedValue(inputString);
        System.assertEquals('', outputString);
        test.stopTest();
    }
}