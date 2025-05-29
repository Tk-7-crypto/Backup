/**
 * This test class is used to test TGR_LR_Project_Overview cls.
 * version : 1.0
*/
@isTest
public class TST_TGR_LR_Project_Overview {
    
    @testSetup
    static void dataSetup(){
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        insert lrRec;
    }
    
    @IsTest
    static void testSetFieldValue (){
        dataSetup();
        Test.startTest();
        LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c limit 1];
        lrRec.Aggregate_Reports__c = 'Yes';
        lrRec.DLP_Enter_only_for_Aggregate_Reports__c = system.today();
        lrRec.Full_Text_Articles_Reviewed__c = 'test Full Text Articles Reviewed';
        update lrRec;
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteSSRecords(){
        LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c limit 1];
        Test.startTest();
        delete lrRec;
        Test.stopTest(); 
    }
}
