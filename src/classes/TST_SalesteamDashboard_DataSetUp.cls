@isTest
public class TST_SalesteamDashboard_DataSetUp {
    private static DashboardDisplayController controller; 
    private static SalesteamDashboard_DataSetUp testDataCon;
    static void setUpController() {
        controller = new DashboardDisplayController();
    }
    static void setUpTestDataForFilter() {
        testDataCon = new SalesteamDashboard_DataSetUp();
        testDataCon.setUpRegions();
        testDataCon.setUpUsers();
        testDataCon.setUpAccounts();
        testDataCon.setUpUserHierarchies(); 
        testDataCon.setUpSalesRevenueForFilterTesting();
    }
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
        
        Test.stopTest(); 
    }
}