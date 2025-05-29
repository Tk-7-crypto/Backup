/*
*@Author  : Chandra Prakash Pandey
*@Purpose : 1. Test class for TPA_CustomReportDashboardController controller class

*/
@isTest(seeAllData=false)
public class TST_CNT_TPA_CustomReportDashboard {
    
    @TestSetup
    static void setupTestData() {
        UTL_TPA_SetupTestData.createTPAReportsDashboardsSettingdata();
        TPA_Country_Codes__c tpaCountryCode = new TPA_Country_Codes__c();
        tpaCountryCode.Name = 'United States';
        tpaCountryCode.Country_Possible_Codes__c ='US; U.S.; USA; United States';
        tpaCountryCode.Code_Type__c = 'C';
        insert tpaCountryCode;
        TPA_Trending_Reports_Mapping_BU__c reportBUObj = new TPA_Trending_Reports_Mapping_BU__c();
        reportBUObj.Record_Type__c = 'BU Mapping';
        reportBUObj.Business_Units__c = 'CENTRAL, EAST and SOUTH EUROPE';
        reportBUObj.Countries_Under_BU__c = 'Bulgaria';
        insert reportBUObj;
        
    }
    public static testMethod void testLoadReport()
    {
        Test.startTest();
        string settingDB = CNT_TPA_CustomReportDashboard.reportDashboardSettingMapSerialize;
        CNT_TPA_CustomReportDashboard dbReportObj = new CNT_TPA_CustomReportDashboard();
        string chunkSize = dbReportObj.getRequestChunkSize;
        string requestLocations = dbReportObj.getRequestLocations();
        
        CNT_TPA_CustomReportDashboard.ReceivedValues recObj = new CNT_TPA_CustomReportDashboard.ReceivedValues();
        CNT_TPA_CustomReportDashboard ctrlObj = new CNT_TPA_CustomReportDashboard();
        recObj.durationValue = 6;
        recObj.countryLocation = 'All';
        recObj.pageSize = 2000;
        recObj.fromDateValue = '05/05/2015';
        recObj.toDateValue = '05/05/2016';
        CNT_TPA_CustomReportDashboard.getReportDashboardValues(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart2(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart3(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart4(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart5(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart6(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesManualReview(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.loadPrimSecOfferingsByCountryDbResult(JSON.serialize(recObj), null);
        ctrlObj.getCategory();
        ctrlObj.getRequestStatuses();
        Test.stopTest();
    }
    public static testMethod void testLoadReport1()
    {
        Test.startTest();
        string settingDB = CNT_TPA_CustomReportDashboard.reportDashboardSettingMapSerialize;
        CNT_TPA_CustomReportDashboard dbReportObj = new CNT_TPA_CustomReportDashboard();
        string chunkSize = dbReportObj.getRequestChunkSize;
        string requestLocations = dbReportObj.getRequestLocations();
        
        CNT_TPA_CustomReportDashboard.ReceivedValues recObj = new CNT_TPA_CustomReportDashboard.ReceivedValues();
        CNT_TPA_CustomReportDashboard ctrlObj = new CNT_TPA_CustomReportDashboard();
        recObj.durationValue = 6;
        recObj.countryLocation = 'All excluding US';
        recObj.pageSize = 2000;
        recObj.fromDateValue = '05/05/2015';
        recObj.toDateValue = '05/05/2016';
        CNT_TPA_CustomReportDashboard.getReportDashboardValues(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart2(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart3(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart4(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart5(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart6(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesManualReview(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.loadPrimSecOfferingsByCountryDbResult(JSON.serialize(recObj), null);
        ctrlObj.getCategory();
        ctrlObj.getRequestStatuses();
        Test.stopTest();
    }
    public static testMethod void testLoadReport2()
    {
        Test.startTest();
        string settingDB = CNT_TPA_CustomReportDashboard.reportDashboardSettingMapSerialize;
        CNT_TPA_CustomReportDashboard dbReportObj = new CNT_TPA_CustomReportDashboard();
        string chunkSize = dbReportObj.getRequestChunkSize;
        string requestLocations = dbReportObj.getRequestLocations();
        
        CNT_TPA_CustomReportDashboard.ReceivedValues recObj = new CNT_TPA_CustomReportDashboard.ReceivedValues();
        CNT_TPA_CustomReportDashboard ctrlObj = new CNT_TPA_CustomReportDashboard();
        recObj.durationValue = 6;
        recObj.countryLocation = 'United States';
        recObj.pageSize = 2000;
        recObj.fromDateValue = '05/05/2015';
        recObj.toDateValue = '05/05/2016';
        CNT_TPA_CustomReportDashboard.getReportDashboardValues(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart2(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart3(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart4(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart5(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart6(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesManualReview(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.loadPrimSecOfferingsByCountryDbResult(JSON.serialize(recObj), null);
        ctrlObj.getCategory();
        ctrlObj.getRequestStatuses();
        Test.stopTest();
    }
    public static testMethod void testLoadReport3()
    {
        Test.startTest();
        string settingDB = CNT_TPA_CustomReportDashboard.reportDashboardSettingMapSerialize;
        CNT_TPA_CustomReportDashboard dbReportObj = new CNT_TPA_CustomReportDashboard();
        string chunkSize = dbReportObj.getRequestChunkSize;
        string requestLocations = dbReportObj.getRequestLocations();
        
        CNT_TPA_CustomReportDashboard.ReceivedValues recObj = new CNT_TPA_CustomReportDashboard.ReceivedValues();
        CNT_TPA_CustomReportDashboard ctrlObj = new CNT_TPA_CustomReportDashboard();
        recObj.durationValue = 6;
        recObj.countryLocation = 'BU - CENTRAL, EAST and SOUTH EUROPE';
        recObj.pageSize = 2000;
        recObj.fromDateValue = '05/05/2015';
        recObj.toDateValue = '05/05/2016';
        CNT_TPA_CustomReportDashboard.getReportDashboardValues(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart2(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart3(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart4(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart5(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesPart6(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.getReportDashboardValuesManualReview(JSON.serialize(recObj), null);
        CNT_TPA_CustomReportDashboard.loadPrimSecOfferingsByCountryDbResult(JSON.serialize(recObj), null);
        ctrlObj.getCategory();
        ctrlObj.getRequestStatuses();
        Test.stopTest();
    }
}