@isTest(seeAllData=false)
public class TST_CNT_TPA_ManualVendorApprovalReport {
    
    private static TPA_Request__c tpaRequest;
    
    @testsetup
    private static void setupTestData() {
        
        Address__c TestAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Account',9999);
        TestAccount.Vendor_Tier__c = 'Y';
        TestAccount.Primary_Vendor_Address__c = true;
        update TestAccount;
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(TestAccount.Id);
        tpaRequest.Is_TPA_Signed_Contract_Attached__c = true;
        tpaRequest.TP_Processor_Email__c = 'ab@gmail.com';
        
        update tpaRequest;
        
        Test.setCreatedDate(tpaRequest.id,  Date.newInstance(2023, 8, 10));
        
        List<IMS_TPA_Purpose__c> listIMSTPAPurpose = new List<IMS_TPA_Purpose__c>();
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail', 
                                                                  Is_Active__c = true);
        listIMSTPAPurpose.add(imsTpaPurpose);

        insert listIMSTPAPurpose;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = tpaRequest.id, BU__c = 'United States', 
                                                       Purpose__c = imsTpaPurpose.id);
        insert tpaPurpose;
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;
        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test',IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;
        
        List<IMS_Data_Asset__c> imsDataAssetList = new List<IMS_Data_Asset__c>();
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', Is_Active__c = true, IMS_Legal_Entity__c = imsLegalEntity.Id);
        imsDataAssetList.add(imsDataAsset);
        insert imsDataAssetList;
        
        List<TPA_Data_Asset__c> tpaDataAssetList = new List<TPA_Data_Asset__c>();
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        tpaDataAssetList.add(tpaDataAsset);
        
        insert tpaDataAssetList;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        tpaSecondaryDataAsset.TPA_Request_Secondary_Assets__c = tpaRequest.Id;
        insert tpaSecondaryDataAsset;  

        Watch_List__c WatchList = new Watch_List__c(Always_Approved__c = false, Vendor_Address__c = TestAccount.id, use__c = 'Test TPA Purpose');
        insert WatchList;
        
    }   
    
    @isTest 
    public static void testManualVendorReport()
    {
        Test.startTest();
        CNT_TPA_ManualVendorApprovalReport obj = new CNT_TPA_ManualVendorApprovalReport();
        obj.getGroupingOptions();
        obj.redirectToExportVAR();
        String priOffs = CNT_TPA_ManualVendorApprovalReport.getPrimaryOfferings('United States');
        String secOffs = CNT_TPA_ManualVendorApprovalReport.getSecondaryOfferings(priOffs,'United States');
        CNT_TPA_ManualVendorApprovalReport.searchData(null , '{"fromDate" : "01/01/2023", "toDate" : "08/20/2023" , "noOfRequestToProcess" : "1","selectedVendor" : "Test Account","purps":"Test TPA Purpose","countries":"United States","priOffs":"MIDAS"}');

        CNT_TPA_ManualVendorApprovalReport.watchListWrapper obj1 = new CNT_TPA_ManualVendorApprovalReport.watchListWrapper(null,null, null, null, null,null, null, null, null);
        Test.stopTest();
    }    
}