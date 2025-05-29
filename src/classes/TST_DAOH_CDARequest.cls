@isTest
private class TST_DAOH_CDARequest { 
    @isTest
    private static void test1(){
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        testSetup.setUpCustomSetting();
        testSetup.setUpContactForEmail();
        testSetup.setupUserRequestor();
        testSetup.setupUserNegotiator();

        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;

        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
        insert testQiLegalEntity;

        CDA_Legal_POC_Cross_Walk__c testLegalPOC = new CDA_Legal_POC_Cross_Walk__c(CDA_Language__c='Chinese',Legal_POC_First_Name__c='TestChinese',Legal_POC_Last_Name__c='Attorney',Legal_POC_Email_Address__c='test@abc.com');
		insert testLegalPOC;

        CDA_Account__c testCdaAccount = testSetup.cdaAccount;

        CDA_Request__c cdaRequest = testSetup.setupTestDataForCustomer(testQiLegalEntity);
        cdaRequest.Originating_Requestor_Flag__c = 'Yes';
        cdaRequest.Originating_Requestor_IQVIA_Email__c = 'orignating@req.com';
        cdaRequest.What_documents_would_you_like_to_provide__c = UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED;
        cdaRequest.Recipient_Account_Name_Other__c = 'Test Recipient Name';
        cdaRequest.Recipient_Account_Street_Other__c = 'Test Recipient Street';
        cdaRequest.Recipient_Account_City_Other__c = 'Test Recipient City';
        cdaRequest.Recipient_Account_State_Other_PL__c = 'Florida';
        cdaRequest.Recipient_Account_Country_Other_PL__c = 'United States';
        cdaRequest.Recipient_Account_ZipCode_Other__c = '123456';
        
        cdaRequest.Customer_Legal_Entity_Name_Other__c = 'Test Customer Name';
        cdaRequest.Customer_Legal_Entity_Street_Other__c = 'Test Customer Street';
        cdaRequest.Customer_Legal_Entity_City_Other__c = 'Test Customer City';
        cdaRequest.Customer_Legal_Entity_State_Other_PL__c = 'Florida';
        cdaRequest.Customer_Legal_Entity_Country_Other_PL__c = 'United States';
        cdaRequest.Customer_Legal_Entity_ZipCode_Other__c = '123456';
        update cdaRequest;
        
        dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRequest.Name);

        testDSStatus.dsfs__Envelope_Status__c = 'Completed';
        update testDSStatus;
        
        cdaRequest.status__c = 'Contract Executed';
        cdaRequest.Status_Completion_Date__c = Date.today();
        update cdaRequest;
        
        CDA_Request__c cdaRequest2 = testSetup.setupTestDataForAuditor(testQiLegalEntity);

        Attachment testAttachment1 = testSetup.getAttachment(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '_Test Attachment' + UTL_CDAUtility.EXTENTION_DOC , cdaRequest2.Id);
    }
}