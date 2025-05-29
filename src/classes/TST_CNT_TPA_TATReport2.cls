@isTest(seeAllData = false)
public class TST_CNT_TPA_TATReport2 {
    public static testMethod void testReportMethods() {
        Test.startTest();
        Address__c TestAccount = TST_EXT_TPA_GenerateAndSendDoc.getTestAccount();  
        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Client_Region__c = 'US';
        tpaRequest.Data_Provided_By__c = 'IMS in lieu of Client';
        tpaRequest.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaRequest.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest.Service_Provider_Address__c = TestAccount.Id;
        tpaRequest.Vendor_Company_Name__c = 'Test company';
        tpaRequest.Secondary_Client_Contact_Territory__c = 'France';
        tpaRequest.In_IMS_Review__c = System.now();
        tpaRequest.Sent_for_Signature__c = System.now();
        tpaRequest.Is_Submitted__c = true;
        date strtDate = date.newInstance(2014, 1, 1);
        tpaRequest.Data_Access_Start_Date__c = strtDate;
        tpaRequest.Data_Access_End_Date__c = strtDate.addDays(2);
        tpaRequest.Requires_Manual_Review__c = false;
        tpaRequest.TP_Processor_Email__c = 'a.a@gmail.com';
        tpaRequest.TP_Processor_Name__c = 'Test TP Processor';
        tpaRequest.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        tpaRequest.TPA_Authorised_Signer__c = 'No';
        tpaRequest.Client_Address__c = TestAccount.Id;
        tpaRequest.Service_Provider_Address__c = TestAccount.Id;
        tpaRequest.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        tpaRequest.Secondary_Client_Contact_Territory__c = 'France';
        tpaRequest.In_IMS_Review__c = System.now();
        tpaRequest.Sent_for_Signature__c = System.now();
        insert tpaRequest;
        
        TPA_Purpose_Category__c tpaPurposeCategory2 = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest);
        tpaPurpose.Request__c = tpaRequest.id;
        tpaPurpose.TPA_Purpose_Category__c = tpaPurposeCategory2.id;
        insert tpaPurpose;
        
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'test data asset');
        imsDataAsset.BU__c = 'United States';
        imsDataAsset.Geo_Level__c = 'Sub-National';
        insert imsDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose.id);
        tpaDataAsset.Request__c = tpaRequest.id;
        tpaDataAsset.Data_Asset__c = imsDataAsset.id;
        tpaDataAsset.BU__c = 'United States';
        tpaDataAsset.Geo_Level__c = 'Sub-National';
        tpaDataAsset.Asset_NametText__c = 'MIDAS';
        insert tpaDataAsset;
        
        Test.stopTest();
        CNT_TPA_TATReport2.allConditions objConditions = new CNT_TPA_TATReport2.allConditions();
        objConditions.dayRange = '0-0';
        objConditions.statusCategorySelected = 'In IMS Review-Sent For Signature';
        objConditions.fromDate = Date.today();
        objConditions.toDate = Date.today();
        objConditions.submittingCountries = new List<String>{'France'};
          
        CNT_TPA_TATReport2 objCon = new CNT_TPA_TATReport2();
        objCon.redirectToExport();
        objCon.getGroupingOptions();
        //objCon.getSubmittingCountry();
        CNT_TPA_TATReport2.getReportResult(JSON.serialize(objConditions), 10, null);
    }
}