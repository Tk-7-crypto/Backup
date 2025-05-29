//Helper class for salesteam dashboard to hold filter criteria, construct queries and other few helper functions
//Date: 27 Sept, 2011 -- MultiPicklist Changes
//Date: 18 April, 2012 --- New filters (Service line and Service Line group) and forecast category changes
//Date: 19 June, 2012 -- ER - 00321 : Pipeline stage split option added
//Date: 20 July, 2012 -- New filter global product added
//Date: 20 July, 2012 -- Time Period made multi select 
//Date: 24 Sept, 2012 -- Issue-00362 - Plan Vs Current Forecast added
//Date: 8th May, 2013 - Adjusted Target and VP Selector
/*
    Update by: Sneha Date: 30 Jan, 2013 -- Issue-01470 : Hiding On Track if On Track is zero
*/
public class SalesTeam_DashboardFilterClass {
    
     public List<String> COEName{get; set;} //holds the selected values for COE Name filter multi picklist in filter criteria
     public List<String> ParentAccount{get;set;} //holds the selected values for Super Parent Account filter multi picklist in filter criteria
     public List<String> OfferingType{get; set;} //holds the selected values for Offering type filter multi picklist in filter criteria
     public List<String> OfferingGroup{get; set;} //holds the selected values for Offering Group filter multi picklist in filter criteria
     public List<String> OfferingSegment{get; set;} //holds the selected values for Offering Segment filter multi picklist in filter criteria
     public List<String> ServiceLine{get; set;} //holds the selected values for Service Line filter multi picklist in filter criteria
     public List<String> ServiceLineGroup{get; set;} //holds the selected values for Service Line Group filter multi picklist in filter criteria
     public List<String> GlobalProduct{get; set;} //holds the selected values for Global Product filter multi picklist in filter criteria
     public List<String> Quarter{get; set;}
     public String selectedProfitCenter{get; set;} // holds the profit center selected for Ops user
     public List<String> selectedSTHids{get; set;} //holds the sales team Hierarchy Id for the Account Executive whose dashboard is been viewed
     public List<String> SelectedTeamCode{get; set;}//holds the team code for the Team(s) whose dashboard is been viewed
     public String QueryLevel{get;set;}  //holds the query level - PC/TM/AE 
     public String HierarchyLevel{get;set;}  //holds the current hierarchy
     public String userDesignation{get; set;} //holds the user's designation
     public String selGraphOptn{get; set;} //holds the current selected graph option
     public List<String> childRegionIDs; //holds the child PC ID's of the selected PC
     public String refreshDate{get; set;}
     public String selectedPipeStageOptn{get; set;} //holds the selected pipeline stage - default is all
     public String planVsCurrentSelectedOptn{get; set;} // Issue-00362 
     private List<String> ytdQuarters;
     public String selectedVP {get; set;}
     
     //Added By Ankita Jain : 27 dec 2012 : Adding Flag for Japanese User
     public boolean isJapaneseUser{get ; set;}
     public boolean showQ1{get; private set;}
     public boolean showQ2{get; private set;}
     public boolean showQ3{get; private set;}
     public boolean showQ4{get; private set;}
     public boolean showFY{get; private set;}
     public boolean showYTDCQ{get; private set;}
     
     //Issue-01470
     public boolean showOnTrack{get; set;}

     public void updateColumnVisibility()
     {
        Set<String> quarLst = new Set<String>();
        if(Quarter.size() == 1 && Quarter[0] == YTDString)
        {
            showYTDCQ = true;
            quarLst.addAll(ytdQuarters);
        }
        else
        {
            showYTDCQ = false;
            quarLst.addAll(Quarter);
        }
        showQ1 = quarLst.contains('Q1') || quarLst.contains('FY');
        showQ2 = quarLst.contains('Q2') || quarLst.contains('FY');
        showQ3 = quarLst.contains('Q3') || quarLst.contains('FY');
        showQ4 = quarLst.contains('Q4') || quarLst.contains('FY');
        showFY = quarLst.contains('FY');
        quarLst.clear();
     }
      
     //static strings for stage, error messages and scenario's
     public static final string STAGE_1 = '1';
     public static final string STAGE_2 = '2';
     public static final string STAGE_3 = '3';
     public static final string STAGE_4 = '4'; 
     public static final string STAGE_5 = '5';
     public static final string STAGE_6a = '7';
     public static final string BUDGET = 'Budget';
     public static final string CURRENTFC = 'Current Forecast';
     public static final string PLAN = 'Plan';
     //changes by anjali - Adjusted Target - BEGIN
     public String ADJ_TARGET {get { return 'Adj Target';} set;}
     //changes by anjali - Adjusted Target - END

     public static final string PIPELINE = 'Pipeline';
     public static final string REVENUE = 'Revenue';
     public static final string queryPC = 'PC';
     public static final string queryTM = 'TM';
     public static final string queryAE = 'AE';
     public static final string BESTCASEFC = 'Best Case';
     public static final string ONTRACKFC = 'On Track';
     public static final string COMMITFC = 'Commit';
     public static final string PIPELINEFC = 'PipelineFC';
     public static final string SIMPLELST = 'SimpleLst';
     public static final string SIMPLEEXCELLST = 'SimpleExcelLst';
     public static final string ERROR_NON_SETUP = ' Dashboard has not been setup. Please contact Local Operations or System Admin.';
     public static final string ERROR_NON_SETUP_Ops = ' Dashboard Access has not been setup. Please contact Local Operations or System Admin.';
     public static final string ekamRootPcCode = 'EUROP-R';
     public static final string gkamRootPcCode = 'OPRTN-R';
     public static final string PROFITCENTRE = 'Profit Centre';
     public static final string SALESTEAM = 'Sales Team';
     public static final string SALESSPECIALIST = 'Sales Specialist';
     public static final string IASPECIALIST = 'I&A Specialist';
     public static final string FYString = 'FY';
     public static final string Q1String = 'Q1';
     public static final string Q2String = 'Q2';
     public static final string Q3String = 'Q3';
     public static final string Q4String = 'Q4';
     public static final string YTDString = 'YTD CQ';
     public static final string UnitSring = 'Legacy';
     
     //Update by: Sneha Date: 22 June, 2012 - Map to store name of fields to refer based on Hierarchy selected
     public static Map<String, String> getMapHierarchyField()
     {
        //Update by: Sneha Date: 22 June, 2012 - constructed the map
        Map<String, String> mapHierarchyField = new Map<String, String>();
        mapHierarchyField.put(SALESTEAM,'Sales_Team_Hierarchy_AE');
        mapHierarchyField.put(SALESSPECIALIST,'Sales_Specialist');
        mapHierarchyField.put(IASPECIALIST,'I_A_Specialist');
        return mapHierarchyField; 
     }
     
     //constructor to initialize the filters
     public SalesTeam_DashboardFilterClass()
     {
        refreshAllfilterData();
        userDesignation = ''; 
        //Added By Ankita Jain : 27 dec 2012 : Set default value of isJapaneseUser flag to False    
        isJapaneseUser = false;
        refreshDate = '';     
        ytdQuarters = new List<String>();
        Integer mnth = DateTime.now().month();
        
        if(mnth > 0)
            ytdQuarters.add(Q1String);
        if(mnth > 3)
            ytdQuarters.add(Q2String);
        if(mnth > 6)
            ytdQuarters.add(Q3String);
        if(mnth > 9)
            ytdQuarters.add(Q4String);
     }
     
     //function to refresh data
     public void refreshAllfilterData()
     {
        COEName = new List<String>(); 
        ParentAccount = new List<String>();
        OfferingType = new List<String>();
        OfferingGroup = new List<String>();
        OfferingSegment = new List<String>();
        ServiceLine = new List<String>();
        ServiceLineGroup = new List<String>();
        GlobalProduct = new List<String>();
        //Quarter = 'FY';
        selectedSTHids = new List<String>();
        SelectedTeamCode = new List<String>();
        QueryLevel = '';
        HierarchyLevel = '';
        selectedProfitCenter = '';
        selGraphOptn = 'Stage';
        childRegionIDs = new List<String>();
        selectedPipeStageOptn = 'All';
        Quarter = new List<String>();
        Quarter.add('FY');
        //Issue-02017 Remove Radio buttons of Plan and Current Forecast for Japan users  
        planVsCurrentSelectedOptn = (isJapaneseUser != null && isJapaneseUser ) ? ADJ_TARGET : 'Plan';
        showOnTrack = true;
     }
     
     //function that constructs the queries as per the above criteria's
     public string queryStr(String init, String scenario)
     {
         //init: simple - for fetching fields of Sales Revenue object
         //init: Aggregate - when aggregation needs to be performed - for aggregated data required in graph / excel
         //init: AggregateStage - when aggregation needs to be performed as per stage of Opportunity
         //init: AggregateForecast - when aggregation needs to be performed as per the Forecast category field
         //QueryLevel - PC for Profit center level, TM for Team Level and AE for Account Executive level
         //scenario: Budget - for Budget Scenario Sales Revenue Data
         //scenario: Revenue - for Revenue Scenario Sales Revenue Data
         //scenario: Pipeline15 - for Pipeline(Opportunity Stage 1 to 5) Scenario Sales Revenue Data
         //scenario: Pipeline6a - for Pipeline(Opportunity Stage 6a) Scenario Sales Revenue Data
         //scenario: Pipeline - for Pipeline Scenario(irrespective of Stage) Sales Revenue Data
         //scenario: COMMITFC - for IMS_Forecast_Category__c = 'Commit'
         //scenario: ONTRACKFC - for IMS_Forecast_Category__c = 'On Track'
         //scenario: BESTCASEFC - for IMS_Forecast_Category__c = 'Best Case'
         ////scenario: PIPELINEFC - for IMS_Forecast_Category__c = 'Pipeline'
         //user desgination - holds user's post
         integer cntConditions = 0;
         String salesQuery = 'Select ' + queryfields(init, scenario) + ' From Sales_Revenue__c s';
         
         //add a check for PC if Ops User or PC level data is been viewed
         if(QueryLevel.equals(queryPC) || userDesignation == SalesTeam_DashboardController.getOpsUser())
         { 
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            salesQuery = salesQuery +'Profit_Centre__c in ('+ CommaSeperatedvalues(childRegionIDs)+ ')';
            cntConditions += 1;         
         } 
         
         
         //change added by anajli - begin
         //if VP has been selected from from VP selector
         if(selectedVP != null && selectedVP != '' && selectedVP != 'All' && selectedVP != 'None') 
         {           
           //Update by: Sneha Date: 26 June, 2012 -- Made generic using map
           //SalesTeam_DashboardFilterClass.getMapHierarchyField().get(querySalesTeamStr) + '__r.Sales_Team__r.VP__c
           if(getMapHierarchyField().get(HierarchyLevel) != null && getMapHierarchyField().get(HierarchyLevel) != '') {
               salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
               salesQuery = salesQuery + 's.' + getMapHierarchyField().get(HierarchyLevel) + '__r.Sales_Team__r.VP__c = \'' + selectedVP + '\' ';
               cntConditions += 1;
           }
         }
         //change added by anjali - end
        
         //if team level data is been viewed
         if(QueryLevel.equals(queryTM))
         {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            //Update by: Sneha Date: 26 June, 2012 -- Made generic using map
            salesQuery = salesQuery + 's.' + getMapHierarchyField().get(HierarchyLevel) + '__r.Sales_Team__c';
            salesQuery = salesQuery + ' in ( ' + CommaSeperatedvalues(SelectedTeamCode) + ' ) ';
            cntConditions += 1;
         }
         else if(QueryLevel.equals(queryAE)) // if AE level data is been viewed is been viewed
         {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            salesQuery = salesQuery +'s.' +  getMapHierarchyField().get(HierarchyLevel) + '__c' ; 
            if((userDesignation == SalesTeam_DashboardController.getOpsUser()) && selectedSTHids.size() == 1 && (selectedSTHids[0] == 'No Sales Specialist' || selectedSTHids[0] == 'No Account Executive' || selectedSTHids[0] == 'No I&A Specialist'))
            {
                salesQuery = salesQuery +' = null';
            }
            else
                salesQuery = salesQuery + ' in ( '+CommaSeperatedvalues(selectedSTHids)+' ) ';
            cntConditions += 1; 
         }
    
         //if ops user and ALL is selected in any of the team / Ae list -- check added for null
         if((userDesignation == SalesTeam_DashboardController.getOpsUser()) && HierarchyLevel != PROFITCENTRE &&  ((selectedSTHids.size() > 0 && selectedSTHids[0] == 'All') || (SelectedTeamCode.size() > 0 && SelectedTeamCode[0] == 'All' && selectedSTHids.size() > 0 && selectedSTHids[0]!= 'No Sales Specialist' && selectedSTHids[0] != 'No Account Executive' && selectedSTHids[0] != 'No I&A Specialist')))
         {
            //Update by: Sneha Date: 26 June, 2012 -- Made generic using map
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            salesQuery = salesQuery +'s.' +getMapHierarchyField().get(HierarchyLevel)+ '__c != null';
            cntConditions += 1;   
         }
    
         //adding conditions for scenario filters
         if(scenario.equals('Pipeline15'))
         {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            salesQuery = salesQuery + 's.Scenario__c = \''+PIPELINE+'\'';
            if(selectedPipeStageOptn == 'All')
                salesQuery = salesQuery + ' and (s.Opportunity_Stage__c = \''+STAGE_1+'\'' + ' or s.Opportunity_Stage__c ='+'\''+STAGE_2+'\'' + ' or s.Opportunity_Stage__c ='+'\''+STAGE_3+'\'' + ' or s.Opportunity_Stage__c ='+'\''+STAGE_4+'\'' + ' or s.Opportunity_Stage__c ='+'\''+STAGE_5+'\'' + ')';
            else
                salesQuery = salesQuery + ' and s.Opportunity_Stage__c = \''+selectedPipeStageOptn+'\'';
            cntConditions += 1;
         }
         else if(scenario.equals('Pipeline6a'))
         {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            salesQuery = salesQuery + 's.Scenario__c = \''+PIPELINE+'\'' + ' and s.Opportunity_Stage__c = \''+STAGE_6a+'\'';
            cntConditions += 1;
         }
         else if(scenario.equals(BESTCASEFC) || scenario.equals(ONTRACKFC)  || scenario.equals(COMMITFC) || scenario.equals(PIPELINEFC))
         {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            if(scenario.equals(PIPELINEFC))
                salesQuery = salesQuery + '(s.Scenario__c = \'' + PIPELINE + '\' and s.IMS_Forecast_Category__c = \''+PIPELINE +'\')' ;
            else
                salesQuery = salesQuery + '(s.Scenario__c = \'' + PIPELINE + '\' and s.IMS_Forecast_Category__c = \''+ scenario+'\')' ;
            cntConditions += 1;
         }
         //Sneha - 25 September, 2012 - Plan vs Current Forecast Changes
         else if(scenario.equals(BUDGET) || scenario.equals(PIPELINE) || scenario.equals(REVENUE) || scenario.equals(CURRENTFC))
         {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            salesQuery = salesQuery + 's.Scenario__c = \''+scenario+'\'';
            cntConditions += 1;
         }
        
         //adding conditions for UI filters if any are selected 
         String uiFilters = makeUIfilterConditions(cntConditions);
         if(uiFilters.trim().length() > 0)
         {
            salesQuery = salesQuery + uiFilters;
            cntConditions += 1;
         }
            
         //applying group by for stage and forecast category if required
         //if(scenario.equals(PIPELINE) && init.equals('AggregateStage'))
         if(init.equals('AggregateStage'))
         {
            salesQuery = salesQuery + ' group by s.Opportunity_Stage__c order by s.Opportunity_Stage__c ASC';
         }
         else if(init.equals('AggregateForecast'))
         {
            salesQuery = salesQuery + ' group by s.IMS_Forecast_Category__c ';
         }
           
         //order by clause added
         /*if(init.equals(SIMPLEEXCELLST))
         {
            if(scenario.equals('Pipeline15') || scenario.equals(PIPELINEFC) || scenario.equals(BESTCASEFC) || scenario.equals(ONTRACKFC)  || scenario.equals(COMMITFC))
                salesQuery = salesQuery +   ' order by s.Opportunity_Stage__c desc, s.Gross_FY_Value__c desc ';
            else
                salesQuery = salesQuery +' order by s.Gross_FY_Value__c desc ';
         } 
         else if(init.equals(SIMPLELST))
         {
            salesQuery = salesQuery +' order by s.Gross_FY_Value__c desc limit 100';
         }*/
         
         //Update by : Sneha Date: 1/9/2012 - Order by changed - Issue-00858
         if(init.equals(SIMPLEEXCELLST))
         {
            salesQuery = salesQuery +   ' order by ';
            if(scenario.equals('Pipeline15') || scenario.equals(PIPELINEFC) || scenario.equals(BESTCASEFC) || scenario.equals(ONTRACKFC)  || scenario.equals(COMMITFC))
                salesQuery = salesQuery + 's.Opportunity_Stage__c desc, ';
            if(Quarter.size() == 1)
                salesQuery = salesQuery + quarterfield(Quarter[0]) + ' desc';
            else
                salesQuery = salesQuery + quarterfield(FYString) + ' desc';
            
         } 
         else if(init.equals(SIMPLELST))
         {
            salesQuery = salesQuery +' order by ';
            if(Quarter.size() == 1)
                salesQuery = salesQuery + quarterfield(Quarter[0]);
            else
                salesQuery = salesQuery + quarterfield(FYString);
            salesQuery = salesQuery + ' desc limit 100';
         }
          
         return salesQuery;
    }
    
    public string quarterfield(String quar)
    {
        if(quar == Q1String)
            return ' s.Gross_Q1_Value__c ';
        else if(quar== Q2String) 
            return ' s.Gross_Q2_Value__c ';
        else if(quar== Q3String)
            return ' s.Gross_Q3_Value__c ';
        else if(quar == Q4String)
            return ' s.Gross_Q4_Value__c ';
        else if(quar == FYString)
            return ' s.Gross_FY_Value__c ';
        else if(quar == YTDSTRING)
            return ' s.Gross_YTD_CQ_Value__c ';
        else 
            return '';
    }
    
    
    
    //function gives the query fields as per the list to be generated  
    public string queryfields(string init, String scenario)
    {
        string salesQuery = '';
        If(init.equals(SIMPLELST) || init.equals(SIMPLEEXCELLST))
        {
            salesQuery = 's.id, s.Scenario__c, s.Product_Name__c, s.Account_Name__c, s.Opportunity__c, s.Profit_Centre_Code__c';
            if(Quarter.size() == 1 && Quarter[0] == FYString)
            {
                salesQuery = salesQuery + ', s.Gross_Q4_Value__c, s.Gross_Q3_Value__c, s.Gross_Q2_Value__c, s.Gross_Q1_Value__c, s.Gross_FY_Value__c';
            }
            else if(Quarter.size() == 1 && Quarter[0] == YTDString)
            {
                salesQuery = salesQuery + ', s.Gross_YTD_CQ_Value__c';
                for(integer i = 0; i < ytdQuarters.size(); i++)
                {
                    salesQuery = salesQuery + ',' + quarterfield(ytdQuarters[i]);
                }
            }
            else
            {
                for(integer i = 0; i < Quarter.size(); i++)
                {
                    salesQuery = salesQuery + ',' + quarterfield(Quarter[i]);
                }
            }
                          
            //Update by: Sneha Date: 27 June, 2012 -- Fields queried as per specified Hierarchy 
            if(HierarchyLevel == SALESSPECIALIST)
                 salesQuery = salesQuery + ', s.Sales_Specialist__c, s.Sales_Specialist__r.AE_Name__c';
            else if(HierarchyLevel == SALESTEAM)
                salesQuery = salesQuery + ', s.Sales_Team_Hierarchy_AE__c, s.Sales_Team_Hierarchy_AE__r.AE_Name__c';
            else if(HierarchyLevel == IASPECIALIST)
                salesQuery = salesQuery + ', s.I_A_Specialist__c, s.I_A_Specialist__r.AE_Name__c';
            else if(HierarchyLevel == PROFITCENTRE)
                salesQuery = salesQuery + ', s.Opportunity__r.Owner.Name';
           
           //Sneha - 25 September, 2012 - Plan vs Current Forecast Changes
           if(!scenario.equals(BUDGET) && !scenario.equals(CURRENTFC))
            {
                salesQuery = salesQuery + ',s.Opportunity__r.Opportunity_Number__c,s.Opportunity__r.Id, s.Opportunity__r.Name, s.Opportunity__r.AccountId ';
            }
           
           if(scenario.equals('Pipeline15') || scenario.equals(PIPELINEFC) || scenario.equals(BESTCASEFC) || scenario.equals(ONTRACKFC)  || scenario.equals(COMMITFC))
            {
                salesQuery = salesQuery + ',s.Opportunity_Stage__c, s.IMS_Forecast_Category__c, s.Opportunity__r.Probability , s.Opportunity__r.NextStep, s.Opportunity__r.CloseDate ';
            }
            
            if(scenario.equals('Pipeline6a'))
            {
                salesQuery = salesQuery + ',s.Opportunity__r.Actual_Close_Date__c';
            }
         }
         else if(init.equals('Aggregate'))
         {
            Integer numQuarters = Quarter.size();
            for(integer i = 0; i < numQuarters ; i++)
            {
                salesQuery = salesQuery + 'sum(' + quarterfield(Quarter[i]) + ') sm' + i;
                if(i < numQuarters - 1)
                    salesQuery = salesQuery + ',';              
            }
         }
         else if(init.equals('AggregateStage'))
         {
            salesQuery = ' s.Opportunity_Stage__c stg,' ;
            Integer numQuarters = Quarter.size();
            for(integer i = 0; i < numQuarters ; i++)
            {
                salesQuery = salesQuery + 'sum(' + quarterfield(Quarter[i]) + ') sm' + i;
                if(i < numQuarters - 1)
                    salesQuery = salesQuery + ',';
                        
            }
             
         }
         else if(init.equals('DualCurrency'))
         {
            if(Quarter.size() == 1)
            {
                if(Quarter[0] == FYString)
                    salesQuery = 'convertCurrency(s.Gross_Q4_Value__c), convertCurrency(s.Gross_Q3_Value__c), convertCurrency(s.Gross_Q2_Value__c), convertCurrency(s.Gross_Q1_Value__c), convertCurrency(s.Gross_FY_Value__c)';
                else if(Quarter[0] == YTDString)
                {
                    salesQuery = salesQuery + 'convertCurrency(' + quarterfield(YTDString) + '),';
                    Integer numQuarters = ytdQuarters.size();
                    for(integer i = 0; i < numQuarters ; i++)
                    {
                        salesQuery = salesQuery + 'convertCurrency(' + quarterfield(ytdQuarters[i]) + ')';
                        if(i < numQuarters - 1)
                            salesQuery = salesQuery + ',';
                            
                    }
                }
                else
                    salesQuery = 'convertCurrency(' + quarterfield(Quarter[0]) + ')';
            }
            else
            {
                Integer numQuarters = Quarter.size();
                for(integer i = 0; i < numQuarters ; i++)
                {
                    salesQuery = salesQuery + 'convertCurrency(' + quarterfield(Quarter[i]) + ')';
                    if(i < numQuarters - 1)
                        salesQuery = salesQuery + ',';
                            
                }
            }
         }
         else if(init.equals('AggregateForecast'))
         {
            salesQuery = ' s.IMS_Forecast_Category__c ctgry,' ;
            Integer numQuarters = Quarter.size();
            for(integer i = 0; i < numQuarters ; i++)
            {
                salesQuery = salesQuery + 'sum(' + quarterfield(Quarter[i]) + ') sm'+i;
                if(i < numQuarters - 1)
                    salesQuery = salesQuery + ',';
                        
            } 
         }
         return salesQuery;
    }
        
    //function to construct the list of filters selected by user    
    public string makeUIfilterConditions(integer cnt)
    {
        integer cntConditions = cnt;
        String salesQuery = '';
        
        if(OfferingGroup.size() > 0)
        {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            salesQuery = salesQuery + 's.Offering_Group__c in (' + CommaSeperatedvalues(OfferingGroup) + ' ) ';
            cntConditions += 1;
        }
           
        if(OfferingSegment.size() > 0)
        {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
            salesQuery = salesQuery + 's.Offering_Segment__c in (' + CommaSeperatedvalues(OfferingSegment) + ' ) ';
            cntConditions += 1;
        }
           
        if(OfferingType.size() > 0)
        {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
           salesQuery = salesQuery + 's.Offering_Type__c in ('+ CommaSeperatedvalues(OfferingType) + ' ) ';
           cntConditions += 1;
        }
           
        if(COEName.size() > 0)
        {
            salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
           salesQuery = salesQuery + 's.COE_Name__c in ('+ CommaSeperatedvalues(COEName) + ' ) ';
           cntConditions += 1;
        }
           
        if(ParentAccount.size() > 0)
        {
           salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
           salesQuery = salesQuery + 's.Account_Parent_ID__c in (' + CommaSeperatedvalues(ParentAccount) + ')'; //+ ParentAccount;
           cntConditions += 1;
        }
        
        if(ServiceLine.size() > 0)
        {
           salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
           salesQuery = salesQuery + 's.Service_Line__c in ('+ CommaSeperatedvalues(ServiceLine) + ' ) ';
           cntConditions += 1;
        }
        
        if(ServiceLineGroup.size() > 0)
        {
           salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
           salesQuery = salesQuery + 's.Service_Line_Group__c in ('+ CommaSeperatedvalues(ServiceLineGroup) + ' ) ';
           cntConditions += 1;
        }
        
        if(GlobalProduct.size() > 0)
        {
           salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
           salesQuery = salesQuery + 's.Global_Product__c in ('+ CommaSeperatedvalues(GlobalProduct) + ' ) ';
           cntConditions += 1;
        }
           
        
        Integer numQuarters = Quarter.size();
        salesQuery = salesQuery + (cntConditions > 0 ? ' and ': ' where ');
        salesQuery = salesQuery + '(';
        for(integer i = 0; i < numQuarters ; i++)
        {
            salesQuery = salesQuery + '(' + quarterfield(Quarter[i]) + ' != 0 and ' + quarterfield(Quarter[i]) + ' != null )';
            if(i < numQuarters - 1)
                salesQuery = salesQuery + ' or ';           
        }
        salesQuery = salesQuery + ')';
        cntConditions += 1;
        
        
        return salesQuery;
    }
        
        
    //function to construct comma seperated strings for the list of options
    public String CommaSeperatedvalues(List<String> lstStr)
    {
        String commaSeperatedStr = '';
        for(integer i = 0; i < lstStr.size(); i++)
        {
         commaSeperatedStr = commaSeperatedStr + '\'' + lstStr[i] + '\'';
         if(i < lstStr.size() - 1)
         {
            commaSeperatedStr = commaSeperatedStr + ',';
         }
       }
       if(commaSeperatedStr == '')
       {
            commaSeperatedStr = commaSeperatedStr + '\'' + + '\'';
       }
       return commaSeperatedStr;
    }
    
    //function to decribe the picklist field options   
    public static List<SelectOption> populateOptions(Schema.DescribeFieldResult fieldResult)
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();   
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        } 
        return options; 
    }

    //helper function to create list of filters selected
    public List<string> makeFilterCriteriaString(List<String> parentAccountName) 
    {
         List<String> FilterStr = new List<String>();
         
            String tempFilter = '';
            
            //Sne Update
            if(Quarter.size() > 0) 
            {
                tempFilter = 'Time Period = ' +  makeOrString(Quarter) +  ' AND ';
                FilterStr.add(tempFilter);
            }
            
            if(OfferingGroup.size() > 0)
            {
                tempFilter = 'Offering Group = ' + makeOrString(OfferingGroup) + ' AND ';
                FilterStr.add(tempFilter);
            }
            
            if(OfferingSegment.size() > 0)
            {
                tempFilter = 'Offering Segment = ' + makeOrString(OfferingSegment) + ' AND ';
                FilterStr.add(tempFilter);
            }
            
            if(OfferingType.size() > 0)
            {
                tempFilter = 'Offering Type = ' + makeOrString(OfferingType) + ' AND ';
                FilterStr.add(tempFilter);
            }
             
            if(COEName.size() > 0)
            {
                tempFilter = 'COE Name = ' + makeOrString(COEName) + ' AND ';
                FilterStr.add(tempFilter);
            }
            
            if(ParentAccount.size() > 0)
            {                     
                tempFilter = 'Account = ' + makeOrString(parentAccountName) + ' AND ';
                FilterStr.add(tempFilter);
            }
            
            if(ServiceLine.size() > 0)
            {
                //tempFilter = 'Unit = ' + makeOrString(ServiceLine) + ' AND ';
                tempFilter = 'Product Group = ' + makeOrString(ServiceLine) + ' AND ';
                FilterStr.add(tempFilter);
            }
            
            if(ServiceLineGroup.size() > 0)
            {
                //tempFilter = 'Service Line Group = ' + makeOrString(ServiceLineGroup) + ' AND ';
                tempFilter = 'Unit = ' + makeOrString(ServiceLineGroup) + ' AND ';
                FilterStr.add(tempFilter);
            }
            
            if(GlobalProduct.size() > 0)
            {
                tempFilter = 'Global Product = ' + makeOrString(GlobalProduct) + ' AND ';
                FilterStr.add(tempFilter);
            }

            if(FilterStr.size() > 0)
            {
               String lastFilter = FilterStr.remove(FilterStr.size() - 1);
               lastFilter = lastFilter.subString(0, lastFilter.length() - 4);
               FilterStr.add(lastFilter);
            }
         return FilterStr;
     }
     
    //helper function to construct the Or string for the various options selected for an option
    public String makeOrString(List<String> listCriteriaStr)
    {
        String tempFilter = '';
        if(listCriteriaStr != null && listCriteriaStr.size() > 0)
        {
            for(String str: listCriteriaStr)
            {
                        tempFilter = tempFilter + '\'' + str + '\'' + ' Or ';
                        
            }
            tempFilter = tempFilter.subString(0, tempFilter.length() - 3);
        }
        return tempFilter;
    }
    
        //Adjusted Target Change - Begin
    public Double calcAdjTarget() {
        Double adjTarget = 0.0;        
        try {
           if(selectedSTHids.size() == 1 ){ // if AE level data is been viewed is been viewed
               system.debug('selectedSTHids = ' + selectedSTHids[0]);
               if(selectedSTHids[0] == null || selectedSTHids[0] == '') throw new IDException();
               ID selectedAEId = selectedSTHids[0];
               system.debug('found AE');
               //return the adjusted target for this AE
               return queryAdjTarget('Sales_Team_Hierarchy_AE__c', selectedAEId , false);
          } else throw new IDException();  
        } catch(Exception ex) {
            //if team level data is being viewed
            try {
               if(selectedTeamCode.size() == 1 ) { 
                   if(SelectedTeamCode[0] == null || SelectedTeamCode[0] == '') throw new IDException();
                   //if VP himself is viewing the dasboard then query his adjusted target
                   if(userDesignation == SalesTeam_DashboardController.getVpUser()) throw new IDException();
                   ID selectedTeamId = SelectedTeamCode[0];
                   system.debug('found Team = ' + selectedTeamId + ' *selectedVP = ' + selectedVP);
                   return queryAdjTarget('Sales_Team_Hierarchy_ST__c', selectedTeamId , true);
               } 
               throw new IDException();    
            } catch(Exception ex1) {
               //if VP level Data is being viewed
               try{
                  if(selectedVP == null || selectedVP == '') throw new IDException();
                  ID selectedVPId = selectedVP;                  
                  system.debug('found VP = ' + selectedVPId );
                  return queryAdjTarget('Sales_Team_Hierarchy_VP__c', selectedVPId  , true);
               } catch (Exception ex2) {
                  //if selectedVP == 'All' we need to perform aggregate of target
                  system.debug('in the last exception block , selectedVP  = ' + selectedVP );
                  //if(selectedVP == 'All') {
                      system.debug('inside all block');
                      List<String> queryFields = QFieldList(true);
                      String qryStr = 'select ' ;
                      
                      Boolean commaAdded = false;
                      for(String fld : queryFields) {
                          if(!commaAdded){
                              qryStr += ' SUM(' + fld +') ' ;
                              commaAdded = true;
                          } else {
                              qryStr += ', SUM(' + fld +') ' ;
                          }
                      }
                      
                      qryStr += ' from Sales_Team_Hierarchy_VP__c';
                      system.debug('qryStr = ' + qryStr);
                      /*--- Issue-02139 fix----*/
                      if(HierarchyLevel != null && HierarchyLevel != '' && HierarchyLevel != PROFITCENTRE) {
                      //if(HierarchyLevel != null && HierarchyLevel != '' ) {
                          qryStr += ' where Type__c = \'' + HierarchyLevel + '\'';
                      }
                      
                      Integer i = 0;
                      AggregateResult[] ag = Database.query(qryStr);
                      for(AggregateResult ar : ag){
                          adjTarget += (Double)ar.get('expr' + i++);
                      }
                  //}
                  return adjTarget;
               }
            }
        }
        
        //return adjTarget;
    } 
    
    
    
    private List<String> QFieldList(Boolean needsOffset){
        //////////        
        Set<String> qtrlist = new Set<String>(); //list of selected quarters
        if(Quarter.size() == 1 && Quarter[0] == YTDString) 
           qtrlist.addAll(ytdQuarters);
        else 
            qtrlist.addAll(Quarter);
        
        List<String> queryFields = new List<String>(); //fields to be queried
        if(qtrlist.contains('FY')) {
           queryFields.add('FY_Adjusted_Target__c');
           if(needsOffset) queryFields.add('FY_Offset__c');
        } else { 
            if (qtrlist.contains('Q1')) {
                queryFields.add('Q1_Adjusted_Target__c');
                if(needsOffset) queryFields.add('Q1_Offset__c');
            } 
            if (qtrlist.contains('Q2')) {
                queryFields.add('Q2_Adjusted_Target__c');
                if(needsOffset) queryFields.add('Q2_Offset__c');
            } 
            if (qtrlist.contains('Q3')) {
                queryFields.add('Q3_Adjusted_Target__c');
                if(needsOffset) queryFields.add('Q3_Offset__c');
            } 
            if (qtrlist.contains('Q4')) {
                queryFields.add('Q4_Adjusted_Target__c');
                if(needsOffset) queryFields.add('Q4_Offset__c');
            }
        }
        return queryFields ;
        /////////
    }
    
    private Double queryAdjTarget(String queryObj, String queryId, Boolean needsOffset) {
        Double adjTarget = 0.0;
        List<String> queryFields = QFieldList(needsOffset);
        
        /////////
        String adjQueryStr = 'SELECT ID ';
        for(String fld : queryFields) {
            adjQueryStr +=  ', ' + fld ;
        }
        adjQueryStr += ' FROM ' + queryObj + ' WHERE ID = \'' + queryId + '\' LIMIT 1';
        system.debug(' adjQueryStr = ' + adjQueryStr);
        sObject s = Database.query(adjQueryStr);
        if(s != null)
            for(String fld : queryFields) {
                  if(s.get(fld) != null) adjTarget += (Double)s.get(fld);
            }       
        return adjTarget;
    }
    //Adjusted Target Changes - end
    
    
    class IDException extends Exception {}
        
}