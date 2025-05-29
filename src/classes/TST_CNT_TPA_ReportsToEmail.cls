@isTest
public class TST_CNT_TPA_ReportsToEmail {
    
    @isTest(SeeAllData=true)
    static void testCNT_TPA_ReportsToEmail() {
        CNT_TPA_ReportsToEmail obj = new CNT_TPA_ReportsToEmail();
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        Report testReport = [Select Id, Name, DeveloperName From Report Where DeveloperName = 'TPA_Data_Assets_Test'];
        obj.rptId = testReport.id;
        obj.getReportMasterRows();
    }

}