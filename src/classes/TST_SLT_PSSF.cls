/*
 * Version       : 1.0
 * Description   : Test Class for SLT_PSSF
 */
@isTest
private class TST_SLT_PSSF {
    @testSetup static void setup() {
        UTL_PSA_TestData.createPSSF(); 
    }
    
    /**
     * This method used to get a PSSF.
     */    
    @IsTest
    static void testgetPSSFByProject() {
        Test.startTest();
        pse__Proj__c projRec = [select id from pse__Proj__c limit 1];
        List<PSSF__c> pssfList1 = new SLT_PSSF().getPSSFByProject(new Set<Id>{projRec.id}, new Set<String>{'PSSF_Version__c'} );
        List<PSSF__c> pssfList2 = new SLT_PSSF(false).getPSSFByProject(new Set<Id>{projRec.id}, new Set<String>{'PSSF_Version__c'} );
        List<PSSF__c> pssfList3 = new SLT_PSSF(false,false).getPSSFByProject(new Set<Id>{projRec.id}, new Set<String>{'PSSF_Version__c'} );
        List<PSSF__c> pssfList4 = new SLT_PSSF(false,false).getPSSFByPSSFParentDataSource(new Set<Id>{projRec.id}, new Set<String>{'PSSF_Version__c'} );
        List<PSSF__c> pssfList5 = new SLT_PSSF(false,false).getPSSFByPSSFParentHistoryChanges(new Set<Id>{projRec.id}, new Set<String>{'PSSF_Version__c'} );
        Test.stopTest();
        System.assertEquals(pssfList1.size(), 0);
    }

}
