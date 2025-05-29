@isTest
public class TST_SalesTeamDashboard_PCHierarchyHelper {
    private static SalesTeam_DashboardController controller;
    private static SalesteamDashboard_DataSetUp testDataCon;  
    
    static void setUpController(Sales_Revenue__c sr){  
        ApexPages.StandardController stc = new ApexPages.StandardController(sr);   
        controller = new SalesTeam_DashboardController(stc);
    } 
    
    static void setUpTestData()  {
        testDataCon = new SalesteamDashboard_DataSetUp();
        testDataCon.setUpRegions();
        testDataCon.setUpAccounts();
        testDataCon.setUpUsers(); 
        testDataCon.setUpUserHierarchies();
    }    
    @isTest
    static void testEkamUserFlow()
    {
        setUpTestData();
        List<Account_Manager__c> accMgr = new List<Account_Manager__c>();
        Account_Manager__c accMgr1 = new Account_Manager__c(Role__c = 'EKAM', Account__c = testDataCon.superParentAcc1.id , user__c = testDataCon.ekamUser.id);
        accMgr.add(accMgr1);
        Account_Manager__c accMgr2 = new Account_Manager__c(Role__c = 'EKAM', Account__c = testDataCon.superParentAcc2.id, user__c = testDataCon.ekamUser.id);
        accMgr.add(accMgr2);
        insert accMgr;
        System.runas(testDataCon.ekamUser)
        { 
            Sales_Revenue__c s = new Sales_Revenue__c();
            List<String> lstSPAccounts = new List<String>();
            lstSPAccounts.add(testDataCon.superParentAcc1.SAP_Reference__c);
            lstSPAccounts.add(testDataCon.superParentAcc2.SAP_Reference__c);
            setUpController(s);
            test.startTest();
            controller.userFlow(); 
            controller.filterOptions.ParentAccount = new List<String>();
            controller.go();
            test.stopTest();
            
        }
    }
}