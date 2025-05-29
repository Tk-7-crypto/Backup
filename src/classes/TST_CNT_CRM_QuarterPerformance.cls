@isTest
public class TST_CNT_CRM_QuarterPerformance {
    
    @testSetup
    static void setUpTestData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        List<Opportunity> opportunityList = new List<Opportunity>();        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = 'Clinical';
        opp.StageName = '3. Developing Proposal';
        opp.Amount = 1200;
        opp.CloseDate = System.Today();
        opp.Inside_Sales_Transfer_Date__c = System.Today();
        opp.Early_Engagement_COE__c = 'Gastroenterology';
        opp.Inside_Sales__c = UserInfo.getUserId();
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.FPI_Date__c = System.today();
        opp.Population_Age_Group__c = 'Not Applicable';
        opp.InterventionType__c = 'Device';
        opp.Advanced_Plan__c = 'Test';
        opportunityList.add(opp);
        
        Opportunity oppQuater = UTL_TestData.createOpportunity(acc.Id);
        oppQuater.Line_of_Business__c = 'Clinical';
        oppQuater.StageName = '2. Qualifying Opportunity';
        oppQuater.Amount = 1800;
        oppQuater.CloseDate = System.Today();
        oppQuater.Inside_Sales_Transfer_Date__c = System.Today();
        oppQuater.Early_Engagement_COE__c = 'Gastroenterology';
        oppQuater.Inside_Sales__c = UserInfo.getUserId();
        oppQuater.Potential_Regions__c = 'Asia Pacific';
        oppQuater.FPI_Date__c = System.today();
        oppQuater.Population_Age_Group__c = 'Not Applicable';
        oppQuater.InterventionType__c = 'Device';
        oppQuater.Advanced_Plan__c = 'Test';
        opportunityList.add(oppQuater);
        upsert opportunityList;
    }
    
    @isTest
    static void testGetCurrentQuarterData() {
        Map<String, Object> returnMap = new Map<String,Object>();
        Test.startTest();
        	returnMap = CNT_CRM_QuarterPerformance.getCurrentQuarterData();
        Test.stopTest();
        System.assertEquals(1200, returnMap.get('totalCallAmount'));
        System.assertEquals(1800, returnMap.get('totalBestAmount'));
    }
    
    @isTest
    static void testGetQuarterReportCall() {
        List<opportunity> lstOpptyReport = new List<opportunity>();
        Test.startTest();
        	lstOpptyReport = CNT_CRM_QuarterPerformance.generateCurrentQuarterReport('ISOpsCall');
        Test.stopTest();
        System.assertEquals((lstOpptyReport != null), true);
    }
    
    @isTest
    static void testGetQuarterReportBest() {
        List<opportunity> lstOpptyReport = new List<opportunity>();
        Test.startTest();
        	lstOpptyReport = CNT_CRM_QuarterPerformance.generateCurrentQuarterReport('ISOpsBest');
        Test.stopTest();
        System.assertEquals((lstOpptyReport != null), true);
    }
}