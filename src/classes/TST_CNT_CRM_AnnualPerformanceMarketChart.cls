@isTest
public class TST_CNT_CRM_AnnualPerformanceMarketChart {
    @testSetup
    static void setUpTestData() {
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance(UserInfo.getUserId());
        ac.Quater_Selected__c='All';
        ac.Goal_Marketing__c = 1500;
        upsert ac;
    }
    
    @isTest
    static void testGetMetaData() {
        Map<String, Object> returnMap = new Map<String,Object>();
        Test.startTest();
        	returnMap = CNT_CRM_AnnualPerformanceMarketChart.getMetaData();
        Test.stopTest();
        System.assertEquals(1500, returnMap.get('goal'));
    }
    
    @isTest
    static void testSetMetaData() {
        Test.startTest();
            CNT_CRM_AnnualPerformanceMarketChart.setMetaData(2100,'All','','');
        Test.stopTest();
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance();
        System.assertEquals(2100, ac.Goal_Marketing__c);
    }
    
    @isTest
    static void testGetAllData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = 'Q2 Solutions';
        opp.StageName = '3. Developing Proposal';
        opp.Amount = 1200;
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.CloseDate = Date.today();
        opp.Early_Engagement_COE__c = 'Gastroenterology';
        insert opp;        
        Map<String, Object> returnMap = new Map<String,Object>();
        Test.startTest();
        	returnMap = CNT_CRM_AnnualPerformanceMarketChart.getAllData();
        Test.stopTest();
        System.assertEquals(0, returnMap.get('totalClosedAmount'));
    }
}