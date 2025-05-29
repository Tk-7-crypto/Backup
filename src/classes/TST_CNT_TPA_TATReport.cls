/**
 * Author: Neetu Bansal
 * Since: August 6, 2015
 * Name: TPA_TATReportControllerTest
 * Description: Test class of controller class TPA_TATReportController
 *              Added under ER-1722
**/
@isTest(seeAllData = false)
private class TST_CNT_TPA_TATReport {
    /**
     * To test the data
    **/
    private static testmethod void insertUpdateTest() 
    {
        // Call default settings
        // Create Account
        Address__c acc = UTL_TPA_SetupTestData.getAccount();
        insert acc;
        
        // Create Custom settings
        TPA_Status_Sequence__c seq = UTL_TPA_SetupTestData.getTpaStatusSequenceRecord('0', 'Awaiting Vendor Submission');
        TPA_Status_Sequence__c seq1 = UTL_TPA_SetupTestData.getTpaStatusSequenceRecord('1', 'In Review By IQVIA');
        TPA_Status_Sequence__c seq2 = UTL_TPA_SetupTestData.getTpaStatusSequenceRecord('2', 'Awaiting Vendor Signature');
        TPA_Status_Sequence__c seq3 = UTL_TPA_SetupTestData.getTpaStatusSequenceRecord('3', 'Expired');
        
        List<TPA_Status_Sequence__c> sequences = new List<TPA_Status_Sequence__c>{ seq, seq1, seq2, seq3 };
        insert sequences;
        
        // Create TPA Request
        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Client_Region__c = 'US';
        tpaRequest.Data_Provided_By__c = 'IQVIA in lieu of Client';
        tpaRequest.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaRequest.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest.Service_Provider_Address__c = acc.Id;
        tpaRequest.TPA_Request_Marked_as__c = 'Public';
        tpaRequest.Vendor_Company_Name__c = 'Test company';
        tpaRequest.Client_Address__c = acc.Id;
        tpaRequest.Client_Contact_Territory__c = 'United States';
        tpaRequest.Is_Submitted__c = true;
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Is_Mail_Feature_Required__c = true;
        tpaRequest.Data_Access_Start_Date__c = Date.today();
        tpaRequest.Data_Access_End_Date__c = Date.today().addDays(2);
        tpaRequest.Requires_Manual_Review__c = false;
        tpaRequest.TP_Processor_Email__c = 'a.a@gmail.com';
        tpaRequest.TP_Processor_Name__c = 'Test TP Processor';
        tpaRequest.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        tpaRequest.TPA_Authorised_Signer__c = 'Yes';
        tpaRequest.Client_Address__c = acc.Id;
        tpaRequest.Service_Provider_Address__c = acc.Id;
        tpaRequest.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        tpaRequest.Request_status__c = 'Cancelled';
        tpaRequest.Vendor_Contact_First_Name_Client__c = 'Test Client First Name';
        tpaRequest.Client_Request_Submission__c = Date.today().addDays(-5);
        tpaRequest.Vendor_App_Submitted__c = Date.today();
        tpaRequest.In_IMS_Review__c = Date.today();
        insert tpaRequest;
        
        // Create ATC
        ATC__c tpaATC = new ATC__c( ATC_Code__c = '123', Name_Eng__c = 'Test ATC' );
        insert tpaATC;
        
        // Create TPA Request ATC
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c( TPA_Request__c = tpaRequest.id, ATC__c = tpaATC.id );
        insert tpaRequestATC;
        
        // Create IMS TPA Purpose
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States', 'test name');
        
        // Create IMS TPA Purpose
        IMS_TPA_Purpose__c imsTpaPurpose2 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States', 'test name2');
        
        // Create TPA Purpose Category
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        
        // Create TPA Purpose Category
        TPA_Purpose_Category__c tpaPurposeCategory2 = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        
        // Create TPA Purpose
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest);
        tpaPurpose.TPA_Purpose_Category__c = tpaPurposeCategory.id;
        tpaPurpose.Request__c = tpaRequest.id;
        insert tpaPurpose;
        
        // Create TPA Purpose
        TPA_Purpose__c tpaPurpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest);
        tpaPurpose2.Name = 'Other';
        tpaPurpose2.TPA_Purpose_Category__c = tpaPurposeCategory2.id;
        tpaPurpose2.Request__c = tpaRequest.id;
        insert tpaPurpose2;
        
        // Create IMS Data Asset
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'test data asset');
        imsDataAsset.BU__c = 'United States';
        insert imsDataAsset;
        
        // Create TPA Data Asset
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose.id);
        tpaDataAsset.Request__c = tpaRequest.id;
        tpaDataAsset.Data_Asset__c = imsDataAsset.id;
        tpaDataAsset.BU__c = 'United States';
        tpaDataAsset.Geo_Level__c = 'Sub-National';
        tpaDataAsset.Asset_NametText__c = 'MIDAS';
        insert tpaDataAsset;
        
        // Create TPA Data Asset
        TPA_Data_Asset__c tpaDataAsset2 = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose2.id);
        tpaDataAsset2.Request__c = tpaRequest.id;
        tpaDataAsset2.Data_Asset__c = imsDataAsset.id;
        tpaDataAsset2.BU__c = 'United States';
        tpaDataAsset2.Geo_Level__c = 'Sub-National';
        tpaDataAsset2.Asset_NametText__c = 'Other';
        insert tpaDataAsset2;
        
        // Create IMS Secondary Data Asset
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.getImsSecDataAsset();
        imsSecondaryDataAsset.Primary_Data_Asset__c = imsDataAsset.id;
        imsSecondaryDataAsset.additional_terms_required__c = true;
        insert imsSecondaryDataAsset;
        
        // Create IMS Secondary Data Asset
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset.TPA_Data_Asset__c = tpaDataAsset.id;
        tpaSecondaryDataAsset.IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id;
        insert tpaSecondaryDataAsset;
        
        // Create TPA Secondary Data Asset
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset2 = UTL_TPA_SetupTestData.getTpaSecDataAsset();
        tpaSecondaryDataAsset2.TPA_Data_Asset__c = tpaDataAsset2.id;
        tpaSecondaryDataAsset2.IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id;
        insert tpaSecondaryDataAsset2;
        
        // Create TPA Purpose Category
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory = UTL_TPA_SetupTestData.getImsTpaPurpCat();
        imsTpaPurposeCategory.IMS_TPA_Purpose__c = imsTpaPurpose.id;
        imsTpaPurposeCategory.TPA_Purpose_Category__c = tpaPurposeCategory.id;
        insert imsTpaPurposeCategory;
        
        // Create TPA Purpose Category
        IMS_TPA_Purpose_Category__c imsTpaPurposeCategory2 = UTL_TPA_SetupTestData.getImsTpaPurpCat();
        imsTpaPurposeCategory2.IMS_TPA_Purpose__c = imsTpaPurpose2.id;
        imsTpaPurposeCategory2.TPA_Purpose_Category__c = tpaPurposeCategory2.id;
        insert imsTpaPurposeCategory2;
        
        // Create IMS Purpose Description
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = UTL_TPA_SetupTestData.getImsTpaPurpDes();
        imsTpaPurposeDescription.Purpose__c = imsTpaPurpose.id;
        imsTpaPurposeDescription.TPA_Purpose_Category__c = tpaPurposeCategory.id;
        imsTpaPurposeDescription.Is_Active__c = true;
        insert imsTpaPurposeDescription;
        
        // Create IMS Purpose Description
        IMS_TPA_Purpose_Description__c imsTpaPurposeDescription2 = UTL_TPA_SetupTestData.getImsTpaPurpDes();
        imsTpaPurposeDescription2.Purpose__c = imsTpaPurpose2.id;
        imsTpaPurposeDescription2.TPA_Purpose_Category__c = tpaPurposeCategory2.id;
        imsTpaPurposeDescription2.Is_Active__c = true;
        insert imsTpaPurposeDescription2;
        
        // Create TPA Purpose Description
        TPA_Purpose_Description__c tpaPurposeDescription = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurposeDescription.Purpose__c = tpaPurpose.id;
        tpaPurposeDescription.Description__c = imsTpaPurposeDescription.id;
        tpaPurposeDescription.Other_Details__c = 'Test Other details';
        tpaPurposeDescription.Description_Text__c = 'Test Desc Text';
        insert tpaPurposeDescription;
        
        // Create TPA Purpose Description
        TPA_Purpose_Description__c tpaPurposeDescription2 = UTL_TPA_SetupTestData.getTpaPurpDes();
        tpaPurposeDescription2.Purpose__c = tpaPurpose2.id;
        tpaPurposeDescription2.Description__c = imsTpaPurposeDescription2.id;
        tpaPurposeDescription2.Other_Details__c = 'Test Other details2';
        tpaPurposeDescription2.Description_Text__c = 'Test Desc Text2';
        insert tpaPurposeDescription2;
        
        TPA_Country_Codes__c tcc = new TPA_Country_Codes__c(Name = 'United States', Country_Possible_Codes__c = 'US', Code_Type__c ='C');
        insert tcc;
        
        Test.startTest();
            // Create the instance of visualforce page and put contact id into parameters
            PageReference pageRef = Page.VFP_TPA_TATReport;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('sdate', String.valueof(DateTime.now()));
			ApexPages.currentPage().getParameters().put('edate', String.valueOf(DateTime.now()));
            
            // Create controller clas instance
            CNT_TPA_TATReport controller = new CNT_TPA_TATReport();
            
            // Call methods
            controller.getGroupingOptions();
            CNT_TPA_TATReport.fromStatusValue = 'In Review By IQVIA';
            controller.populateToStatus();
            String searchData = '{"fromDate":"' + String.valueOf(Date.today().addDays(-20)) + '","toDate":"' + String.valueOf(Date.today().addDays(20)) + '","fromStatus":"In Review By IQVIA","toStatus":"In Review By IQVIA","submittingCountry":"United States;","vendorName":"","clientName":"TP"}';
            // Call method
            CNT_TPA_TATReport.searchRequest(null, searchData);
        Test.stopTest();
    }
}