/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=False)
private class TST_DashboardDisplayController {

private static DashboardDisplayController controller; 
    private static SalesteamDashboard_DataSetUp testDataCon;
    
    static void setUpController() 
    {
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
    
    static void setUpTestDataForPagination()
    {
        testDataCon = new SalesteamDashboard_DataSetUp();
        testDataCon.setUpSalesRevenueForPagination();
    }
 
    //Case - Account Executive View - Data present for the sales Team Hierarchy for a particular account Executive
   static testMethod void testAESalesDataPresent()
    {
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE'; 
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);//sales revenue data exists for this sales Team Hierarchy ID
        SalesTeam_DashboardFilterClass filterReturnVal = controller.getFilterCriteria();
        System.assertEquals(filters,filterReturnVal);
        test.startTest();
            controller.getBudgetData();
            controller.getRevenueData();
            controller.getWnihData();
            controller.getPipelineData();
        test.stopTest();
    }
    
   
     
  //Case - Team View - Data present for the Team
    static testMethod void testTeamSalesDataPresent()
    {
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids = null;
        filters.SelectedTeamCode = new list<String>();
        filters.SelectedTeamCode.add(testDataCon.accExecSTH1.Sales_Team__r.id);
        filters.QueryLevel = 'TM';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
        test.startTest();
            controller.getBudgetData();
            controller.getRevenueData();
            controller.getWnihData();
            controller.getPipelineData();
        test.stopTest();
        
    } 
    
    //Case - Team View - Data present for the Team
    static testMethod void testPCSalesDataPresent()
    {
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.QueryLevel = 'PC';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        filters.selectedProfitCenter = testDataCon.leafRegion1.ProfitCenterCode__c;
        controller.setFilterCriteria(filters);
        test.startTest();
            controller.getBudgetData();
            controller.getRevenueData();
            controller.getWnihData();
            controller.getPipelineData();
        test.stopTest();
        
    } 
    
    /* 
    //Case - Filter Criteria Testing - Quarter
   static testMethod void testQuarterFilter()
    {
        setUpController();
        setUpTestDataForFilter();
       
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
        test.startTest();
        controller.getBudgetData();
        controller.getRevenueData();
        controller.getWnihData();
        controller.getPipelineData();
        List<Sales_Revenue__c> lstSalesRev = [Select id from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id];
        AggregateResult[] lstAggSalesRev = [Select Sum(Gross_Q1_Value__c)sumQ1, Sum(Gross_Q2_Value__c)sumQ2, Sum(Gross_Q3_Value__c)sumQ3, Sum(Gross_Q4_Value__c)sumQ4, Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id];
        
        controller.filterCriteria.Quarter = 'FY';
        System.assertEquals( new List<String>(),controller.lstFilterCriteria );
        controller.RefreshDashboard();
        controller.getBudgetData();
        controller.getRevenueData();
        controller.getWnihData();
        controller.getPipelineData();
        //System.assertEquals(lstSalesRev.size(), controller.budgetPaginator.getResultSize() + controller.revenuePaginator.getResultSize()+ controller.pipelinePaginator.getResultSize() +controller.wnihPaginator.getResultSize());
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumFY'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        
        controller.filterCriteria.Quarter = 'Q1';
        //System.assertEquals('Quarter = \'Q1\'',controller.lstFilterCriteria[0] );
        System.assert(controller.lstFilterCriteria.size() > 0 );
        controller.RefreshDashboard();
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumQ1'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        
        controller.filterCriteria.Quarter = 'Q2';
        System.assert(controller.lstFilterCriteria.size() > 0 );
        controller.RefreshDashboard();
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumQ2'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        
        controller.filterCriteria.Quarter = 'Q3';
        System.assert(controller.lstFilterCriteria.size() > 0 );
        controller.RefreshDashboard();
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumQ3'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        
        controller.filterCriteria.Quarter = 'Q4';
        System.assert(controller.lstFilterCriteria.size() > 0 );
        controller.RefreshDashboard();
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumQ4'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        
        test.stopTest();
    } 
  
  
   
    //Case - Filter Criteria Testing - Offering Group
    static testMethod void testOfferingGroup()
    {
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        filters.OfferingGroup.add(SalesteamDashboard_DataSetUp.OG_Payer);
        controller.setFilterCriteria(filters);
        test.startTest();
        System.assert(controller.lstFilterCriteria.size() > 0 );
        controller.RefreshDashboard();
        
        String queryStr = 'Select id from Sales_Revenue__c where Offering_Group__c in (' + controller.filterCriteria.CommaSeperatedvalues(controller.filterCriteria.OfferingGroup) +  ') and Sales_Team_Hierarchy_AE__c ='+'\''+testDataCon.accExecSTH1.id+'\'';
        List<Sales_Revenue__c> lstSalesRev = Database.query(queryStr);
        controller.getBudgetData();
        controller.getRevenueData(); 
        controller.getWnihData();
        controller.getPipelineData();
        //System.assertEquals(lstSalesRev.size(), controller.budgetPaginator.getResultSize() + controller.revenuePaginator.getResultSize()+ controller.pipelinePaginator.getResultSize() +controller.wnihPaginator.getResultSize());
        
        AggregateResult[] lstAggSalesRev = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Offering_Group__c = :SalesteamDashboard_DataSetUp.OG_Payer];
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumFY'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        test.stopTest();
    }
    
      
    //Case - Filter Criteria Testing - Offering Segment
    static testMethod void testOfferingSegment()
    {
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        filters.OfferingSegment.add(SalesteamDashboard_DataSetUp.OS_Government);
        controller.setFilterCriteria(filters);
        
        test.startTest();
        System.assert(controller.lstFilterCriteria.size() > 0 );
        controller.RefreshDashboard();
        
        
        String queryStr = 'Select id from Sales_Revenue__c where Offering_Segment__c in (' + controller.filterCriteria.CommaSeperatedvalues(controller.filterCriteria.OfferingSegment) +  ') and Sales_Team_Hierarchy_AE__c ='+'\''+testDataCon.accExecSTH1.id+'\'';
        controller.getBudgetData();
        controller.getRevenueData();
        controller.getWnihData();
        controller.getPipelineData();
        List<Sales_Revenue__c> lstSalesRev = Database.query(queryStr);//[Select id from Sales_Revenue__c where Offering_Segment__c in ('Government') and Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id];
       // System.assertEquals(lstSalesRev.size(), controller.budgetPaginator.getResultSize() + controller.revenuePaginator.getResultSize()+ controller.pipelinePaginator.getResultSize() +controller.wnihPaginator.getResultSize());
        
        AggregateResult[] lstAggSalesRev = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Offering_Segment__c = :SalesteamDashboard_DataSetUp.OS_Government];
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumFY'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        test.stopTest();
        
    }
    
    
    //Case - Filter Criteria Testing - Offering Type
    static testMethod void testOfferingType()
    {
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        filters.OfferingType.add(SalesteamDashboard_DataSetUp.OT_Core);
        controller.setFilterCriteria(filters);
        
        test.startTest();
        System.assert(controller.lstFilterCriteria.size() > 0 );
        controller.RefreshDashboard();
        controller.getBudgetData();
        controller.getRevenueData();
        controller.getWnihData();
        controller.getPipelineData();
        String queryStr = 'Select id from Sales_Revenue__c where Offering_Type__c in (' + controller.filterCriteria.CommaSeperatedvalues(controller.filterCriteria.OfferingType) +  ') and Sales_Team_Hierarchy_AE__c ='+'\''+testDataCon.accExecSTH1.id+'\'';
        List<Sales_Revenue__c> lstSalesRev = Database.query(queryStr);
        //List<Sales_Revenue__c> lstSalesRev = [Select id from Sales_Revenue__c where Offering_Type__c in :controller.filterCriteria.OfferingType and Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id];
        //System.assertEquals(lstSalesRev.size(), controller.budgetPaginator.getResultSize() + controller.revenuePaginator.getResultSize()+ controller.pipelinePaginator.getResultSize() +controller.wnihPaginator.getResultSize());
        
        AggregateResult[] lstAggSalesRev = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Offering_Type__c = :SalesteamDashboard_DataSetUp.OT_Core];
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumFY'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        test.stopTest();
    }
    
    //Case - Filter Criteria Testing - COE Name
    static testMethod void testCOEName()
    { 
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        filters.COEName.add(SalesteamDashboard_DataSetUp.CN_BrandCS); 
        controller.setFilterCriteria(filters);
        
        test.startTest();
        System.assert(controller.lstFilterCriteria.size() > 0 );
        controller.RefreshDashboard();
        controller.getBudgetData();
        controller.getRevenueData();
        controller.getWnihData();
        controller.getPipelineData();
        String queryStr = 'Select id from Sales_Revenue__c where COE_Name__c in (' + controller.filterCriteria.CommaSeperatedvalues(controller.filterCriteria.COEName) +  ') and Sales_Team_Hierarchy_AE__c ='+'\''+testDataCon.accExecSTH1.id+'\'';
        List<Sales_Revenue__c> lstSalesRev = Database.query(queryStr);
        //List<Sales_Revenue__c> lstSalesRev = [Select id from Sales_Revenue__c where COE_Name__c in :controller.filterCriteria.COEName and Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id];
        System.assertEquals(lstSalesRev.size(), controller.budgetPaginator.getResultSize() + controller.revenuePaginator.getResultSize()+ controller.pipelinePaginator.getResultSize() +controller.wnihPaginator.getResultSize());
        
        AggregateResult[] lstAggSalesRev = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and COE_Name__c = :SalesteamDashboard_DataSetUp.CN_BrandCS];
        System.assertEquals((Decimal)lstAggSalesRev[0].get('sumFY'), controller.BudgetValue.Gross_Q1_Value__c + controller.RIHvalue.Gross_Q1_Value__c + controller.FY_WNIH_Total.Gross_Q1_Value__c + controller.FY_Pipeline_Total.Gross_Q1_Value__c);
        test.stopTest();
    }
  

     //Case - Test all zero Impact records present
    static testMethod void testAllImpactZero()
    {
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH2.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
                
        test.startTest();
        controller.getBudgetData();
        controller.getRevenueData();
        controller.getWnihData();
        controller.getPipelineData();
        List<Sales_Revenue__c> lstSalesRev = [Select s.id from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH2.id and (s.Gross_Q1_Value__c != 0 or s.Gross_Q2_Value__c != 0 or s.Gross_Q3_Value__c != 0 or s.Gross_Q4_Value__c != 0) and (s.Gross_Q1_Value__c != null or s.Gross_Q2_Value__c != null or s.Gross_Q3_Value__c != null or s.Gross_Q4_Value__c != null)];
        System.assertEquals(lstSalesRev.size(), controller.budgetPaginator.getResultSize() + controller.revenuePaginator.getResultSize()+ controller.pipelinePaginator.getResultSize() +controller.wnihPaginator.getResultSize());
        
        test.stopTest();
    }
     */
     
     
     //add case for stage lst in pipeline section
     
     
     
    //Case - Test commonCalculation & values passed to graph
    static testMethod void testCommonCalculationStageCutoff()
    {
        
        setUpController();
        setUpTestDataForFilter();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        filters.selGraphOptn = 'Stage';
        
        controller.setFilterCriteria(filters);

        test.startTest();
            List<String> lstFltr = new list<String>();
            lstFltr.add('Time Period = \'FY\' ');
            //System.assertEquals(lstFltr.size(),controller.lstFilterCriteria.size());
            AggregateResult[] lstAggSalesRevBUD = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.BUDGET];
            //System.assertEquals(lstAggSalesRevBUD[0].get('sumFY'), controller.Budget_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesRevREV = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.REVENUE];
            //System.assertEquals(lstAggSalesRevREV[0].get('sumFY'), controller.Rih_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesRevPIPE = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and s.Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE  and (s.Opportunity_Stage__c = '1' or s.Opportunity_Stage__c ='2' or s.Opportunity_Stage__c ='3' or s.Opportunity_Stage__c ='4' or s.Opportunity_Stage__c ='5')];
            //System.assertEquals(lstAggSalesRevPIPE[0].get('sumFY'), controller.Pipeline_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesRevPIPE6a = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and s.Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE and s.Opportunity_Stage__c = '6'];
            //System.assertEquals(lstAggSalesRevPIPE6a[0].get('sumFY'), controller.Wnih_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesRevPIPE35 = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and s.Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE  and (s.Opportunity_Stage__c ='3' or s.Opportunity_Stage__c ='4' or s.Opportunity_Stage__c ='5')];
            
            Decimal GvB = ((decimal)lstAggSalesRevBUD[0].get('sumFY') - ((decimal)lstAggSalesRevREV[0].get('sumFY') + (decimal)lstAggSalesRevPIPE6a[0].get('sumFY')));
            //System.assertEquals( GvB , controller.GapvsBudget);
            
            Double WoB = 0;
            if((decimal)lstAggSalesRevBUD[0].get('sumFY') > 0)
                WoB = (((decimal)lstAggSalesRevREV[0].get('sumFY') + (decimal)lstAggSalesRevPIPE6a[0].get('sumFY'))/(decimal)lstAggSalesRevBUD[0].get('sumFY'))*100 ;
            
            //System.assertEquals( WoB.round().format() , controller.WonofBudget.round().format());
            
            Decimal pipeCov15 = 0;
            Decimal pipeCov35 = 0;
            if (GvB != 0)
            {
                pipeCov15 = ((Decimal)lstAggSalesRevPIPE[0].get('sumFY') / GvB)*100; 
                pipeCov35 = ((Decimal)lstAggSalesRevPIPE35[0].get('sumFY') / GvB)*100;
            }
            //System.assertEquals(pipeCov15.round(), (controller.PipelineCoverageAll).round());
            //System.assertEquals(pipeCov35.round(), (controller.PipelineCoverage3to5).round());
        test.stopTest();
    }
    
    
    static testMethod void testCommonCalculationForecastCutOff()
    {
      setUpController();
        setUpTestDataForFilter();
        testDataCon.setUpSalesRevenueForFCFilterTesting();
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        filters.selGraphOptn = 'Forecast Category';
        controller.setFilterCriteria(filters);

        test.startTest(); 
            List<String> lstFltr = new list<String>();
            lstFltr.add('Time Period = \'FY\' ');
            //System.assertEquals(lstFltr.size(),controller.lstFilterCriteria.size());
            AggregateResult[] lstAggSalesFCPipe = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE and IMS_Forecast_Category__c = :SalesTeam_DashboardFilterClass.PIPELINE];
            //System.assertEquals(lstAggSalesFCPipe[0].get('sumFY'), controller.Pipeline_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesFCCommit = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE and IMS_Forecast_Category__c = 'Commit'];
            //System.assertEquals(lstAggSalesFCCommit[0].get('sumFY'), controller.Commit_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesFCBestCase = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE and IMS_Forecast_Category__c = 'Best Case'];
            //System.assertEquals(lstAggSalesFCBestCase[0].get('sumFY'), controller.BestCase_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesFCOnTrack = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE and IMS_Forecast_Category__c = 'On Track'];
            //System.assertEquals(lstAggSalesFCOnTrack[0].get('sumFY'), controller.OnTrack_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesRevBUD = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.BUDGET];
            //System.assertEquals(lstAggSalesRevBUD[0].get('sumFY'), controller.Budget_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesRevREV = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c where Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Scenario__c = :SalesTeam_DashboardFilterClass.REVENUE];
            //System.assertEquals(lstAggSalesRevREV[0].get('sumFY'), controller.Rih_Total.Gross_Q1_Value__c);
            
            AggregateResult[] lstAggSalesRevPIPE6a = [Select Sum(Gross_FY_Value__c) sumFY from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and s.Scenario__c = :SalesTeam_DashboardFilterClass.PIPELINE and s.Opportunity_Stage__c = '6'];
            //System.assertEquals(lstAggSalesRevPIPE6a[0].get('sumFY'), controller.Wnih_Total.Gross_Q1_Value__c);
        test.stopTest();
    }
     
    // Case - Pagination Testing
    static testMethod void testBudgetPagination()
    {
        setUpController();
        setUpTestDataForPagination(); //pushing 25 records for budget Scenario
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
                
        test.startTest();
            controller.getBudgetData();
            
            ApexPages.currentPage().getParameters().put('context','Bud');
            
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.planPaginator.recStr );
            //System.assertEquals(1, controller.planPaginator.currentPage);
            controller.last(); 
            controller.getBudgetData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.planPaginator.recStr );
            //System.assertEquals(3, controller.planPaginator.currentPage);
            //System.assertEquals(true, controller.planPaginator.hasPrev);
            controller.previous();
            controller.getBudgetData();
            //System.assertEquals(' Showing 11 - 20 Of 25 records.' ,controller.planPaginator.recStr );
            //System.assertEquals(2, controller.planPaginator.currentPage);
            //System.assertEquals(true, controller.planPaginator.hasNxt);
            controller.next();
            controller.getBudgetData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.planPaginator.recStr );
            //System.assertEquals(3, controller.planPaginator.currentPage);
            controller.first();
            controller.getBudgetData();
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.planPaginator.recStr );
            //System.assertEquals(1, controller.planPaginator.currentPage);
        test.stopTest();
    }
    
    
    // Case - Pagination Testing
    static testMethod void testBestCasePagination()
    {
        setUpController();
        setUpTestDataForPagination(); //pushing 25 records for budget Scenario
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
                
        test.startTest();
            controller.getBestCaseFCData();
            
            ApexPages.currentPage().getParameters().put('context','BestCase');
            
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.bestCaseFCPaginator.recStr );
            //System.assertEquals(1, controller.bestCaseFCPaginator.currentPage);
            controller.last();
            controller.getBestCaseFCData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.bestCaseFCPaginator.recStr );
            //System.assertEquals(3, controller.bestCaseFCPaginator.currentPage);
            //System.assertEquals(true, controller.bestCaseFCPaginator.hasPrev);
            controller.previous();
            controller.getBestCaseFCData();
            //System.assertEquals(' Showing 11 - 20 Of 25 records.' ,controller.bestCaseFCPaginator.recStr );
            //System.assertEquals(2, controller.bestCaseFCPaginator.currentPage);
            //System.assertEquals(true, controller.bestCaseFCPaginator.hasNxt);
            controller.next();
            controller.getBestCaseFCData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.bestCaseFCPaginator.recStr );
            //System.assertEquals(3, controller.bestCaseFCPaginator.currentPage);
            controller.first();
            controller.getBestCaseFCData();
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.bestCaseFCPaginator.recStr );
            //System.assertEquals(1, controller.bestCaseFCPaginator.currentPage);
        test.stopTest();
    }
    
    
    // Case - Pagination Testing
    static testMethod void testOnTrackPagination()
    {
        setUpController();
        setUpTestDataForPagination(); //pushing 25 records for budget Scenario
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
                
        test.startTest();
            controller.getOnTrackFCData();
            
            ApexPages.currentPage().getParameters().put('context','OnTrack');
            
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.onTrackFCPaginator.recStr );
            //System.assertEquals(1, controller.onTrackFCPaginator.currentPage);
            controller.last();
            controller.getOnTrackFCData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.onTrackFCPaginator.recStr );
            //System.assertEquals(3, controller.onTrackFCPaginator.currentPage);
            //System.assertEquals(true, controller.onTrackFCPaginator.hasPrev);
            controller.previous();
            controller.getOnTrackFCData();
            //System.assertEquals(' Showing 11 - 20 Of 25 records.' ,controller.onTrackFCPaginator.recStr );
            //System.assertEquals(2, controller.onTrackFCPaginator.currentPage);
            //System.assertEquals(true, controller.onTrackFCPaginator.hasNxt);
            controller.next();
            controller.getOnTrackFCData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.onTrackFCPaginator.recStr );
            //System.assertEquals(3, controller.onTrackFCPaginator.currentPage);
            controller.first();
            controller.getOnTrackFCData();
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.onTrackFCPaginator.recStr );
            //System.assertEquals(1, controller.onTrackFCPaginator.currentPage);
        test.stopTest();
    }
    
    
    // Case - Pagination Testing
    static testMethod void testCommitPagination()
    {
        setUpController();
        setUpTestDataForPagination(); //pushing 25 records for budget Scenario
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
                
        test.startTest();
            controller.getCommitFCData();
            
            ApexPages.currentPage().getParameters().put('context','Commit');
            
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.commitFCPaginator.recStr );
            //System.assertEquals(1, controller.commitFCPaginator.currentPage);
            controller.last();
            controller.getCommitFCData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.commitFCPaginator.recStr );
            //System.assertEquals(3, controller.commitFCPaginator.currentPage);
            //System.assertEquals(true, controller.commitFCPaginator.hasPrev);
            controller.previous();
            controller.getCommitFCData();
            //System.assertEquals(' Showing 11 - 20 Of 25 records.' ,controller.commitFCPaginator.recStr );
            //System.assertEquals(2, controller.commitFCPaginator.currentPage);
            //System.assertEquals(true, controller.commitFCPaginator.hasNxt);
            controller.next();
            controller.getCommitFCData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.commitFCPaginator.recStr );
            //System.assertEquals(3, controller.commitFCPaginator.currentPage);
            controller.first();
            controller.getCommitFCData();
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.commitFCPaginator.recStr );
            //System.assertEquals(1, controller.commitFCPaginator.currentPage);
        test.stopTest();
    }
    
    //Pipeline Pagination with Stage cut off & Forecast Category cut off
    static testMethod void testPipelinePagination()
    {
       setUpController();
        setUpTestDataForPagination(); //pushing 25 records for budget Scenario
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        //for Stage Cut off
        filters.selGraphOptn = 'Stage';
        controller.setFilterCriteria(filters);
                
        test.startTest();
            controller.getPipelineData();
            
            ApexPages.currentPage().getParameters().put('context','Pipe');
            
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(1, controller.pipelinePaginator.currentPage);
            controller.last();
            controller.getPipelineData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(3, controller.pipelinePaginator.currentPage);
            //System.assertEquals(true, controller.pipelinePaginator.hasPrev);
            controller.previous();
            controller.getPipelineData();
            //System.assertEquals(' Showing 11 - 20 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(2, controller.pipelinePaginator.currentPage);
            //System.assertEquals(true, controller.pipelinePaginator.hasNxt);
            controller.next();
            controller.getPipelineData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(3, controller.pipelinePaginator.currentPage);
            controller.first();
            controller.getPipelineData();
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(1, controller.pipelinePaginator.currentPage);
            
            
            
            filters = new SalesTeam_DashboardFilterClass();
            filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
            filters.SelectedTeamCode = new list<String>();
            filters.QueryLevel = 'AE';
            filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
            //for Forecast Catgeory Cut off
            filters.selGraphOptn = 'Forecast Category';
            controller.setFilterCriteria(filters);
                    
            controller.getPipelineData();
            
            ApexPages.currentPage().getParameters().put('context','Pipe');
            
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(1, controller.pipelinePaginator.currentPage);
            controller.last();
            controller.getPipelineData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(3, controller.pipelinePaginator.currentPage);
            //System.assertEquals(true, controller.pipelinePaginator.hasPrev);
            controller.previous();
            controller.getPipelineData();
            //System.assertEquals(' Showing 11 - 20 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(2, controller.pipelinePaginator.currentPage);
            //System.assertEquals(true, controller.pipelinePaginator.hasNxt);
            controller.next();
            controller.getPipelineData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(3, controller.pipelinePaginator.currentPage);
            controller.first();
            controller.getPipelineData();
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.pipelinePaginator.recStr );
            //System.assertEquals(1, controller.pipelinePaginator.currentPage);
        
        test.stopTest();
    }
    
    
    static testMethod void testWnihPagination()
    {
        setUpController();
        setUpTestDataForPagination(); //pushing 25 records for budget Scenario
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
                
        test.startTest();
            controller.getWnihData();
            
            ApexPages.currentPage().getParameters().put('context','WNIH');
            
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.wnihPaginator.recStr );
            //System.assertEquals(1, controller.wnihPaginator.currentPage);
            controller.last();
            controller.getWnihData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.wnihPaginator.recStr );
            //System.assertEquals(3, controller.wnihPaginator.currentPage);
            //System.assertEquals(true, controller.wnihPaginator.hasPrev);
            controller.previous();
            controller.getWnihData();
            //System.assertEquals(' Showing 11 - 20 Of 25 records.' ,controller.wnihPaginator.recStr );
            //System.assertEquals(2, controller.wnihPaginator.currentPage);
            //System.assertEquals(true, controller.wnihPaginator.hasNxt);
            controller.next();
            controller.getWnihData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.wnihPaginator.recStr );
            //System.assertEquals(3, controller.wnihPaginator.currentPage);
            controller.first();
            controller.getWnihData();
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.wnihPaginator.recStr );
            //System.assertEquals(1, controller.wnihPaginator.currentPage);
        test.stopTest();
    }
    
    
    static testMethod void testRevenuePagination()
    {
       setUpController();
        setUpTestDataForPagination(); //pushing 25 records for budget Scenario
        SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
        filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
        filters.SelectedTeamCode = new list<String>();
        filters.QueryLevel = 'AE';
        filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
        controller.setFilterCriteria(filters);
                
        test.startTest();
            controller.getRevenueData();
            
            ApexPages.currentPage().getParameters().put('context','Rev');
            
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.revenuePaginator.recStr );
            //System.assertEquals(1, controller.revenuePaginator.currentPage);
            controller.last();
            controller.getRevenueData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.revenuePaginator.recStr );
            //System.assertEquals(3, controller.revenuePaginator.currentPage);
            //System.assertEquals(true, controller.revenuePaginator.hasPrev);
            controller.previous();
            controller.getRevenueData();
            //System.assertEquals(' Showing 11 - 20 Of 25 records.' ,controller.revenuePaginator.recStr );
            //System.assertEquals(2, controller.revenuePaginator.currentPage);
            //System.assertEquals(true, controller.revenuePaginator.hasNxt);
            controller.next();
            controller.getRevenueData();
            //System.assertEquals(' Showing 21 - 25 Of 25 records.' ,controller.revenuePaginator.recStr );
            //System.assertEquals(3, controller.revenuePaginator.currentPage);
            controller.first();
            controller.getRevenueData();
            //System.assertEquals(' Showing 1 - 10 Of 25 records.' ,controller.revenuePaginator.recStr );
            //System.assertEquals(1, controller.revenuePaginator.currentPage);
        test.stopTest();
    }
    
     
    // Case - Excel Export
    static testMethod void testExcelExport()
    {
        setUpController();
        setUpTestDataForFilter();
        Test.startTest();
            SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
            filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
            filters.QueryLevel = 'AE';
            filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
            controller.setFilterCriteria(filters);
            controller.ExcelExport();
        Test.stopTest();
    }
    
    //Case --- Excel Export Mode
    static testMethod void testAEStageExportFlow()
    {
      setUpController();
        setUpTestDataForFilter();
        Test.startTest();
            ApexPages.currentPage().getParameters().put('calledFromExcel','true');
            ApexPages.currentPage().getParameters().put('selectedGraphOptn','Stage');
            SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
            filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
            filters.QueryLevel = 'AE';
            filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
            filters.ParentAccount.add(testDataCon.superParentAcc1.SAP_Reference__c);
            filters.OfferingGroup.add(SalesteamDashboard_DataSetUp.OG_Pharma);
            filters.OfferingSegment.add(SalesteamDashboard_DataSetUp.OS_National);
            filters.OfferingType.add(SalesteamDashboard_DataSetUp.OT_Core);
            filters.COEName.add(SalesteamDashboard_DataSetUp.CN_BrandCS);
            controller.setFilterCriteria(filters);
            
            List<Sales_Revenue__c> lstSalesRev = [Select s.id from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Offering_Group__c = :SalesteamDashboard_DataSetUp.OG_Pharma and Offering_Segment__c = :SalesteamDashboard_DataSetUp.OS_National and Offering_Type__c = :SalesteamDashboard_DataSetUp.OT_Core and COE_Name__c = :SalesteamDashboard_DataSetUp.CN_BrandCS and Account_Parent_ID__c = :testDataCon.superParentAcc1.SAP_Reference__c];
            integer totSize = 0;
            if(controller.budgetDataExcel.size() > 0)
                totSize = totSize + controller.budgetDataExcel.size();
            if(controller.revenueDataExcel.size() > 0)
                totSize = totSize + controller.revenueDataExcel.size();
            if(controller.pipelineDataExcel.size() > 0)
                totSize = totSize + controller.pipelineDataExcel.size();
            if(controller.wnihDataExcel.size() > 0)
                totSize = totSize + controller.wnihDataExcel.size();
            //System.assertEquals(lstSalesRev.size(), totSize );
        Test.stopTest(); 
    }
    
     //Case --- Excel Export Mode
    static testMethod void testAEFCExportFlow()
    {
      setUpController();
        setUpTestDataForFilter();
        testDataCon.setUpSalesRevenueForFCFilterTesting();
        Test.startTest();
            ApexPages.currentPage().getParameters().put('calledFromExcel','true');
            //ApexPages.currentPage().getParameters().put('selectedGraphOptn','Forecast Category');
            SalesTeam_DashboardFilterClass filters = new SalesTeam_DashboardFilterClass();
            filters.selGraphOptn = 'Forecast Category';
            filters.selectedSTHids.add(testDataCon.accExecSTH1.id);
            filters.QueryLevel = 'AE';
            filters.HierarchyLevel = SalesTeam_DashboardFilterClass.SALESTEAM;
            filters.ParentAccount.add(testDataCon.superParentAcc1.SAP_Reference__c);
            filters.OfferingGroup.add(SalesteamDashboard_DataSetUp.OG_Pharma);
            filters.OfferingSegment.add(SalesteamDashboard_DataSetUp.OS_National);
            filters.OfferingType.add(SalesteamDashboard_DataSetUp.OT_Core);
            filters.COEName.add(SalesteamDashboard_DataSetUp.CN_BrandCS);
            controller.setFilterCriteria(filters);
            
            List<Sales_Revenue__c> lstSalesRev = [Select s.id from Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c = :testDataCon.accExecSTH1.id and Offering_Group__c = :SalesteamDashboard_DataSetUp.OG_Pharma and Offering_Segment__c = :SalesteamDashboard_DataSetUp.OS_National and Offering_Type__c = :SalesteamDashboard_DataSetUp.OT_Core and COE_Name__c = :SalesteamDashboard_DataSetUp.CN_BrandCS and Account_Parent_ID__c = :testDataCon.superParentAcc1.SAP_Reference__c and IMS_Forecast_Category__c in ('Pipeline', 'Commit', 'On Track', 'Best Case')];
            integer totSize = 0;
            if(controller.BestCaseFCDataExcel.size() > 0)
                totSize = totSize + controller.BestCaseFCDataExcel.size();
            if(controller.OnTrackFCDataExcel.size() > 0)
                totSize = totSize + controller.OnTrackFCDataExcel.size();
            if(controller.CommitFCDataExcel.size() > 0)
                totSize = totSize + controller.CommitFCDataExcel.size();
            if(controller.pipelineDataExcel.size() > 0)
                totSize = totSize + controller.pipelineDataExcel.size();
            //System.assertEquals(lstSalesRev.size(), totSize );
             
        Test.stopTest(); 
    }
    
  static testmethod void testGraphOptions()
    {
        
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
     //Added By Ankita Jain : 27 dec 2012 
    static testMethod void testKPIforJapanUSer()
    {
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
            //System.assertEquals(false,controller.StagePlanKPI.contains(expValS));
            System.assertEquals(false,controller.StagePlanKPI.contains('RIH vs Plan :'));
            System.assertEquals(false,controller.StagePlanKPI.contains(expValS1));
            System.assertEquals(false,controller.StagePlanKPI.contains('Secured vs Plan :'));
            filters.isJapaneseUser = true;
            controller.setFilterCriteria(filters);
            filters.calcAdjTarget();
            //System.assertEquals(true,controller.StagePlanKPI.contains(expValS));
            //System.assertEquals(true,controller.StagePlanKPI.contains('RIH vs Plan :'));
            //System.assertEquals(true,controller.StagePlanKPI.contains(expValS1));
            //System.assertEquals(true,controller.StagePlanKPI.contains('Secured vs Plan :'));
        test.stopTest();
    }
}