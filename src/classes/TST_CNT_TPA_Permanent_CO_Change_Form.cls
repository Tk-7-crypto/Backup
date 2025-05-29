@isTest(SeeAllData=false) 
public class TST_CNT_TPA_Permanent_CO_Change_Form {
    @TestSetup 
    static void setup() {
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'test@test.com');
        insert tpProcessor;
        
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        List<IMS_Data_Asset__c> lstDataAsset = new List<IMS_Data_Asset__c>();
        IMS_Data_Asset__c dataAsset1 = new IMS_Data_Asset__c(Is_Active__c = true, Asset_Name__c = 'PrimaryDataAsset1', BU__c = 'United States',Geo_Level__c = 'Sub-National',Commercial_Owner_Email__c = 'test@test.com', Commercial_Manager_Name__c = 'TestName',IMS_Legal_Entity__c = 'IQVIA AG');
        IMS_Data_Asset__c dataAsset2 = new IMS_Data_Asset__c(Is_Active__c = true, Asset_Name__c = 'PrimaryDataAsset2', BU__c = 'United States',Geo_Level__c = 'Sub-National',Commercial_Owner_Email__c = 'test@test.com', Commercial_Manager_Name__c = 'TestName', IMS_Legal_Entity__c = 'IQVIA AG');
        IMS_Data_Asset__c dataAsset3 = new IMS_Data_Asset__c(Is_Active__c = true, Asset_Name__c = 'PrimaryDataAsset3', BU__c = 'United States',Geo_Level__c = 'National',Commercial_Owner_Email__c = 'test@test.com', Commercial_Manager_Name__c = 'TestName', IMS_Legal_Entity__c = 'IQVIA AG');
        lstDataAsset.add(dataAsset1);
        lstDataAsset.add(dataAsset2);
        lstDataAsset.add(dataAsset3);
        insert lstDataAsset;
		IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = dataAsset1.id, additional_terms_required__c = true, Is_Active__c = true);
        insert imsSecondaryDataAsset;
        UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();

    }
    @isTest
    static void testSave() {
        Test.startTest();
        CNT_TPA_Permanent_CO_Change_Form testFormData = new CNT_TPA_Permanent_CO_Change_Form();
        system.debug(testFormData.currentLoginUserName);
        system.debug(testFormData.tpProcessorEmail);
        system.debug(CNT_TPA_Permanent_CO_Change_Form.jsonOfferingList);
        CNT_TPA_Permanent_CO_Change_Form.wrapperClassPermanentOwnerDetails Data = new CNT_TPA_Permanent_CO_Change_Form.wrapperClassPermanentOwnerDetails();
        Data.actionSelected = 'addOwner';
        Data.effectiveDate = Datetime.now().format('yyyy-MM-dd');
        Data.newPermanentOwnerEmail = 'testnew@test.com';
        Data.newPermanentOwnerName = 'New Owner';
        Data.tpProcessorEmail = 'test@test.com';
        Data.permanentOwnerEmail = 'test@test.com';
        Data.tpProcessorName = 'US TP Proccessor';
        CNT_TPA_Permanent_CO_Change_Form.WrapperOffRow OfferingList = new CNT_TPA_Permanent_CO_Change_Form.WrapperOffRow();
        OfferingList.country = 'United States';
        OfferingList.offCat = 'National';
        OfferingList.primOffName = 'PrimaryDataAsset1';
        OfferingList.secOffName = 'SecondaryDataAsset';
        OfferingList.selected = true;
        system.debug(UTL_TPA.Tpa50orMoreLicensesEmailIds);
        system.debug(utl_tpa.tpaSetting);
        Data.uniqueOfferingCombinations = new List<CNT_TPA_Permanent_CO_Change_Form.WrapperOffRow>();
        Data.uniqueOfferingCombinations.add(OfferingList);
        CNT_TPA_Permanent_CO_Change_Form.saveRequest(JSON.serialize(Data));
        
        Test.stoptest();
    }
    
}