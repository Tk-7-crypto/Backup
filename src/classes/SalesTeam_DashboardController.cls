//  ********************************    
//  Created by Sneha Rathi on 18 Feb, 2011 
//  Controller class for SalesTeam_Dashboard.Page
//  Contains methods for deciding whether the current user is Admin/Operations/Account Director/Account Executive
//  decide the further flow to display Sales revenue data for team / Account executive using the DashboardDisplay.component  
//
//  Major Refactoring: 27 Sept, 2011 -- changes due to multi picklist options changes
//  Update by: Sneha Date: 08 Dec, 2011 -- target Changes
//  Major Refactoring: 12 Dec, 2011 -- Major Enhancements
//  Date: 13 Dec, 2011 --- Merged Team and AE list for all views
//  Enhancements: 10th Feb, 2012 -- Dynamic list etc changes
//  Major Refactoring: 09 Feb, 2012 --- Allow Sales Revenue with AE -- Profit Center Level view added
//  Enhancement: 24 Feb, 2012 -- Sales Specialist Hierarchy added
//  Enhancement: 15 March, 2012 -- Single PC fix for Ops user
//  Enhancements: --> after 18th March -- PC population logic changed -- User's default PC is now stored in a custom setting and all the leaf child PC under this are selected.
//               No traveling 2 level up the hierarchy required.
//               --> All PC under the user would be shown whether Sales Revenue exists or not against them
//               --> EKam / Gkam users added
//               --> SS removed 
//               --> Custom setting added to check if ETL is refreshing the data
//  9 april, 2012 --> PC hierarchy introduced for Ops user, GKAM/EKAM and data for all child PC's shown
//  Date: 18 April, 2012 --- New filters (Service line and Service Line group) and forecast category changes
//  Update by: Sneha Date: 25th May, 2012 --- replaced the static message with custom setting
//  //Update by: Sneha Date: 22 June, 2012 -- New I&A Hierarchy introduced
//  ********************************

public class SalesTeam_DashboardController {    
    
    public String userId {get;set;}
    private User user; // hold the current logged in user
    public Boolean showDashboard{get; private set;}// boolean to check whether dashboard should be displayed or not
    public String userName{get; private set;}// current user's name
    public String viewLevelName{get; private set;}//name of executive / team(s) whose dashboard is been viewed
    public Boolean haveSalesData{get; private set;}//boolean to check if Sales Revenue Data is present for the AE/Team(s) whose dashboard is been viewed
    public List<targetWrapper> targetData{get; private set;} // holds the target for AE
    public Boolean targetDataExists{get; private set;}//boolean to check if target data exists or not
    public string querySalesTeamStr{get; set;} // stores the current hierarchy
    public List<String> newLstTeamCodesGlobal = new List<String>();
    public static string pcJsonString{get; private set;}// JSON string that contains the Profit centre hierarchy
    private string rootPc; //holds the Top level PC to which current user have access
    private SalesTeamDashboard_PCHierarchyHelper pcHierarchyHelper; // instance for helper class SalesTeamDashboard_PCHierarchyHelper which constructs the JSON by taking out the hierarchy
    
    //static string for User Designation
    public static string getOpsUser()
    {
        return 'Operations User';
    }
    public static string getVpUser()
    {
        return 'Account Director';
    }
    public static string getSlUser()
    {
        return 'Sales Leader';
    }
    public static string getAeUser()
    {
        return 'Account Executive';
    }
    public static string getGkam()
    {
        return 'GKAM';
    }
    public static string getEkam()
    {
        return 'EKAM';
    }
    
    //function to decide Team & Emp Labels
    public String vpLabel{get{
        return 'Select VP';
    } private set;}
    
    public String teamLabel{get{
        return 'Select Team';
    } private set;}
    
    public String EmpLabel{ get{
        //Update by: Sneha Date: 22 June, 2012 -- Label Constant through out in each hierarchy
        return 'Select Executive';
    } private set;}
    
    public boolean multipleHierarchiesExists{get; private set;} // stores whether multiple hierarchies exist
    
    //function to populate Hierarchy list
    public List<SelectOption> hierarchyList{get; private set;}
    
    private List<SelectOption> populateHierarchyList(AggregateResult[] lst)
    {
        List<SelectOption> options = new List<SelectOption>();
        if(this.filterOptions.userDesignation == getOpsUser())
        {
            options.add(new SelectOption(SalesTeam_DashboardFilterClass.PROFITCENTRE,SalesTeam_DashboardFilterClass.PROFITCENTRE)); 
            options.add(new SelectOption(SalesTeam_DashboardFilterClass.SALESTEAM,'Account Executive'));                            
            options.add(new SelectOption(SalesTeam_DashboardFilterClass.SALESSPECIALIST,SalesTeam_DashboardFilterClass.SALESSPECIALIST));
            options.add(new SelectOption(SalesTeam_DashboardFilterClass.IASPECIALIST,SalesTeam_DashboardFilterClass.IASPECIALIST));
        }
        else
        {
            for(AggregateResult l: lst)
            {
                String hierarchyOpt = (String)l.get('ty');
                if(hierarchyOpt == 'Sales Team')
                    options.add(new SelectOption(hierarchyOpt, 'Account Executive'));
                else
                    options.add(new SelectOption(hierarchyOpt, hierarchyOpt));
            }
        }
        return options;
    }
    
    
    public string selectedOpsProfitCenter{get; set;}// the currently selected Profit center by Operations user
    private List<string> childPCs;// hold all child PC id's for the selected Profit center
    
    // constructs the list of teams under any top level user
    private List<String> lstTeamCodes;
    public List<SelectOption> Teams{get; private set;}//list of options
    // Change by anjali - BEGIN
    private List<String> lstVPCodes;
    public List<SelectOption> VPs{get; private set;}//list of options
    public string selectedVP{get; set;}// the currently selected VP code by Operations user/ EKAM / GKAM
    //change by anjali - END 
    public string selectedTeam{get; set;}// the currently selected Team code by Operations user/ Vp / Sales Team Leader 
    
    //constructs the list of Account Executive under any team
    public List<SelectOption> AccountExecutive{get; private set;}//list of options
    public string selectedAccountExecutive{get; set;}// the currently selected Account Executive code by Operations user / VP / Sales Leader
    
    public SalesTeam_DashboardFilterClass filterOptions{get; set;} // instance of helper filter class
    
    // -- Quarter list --
    public static List<SelectOption> getQuarterList() {
        List<SelectOption> options = new List<SelectOption>();    
        options.add(new SelectOption(SalesTeam_DashboardFilterClass.FYString,SalesTeam_DashboardFilterClass.FYString));                            
        options.add(new SelectOption(SalesTeam_DashboardFilterClass.Q1String,SalesTeam_DashboardFilterClass.Q1String));
        options.add(new SelectOption(SalesTeam_DashboardFilterClass.Q2String,SalesTeam_DashboardFilterClass.Q2String));
        options.add(new SelectOption(SalesTeam_DashboardFilterClass.Q3String,SalesTeam_DashboardFilterClass.Q3String));
        options.add(new SelectOption(SalesTeam_DashboardFilterClass.Q4String,SalesTeam_DashboardFilterClass.Q4String));
        options.add(new SelectOption(SalesTeam_DashboardFilterClass.YTDString,SalesTeam_DashboardFilterClass.YTDString));  
        return options;                          
    }
    
    // -- for Offering Group --    
    public static List<SelectOption> getOfferingGroupList()
    {
        return SalesTeam_DashboardFilterClass.populateOptions(Product2.Offering_Group__c.getDescribe());
    }
    
    // -- for Offering Segment --
    public static List<SelectOption> getOfferingTypeList()
    {
        return SalesTeam_DashboardFilterClass.populateOptions(Product2.Offering_Type__c.getDescribe());
        
    }
    
    // -- for Offering Type
    public static List<SelectOption> getOfferingSegmentList()
    {
        return SalesTeam_DashboardFilterClass.populateOptions(Product2.Offering_Segment__c.getDescribe());
    }
    
    //-- for COE name -- 
    public static List<SelectOption> getCoeNameList()
    {
        return SalesTeam_DashboardFilterClass.populateOptions(Product2.COE_Name__c.getDescribe());
    }
    
    //-- for Global Product --
    public static List<SelectOption> getGlobalProductLst()
    {
        return SalesTeam_DashboardFilterClass.populateOptions(Product2.Global_Product__c.getDescribe());
    }
    
    // -- for Super Parent Account --
    private set<String> SuperParentAccSapRef;//Contains Sap reference values for all the Accounts for EKAM/GKAM 
    public List<SelectOption> getParentAccountList() { 
        List<SelectOption> options = new List<SelectOption>();      
        List<Account> lstAccounts = new List<Account>();
        // Update on: 7th MAp -- For EKAM & GKAM add only specific accounts which they have access to, else show all Super Parent Account
        if(this.filterOptions.userDesignation == getGkam() || this.filterOptions.userDesignation == getEkam())
        {
            lstAccounts = [Select a.Name, a.SAP_Reference__c, a.MDMID__c From Account a  where a.MDMID__c in :SuperParentAccSapRef order by a.Name ASC];
        }
        else
        {
            lstAccounts = [Select a.Name, a.SAP_Reference__c, a.MDMID__c From Account a where a.RecordType.Name like 'Global Customer Account' order by a.Name ASC];
        }
        for(Account acc: lstAccounts)
        {
            //if(acc.SAP_Reference__c != null && acc.SAP_Reference__c != '')
                //options.add(new Selectoption(acc.SAP_Reference__c ,acc.Name));
            if(acc.MDMID__c != null && acc.MDMID__c != '')
                options.add(new Selectoption(acc.MDMID__c ,acc.Name));
        }
        lstAccounts = null;
        return options;
    }   
    
    // -- for Service Line -- 
    public static List<SelectOption> getServiceLineList()
    {
        return SalesTeam_DashboardFilterClass.populateOptions(Sales_Revenue__c.Service_Line__c.getDescribe());
    }
    
    // -- for Service Line Group -- 
    public static List<SelectOption> getServiceLineGroupList()
    {
        return SalesTeam_DashboardFilterClass.populateOptions(Sales_Revenue__c.Service_Line_Group__c.getDescribe());
    }
    
    //constructor
    public SalesTeam_DashboardController(ApexPages.StandardController controller)
    {  
        userId = '';
        reInitialize();
    }
    
    public void updateRunAsUser()
    {  
        if(userId != null && userId != ''){
            reInitialize();
        }
    }
    
    private void reInitialize(){
		this.filterOptions = new SalesTeam_DashboardFilterClass(); //initialises the filterClass Instance
        //Update by: Sneha Date: 5th April 2012 -- Added a check if ETL is refreshing the dashoard
        //SalesTeamDashboardPCAccess__c dashboardLocked = SalesTeamDashboardPCAccess__c.getOrgDefaults();
        //if(dashboardLocked.DashboardLocked__c)
        //{
        //this.showDashboard = true;
        //this.haveSalesData = false;
        //this.viewLevelName = Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
        //String error = dashboardLocked.DashboardLockedMessage__c + '<br/><br/><a  href="/home/home.jsp" target="_parent">Click here to return to the homepage</a>';
        //ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO , error );
        //ApexPages.addMessage(infoMsg);
        //this.multipleHierarchiesExists = false;
        //this.querySalesTeamStr = 'None';
        //this.filterOptions.userDesignation = getAEUser();
        //return;
		//}
        
        //variables initialised with default values
        this.showDashboard = false;
        this.selectedOpsProfitCenter = 'None';
        this.selectedAccountExecutive = 'None';
        this.selectedTeam = 'None';
        //change by anjali - begin
        this.selectedVP = 'None';
        lstVPCodes = new List<String>();
        //change by anjali - end
        this.multipleHierarchiesExists = false;
        AggregateResult[] hierarchyLst;
        lstTeamCodes = new List<String>();        
        hierarchyList = new List<SelectOption>();
        
        //system.assert(false,ApexPages.currentPage().getURL());
        //fetch the current users ID & profile details for the current logged in user
        String currentUserid = Userinfo.getUserId();
        Profile P = [select Id,Name from Profile where Id = :userInfo.getProfileId() limit 1];
        //check for system administrator so that he/she can view any other users dashboard using runasid
        if (userId != null && userId != '' && P.Name.toLowerCase().contains('system administrator'))
        { 
            //when any other user's dashboard can be viewed make it the current user in case of system admin & runasid parameter present
            //currentUserId = ApexPages.currentPage().getParameters().get('runasid');
            currentUserId = userId;
        }
        
        //Check for user details
        //Added by Sneha Rathi : 27 dec 2012 : Querying User_Country__c from user
        List<User> ur = [SELECT id, Ops_Sales_Team_Dashboard_Access__c,User_Country__c, Profile.Name, Name, EmployeeNumber from User where id = :currentUserid limit 1];
        if(ur.size() == 0)
        {
            this.showDashboard = true;
            this.haveSalesData = false;
            this.querySalesTeamStr = 'None';
            addError(' User does not exist against the Specified ID. Please give a valid user Id to view his/her Dashboard.', false); 
            return;
        }
        else
        {    
            user = ur[0];
            //Added By Sneha rathi : 27 dec 2012 : Check if user is japanese or not and set the isJapaneseUser flag accordingly
            if(user.User_Country__c == 'Japan')
                this.filterOptions.isJapaneseUser = true;   
        }
        
        this.userName = user.Name;//display name in header
        
        // Operations user - if its profile contains string 'operations' or the Ops_Sales_Team_Dashboard_Access__c in his/her record is set to true
        // GKAM - Have records in Account Manager object with role 'GKAM'
        // EKAM - Have records in Account Manager object with role 'EKAM'
        // Account Director - if his/her EmployeeNumber is present in VP_Code__c in any of the Sales Team Hierarchy records
        // Sales Team Leader - if his/her Emp Number is present in the ST_Code__c field in any of the Sales_Team_Hierarchy_ST__c record
        // else Account Executive
        
        for(Sales_Revenue__c sr: [select LastModifiedDate from Sales_Revenue__c order by LastModifiedDate desc limit 1])
        {
            DateTime st = sr.LastModifiedDate.addDays(-1);
            //Issue-01959 - Consider timezone for timestamp on MyDashboard disclaimer
            this.filterOptions.refreshDate = st.format('EEE d MMM yyyy', 'US/Eastern');  
        }
        
        //Check if user is ops user.
        //if (user.Profile.Name.toLowerCase().contains('operations') || user.Ops_Sales_Team_Dashboard_Access__c) // when user is operations user
        //{ 
            
        // we have used a Custom setting for overriding an Ops user's PC
        if(SalesTeamDashboardPCAccess__c.getInstance(user.id) != null && SalesTeamDashboardPCAccess__c.getInstance(user.id).Assigned_Profit_Center__c != null && SalesTeamDashboardPCAccess__c.getInstance(user.id).Assigned_Profit_Center__c != '' && SalesTeamDashboardPCAccess__c.getInstance(user.id).Assigned_Profit_Center__c != 'NONE') 
        {
            this.filterOptions.userDesignation = getOpsUser();
            rootPc = SalesTeamDashboardPCAccess__c.getInstance(user.id).Assigned_Profit_Center__c;
            //build the JSON string for the PC which holds all child PC hierarchy
            List<Profit_Centre__c> lstregion = [Select id from Profit_Centre__c p where p.ProfitCenterCode__c  = :rootPc];
            if(lstregion.size() > 0)
            {
                pcHierarchyHelper = new SalesTeamDashboard_PCHierarchyHelper();
                pcJsonString = pcHierarchyHelper.getHierarchyJSON(rootPc);
                pcHierarchyHelper = null;
                this.multipleHierarchiesExists = true;
                //Update by: Sneha Date: 26 June, 2012 -- Dynamically generating the hierachy list
                this.hierarchyList = populateHierarchyList(new AggregateResult[]{});  
            }
            else
            {
                addError(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP_Ops, false);
            }
        }
        //else //if no profit center assigned add a error to page
        //addError(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP_Ops, false);   
        //}
        else
        {
            //GKAM user check
            List<Account_Manager__c> lstAccManager = [Select a.Account__r.SAP_Reference__c, a.Account__r.MDMID__c From Account_Manager__c a where a.User__c = :user.id and Role__c = :getGkam()];
            if(lstAccManager.size() > 0)
            {
                this.filterOptions.userDesignation = getGkam();
                //compile a set of all Super Parent account which user have access to
                SuperParentAccSapRef = new Set<String>();
                for(Account_Manager__c accM: lstAccManager)
                {
                    //SuperParentAccSapRef.add(accM.Account__r.SAP_Reference__c);
                    SuperParentAccSapRef.add(accM.Account__r.MDMID__c);
                }
                this.querySalesTeamStr = getGkam();
                rootPc = SalesTeam_DashboardFilterClass.gkamRootPcCode; //Gkam has access to all the regions
                //build the JSON string for the PC which holds all child PC hierarchy
                pcHierarchyHelper = new SalesTeamDashboard_PCHierarchyHelper();
                pcJsonString = pcHierarchyHelper.getHierarchyJSON(rootPc);
                pcHierarchyHelper = null;
                lstAccManager = null;
            }
            else
            {   
                //EKAM user check
                List<Account_Manager__c> lstEAccManager = [Select a.Account__r.SAP_Reference__c, a.Account__r.MDMID__c From Account_Manager__c a where a.User__c = :user.id and Role__c = :getEkam()];
                if(lstEAccManager.size() > 0)
                {
                    this.viewLevelName = user.Name;
                    this.filterOptions.userDesignation = getEkam();
                    //compile a set of all Super Parent account which user have access to
                    SuperParentAccSapRef = new Set<String>();
                    for(Account_Manager__c accM: lstEAccManager)
                    {
                        //SuperParentAccSapRef.add(accM.Account__r.SAP_Reference__c);
                        SuperParentAccSapRef.add(accM.Account__r.MDMID__c);
                    }
                    this.querySalesTeamStr = getEkam();
                    rootPc = SalesTeam_DashboardFilterClass.ekamRootPcCode; // Ekam has all regions under Europe 
                    //build the JSON string for the PC which holds all child PC hierarchy
                    pcHierarchyHelper = new SalesTeamDashboard_PCHierarchyHelper();
                    pcJsonString = pcHierarchyHelper.getHierarchyJSON(rootPc);
                    pcHierarchyHelper = null;
                    lstEAccManager = null;
                }
                else
                {       
                    //Account Director/VP user check
                    hierarchyLst = [Select s.Type__c ty From Sales_Team_Hierarchy_VP__c s where s.VP_Code__c = :user.EmployeeNumber group by s.Type__c order by Type__c asc];
                    if(hierarchyLst.size() > 0)
                    {
                        //Update by: Sneha Date: 28 June, 2012 -- Defaulted to first hierarchy
                        this.filterOptions.userDesignation = getVpUser();                        
                        querySalesTeamStr = (String)hierarchyLst[0].get('ty');
                        if(hierarchyLst.size() >= 2)
                        {
                            this.multipleHierarchiesExists = true;
                            //Update by: Sneha Date: 26 June, 2012 -- Dynamically generating the hierachy list
                            this.hierarchyList = populateHierarchyList(hierarchyLst);
                        }
                        vpUserFlow();
                        hierarchyLst = null;
                    }
                    else
                    {
                        // Sales Leader Check
                        hierarchyLst = [Select s.Type__c ty From Sales_Team_Hierarchy_ST__c s where s.ST_Code__c = :user.EmployeeNumber group by s.Type__c order by Type__c asc];
                        if(hierarchyLst.size() > 0)
                        {
                            this.filterOptions.userDesignation = getSlUser();
                            //Update by: Sneha Date: 28 June, 2012 -- Defaulted to first hierarchy
                            querySalesTeamStr = (String)hierarchyLst[0].get('ty');  
                            if(hierarchyLst.size() >= 2)
                            {
                                this.multipleHierarchiesExists = true;
                                //Update by: Sneha Date: 26 June, 2012 -- Dynamically generating the hierachy list
                                this.hierarchyList = populateHierarchyList(hierarchyLst);
                            }
                            SalesLeaderUserFlow();
                            this.filterOptions.SelectedTeamCode.add(selectedTeam);
                            filterSetter(SalesTeam_DashboardFilterClass.queryTM, querySalesTeamStr,selectedOpsProfitCenter, true);
                            displayName(this.filterOptions.SelectedTeamCode[0]);
                            this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
                            hierarchyLst = null;
                        }
                        else
                        {
                            //AE user check
                            this.filterOptions.userDesignation = getAeUser();
                            hierarchyLst = [select Type__c ty from Sales_Team_Hierarchy_AE__c where AE_Code__c = :User.EmployeeNumber group by Type__c order by Type__c asc];
                            if(hierarchyLst.size() == 0)
                            {
                                //if not present, add error to page
                                this.viewLevelName = user.Name;
                                this.haveSalesData = false;
                                this.showDashboard = true;
                                this.querySalesTeamStr = 'None';
                                addError(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, false);  
                            }
                            //Update by: Sneha Date: 28 June, 2012 -- Defaulted to first hierarchy
                            else 
                            {
                                this.querySalesTeamStr = ((String)hierarchyLst[0].get('ty'));
                                if(hierarchyLst.size() >= 2)
                                {
                                    multipleHierarchiesExists = true;
                                    this.hierarchyList = populateHierarchyList(hierarchyLst);
                                }
                                normalUserFlow();
                            }
                            hierarchyLst = null;
                        }
                    }
                }  
            }
        }          
    }
    
    
    //helper function to set all common filter data
    public void filterSetter(string queryLvl, String hrLevl, String pc, boolean displayDashboard)
    {
        this.filterOptions.QueryLevel = queryLvl;
        this.filterOptions.HierarchyLevel = hrLevl;
        this.filterOptions.selectedProfitCenter = pc;
        this.filterOptions.childRegionIDs = childPCs;
        this.showDashboard = displayDashboard;
    }
    
    //handles the data display and user flow
    public void userFlow()
    {
        this.filterOptions.refreshAllfilterData();
        this.showDashboard = false;
        this.haveSalesData = false;
        this.viewLevelName = '';
        //if ops user
        if(this.filterOptions.userDesignation == getOpsUser())
        {
            if(querySalesTeamStr == SalesTeam_DashboardFilterClass.PROFITCENTRE) // PC centre data view
            {
                filterSetter(SalesTeam_DashboardFilterClass.queryPC, querySalesTeamStr,selectedOpsProfitCenter, true);
                this.viewLevelName = this.filterOptions.selectedProfitCenter;
                this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
            }
            //changes added by anjali - start - changes for display name
            //when a particular VP has been selected
            else if(selectedVP != null && selectedVP != '' && selectedVP != 'All' && selectedVP != 'None' && selectedTeam == 'All' && selectedAccountExecutive == 'All'){
                this.filterOptions.SelectedTeamCode.add(selectedTeam);                
                this.filterOptions.selectedSTHids.add(selectedAccountExecutive);
                filterSetter(SalesTeam_DashboardFilterClass.queryPC, querySalesTeamStr,selectedOpsProfitCenter, true);
                displayName(selectedVP);
                this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
            }
            //chages added by anjali - end 
            else if(selectedTeam == 'All' && selectedAccountExecutive == 'All') // if viewing data for any PC in ST/SS hierarchy
            {
                this.filterOptions.SelectedTeamCode.add(selectedTeam);                
                this.filterOptions.selectedSTHids.add(selectedAccountExecutive);
                filterSetter(SalesTeam_DashboardFilterClass.queryPC, querySalesTeamStr,selectedOpsProfitCenter, true);
                this.viewLevelName = 'All Teams';
                this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
            }
            else if(selectedAccountExecutive == 'All')// if viewind data for any team in a PC
            {
                this.filterOptions.SelectedTeamCode.add(selectedTeam);
                this.filterOptions.selectedSTHids.add(selectedAccountExecutive);
                filterSetter(SalesTeam_DashboardFilterClass.queryTM, querySalesTeamStr,selectedOpsProfitCenter, true);
                displayName(this.filterOptions.SelectedTeamCode[0]);
                this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
            }
            else if(selectedAccountExecutive != 'All' && selectedAccountExecutive != 'None' ) // if viewing data for any AE in a PC
            {
                this.filterOptions.SelectedTeamCode.add(selectedTeam);
                this.filterOptions.selectedSTHids.add(selectedAccountExecutive);
                filterSetter(SalesTeam_DashboardFilterClass.queryAE, querySalesTeamStr,selectedOpsProfitCenter, true);
                if(selectedAccountExecutive == 'No Sales Specialist' || selectedAccountExecutive == 'No Account Executive' || selectedAccountExecutive == 'No I&A Specialist')
                    this.viewLevelName = selectedAccountExecutive;
                else
                    displayName(this.filterOptions.selectedSTHids[0]);  
                this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
            }
        }
        //for EKAM & GKAM
        else if(this.filterOptions.userDesignation == getGkam() || this.filterOptions.userDesignation == getEkam())
        {
            filterSetter(SalesTeam_DashboardFilterClass.queryPC, querySalesTeamStr,selectedOpsProfitCenter, true);
            this.filterOptions.ParentAccount.addAll(SuperParentAccSapRef);
            this.haveSalesData = true;
            this.viewLevelName = this.filterOptions.selectedProfitCenter;
        }
        //not an ops user - VP or SL
        else if(selectedTeam == 'All' && selectedAccountExecutive == 'All') //if not an ops user and viewing data for all teams
        {
            integer cnt = lstTeamCodes.size();
            for(integer i = 0; i < cnt; i++)
            {
                this.filterOptions.SelectedTeamCode.addAll(lstTeamCodes);
            }
            filterSetter(SalesTeam_DashboardFilterClass.queryTM, querySalesTeamStr,selectedOpsProfitCenter, true);
            this.viewLevelName = 'All Teams';   
            this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
        }
        else if(selectedAccountExecutive == 'All')// if viewing data for any Team
        {
            this.filterOptions.SelectedTeamCode.add(selectedTeam);
            filterSetter(SalesTeam_DashboardFilterClass.queryTM, querySalesTeamStr,selectedOpsProfitCenter, true);
            displayName(this.filterOptions.SelectedTeamCode[0]);
            this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
        }
        else if(selectedAccountExecutive != 'All' && selectedAccountExecutive != 'None') // viewing data for any AE
        {
            this.filterOptions.selectedSTHids.add(selectedAccountExecutive);
            filterSetter(SalesTeam_DashboardFilterClass.queryAE, querySalesTeamStr,selectedOpsProfitCenter, true);
            displayName(this.filterOptions.selectedSTHids[0]);
            this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
        }
        //call to function to fill the target data 
        if(!this.filterOptions.isJapaneseUser){
            fillTargetData(); 
        } 
    }    
    
    //function for VP user flow
    public void vpUserFlow()
    {
        for(Sales_Team_Hierarchy_ST__c sthST : [Select id,Vp__c From Sales_Team_Hierarchy_ST__c st where st.Type__c = :querySalesTeamStr and st.VP__r.VP_Code__c = :user.EmployeeNumber ])
        {
            lstTeamCodes.add(sthST.id);
            selectedVP = sthST.vp__c;
        }        
        this.filteroptions.selectedVP = selectedVP;
        populateTeams();
        populateAE();
    }
    
    //function for normal user flow
    public void normalUserFlow()
    {
        this.filterOptions.refreshAllfilterData();
        filterSetter(SalesTeam_DashboardFilterClass.queryAE, querySalesTeamStr,selectedOpsProfitCenter, true);
        this.filterOptions.selectedSTHids = new List<String>();
        List<Sales_Team_Hierarchy_AE__c> tempSTH = [select Id from Sales_Team_Hierarchy_AE__c where AE_Code__c = :user.EmployeeNumber and Type__c = :querySalesTeamStr];
        integer cnt = tempSTH.size();
        for(integer i = 0; i < cnt; i++)
        {
            this.filterOptions.selectedSTHids.add(tempSTH.get(i).ID);  
        }
        this.haveSalesData = checkSalesRevenuePresence(SalesTeam_DashboardFilterClass.ERROR_NON_SETUP, true);
        displayName(this.filterOptions.selectedSTHids[0]);
        fillTargetData();
        tempSTH = null;
    }
    
    //function for ST user flow
    public void SalesLeaderUserFlow()
    {
        for(Sales_Team_Hierarchy_ST__c tm: [Select s.id From Sales_Team_Hierarchy_ST__c s where s.ST_Code__c = :user.EmployeeNumber and s.Type__c = :querySalesTeamStr order by s.ST_Name__c])
        {
            lstTeamCodes.add(tm.id);
        }
        populateTeams();
        if(lstTeamCodes.size() > 0)
        selectedTeam = lstTeamCodes[0];
        populateAE();
    }
    
    //Add error supplied as string to page
    public void addError(String err, Boolean addHierarchy)
    {
        String error = 'Your ';
        if(addHierarchy)
            error = error + (querySalesTeamStr == 'Sales Team' ? 'Account Executive' : querySalesTeamStr);
        error = error + err + '<br/><br/><a  href="/home/home.jsp" target="_parent">Click here to return to the homepage</a>';
        ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO , error );
        ApexPages.addMessage(infoMsg);
    }
    
    //change by anjali - begin
    //populates the Team list   
    private void populateVPs()
    {
        VPs = new List<SelectOption>();
        if(lstVPCodes != null && lstVPCodes.size() > 0)
        {
            VPs.add(new SelectOption('All', '--All--'));
            //for(Sales_Team_Hierarchy_VP__c vpRec : [Select s.VP_Name__c, s.id From Sales_Team_Hierarchy_VP__c s where s.id in :lstVPCodes order by s.VP_Name__c])
            for(Sales_Team_Hierarchy_VP__c vpRec : [Select s.VP_Name__c, s.id From Sales_Team_Hierarchy_VP__c s where s.id in :lstVPCodes and Type__c =:querySalesTeamStr order by s.VP_Name__c])
            {
                VPs.add(new SelectOption(vpRec.id, vpRec.VP_Name__c));
            }
            selectedVP = 'All';  
        }
        else
        {
            VPs.add(new SelectOption('None', '--None--'));
            selectedVP = 'None';
        }
    } 
    //change by anjali - end
    
    //populates the Team list   
    private void populateTeams()
    {
        Teams = new List<SelectOption>();
        if(lstTeamCodes != null && lstTeamCodes.size() > 0){
            Teams.add(new SelectOption('All', '--All--'));            
            //change added by anjali - begin
            List<String> newLstTeamCodes = new List<String>();
            if(selectedVP != null && selectedVP != 'All' && selectedVP != 'None' && selectedVP != ''){   
                this.filterOptions.selectedVP = selectedVP;
                for(Sales_Team_Hierarchy_ST__c stRec : [Select s.ST_Name__c, s.id From Sales_Team_Hierarchy_ST__c s where s.id in :newLstTeamCodesGlobal
                                                        and VP__C =: selectedVP order by s.ST_Name__c])
                {
                    Teams.add(new SelectOption(stRec.id, stRec.ST_Name__c));
                    newLstTeamCodes.add(stRec.id);
                }
                //chagne lstTeamCodes since it is being used in filtercriteria class for generating query string
                lstTeamCodes = (newLstTeamCodes);
            } else{ // if (selectedVP == 'All' ){
                if(newLstTeamCodesGlobal.size() == 0){
                    newLstTeamCodesGlobal = new List<String>();
                for(Sales_Team_Hierarchy_ST__c stRec : [Select s.ST_Name__c, s.id From Sales_Team_Hierarchy_ST__c s where s.id in :lstTeamCodes order by s.ST_Name__c])
                {
                    Teams.add(new SelectOption(stRec.id, stRec.ST_Name__c));
                        newLstTeamCodesGlobal.add(stRec.id);
                    }
                }else{
                    for(Sales_Team_Hierarchy_ST__c stRec : [Select s.ST_Name__c, s.id From Sales_Team_Hierarchy_ST__c s where s.id in :newLstTeamCodesGlobal order by s.ST_Name__c]){
                        Teams.add(new SelectOption(stRec.id, stRec.ST_Name__c));
                    }
                }
            }
            //change added by anjali - end
            selectedTeam = 'All';    
        }
        else
        {
            Teams.add(new SelectOption('None', '--None--'));
            selectedTeam = 'None';
        }
    }    
    
    
    //populates the list of AE
    private void populateAE()
    {
        AccountExecutive = new List<SelectOption>();
        if((this.filteroptions.userDesignation  == getOpsUser() &&  (selectedOpsProfitCenter == 'None' || selectedOpsProfitCenter== null)) || selectedTeam == 'None')
        {
            AccountExecutive.add(new SelectOption('None', '--None--')); 
            selectedAccountExecutive = 'None';
        }
        else
        {
            AccountExecutive.add(new SelectOption('All', '--All--')); 
            String queryStr = 'select id, AE_Name__c from Sales_Team_Hierarchy_AE__c where Sales_Team__c ';
            if(selectedTeam == 'All')
                queryStr = queryStr + 'in ( ' + filterOptions.CommaSeperatedvalues(lstTeamCodes) + ' ) ';
            else
                queryStr = queryStr + '= \''+selectedTeam+'\'';
            if(selectedVP != null && selectedVP != 'All' && selectedVP != 'None') {
                queryStr = queryStr + ' and sales_team__r.VP__c = \'' + selectedVP +'\'';
            } 
            queryStr = queryStr + ' order by AE_Name__c ASC';
            system.debug('queryStr ' + queryStr + ' * ' + selectedTeam ); 
            List<Sales_Team_Hierarchy_AE__c> lstAEResult = Database.Query(queryStr);
            
            integer cnt = lstAEResult.size();     
            system.debug('queryStr ' + queryStr + ' * ' + selectedTeam );          
            for(integer i = 0; i < cnt; i++)
            {
                AccountExecutive.add(new SelectOption(lstAEResult[i].id, lstAEResult[i].AE_Name__c)); 
            }
            lstAEResult = null;
            selectedAccountExecutive = 'All';
        }
        if(this.filterOptions.userDesignation == getOpsUser())
        {
            //Update by: Sneha Date: 22 jnue, 2012 - New option added for I&A hierarchy
            if(querySalesTeamStr == SalesTeam_DashboardFilterClass.SALESTEAM)
                AccountExecutive.add(new SelectOption('No Account Executive', 'No Account Executive')); 
            else if(querySalesTeamStr == SalesTeam_DashboardFilterClass.SALESSPECIALIST)
                AccountExecutive.add(new SelectOption('No Sales Specialist', 'No Sales Specialist')); 
            else if(querySalesTeamStr == SalesTeam_DashboardFilterClass.IASPECIALIST)
                AccountExecutive.add(new SelectOption('No I&A Specialist', 'No I&A Specialist')); 
        }
        
    }
    
    //Function to check if Sales Revenue Data exists for the Selected team(s)/AE
    public Boolean checkSalesRevenuePresence(String err, boolean addHierarchy)
    {
        Boolean salesDataPresent = false;
        String salesQuery = 'Select s.id From Sales_Revenue__c s ';
        if(this.filterOptions.QueryLevel == SalesTeam_DashboardFilterClass.queryAE) //if Account Executive view
        {
            //Update by: Sneha Date: 22 June, 2012 -- Made generic using map
            salesQuery = salesQuery + ' where s.' + SalesTeam_DashboardFilterClass.getMapHierarchyField().get(querySalesTeamStr) + '__c'; 
            if((this.filterOptions.userDesignation == getOpsUser()) && this.filterOptions.selectedSTHids.size() == 1 && (this.filterOptions.selectedSTHids[0] == 'No Sales Specialist' || this.filterOptions.selectedSTHids[0] == 'No Account Executive' || this.filterOptions.selectedSTHids[0] == 'No I&A Specialist'))
            {
                salesQuery = salesQuery + ' = null';
            }
            else
                salesQuery = salesQuery + ' in ('+filterOptions.CommaSeperatedvalues(this.filterOptions.selectedSTHids) + ')';
            
            if(this.filterOptions.userDesignation == getOpsUser())
            {
                //Replaced Name Chain with Code Chain by Abhishek Bansal : 20-September-2017 : Issue-11239 : Start/End
                salesQuery = salesQuery + ' and s.Profit_Centre__r.Profit_Center_Code_Chain__c like \'%('+ this.filterOptions.selectedProfitCenter +')%\''  ;
            }
        }
        else if(this.filterOptions.QueryLevel == SalesTeam_DashboardFilterClass.queryTM) //if Team(s) View
        {
            //Update by: Sneha Date: 22 June, 2012 -- Made generic using map
            salesQuery = salesQuery +  ' where s.'+ SalesTeam_DashboardFilterClass.getMapHierarchyField().get(querySalesTeamStr) +'__r.Sales_Team__c in (' + filterOptions.CommaSeperatedvalues(this.filterOptions.SelectedTeamCode) + ' ) ';
            if(this.filterOptions.userDesignation == getOpsUser())
            {
                salesQuery = salesQuery + ' and s.Profit_Centre__c in ('+ this.filterOptions.CommaSeperatedvalues(this.filterOptions.childRegionIDs)+ ')'; 
            } 
        } 
        else if(this.filterOptions.QueryLevel == SalesTeam_DashboardFilterClass.queryPC)
        {
            salesQuery = salesQuery + ' where s.Profit_Centre__c in (' + this.filterOptions.CommaSeperatedvalues(this.filterOptions.childRegionIDs) + ')';
        }
        else
        {
            addError(err, addHierarchy);
            return salesDataPresent;
        }           
        salesQuery = salesQuery + ' limit 1';
        for(Sales_Revenue__c sr: Database.query(salesQuery))
        {
            salesDataPresent = true;
        }
        if(!salesDataPresent)
            addError(err, addHierarchy);
        return salesDataPresent;  
    }
    
    //Function to fetch the Name for the Team/AE selected for View
    public void displayName(string searchID)
    {
        String nm = '';
        if(this.filterOptions.QueryLevel == SalesTeam_DashboardFilterClass.queryAE) // for Account Executive
        {
            for(Sales_Team_Hierarchy_AE__c temp : [Select s.AE_Name__c From Sales_Team_Hierarchy_AE__c s where s.id = :searchID Limit 1])
            {
                if(temp.AE_Name__c != null)
                    nm = temp.AE_Name__c;   
            }
        }
        else if(this.filterOptions.QueryLevel == SalesTeam_DashboardFilterClass.queryTM) //for team
        {
            
            for(Sales_Team_Hierarchy_ST__c temp : [Select s.ST_Name__c From Sales_Team_Hierarchy_ST__c s where s.id = :searchID Limit 1])
            {
                if(temp.ST_Name__c != null)
                    nm = temp.ST_Name__c;   
            }
        } else if(this.filterOptions.QueryLevel == SalesTeam_DashboardFilterClass.queryPC){ //for VP
            //changes by anjali - start
            if(selectedVP != null && selectedVP != '' && selectedVP!= 'All' && selectedVP != 'None' && selectedTeam == 'All' && selectedAccountExecutive == 'All') {
                for(Sales_Team_Hierarchy_VP__c temp : [Select s.VP_Name__c From Sales_Team_Hierarchy_VP__c s where s.id = :searchID Limit 1])
                {
                    if(temp.VP_Name__c != null)
                        nm = temp.VP_Name__c;   
                }
            } 
            //changes by anjali - end
        }
        
        Integer startPOS = nm.indexOf('(',0);
        if(startPOS > 0)
            this.viewLevelName = nm.substring(0,startPOS);
        else
            this.viewLevelName = nm;         
    }
    
    
    //initialises the team list and AE list if the PC is Changed
    public void profitCentreChanged()
    {
        //for a ops user -- refresh the selected data beneath
        if(this.filterOptions.userDesignation == getOpsUser())
        {
            this.querySalesTeamStr = SalesTeam_DashboardFilterClass.PROFITCENTRE;
            this.selectedAccountExecutive = 'None';
            this.selectedTeam = 'None';
            this.selectedVP = null;
        }
        
        //populate a list of all child PC under the selected PC
        childPCs = new List<String>();
        lstVPCodes = new List<String>();
        newLstTeamCodesGlobal = new List<String>();
        if(selectedOpsProfitCenter != 'None') 
        {
            //Added one more field in query Profit_Center_Code_Chain__c : 20-September-2017 : Issue-11239 : Start/End  
            String rgn = 'Select id from Profit_Centre__c where Profit_Center_Code_Chain__c like \'%('+selectedOpsProfitCenter+')%\'';
            for(Profit_Centre__c rg: Database.query(rgn))
            {
                childPCs.add(rg.id);
            }
        }
        
    }
    
    //change added by anjali - begin
    public void vpChanged(){
        filterSetter(SalesTeam_DashboardFilterClass.queryPC, querySalesTeamStr,selectedOpsProfitCenter, true);
        populateTeams(); 
        populateAE();
    }
    //change added by anjali - end
    
    //function to initialise the AE if Team is changed
    public void teamChanged()
    {
        populateAE();
    }
    
    //function to check if user is EKAM or GKAM and No Account is selected - make all selected by default
    public void go()
    {
        //Issue-02009
        if(filterOptions.selGraphOptn == null || filterOptions.selGraphOptn == '')
            filterOptions.selGraphOptn = 'Stage';
        //Issue-00362 //Issue-02009 - added if condition
        if(filterOptions.planVsCurrentSelectedOptn == null || filterOptions.planVsCurrentSelectedOptn == ''){            
            //Issue-02017 Remove Radio buttons of Plan and Current Forecast for Japan users
            filterOptions.planVsCurrentSelectedOptn = (this.filterOptions.isJapaneseUser)?this.filterOptions.ADJ_TARGET:'Plan';
        }
        if((this.filterOptions.userDesignation == getGkam() || this.filterOptions.userDesignation == getEkam()) && this.filterOptions.ParentAccount.size() == 0)
        {
            this.filterOptions.ParentAccount.addAll(SuperParentAccSapRef);
        }
        
        //Update by: 23 July, 2012 -- Time Period Multi select check for options selected
        if(filterOptions.Quarter.size() > 0)
        {
            Set<String> tempQuarter = new Set<String>();
            tempQuarter.addAll(filterOptions.Quarter);
            if(tempQuarter.contains(SalesTeam_DashboardFilterClass.YTDString))
            {
                filterOptions.Quarter = new List<String>();
                filterOptions.Quarter.add(SalesTeam_DashboardFilterClass.YTDString);
            }
            else if(tempQuarter.contains(SalesTeam_DashboardFilterClass.FYString))
            {
                filterOptions.Quarter = new List<String>();
                filterOptions.Quarter.add(SalesTeam_DashboardFilterClass.FYString);
            }
            tempQuarter.clear();
        }
        else
        {
            filterOptions.Quarter.add('FY');
        }
        
    }
    
    // if Sales Hierarchy is changed
    public void salesHierarchyChanged()
    {
        newLstTeamCodesGlobal = new List<String>();
        if(this.filterOptions.userDesignation == getOpsUser())
        {
            lstTeamCodes = new List<String>();
            if(querySalesTeamStr != SalesTeam_DashboardFilterClass.PROFITCENTRE)
            {
                if(selectedOpsProfitCenter != 'None')
                { 
                    //changes by anjali - begin
                    String vpQuery = 'Select s.' + SalesTeam_DashboardFilterClass.getMapHierarchyField().get(querySalesTeamStr) + '__r.Sales_Team__r.VP__c ';
                    vpQuery = vpQuery + ' vpid From Sales_Revenue__c s where Profit_Centre__c in ('+ this.filterOptions.CommaSeperatedvalues(childPCs) + ') group by ';
                    
                    vpQuery = vpQuery + 's.' + SalesTeam_DashboardFilterClass.getMapHierarchyField().get(querySalesTeamStr) + '__r.Sales_Team__r.VP__c';
                    for(AggregateResult ar: Database.query(vpQuery))
                    {
                        if(ar.get('vpid') != null)
                            lstVPCodes.add(String.valueOf(ar.get('vpid')));
                    }
                    //changes by anjali - end
                    //Update  by: Sneha Date: 22 June, 2012 -- Made generic based on Hierarchy selected
                    String teamQuery = 'Select s.' + SalesTeam_DashboardFilterClass.getMapHierarchyField().get(querySalesTeamStr) + '__r.Sales_Team__c ';
                    teamQuery = teamQuery + ' tcid From Sales_Revenue__c s where Profit_Centre__c in ('+ this.filterOptions.CommaSeperatedvalues(childPCs) + ') group by ';
                    
                    teamQuery = teamQuery + 's.' + SalesTeam_DashboardFilterClass.getMapHierarchyField().get(querySalesTeamStr) + '__r.Sales_Team__c';
                    for(AggregateResult ar: Database.query(teamQuery))
                    {
                        if(ar.get('tcid') != null)
                            lstTeamCodes.add(String.valueOf(ar.get('tcid')));
                    }   
                }
                //filterSetter(SalesTeam_DashboardFilterClass.queryPC, querySalesTeamStr,selectedOpsProfitCenter, true);
                populateVPs();   
                populateTeams(); 
                populateAE();
            } else { //we have selected Profit Center hierarchy
                this.selectedVP = null;
            }
        }
        else if(this.filterOptions.userDesignation == getVpUser())
        {
            this.filterOptions.selectedVP = null;
            this.filterOptions.SelectedTeamCode = new List<String>();
            lstTeamCodes = new List<String>();
            vpUserFlow();
        }
        else if(this.filterOptions.userDesignation == getSlUser())
        {
            this.filterOptions.selectedVP = null;
            this.filterOptions.SelectedTeamCode = new List<String>();
            lstTeamCodes = new List<String>();
            SalesLeaderUserFlow();
        }
    }
    
    //Update by: Sneha Date: 08 Dec, 2011 -- Populates target Section Data
    public void fillTargetData()
    {
        targetDataExists = false;
        targetData = new List<targetWrapper>();
        if(this.filterOptions.selectedSTHids != null && this.filterOptions.selectedSTHids.size() > 0  && filterOptions.QueryLevel == SalesTeam_DashboardFilterClass.queryAE)
        {
            for(Sales_Team_Hierarchy_AE__c empNum : [Select s.AE_Code__c From Sales_Team_Hierarchy_AE__c s where s.Type__c = :querySalesTeamStr and s.id in :this.filterOptions.selectedSTHids Limit 1])
            {
                if(empNum.AE_Code__c != null)
                {
                    for(User u : [Select u.Q4_Target__c, u.Q3_Target__c, u.Q2_Target__c, u.Q1_Target__c From User u where u.EmployeeNumber = :empNum.AE_Code__c Limit 1])
                    {
                        Sales_Revenue__c targetdt = new Sales_Revenue__c();             
                        targetdt.Gross_Q1_Value__c = ((u.Q1_Target__c == null)? 0.0 : (Double)u.Q1_Target__c).round();
                        targetdt.Gross_Q2_Value__c = ((u.Q2_Target__c == null)? 0.0 : (Double)u.Q2_Target__c).round();
                        targetdt.Gross_Q3_Value__c = ((u.Q3_Target__c == null)? 0.0 : (Double)u.Q3_Target__c).round();
                        targetdt.Gross_Q4_Value__c = ((u.Q4_Target__c == null)? 0.0 : (Double)u.Q4_Target__c).round();
                        
                        if(targetdt.Gross_Q1_Value__c + targetdt.Gross_Q2_Value__c + targetdt.Gross_Q3_Value__c + targetdt.Gross_Q4_Value__c > 0 )
                        {
                            targetDataExists = true;
                            targetData.add(new targetWrapper('Target' , targetdt));
                            
                            String queryInHandAndWnih = 'Select Sum(Gross_Q1_Value__c)sumQ1, Sum(Gross_Q2_Value__c)sumQ2, Sum(Gross_Q3_Value__c)sumQ3, Sum(Gross_Q4_Value__c)sumQ4 ';
                            queryInHandAndWnih = queryInHandAndWnih + 'From Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c in ('+filterOptions.CommaSeperatedvalues(this.filterOptions.selectedSTHids) +' )';
                            queryInHandAndWnih = queryInHandAndWnih + ' and ((s.Scenario__c ='+'\''+SalesTeam_DashboardFilterClass.REVENUE+'\') or (s.Scenario__c ='+'\''+SalesTeam_DashboardFilterClass.PIPELINE+'\'' + ' and s.Opportunity_Stage__c = '+'\''+SalesTeam_DashboardFilterClass.STAGE_6a+'\')) ';
                            Sales_Revenue__c targetInHandAndWnih = addTargetData('Total InHand + WNIH', queryInHandAndWnih);
                            
                            Sales_Revenue__c targetGapVsTarget = new Sales_Revenue__c();
                            targetGapVsTarget.Gross_Q1_Value__c =  targetdt.Gross_Q1_Value__c - targetInHandAndWnih.Gross_Q1_Value__c ;
                            targetGapVsTarget.Gross_Q2_Value__c = targetdt.Gross_Q2_Value__c - targetInHandAndWnih.Gross_Q2_Value__c ; 
                            targetGapVsTarget.Gross_Q3_Value__c = targetdt.Gross_Q3_Value__c - targetInHandAndWnih.Gross_Q3_Value__c ;
                            targetGapVsTarget.Gross_Q4_Value__c = targetdt.Gross_Q4_Value__c - targetInHandAndWnih.Gross_Q4_Value__c ; 
                            targetData.add(new targetWrapper('Gap vs. Target' , targetGapVsTarget));
                            
                            String stagePieline15Query = 'Select Sum(Gross_Q1_Value__c)sumQ1, Sum(Gross_Q2_Value__c)sumQ2, Sum(Gross_Q3_Value__c)sumQ3, Sum(Gross_Q4_Value__c)sumQ4, Sum(Gross_FY_Value__c) sumFY ';
                            stagePieline15Query = stagePieline15Query + 'From Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c in ('+filterOptions.CommaSeperatedvalues(this.filterOptions.selectedSTHids) +' )';
                            stagePieline15Query = stagePieline15Query + ' and s.Scenario__c ='+'\''+SalesTeam_DashboardFilterClass.PIPELINE+'\'' + ' and s.Opportunity_Stage__c != '+'\''+SalesTeam_DashboardFilterClass.STAGE_6a+'\'';
                            Sales_Revenue__c targetPipe15 =  addTargetData('Pipeline 1-5', stagePieline15Query);
                            
                            
                            String stagePieline35Query = 'Select Sum(Gross_Q1_Value__c)sumQ1, Sum(Gross_Q2_Value__c)sumQ2, Sum(Gross_Q3_Value__c)sumQ3, Sum(Gross_Q4_Value__c)sumQ4, Sum(Gross_FY_Value__c) sumFY ';
                            stagePieline35Query = stagePieline35Query + 'From Sales_Revenue__c s where s.Sales_Team_Hierarchy_AE__c in ('+filterOptions.CommaSeperatedvalues(this.filterOptions.selectedSTHids) +' )';
                            stagePieline35Query = stagePieline35Query + ' and s.Scenario__c ='+'\''+SalesTeam_DashboardFilterClass.PIPELINE+'\'' + ' and (s.Opportunity_Stage__c = '+'\''+SalesTeam_DashboardFilterClass.STAGE_3+'\'' + ' or s.Opportunity_Stage__c ='+'\''+SalesTeam_DashboardFilterClass.STAGE_4+'\'' + ' or s.Opportunity_Stage__c ='+'\''+SalesTeam_DashboardFilterClass.STAGE_5+'\'' + ')';
                            Sales_Revenue__c targetPipe35 = addTargetData('Pipeline 3-5', stagePieline35Query);
                        }   
                    }   
                } 
            }   
        }
    }
    
    // helper function to construct Target Data
    public Sales_Revenue__c addTargetData(String colNm, String queryStr )
    {
        AggregateResult[] targetPipeVal = Database.Query(queryStr);
        Sales_Revenue__c targetVal = new Sales_Revenue__c();
        if(targetPipeVal.size() > 0)
        {
            targetVal.Gross_Q1_Value__c =  (( targetPipeVal[0].get('sumQ1') != null)?((Double)  targetPipeVal[0].get('sumQ1')): 0.0).round();
            targetVal.Gross_Q2_Value__c = (( targetPipeVal[0].get('sumQ2') != null)?((Double)  targetPipeVal[0].get('sumQ2')): 0.0).round(); 
            targetVal.Gross_Q3_Value__c = (( targetPipeVal[0].get('sumQ3') != null)?((Double)  targetPipeVal[0].get('sumQ3')): 0.0).round();
            targetVal.Gross_Q4_Value__c = (( targetPipeVal[0].get('sumQ4') != null)?((Double)  targetPipeVal[0].get('sumQ4')): 0.0).round(); 
        }
        else 
        {
            targetVal.Gross_Q1_Value__c = 0.0;
            targetVal.Gross_Q2_Value__c = 0.0;
            targetVal.Gross_Q3_Value__c = 0.0; 
            targetVal.Gross_Q4_Value__c = 0.0;
        }
        targetData.add(new targetWrapper(colNm , targetVal));
        return targetVal;       
    }
    
    
    //Wrapper class to hold target data
    public class targetWrapper
    {
        public string colNm{get; set;}
        public Sales_Revenue__c quarterData{get; set;}
        public Sales_Revenue__c FYData{get; set;}
        
        public targetWrapper(String nm, Sales_Revenue__c sr)
        {
            colNm = nm;
            quarterData = sr;
            FYData = new Sales_Revenue__c();
            FYData.Gross_Q1_Value__c = (quarterData.Gross_Q1_Value__c + quarterData.Gross_Q2_Value__c + quarterData.Gross_Q3_Value__c + quarterData.Gross_Q4_Value__c).round();
        }
    }
}