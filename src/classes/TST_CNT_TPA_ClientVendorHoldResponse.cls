@isTest(SeeAllData=false)
public class TST_CNT_TPA_ClientVendorHoldResponse {
    @TestSetup static void setup() {

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
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'Expired';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-1);
        tpaRequest1.ClientContact__c = testContact.Id;
        tpaRequest1.Is_Renewed__c = false;
        tpaRequest1.Purpose_List__c = 'Test Purpose List';
        tpaRequest1.Data_Asset_List__c = 'AAN';
        tpaRequest1.IMS_Legal_Entity_List__c = 'test';
        tpaRequest1.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest1.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest1.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest1.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest1.Vendor_Language__c =  'English';
        tpaRequestList.add(tpaRequest1);

        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest2.OwnerId = UserInfo.getUserId();
        tpaRequest2.Service_Provider_Address__c = testNewClientAccount.Id;
        tpaRequest2.Client_Address__c = testNewClientAccount.Id;
        tpaRequest2.Client_Language__c = 'Japanese';
        tpaRequest2.Vendor_Language__c = 'Japanese';
        tpaRequest2.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest2.Request_Status__c = 'Expired';
        tpaRequest2.Data_Access_End_Date__c = todayDate.addDays(-2);
        tpaRequest2.ClientContact__c = testContact.Id;
        tpaRequest2.Is_Renewed__c = false;
        tpaRequest2.Purpose_List__c = 'Test Purpose List';
        tpaRequest2.Data_Asset_List__c = 'AAN';
        tpaRequest2.IMS_Legal_Entity_List__c = 'test';
        tpaRequest2.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest2.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest2.Request_Status__c = 'Expired';
        tpaRequest2.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest2.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest2.Vendor_Language__c =  'English';
        tpaRequestList.add(tpaRequest2);

        TPA_Request__c tpaRequest3 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest3.OwnerId = UserInfo.getUserId();
        tpaRequest3.Client_Address__c = testNewClientAccount.Id;
        tpaRequest3.Client_Language__c = 'Japanese';
        tpaRequest3.Vendor_Language__c = 'Japanese';
        tpaRequest3.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest3.Request_Status__c = 'Expired';
        tpaRequest3.Data_Access_End_Date__c = todayDate.addDays(-6);
        tpaRequest3.ClientContact__c = testContact.Id;
        tpaRequest3.Is_Renewed__c = false;
        tpaRequest3.Service_Provider_Address__c = testNewClientAccount.Id;
        tpaRequest3.Purpose_List__c = 'Test Purpose List';
        tpaRequest3.Data_Asset_List__c = 'AAN';
        tpaRequest3.IMS_Legal_Entity_List__c = 'test';
        tpaRequest3.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest3.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest3.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest3.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest3.Vendor_Language__c =  'English';
        tpaRequestList.add(tpaRequest3);

        insert tpaRequestList;
        
        

        TPA_Contact__c tpaContact = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaRequest2);
        tpaContact.Email__c = 'test@mail.com';
        update tpaContact;

        TPA_Contact__c tpaContact2 = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaRequest3);
        tpaContact2.Email__c = 'test@mail.com';
        update tpaContact2;

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
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        Test.StartTest();
        List<TPA_Request__c> requestList = [SELECT Id, Name FROM TPA_Request__c LIMIT 3];
        if(requestList.size() > 0) {
            String userProfileName = CNT_TPA_VendorOfferingReturnAck.currentUserProfileName;
            String tpaCommunityUrl = CNT_TPA_VendorOfferingReturnAck.tpaCommunityUrl;
            string renewedReqNo = '12345';
            if(requestList[1] != null) {
                renewedReqNo = requestList[1].Name.split('-')[1];
            }  
            TPA_Agreement_Additional_Field__c additionalfield = new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = requestList[0].Id);
            insert additionalfield;
            
            
            ResponseWrapper wrapper = new ResponseWrapper();
            wrapper.ddnAck1 = false;
            wrapper.ddnAck2 = false; 
            wrapper.ddnAck3 = true;
            wrapper.requestId = requestList[0].Id;
            wrapper.ddnAck2Response = '';
            wrapper.ddnAck3Response = 'hhhhh';

            PageReference pageRef = Page.VFP_TPA_ClientVendorHoldResponse;
            pageRef.getParameters().put('id', requestList[0].Id);
            Test.setCurrentPage(pageRef);
            CNT_TPA_ClientVendorHoldResponse venOffRetAckCon = new CNT_TPA_ClientVendorHoldResponse();
            venOffRetAckCon.requestValidateOnLoad();
            String Message1 = venOffRetAckCon.Message;

            String vendorOffRetAckJSON2 = JSON.serialize(wrapper);
            CNT_TPA_ClientVendorHoldResponse.saveRequest(vendorOffRetAckJSON2);

            venOffRetAckCon.getObjectTpaRequestToEdit();
            venOffRetAckCon.getObjectpurposeIdDataAssetMap();
        }
    }
    
     @isTest static void test_requestValidateOnLoadForClient1() {
         UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
         UTL_TPA_SetupTestData.createAMASetting();
        Test.StartTest();
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 3];
        if(requestList.size() > 0) {
            String userProfileName = CNT_TPA_ClientVendorHoldResponse.currentUserProfileName;
            String tpaCommunityUrl = CNT_TPA_ClientVendorHoldResponse.tpaCommunityUrl;
            
            
            TPA_Agreement_Additional_Field__c additionalfield = new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = requestList[0].Id);
            insert additionalfield;
            
            ResponseWrapper wrapper = new ResponseWrapper();
            wrapper.ddnAck1 = false;
            wrapper.ddnAck2 = true; 
            wrapper.ddnAck3 = false;
            wrapper.requestId = requestList[0].Id;
            wrapper.ddnAck2Response = 'hhhhhhh';
            wrapper.ddnAck3Response = '';
            requestList = [SELECT Id,Client_First_Name__c,Service_Provider_f__c FROM TPA_Request__c where Client_First_Name__c != null AND Service_Provider_f__c != null limit 1];
             system.debug('requestList:' + requestList);
            AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetail( 'IMS', 'Service Bureau II', requestList[0].Id);
            amaAgg.AMA_Services_Provided__c = 'test';
            update amaAgg;
            Account acc2 = [select id, Name,Client_Account_Compliance__c, Vendor_Account_Compliance__c from Account limit 1];
            
            Account_Compliance__c accCompl = new Account_Compliance__c(Account__c = acc2.Id, Client_TPA_Compliance_Hold__c = true, Vendor_TPA_Compliance_Hold__c = true, Client_TPA_Compliance_Hold_Reason__c = 'Client on Hold', Vendor_TPA_Compliance_Hold_Reason__c = 'Vendor on Hold');
            insert accCompl;
            
            PageReference pageRef = Page.VFP_TPA_ClientVendorHoldResponse;
            pageRef.getParameters().put('id', requestList[0].Id);
            Test.setCurrentPage(pageRef);
            CNT_TPA_ClientVendorHoldResponse venOffRetAckCon = new CNT_TPA_ClientVendorHoldResponse();
            venOffRetAckCon.requestValidateOnLoad();

            String vendorOffRetAckJSON2 = JSON.serialize(wrapper );
            CNT_TPA_ClientVendorHoldResponse.saveRequest(vendorOffRetAckJSON2);

        }
   }
    
    @isTest static void test_requestValidateOnLoadForClient2() {
         UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
         UTL_TPA_SetupTestData.createAMASetting();
        Test.StartTest();
        List<TPA_Request__c> requestList = [SELECT Id FROM TPA_Request__c LIMIT 3];
        if(requestList.size() > 0) {
            String userProfileName = CNT_TPA_ClientVendorHoldResponse.currentUserProfileName;
            String tpaCommunityUrl = CNT_TPA_ClientVendorHoldResponse.tpaCommunityUrl;
            
            
            TPA_Agreement_Additional_Field__c additionalfield = new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = requestList[0].Id);
            insert additionalfield;
            
            ResponseWrapper wrapper = new ResponseWrapper();
            wrapper.ddnAck1 = true;
            wrapper.ddnAck2 = false; 
            wrapper.ddnAck3 = false;
            wrapper.requestId = requestList[0].Id;
            wrapper.ddnAck2Response = '';
            wrapper.ddnAck3Response = '';
            requestList = [SELECT Id,Client_First_Name__c,Service_Provider_f__c FROM TPA_Request__c where Client_First_Name__c != null AND Service_Provider_f__c != null limit 1];
             system.debug('requestList:' + requestList);
            AMA_Agreement_Detail__c amaAgg = UTL_TPA_SetupTestData.getAMAAgreementDetail( 'IMS', 'Service Bureau II', requestList[0].Id);
            amaAgg.AMA_Services_Provided__c = 'test';
            update amaAgg;
            
            PageReference pageRef = Page.VFP_TPA_ClientVendorHoldResponse;
            pageRef.getParameters().put('id', requestList[0].Id);
            Test.setCurrentPage(pageRef);
            CNT_TPA_ClientVendorHoldResponse venOffRetAckCon = new CNT_TPA_ClientVendorHoldResponse();
            venOffRetAckCon.requestValidateOnLoad();
            String note2 = CNT_TPA_ClientVendorHoldResponse.note2;
            String note3 = CNT_TPA_ClientVendorHoldResponse.note3;
            List<String> stringList = CNT_TPA_ClientVendorHoldResponse.amaUsesSelected;

            String vendorOffRetAckJSON2 = JSON.serialize(wrapper );
            CNT_TPA_ClientVendorHoldResponse.saveRequest(vendorOffRetAckJSON2);

        }
   }
    
    public class ResponseWrapper
    {
        public Boolean ddnAck1 {get;set;}
        public Boolean ddnAck2 {get;set;}
        public Boolean ddnAck3 {get;set;}
        public String requestId {get;set;}
        public String ddnAck2Response {get;set;}
        public String ddnAck3Response {get;set;}
    }

}