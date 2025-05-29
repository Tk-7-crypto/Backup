@isTest(seeAllData = false)
public class TST_CNT_TPA_IMSLegalEntity_with_Offering {
    public static testmethod void myUnitTest() {
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'test@test.com');
        insert tpProcessor;
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = true, IMS_Legal_Entity__c='IQVIA AG', Asset_Name__c = 'test');
        insert imsDataAsset;
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, Secondary_Asset_Name__c = 'test', Is_Active__c = true, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        IMS_Data_Asset__c imsDataAsset4 = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States', Geo_Level__c = 'Sub-National', Is_Active__c = true, IMS_Legal_Entity__c='IQVIA AG');
        insert imsDataAsset4;
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'IQVIA AG',
                                                                                         Legal_Entity_Name_for_TLLA__c = 'IQVIA AG',
                                                                                         Name_for_ESign__c = 'Test Esign',
                                                                                         Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;
        CNT_TPA_IMSLegalEntity_with_Offering.searchData(null,'United States;UK');
        CNT_TPA_IMSLegalEntity_with_Offering cnt = new CNT_TPA_IMSLegalEntity_with_Offering();
        cnt.selectedCountries = new List<String>{'United States'};
        cnt.redirectToExport();
        cnt.getCountryList();
    }

}