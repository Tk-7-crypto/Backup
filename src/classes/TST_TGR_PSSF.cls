/**
* This test class is used to test TGR_PSSF.cls.
*
*/
@isTest
private class TST_TGR_PSSF {
    @testSetup static void setup() {
        UTL_PSA_TestData.createPSSF();  
    }
    
    testmethod static void testvalidateFieldsPSSF(){
        Test.startTest(); 
        try{
            PSSF__c pssfRec = [SELECT id from PSSF__c limit 1];
            //pssfRec.Project_Name__c = null;

            pssfRec.PSSF_Status__c = 'Published';
            update pssfRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        //System.assertEquals(1, pssfRec.size());
        Test.stopTest();
    }
    
}
