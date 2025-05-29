@isTest(seeAllData = false)
public class TST_CNT_TPA_AllTPA_Country_Workbook {
    @testSetup
    public static void setup(){
        List<IMS_Data_Asset__c> lsDataAsset = new List<IMS_Data_Asset__c>();
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'test@test.com');
        insert tpProcessor;
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States',Additional_Terms_Required__c = true, Requires_Fee__c = false, Commercial_Manager_Name__c = 'Test Manager', Commercial_Owner_Email__c = 'Test.Owner@mail.com', Is_AMA_Required__c = true, Is_Restricted_Data__c = true, Requires_Manual_Review__c = true,  IMS_Legal_Name__c = 'TestLegal', Geo_Level__c = 'Sub-National', Is_Active__c = true, IMS_Legal_Entity__c='IQVIA AG', Asset_Name__c = 'test');
        lsDataAsset.add(imsDataAsset);
        IMS_Data_Asset__c imsDataAsset2 = new IMS_Data_Asset__c(BU__c = 'United States',Additional_Terms_Required__c = true, Requires_Fee__c = false, Commercial_Manager_Name__c = 'Test Manager', Commercial_Owner_Email__c = 'Test.Owner@Mail.com', Is_AMA_Required__c = true, Is_Restricted_Data__c = true, Requires_Manual_Review__c = true,  IMS_Legal_Name__c = 'TestLegal', Geo_Level__c = 'Sub-National', Is_Active__c = true, IMS_Legal_Entity__c='IQVIA AG', Asset_Name__c = 'test');
        lsDataAsset.add(imsDataAsset2);
        insert lsDataAsset;
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, Secondary_Asset_Name__c = 'test', Is_Active__c = true, additional_terms_required__c = true);
        insert imsSecondaryDataAsset;
        
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'IQVIA AG',
                                                                                         Legal_Entity_Name_for_TLLA__c = 'IQVIA AG',
                                                                                         Name_for_ESign__c = 'Test Esign',
                                                                                         Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;
        
        TPA_Text_Editor__c tpatext1 = new TPA_Text_Editor__c(Page_Type__c = 'Hover Descriptions',Page_Name__c = 'test',English_Translation__c = 'abcd');
        TPA_Text_Editor__c tpatext2 = new TPA_Text_Editor__c(Page_Type__c = 'IMS__Legal_Entity__c',Page_Name__c = 'test',English_Translation__c = 'abcd');
    	
        insert tpatext1;
        insert tpatext2;
    }
    @isTest
    public static void myUnitTest() {
        TPA_TP_Processor__c tpProcessor = [Select TP_Processor_Name__c from TPA_TP_Processor__c where TP_Processor_Email__c = 'test@test.com'];
        CNT_TPA_AllTPA_Country_Workbook.searchData(null,'United States;UK');
        CNT_TPA_AllTPA_Country_Workbook.searchData(null,':'+tpProcessor.TP_Processor_Name__c);
        CNT_TPA_AllTPA_Country_Workbook cnt = new CNT_TPA_AllTPA_Country_Workbook();
        CNT_TPA_AllTPA_Country_Workbook.getAdditionalTerms(new IMS_Data_Asset__c(Asset_Name__c='Ambulatory electronic medical records data',BU__c='United States'),null);
        CNT_TPA_AllTPA_Country_Workbook.getAdditionalTerms(new IMS_Data_Asset__c(Asset_Name__c='IQVIA Consumer Aisle',BU__c='South Africa'),null);
        CNT_TPA_AllTPA_Country_Workbook.getAdditionalTerms(new IMS_Data_Asset__c(Asset_Name__c='MIDAS',BU__c='South Africa'),null);
        CNT_TPA_AllTPA_Country_Workbook.getAdditionalTerms(new IMS_Data_Asset__c(Asset_Name__c='Patient Companion File (PatCo) - Formerly Patient Reference File',BU__c='United States'),null);
        CNT_TPA_AllTPA_Country_Workbook.getAdditionalTerms(new IMS_Data_Asset__c(Asset_Name__c='Patient Reference File',BU__c='South Africa'),null);
        CNT_TPA_AllTPA_Country_Workbook.getAdditionalTerms(new IMS_Data_Asset__c(Asset_Name__c='Payer Companion File',BU__c='United States'),null);
        CNT_TPA_AllTPA_Country_Workbook.getAdditionalTerms(new IMS_Data_Asset__c(Asset_Name__c='LAAD - Longitudinal Access and Adjudication Data',BU__c='South Africa'),null);
        //cnt.redirectToExport();
    }

}
