@isTest(SeeAllData=true)
private class TST_SLT_Report {    
   
    @isTest()
    static void testSelectById(){
        
        Report testReport = [Select Id, Name, DeveloperName From Report Where DeveloperName = :CON_CPQ.ERROR_HANDLING_FOR_SAP_CODE_DEVELOPER_NAME];
        
        Test.startTest();
        	List<Report> reportList = new SLT_Report().selectById(new Set<ID> {testReport.Id});
        Test.stopTest();
        
        System.assertEquals(reportList.size(), 1, 'Report found');        
    }
    
    @isTest()
    static void testSelectById2(){
        
        Report testReport = [Select Id, Name, DeveloperName From Report Where DeveloperName = :CON_CPQ.ERROR_HANDLING_FOR_SAP_CODE_DEVELOPER_NAME];
        
        Test.startTest();
        	List<Report> reportList = new SLT_Report().selectById(new List<String> {testReport.Id});
        Test.stopTest();
        
        System.assertEquals(reportList.size(), 1, 'Report found');        
    }
    
    @isTest()
    static void testSelectReportByDeveloperName(){
        
        Test.startTest();
            Report testReport = new SLT_Report().selectReportByDeveloperName(CON_CPQ.ERROR_HANDLING_FOR_SAP_CODE_DEVELOPER_NAME);
        Test.stopTest();
        
        System.assertNotEquals(testReport, null, 'Report found');        
    }
}