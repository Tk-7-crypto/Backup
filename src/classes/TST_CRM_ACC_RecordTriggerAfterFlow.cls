/**
 * This test class is used to cover the record triggered flow on account in after context.
 * version : 1.0
 */
@isTest
public class TST_CRM_ACC_RecordTriggerAfterFlow {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup(){
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        
        Contact testContact1 = UTL_TestData.createContact(newAccount.id);
        testContact1.Disposition__c = 'Test Disposition';
        insert testContact1;
    }
    
    
    @isTest
    public static void testCRMSubflowForDescartesRiskRating() {
        upsert new  Descartes_Approval_Setting__c(Account_Enabled__c = true); 
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Account DSP';
        Test.startTest();
            insert acc1;         
        Test.stopTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setComments('Submitting request for approval');
        submitRequest.setObjectId(acc1.Id);
        requests.add(submitRequest); 
        Approval.ProcessResult[] processResults = Approval.process(requests, true);
        acc1.DPS_Status__c = 'Cleared';
        update acc1;  
        acc1.DPS_Status__c = 'Pending';
        update acc1; 
    }  

}