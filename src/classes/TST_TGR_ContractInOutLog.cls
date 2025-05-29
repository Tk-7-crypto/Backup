@isTest
private class TST_TGR_ContractInOutLog {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() { 
        Account acc = new Account(Name = 'TestAccount', BillingStreet = 'testStreet', BillingCity = 'testCity', BillingCountry = 'testCountry', BillingPostalCode = '123465',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        Stage_Gate_Status_Values__c statusvalue = new Stage_Gate_Status_Values__c();
        statusvalue.Name = 'AnalystPP';
        statusvalue.Status__c = 'Analyst Preparing Customer Budget Deliverable';
        upsert statusvalue;
        Contract cntrt = new Contract();
        cntrt.AccountId = acc.Id;
        cntrt.Status = 'Draft';
        cntrt.CurrencyIsoCode = 'INR';
        cntrt.Status = 'Analyst Preparing Customer Budget Deliverable';
        cntrt.StartDate = System.today();
        cntrt.ContractTerm = 12;
        cntrt.Parent_Contract_Number__c = 1234;
        cntrt.Ultimate_Parent_Contract_Number__c = 5678;
        insert cntrt;
        Contract_In_Out_Log__c newInOutLog = new Contract_In_Out_Log__c(Contract__c = cntrt.Id);
        insert newInOutLog;   
    }
    
    @isTest
    static void test1() {
        Contract_In_Out_Log__c cio = [select id from Contract_In_Out_Log__c limit 1];
        cio.Number_of_Documents__c = 10;
        update cio;
        delete cio;
    }
}