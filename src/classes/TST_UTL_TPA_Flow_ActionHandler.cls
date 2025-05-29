/*
* Description   : Apex Test class for UTL_TPA_Flow_ActionHandler 
*/ 
@isTest
public class TST_UTL_TPA_Flow_ActionHandler {
    @testSetup
    static void dataSetUp(){
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        Account acc = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        Address__c testAddrs = new Address__c(Name = 'TPA Test Acc', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Account__c = acc.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddrs;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        insert con;
        
        acc = [select Id from Account where name = 'Test acc'];
        
        Account_Compliance__c accCompl = new Account_Compliance__c(Account__c = acc.Id, Client_TPA_Compliance_Hold__c = true, Vendor_TPA_Compliance_Hold__c = true, Client_TPA_Compliance_Hold_Reason__c = 'Client on Hold', Vendor_TPA_Compliance_Hold_Reason__c = 'Vendor on Hold');
        insert accCompl;
    }
    
    @isTest
    private static void testsendCertificateEmailPreviewP(){
        UTL_TPA_Flow_ActionHandler.FlowInputs flowInputs = new UTL_TPA_Flow_ActionHandler.FlowInputs();
        Account acc = [select Id from Account where name = 'Test acc'];
        Account_Compliance__c accComp = [select Id from Account_Compliance__c where Account__c =:acc.Id];
        flowInputs.recordID = accComp.Id;
        flowInputs.action = 'TPA Certification Email Preview';
        
        Test.startTest();
        List<UTL_TPA_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_TPA_Flow_ActionHandler.apexFlowAction(
            new List<UTL_TPA_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();
    }
    
    @isTest
    private static void testsendCertificateEmail(){
        UTL_TPA_Flow_ActionHandler.FlowInputs flowInputs = new UTL_TPA_Flow_ActionHandler.FlowInputs();
        Account acc = [select Id from Account where name = 'Test acc'];
        Account_Compliance__c accComp = [select Id from Account_Compliance__c where Account__c =: acc.Id];
        flowInputs.recordID = accComp.Id;
        flowInputs.action = 'TPA Certification Send Email';
        flowInputs.emailSubject = 'Hi';
        flowInputs.emailBody = 'Hi [Client Name]';
        flowInputs.ClientName = 'test';
        flowInputs.ClientEmail = 'a@a.com';
        flowInputs.ccEmails = 'test@test.com';
        
        Test.startTest();
        List<UTL_TPA_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_TPA_Flow_ActionHandler.apexFlowAction(
            new List<UTL_TPA_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();
    }
    
}