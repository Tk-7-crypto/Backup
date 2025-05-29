///********      
//  Created by Sneha Rathi on 28 March, 2011 
//  Controller class for DashboardDisplay.Component
//  Contains methods for querying, displaying & exporting Sales Revenue Data for a Account Executive / Team based on filter criteria's choosen on page
//  Major Refactoring: 27 Sept 2011 -- Multi Picklist Option changes
//  Major Refactoring: 16 Dec 2011 onwards-- Major Enhancements Changes
//  Major Refactoring - 16 April, 2012 --- For solving heap size issue
//  Date: 18 April, 2012 --- New filters (Service line and Service Line group) and forecast category changes
//  Update by: Sneha Date: 07 June, 2012 -- Stage 1 & 2 split in graph - Issue - 00321
//  Update by: Sneha Date: 19 June 2012 -- Stage option added to Pipeline list for selection of stage between 1 to 5 
//  Update by: Sneha Date: 06 july, 2012 -- Converting flex chart to jqplot --- ER - 0022
//  Date: 24 Sept, 2012 -- Issue-00362 - Plan Vs Current Forecast added
//  Date: 8th Oct, 2012 - Issue-01070 - Removal of Decimal from Graph & KPI's
// ******* 

public virtual class DashboardDisplayController {

    //Instance of the helper filter class to hold the filters etc. Used as an attribute for the component
    public SalesTeam_DashboardFilterClass filterCriteria;
    public void setFilterCriteria(SalesTeam_DashboardFilterClass tmp) //Attribute Setter
    {
        filterCriteria = tmp;
        tmp = null; // to free the heap space 
        nullAllExcelList(); // to free the heap space
        if(filterCriteria != null) 
        {
            if(Apexpages.currentPage().getParameters().get('calledFromExcel') != null && Apexpages.currentPage().getParameters().get('calledFromExcel') == 'true') //If excel export
            { 
                isExcelExport = true; 
                parentAccountName = new list<String>();  //Name of all the Super parent Account selected in Filters
                If(filterCriteria.ParentAccount.size() > 0)
                {
                    String accQuery = 'Select Name from Account where MDMID__c in (' + filterCriteria.CommaSeperatedvalues(filterCriteria.ParentAccount)+ ')';
                    for(Account tempAccount : Database.Query(accQuery))
                    {
                        parentAccountName.add(tempAccount.Name);
                    }
                } 
                calledForExcel(); //function to prepare excel list
            }
            else //if not excel export
            {
                isExcelExport = false;
                calledFrom = Apexpages.currentPage().getParameters().get('context');
                //the dashboard data should be refreshed only if filters are changed and paginators naviagtion is not done.
                if(calledFrom != 'Bud' && calledFrom != 'Rev' && calledFrom != 'Pipe' && calledFrom != 'WNIH' && calledFrom != 'Commit' && calledFrom != 'OnTrack' && calledFrom != 'BestCase')
                {
                    parentAccountName = new list<String>(); //Name of all the Super parent Account selected in Filters
                    If(filterCriteria.ParentAccount.size() > 0)
                    {
                        String accQuery = 'Select Name from Account where MDMID__c in (' + filterCriteria.CommaSeperatedvalues(filterCriteria.ParentAccount)+ ')';
                        for(Account tempAccount : Database.Query(accQuery))
                        {
                            parentAccountName.add(tempAccount.Name);
                        }
                    }
                    RefreshDashboard(); //function to reload the component's data
                }
                else
                {
                    calledFrom = '';//if ajax request comes from Component itself then the context should be initiated
                }
            }   
        }   
    }
    public SalesTeam_DashboardFilterClass getFilterCriteria()
    { 
        return filterCriteria;  
    } 
    
    //List to allow toggle for Stage & Forecast Category split
    public static List<SelectOption> GraphOptions{
    get{
        List<SelectOption> lst = new List<SelectOption>();
        lst.add(new SelectOption('Stage', 'Stage'));
        lst.add(new SelectOption('Forecast Category', 'Forecast Category'));
        return lst;
    }
    private set;
    } 
    
    //List to allow toggle for Plan & Current Forecast - Issue-00362
    public List<SelectOption> PlanVsCurrentOption{
    get{
        List<SelectOption> lst = new List<SelectOption>();
        //Issue-02017 Remove Radio buttons of Plan and Current Forecast for Japan users
        if(!filtercriteria.isJapaneseUser) {
            lst.add(new SelectOption(SalesTeam_DashboardFilterClass.PLAN, SalesTeam_DashboardFilterClass.PLAN));
            lst.add(new SelectOption(SalesTeam_DashboardFilterClass.CURRENTFC, SalesTeam_DashboardFilterClass.CURRENTFC));
        }
        //HierarchyLevel   = SalesTeam_DashboardFilterClass.PROFITCENTRE
        if(filterCriteria.hierarchyLevel != SalesTeam_DashboardFilterClass.PROFITCENTRE )
           lst.add(new SelectOption(filterCriteria.ADJ_TARGET, 'Adjusted Target'));//filterCriteria.ADJ_TARGET));
        //ADJ_TARGET
        return lst;
    }
    private set;
    } 
   
    private String calledFrom; // boolean to check whether pagination is been called from the Detail section navigation
    private static final Integer MAX_REC_PER_PAGE = 10; // stores the number of records to be shown for pagination
    public List<String> parentAccountName{get; private set;}//holds the selected Super Parent Account name
    public List<String> lstFilterCriteria{get; private set;} //Contructs the list of filter criteria that is been currently selected by user to filter dashboard's data
    public Boolean isExcelExport{get; private set;}//boolean to decide if Excel export or not
    TRANSIENT public Double GapvsBudget{get;private set;}//stores the KPI for Stage graph   
    TRANSIENT public Double WonofBudget{get;private set;}//stores the KPI for Stage graph         
    TRANSIENT public Double PipelineCoverageAll{get;private set;}//stores the KPI for Stage graph    
    TRANSIENT public Double PipelineCoverage3to5{get;private set;}//stores the KPI for Stage graph
    //Issue-01470 - new KPI's for Japanese Users
    TRANSIENT public Double RIHvsPlan{get; private set;}
    TRANSIENT public Double SecuredvsPlan{get; private set;}
    public String passValueStage{get;private set;}//string to be passed to the flex chart, includes CSV of all the required values for Stage Graph
    TRANSIENT public Double CommitForecast{get; private set;}//stores the KPI for FC graph
    TRANSIENT public Double OnTrackForecast{get; private set;}//stores the KPI for FC graph
    TRANSIENT public Double BestCaseForecast{get; private set;}//stores the KPI for FC graph
    TRANSIENT public Double commitGapVsPlan{get; private set;}//stores the KPI for FC graph
    TRANSIENT public Double commitPlanPCT{get; private set;}//stores the KPI for FC graph
    TRANSIENT public Double onTrackGapVsPlan{get; private set;}//stores the KPI for FC graph
    TRANSIENT public Double onTrackPlanPCT{get; private set;}//stores the KPI for FC graph
    TRANSIENT public Double bestCaseGapVsPlan{get; private set;}//stores the KPI for FC graph
    TRANSIENT public Double bestCasePlanPCT{get; private set;}//stores the KPI for FC graph
    public String passValueFC{get;private set;}//string to be passed to the flex chart, includes CSV of all the required values for Forecast Category Graph
    
    //Changes by Anjali - Sec Rev KPIs for Excel Export, when Stage is selected - Begin
    TRANSIENT public Double secRev {get;private set;} //Secured Revenue :
    TRANSIENT public Double adjMinusSecRev {get;private set;} //Adj Target - Sec Rev
    TRANSIENT public Double wonOfSecRev {get;private set;} //Won of Secured Revenue
    TRANSIENT public Double pipeLineCoverage {get;private set;} //Pipeline Coverage (1 to 4) vs Secured Revenue
    //Issue-02020 remove KPI
    //TRANSIENT public Double pipeLineCoverage1_4 {get;private set;} //Pipeline Coverage (1 to 4)
    //Changes by Anjali - Sec Rev KPIs for Excel Export, when Stage is selected - End
    
    //Changes by Anjali - Sec Rev KPIs for Excel Export, when Forecast Category is selected - Begin
    TRANSIENT public Double commitFC1_4 {get;private set;} //Commit Stage(1 to 4) 
    //Issue-02088 Remove commit STage 5 KPI 
    //TRANSIENT public Double commitFc5_6_WNIH {get;private set;} //Commit Stage (Stage5/WnIH/InHand) : 
    //Changes by Anjali - Sec Rev KPIs for Excel Export, when Forecast Category is selected - End
    
    //Update by: Sneha Date: 06 July, 2012 -- ER-0022
    public List<String> graphLegendLabels{get; private set;}
    public List<Double> graphValues{get; private set;}
    public String StagePlanKPI{get; private set;}
    public String FcForecastKPI{get; private set;}
    public String FcPlanKPI{get; private set;}
    //added by anjali - Adjusted Target Chagne
    public String secRevKPI {get; private set;}
    
    TRANSIENT public Map<ID, Sales_Revenue__c> convertedDualCurrencyMap{get; private set;}// Map to store the Impact values in users currency, if other than USD
    TRANSIENT public Boolean haveDualCurrency{get; private set;}//boolean to check id current logged in user have dual currency
    TRANSIENT public String dualCurrency{get; private set;}// stores the dual currency, if other than USD
    
    //Plan Data - filter: Scenario = 'Budget' + all other filters on page
    TRANSIENT List<Sales_Revenue__c> budgetData; // list to be displayed for current page
    public Sales_Revenue__c Budget_Total{get;private set;}//total value
    TRANSIENT public List<List<Sales_Revenue__c>> budgetDataExcel{get; private set;}//stores complete data for excel export
    public paginationClass planPaginator{get; private set;}//holds the pagination data
    public List<Sales_Revenue__c> getBudgetData() //getter for Budget data list
    {
        budgetData = new List<Sales_Revenue__c>();
        if(filterCriteria != null)
        {
            //Sneha - 25 September, 2012 - Issue-00362 : Plan vs Current Forecast Changes
            String budgetQuery = '';
            if(filterCriteria.planVsCurrentSelectedOptn == SalesTeam_DashboardFilterClass.PLAN)
                budgetQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, SalesTeam_DashboardFilterClass.BUDGET); //construct queries as required
            else
                budgetQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, SalesTeam_DashboardFilterClass.CURRENTFC); //construct queries as required  
            budgetData = planPaginator.fillData(budgetQuery);
        }
        return budgetData;
    }
    
    //Revenue Data - filter: Scenario = 'Revenue' + all other filters on page
    TRANSIENT List<Sales_Revenue__c> revenueData; // list to be displayed for current page
    public Sales_Revenue__c Rih_Total {get;private set;}//total value
    TRANSIENT public List<List<Sales_Revenue__c>> revenueDataExcel{get; private set;}//stores complete data for excel export
    public paginationClass revenuePaginator{get; private set;}//holds the pagination data
    public List<Sales_Revenue__c> getRevenueData()//getter for Revenue Data list
    { 
        revenueData = new List<Sales_Revenue__c>();
        if(filterCriteria != null)
        {
            String revenueQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, SalesTeam_DashboardFilterClass.REVENUE); //construct queries as required
            revenueData = revenuePaginator.fillData(revenueQuery);
        }      
        return revenueData; 
    }
    
    public static List<SelectOption> getLstStage()
    {
        List<SelectOption> options = new List<SelectOption>();    
        options.add(new SelectOption('All','Stage 1-5'));                            
        options.add(new SelectOption('1','Stage 1'));
        options.add(new SelectOption('2','Stage 2'));
        options.add(new SelectOption('3','Stage 3'));
        options.add(new SelectOption('4','Stage 4')); 
        options.add(new SelectOption('5','Stage 5')); 
        return options;
    }
    
    //Pipeline Data - filter: Scenario = 'Pipeline' and Oppty Stage = 1 to 5 + all other filters on page
    TRANSIENT List<Sales_Revenue__c> pipelineData;// list to be displayed for current page
    public Sales_Revenue__c Pipeline_Total{get;private set;}//total value
    TRANSIENT public List<List<Sales_Revenue__c>>pipelineDataExcel{get; private set;}// stores the Pipeline(opportunity Stage 1 to 5) Scenario Sales Revenue complete Data for executive/team(s), for excel export
    public paginationClass pipelinePaginator{get; private set;}//holds the pagination data
    public List<Sales_Revenue__c> getPipelineData()//getter for pipeline data
    {
        pipelineData = new List<Sales_Revenue__c>();
        if(filterCriteria != null)
        {
            String pipeline15Query = '';
            if(filterCriteria.selGraphOptn == 'Stage')
                 pipeline15Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, 'Pipeline15'); //construct queries as required
            else 
                 pipeline15Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, SalesTeam_DashboardFilterClass.PIPELINEFC);
            pipelineData = pipelinePaginator.fillData(pipeline15Query);
            
            //ER - 00321 changes for selecting total
            if(filterCriteria.selGraphOptn == 'Stage')
            {
                if(filterCriteria.selectedPipeStageOptn == 'All')
                    this.Pipeline_Total.Gross_Q1_Value__c = pipeline_1_5.round();
               else if(filterCriteria.selectedPipeStageOptn == '1')
                    this.Pipeline_Total.Gross_Q1_Value__c = pipeline_1.round();
               else if(filterCriteria.selectedPipeStageOptn == '2')
                    this.Pipeline_Total.Gross_Q1_Value__c = pipeline_2.round();
               else if(filterCriteria.selectedPipeStageOptn == '3')
                    this.Pipeline_Total.Gross_Q1_Value__c = pipeline_3.round();
               else if(filterCriteria.selectedPipeStageOptn == '4')
                    this.Pipeline_Total.Gross_Q1_Value__c = pipeline_4.round();
               else if(filterCriteria.selectedPipeStageOptn == '5')
                    this.Pipeline_Total.Gross_Q1_Value__c = pipeline_5.round();
            }
        }
        return  pipelineData;
    }
    
    public void pipelinePageInitialise()
    {
        pipelinePaginator.currentPage = 1;
    }
    
    //Won not in Hand Data - filter: Scenario = 'Pipeline' and Oppty Stage = '6a' + all other filters on page
    TRANSIENT List<Sales_Revenue__c> wnihData;// list to be displayed for current page
    public Sales_Revenue__c Wnih_Total{get;private set;}//total value
    TRANSIENT public List<List<Sales_Revenue__c>> wnihDataExcel {get; private set;}//stores complete data for excel export
    public paginationClass wnihPaginator{get; private set;}//holds the pagination data
    public List<Sales_Revenue__c> getWnihData()//getter for wnih data
    {
        wnihData = new List<Sales_Revenue__c>();
        if(filterCriteria != null)
        {
            String pipeline6Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, 'Pipeline6a');//construct queries as required
            wnihData = wnihPaginator.fillData(pipeline6Query);
        }
        return wnihData;
    }
    
    // Best Case FC Data - filter: Scenario = 'Pipeline' and IMS_Forecast_Category__c = 'Best Case' + all other filters
    TRANSIENT List<Sales_Revenue__c> BestCaseFCData;// list to be displayed for current page
    public Sales_Revenue__c BestCase_Total{get; private set;}//total value
    TRANSIENT public List<List<Sales_Revenue__c>> BestCaseFCDataExcel {get; private set;}//stores complete data for excel export
    public paginationClass bestCaseFCPaginator{get; private set;}//holds the pagination data
    public List<Sales_Revenue__c> getBestCaseFCData()//getter for Best Case FC Data
    {
        BestCaseFCData = new List<Sales_Revenue__c>();
        if(filterCriteria != null)
        {
            String Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, SalesTeam_DashboardFilterClass.BESTCASEFC); //build the query as required 
            BestCaseFCData = bestCaseFCPaginator.fillData(Query);
        }
        return BestCaseFCData;
    }
    
    // On Track FC Data - filter: Scenario = 'Pipeline' and IMS_Forecast_Category__c = 'On Track' + all other filters
    TRANSIENT List<Sales_Revenue__c> OnTrackFCData;// list to be displayed for current page
    public Sales_Revenue__c OnTrack_Total{get; private set;}//total value
    TRANSIENT public List<List<Sales_Revenue__c>> OnTrackFCDataExcel {get; private set;}//stores complete data for excel export
    public paginationClass onTrackFCPaginator{get; private set;}//holds the pagination data
    public List<Sales_Revenue__c> getOnTrackFCData()//getter for On Track FC Data 
    {
        OnTrackFCData = new List<Sales_Revenue__c>();
        if(filterCriteria != null)
        {
            String Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, SalesTeam_DashboardFilterClass.ONTRACKFC);  //build the query as required
            OnTrackFCData = onTrackFCPaginator.fillData(Query);
        }
        return OnTrackFCData;
    }
    
    // Commit FC Data - filter: Scenario = 'Pipeline' and IMS_Forecast_Category__c = 'Commit' + all other filters
    TRANSIENT List<Sales_Revenue__c> CommitFCData;// list to be displayed for current page
    public Sales_Revenue__c Commit_Total{get; private set;}//total value
    TRANSIENT public List<List<Sales_Revenue__c>> CommitFCDataExcel {get; private set;}//stores complete data for excel export
    public paginationClass commitFCPaginator{get; private set;}//holds the pagination data
    public List<Sales_Revenue__c> getCommitFCData()
    {
        commitFCData = new List<Sales_Revenue__c>();
        if(filterCriteria != null)
        {
            String Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLELST, SalesTeam_DashboardFilterClass.COMMITFC);  //build the query as required
            commitFCData = commitFCPaginator.fillData(Query);
        }
        return commitFCData;
    }
    
    //Function to refresh dashboard data as per the filter criteria's
    public void RefreshDashboard()
    { 
       //initialise the pagination info
       pipelinePaginator = new paginationClass();
       wnihPaginator = new paginationClass();
       revenuePaginator = new paginationClass();
       planPaginator = new paginationClass();
       bestCaseFCPaginator = new paginationClass();
       onTrackFCPaginator = new paginationClass();
       commitFCPaginator = new paginationClass();
       filterCriteria.selectedPipeStageOptn = 'All';
       lstFilterCriteria = filterCriteria.makeFilterCriteriaString(parentAccountName); // makes a array of selected filters
       CommonCalculation(); //Call to function for calculating the Aggreagates & Totals for different scenario's/graph as per the filter criteria     
       filterCriteria.updateColumnVisibility();
    }
    
    private Double pipeline_1_5;
    private Double pipeline_1;
    private Double pipeline_2;
    private Double pipeline_3;
    private Double pipeline_4;
    private Double pipeline_5;
    
    //Issue - 00362
    public void toggleStageFC()
    {
        //Issue-02009 - added if condition
        if(filterCriteria.planVsCurrentSelectedOptn == null || filterCriteria.planVsCurrentSelectedOptn == ''){
            filterCriteria.planVsCurrentSelectedOptn = (filterCriteria.isJapaneseUser)? filterCriteria.ADJ_TARGET:'Plan';
        }
    }
    
    //performs all the calculation for aggregation on data used in Dashboard/Excel Export/Graph
    public void CommonCalculation()
    {
        //Issue-01070 - removed decimal places for legend & KPI's
       //Initialise all variables
       graphLegendLabels = new List<String>();
       graphValues = new List<Double>();
       
       //this.passValueStage = ''; 
       //this.passValueFC = '';
       pipeline_1_5 = 0;
       Double pipeline_3_5 = 0;
       pipeline_1 = 0;
       pipeline_2 = 0;
       pipeline_3 = 0 ;
       pipeline_4 = 0;
       pipeline_5  = 0;
       Double pipeline_6a = 0;
       Double BudValue = 0;
       Double RIHVal_num = 0;
       this.Pipeline_Total = new Sales_Revenue__c(CurrencyIsoCode = 'USD');             
       this.Budget_Total = new Sales_Revenue__c(CurrencyIsoCode = 'USD');
       this.Rih_Total = new Sales_Revenue__c(CurrencyIsoCode = 'USD');
       this.Wnih_Total = new Sales_Revenue__c(CurrencyIsoCode = 'USD');
       
       filterCriteria.showOnTrack = true;
       
       Integer numQuarters = filterCriteria.Quarter.size(); 
      
      //calculations for total pipeline (as per the selected Quarter & other filter)
       String stageDataQuery = filterCriteria.queryStr('AggregateStage', SalesTeam_DashboardFilterClass.PIPELINE);
       AggregateResult[] stageResult = Database.Query(stageDataQuery);
       Map<String, Double> StageValueMap = new Map<String, Double>();
       for(AggregateResult ar: stageResult)
       {
         String nm = String.valueOf(ar.get('stg'));
         Double val = 0;
         for(integer i = 0; i < numQuarters ; i++)
         {
                String sm = 'sm' + i; 
                val = val + ((ar.get(sm)!= null) ? (Double)ar.get(sm) : 0.0);
         }  
         
         StageValueMap.put(nm, val);
       }
       
       //Pipeline Values
       If(StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_1) != null)
                pipeline_1 = (StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_1));
       If(StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_2) != null)
                 pipeline_2 = (StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_2));
       If(StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_3) != null)
                pipeline_3 = (StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_3));
       If(StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_4) != null)
                pipeline_4 = (StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_4));
       If(StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_5) != null)
                 pipeline_5 = (StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_5));
       If(StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_6a) != null)
                 pipeline_6a = (StageValueMap.get(SalesTeam_DashboardFilterClass.STAGE_6a)); 
                 
       pipeline_3_5 = pipeline_3 + pipeline_4 + pipeline_5;
       pipeline_1_5 = pipeline_1 + pipeline_2 + pipeline_3_5;
       this.Wnih_Total.Gross_Q1_Value__c = pipeline_6a.round();
       this.Pipeline_Total.Gross_Q1_Value__c = pipeline_1_5.round();
       
       String Rev_Query = filterCriteria.queryStr('Aggregate', SalesTeam_DashboardFilterClass.REVENUE);
       AggregateResult[] RevAggregation = Database.Query(Rev_Query);
       for(integer i = 0; i < numQuarters ; i++)
       {
            String sm = 'sm' + i;
            RIHVal_num = RIHVal_num + ((RevAggregation[0].get(sm) != null)?((Double)RevAggregation[0].get(sm)): 0.0);
       }
       
       //Issue-00362 - Plan Vs Current Forecast
       String Bud_Query = '';
       if(filterCriteria.planVsCurrentSelectedOptn == SalesTeam_DashboardFilterClass.PLAN)
            Bud_Query = filterCriteria.queryStr('Aggregate', SalesTeam_DashboardFilterClass.BUDGET);
       else if(filterCriteria.planVsCurrentSelectedOptn == SalesTeam_DashboardFilterClass.CURRENTFC)
            Bud_Query = filterCriteria.queryStr('Aggregate', SalesTeam_DashboardFilterClass.CURRENTFC);
       
       if(Bud_Query != ''){
           AggregateResult[] budAggregation = Database.Query(Bud_Query);       
           for(integer i1 = 0; i1 < numQuarters ; i1++)
           {
                String sm = 'sm' + i1;
                BudValue = BudValue + ((budAggregation[0].get(sm) != null)?((Double)budAggregation[0].get(sm)): 0.0);
           }
           budAggregation.clear();
       }
       //code added by anjali - begin - adjusted target
       if(filterCriteria.planVsCurrentSelectedOptn == filterCriteria.ADJ_TARGET){
           BudValue = filterCriteria.calcAdjTarget();
       }
       //code added by anjali - end - adjusted target
       this.Budget_Total.Gross_Q1_Value__c = BudValue.round();
       this.Rih_Total.Gross_Q1_Value__c = RIHVal_num.round();
       StageValueMap.clear();
       RevAggregation.clear();
       stageResult.clear();
       
       
            
       if(filterCriteria.selGraphOptn == 'Stage') //if user is viewing split by Stage 
       {
           //Issue-01470 
           filterCriteria.showOnTrack = false;             
           //ER - 0022
           graphLegendLabels.add(filterCriteria.planVsCurrentSelectedOptn);
           graphLegendLabels.add('In Hand');
           graphLegendLabels.add('WNIH');
           graphLegendLabels.add('Pipeline Stage 5');
           graphLegendLabels.add('Pipeline Stage 4');
           graphLegendLabels.add('Pipeline Stage 3');
           graphLegendLabels.add('Pipeline Stage 2');
           graphLegendLabels.add('Pipeline Stage 1');
           
           graphValues.add(decimal.valueOf(BudValue.round()).setScale(0, System.RoundingMode.UP));
           graphValues.add(decimal.valueOf(RIHVal_num.round()).setScale(0, System.RoundingMode.UP));
           graphValues.add(decimal.valueOf(Pipeline_6a.round()).setScale(0, System.RoundingMode.UP));
           graphValues.add(decimal.valueOf(Pipeline_5.round()).setScale(0, System.RoundingMode.UP));
           graphValues.add(decimal.valueOf(Pipeline_4.round()).setScale(0, System.RoundingMode.UP));
           graphValues.add(decimal.valueOf(Pipeline_3.round()).setScale(0, System.RoundingMode.UP));
           graphValues.add(decimal.valueOf(Pipeline_2.round()).setScale(0, System.RoundingMode.UP));
           graphValues.add(decimal.valueOf(Pipeline_1.round()).setScale(0, System.RoundingMode.UP));
           
           this.WonofBudget = 0;
           this.PipelineCoverageAll = 0;
           this.PipelineCoverage3to5 = 0;
           this.RIHvsPlan = 0;
           this.SecuredvsPlan = 0;
           this.GapvsBudget = (BudValue - (RIHVal_num + pipeline_6a));            
           if (BudValue > 0)
                this.WonofBudget = ((RIHVal_num + pipeline_6a)/BudValue)*100;  
            if (this.GapvsBudget != 0) {
                this.PipelineCoverageAll =  (Pipeline_1_5/GapvsBudget)*100;
                this.PipelineCoverage3to5 = (Pipeline_3_5/GapvsBudget)*100;            
            }
            // this.passValueStage = Pipeline_6a.round()+','+ Pipeline_1.round() +','+ Pipeline_2.round() +','+ Pipeline_3.round()+','+ Pipeline_4.round()+','+ Pipeline_5.round()+',' + RIHVal_num.round() + ',';
            // this.passValueStage = this.passValueStage + BudValue.round() + ',' + this.GapvsBudget.round() + ',' + this.WonofBudget + ',' + this.PipelineCoverageAll + ',' + this.PipelineCoverage3to5;
            StagePlanKPI = 'Gap vs ' + filterCriteria.planVsCurrentSelectedOptn + ' : $' + (decimal.valueOf(this.GapvsBudget).setScale(0, System.RoundingMode.UP)).format() + '<br/>';
            StagePlanKPI = StagePlanKPI + 'Won of ' + filterCriteria.planVsCurrentSelectedOptn + ' : ' + (decimal.valueOf(this.WonofBudget).setScale(0, System.RoundingMode.UP)).format() + '% <br/>';
            StagePlanKPI = StagePlanKPI + 'Pipeline Coverage (all)  : ' + (decimal.valueOf(this.PipelineCoverageAll).setScale(0, System.RoundingMode.UP)).format() + '%<br/>';
            StagePlanKPI = StagePlanKPI + 'Pipeline Coverage (3 to 5)  : ' + (decimal.valueOf(this.PipelineCoverage3to5).setScale(0, System.RoundingMode.UP)).format() + '%<br>';
            //Added By Sneha Rathi : 27 dec 2012 : Adding two new KPIs for Japanese User
            if(filterCriteria.isJapaneseUser)
            {
                this.RIHvsPlan = BudValue - RIHVal_num;
                this.SecuredvsPlan = BudValue - RIHVal_num - pipeline_6a - pipeline_5;
                StagePlanKPI = StagePlanKPI + 'RIH vs '+ filterCriteria.planVsCurrentSelectedOptn  +' : $' + (decimal.valueOf(this.RIHvsPlan).setScale(0, System.RoundingMode.UP)).format() +'<br>';
                if(filterCriteria.planVsCurrentSelectedOptn != filterCriteria.ADJ_TARGET)
                    StagePlanKPI = StagePlanKPI + 'Secured vs '+ filterCriteria.planVsCurrentSelectedOptn  +' : $' +(decimal.valueOf(SecuredvsPlan).setScale(0, System.RoundingMode.UP)).format() + '<br>';
            }
            
            
            Decimal secRev1 = Pipeline_5 + Pipeline_6a + RIHVal_num;
            secRev1 = (secRev1 == null)?0.0 : secRev1;
            secRevKPI = 'Secured Revenue : $' + secRev1.setScale(0, System.RoundingMode.UP).format() + '<br/>' ;
            Decimal remainingAdjTarget = BudValue - secRev1;
            secRevKPI += 'Adj Target - Sec Rev: $' +(BudValue - secRev1).setScale(0, System.RoundingMode.UP).format()+ '<br/>' ;
            
            //Issue-02019 Change Formular of "Secured of Adj Target"
            //Decimal wSecRev = (BudValue == 0)? 0.0:(BudValue - secRev1)/BudValue; //old formula
            Decimal wSecRev = (BudValue == 0)? 0.0:(secRev1/BudValue)*100 ;
            secRevKPI += 'Secured of Adj Target: ' + wSecRev.setScale(0, System.RoundingMode.UP).format() + '%<br/>' ;
            
            //Issue-02021 Wrong Results of "Pipeline Coverage (1 to 4) vs Secured Revenue
            Decimal pCoverage = Pipeline_1 + Pipeline_2 + Pipeline_3 + Pipeline_4;
            Decimal pCoverageVsSecRev = (remainingAdjTarget == 0.0)?0.0:(pCoverage/remainingAdjTarget)*100;
            
            //secRevKPI += 'Pipeline Coverage (1 to 4) vs Secured Revenue:' + pCoverage.setScale(0, System.RoundingMode.UP).format();// + '%<br/>' ;
            secRevKPI += 'Pipeline (1 to 4) vs Sec Rev Gap:' + pCoverageVsSecRev.setScale(2, System.RoundingMode.UP).format() + '%';// + '%<br/>' ;
            //Decimal pCoverage1_4 = pCoverage/(BudValue - secRev1);
            //secRevKPI += 'Pipeline Coverage(1-4):' + pCoverage1_4.setScale(0, System.RoundingMode.UP).format() + '%' ;
            //set the above values for excel export - number format - begin
            if(isExcelExport && filterCriteria.planVsCurrentSelectedOptn == filterCriteria.ADJ_TARGET) {
                secRev = secRev1.round();
                adjMinusSecRev = (BudValue - secRev1).round();
                wonOfSecRev = wSecRev.round();
                pipeLineCoverage = pCoverageVsSecRev.round();//pCoverage.round();
                //pipeLineCoverage1_4 = pCoverage1_4.round();
            }
            //set the above values for excel export - number format - begin
            
            
       }
       else //if user is viewing split by Forecast Category
       {
            //Update by: Sneha Date: 29 Jan, 2013 -- Issue-01470 : Hiding On Track if its zero
            Double bestCaseCategory = 0;
            Double commitCategory = 0;
            Double pipelineCategory = 0;
            Double onTrackCategory = 0;
            
            this.BestCase_Total = new Sales_Revenue__c(CurrencyIsoCode = 'USD');
            this.OnTrack_Total = new Sales_Revenue__c(CurrencyIsoCode = 'USD');
            this.Commit_Total = new Sales_Revenue__c(CurrencyIsoCode = 'USD');
            
            Map<String, Double> mapFCData = new Map<String, Double>();
            String forecastQuery = filterCriteria.queryStr('AggregateForecast', SalesTeam_DashboardFilterClass.PIPELINE); 
            AggregateResult[] forecastAggregation = Database.Query(forecastQuery);
            for(AggregateResult ar: forecastAggregation)
            {
               Double val = 0;
               for(integer i = 0; i < numQuarters ; i++)
               {
                    String sm = 'sm' + i; 
                    val = val + ((Double) ar.get(sm));
               }    
               mapFCData.put(String.valueOf(ar.get('ctgry')), val);
            }
            forecastAggregation.clear();
            
            if(mapFCData.get(SalesTeam_DashboardFilterClass.BESTCASEFC) != null)
                bestCaseCategory = mapFCData.get(SalesTeam_DashboardFilterClass.BESTCASEFC);    
            if(mapFCData.get(SalesTeam_DashboardFilterClass.ONTRACKFC) != null)
                onTrackCategory = mapFCData.get(SalesTeam_DashboardFilterClass.ONTRACKFC);
            if(mapFCData.get(SalesTeam_DashboardFilterClass.COMMITFC) != null)
                commitCategory = mapFCData.get(SalesTeam_DashboardFilterClass.COMMITFC);
            if(mapFCData.get(SalesTeam_DashboardFilterClass.PIPELINE) != null)
                pipelineCategory= mapFCData.get(SalesTeam_DashboardFilterClass.PIPELINE);    
            mapFCData.clear();   
            
            this.BestCase_Total.Gross_Q1_Value__c = bestCaseCategory;
            this.OnTrack_Total.Gross_Q1_Value__c = onTrackCategory;
            //Issue-01470
            if(onTrackCategory == 0)
                filterCriteria.showOnTrack = false;       
            this.Commit_Total.Gross_Q1_Value__c = commitCategory;
            this.Pipeline_Total.Gross_Q1_Value__c = pipelineCategory;
            
            //ER - 0022
            graphLegendLabels.add(filterCriteria.planVsCurrentSelectedOptn);
            graphLegendLabels.add('In Hand');
            graphLegendLabels.add('WNIH');
            graphLegendLabels.add('Commit');
            if(filterCriteria.showOnTrack)
                graphLegendLabels.add('On Track');
            graphLegendLabels.add('Best Case');
            graphLegendLabels.add('Pipeline');
            
            graphValues.add(decimal.valueOf(BudValue.round()).setScale(0, System.RoundingMode.UP));
            graphValues.add(decimal.valueOf(RIHVal_num.round()).setScale(0, System.RoundingMode.UP));
            graphValues.add(decimal.valueOf(Pipeline_6a.round()).setScale(0, System.RoundingMode.UP));
            graphValues.add(decimal.valueOf(commitCategory.round()).setScale(0, System.RoundingMode.UP));
            if(filterCriteria.showOnTrack)
                graphValues.add(decimal.valueOf(onTrackCategory.round()).setScale(0, System.RoundingMode.UP));
            graphValues.add(decimal.valueOf(bestCaseCategory.round()).setScale(0, System.RoundingMode.UP));
            graphValues.add(decimal.valueOf(pipelineCategory.round()).setScale(0, System.RoundingMode.UP));
            
            //this.passValueFC = pipelineCategory.round() + ',' + BudValue.round() + ',' + RIHVal_num.round() + ',' + pipeline_6a.round();
            //this.passValueFC = this.passValueFC + ',' +bestCaseCategory.round()+ ',' + onTrackCategory.round() + ',' + commitCategory.round()+',';
            
            this.CommitForecast = RIHVal_num + pipeline_6a + commitCategory;
            this.OnTrackForecast = this.CommitForecast + onTrackCategory;
            this.BestCaseForecast = this.OnTrackForecast + bestCaseCategory;
         
            //this.passValueFC  = this.passValueFC + ((Decimal)this.CommitForecast.round()).toPlainString() + ',' + ((Decimal)this.OnTrackForecast.round()).toPlainString() + ',' + ((Decimal)this.BestCaseForecast.round()).toPlainString();
            
            //Update by: Sneha Date: 3 may, 2012 -- Added new KPI's for graph
            this.commitGapVsPlan = (BudValue - CommitForecast).round();
            this.onTrackGapVsPlan = (BudValue - OnTrackForecast).round();
            this.bestCaseGapVsPlan = (BudValue - BestCaseForecast).round();
            if(BudValue != 0)
            {
                this.onTrackPlanPCT = ( this.OnTrackForecast / BudValue) * 100;
                this.commitPlanPCT = (this.CommitForecast / BudValue) * 100;
                this.bestCasePlanPCT = (this.BestCaseForecast / BudValue) * 100;
            }
            else
            {
                this.onTrackPlanPCT = 0;
                this.commitPlanPCT = 0;
                this.bestCasePlanPCT = 0;
            }
            //this.passValueFC  = this.passValueFC + ',' + this.commitGapVsPlan.round() + ',' + this.commitPlanPCT + ',' + this.onTrackGapVsPlan.round() + ',' + this.onTrackPlanPCT + ',' +  this.bestCaseGapVsPlan.round() + ',' + this.bestCasePlanPCT;
       
            FcForecastKPI = 'Commit Forecast : $' + (decimal.valueOf(this.CommitForecast).setScale(0, System.RoundingMode.UP)).format() + '<br/>';
            //changes by anjali - adjusted target - begin
            if(filterCriteria.planVsCurrentSelectedOptn == filterCriteria.ADJ_TARGET){                
                //Issue-02018 Wrong results of Commit (1-4)
                Decimal commitStg1_4 = 0.0; //pipeline_1 + pipeline_2 + pipeline_3 + pipeline_4;
                Decimal commitStg5_6_w = 0.0;//pipeline_5 + pipeline_6a +  RIHVal_num ;
                //Issue-02018 fix - begin
                String forecastStageQuery = filterCriteria.queryStr('AggregateStage',SalesTeam_DashboardFilterClass.COMMITFC);
                //System.debug('forecastStageQuery = ' + forecastStageQuery );
                AggregateResult[] agFCStage = Database.query(forecastStageQuery);
                for(AggregateResult agfcs : agFCStage ) {
                    String stg = (String)agfcs.get('stg');
                    if(stg == SalesTeam_DashboardFilterClass.STAGE_1 || stg == SalesTeam_DashboardFilterClass.STAGE_2 ||
                        stg == SalesTeam_DashboardFilterClass.STAGE_3 || stg == SalesTeam_DashboardFilterClass.STAGE_4) {
                        for(integer i = 0; i < numQuarters ; i++) {
                            String str = 'sm' + i;
                            commitStg1_4 += ( (agfcs.get(str) != null) ? ((Double)agfcs.get(str)) : 0.0 );
                        }
                    } /* Issue-02088 Remove Stage 5 KPI
                    else if (stg == SalesTeam_DashboardFilterClass.STAGE_5) {
                            for(integer i = 0; i < numQuarters ; i++) {
                                String str = 'sm' + i;
                                commitStg5_6_w += ( (agfcs.get(str) != null) ? ((Double)agfcs.get(str)) : 0.0 );
                            }
                    } */
                }
                //Issue-02018 fix - end
                FcForecastKPI += 'Commit Stage(1 to 4) : $' + ( commitStg1_4 ).setScale(0, System.RoundingMode.UP).format()+ '<br/>';
                
                //FcForecastKPI += 'Commit Stage (Stage5) : $' +(commitStg5_6_w ).setScale(0, System.RoundingMode.UP).format()+ '<br/>';
                if(isExcelExport) {
                    //commitFC1_4 = (pipeline_1 + pipeline_2 + pipeline_3 + pipeline_4).round();
                    //commitFc5_6_WNIH = (pipeline_5 + pipeline_6a +  RIHVal_num).round();
                    commitFC1_4 = (commitStg1_4).round();
                    //commitFc5_6_WNIH = (commitStg5_6_w).round();
                }
            }
            //changes by anjali - adjusted target - end
            if(filterCriteria.showOnTrack)
                FcForecastKPI = FcForecastKPI + 'On Track Forecast : $' + (decimal.valueOf(this.OnTrackForecast).setScale(0, System.RoundingMode.UP)).format() + '<br/>';
            FcForecastKPI = FcForecastKPI + 'Best Case Forecast : $' + (decimal.valueOf(this.BestCaseForecast).setScale(0, System.RoundingMode.UP)).format() + '<br/>';
            
            FcPlanKPI = 'Commit Gap vs ' + filterCriteria.planVsCurrentSelectedOptn + ' : $' + (decimal.valueOf(this.commitGapVsPlan).setScale(0, System.RoundingMode.UP)).format() + '<br/>';
            FcPlanKPI = FcPlanKPI + 'Commit % of ' + filterCriteria.planVsCurrentSelectedOptn + ' : '  + (decimal.valueOf(this.commitPlanPCT).setScale(0, System.RoundingMode.UP)).format() + '%<br/>';
            if(filterCriteria.showOnTrack)
            {
                FcPlanKPI = FcPlanKPI + 'On Track Gap vs ' + filterCriteria.planVsCurrentSelectedOptn + ' &nbsp : &nbsp $'  + (decimal.valueOf(this.onTrackGapVsPlan).setScale(0, System.RoundingMode.UP)).format() + '<br/>';
                FcPlanKPI = FcPlanKPI + 'On Track % of ' + filterCriteria.planVsCurrentSelectedOptn + ' : '  + (decimal.valueOf(this.onTrackPlanPCT).setScale(0, System.RoundingMode.UP)).format() + '%<br/>';
            }
            FcPlanKPI = FcPlanKPI + 'Best Case vs ' + filterCriteria.planVsCurrentSelectedOptn + ' : '  + (decimal.valueOf(this.bestCaseGapVsPlan).setScale(0, System.RoundingMode.UP)).format() + '<br/>';
            FcPlanKPI = FcPlanKPI + 'Best Case % of ' + filterCriteria.planVsCurrentSelectedOptn + ' : '  + (decimal.valueOf(this.bestCasePlanPCT).setScale(0, System.RoundingMode.UP)).format() + '%<br/>';
       }  
    } 
    
    
    public void resetFilter_AdjTarget(){
        filterCriteria.COEName = new List<String>();
        filterCriteria.ParentAccount = new List<String>();
        filterCriteria.OfferingType = new List<String>();
        filterCriteria.OfferingGroup = new List<String>();
        filterCriteria.OfferingSegment = new List<String>();
        filterCriteria.ServiceLine = new List<String>();
        filterCriteria.ServiceLineGroup = new List<String>();
        filterCriteria.GlobalProduct = new List<String>();
    }
    
  
    //function for excel export
    //redirects to a new page which generates pdf, parameters are been added to the new page
    public pageReference ExcelExport()
    {       
            PageReference retUrl = Page.Sales_Team_Summary_Report;   
            retUrl.getParameters().put('calledFromExcel','true');  
            //retUrl.getParameters().put('selectedGraphOptn',this.filterCriteria.selGraphOptn);                         
            retUrl.setRedirect(false);
            return retUrl;     
    }

    // returns the first page of records
    public void first() {
        //context decides from which section first is been called
        //Bud: for Budget
        //Rev: for Revenue
        //WNIH: for Pipeline(Opp stage 6a)
        //Pipe: for Pipeline(Opp stage 1 to 5)
        //BestCase: for Best Case list
        //onTrack: for On Track list
        //Commit: for Commit List
        calledFrom = Apexpages.currentPage().getParameters().get('context');
        If(calledFrom == 'Bud')
        {
           planPaginator.currentPage = 1;
        }   
        else if(calledFrom == 'Rev')
        {
           revenuePaginator.currentPage = 1;
        }
        else if(calledFrom == 'WNIH')
        {
          wnihPaginator.currentPage = 1;
        }
        else if(calledFrom == 'Pipe')
        {
          pipelinePaginator.currentPage = 1;
        }
        else if(calledFrom == 'BestCase')
        {
            BestCaseFCPaginator.currentPage = 1;
        }
        else if(calledFrom == 'OnTrack')
        {
            OnTrackFCPaginator.currentPage = 1;
        }
        else if(calledFrom == 'Commit')
        {
            CommitFCPaginator.currentPage = 1;
        }            
    }
 
    // returns the last page of records
    public void last() {
        
        //context decides from which section last is been called
        //Bud: for Budget
        //Rev: for Revenue
        //WNIH: for Pipeline(Opp stage 6a)
        //Pipe: for Pipeline(Opp stage 1 to 5)
        //BestCase: for Best Case list
        //onTrack: for On Track list
        //Commit: for Commit List
        calledFrom = Apexpages.currentPage().getParameters().get('context');
        If(calledFrom == 'Bud')
        {
           planPaginator.currentPage = planPaginator.lastPage;
        }   
        else if(calledFrom == 'Rev')
        {
          revenuePaginator.currentPage = revenuePaginator.lastPage;
        }
        else if(calledFrom == 'WNIH')
        {
            wnihPaginator.currentPage = wnihPaginator.lastPage;
        }
        else if(calledFrom == 'Pipe')
        {
          pipelinePaginator.currentPage = pipelinePaginator.lastPage;
        }
        else if(calledFrom == 'BestCase')
        {
            BestCaseFCPaginator.currentPage = BestCaseFCPaginator.lastPage;
        }
        else if(calledFrom == 'OnTrack')
        {
            OnTrackFCPaginator.currentPage = OnTrackFCPaginator.lastPage;
        }
        else if(calledFrom == 'Commit')
        {
            CommitFCPaginator.currentPage = CommitFCPaginator.lastPage;
        }
    }
 
    // returns the previous page of records
    public void previous() {
        //context decides from which section previous is been called
        //Bud: for Budget
        //Rev: for Revenue
        //WNIH: for Pipeline(Opp stage 6a)
        //Pipe: for Pipeline(Opp stage 1 to 5)
        //BestCase: for Best Case list
        //onTrack: for On Track list
        //Commit: for Commit List
        calledFrom = Apexpages.currentPage().getParameters().get('context');
        
        If(calledFrom == 'Bud')
        {
           planPaginator.currentPage = planPaginator.currentPage - 1;
        }   
        else if(calledFrom == 'Rev')
        {
           revenuePaginator.currentPage = revenuePaginator.currentPage - 1;
        }
        else if(calledFrom == 'WNIH')
        {
            wnihPaginator.currentPage = wnihPaginator.currentPage - 1;
        }
        else if(calledFrom == 'Pipe')
        {
            pipelinePaginator.currentPage = pipelinePaginator.currentPage - 1;
        }
        else if(calledFrom == 'BestCase')
        {
            BestCaseFCPaginator.currentPage = BestCaseFCPaginator.currentPage - 1;
        }
        else if(calledFrom == 'OnTrack')
        {
            OnTrackFCPaginator.currentPage = OnTrackFCPaginator.currentPage - 1;
        }
        else if(calledFrom == 'Commit')
        {
            CommitFCPaginator.currentPage = CommitFCPaginator.currentPage - 1;
        }
    }
 
    // returns the next page of records
    public void next() {
        //context decides from which section next is been called
        //Bud: for Budget
        //Rev: for Revenue
        //WNIH: for Pipeline(Opp stage 6a)
        //Pipe: for Pipeline(Opp stage 1 to 5)
        //BestCase: for Best Case list
        //onTrack: for On Track list
        //Commit: for Commit List
        calledFrom = Apexpages.currentPage().getParameters().get('context');
        If(calledFrom == 'Bud')
        {
           planPaginator.currentPage = planPaginator.currentPage + 1;
        }   
        else if(calledFrom == 'Rev')
        {
           revenuePaginator.currentPage = revenuePaginator.currentPage + 1;
        }
        else if(calledFrom == 'WNIH')
        {
           wnihPaginator.currentPage = wnihPaginator.currentPage + 1;
        }
        else if(calledFrom == 'Pipe')
        {
           pipelinePaginator.currentPage = pipelinePaginator.currentPage + 1;
        }
        else if(calledFrom == 'BestCase')
        {
            BestCaseFCPaginator.currentPage = BestCaseFCPaginator.currentPage + 1;
        }
        else if(calledFrom == 'OnTrack')
        {
            OnTrackFCPaginator.currentPage = OnTrackFCPaginator.currentPage + 1;
        }
        else if(calledFrom == 'Commit')
        {
            CommitFCPaginator.currentPage = CommitFCPaginator.currentPage + 1;
        }
    }
    
    //null all excel lists
    private void nullAllExcelList()
    {
        commitFCDataExcel = null;
        OnTrackFCDataExcel = null;
        BestCaseFCDataExcel = null;
        pipelineDataExcel = null;
        revenueDataExcel = null;
        wnihDataExcel = null;
        budgetDataExcel = null; 
    }
   
    //function for exporting to excel
    public void calledForExcel()
    {
           //Excel export as per the selected split
           if(filterCriteria.selGraphOptn == 'Stage')
           {
                String pipeline15Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, 'Pipeline15'); 
                pipelineDataExcel = makeListOfList(Database.Query(pipeline15Query));
           } 
           else
           {
                String pipeline15Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, SalesTeam_DashboardFilterClass.PIPELINEFC); 
                pipelineDataExcel = makeListOfList(Database.Query(pipeline15Query));
                
                String CommitQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, SalesTeam_DashboardFilterClass.COMMITFC); 
                commitFCDataExcel = makeListOfList(Database.Query(CommitQuery));
               
                String OnTrackQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, SalesTeam_DashboardFilterClass.ONTRACKFC); 
                OnTrackFCDataExcel = makeListOfList(Database.Query(OnTrackQuery));
                
                String BestCaseQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, SalesTeam_DashboardFilterClass.BESTCASEFC); 
                BestCaseFCDataExcel = makeListOfList(Database.Query(BestCaseQuery));  
           }
           
           String revenueQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, SalesTeam_DashboardFilterClass.REVENUE);
           revenueDataExcel =makeListOfList(Database.Query(revenueQuery));
          
           String pipeline6Query = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, 'Pipeline6a');
           wnihDataExcel = makeListOfList(Database.Query(pipeline6Query));
          
           //String budgetQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, SalesTeam_DashboardFilterClass.BUDGET);  
           //Issue-00362 : Plan vs Current Forecast
           String budgetQuery = '';
           if(filterCriteria.planVsCurrentSelectedOptn == SalesTeam_DashboardFilterClass.PLAN)
                budgetQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, SalesTeam_DashboardFilterClass.BUDGET); //construct queries as required
            else
                budgetQuery = filterCriteria.queryStr(SalesTeam_DashboardFilterClass.SIMPLEEXCELLST, SalesTeam_DashboardFilterClass.CURRENTFC); //construct queries as required
           budgetDataExcel = makeListOfList(Database.Query(budgetQuery));
         
            
           //check if the currency of current user is other than USD
           User currUser = [Select u.DefaultCurrencyIsoCode From User u where u.id = :Userinfo.getUserId() Limit 1 ];
           if(currUser.DefaultCurrencyIsoCode != 'USD')
           {
             //if other than USD then construct a map that consists all the impact values in user's currency - this map is used in excel export page for showing data in dual currency
             haveDualCurrency = true; //true if user's currency is other than USD 
             dualCurrency = currUser.DefaultCurrencyIsoCode; //user's currency
             String dualCurrencyQuery = filterCriteria.queryStr('DualCurrency', 'None');
             List<Sales_Revenue__c> dualCurrencyData = Database.Query(dualCurrencyQuery);
             convertedDualCurrencyMap = new Map<ID, Sales_Revenue__c>(dualCurrencyData);
             dualCurrencyData.clear();
           }
           else
                haveDualCurrency = false; //User's currency is USD
           //call to function to construct list of list
           CommonCalculation();
    }
    
    //constructs list of list for Sales Revenue data - page can't display any list of more than 10000 size in readonly mode, so list of list needs to be constructed for excel as no pagination exists there
    public list<List<Sales_Revenue__c>> makeListOfList(List<Sales_Revenue__c> FullData)
    {
        List<Sales_Revenue__c> tempList = new List<Sales_Revenue__c>();
        List<List<Sales_Revenue__c>> tempListOfList = new List<List<Sales_Revenue__c>>();   
        for(Sales_Revenue__c sr: FullData)
        {
          tempList.add(sr);
          //once list's size reaches 10000, add it to list of list and reinitialize it
          if(tempList.size() == 10000)
          {
             tempListOfList.add(tempList);
             tempList = new List<Sales_Revenue__c>();
          }
        } 
        if(tempList.size() > 0)
            tempListOfList.add(tempList);
       FullData = new List<Sales_Revenue__c>();
       return tempListOfList;
    }
    
    //wapper class for holding pagination information for lists display on page
    public class paginationClass
    {
        public boolean hasNxt{get; private set;} //boolean to check if data for next page is present
        public boolean hasPrev{get; private set;} //boolean to check if data for previous page is present
        public String recStr{get; private set;} //holds current record condition
        public integer currentPage{get; private set;} //holds the current page
        public integer lastPage; //holds the last page
        public paginationClass()
        {
            currentPage = 1;
        }
        public List<Sales_Revenue__c> fillData(String query)
        {
            System.debug('---->>>> ' + query);
            ApexPages.StandardSetController paginator = new ApexPages.StandardSetController(Database.Query(query));
            paginator.setPageSize(MAX_REC_PER_PAGE);
            paginator.setPageNumber(currentPage); 
            List<Sales_Revenue__c> data = (List<Sales_Revenue__c>)paginator.getRecords(); 
            hasNxt = paginator.getHasNext();
            hasPrev = paginator.getHasPrevious();
            Integer MaxRec = paginator.getPageNumber() * paginator.getPageSize();
            Integer MinRec = (paginator.getPageNumber() - 1) * (paginator.getPageSize()) + 1 ;
            if(MaxRec > paginator.getResultSize())
            {
                MaxRec = paginator.getResultSize();
            }
            If(MaxRec < 0)
                MaxRec = 0;
            If(MinRec < 0)
                MinRec = 0;
            recStr = ' Showing ' + MinRec + ' - ' + MaxRec + ' Of ' + paginator.getResultSize() +' records.';
            currentPage = paginator.getPageNumber();
            paginator.last();
            lastPage = paginator.getPageNumber(); 
            paginator = null;
            return data;
        }
        
    }
   
}