/**
 * This test class is used to test SCH_CRM_OpportunityStage
 * version : 1.0
 */
@isTest
private class TST_BCH_CRM_Unsigned_Contract_Alert {
    
    /**
    * This method is used to create data for BCH_CRM_Unsigned_Contract_Alert Batch
    */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact contact = UTL_TestData.createContact(acc.Id);
        contact.Email = 'testuser33@iqvia.com';
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
            .get('IQVIA User Contact').getRecordTypeId();
        contact.RecordTypeId = recordTypeId;
        contact.EmployeeNumber__c = '090909097';
        insert contact;
        List<User> userList = UTL_TestData.createUser('System Administrator',1);
        insert userList;
        Stage_Gate_Status_Values__c statusvalue = new Stage_Gate_Status_Values__c();
        statusvalue.Name = 'AnalystPP';
        statusvalue.Status__c = 'Analyst Preparing Customer Budget Deliverable';
        upsert statusvalue;
        Unsigned_Contract_Alert__c contractSetting = new Unsigned_Contract_Alert__c();
        contractSetting.Days_Before_Signature_Alert__c = 1;
        upsert contractSetting;
        Contract cntrt = new Contract();
        cntrt.AccountId = acc.Id;
        cntrt.Status = 'Activated';
        cntrt.CurrencyIsoCode = 'INR';
        cntrt.Contract_Execution_Date_Actual_Expected__c = System.today() -1;
        cntrt.Status = 'Analyst Preparing Customer Budget Deliverable';
        cntrt.StartDate = System.today();
        cntrt.ContractTerm = 12;
        cntrt.IQVIA_Project_Manager_Contact__c = contact.Id;
        cntrt.IQVIA_Project_Finance_Manager__c = userList[0].Id;
        cntrt.Specific_Contract_Type__c = 'Master Independent Contractor Agreement';
        insert cntrt; 
    }
    
    /**
    * This method is used to test BCH_CRM_Unsigned_Contract_Alert Batch
    */    
    @isTest
    static void testBatchUnsignedContractAlert() {
        Test.startTest();   
        String cronExp = '0 0 13 * * ?';
        System.schedule('SCH_CRM_Unsigned_Contract_Alert', cronExp, new SCH_CRM_UnsignedContractAlert());
        Test.stopTest();
    }

}