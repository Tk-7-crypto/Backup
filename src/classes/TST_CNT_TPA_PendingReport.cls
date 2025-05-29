/**
 * Author: Neetu Bansal
 * Since: August 7, 2015
 * Name: TST_TPA_PendingReportController
 * Description: Test class of controller class TPA_PendingReportController
 *              Added under ER-1722
**/
@isTest
private class TST_CNT_TPA_PendingReport {

    @testSetup
    static void setupData() {
        UTL_TPA_SetupTestData.createStatusSequenceSettingData();
        UTL_TPA_SetupTestData.createGlobalHolidaysSettingData();

        Date todayDate = Date.today();

        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest.Client_Address__c = testAccount1.Id;
        tpaRequest.Client_Language__c = 'Japanese';
        tpaRequest.Vendor_Language__c = 'Japanese';
        tpaRequest.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest.Client_Region__c = 'US';
        tpaRequest.Data_Provided_By__c = 'IQVIA in lieu of Client';
        tpaRequest.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaRequest.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest.TPA_Request_Marked_as__c = 'Public';
        tpaRequest.Vendor_Company_Name__c = 'Test company';
        tpaRequest.Client_Address__c = testAccount1.Id;
        tpaRequest.Client_Contact_Territory__c = 'United States';
        tpaRequest.Is_Submitted__c = true;
        tpaRequest.Request_status__c = 'Awaiting Vendor Submission';
        tpaRequest.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest.Purpose_List__c = 'Test Purpose List';
        tpaRequest.Data_Asset_List__c = 'AAN';
        tpaRequest.IMS_Legal_Entity_List__c = 'test';
        tpaRequest.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest.Client_Request_Submission__c = todayDate.addDays(2);
        tpaRequest.Is_Mail_Feature_Required__c = true;
        tpaRequest.Data_Access_Start_Date__c = Date.today();
        tpaRequest.Data_Access_End_Date__c = Date.today().addDays(2);
        tpaRequest.Requires_Manual_Review__c = false;
        tpaRequest.TP_Processor_Email__c = 'a.a@gmail.com';
        tpaRequest.TP_Processor_Name__c = 'Test TP Processor';
        tpaRequest.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        tpaRequest.TPA_Authorised_Signer__c = 'Yes';
        tpaRequest.Client_Address__c = testAccount1.Id;
        tpaRequest.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        tpaRequest.Request_status__c = 'Awaiting Vendor Submission';
        tpaRequest.Vendor_Contact_First_Name_Client__c = 'Test Client First Name';
        tpaRequest.Client_Request_Submission__c = todayDate.addDays(-5);
        tpaRequest.Vendor_App_Sent__c = todayDate.addDays(-5);
        tpaRequest.Vendor_App_Submitted__c = todayDate;
        tpaRequest.In_IMS_Review__c = todayDate;
        insert tpaRequest;

        //Bulkified Data - Start

        UTL_TPA_SetupTestData.createTpaRequestATC(tpaRequest);
        IMS_Master_Legal_Entity__c imsMasterLegalEntity =  UTL_TPA_SetupTestData.getImsMasterLegalEntity();
        IMS_Legal_Entity__c imsLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity(tpaRequest, imsMasterLegalEntity);

        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createImsTPAPurposeData('United States', 'test name');
        imsTpaPurpose1.Purpose_Details__c = 'test detail';
        imsTpaPurpose1.Is_Active__c = true;
        update imsTpaPurpose1;

        IMS_TPA_Purpose__c imsTpaPurpose2 = UTL_TPA_SetupTestData.createImsTPAPurposeData('United States', 'test name2');
        imsTpaPurpose2.Purpose_Details__c = 'test detail2';
        imsTpaPurpose2.Is_Active__c = true;
        update imsTpaPurpose2;

        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');

        TPA_Purpose__c tpaPurpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest);
        tpaPurpose1.TPA_Purpose_Category__c = tpaPurposeCategory.Id;
        // tpaPurpose1.Purpose__c = imsTpaPurpose1.Id;
        tpaPurpose1.Request__c = tpaRequest.Id;
        tpaPurpose1.Name = 'Test TPA Purpose';
        tpaPurpose1.BU__c = 'United States';
        insert tpaPurpose1;

        TPA_Purpose__c tpaPurpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest);
        tpaPurpose2.TPA_Purpose_Category__c = tpaPurposeCategory.Id;
        // tpaPurpose2.Purpose__c = imsTpaPurpose2.Id;
        tpaPurpose2.Name = 'Other';
        tpaPurpose2.BU__c = 'United States';
        insert tpaPurpose2;

        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        insert imsDataAsset;

        TPA_Data_Asset__c tpaDataAsset1 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose1.Id);
        tpaDataAsset1.Request__c = tpaRequest.id;
        tpaDataAsset1.Data_Asset__c = imsDataAsset.id;
        tpaDataAsset1.BU__c = 'United States';
        tpaDataAsset1.Geo_Level__c = 'Sub-National';
        tpaDataAsset1.Asset_NametText__c = 'MIDAS';
        insert tpaDataAsset1;

        TPA_Data_Asset__c tpaDataAsset2 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose2.Id);
        tpaDataAsset2.Request__c = tpaRequest.id;
        tpaDataAsset2.Data_Asset__c = imsDataAsset.id;
        tpaDataAsset2.BU__c = 'United States';
        tpaDataAsset2.Geo_Level__c = 'Sub-National';
        tpaDataAsset2.Asset_NametText__c = 'MIDAS';
        insert tpaDataAsset2;

        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAsset.Primary_Data_Asset__c = imsDataAsset.id;
        imsSecondaryDataAsset.additional_terms_required__c = true;
        insert imsSecondaryDataAsset;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset1 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset1.TPA_Data_Asset__c = tpaDataAsset1.id;
        tpaSecondaryDataAsset1.IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id;
        insert tpaSecondaryDataAsset1;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset2.TPA_Data_Asset__c = tpaDataAsset2.id;
        tpaSecondaryDataAsset2.IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id;
        insert tpaSecondaryDataAsset2;

        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory1 = UTL_TPA_SetupTestData.createImsTpaPurposeCategory(imsTpaPurpose1, tpaPurposeCategory);
        insert imsTpaPurposeCategory1;

        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2 = UTL_TPA_SetupTestData.createImsTpaPurposeCategory(imsTpaPurpose2, tpaPurposeCategory);
        insert imsTpaPurposeCategory2;

        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription1 = UTL_TPA_SetupTestData.createImsTpaPurposeDescription(imsTpaPurpose1, tpaPurposeCategory);
        insert imsTpaPurposeDescription1;

        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = UTL_TPA_SetupTestData.createImsTpaPurposeDescription(imsTpaPurpose2, tpaPurposeCategory);
        insert imsTpaPurposeDescription2;

        TPA_Purpose_Description__c tpaPurposeDescription1 = UTL_TPA_SetupTestData.createTpaPurposeDescription(tpaPurpose1, imsTpaPurposeDescription1);
        tpaPurposeDescription1.Other_Details__c = 'Test Other details';
        tpaPurposeDescription1.Description_Text__c = 'Test Desc Text';
        insert tpaPurposeDescription1;

        TPA_Purpose_Description__c tpaPurposeDescription2 = UTL_TPA_SetupTestData.createTpaPurposeDescription(tpaPurpose2, imsTpaPurposeDescription2);
        tpaPurposeDescription2.Other_Details__c = 'Test Other details2';
        tpaPurposeDescription2.Description_Text__c = 'Test Desc Text2';
        insert tpaPurposeDescription2;
    }

    /**
     * To test the data
    **/
    private static testmethod void insertUpdateTest() {
        Test.startTest();
            // Create the instance of visualforce page and put contact id into parameters
            Test.setCurrentPageReference(new PageReference('Page.VFP_TPA_PendingReport'));

            // Create controller clas instance
            CNT_TPA_PendingReport controller = new CNT_TPA_PendingReport();

        	controller.currentDateReq = new TPA_Request__c();
            // Call methods
            //controller.getSubmittingCountry();
            controller.removeGrid();
            controller.getGroupingOptions();
            controller.showGrid();

        	CNT_TPA_PendingReport.setFieldMaps();

        	CNT_TPA_PendingReport.fetchRequests(null,'{"vendorName":"Test Acc","clientName":"","countries":"United States","status":"All","fromDate":"01/01/2023","toDate":"08/03/2023"}');
        
            // Call method
            controller.saveReport();
        Test.stopTest();
    }

}