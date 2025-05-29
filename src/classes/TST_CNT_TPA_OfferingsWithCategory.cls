@isTest
public class TST_CNT_TPA_OfferingsWithCategory {
    @TestSetup static void setup(){
        TPA_Request__c testTpaRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        insert testTpaRequest;
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', Primary_Purpose_Name__c = 'test name', Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = 'Expert Analysis', isActive__c = true);
        insert tpaPurposeCategory;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',Request__c = testTpaRequest.id, BU__c = 'United States', TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                       Purpose__c = imsTpaPurpose.id);
        insert tpaPurpose;
        
        List<IMS_Data_Asset__c> imsDataAssetList = new List<IMS_Data_Asset__c>();
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = true, IMS_Legal_Entity__c='IQVIA AG', Asset_Name__c = 'test');
        imsDataAssetList.add(imsDataAsset);
        
        IMS_Data_Asset__c imsDataAsset1 = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = false, IMS_Legal_Entity__c='IQVIA AG');
        imsDataAssetList.add(imsDataAsset1);
        
        insert imsDataAssetList;
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = testTpaRequest.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;

        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id);
        insert tpaSecondaryDataAsset;
        
    }
    
    @isTest static void test_getOfferingRecords(){
        List<TPA_Request__c> tpaReqs = [Select Id From TPA_Request__c Limit 1];
        String testUser = CNT_TPA_OfferingsWithCategory.currentUserProfileName;
        Test.startTest();
        CNT_TPA_OfferingsWithCategory.getOfferingRecords(tpaReqs[0].Id,null,1000);
        Test.stopTest();
    }

}