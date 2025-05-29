/**
*@Author: Chandra Prakash Pandey
*@Purpose: Test class for TPA_UseDefDocTypeController controller class
*/
@isTest(SeeAllData = false)
private class TST_CNT_TPA_ValidateUseDefDocType {

    @TestSetup static void setup() {
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createTPASettingData();

        Date todayDate = Date.today();

        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testAccount1.Account__c;
        insert testContact;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(3);
        tpaRequest1.Purpose_List__c = 'Test Purpose List';
        tpaRequest1.Data_Asset_List__c = 'AAN';
        tpaRequest1.IMS_Legal_Entity_List__c = 'test';
        tpaRequest1.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest1.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest1.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest1.Vendor_Language__c =  'English';
        insert tpaRequest1;
        
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
        dsStatus.dsfs__Voided_Reason__c = 'Test Void';
        dsStatus.TPA_Request__c = tpaRequest1.Id;
        insert dsStatus;
    }

    @isTest static void test_ManualDRNSend() {
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_OffNotificationsGenerator;
        Test.setCurrentPage(pageRef);
        TPA_Request__c tpaRequest1 = [SELECT Id FROM TPA_Request__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('agrIdforAddendumGeneration', tpaRequest1.Id);

        CNT_TPA_ValidateUseDefDocType docTypeCntrlObj = new CNT_TPA_ValidateUseDefDocType();
        docTypeCntrlObj.loadDefaultValues(tpaRequest1.Id);
        docTypeCntrlObj.generateAddendumDoc();
        CNT_TPA_ValidateUseDefDocType.sendDRNManually(tpaRequest1.Id);
        CNT_TPA_ValidateUseDefDocType.sendCopyofSignedManually(tpaRequest1.Id);
        CNT_TPA_ValidateUseDefDocType.voidEnvelopeNManually(tpaRequest1.Id, 'test', 'envelopeCorrected');

        Test.stopTest();
    }
}