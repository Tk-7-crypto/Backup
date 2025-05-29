@isTest(SeeAllData=False)
public class TST_CNT_TPA_OfferingNotificationMapping {
    private static Address__c testAccount;
    private static Address__c testAccount1;
    private static CNT_TPA_OfferingNotificationMapping tPAOfferingNotificationMappingContInstance;
    private static TPA_Offering_Notification_Mapping__c offNotObj;
    TPA_Offering_Notification_Mapping__c offNotObj1;
    TPA_Offering_Notification_Mapping__c offNotObj2;
    public static testMethod void TPA_OfferingNotificationMappingContTest() {  
        TST_CNT_TPA_OfferingNotificationMapping instance = new TST_CNT_TPA_OfferingNotificationMapping();
        instance.setupTestData();
        tPAOfferingNotificationMappingContInstance = new CNT_TPA_OfferingNotificationMapping();
        PageReference pageRef = Page.VFP_TPA_Offering_Notification_Mapping;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('VendorAccountName', 'testaccount');
        ApexPages.currentPage().getParameters().put('VendorAccountAddress', 'testa');
        ApexPages.currentPage().getParameters().put('uses', 'testus');
        ApexPages.currentPage().getParameters().put('primaryOfferingName', 'United states');
        ApexPages.currentPage().getParameters().put('secondryOfferingName', 'United states');
        ApexPages.currentPage().getParameters().put('countryName', 'United states');
        List <id> accid = new list <id>();
        accid.add(testAccount.id);
        ApexPages.currentPage().getParameters().put('selectedVendorAccountIDs', JSON.serialize(accid));
        ApexPages.currentPage().getParameters().put('selectedVendorAccountID', testAccount.id);
        ApexPages.currentPage().getParameters().put('OfferingNotificationObjId', offNotObj.id);
        ApexPages.currentPage().getParameters().put('AccountIdList', testAccount.id);
        
        List<TPA_Offering_Notification_Mapping__c> lstofAllTPAOffNotificationMapping = [SELECT Id,Name,IsActive__c,Country__c,Offering_Country_Name__c, IMS_Primary_Data_Asset__r.Asset_Name__c,Primary_Data_Asset_Name__c, IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c,Secondary_Data_Asset_Name__c,IMS_TPA_Purpose__r.Primary_Purpose_Name__c,Purpose_Name__c,Offering_Notifications__r.Page_Name__c,TLLA_Additional_Terms__r.Page_Name__c,Process_Execution_Mode__c,LastModifiedBy.name,lastmodifieddate FROM TPA_Offering_Notification_Mapping__c];
        system.debug('lstofAllTPAOffNotificationMapping:  ss' + lstofAllTPAOffNotificationMapping);
        if(lstofAllTPAOffNotificationMapping != null && lstofAllTPAOffNotificationMapping.size() >= 2){
            tPAOfferingNotificationMappingContInstance.lstofAllTPAOffNotificationMapping = lstofAllTPAOffNotificationMapping;
            tPAOfferingNotificationMappingContInstance.idToUpdate = lstofAllTPAOffNotificationMapping[0].id;
            tPAOfferingNotificationMappingContInstance.idToClone = lstofAllTPAOffNotificationMapping[1].id;
        }
        
        Test.startTest();
        tPAOfferingNotificationMappingContInstance.getNameOfOffMapping();
        
        tPAOfferingNotificationMappingContInstance.ShowDataToEdit();
        tPAOfferingNotificationMappingContInstance.saveNotificationMapping();
        tPAOfferingNotificationMappingContInstance.getTPAOffNotificationMappings();
        
        tPAOfferingNotificationMappingContInstance.CreteClonedCopy();
        tPAOfferingNotificationMappingContInstance.runSearch();
        tPAOfferingNotificationMappingContInstance.toggleSort();
        tPAOfferingNotificationMappingContInstance.exportAll();
        tPAOfferingNotificationMappingContInstance.resetOffId();
        tPAOfferingNotificationMappingContInstance.onSearch();
        tPAOfferingNotificationMappingContInstance.refreshPageSize();
        tPAOfferingNotificationMappingContInstance.showSelectedAccounts();
        CNT_TPA_OfferingNotificationMapping.getMapOffNotiIdRcrdWithAddendumRcrdId();
        tPAOfferingNotificationMappingContInstance.PopulateAddendumValue();
		tPAOfferingNotificationMappingContInstance.setAddendumPageName();
        
        Test.stopTest();
    }
    private void setupTestData() {
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        testAccount1 = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test account q',1300);
        
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        
        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        /*IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        imsDataAsset.Asset_Name__c = 'OneKey Database';
        update imsDataAsset;
        IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        IMS_Data_Asset__c imsDataAsset3 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        IMS_Data_Asset__c imsDataAsset4 = UTL_TPA_SetupTestData.createImsDataAsset(false);
        IMS_Data_Asset__c imsDataAsset5 = UTL_TPA_SetupTestData.createImsDataAsset(false);*/

        List<IMS_Data_Asset__c> lstOff = new List<IMS_Data_Asset__c>();

        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset.Asset_Name__c = 'OneKey Data - uuu';
        imsDataAsset.Is_Notification_Required__c = true;
        lstOff.add(imsDataAsset);                                                                                                                                                                                                                                                                                                                                                                                                                
        IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset1.Asset_Name__c = 'OneKey Data - fff';
        imsDataAsset1.Is_Notification_Required__c = false;
        lstOff.add(imsDataAsset1);  
        IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset2.Asset_Name__c = 'test';
        imsDataAsset2.Is_Notification_Required__c = false;
        lstOff.add(imsDataAsset2);  
        IMS_Data_Asset__c imsDataAsset3 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset3.Asset_Name__c = 'test11';
        imsDataAsset3.Is_Notification_Required__c = false;
        lstOff.add(imsDataAsset3);  
        IMS_Data_Asset__c imsDataAsset4 = UTL_TPA_SetupTestData.createImsDataAsset_Template();
        imsDataAsset4.Asset_Name__c = 'test12';
        imsDataAsset4.Is_Notification_Required__c = false;
        lstOff.add(imsDataAsset4);  
        IMS_Data_Asset__c imsDataAsset5 = UTL_TPA_SetupTestData.createImsDataAsset_Template();   
        imsDataAsset5.Asset_Name__c = 'test13';
        imsDataAsset5.Is_Notification_Required__c = false;
        lstOff.add(imsDataAsset5);  
        
        insert lstOff;
        
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset1 = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset1, true, 'test');
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset2 = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset2, true, 'test1');
        
        
        // IMS_TPA_Purpose_Description__c imsTpaPurposeDescription = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id,
        //  insert imsTpaPurposeDescription;
        
        TPA_Text_Editor__c tpaUseDefinition1 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification', Page_Title__c = imsDataAsset.Id, Page_Type__c = 'Tpa Offering Notifications');
        insert tpaUseDefinition1;
        
        TPA_Text_Editor__c tpaUseDefinition2 = UTL_TPA_SetupTestData.createTpaTestEditorData('Client/Vendor Notification', 'Test Offerings Notification', 'Client/Vendor Notification', 'TPA Offering Notifications');
        TPA_Text_Editor__c tpaUseDefinition3 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 3', 'Notification_Content', 'TPA Offering Addendum');
        TPA_Text_Editor__c tpaUseDefinition4 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 4', 'Notification_Content', 'TPA Offering Addendum');
        TPA_Text_Editor__c tpaUseDefinition5 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 5', 'Notification_Content', 'TPA Offering Notifications');
        
        offNotObj = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition3.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj;
        
        TPA_Off_Notification_Account_Mapping__c accmapObj1 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = testAccount.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj.id);
        insert accmapObj1;
        
        TPA_Off_Notification_Account_Mapping__c accmapObj2 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = testAccount1.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj.id);
        insert accmapObj2;
        delete accmapObj2;
        
        offNotObj1 = new TPA_Offering_Notification_Mapping__c(Is_Applicable_for_All_OneKey_Countries__c = true, IMS_Primary_Data_Asset__c = imsDataAsset1.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset1.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition4.id, IsActive__c = true,Country__c = 'United Kingdom');
        insert offNotObj1;
        
        offNotObj2 = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset1.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset1.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition4.id, Offering_Notifications__c = tpaUseDefinition5.id, IsActive__c = true,Country__c = 'Germany');
        insert offNotObj2;
        
        TPA_Off_Notification_Account_Mapping__c accmapObj3 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = testAccount1.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj2.id);
        insert accmapObj3;
    }
    
}