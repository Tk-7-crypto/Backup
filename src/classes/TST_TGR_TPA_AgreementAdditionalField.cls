@isTest
public class TST_TGR_TPA_AgreementAdditionalField { 
    private static TPA_Request__c tpaRequest1;
    private static TPA_Agreement_Additional_Field__c tpaAgreeAdditionalObj;
    private static Contact tpaContact;
    private static Address__c testAccount;
    private static Address__c testClientAccount;
    static testMethod void myUnitTest() {
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        
        Date todayDate = Date.today();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test client',1211);
        testClientAccount.City__c = 'test billing city';
        testClientAccount.State__c = 'test billing state';
        update testClientAccount;
        
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        
        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAccount.id);
        tpaRequest1.Client_Address__c = testClientAccount.id;
        tpaRequest1.Request_Status__c = 'In Effect';
        date strtDate = date.newInstance(2014, 1, 1);
        tpaRequest1.Data_Access_Start_Date__c = strtDate.addDays(-5);
        update tpaRequest1;
        
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = 'United States', 
                                                                  Primary_Purpose_Name__c = 'test name', 
                                                                  Purpose_Details__c = 'test detail',
                                                                  Is_Active__c = true);
        insert imsTpaPurpose;
        
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', 
                                                                                 Category_Name__c = 'Expert Analysis', 
                                                                                 isActive__c = true);
        insert tpaPurposeCategory;
        
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',
                                                       Request__c = tpaRequest1.id, 
                                                       BU__c = 'United States', 
                                                       TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                       Purpose__c = imsTpaPurpose.id);
        insert tpaPurpose;
        
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', 
                                                               Geo_Level__c = 'Sub-National', 
                                                               Is_Active__c = true, 
                                                               IMS_Legal_Entity__c='IQVIA AG', 
                                                               Asset_Name__c = 'test');
        insert imsDataAsset;
        
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest1.id, 
                                                               Data_Asset__c = imsDataAsset.id,
                                                               BU__c = 'United States', 
                                                               Purpose__c = tpaPurpose.Id,
                                                               Geo_Level__c = 'Sub-National', 
                                                               Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, 
                                                                                            additional_terms_required__c = true);
        insert imsSecondaryDataAsset;

        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, 
                                                                                            IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,
                                                                                           Secondary_Asset_Name__c = 'testSec1');
        insert tpaSecondaryDataAsset;
        List<TPA_Data_Asset__c> offeringList = [select Id,
                                                       Asset_Name__c, 
                                                       BU__c, 
                                                       Request__c, 
                                                       (select Id, 
                                                               Name, 
                                                               Secondary_Asset_Name__c
                                                        from TPA_Secondary_Data_Assets__r) 
                                                from TPA_Data_Asset__c 
                                                where Request__c =: tpaRequest1.Id];
         system.debug('offeringList: ' + offeringList);
        
        Test.startTest();
        TPA_Agreement_Additional_Field__c tpaAgreeAdditionalObj = new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = tpaRequest1.id, 
                                                                                                       Parent_TPA_Request_Offering_Data__c = 'USA:PriOff1:SecOff1;USA:PriOff2');
        insert tpaAgreeAdditionalObj;
        tpaAgreeAdditionalObj.Vendor_Contact_First_Name__c = 'Test';
        update tpaAgreeAdditionalObj; 
        Test.stopTest();
        
    }

}