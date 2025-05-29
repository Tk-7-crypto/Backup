@isTest
public class TST_CNT_PSA_PSSF_PDF {
    @testSetup static void setup() {
        UTL_PSA_TestData.createPSSF();
    }
    testmethod static void test_CNT_PSA_PSSF_PDF() {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.VFP_PSA_PSSF_PDF'));
        pssf__c pssfRec =  [select id from pssf__c where PSSF_Version__c = 'Draft' ];
        System.currentPageReference().getParameters().put('pssfParent', pssfRec.id);
        
        CNT_PSA_PSSF_PDF pssfPDF =  new CNT_PSA_PSSF_PDF();
        Test.stopTest();
    }
} 
