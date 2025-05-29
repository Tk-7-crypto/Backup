/* Class to set Up test Data for SalesTeam_DashboardControllerTest & DashboardDisplayControllerTest class 
Created by : Sneha Rathi
Date: 8 April, 2011
*/
public class SalesteamDashboard_DataSetUp {
 
    //users to be used in testing
    public User opsUser; 
    public User vpUser;
    public User accExec1;
    public User accExec2;
    public User accExec3;
    public User accExec4;
    public User adminUser;
    public User salesTeamLeader;
    public User ekamUser;
    public User gkamUser;
    
    //regions
    public Profit_Centre__c topLevelRegion;
    public Profit_Centre__c middleLevelRegion1;
    public Profit_Centre__c middleLevelRegion3;
    public Profit_Centre__c leafRegion1;
    public Profit_Centre__c leafRegion2;
    public Profit_Centre__c leafRegion3;
    public Profit_Centre__c gkamRegion;
    public Profit_Centre__c ekamRegion;

    //accounts
    public Account superParentAcc1;
    public Account superParentAcc2;
    public Account superParentAcc3;
    public Account acc1;
    public Account acc2;
    public Account acc3;
    public Account acc4;
    public Account acc5;
    public Account acc6; 
    
    //Update by: Sneha Date: 14 July, 2011 - New Schema Change
    
    //Sales Team Hierarchies for Account Exec
    public Sales_Team_Hierarchy_AE__c accExecSTH1;
    public Sales_Team_Hierarchy_AE__c accExecSTH2;
    public Sales_Team_Hierarchy_AE__c accExecSTH3;
    public Sales_Team_Hierarchy_AE__c accExecSTH4; 
    public Sales_Team_Hierarchy_AE__c salesSpecialist1;
    public Sales_Team_Hierarchy_AE__c salesSpecialist2;
    public Sales_Team_Hierarchy_AE__c IAExec1;
    public Sales_Team_Hierarchy_AE__c IAExec2;
   
    //Sales Team Hierarchies for Sales Team
    public Sales_Team_Hierarchy_ST__c salesTeam1;
    public Sales_Team_Hierarchy_ST__c salesTeam2;
    public Sales_Team_Hierarchy_ST__c salesTeam3;
    public Sales_Team_Hierarchy_ST__c salesTeam4;
    public Sales_Team_Hierarchy_ST__c salesSplTm1;
    public Sales_Team_Hierarchy_ST__c salesSplTm2;
    public Sales_Team_Hierarchy_ST__c salesSplTm3;
    public Sales_Team_Hierarchy_ST__c IATm1;
    public Sales_Team_Hierarchy_ST__c IATm2;
    public Sales_Team_Hierarchy_ST__c IATm3;
     
    //Sales Team Hierarchies for VP 
    public Sales_Team_Hierarchy_VP__c vP1;
    public Sales_Team_Hierarchy_VP__c SSVp1;
    public Sales_Team_Hierarchy_VP__c IAVp1;
    
    //Static strings for Offering Segment values
    public static String OS_National = 'National';
    public static String OS_Subnational = 'Subnational';
    public static String OS_GlobalMM = 'Global Market Measurements';
    public static String OS_ManagedMS = 'Managed Market Services';
    public static String OS_ConHealth = 'Consumer Health';
    public static String OS_Government = 'Government';    
    public static String OS_Payer = 'Payer';    
    public static String OS_Other = 'Other';    
    
    //Static Strings for Offering Group Values
    public static String OG_Pharma = 'Pharma';
    public static String OG_Government = 'Government';
    public static String OG_Payer = 'Payer';
    public static String OG_ManagedCons = 'Management Consulting';
   
    //Static Strings for Offering Type Values 
    public static String OT_Core = 'Core';
    public static String OT_SFocusArea = 'Strategic Focus Area';
    // Date 23/1/2015 - UPdated by Sunil Kumar Sharma
    //public static String OT_CES = System.Label.CES_TOT_Offering_Type;
    public static String OT_CES = 'CES'; 
    
    //Static strings for COE Name Values
    public static String CN_BrandCS = 'Brand & Commercial Strategy';
    public static String CN_CompIntelligence = 'Competitive Intelligence';
    public static String CN_Other = 'Other';
    public static String CN_PricingMA = 'Pricing & Market Access';   
    public static String CN_StrategyPA  = 'Strategy & Portfolio Analysis';   
    public static String CN_HEOROff = 'HEOR Offerings';
   
    public Sales_Revenue__c[] salesRevenue;
    public Sales_Revenue__c[] salesRevenueBulk;
    
    public void setUpRegions() 
    { 
        PseSecurityConfig__c securityConfig = new PseSecurityConfig__c();
        securityConfig.UserName__c = 'phi@imshealth.com.uat';
        securityConfig.Password__c = 'appirio4';
        securityConfig.ForceSecurityCalloutsToQueue__c = false;
        securityConfig.DisableSecurityTriggers__c = true;
        securityConfig.DefaultOwnerUsername__c = 'integration@uk.imshealth.com.uat';
        upsert securityConfig;
        
        //sets up regions
        Profit_Centre__c temp;
        List<Profit_Centre__c> lstRegions = new List<Profit_Centre__c>();
        for(Profit_Centre__c r: [Select id from Profit_Centre__c where Parent_Profit_Centre__c = null OR Parent_Profit_Centre__c = ''])
        {
            temp = r;
        } 
        if(temp != null)
        {
            topLevelRegion = new Profit_Centre__c(Name='TopLevel' + System.now(), ProfitCenterCode__c ='T1', Parent_Profit_Centre__c = temp.id);
            lstRegions.add(topLevelRegion);
        }
        else 
        {
            topLevelRegion = new Profit_Centre__c(Name='TopLevel (T2)' + System.now(), ProfitCenterCode__c ='T2');
            lstRegions.add(topLevelRegion);
        }
        middleLevelRegion1 = new Profit_Centre__c(Name='MiddleLevel1 (M1)' + System.now(), ProfitCenterCode__c ='M1', Parent_Profit_Centre__c = topLevelRegion.id );
        lstRegions.add(middleLevelRegion1);
        middleLevelRegion3 = new Profit_Centre__c(Name='MiddleLevel3 (M3)' + System.now(), ProfitCenterCode__c ='M3', Parent_Profit_Centre__c = middleLevelRegion1.id );
        lstRegions.add(middleLevelRegion3);
        leafRegion1 = new Profit_Centre__c(Name='Leaf1 (L1)' + System.now(), ProfitCenterCode__c ='L1', Parent_Profit_Centre__c = middleLevelRegion1.id );
        lstRegions.add(leafRegion1);
        leafRegion2 = new Profit_Centre__c(Name='Leaf2 (L2)' + System.now(), ProfitCenterCode__c ='L2', Parent_Profit_Centre__c = topLevelRegion.id );
        lstRegions.add(leafRegion2);
        leafRegion3 = new Profit_Centre__c(Name='Leaf3 (L3)' + System.now(), ProfitCenterCode__c ='L3', Parent_Profit_Centre__c = middleLevelRegion3.id );
        lstRegions.add(leafRegion3);
        gkamRegion = new Profit_Centre__c(Name='GKAM (' + SalesTeam_DashboardFilterClass.gkamRootPcCode + ')' + System.now(), ProfitCenterCode__c =SalesTeam_DashboardFilterClass.gkamRootPcCode, Parent_Profit_Centre__c = topLevelRegion.id );
        lstRegions.add(gkamRegion);
        ekamRegion = new Profit_Centre__c(Name='EKAM (' + SalesTeam_DashboardFilterClass.ekamRootPcCode + ')' + System.now(), ProfitCenterCode__c =SalesTeam_DashboardFilterClass.ekamRootPcCode, Parent_Profit_Centre__c = topLevelRegion.id );
        lstRegions.add(ekamRegion);
        
        insert lstRegions;
    }
    
    public void setUpAccounts()
    {
        //sets up super parent accounts & other accounts
        RecordType superParentAccRecType;
        for(RecordType r:[Select id from RecordType where name like 'Unvalidated Account' Limit 1])
        {
            superParentAccRecType = r;
        }
        if(superParentAccRecType != null)
        {
            List<Account> lstAcc = new List<Account>();
            superParentAcc1 = new Account(Name = 'Super Parent Account 1' + System.now(), Status__c = 'SAP Validated', SAP_Reference__c = 'HNCSP@@001', Industry_IMS__c = 'BioTech', Region_Territory__c = 'India', RecordTypeId = superParentAccRecType.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(superParentAcc1);
            superParentAcc2 = new Account(Name = 'Super Parent Account 2' + System.now(),Status__c = 'SAP Validated', SAP_Reference__c = 'HNCSP@@002', Industry_IMS__c = 'Traditional Pharma', Region_Territory__c = 'Germany', RecordTypeId = superParentAccRecType.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(superParentAcc2);
            superParentAcc3 = new Account(Name = 'Super Parent Account 3' + System.now(), Status__c = 'SAP Validated', SAP_Reference__c = 'HNCSP@@003', Industry_IMS__c = 'Generics', Region_Territory__c = 'USA', RecordTypeId = superParentAccRecType.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(superParentAcc3);
            insert lstAcc;
        }
        
        RecordType imsStandardAccount;
        for(RecordType r:[Select id from RecordType where name like 'Global Customer Account' Limit 1])
        {
            imsStandardAccount = r;
        }
        if(imsStandardAccount != null)
        {
            List<Account> lstAcc = new List<Account>();
            acc1 = new Account(Name = 'Account 1' + System.now(), Industry_IMS__c = 'BioTech', Region_Territory__c = 'India', RecordTypeId = imsStandardAccount.id, ParentId = superParentAcc1.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(acc1);
            acc2 = new Account(Name = 'Account 2' + System.now(), Industry_IMS__c = 'BioTech', Region_Territory__c = 'India', RecordTypeId = imsStandardAccount.id, ParentId = superParentAcc1.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(acc2);
            acc3 = new Account(Name = 'Account 3' + System.now(), Industry_IMS__c = 'Traditional Pharma', Region_Territory__c = 'Germany', RecordTypeId = imsStandardAccount.id, ParentId = superParentAcc2.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(acc3);
            acc4 = new Account(Name = 'Account 4' + System.now(), Industry_IMS__c = 'Traditional Pharma', Region_Territory__c = 'Germany', RecordTypeId = imsStandardAccount.id, ParentId = superParentAcc2.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(acc4);
            acc5 = new Account(Name = 'Account 5' + System.now(), Industry_IMS__c = 'Generics', Region_Territory__c = 'USA', RecordTypeId = imsStandardAccount.id, ParentId = superParentAcc3.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(acc5);
            acc6 = new Account(Name = 'Account 6' + System.now(), Industry_IMS__c = 'Generics', Region_Territory__c = 'USA', RecordTypeId = imsStandardAccount.id, ParentId = superParentAcc3.id,CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            lstAcc.add(acc6);
            insert lstAcc;
        }
        
        superParentAcc1 = [Select SAP_Reference__c, id, Name, Status__c from Account where id = :superParentAcc1.id];
        superParentAcc2 = [Select SAP_Reference__c, id, Name, Status__c from Account where id = :superParentAcc2.id];
        superParentAcc3 = [Select SAP_Reference__c, id, Name, Status__c from Account where id = :superParentAcc3.id];
    }
    
    public void setUpUsers()
    {
        //Update by: Sneha Date: 11 July, 2012 -- Added a check for PSE user & Ops Sales Team Dashboard Acccess
         //opsUser = [Select u.LastName, u.name, u.FirstName, u.EmployeeNumber,PSE_Resource_Profit_Center__c,Ops_Sales_Team_Dashboard_Access__c, u.DefaultCurrencyIsoCode From User u where u.Profile.Name like '%Sales%' and u.EmployeeNumber != 'N/A' and u.EmployeeNumber != '' and (EmployeeNumber != 'NO_MATCH') and u.IsActive = true and (PSE_User__c = false) Limit 1];
         opsUser = [Select u.LastName, u.name, u.FirstName, u.EmployeeNumber,PSE_Resource_Profit_Center__c,Ops_Sales_Team_Dashboard_Access__c, u.DefaultCurrencyIsoCode From User u where u.Profile.Name like '%Sales%' AND u.IsActive = true AND u.profile.UserLicense.Name = 'Salesforce' LIMIT 1];
         //List<User> lstUsers = [Select u.LastName, u.name , u.FirstName, u.EmployeeNumber ,PSE_Resource_Profit_Center__c, u.DefaultCurrencyIsoCode From User u where (EmployeeNumber != 'N/A' ) and (EmployeeNumber != 'NO_MATCH') and (EmployeeNumber != '' ) and (u.IsActive = true) and (Ops_Sales_Team_Dashboard_Access__c = false) and (PSE_User__c = false) and (not( u.Profile.Name  like '%Sales%')) Limit 8];
         List<User> lstUsers = [Select u.LastName, u.name , u.FirstName, u.EmployeeNumber ,PSE_Resource_Profit_Center__c, u.DefaultCurrencyIsoCode From User u where u.IsActive = true AND u.Profile.Name  like '%system administrator%' Limit 5];
         vpUser = lstUsers.get(0);
         accExec1 = lstUsers.get(1);
         accExec2 = lstUsers.get(1);
         accExec3 = lstUsers.get(1);
         accExec4 = lstUsers.get(1);
         salesTeamLeader = lstUsers.get(2);
         ekamUser = lstUsers.get(3);
         gkamUser = lstUsers.get(4);
         adminUser = [Select u.LastName, u.FirstName,u.name, u.EmployeeNumber,PSE_Resource_Profit_Center__c,Ops_Sales_Team_Dashboard_Access__c, u.DefaultCurrencyIsoCode From User u where u.Profile.Name like '%system administrator%' and u.EmployeeNumber != 'N/A' and u.EmployeeNumber != '' and EmployeeNumber != 'NO_MATCH' and u.IsActive = true Limit 1];
    }
    
    public void setUpUserHierarchies()
    { 
        
        SalesTeamDashboardPCAccess__c temp = new SalesTeamDashboardPCAccess__c();
        temp.DashboardLocked__c = false;
        temp.Assigned_Profit_Center__c = 'None';
        insert temp;
        
        //Update by: Sneha Date: 14 July, 2011 - New Schema Change
        List<Sales_Team_Hierarchy_VP__c> lstVP = new List<Sales_Team_Hierarchy_VP__c>();
        vp1 = new Sales_Team_Hierarchy_VP__c(VP_Name__c = vpUser.name + '(0000' + vpUser.EmployeeNumber + '_VP)' , VP_Code__c = vpUser.EmployeeNumber, Name = vpUser.name + '(0000' + vpUser.EmployeeNumber + '_VP)' , Hierarchy_Id__c = '0000' + vpUser.EmployeeNumber + '_ST_VP', Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstVP.add(vp1);
        SSVp1 = new Sales_Team_Hierarchy_VP__c(VP_Name__c = vpUser.name + '(0000' + vpUser.EmployeeNumber + '_VP)' , VP_Code__c = vpUser.EmployeeNumber, Name = vpUser.name + '(0000' + vpUser.EmployeeNumber + '_VP)' , Hierarchy_Id__c = '0000' + vpUser.EmployeeNumber + '_SS_VP', Type__c = SalesTeam_DashboardFilterClass.SALESSPECIALIST);
        lstVP.add(SSVp1);
        IAVp1 = new Sales_Team_Hierarchy_VP__c(VP_Name__c = vpUser.name + '(0000' + vpUser.EmployeeNumber + '_VP)' , VP_Code__c = vpUser.EmployeeNumber, Name = vpUser.name + '(0000' + vpUser.EmployeeNumber + '_VP)' , Hierarchy_Id__c = '0000' + vpUser.EmployeeNumber + '_IA_VP', Type__c = SalesTeam_DashboardFilterClass.IASPECIALIST);
        lstVP.add(IAVp1);
        insert lstVP;
        
        List<Sales_Team_Hierarchy_ST__c> lstSTD_ST = new List<Sales_Team_Hierarchy_ST__c>();
        salesTeam1 = new Sales_Team_Hierarchy_ST__c(VP__c = vp1.Id, ST_Name__c = 'Team 1(0000T0001_ST)', ST_Code__c = 'T0001', Name = 'Team 1(0000T0001_ST)', Hierarchy_Id__c = '0000T0001_ST' , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstSTD_ST.add(salesTeam1);        
        salesTeam2 = new Sales_Team_Hierarchy_ST__c(VP__c = vp1.Id, ST_Name__c = 'Team 2(0000T0002_ST)', ST_Code__c = 'T0002', Name = 'Team 2(0000T0002_ST)', Hierarchy_Id__c = '0000T0002_ST' , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstSTD_ST.add(salesTeam2);
        salesTeam3 = new Sales_Team_Hierarchy_ST__c(VP__c = vp1.Id, ST_Name__c = 'Team 3(0000T0003_ST)', ST_Code__c = 'T0003', Name = 'Team 3(0000T0003_ST)', Hierarchy_Id__c = '0000T0003_ST' , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstSTD_ST.add(salesTeam3);
        salesSplTm1 = new Sales_Team_Hierarchy_ST__c(VP__c = SSVp1.id, ST_Name__c = 'Team 2(0000T0002_ST)', ST_Code__c = 'T0004', Name = 'Team 2(0000T0002_ST_SS)', Hierarchy_Id__c = '0000T0002_ST_SS' , Type__c = SalesTeam_DashboardFilterClass.SALESSPECIALIST);
        lstSTD_ST.add(salesSplTm1);
        salesSplTm2 = new Sales_Team_Hierarchy_ST__c(VP__c = SSVp1.Id, ST_Name__c = 'Team 3(0000T0003_ST)', ST_Code__c = 'T0005', Name = 'Team 3(0000T0003_ST_SS)', Hierarchy_Id__c = '0000T0003_ST_SS' , Type__c = SalesTeam_DashboardFilterClass.SALESSPECIALIST);
        lstSTD_ST.add(salesSplTm2);
        salesSplTm3 = new Sales_Team_Hierarchy_ST__c(VP__c = SSVp1.Id, ST_Name__c = 'Team 4(0000T0004_ST)', ST_Code__c = salesTeamLeader.EmployeeNumber, Name = 'Team 4(0000T0004_ST_SS)', Hierarchy_Id__c = '0000T0004_ST_SS' , Type__c = SalesTeam_DashboardFilterClass.SALESSPECIALIST);
        lstSTD_ST.add(salesSplTm3);
        salesTeam4 = new Sales_Team_Hierarchy_ST__c(VP__c = vp1.Id, ST_Name__c = 'Team 4(0000T0004_ST)', ST_Code__c = salesTeamLeader.EmployeeNumber, Name = 'Team 4(0000T0004_ST)', Hierarchy_Id__c = '0000T0004_ST' , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstSTD_ST.add(salesTeam4);
        
        IATm1 = new Sales_Team_Hierarchy_ST__c(VP__c = IAVp1.Id, ST_Name__c = 'Team 4(0000T0004_ST)', ST_Code__c = salesTeamLeader.EmployeeNumber, Name = 'Team 4(0000T0004_ST)', Hierarchy_Id__c = '0000T0004_IA_ST' , Type__c = SalesTeam_DashboardFilterClass.IASPECIALIST);
        lstSTD_ST.add(IATm1);
        IATm2 = new Sales_Team_Hierarchy_ST__c(VP__c = IAVp1.id, ST_Name__c = 'Team 4(0000T0004_ST)', ST_Code__c = 'T0006', Name = 'Team 4(0000T0004_ST)', Hierarchy_Id__c = '0000T0006_IA_ST' , Type__c = SalesTeam_DashboardFilterClass.IASPECIALIST);
        lstSTD_ST.add(IATm2);
        IATm3 = new Sales_Team_Hierarchy_ST__c(VP__c = IAVp1.id, ST_Name__c = 'Team 4(0000T0004_ST)', ST_Code__c = 'T0007', Name = 'Team 4(0000T0004_ST)', Hierarchy_Id__c = '0000T0007_IA_ST' , Type__c = SalesTeam_DashboardFilterClass.IASPECIALIST);
        lstSTD_ST.add(IATm3);
        
        
        insert lstSTD_ST;
        
        List<Sales_Team_Hierarchy_AE__c> lstSTD_AE = new List<Sales_Team_Hierarchy_AE__c>();
        accExecSTH1 = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = salesTeam1.id , Name = accExec1.name + '(0000' + accExec1.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000A' + accExec1.EmployeeNumber + '_AE', AE_Name__c = accExec1.name + '(0000' + accExec1.EmployeeNumber + '_AE)', AE_Code__c = accExec1.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstSTD_AE.add(accExecSTH1);
        accExecSTH2 = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = salesTeam2.id,  Name = accExec2.name + '(0000' + accExec2.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000B' + accExec2.EmployeeNumber + '_AE', AE_Name__c = accExec2.name + '(0000' + accExec2.EmployeeNumber + '_AE)', AE_Code__c = accExec2.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstSTD_AE.add(accExecSTH2);
        accExecSTH3 = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = salesTeam3.id,  Name = accExec3.name + '(0000' + accExec3.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000C' + accExec3.EmployeeNumber + '_AE', AE_Name__c = accExec3.name + '(0000' + accExec3.EmployeeNumber + '_AE)', AE_Code__c = accExec3.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstSTD_AE.add(accExecSTH3);
        accExecSTH4 = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = salesTeam1.id,  Name = accExec4.name + '(0000' + accExec4.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000D' + accExec4.EmployeeNumber + '_AE', AE_Name__c = accExec4.name + '(0000' + accExec4.EmployeeNumber + '_AE)', AE_Code__c = accExec4.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.SALESTEAM);
        lstSTD_AE.add(accExecSTH4);
        salesSpecialist1 = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = salesSplTm1.id , Name = accExec1.name + '(0000' + accExec1.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000A' + accExec1.EmployeeNumber + '_AE_SS', AE_Name__c = accExec1.name + '(0000' + accExec1.EmployeeNumber + '_AE_SS)', AE_Code__c = accExec1.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.SALESSPECIALIST);
        lstSTD_AE.add(salesSpecialist1);
        salesSpecialist2 = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = salesSplTm2.id,  Name = accExec2.name + '(0000' + accExec2.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000B' + accExec2.EmployeeNumber + '_AE_SS', AE_Name__c = accExec2.name + '(0000' + accExec2.EmployeeNumber + '_AE_SS)', AE_Code__c = accExec2.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.SALESSPECIALIST);
        lstSTD_AE.add(salesSpecialist2);
        
        IAExec1 = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = IATm2.id,  Name = accExec2.name + '(0000' + accExec2.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000E' + accExec2.EmployeeNumber + '_AE_SS', AE_Name__c = accExec2.name + '(0000' + accExec2.EmployeeNumber + '_AE_SS)', AE_Code__c = accExec2.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.IASPECIALIST);
        lstSTD_AE.add(IAExec1);
        IAExec2 = new Sales_Team_Hierarchy_AE__c( Sales_Team__c = IATm2.id,  Name = accExec2.name + '(0000' + accExec2.EmployeeNumber + '_AE)' , Hierarchy_Id__c = '000F' + accExec2.EmployeeNumber + '_AE_SS', AE_Name__c = accExec2.name + '(0000' + accExec2.EmployeeNumber + '_AE_SS)', AE_Code__c = accExec2.EmployeeNumber , Type__c = SalesTeam_DashboardFilterClass.IASPECIALIST);
        lstSTD_AE.add(IAExec2);
        
        
        insert lstSTD_AE;
        
        accExecSTH1 = [Select id, Type__c, Sales_Team__c , Sales_Team__r.ST_Code__c, Sales_Team__r.ST_Name__c, AE_Name__c, AE_Code__c, Name, Hierarchy_Id__c   from Sales_Team_Hierarchy_AE__c where id = :accExecSTH1.id];
         
        /*accExecSTH2 = [Select id, Type__c, Sales_Team__c , Sales_Team__r.ST_Code__c, Sales_Team__r.ST_Name__c, AE_Name__c, AE_Code__c, Name, Hierarchy_Id__c   from Sales_Team_Hierarchy_AE__c where id = :accExecSTH2.id];
        accExecSTH3 = [Select id, Type__c, Sales_Team__c , Sales_Team__r.ST_Code__c, Sales_Team__r.ST_Name__c, AE_Name__c, AE_Code__c, Name, Hierarchy_Id__c   from Sales_Team_Hierarchy_AE__c where id = :accExecSTH3.id];
        accExecSTH4 = [Select id, Type__c, Sales_Team__c , Sales_Team__r.ST_Code__c, Sales_Team__r.ST_Name__c, AE_Name__c, AE_Code__c, Name, Hierarchy_Id__c   from Sales_Team_Hierarchy_AE__c where id = :accExecSTH4.id];
        */
        
    }
    
    public void setUpSalesRevenueForFilterTesting()
    {
        //add new fields - Service line & service line group
        salesRevenue = new Sales_Revenue__c[21];
        salesRevenue[0] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Profit_Centre__c = leafRegion1.id  , Opportunity_Stage__c = '1', Offering_Type__c = OT_Core, Offering_Segment__c = OS_National , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 2000, Gross_Q1_Value__c = 4000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c );
        salesRevenue[1] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id ,  Profit_Centre__c = leafRegion1.id  , Opportunity_Stage__c = '2', Offering_Type__c = OT_Core, Offering_Segment__c = OS_GlobalMM, Offering_Group__c = OG_Government , Gross_Q4_Value__c = 200, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 0, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[2] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '3', Offering_Type__c = OT_CES, Offering_Segment__c = OS_Subnational , Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 3200, Gross_Q2_Value__c = 1909, Gross_Q1_Value__c = 2000,CurrencyIsoCode = 'USD', COE_Name__c = CN_Other , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[3] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id,  Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '4', Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_ManagedMS , Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1020, Gross_Q3_Value__c = 1233, Gross_Q2_Value__c = 1234, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_PricingMA , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[4] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id ,  Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '5', Offering_Type__c = OT_Core, Offering_Segment__c = OS_Government, Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_HEOROff, Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[5] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id ,  Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '6', Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Other, Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 2000, Gross_Q2_Value__c = 0, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[6] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH2.id,  Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '6',  Offering_Type__c = OT_Core, Offering_Segment__c = OS_Payer  , Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 2000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 3000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[7] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id ,  Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '6', Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_ConHealth, Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1000 , Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_StrategyPA, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[8] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH2.id,  Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '6', Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_National , Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_Other, Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[9] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '6', Offering_Type__c = OT_Core, Offering_Segment__c = OS_Other, Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_PricingMA , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[10] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.REVENUE, Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '1', Offering_Type__c = OT_CES, Offering_Segment__c = OS_Payer , Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[11] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.REVENUE, Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '2', Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Government, Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[12] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.REVENUE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id,  Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '4', Offering_Type__c = OT_CES, Offering_Segment__c = OS_Subnational , Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_PricingMA , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[13] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.REVENUE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '3', Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Other, Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_Other , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[14] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.REVENUE, Sales_Team_Hierarchy_AE__c = accExecSTH2.id,  Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '5', Offering_Type__c = OT_CES, Offering_Segment__c = OS_GlobalMM , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 1200, Gross_Q2_Value__c = 1200, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_HEOROff, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[15] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.BUDGET, Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Offering_Type__c = OT_SFocusArea, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_GlobalMM, Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 1200, Gross_Q2_Value__c = 1200, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c, Account_Name__c = acc1.name);
        salesRevenue[16] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.BUDGET, Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Offering_Type__c = OT_SFocusArea, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_GlobalMM, Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 1800, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc3.SAP_Reference__c, Account_Name__c = acc2.name);
        salesRevenue[17] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.BUDGET, Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Offering_Type__c = OT_CES, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_ManagedMS , Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = null, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_HEOROff, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c, Account_Name__c = acc1.name);
        salesRevenue[18] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.BUDGET, Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Offering_Type__c = OT_SFocusArea, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_ConHealth, Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1800, Gross_Q3_Value__c = 1800, Gross_Q2_Value__c = 0 , Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_StrategyPA, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c, Account_Name__c = acc2.name);
        salesRevenue[19] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.BUDGET, Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Offering_Type__c = OT_Core, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_ManagedMS, Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 1800, Gross_Q3_Value__c = 1800, Gross_Q2_Value__c = 1800, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_StrategyPA, Account_Parent_ID__c = superParentAcc3.SAP_Reference__c, Account_Name__c = acc1.name);
        salesRevenue[20] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.REVENUE, Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Profit_Centre__c = leafRegion1.id , Opportunity_Stage__c = '1', Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Government, Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 0, Gross_Q1_Value__c = 0,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        insert salesRevenue; 
    }
    
    
     public void setUpSalesRevenueForFCFilterTesting()
    {
        //add new fields - Service line & service line group
        salesRevenue = new Sales_Revenue__c[21];
        salesRevenue[0] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Pipeline', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Opportunity_Stage__c = '1', Profit_Centre__c = leafRegion1.id  , Offering_Type__c = OT_Core, Offering_Segment__c = OS_National , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 2000, Gross_Q1_Value__c = 4000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c );
        salesRevenue[1] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Pipeline', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Opportunity_Stage__c = '2', Profit_Centre__c = leafRegion1.id  , Offering_Type__c = OT_Core, Offering_Segment__c = OS_GlobalMM, Offering_Group__c = OG_Government , Gross_Q4_Value__c = 200, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 0, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[2] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Pipeline', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Opportunity_Stage__c = '3', Profit_Centre__c = leafRegion1.id ,  Offering_Type__c = OT_CES, Offering_Segment__c = OS_Subnational , Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 3200, Gross_Q2_Value__c = 1909, Gross_Q1_Value__c = 2000,CurrencyIsoCode = 'USD', COE_Name__c = CN_Other , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[3] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Pipeline', Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Opportunity_Stage__c = '4', Profit_Centre__c = leafRegion1.id ,  Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_ManagedMS , Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1020, Gross_Q3_Value__c = 1233, Gross_Q2_Value__c = 1234, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_PricingMA , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[4] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Pipeline', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Profit_Centre__c = leafRegion1.id ,  Offering_Type__c = OT_Core, Offering_Segment__c = OS_Government, Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_HEOROff, Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[5] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'On Track', Sales_Team_Hierarchy_AE__c = accExecSTH1.id ,  Opportunity_Stage__c = '6', Profit_Centre__c = leafRegion1.id ,  Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Other, Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 2000, Gross_Q2_Value__c = 0, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[6] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE,  IMS_Forecast_Category__c = 'On Track', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Opportunity_Stage__c = '6', Profit_Centre__c = leafRegion1.id ,  Offering_Type__c = OT_Core, Offering_Segment__c = OS_Payer  , Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 2000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 3000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[7] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE,  IMS_Forecast_Category__c = 'On Track', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Opportunity_Stage__c = '6', Profit_Centre__c = leafRegion1.id , Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_ConHealth, Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1000 , Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_StrategyPA, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[8] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE,  IMS_Forecast_Category__c = 'On Track', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Opportunity_Stage__c = '6', Profit_Centre__c = leafRegion1.id ,  Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_National , Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_Other, Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[9] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'On Track', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Opportunity_Stage__c = '6', Profit_Centre__c = leafRegion1.id , Offering_Type__c = OT_Core, Offering_Segment__c = OS_Other, Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_PricingMA , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[10] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE,  IMS_Forecast_Category__c = 'Best Case', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Opportunity_Stage__c = '1', Profit_Centre__c = leafRegion1.id ,  Offering_Type__c = OT_CES, Offering_Segment__c = OS_Payer , Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[11] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Best Case', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Opportunity_Stage__c = '2', Profit_Centre__c = leafRegion1.id , Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Government, Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[12] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE,IMS_Forecast_Category__c = 'Best Case', Sales_Team_Hierarchy_AE__c = accExecSTH1.id,Opportunity_Stage__c = '4', Profit_Centre__c = leafRegion1.id , Offering_Type__c = OT_CES, Offering_Segment__c = OS_Subnational , Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_PricingMA , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        salesRevenue[13] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Best Case', Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Opportunity_Stage__c = '3', Profit_Centre__c = leafRegion1.id , Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Other, Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_Other , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[14] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Commit', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Opportunity_Stage__c = '5', Profit_Centre__c = leafRegion1.id , Offering_Type__c = OT_CES, Offering_Segment__c = OS_GlobalMM , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 1200, Gross_Q2_Value__c = 1200, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_HEOROff, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        salesRevenue[15] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Commit', Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Offering_Type__c = OT_SFocusArea, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_GlobalMM, Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 1200, Gross_Q2_Value__c = 1200, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c, Account_Name__c = acc1.name);
        salesRevenue[16] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Commit', Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Offering_Type__c = OT_SFocusArea, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_GlobalMM, Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 1800, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc3.SAP_Reference__c, Account_Name__c = acc2.name);
        salesRevenue[17] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, IMS_Forecast_Category__c = 'Commit', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Offering_Type__c = OT_CES, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_ManagedMS , Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = null, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_HEOROff, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c, Account_Name__c = acc1.name);
        salesRevenue[18] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE,IMS_Forecast_Category__c = 'Commit', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Offering_Type__c = OT_SFocusArea, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_ConHealth, Offering_Group__c = OG_ManagedCons, Gross_Q4_Value__c = 1800, Gross_Q3_Value__c = 1800, Gross_Q2_Value__c = 0 , Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_StrategyPA, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c, Account_Name__c = acc2.name);
        salesRevenue[19] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE,IMS_Forecast_Category__c = 'Commit', Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Offering_Type__c = OT_Core, Profit_Centre__c = leafRegion1.id , Offering_Segment__c = OS_ManagedMS, Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 1800, Gross_Q3_Value__c = 1800, Gross_Q2_Value__c = 1800, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_StrategyPA, Account_Parent_ID__c = superParentAcc3.SAP_Reference__c, Account_Name__c = acc1.name);
        salesRevenue[20] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE,IMS_Forecast_Category__c = 'Commit', Sales_Team_Hierarchy_AE__c = accExecSTH2.id, Opportunity_Stage__c = '1',  Profit_Centre__c = leafRegion1.id ,  Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Government, Offering_Group__c = OG_Payer, Gross_Q4_Value__c = 0, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 0, Gross_Q1_Value__c = 0,CurrencyIsoCode = 'USD', COE_Name__c = CN_CompIntelligence, Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        insert salesRevenue; 
    }
        
    public void setUpSalesRevenueForPagination()
    { 
        //sets up sales revenue records for twesting pagination
        setUpRegions();
        setUpUsers();
        setUpAccounts();
        setUpUserHierarchies();
        salesRevenueBulk = new Sales_Revenue__c[200]; 
        
        //data for pipeline - 1 to 5 opportunity stage record
        for(integer i = 0; i < 25; i++)
        {
            salesRevenueBulk[i] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id ,  Opportunity_Stage__c = '1', Profit_Centre__c = leafRegion1.id, Offering_Type__c = OT_Core, Offering_Segment__c = OS_National , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 2000, Gross_Q1_Value__c = 4000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c );
        }
        
        //data for pipeline - 6a opportunity stage record
        for(integer i = 25; i < 50; i++)
        {
            salesRevenueBulk[i] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.PIPELINE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Opportunity_Stage__c = '6', Profit_Centre__c = leafRegion1.id, Offering_Type__c = OT_SFocusArea, Offering_Segment__c = OS_Other, Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 2000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc3.SAP_Reference__c);
        }
        
        //data for revenue records
        for(integer i = 50; i < 75; i++)
        {
            salesRevenueBulk[i] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.REVENUE, Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Profit_Centre__c = leafRegion1.id, Opportunity_Stage__c = '1', Offering_Type__c = OT_CES, Offering_Segment__c = OS_Payer , Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 1000, Gross_Q2_Value__c = 1000, Gross_Q1_Value__c = 1000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c);
        }
        
        //data for budget records
        for(integer i = 75; i < 100; i++)
        {
            salesRevenueBulk[i] = new Sales_Revenue__c(Scenario__c = SalesTeam_DashboardFilterClass.BUDGET, Sales_Team_Hierarchy_AE__c = accExecSTH1.id, Offering_Type__c = OT_SFocusArea, Profit_Centre__c = leafRegion1.id, Offering_Segment__c = OS_GlobalMM, Offering_Group__c = OG_Government , Gross_Q4_Value__c = 1200, Gross_Q3_Value__c = 1200, Gross_Q2_Value__c = 1200, Gross_Q1_Value__c = 1200,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c, Account_Name__c = acc1.name);
        }
        
        
        //data for Best Case FC
        for(integer i = 100; i < 125; i++)
        {
            salesRevenueBulk[i] = new Sales_Revenue__c(Scenario__c = 'Pipeline', IMS_Forecast_Category__c = 'Best Case', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Profit_Centre__c = leafRegion1.id,  Offering_Type__c = OT_Core, Offering_Segment__c = OS_National , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 2000, Gross_Q1_Value__c = 4000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c );
        }
        
        //data for On Track FC
        for(integer i = 125; i < 150; i++)
        {
            salesRevenueBulk[i] = new Sales_Revenue__c(Scenario__c = 'Pipeline', IMS_Forecast_Category__c = 'On Track', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Profit_Centre__c = leafRegion1.id,  Offering_Type__c = OT_Core, Offering_Segment__c = OS_National , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 2000, Gross_Q1_Value__c = 4000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c );
        }
        
        //data for Pipeline FC
        for(integer i = 150; i < 175; i++)
        {
            salesRevenueBulk[i] = new Sales_Revenue__c(Scenario__c = 'Pipeline', IMS_Forecast_Category__c = 'Pipeline', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Profit_Centre__c = leafRegion1.id, Offering_Type__c = OT_Core, Offering_Segment__c = OS_National , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 2000, Gross_Q1_Value__c = 4000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c );
        }
        
        //data for Commit FC
        for(integer i = 175; i < 200; i++)
        {
            salesRevenueBulk[i] = new Sales_Revenue__c( Scenario__c = 'Pipeline', IMS_Forecast_Category__c = 'Commit', Sales_Team_Hierarchy_AE__c = accExecSTH1.id , Profit_Centre__c = leafRegion1.id, Offering_Type__c = OT_Core, Offering_Segment__c = OS_National , Offering_Group__c = OG_Pharma, Gross_Q4_Value__c = 1000, Gross_Q3_Value__c = 0, Gross_Q2_Value__c = 2000, Gross_Q1_Value__c = 4000,CurrencyIsoCode = 'USD', COE_Name__c = CN_BrandCS , Account_Parent_ID__c = superParentAcc1.SAP_Reference__c );
        }
        
        insert salesRevenueBulk; 
    }

}