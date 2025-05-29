@isTest
private class TST_DAOH_TpaSecondaryDataAsset {
	private static TPA_Request__c tpaRequest1;
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
        date strtDate = date.newInstance(2014, 1, 1);
        tpaRequest1.Data_Access_Start_Date__c = strtDate.addDays(-5);
        update tpaRequest1;
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'test', Legal_Entity_Name_for_TLLA__c = 'test Name', Name_for_ESign__c = 'Test Esign',Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;
        
        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test', Tpa_Request__c = tpaRequest1.Id,IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;
        
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurpose('Test TPA Purpose', tpaRequest1, tpaPurposeCategory, imsTpaPurpose, imsLegalEntity);
        
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.createTpaDataAsset(tpaRequest1, tpaPurpose, imsDataAsset, imsLegalEntity);
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = UTL_TPA_SetupTestData.createTPASecondaryDataAsset(tpaDataAsset, imsSecondaryDataAsset, imsLegalEntity, tpaRequest1, 'test');
        
        try{
            delete tpaSecondaryDataAsset;
        }catch(Exception e){
            system.debug(e);
            System.assert(e.getMessage().contains('You do not have necessary permissions to delete this TPA Secondary Data Asset record'));
        }
    }
}