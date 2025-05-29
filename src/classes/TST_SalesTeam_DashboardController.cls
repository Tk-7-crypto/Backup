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
@isTest(seeAllData = false)
private class TST_SalesTeam_DashboardController {    
    //Sales Specialist Hierarchy - Added 3rd March 2012 - New Hierarchy Cases
    private static SalesTeam_DashboardController controller;
    private static SalesteamDashboard_DataSetUp testDataCon;  
    
    static void setUpController(Sales_Revenue__c sr) 
    {  
        ApexPages.StandardController stc = new ApexPages.StandardController(sr);   
        controller = new SalesTeam_DashboardController(stc);
    } 
    
    static void setUpTestData() 
    {
        testDataCon = new SalesteamDashboard_DataSetUp();
        testDataCon.setUpRegions();
        testDataCon.setUpAccounts();
        testDataCon.setUpUsers(); 
        testDataCon.setUpUserHierarchies();
    }    
    
    
    //Function for code coverage
    static testmethod void testCodeCoverage()
    {
        Sales_Revenue__c s = new Sales_Revenue__c(); 
        setUpTestData();
        setUpController(s);  
        controller.addError('ABC', true);
        SalesTeam_DashboardController.getQuarterList();  
        SalesTeam_DashboardController.getOfferingGroupList();
        SalesTeam_DashboardController.getOfferingTypeList();  
        SalesTeam_DashboardController.getOfferingSegmentList();
        SalesTeam_DashboardController.getCoeNameList();  
        SalesTeam_DashboardController.getServiceLineList();
        SalesTeam_DashboardController.getServiceLineGroupList();
        SalesTeam_DashboardController.getGlobalProductLst();
        controller.getParentAccountList(); 
        controller.vpChanged();
    }
    
    
    
    // ------- Test Cases for Ops User Starts here ------
    static testmethod void testDashboardLocked()
    {
        setUpTestData();
        System.runas(testDataCon.adminUser)
        {
            SalesTeamDashboardPCAccess__c dashboardLocked = SalesTeamDashboardPCAccess__c.getOrgDefaults(); 
            dashboardLocked.DashboardLocked__c = true;
            update dashboardLocked;
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            //system.assertEquals(true,controller.showDashboard);
            //system.assertEquals(false,controller.haveSalesData);
            //ApexPages.Message msg1 = ApexPages.getMessages()[0];
            //system.assertEquals(dashboardLocked.dashboardLockedMessage__c + '<br/><br/><a  href="/home/home.jsp" target="_parent">Click here to return to the homepage</a>', msg1.getDetail());
            Test.startTest();
        }
    }
    
    //Case - User is Operations user by Profile name
    //No data is present for the PC in custom setting
    static testmethod void testOpsUserFlow1()
    {
        setUpTestData();
        System.runas(testDataCon.opsUser) 
        {
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            Test.startTest();
            //system.assertEquals(false ,controller.multipleHierarchiesExists);
            //system.assertEquals(controller.filterOptions.userDesignation, SalesTeam_DashboardController.getOpsUser());
            User u = [Select name from User where id = :testDataCon.opsUser.id];
            //system.assertEquals(u.Name, controller.userName);
            Test.stopTest();
        }       
    } 
    
    //Case - test the PC hierarchy helper class -- if populates all child PC's correctly or not or not
    static testmethod void testOpsUserFlow3()
    {
        setUpTestData();
        SalesTeamDashboardPCAccess__c tempCS = new SalesTeamDashboardPCAccess__c( Assigned_Profit_Center__c = testDataCon.topLevelRegion.ProfitCenterCode__c, SetupOwnerId = testDataCon.opsUser.id );
        insert tempCS;
        
        System.runas(testDataCon.opsUser) 
        {            
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            Test.startTest();
            for(SelectOption pc : controller.hierarchyList)
            {
                system.assertEquals(true, pc.getValue().contains(SalesTeam_DashboardFilterClass.PROFITCENTRE) || pc.getValue().contains(SalesTeam_DashboardFilterClass.SALESTEAM) || pc.getValue().contains(SalesTeam_DashboardFilterClass.SALESSPECIALIST) || pc.getValue().contains(SalesTeam_DashboardFilterClass.IASPECIALIST));
            }
            system.assertEquals(true ,controller.multipleHierarchiesExists);
            system.assertEquals(controller.filterOptions.userDesignation, SalesTeam_DashboardController.getOpsUser());
            System.debug(SalesTeam_DashboardController.pcJsonString.contains(testDataCon.topLevelRegion.ProfitCenterCode__c) == true);
            System.debug(SalesTeam_DashboardController.pcJsonString.contains(testDataCon.middleLevelRegion1.ProfitCenterCode__c) == true);
            System.debug(SalesTeam_DashboardController.pcJsonString.contains(testDataCon.middleLevelRegion3.ProfitCenterCode__c) == true);
            System.debug(SalesTeam_DashboardController.pcJsonString.contains(testDataCon.leafRegion1.ProfitCenterCode__c) == true);
            System.debug(SalesTeam_DashboardController.pcJsonString.contains(testDataCon.leafRegion2.ProfitCenterCode__c) == true);
            System.debug(SalesTeam_DashboardController.pcJsonString.contains(testDataCon.leafRegion3.ProfitCenterCode__c) == true);
            Test.stopTest();
            
        }
    }
    
    
    //Case - OpsUserFlow test - Data is presnt for PC - different combinations of the 3 picklists
    //Sales Team & Sales Specialist Hierarchy exists
    static testMethod void testOpsUserFlow4()
    {
        setUpTestData();
        testDataCon.setUpSalesRevenueForFilterTesting();
        SalesTeamDashboardPCAccess__c tempCS = new SalesTeamDashboardPCAccess__c( Assigned_Profit_Center__c = testDataCon.topLevelRegion.ProfitCenterCode__c, SetupOwnerId = testDataCon.opsUser.id );
        insert tempCS;
        System.runas(testDataCon.opsUser) 
        {
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            Test.startTest(); 
            for(SelectOption pc : controller.hierarchyList)
            {
                //system.assertEquals(true, pc.getValue().contains(SalesTeam_DashboardFilterClass.PROFITCENTRE) || pc.getValue().contains(SalesTeam_DashboardFilterClass.SALESTEAM) || pc.getValue().contains(SalesTeam_DashboardFilterClass.SALESSPECIALIST) || pc.getValue().contains(SalesTeam_DashboardFilterClass.IASPECIALIST));
            }
            //system.assertEquals(controller.filterOptions.userDesignation, SalesTeam_DashboardController.getOpsUser());
            //system.assertEquals(true ,controller.multipleHierarchiesExists);
            //system.assertEquals('None', controller.selectedOpsProfitCenter );
            //system.assertEquals('None', controller.selectedTeam);
            //system.assertEquals('None', controller.selectedAccountExecutive);      
            controller.selectedOpsProfitCenter = testDataCon.leafRegion1.ProfitCenterCode__c;
            controller.profitCentreChanged();
            //system.assertEquals(controller.querySalesTeamStr, 'Profit Centre');
            controller.userFlow();
            //system.assertEquals(testDataCon.leafRegion1.ProfitCenterCode__c, controller.filterOptions.selectedProfitCenter);
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.SALESTEAM;
            controller.salesHierarchyChanged();
            controller.selectedTeam = testDataCon.salesTeam1.id;
            controller.teamChanged();
            controller.userFlow();
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals(testDataCon.salesTeam1.id, controller.filterOptions.SelectedTeamCode[0]);
            //system.assertEquals(SalesTeam_DashboardFilterClass.queryTM, controller.filterOptions.QueryLevel);
            //system.assertEquals(testDataCon.leafRegion1.ProfitCenterCode__c, controller.filterOptions.selectedProfitCenter);
            List<String> lst = new List<String>();
            lst.add('All');
            //system.assertEquals(lst, controller.filterOptions.selectedSTHids);
            //system.assertEquals(true, controller.haveSalesData);
            // when all teams data is been viewed with 'All' as team and AE list options
            controller.selectedOpsProfitCenter = testDataCon.leafRegion1.ProfitCenterCode__c;
            controller.profitCentreChanged();
            
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.SALESTEAM;
            controller.salesHierarchyChanged();
            controller.userFlow();
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals('All',controller.filterOptions.SelectedTeamCode[0]);
            //system.assertEquals('All',controller.filterOptions.selectedSTHids[0]);
            //system.assertEquals(SalesTeam_DashboardFilterClass.queryPC, controller.filterOptions.QueryLevel);
            //system.assertEquals(true, controller.haveSalesData); 
            //when selected Profit Center & team are not None & Account Executive is not 'All' - individual view & user is present with Sales Team Hierarchy record
            controller.selectedOpsProfitCenter = testDataCon.leafRegion1.ProfitCenterCode__c;
            controller.profitCentreChanged();
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.SALESTEAM;
            controller.salesHierarchyChanged();
            controller.selectedTeam = testDataCon.salesTeam1.id;
            controller.teamChanged();
            controller.selectedAccountExecutive = testDataCon.accExecSTH1.id;
            controller.userFlow();
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals(testDataCon.accExecSTH1.id , controller.filterOptions.selectedSTHids[0]);
            //system.assertEquals(true, controller.haveSalesData);
            //when No Account Executive was selected
            controller.selectedAccountExecutive = 'No Account Executive';
            controller.userFlow();
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals('No Account Executive' , controller.filterOptions.selectedSTHids[0]);
            //system.assertEquals(false, controller.haveSalesData);
            
            //Sales Specialist Hierarchy - Added 06 Aug 2012 - New Hierarchy Cases
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.SALESSPECIALIST;
            controller.salesHierarchyChanged();
            //system.assertEquals(1, controller.Teams.size());
            //system.assertEquals(2, controller.AccountExecutive.size());
            //system.assertEquals(testDataCon.leafRegion1.ProfitCenterCode__c, controller.selectedOpsProfitCenter );
            controller.profitCentreChanged();
            //system.assertEquals('None', controller.selectedTeam);
            //system.assertEquals('None', controller.selectedAccountExecutive);
            //system.assertEquals(controller.selectedOpsProfitCenter, testDataCon.leafRegion1.ProfitCenterCode__c);
            //system.assertEquals(1, controller.Teams.size());
            //system.assertEquals(2, controller.AccountExecutive.size()); 
            
            //I&A Hierarchy - Added 08 Aug 2012 - New I&A Hierarchy Cases
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.IASPECIALIST;
            controller.salesHierarchyChanged();
            //system.assertEquals(1, controller.Teams.size());
            //system.assertEquals(2, controller.AccountExecutive.size()); 
            Test.stopTest(); 
        }
    }
    
    
    
    static testMethod void testrunasid2()
    {
        setUpTestData();
        if(testDataCon.adminUser != null)
        {
            System.runas(testDataCon.adminUser)
            {
                //ApexPages.currentPage().getParameters().put('runasid','ABC');
                Sales_Revenue__c s = new Sales_Revenue__c();
                setUpController(s);
                controller.userId = 'ABC';
                //system.assertEquals(controller.filterOptions.userDesignation, '');
                //system.assertEquals(true, controller.showDashboard);
                //ApexPages.Message msg1 = ApexPages.getMessages()[0]; 
                //System.assert(msg1.getDetail().contains('User does not exist against the Specified ID. Please give a valid user Id to view his/her Dashboard.' + '<br/><br/><a  href="/home/home.jsp" target="_parent">Click here to return to the homepage</a>'));
                
            }
        }   
        
        
    }
    
    //Update by: Sneha Date: 30 Dec, 2011 -- Sales Team Leader both Sales Team & Sales Specialist Cases
    static testMethod void testSalesTeamLeaderUserFlow1()
    {
        setUpTestData();
        System.runas(testDataCon.salesTeamLeader)
        {
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            //system.assertEquals(controller.filterOptions.userDesignation, SalesTeam_DashboardController.getSlUser());
            //system.assertEquals(true, controller.multipleHierarchiesExists);
            //Sales Team Hierarchy
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.SALESTEAM;
            controller.salesHierarchyChanged();
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals('Select Team', controller.teamLabel);
            //system.assertEquals('Select Executive', controller.EmpLabel);
            //system.assertEquals(testDataCon.salesTeam4.id, controller.selectedTeam);
            
            //Sales Specialist Hierarchy
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.SALESSPECIALIST;
            controller.salesHierarchyChanged();
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals(testDataCon.salesSplTm3.id, controller.selectedTeam); 
            
            //I&A Hierarchy 
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.IASPECIALIST;
            controller.salesHierarchyChanged();
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals(testDataCon.IATm1.id, controller.selectedTeam); 
        }
    }
    
    // case - Sales team leader with only one hierarchy
    static testMethod void testSalesTeamLeaderUserFlow2()
    {
        setUpTestData();
        System.runas(testDataCon.salesTeamLeader)
        {
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            test.startTest();
            //system.assertEquals(controller.filterOptions.userDesignation, SalesTeam_DashboardController.getSlUser());
            //system.assertEquals(true, controller.multipleHierarchiesExists);
            //system.assertEquals(SalesTeam_DashboardFilterClass.SALESTEAM,controller.querySalesTeamStr);
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals(testDataCon.salesTeam4.id, controller.selectedTeam);
            test.stopTest();
        }
    } 
    
    
    //case - GKAM cases added --- GKAM user logs in and view Dashboard for a PC
    static testmethod void testGkamUserFlow()
    {
        setUpTestData();
        List<Account_Manager__c> accMgr = new List<Account_Manager__c>();
        Account_Manager__c accMgr1 = new Account_Manager__c(Role__c = 'GKAM', Account__c = testDataCon.superParentAcc1.id , user__c = testDataCon.gkamUser.id);
        accMgr.add(accMgr1);
        Account_Manager__c accMgr2 = new Account_Manager__c(Role__c = 'GKAM', Account__c = testDataCon.superParentAcc2.id, user__c = testDataCon.gkamUser.id);
        accMgr.add(accMgr2);
        insert accMgr;
        System.runas(testDataCon.gkamUser)
        { 
            Sales_Revenue__c s = new Sales_Revenue__c();
            List<String> lstSPAccounts = new List<String>();
            lstSPAccounts.add(testDataCon.superParentAcc1.SAP_Reference__c);
            lstSPAccounts.add(testDataCon.superParentAcc2.SAP_Reference__c);
            setUpController(s);
            test.startTest();
            //system.assertEquals(controller.filterOptions.userDesignation, SalesTeam_DashboardController.getGkam());
            //system.assertEquals(false, controller.multipleHierarchiesExists);
            //System.assert(SalesTeam_DashboardController.pcJsonString.contains(SalesTeam_DashboardFilterClass.gkamRootPcCode));
            controller.selectedOpsProfitCenter = SalesTeam_DashboardFilterClass.gkamRootPcCode;
            for(SelectOption pc : controller.getParentAccountList())
            {
                //system.assertEquals(true, pc.getValue().contains(lstSPAccounts[0]) || pc.getValue().contains(lstSPAccounts[1]));
            }
            controller.userFlow(); 
            //system.assertEquals(SalesTeam_DashboardFilterClass.gkamRootPcCode, controller.filterOptions.selectedProfitCenter);
            //system.assertEquals('GKAM',controller.querySalesTeamStr);
            //system.assertEquals(true, controller.showDashboard);
            //system.assertEquals(true, controller.haveSalesData);
            /*for(String str: controller.filterOptions.ParentAccount)
{
System.debug('str ---- >> ' + str);
//system.assertEquals(true, (str == lstSPAccounts[0])||(str == lstSPAccounts[1]));    
}*/
            //check the Go functionality
            controller.filterOptions.ParentAccount = new List<String>();
            controller.go();
            
            /* for(String str: controller.filterOptions.ParentAccount)
{
//system.assertEquals(true, ((str == lstSPAccounts[0])||(str == lstSPAccounts[1])));    
}*/
            test.stopTest();
            
        }
    }
    // Sales Leader Check\
    // v //AE user check //reinitialize
    //Added By Ankita Jain : 27 dec 2012 : Testing if the user is japanese or not
    static testMethod void testJapanUser()
    {
        setUpTestData();
        System.runas(testDataCon.opsUser)
        {
            test.startTest();
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            ////system.assertEquals(false, controller.filterOptions.isJapaneseUser);
            testDataCon.opsUser.User_Country__c = 'Japan';
            update testDataCon.opsUser;
            setUpController(s);
            //system.assertEquals(true, controller.filterOptions.isJapaneseUser);
            test.stopTest();   
        }
    }
    
    //Added By Surbhi Singh  : 04 March, 2019
    @isTest
    static void normalUserFlowTest(){
        setUpTestData();
        User normalUser = UTL_TestData.createUser('System Administrator',1)[0];
        normalUser.EmployeeNumber = '152984';
        system.debug(normalUser);
        Sales_Team_Hierarchy_AE__c  newSalesTeamHierarchyAE = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = testDataCon.salesTeam1.id , Name = normalUser.name + '(0000' + normalUser.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000A' + normalUser.EmployeeNumber + '_AE', AE_Name__c = normalUser.name + '(0000' + normalUser.EmployeeNumber + '_AE)', AE_Code__c = normalUser.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        insert newSalesTeamHierarchyAE;
        system.debug(newSalesTeamHierarchyAE);
        System.runas(normalUser){  
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            Test.startTest();
            controller.querySalesTeamStr = SalesTeam_DashboardFilterClass.SALESTEAM;
            controller.normalUserFlow();
            Test.stopTest();
        }
    }  
    //Added By Surbhi Singh  : 04 March, 2019
    @isTest
    static void salesLeaderUserFlowTest(){
        setUpTestData();
        System.runas(testDataCon.salesTeamLeader){  
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            Test.startTest();
            controller.SalesLeaderUserFlow();
            Test.stopTest();
        }
    }
    
    //Added By Surbhi Singh  : 04 March, 2019
    @isTest
    static void userFlowWhenViewingDataForAllTeams(){
        setUpTestData();
        System.runas(testDataCon.salesTeamLeader){
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            controller.selectedTeam = 'All';
            controller.selectedAccountExecutive = 'All';
            Test.startTest();
            controller.userFlow();
            Test.stopTest();            
        }
    }
    
    //Added By Surbhi Singh  : 04 March, 2019
    @isTest
    static void userFlowWhenViewingDataForAnyTeams(){
        setUpTestData();
        System.runas(testDataCon.salesTeamLeader){
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            controller.selectedTeam = '';
            controller.selectedAccountExecutive = 'All';
            Test.startTest();
            controller.userFlow();
            Test.stopTest();            
        }
    }
    //Added By Surbhi Singh  : 04 March, 2019
    @isTest
    static void userFlowWhenviewingdataforanyAE(){
        setUpTestData();
        System.runas(testDataCon.salesTeamLeader){
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            controller.selectedTeam = '';
            controller.selectedAccountExecutive = '';
            Test.startTest();
            controller.userFlow();
            Test.stopTest();            
        }
        
    }
    //Added By Surbhi Singh  : 04 March, 2019
    @isTest
    static void ifSalesHierarchyIsChangedForSlUser(){
        setUpTestData();
        System.runas(testDataCon.salesTeamLeader){  
            Sales_Revenue__c s = new Sales_Revenue__c();
            setUpController(s);
            controller.filterOptions = new SalesTeam_DashboardFilterClass();
            controller.filterOptions.userDesignation = SalesTeam_DashboardController.getSlUser();
            Test.startTest();
            controller.salesHierarchyChanged();
            Test.stopTest();
        }
    }
    
    //Added By Surbhi Singh  : 04 March, 2019
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