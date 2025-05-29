@isTest
public class TST_CNT_CPQ_ATCAdminWizard {
    private static String createJSONData()
    {
        JSONGenerator testJSON = JSON.createGenerator(true);
        testJSON.writeStartObject();
        testJSON.writeStringField('Migration Id', 'AO-000001');
        testJSON.writeNumberField('Market Share', 1.21);
        testJSON.writeEndObject();
        String jsonString = testJSON.getAsString();
        return jsonString;
    }
    
    @isTest
    static void testUpdateATCOTCData(){
        String testJSONData = createJSONData();
        Test.startTest();
        String jobId = CNT_CPQ_ATCAdminWizard.updateATCOTCData('['+testJSONData+']', '2022 Q1');
        String jobStatus = CNT_CPQ_ATCAdminWizard.checkBatchJobStatus(jobId);
        Test.stopTest();
        System.assert( jobId != null, 'Update Batch called successfully');
        System.assert( jobStatus != null, 'Update Batch run');
    }
    @isTest(SeeAllData='true')
    public static void testGetReportRecordId() {
        List <Report> reportList = [SELECT Id, DeveloperName FROM Report where
                                    DeveloperName = 'ATC_OTC_Classifications_Report_xTR'];
        Test.startTest();
        String reportName = (String)reportList.get(0).get('DeveloperName');
        String result = CNT_CPQ_ATCAdminWizard.getReportRecordId(reportName);
        Test.stopTest();
        System.assert(result != null, 'ATC_OTC_Classifications_Report Successfully runs');  
    }
}