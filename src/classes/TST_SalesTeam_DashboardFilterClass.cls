@isTest
public class TST_SalesTeam_DashboardFilterClass {
    private static DashboardDisplayController controller; 
    private static SalesteamDashboard_DataSetUp testDataCon;
    
    static void setUpController() {
        controller = new DashboardDisplayController();
    }
    static void setUpTestDataForFilter()
    {
        testDataCon = new SalesteamDashboard_DataSetUp();
        testDataCon.setUpRegions();
        testDataCon.setUpUsers();
        testDataCon.setUpAccounts();
        testDataCon.setUpUserHierarchies(); 
        testDataCon.setUpSalesRevenueForFilterTesting();
    }
    static testmethod void test1() {
        
        setUpController();
        setUpTestDataForFilter();
        
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);//sales revenue data exists for this sales Team Hierarchy ID
        SalesTeam_DashboardFilterClass filterReturnVal = controller.getFilterCriteria();
        System.assertEquals(filters,filterReturnVal);
        test.startTest();
        for(SelectOption pc : DashboardDisplayController.GraphOptions)
        {
            System.assertEquals(true, pc.getValue().contains('Stage') || pc.getValue().contains('Forecast Category'));
        }
        controller.filterCriteria.selGraphOptn = 'Forecast Category';
        filters.OfferingGroup.add(SalesteamDashboard_DataSetUp.OG_Pharma);
        filters.OfferingSegment.add(SalesteamDashboard_DataSetUp.OS_National);
        filters.OfferingType.add(SalesteamDashboard_DataSetUp.OT_Core);
        filters.COEName.add(SalesteamDashboard_DataSetUp.CN_BrandCS);
        filters.ParentAccount.add(SalesteamDashboard_DataSetUp.OG_Pharma);
        filters.ServiceLine.add(SalesteamDashboard_DataSetUp.OS_National);
        filters.ServiceLineGroup.add(SalesteamDashboard_DataSetUp.OT_Core);
        filters.GlobalProduct.add(SalesteamDashboard_DataSetUp.CN_BrandCS);
        controller.RefreshDashboard();
        test.stopTest();
    }
    static testMethod void test2()  {
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        filters.selGraphOptn = 'Stage';
        controller.setFilterCriteria(filters);
        test.startTest();
        AggregateResult[] lstAggSalesRevBUD = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.BUDGET];
        AggregateResult[] lstAggSalesRevREV = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.REVENUE];
        AggregateResult[] lstAggSalesRevPIPE = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and s.Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE  and (s.Opportunity_Stage__c = '1' or s.Opportunity_Stage__c ='2' or s.Opportunity_Stage__c ='3' or s.Opportunity_Stage__c ='4' or s.Opportunity_Stage__c ='5')];
        AggregateResult[] lstAggSalesRevPIPE6a = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and s.Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE and s.Opportunity_Stage__c = '6'];
        AggregateResult[] lstAggSalesRevPIPE5 = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and s.Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE  and s.Opportunity_Stage__c ='5'];
        decimal expValue =((decimal)lstAggSalesRevBUD[0].get('sumFY') - (decimal)lstAggSalesRevREV[0].get('sumFY'));
        String expValS = ''+(expValue.setScale(0, System.RoundingMode.UP)).format();
        decimal expValue1 =((decimal)lstAggSalesRevBUD[0].get('sumFY') - (decimal)lstAggSalesRevREV[0].get('sumFY') - (decimal)lstAggSalesRevPIPE5[0].get('sumFY') - (decimal)lstAggSalesRevPIPE6a[0].get('sumFY'));
        String expValS1 = ''+(expValue1.setScale(0, System.RoundingMode.UP)).format();
        filters.isJapaneseUser = true;
        controller.setFilterCriteria(filters);
        filters.calcAdjTarget();
        Schema.DescribeFieldResult dfr = BNF2__c.Therapy_Area__c.getDescribe();
        SalesTeam_DashboardFilterClass.populateOptions(dfr);
        SalesTeam_DashboardFilterClass std = new SalesTeam_DashboardFilterClass();
        std.QueryLevel = 'PC';
        std.selectedVP = 'TEST';
        std.queryStr('SimpleExcelLst','Pipeline15');
        std.QueryLevel = 'TM';
        std.queryStr('test','Pipeline6a');
        std.selectedSTHids = new List<String>{'null'};
        std.calcAdjTarget();
        test.stopTest();
    }
}