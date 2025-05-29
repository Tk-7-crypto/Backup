@isTest(SeeAllData=false)
public class TST_CNT_TPA_ClientConfirmRequestedForm {
    @TestSetup static void setup() {
		
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        Date todayDate = Date.today();

        Account testAccount1 = new Account();
        testAccount1.Name = 'Test Acc';
        testAccount1.CustomerSegment__c = 'GOVERNMENT';
        testAccount1.Sub_Industry__c = 'STATE';
        insert testAccount1;
        
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAddress();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Account__c = testAccount1.Id;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;


        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testNewClientAccount.Account__r.Id;
        insert testContact;

        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>();

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testNewClientAccount.Id;
        tpaRequest1.Client_Address__c = testNewClientAccount.Id;
        tpaRequest1.Client_Language__c = 'English';
        tpaRequest1.Vendor_Language__c = 'English';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'In Review by IQVIA';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-1);
        tpaRequest1.ClientContact__c = testContact.Id;
        tpaRequest1.Is_Renewed__c = false;
        tpaRequest1.Purpose_List__c = 'Test Purpose List';
        tpaRequest1.Data_Asset_List__c = 'AAN';
        tpaRequest1.IMS_Legal_Entity_List__c = 'test';
        tpaRequest1.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest1.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest1.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest1.Client_TPA_Representative_Email__c = 'test1@gmail.com';
        tpaRequest1.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest1.Vendor_Language__c =  'English';
        tpaRequest1.Pending_Acknowledgements__c = 'Pending Client Acknowledgements';
        tpaRequest1.Client_Confirmation_Requested_Response__c = 'Disclosure to external legal counsel solely for purposes of obtaining internal legal advice';
        tpaRequestList.add(tpaRequest1);


        insert tpaRequestList;

        TPA_Contact__c tpaContact = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaRequest1);
        tpaContact.Type__c = 'Additional Client Contact';
        tpaContact.Email__c = 'test@mail.com';
        update tpaContact;

        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States', 'test name');

        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');

        List<TPA_Purpose__c> tpaPurposeList = new List<TPA_Purpose__c>();
        
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose.TPA_Purpose_Category__c = tpaPurposeCategory.Id;
        tpaPurpose.Purpose__c = imsTpaPurpose.Id;
        tpaPurpose.Request__c = tpaRequest1.Id;
        tpaPurposeList.add(tpaPurpose);
        //insert tpaPurpose;

        TPA_Purpose__c tpaPurpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        tpaPurpose2.TPA_Purpose_Category__c = tpaPurposeCategory.Id;
        tpaPurpose2.Purpose__c = imsTpaPurpose.Id;
        tpaPurpose2.Request__c = tpaRequest1.Id;
        tpaPurposeList.add(tpaPurpose2);
        insert tpaPurposeList;

        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset.BU__c = 'United States';
        
        
        insert imsDataAsset;

        IMS_Legal_Entity__c imsLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        imsLegalEntity.Name = 'IMS AG';
        imsLegalEntity.Legal_Entity_Name_for_TLLA__c = 'IMS AG';
        imsLegalEntity.TPA_Request__c = tpaRequest1.Id;
        insert imsLegalEntity;

        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset, imsLegalEntity);
        tpaDataAsset.BU__c = 'United States';
        tpaDataAsset.Geo_Level__c = 'Sub-National';
        tpaDataAsset.Asset_NametText__c = 'MIDAS';
        update tpaDataAsset;

        TPA_Data_Asset__c tpaDataAsset2 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset, imsLegalEntity);
        tpaDataAsset2.BU__c = 'United States';
        tpaDataAsset2.Geo_Level__c = 'Sub-National';
        tpaDataAsset2.Asset_NametText__c = 'Other';
        update tpaDataAsset2;

        TPA_Data_Asset__c tpaDataAsset3 = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose2, imsDataAsset, imsLegalEntity);
        tpaDataAsset3.BU__c = 'United States';
        tpaDataAsset3.Geo_Level__c = 'Sub-National';
        tpaDataAsset3.Asset_NametText__c = 'Other test';
        update tpaDataAsset3;

        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true, 'Test Sec Assest');

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset, imsSecondaryDataAsset, imsLegalEntity, tpaRequest1, 'Xponent PlanTrak');

        IMS_TPA_Purpose_Description__c imsTpaPurpDes = UTL_TPA_SetupTestData.createImsTpaPurposeDescription(imsTpaPurpose, tpaPurposeCategory);
        insert imsTpaPurpDes;

        TPA_Purpose_Description__c tpaPurpDes = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurpDes.Purpose__c = tpaPurpose.Id;
        tpaPurpDes.Description__c = imsTpaPurpDes.Id;
        tpaPurpDes.Other_Details__c = 'Test Other details';
        tpaPurpDes.Description_Text__c = 'Test Desc Text';
        insert tpaPurpDes;
        
        UTL_TPA_SetupTestData.createTpaTestEditorData('TPA ShutDown Message', 'Test', 'Shutdown Message', 'Shutdown Message');
    }

    @isTest static void test_requestValidateOnLoadForClient() {
        Test.StartTest();
        List<TPA_Request__c> requestList = [SELECT Id, Name,Client_Confirmation_Requested_Response__c FROM TPA_Request__c LIMIT 3];
        if(requestList.size() > 0) {
            String userProfileName = CNT_TPA_ClientConfirmRequestedForm.currentUserProfileName;
            String tpaCommunityUrl = CNT_TPA_ClientConfirmRequestedForm.tpaCommunityUrl;
            
            

            PageReference pageRef = Page.VFP_TPA_ClientConfirmRequestedForm;
            pageRef.getParameters().put('id', requestList[0].Id);
            Test.setCurrentPage(pageRef);
            CNT_TPA_ClientConfirmRequestedForm clientConfirm = new CNT_TPA_ClientConfirmRequestedForm();
            clientConfirm.requestValidateOnLoad();
            String Message1 = clientConfirm.Message;
            String jsonData = clientConfirm.jsonData;
            Boolean isRestrictedUser = clientConfirm.isRestrictedUser;
            String objectData = clientConfirm.getObjectTpaRequestToEdit();
            Boolean checkbox1 = true;
            Boolean checkbox2 = true;
            Boolean checkbox3 = true;
            Boolean checkbox4 = true;
			
            TPA_Request__c tpaObj = new TPA_Request__c(Id = requestList[0].Id, Client_Confirmation_Requested_Response__c = 'Disclosure to external legal counsel solely for purposes of obtaining internal legal advice;');
            
		    String reqObj = JSON.serialize(tpaObj );
            CNT_TPA_ClientConfirmRequestedForm.saveRequest(reqObj,checkbox1,checkbox2,checkbox3,checkbox4);
        }
    }
    

}