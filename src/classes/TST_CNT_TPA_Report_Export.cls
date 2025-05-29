@isTest(seeAllData=false)
public class TST_CNT_TPA_Report_Export {
    @testsetup
    private static void setupTestData() {
        tpa_request__c tpaRequest;
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
    
    public static testMethod void testLoadRecords(){
        CNT_TPA_Report_Export cnt = new CNT_TPA_Report_Export();
        CNT_TPA_Report_Export.loadRecords(null, 'Select Id From TPA_Request__c where is_Bulk_TPA_Request__c = true');
        IMS_Data_Asset__c ims = UTL_TPA_SetupTestData.createImsDataAsset(false);
        CNT_TPA_Report_Export.loadOffRecords(null, 'United States;');
        CNT_TPA_Report_Export.loadTAT2Records(null, '{"dayRange":"16-21","statusCategorySelected":"Client Request Submission-In Effect Date","clientName":"","vendorName":"test","submittingCountries":["United States"],"fromDate":"' + DateTime.newInstance(2023,06,30).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + '","toDate":"'+ DateTime.newInstance(2023,07,23).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') +'"}');
    	
        IMS_Master_Legal_Entity__c testEntity = new IMS_Master_Legal_Entity__c( Name = 'test', Name_for_ESign__c = 'testName', IMS_Entity_Address__c = 'testAddress');
        insert testEntity;
        IMS_Data_Asset__c testAsset = new IMS_Data_Asset__c(IMS_Legal_Entity__c = testEntity.id);
        insert testAsset;
        CNT_TPA_Report_Export.loadLegalEntitywithOffRecords(testAsset.id, 'Select Id,Asset_Name__c,BU__c, IMS_Legal_Entity__c, (select id,Secondary_Asset_Name__c from IMS_Secondary_Data_Assets__r WHERE Is_Active__c = true) from IMS_Data_Asset__c WHERE  Is_Active__c = true ');
        String toDate = (DateTime.now()).format('MM/dd/yyyy');
        String fromDate = (DateTime.newInstance(2023, 1, 1)).format('MM/dd/yyyy');
        String conditions = '{"fromDate":"' + fromDate +'","toDate":"' + toDate + '","pageSize":"100"}';
        CNT_TPA_Report_Export.loadTPSAReport(null,conditions);
        
        CNT_TPA_Report_Export.manualVendorApproval(null , '{"fromDate" : "' + fromDate + '", "toDate" : "'+ toDate + '" , "noOfRequestToProcess" : "10", "selectedVendor" : "Test Account"}');
        //CNT_TPA_Report_Export.searchCountryWorkbook(null, 'United States;');
    }
}