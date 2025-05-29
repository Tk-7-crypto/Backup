public class ATC_Chart
{       
    /**-- public properties declaration --**/               
    public  String      AccountId {get;set;}
    public  integer     outerColSpan {get;set;}
    public  String      aTCodeCriteria{get;set;}        
    public  List<Date>  lstDates {get;set;}
    public  boolean     hasProductData {get;set;}
    public  integer     dataPeriodLength {get;set;}                      
    public  integer     itemCount {get;set;}        
    public  boolean     showDataBlock{get;set;}        
    public  string      ViewMode {get;set;}               
    public  date        dataPeriodStart{get;set;}
    public  date        dataPeriodEnd{get; set;}        
    public  Date        minStartDateWithActualData{get;set;} 
    public  Date        maxEndDateWithActualData{get;set;}
    public  Integer     pageSize{get;private set;}
    public  Integer     pageNumberInTable{get;set;}
    public  Integer     totaIItemInTable{get;private set;}  
    public  List<Integer> ListToPlotDiv{get;set;}               
    public  Integer     totalPagesInTable{get;private set;}
    public  List<ProductDataWrapper> lstDataWrapper {get;set;}
    public  List<ATCViewWrapper> lstATCViewWrapper {get;set;}
    public  Agreement__c objAgreement {get;set;}
    public  Boolean     Non_Chargedeliverof_ATC{get;set;}
    private Boolean     Non_Chargedeliverof_ATCForExport;
    public  List<selectOption> lstProducts {get;set;}
    public  String      ProductId {get;set;}
    private String      productIdForExport;
    
    //Private Properties 
    private ApexPages.StandardSetController ssc1;
    
    // query strings
    String lstATCVOrProductViewQuery;
    String lstATCVOrProductViewQuerySumm;
    //Query varaiables
    String ATCCode ;
    
    Set<Id> lstProductId ;
    private string searchedViewMode ;
    private string searchedAccountId ;
    private date searchedEndDate ;        
    private string searchedATCode ;
    private date searchedStartDate {get;set;}
    private Id atcRecordTypeID ; // this contains id for record type 'ATC' on ATC__c object
    
    List<Agreement_Line_Item_ATCs__c> lstATCVOrProductView ;
    List<AggregateResult> lstARSumm ;
    Set<String> setProductName = new set<String> ();
    Set<String> setATCCode = new set<String> ();
    Set<String> setAccName = new set<String> ();
    // Set of unique combination to avoid extra combination records by Sandeep 27 Dec 2012
    Set<String> setOfCombination = new Set<String>();
    
    /** Error message declaration **/ 
    private static final String WILD_CHAR_ENTER_MSG = Label.WILD_CHAR_ENTER_MSG;
    
    // pagination variables 
    private Integer offVar = 0;
    // Cconstructor
    public ATC_Chart() 
    {               
        pageSize = 10 ; 
        itemCount = 1;              
        viewMode = 'ProductSumm'; 
        dataPeriodLength = 1;                
        showDataBlock = false;
        hasProductData = false;
        outerColSpan = dataPeriodLength + 1;
        lstDates = new List<Date>();
        objAgreement = new Agreement__c();
        lstDataWrapper = new List<ProductDataWrapper>();
        lstATCViewWrapper = new List<ATCViewWrapper>();                                
        productIdForExport = '' ; 
        Non_Chargedeliverof_ATCForExport = false ; 
        atcRecordTypeID = ConstantClass.getRecordTypeId('ATC__c','ATC');
    }
    
    //action function handler for account selection on UI
    public void AssignAccount()
    {
        if(AccountId == '')
        {
            objAgreement = new Agreement__c();
            lstDataWrapper = new List<ProductDataWrapper>();
            lstATCViewWrapper = new List<ATCViewWrapper>();
            showDataBlock = false;
            hasProductData = false;
            dataPeriodLength = 1;
            outerColSpan = dataPeriodLength + 1;
            itemCount = 1;
            lstDates = new List<Date>();
        }
        else 
        {
            objAgreement.Account__c = AccountId;    
            LoadProducts();
        }
    }
    
    public void RemoveProducts()
    {
        lstProducts = new List<SelectOption>(); 
    }        
    //load products based on the account selected by the user    
    public void LoadProducts()
    {  
        ProductId = '';
        set<Id> productIds = new set<Id>();                
        lstProducts = new List<SelectOption>();                
        if(accountId != '')              
            for(Agreement_Line_item__c objAgreements : [select AgreementId__r.Account__r.Name,ProductId__r.Name,ProductId__r.id ,(select id ,ATC__r.RecordTypeId from Agreement_Line_Item_ATCs__r where ATC__r.RecordTypeId =: atcRecordTypeID ) from Agreement_Line_item__c where AgreementId__r.Account__c =: accountId])
        {                  
            if(objAgreements.Agreement_Line_Item_ATCs__r.size() != 0 && objAgreements.ProductId__r != null)
            {
                if(!productIds.contains(objAgreements.ProductId__r.id))
                {
                    productIds.add(objAgreements.ProductId__r.id);
                    lstProducts.add(new selectOption(objAgreements.ProductId__r.id,objAgreements.ProductId__r.name));
                }
            }
        }                
    }
    
    // Handler to obtain search results based on selected filter criteria 
    /* Updated By : Ranu Jain, date : 13th August
* Detail : This method is updated for optimization of code. 
*/
    
    public void searchResults()
    {   
        
        Try{
            if(objAgreement.Account__c == null && (aTCodeCriteria == '' || aTCodeCriteria == null))
            {
                ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error , 'Please select an account or specify an ATC code.' );
                ApexPages.addMessage(infoMsg);
                lstDataWrapper = new List<ProductDataWrapper>();
                showDataBlock = false;
                return;
            }
            
            //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
            if(dataPeriodStart == null)
            {
                ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error , 'Please select Data Period Start.' );
                ApexPages.addMessage(infoMsg);
                lstDataWrapper = new List<ProductDataWrapper>();
                showDataBlock = false;
                return;
            }                    
            //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
            if(dataPeriodEnd == null)
            {
                ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error , 'Please select Data Period End.' );
                ApexPages.addMessage(infoMsg);
                lstDataWrapper = new List<ProductDataWrapper>();
                showDataBlock = false;
                return;
            } 
            ProductId = ProductId.replace('[','').replace(']','').replace('--All--','');                
            productIdForExport = ProductId ;
            Non_Chargedeliverof_ATCForExport = Non_Chargedeliverof_ATC ; 
            //set<Id> lstProductId ;
            
            IF(ProductId != '')
                lstProductId = new set<id>();
            for(string idValue : ProductId.split(','))
            {
                if(idValue != '')
                {
                    lstProductId.add(ID.ValueOf(idvalue.trim()));
                }
            }
            searchedStartDate = dataPeriodStart;
            searchedEndDate   = dataPeriodEnd;
            searchedViewMode  = viewMode ;
            searchedAccountId = objAgreement.Account__c;
            // initialization 
            lstDataWrapper = new List<ProductDataWrapper>();
            lstATCViewWrapper = new List<ATCViewWrapper>();
            hasProductData = false;
            showDataBlock = true;
            lstATCVOrProductView = new List<Agreement_Line_Item_ATCs__c>();                
            List<AggregateResult> groupResult ;
            List<AggregateResult> groupResult3 ;
            List<AggregateResult> groupResult1;
            
            if(aTCodeCriteria != null && aTCodeCriteria.trim() !='')
            {   
                aTCodeCriteria = aTCodeCriteria.trim();  // Updated BY : Ranu Jain, Date : 
                if(checkForWildChar(aTCodeCriteria)) {
                    return ;
                }
            }   
            if((aTCodeCriteria != '' && aTCodeCriteria != null) && ( aTCodeCriteria.contains('*')) ) {
                ATCCode = aTCodeCriteria.replace('*','%');
            }
            else if(aTCodeCriteria != '' && aTCodeCriteria != null)  {
                ATCCode = aTCodeCriteria + '%'; 
            }
            if(aTCodeCriteria.contains('%')) {
                searchedATCode    = aTCodeCriteria.replace('%', '$');
            }
            else {
                searchedATCode    = aTCodeCriteria ;
            }
            lstATCVOrProductViewQuery = ' select Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c , Agreement_Line_Item__r.Contract_Start_Date__c,Agreement_Line_Item__r.Contract_End_Date__c ,Agreement_Line_Item__r.AgreementId__c,Agreement_Line_Item__r.AgreementId__r.name,Agreement_Line_Item__r.AgreementId__r.Account__r.Name,Agreement_Line_Item__r.AgreementId__r.Active__c,Agreement_Line_Item__r.ProductId__r.Name,ATC__c,ATC__r.ATC_Code__c,ATC__r.RecordTypeId,Non_Charge_deliver_of_ATC__c,Period_of_Non_Charge_Deliver_Start__c,Period_of_Non_Charge_Deliver_End__c,Data_Period_Start__c,Data_Period_End__c,Termination_date__c,Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c,Agreement_Line_Item__r.AgreementId__r.CreatedDate  from Agreement_Line_Item_ATCs__c  ' ;
            lstATCVOrProductViewQuerySumm = ' select Agreement_Line_Item__r.AgreementId__r.Account__r.Name AccName,Agreement_Line_Item__r.ProductId__r.Name prodName,ATC__r.ATC_Code__c atcCode from Agreement_Line_Item_ATCs__c ';
            lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' where ';
            lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + ' where ';
            lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' ATC__r.RecordTypeId =: atcRecordTypeID and ' ;
            lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + ' ATC__r.RecordTypeId =: atcRecordTypeID and ' ;
            String groupResultQuery  = ' select MIN(Period_of_Non_Charge_Deliver_Start__c) min_date_NonDeliver , Max(Period_of_Non_Charge_Deliver_End__c) max_date_NonDeliver ';
            String groupResultQuery_terminationDt = '';
            String groupResultQuery3 = '';
            String whereCondForDateCompare = '';
            String whereConForNonChargeDeliverAtc = '';
            String whereCondForDateCompare_datPeriodStrtEnd = '';
            String whereCondDC_NonChargeTrue_TerminationNotNull = '';
            String where_DataPS_DataPE_notnull = '';
            String whereCondDateCompare_datPeriodStrtEnd_NonCDATCTrue = '';
            String whereConForNonChargeDeliverAtctrue = '';
            if(!Non_Chargedeliverof_ATC) {
                where_DataPS_DataPE_notnull = where_DataPS_DataPE_notnull + ' Data_Period_Start__c != null and Data_Period_End__c !=null and ';
          
                whereCondForDateCompare_datPeriodStrtEnd = where_DataPS_DataPE_notnull + ' (( (NOT (( ( (Data_Period_Start__c < : dataPeriodStart and  Data_Period_End__c <: dataPeriodStart ) '+
                    ' or ( Data_Period_End__c > : '+
                    'dataPeriodEnd and Data_Period_Start__c >:  dataPeriodEnd ) ) '+
                    ' and Non_Charge_deliver_of_ATC__c = false and Termination_date__c = null  ) ) )'+
                    ' OR (  ( Non_Charge_deliver_of_ATC__c = true)  AND  (NOT ( ( ( (Termination_date__c = null ) AND ( ( '+
                    ' (Data_Period_Start__c < : dataPeriodStart and  Data_Period_End__c <: dataPeriodStart )'+
                    '  OR (Data_Period_End__c > : dataPeriodEnd and Data_Period_Start__c >:  dataPeriodEnd ) ) AND  ( '+
                    ' (Period_of_Non_Charge_Deliver_Start__c <: dataPeriodStart and  Period_of_Non_Charge_Deliver_End__c <: '+
                    ' dataPeriodStart) OR ( Period_of_Non_Charge_Deliver_End__c >: dataPeriodEnd and '+
                    ' Period_of_Non_Charge_Deliver_Start__c > :dataPeriodEnd)  )  ) ) ) )  ))) ) '+
                    ' AND ( ( Non_Charge_deliver_of_ATC__c = false and Termination_date__c = null ) OR ( Non_Charge_deliver_of_ATC__c = true AND Termination_date__c = null ) ) ' ;
                
                whereCondDC_NonChargeTrue_TerminationNotNull = where_DataPS_DataPE_notnull + ' (( '+
                    ' ( Non_Charge_deliver_of_ATC__c = true)  AND  (NOT ( (  (Termination_date__c != null ) AND '+
                    ' ( ( (Data_Period_Start__c < : dataPeriodStart and  Termination_date__c <: dataPeriodStart )'+
                    '  OR (Termination_date__c > : dataPeriodEnd and Data_Period_Start__c >:  dataPeriodEnd ) '+
                    '  )  AND ( (Period_of_Non_Charge_Deliver_Start__c <: dataPeriodStart and '+
                    ' Period_of_Non_Charge_Deliver_End__c <: dataPeriodStart) OR '+
                    ' ( Period_of_Non_Charge_Deliver_End__c >: dataPeriodEnd and Period_of_Non_Charge_Deliver_Start__c > :dataPeriodEnd) '+
                    ' )  ) ) )  )) ) '+
                    ' AND ((Non_Charge_deliver_of_ATC__c = true) AND (Termination_date__c != null) ) ' ;              
                
                whereCondDateCompare_datPeriodStrtEnd_NonCDATCTrue = where_DataPS_DataPE_notnull + ' ( (not ((Data_Period_Start__c < : dataPeriodStart and  Termination_date__c <: dataPeriodStart and Termination_date__c != null) '+
                    ' or (Termination_date__c > : '+
                    
                    'dataPeriodEnd and Data_Period_Start__c >:  dataPeriodEnd and Termination_date__c != null ))) )'+
                    ' and  Non_Charge_deliver_of_ATC__c = false  and  Non_Charge_deliver_of_ATC__c = false and Termination_date__c != null '; 
                
                whereCondForDateCompare = whereCondForDateCompare +  ' Data_Period_Start__c != null and Data_Period_End__c !=null and ( '+
                    ' ( ( NOT (  ( (Termination_date__c = null ) '+ 
                    ' AND ( (Data_Period_Start__c < : dataPeriodStart and  Data_Period_End__c <: dataPeriodStart ) '+
                    ' OR ( Data_Period_End__c > :dataPeriodEnd and Data_Period_Start__c >:  dataPeriodEnd) '+
                    ' ) ) OR( (Termination_date__c != null ) AND ( '+
                    ' (Data_Period_Start__c < : dataPeriodStart and  Termination_date__c <: dataPeriodStart ) '+
                    ' OR ( Termination_date__c > :dataPeriodEnd and Data_Period_Start__c >:  dataPeriodEnd) '+
                    ' )  ) ) ) AND( Non_Charge_deliver_of_ATC__c = false ) ) ' +
                    ' OR (  ( Non_Charge_deliver_of_ATC__c = true)  AND  (NOT ( ( ( (Termination_date__c = null ) AND ( ( '+
                    ' (Data_Period_Start__c < : dataPeriodStart and  Data_Period_End__c <: dataPeriodStart )'+
                    '  OR (Data_Period_End__c > : dataPeriodEnd and Data_Period_Start__c >:  dataPeriodEnd ) ) AND  ( '+
                    ' (Period_of_Non_Charge_Deliver_Start__c <: dataPeriodStart and  Period_of_Non_Charge_Deliver_End__c <: '+
                    ' dataPeriodStart) OR ( Period_of_Non_Charge_Deliver_End__c >: dataPeriodEnd and '+
                    ' Period_of_Non_Charge_Deliver_Start__c > :dataPeriodEnd)  )  ) ) OR ( (Termination_date__c != null ) AND '+
                    ' ( ( (Data_Period_Start__c < : dataPeriodStart and  Termination_date__c <: dataPeriodStart )'+
                    '  OR (Termination_date__c > : dataPeriodEnd and Data_Period_Start__c >:  dataPeriodEnd ) '+
                    '  )  AND ( (Period_of_Non_Charge_Deliver_Start__c <: dataPeriodStart and '+
                    ' Period_of_Non_Charge_Deliver_End__c <: dataPeriodStart) OR '+
                    ' ( Period_of_Non_Charge_Deliver_End__c >: dataPeriodEnd and Period_of_Non_Charge_Deliver_Start__c > :dataPeriodEnd) '+
                    ' )  ) )) )  )) )';
                groupResultQuery = groupResultQuery + ' , MIN(Data_Period_Start__c) min_date , Max(Data_Period_End__c) max_date , MAX(Termination_Date__c) termination_date  ' ;
            }else {
                whereCondForDateCompare = whereCondForDateCompare =  ' Data_Period_Start__c != null and Data_Period_End__c !=null and Period_of_Non_Charge_Deliver_Start__c != null and Period_of_Non_Charge_Deliver_End__c !=null and ( not( (Period_of_Non_Charge_Deliver_Start__c <: dataPeriodStart and  Period_of_Non_Charge_Deliver_End__c <: dataPeriodStart) or ( Period_of_Non_Charge_Deliver_End__c >: dataPeriodEnd and Period_of_Non_Charge_Deliver_Start__c > :dataPeriodEnd))) ' ;
                whereConForNonChargeDeliverAtc = ' Non_Charge_deliver_of_ATC__c = : Non_Chargedeliverof_ATC ' ;
            }
            groupResultQuery = groupResultQuery + ' from Agreement_Line_Item_ATCs__c where ' ;
            groupResultQuery = groupResultQuery + ' ATC__r.RecordTypeId =: atcRecordTypeID and ' ;
            
            if( whereConForNonChargeDeliverAtc != '') {
                whereConForNonChargeDeliverAtc = whereConForNonChargeDeliverAtc + ' and ';
            }
            groupResultQuery = groupResultQuery +  whereConForNonChargeDeliverAtc  ;
            if(!Non_Chargedeliverof_ATC ) {
                String tempQ = groupResultQuery ;
                groupResultQuery3 = tempQ + whereCondDC_NonChargeTrue_TerminationNotNull;
                groupResultQuery_terminationDt = tempQ + whereCondDateCompare_datPeriodStrtEnd_NonCDATCTrue;
                groupResultQuery = groupResultQuery + whereCondForDateCompare_datPeriodStrtEnd ;
                
            }else {
                groupResultQuery = groupResultQuery + whereCondForDateCompare ; 
            }
            
            if(ProductId != '')
            {
                lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + '  Agreement_Line_Item__r.ProductId__c in : lstProductId and '+whereConForNonChargeDeliverAtc +  whereCondForDateCompare +  ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId ';
                lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + '  Agreement_Line_Item__r.ProductId__c in : lstProductId and '+whereConForNonChargeDeliverAtc +  whereCondForDateCompare +  ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId '; 
                groupResultQuery = groupResultQuery + ' and Agreement_Line_Item__r.ProductId__c in : lstProductId '  + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId ' ;
                groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and Agreement_Line_Item__r.ProductId__c in : lstProductId '  + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId ' ;
                groupResultQuery3 = groupResultQuery3 + ' and Agreement_Line_Item__r.ProductId__c in : lstProductId '  + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId ' ;
                if(aTCodeCriteria != '' && aTCodeCriteria != null) {
                    lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' and ATC__r.ATC_Code__c like : ATCCode ';
                    lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + ' and ATC__r.ATC_Code__c like : ATCCode '; 
                    groupResultQuery = groupResultQuery + ' and ATC__r.ATC_Code__c like : ATCCode ';
                    groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and ATC__r.ATC_Code__c like : ATCCode ';
                    groupResultQuery3 = groupResultQuery3 + ' and ATC__r.ATC_Code__c like : ATCCode ';
                }
            }
            else
            {
                if(objAgreement.Account__c == null) {
                    lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + whereConForNonChargeDeliverAtc + whereCondForDateCompare + ' and ATC__r.ATC_Code__c like : ATCCode ';
                    lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + whereConForNonChargeDeliverAtc + whereCondForDateCompare + ' and ATC__r.ATC_Code__c like : ATCCode ';
                    groupResultQuery = groupResultQuery + ' and ATC__r.ATC_Code__c like : ATCCode ' ;
                    groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and ATC__r.ATC_Code__c like : ATCCode ' ;
                    groupResultQuery3 = groupResultQuery3 + ' and ATC__r.ATC_Code__c like : ATCCode ' ;
                }
                else {
                    if(aTCodeCriteria == '' || aTCodeCriteria == null)
                    {
                        lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + whereConForNonChargeDeliverAtc +  whereCondForDateCompare + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId   '; 
                        lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + whereConForNonChargeDeliverAtc +  whereCondForDateCompare + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId   '; 
                        groupResultQuery = groupResultQuery + ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId ';
                        groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId ';
                        groupResultQuery3 = groupResultQuery3 + ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId ';
                    }else {
                        lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + whereConForNonChargeDeliverAtc +  whereCondForDateCompare + ' and ATC__r.ATC_Code__c like : ATCCode and Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId  ';
                        lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + whereConForNonChargeDeliverAtc +  whereCondForDateCompare + ' and ATC__r.ATC_Code__c like : ATCCode and Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId  ';
                        groupResultQuery = groupResultQuery + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId and ATC__r.ATC_Code__c like : ATCCode ';   
                        groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId and ATC__r.ATC_Code__c like : ATCCode '; 
                        groupResultQuery3 = groupResultQuery3 + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: searchedAccountId and ATC__r.ATC_Code__c like : ATCCode '; 
                    }
                }
            }
            groupResult =  database.query(groupResultQuery) ;
            if(!Non_Chargedeliverof_ATC) {
                groupResult3 =  database.query(groupResultQuery3) ;
                groupResult1 = database.query(groupResultQuery_terminationDt); 
            }
            if(viewMode == 'ProductSumm' || viewMode == 'ATCSumm') {
                lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' and  Agreement_Line_Item__r.ProductId__r.Name IN : setProductName and ATC__r.ATC_Code__c IN : setATCCode and Agreement_Line_Item__r.AgreementId__r.Account__r.Name IN : setAccName '; 
                lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + ' group by Agreement_Line_Item__r.ProductId__r.Name,ATC__r.ATC_Code__c ,Agreement_Line_Item__r.AgreementId__r.Account__r.Name ';
            } if(viewMode == 'Product' ) {
                lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' order by Agreement_Line_Item__r.ProductId__r.Name,ATC__r.ATC_Code__c,Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c ';
            } else if(viewMode == 'ProductSumm') {
                lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' order by Agreement_Line_Item__r.ProductId__r.Name,ATC__r.ATC_Code__c ,Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c ';
                lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + ' order by Agreement_Line_Item__r.ProductId__r.Name,ATC__r.ATC_Code__c ';
            }else {
                lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' order by ATC__r.ATC_Code__c,Agreement_Line_Item__r.AgreementId__r.Account__r.Name,Agreement_Line_Item__r.ProductId__r.Name  ,Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c';
                lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + ' order by ATC__r.ATC_Code__c,Agreement_Line_Item__r.AgreementId__r.Account__r.Name,Agreement_Line_Item__r.ProductId__r.Name';
            }
            lstARSumm = new list<AggregateResult>(); 
            if(viewMode == 'Product' || viewMode == 'ATC') {
                lstATCVOrProductView = database.query(lstATCVOrProductViewQuery);
                lstATCVOrProductViewQuerySumm =  null;
            } else {
                lstARSumm = database.query(lstATCVOrProductViewQuerySumm);
            }   
            if( (lstATCVOrProductView != null && lstATCVOrProductView.size()>0 ) || (lstARSumm != null && lstARSumm.size()>0 ))
            {   
                if(viewMode == 'Product' || viewMode == 'ATC') {
                    ssc1 = new ApexPages.StandardSetController(lstATCVOrProductView);
                }
                
                if( (groupResult != null && groupResult.size() >0) || (groupResult1 != null && groupResult1.size() > 0) || (groupResult3 != null && groupResult3.size() > 0) )
                {
                    Date min1,max1,min2,max2,max3_terminationDate;
                    Date min1_terminationDate ;
                    min2 =  (groupResult.size() >0)?(date)groupResult.get(0).get('min_date_NonDeliver'): null;
                    max2 =   (groupResult.size() >0)?(date)groupResult.get(0).get('max_date_NonDeliver'):null;
                    if( (min2 < dataPeriodStart && max2 < dataPeriodStart) || ( min2 < dataPeriodStart && max2 < dataPeriodStart  )  ) {
                        min2 = null;
                        max2 = null;
                    }
                    if(!Non_Chargedeliverof_ATC) {
                        Date temMin1,temMin2,temMin3;
                        temMin1 = (groupResult.size() >0)?(date)groupResult.get(0).get('min_date'):null;
                        if( groupResult3 != null ) {
                            temMin3 = ( (date)groupResult3.get(0).get('min_date') > (date)groupResult3.get(0).get('min_date_NonDeliver'))?(date)groupResult3.get(0).get('min_date_NonDeliver'):(date)groupResult3.get(0).get('min_date') ;
                        }
                        if( (temMin1!=null && temMin3!=null) && ( temMin1 < temMin3) ) {
                            temMin1 =  temMin1;
                        } else if( (temMin1!=null && temMin3!=null) && ( temMin3 < temMin1)) {
                            temMin1 = temMin3; 
                        }else if(temMin1==null ) {
                            temMin1 = temMin3;   
                        }else {
                            temMin1 = temMin1;
                        }
                        
                        temMin2 = (groupResult1!=null && groupResult1.size() >0)?(date)groupResult1.get(0).get('min_date'):null;
                        if( (temMin1!=null && temMin2!=null) && ( temMin1 < temMin2) ) {
                            min1 =  temMin1;
                        } else if( (temMin1!=null && temMin2!=null) && ( temMin2 < temMin1)) {
                            min1 = temMin2; 
                        }else if(temMin1==null ) {
                            min1 = temMin2;   
                        }else {
                            min1 = temMin1;
                        }
                        
                        Date tempMax1,tempMax2,tempMax3;
                        tempMax1 = (groupResult.size() >0)?(date)groupResult.get(0).get('max_date'):null;
                        if(groupResult3 != null ) {
                            tempMax3 = ( (date)groupResult3.get(0).get('termination_date') > (date)groupResult3.get(0).get('max_date_NonDeliver') )?(date)groupResult3.get(0).get('termination_date'):(date)groupResult3.get(0).get('max_date_NonDeliver');
                        }
                        tempMax2 = (groupResult1!=null)?(date)groupResult1.get(0).get('termination_date'):null;
                        if( (tempMax3 != null && tempMax1 != null) && (tempMax3 < tempMax1) ) {
                            tempMax1 = tempMax1; 
                        }else if( (tempMax3 != null && tempMax1 != null) && (tempMax1 < tempMax3)  ){
                            tempMax1 = tempMax3; 
                        }else if(tempMax3 == null ) {
                            tempMax1 = tempMax1; 
                        }else {
                            tempMax1 = tempMax3;  
                        }
                        if(  (tempMax1 != null && tempMax2 != null) && (tempMax1 < tempMax2 ) ) {
                            max1 =  tempMax2; 
                        }else if( (tempMax1 != null && tempMax2 != null) && (tempMax2 < tempMax1 ) ) {
                            max1 =  tempMax1; 
                        }else if(tempMax1 == null ) {
                            max1 =  tempMax2;  
                        }else {
                            max1 =  tempMax1;  
                        }
                        if(min2 == null && max2 == null) {
                            minStartDateWithActualData = min1 ;
                            maxEndDateWithActualData = max1;
                        }else {
                            minStartDateWithActualData = ( (min1 == null ) || (min1 > min2 ))? min2 : min1 ; 
                            maxEndDateWithActualData  =  ( (max2 == null) || (max1 > max2) )? max1 : max2 ; 
                        }
                    }
                    // finding minimum of minimum Data period Start and minimum Non-Charge Deliver Start within range provided by user 
                    else {
                        minStartDateWithActualData = min2;
                        maxEndDateWithActualData = max2;
                    }
                    // Reducing the limit if it is still crossing the main range provided by user(it may happen because earlier we didn't check Non-Charge Deliver are within range (provided by user )or not 
                    if(minStartDateWithActualData == null || minStartDateWithActualData < dataPeriodStart)
                        minStartDateWithActualData = dataPeriodStart;
                    if(maxEndDateWithActualData  == null || maxEndDateWithActualData > dataPeriodEnd) 
                        maxEndDateWithActualData = dataPeriodEnd ;
                }
                system.debug('******minStartDateWithActualData*******'+minStartDateWithActualData);
                //system.debug('******maxEndDateWithActualData*******'+maxEndDateWithActualData);
                // -- Replacing given user defined range by calculated date range because in further code we are using only these two field dataPeriodStart,dataPeriodEnd as a criteria 
                dataPeriodStart = minStartDateWithActualData ;
                dataPeriodEnd  = maxEndDateWithActualData ;                                       
                //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
                Date startDate = dataPeriodStart;
                Date endDate   = dataPeriodEnd;                 
                lstDates = new List<Date>();
                // List to be plotted on page with different colors                        
                ListToPlotDiv = new List<Integer>();                            
                for(integer i=0; i<=startDate.monthsBetween(endDate);)
                {                       
                    // creating a list of all months lying between minimum and maximum date (calculated earlier) 
                    lstDates.Add(startDate);
                    ListToPlotDiv.add(0);
                    startDate = startDate.AddMonths(1);
                }
                
                dataPeriodLength = lstDates.size();
                outerColSpan = dataPeriodLength + 1;                                                        
                decimal temp ;                          
                if(viewMode == 'Product' || viewMode == 'ATC') {
                    temp  = ssc1.getResultsize()/decimal.valueof(pagesize);                        
                    totaIItemInTable = ssc1.getResultSize();
                }else {
                    temp  = lstARSumm.size()/decimal.valueof(pagesize);                        
                    totaIItemInTable = lstARSumm.size();
                }
                totalPagesInTABLE = (temp> Integer.valueOf(temp))?Integer.valueOf(temp)+1:Integer.valueOf(temp);
                if(totalPagesInTABLE == 0)
                    totalPagesInTABLE = 1 ; 
                gotofirstPageOfTable();
                
            }
        } catch(exception e)
        {
            Apexpages.addMessages(e);
        }      
    }
    
    public String excelPageUrl{get;set;}
    public void ExporttoExcel()
    {
        string qryStr =  '?';
        qryStr = qryStr + 'stDate=' + searchedStartDate ;
        qryStr = qryStr + '&endDate=' + searchedEndDate ;
        if(searchedAccountId  != null)
            qryStr = qryStr + '&accId=' + searchedAccountId ;
        else
            qryStr = qryStr + '&accId=' ;
        qryStr = qryStr + '&view=' + searchedViewMode ;
        if(searchedATCode  != null) 
            qryStr = qryStr + '&atcCode=' + searchedATCode ;
        else
            qryStr = qryStr + '&atcCode=' ;  
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+ Non_Chargedeliverof_ATCForExport ;
        qryStr = qryStr + '&SelectedProducts='+productIdForExport ;
        
        //updated by smita pandey: Issue-03679 : 10 Feb 2014
        // PageReference ref = new PageReference('https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/ATC_Chart_Excel' + qryStr);
        // return ref ;
        excelPageUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/ATC_Chart_Excel' + qryStr;
    }
    
    // reset button handler 
    public PageReference resetFilters()
    {           
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef; 
    }
    
    // Wrapper class for Product view 
    public class ProductDataWrapper
    {
        //public properties
        public String ProductName{get;set;}
        public String ATCCode{get;set;}
        public String Brand{get;set;}
        public String AgreementName {get;set;}
        public string AgreementNumber{get;set;}
        public string AgreementId {get;set;} 
        public Date agreementStartDate{get;set;}
        public date aliContractStartDate{get;set;}
        public datetime createdDate{get;set;} 
        public List<Integer> divList{get;set;}               
        // constructor 
        ProductDataWrapper(Agreement_Line_Item_ATCs__c aggli, string strATCCode,boolean NonchargeDeliver, List<Integer> ListToPlotDiv , Date dataPeriodStart ,Date dataPeriodEnd)
        {                
            ATCCode = strATCCode;
            AgreementId = aggli.Agreement_Line_Item__r.AgreementId__c;
            AgreementName = aggli.Agreement_Line_Item__r.AgreementId__r.Name;
            AgreementNumber= aggli.Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c;
            ProductName = aggli.Agreement_Line_Item__r.ProductId__r.Name;
            
            //added by :Ranu,ER-283(Request-3),Detail: to find out newest agreement number
            //update by ekta sharma, Detail:Case 70135,date:9th Jan,2013
            agreementStartDate = aggli.Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c;
            aliContractStartDate = aggli.Agreement_Line_Item__r.Contract_Start_Date__c ;
            createdDate = aggli.Agreement_Line_Item__r.AgreementId__r.CreatedDate;
            Brand = 'ATC';  //Updated By : Ranu Jain, Date : 17th Sep,Detail : ER - 00919 (ATC Chart works for only record type 'ATC')
            divList = ATC_Chart.buildDivList(aggli,nonChargeDeliver,ListToPlotDiv,dataPeriodStart,dataPeriodEnd);
        }            
    } 
    
    // wrapper class for ATC view 
    public class ATCViewWrapper
    {
        // public properties
        public String ATCCode{get;set;}
        public String AccountName{get;set;}
        public String Brand{get;set;}                            
        public string productName{get;set;}
        public string AgreementName {get;set;}
        public string AgreementNumber{get;set;}
        public String AgreementId {get;set;}
        //update by ekta sharma, Detail:Case 70135,date:9th Jan,2013
        public date agreementStartDate{get;set;}
        public date aliContractStartDate{get;set;}
        public datetime createdDate{get;set;}
        public List<Integer> divList{get;set;}                           
        
        // constructor
        public  ATCViewWrapper(Agreement_Line_Item_ATCs__c aggli, string strATCCode,boolean nonChargeDeliver,List<Integer> ListToPlotDiv , Date dataPeriodStart ,Date dataPeriodEnd)
        {
            ATCCode = strATCCode ;
            Brand = 'ATC' ;  
            AgreementId   = aggli.Agreement_Line_Item__r.AgreementId__c ;
            AgreementName = aggli.Agreement_Line_Item__r.AgreementId__r.Name ;
            AgreementNumber= aggli.Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c;
            ProductName   = aggli.Agreement_Line_Item__r.ProductId__r.Name ;                        
            AccountName = aggli.Agreement_Line_Item__r.AgreementId__r.Account__r.Name ;
            agreementStartDate = aggli.Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c;
            aliContractStartDate = aggli.Agreement_Line_Item__r.Contract_Start_Date__c ;
            createdDate = aggli.Agreement_Line_Item__r.AgreementId__r.CreatedDate;
            divList = ATC_Chart.buildDivList(aggli,nonChargeDeliver,ListToPlotDiv,dataPeriodStart,dataPeriodEnd);                        
        }
    }  
    
    private static List<Integer> localListToPlotDiv ; 
    private static Date dateToFindIndex ;     
    private static Integer index ;        
    private static List<Integer> tempdivList ; 
    public  static List<Integer> BuildDivList(Agreement_Line_Item_ATCs__c aggli,boolean nonChargeDeliver,List<Integer> ListToPlotDiv , Date dataPeriodStart ,Date dataPeriodEnd)
    {
        localListToPlotDiv = ListToPlotDiv.clone();  
        if (aggli.Termination_Date__c != null) {
            if(aggli.Period_of_Non_Charge_Deliver_Start__c == null && aggli.Period_of_Non_Charge_Deliver_End__c == null && nonChargeDeliver == false) {
                dateToFindIndex = aggli.Data_Period_start__c.toStartOfMonth() ;
                
                while(dateToFindIndex <= aggli.Termination_Date__c )
                {   
                    
                    if(dateToFindIndex>= dataPeriodStart.toStartOfMonth() && dateToFindIndex <= dataPeriodEnd.toStartOfMonth())
                    {   
                        index = dataPeriodStart.toStartOfMonth().monthsBetween(dateToFindIndex.toStartOfMonth());                                   
                        if(localListToPlotDiv.get(index)!=2)
                            localListToPlotDiv.set(index,1);        
                    }
                    dateToFindIndex = dateToFindIndex.addMonths(1) ;                                 
                }
                
            }
            
            if(dataPeriodStart != null && dataPeriodEnd != null && aggli.Data_Period_start__c != null && aggli.Data_Period_end__c != null)
            {
                dateToFindIndex = aggli.Data_Period_start__c.toStartOfMonth() ;
                while(dateToFindIndex <= aggli.Termination_Date__c )
                {   
                    if(dateToFindIndex>= dataPeriodStart.toStartOfMonth() && dateToFindIndex <= dataPeriodEnd.toStartOfMonth())
                    {   
                        index = dataPeriodStart.toStartOfMonth().monthsBetween(dateToFindIndex.toStartOfMonth());                                   
                        if(localListToPlotDiv.get(index)!=2)
                            localListToPlotDiv.set(index,1);        
                    }
                    
                    dateToFindIndex = dateToFindIndex.addMonths(1) ;                                 
                }
            }
            if(aggli.Period_of_Non_Charge_Deliver_Start__c != null && aggli.Period_of_Non_Charge_Deliver_End__c != null && aggli.Data_Period_start__c != null && aggli.Data_Period_end__c != null )
            {
                dateToFindIndex = aggli.Period_of_Non_Charge_Deliver_Start__c.toStartOfMonth() ;                                                                              
                date endDttoPlotgray = ((aggli.Termination_date__c != null &&(aggli.Termination_date__c < aggli.Period_of_Non_Charge_Deliver_End__c ) )|| ( (aggli.Termination_date__c != null) && aggli.Termination_date__c <aggli.Period_of_Non_Charge_Deliver_Start__c) )?aggli.Termination_date__c:aggli.Period_of_Non_Charge_Deliver_End__c;                         
                while(dateToFindIndex <= endDttoPlotgray)
                {   
                    if(dateToFindIndex.toStartOfMonth()>= dataPeriodStart.toStartOfMonth() && dateToFindIndex.toStartOfMonth() <= dataPeriodEnd.toStartOfMonth())
                    {                                   
                        index = dataPeriodStart.toStartOfMonth().monthsBetween(dateToFindIndex.toStartOfMonth());                                   
                        localListToPlotDiv.set(index,2); 
                        
                    } 
                    dateToFindIndex = dateToFindIndex.addMonths(1) ;                                
                }
            } 
        }
        else {                                        
            if(dataPeriodStart != null && dataPeriodEnd != null && aggli.Data_Period_start__c != null && aggli.Data_Period_end__c != null)
            {
                
                dateToFindIndex = aggli.Data_Period_start__c.toStartOfMonth() ;
                
                while(dateToFindIndex <= aggli.Data_Period_end__c)
                {   
                    if(dateToFindIndex>= dataPeriodStart.toStartOfMonth() && dateToFindIndex <= dataPeriodEnd.toStartOfMonth())
                    {   
                        index = dataPeriodStart.toStartOfMonth().monthsBetween(dateToFindIndex.toStartOfMonth());                                   
                        if(localListToPlotDiv.get(index)!=2)
                            localListToPlotDiv.set(index,1);        
                    }
                    
                    dateToFindIndex = dateToFindIndex.addMonths(1) ;                                 
                }
            }
            
            if(aggli.Period_of_Non_Charge_Deliver_Start__c != null && aggli.Period_of_Non_Charge_Deliver_End__c != null && aggli.Data_Period_start__c != null && aggli.Data_Period_end__c != null)
            {
                
                dateToFindIndex = aggli.Period_of_Non_Charge_Deliver_Start__c.toStartOfMonth() ;                                                                              
                while(dateToFindIndex <= aggli.Period_of_Non_Charge_Deliver_End__c)
                {   
                    if(dateToFindIndex.toStartOfMonth()>= dataPeriodStart.toStartOfMonth() && dateToFindIndex.toStartOfMonth() <= dataPeriodEnd.toStartOfMonth())
                    {                                   
                        index = dataPeriodStart.toStartOfMonth().monthsBetween(dateToFindIndex.toStartOfMonth());                                   
                        localListToPlotDiv.set(index,2); 
                        
                    } 
                    dateToFindIndex = dateToFindIndex.addMonths(1) ;                                
                }
            } 
        }
        tempdivList = localListToPlotDiv.clone();  
        localListToPlotDiv.clear(); // Clearing list to avoid overriding colors 
        return tempdivList;
    }     
    
    public void gotofirstPageOfTable() {                      
        offVar = 0; 
        pageNumberInTable= 1;           
        if(viewMode == 'Product' || viewMode == 'ATC')  {           
            ProcessToBuildWrapList(BuildPaginatedAgLnItmAtcs(pageNumberInTable));
        }
        else  {
            ProcessToBuildMergeList(BuildPaginatedAgLnItmAtcs(pageNumberInTable,offVar)) ;   
        }  
    }
    
    public void gotoNextPageOfTable() {             
        
        if(pageNumberInTable != totalPagesinTable) {
            pageNumberInTable++;
            offVar = offVar + 10;
        }               
        if(viewMode == 'Product' || viewMode == 'ATC') {                        
            ProcessToBuildWrapList(BuildPaginatedAgLnItmAtcs(pageNumberInTable));
        } else {
            ProcessToBuildMergeList(BuildPaginatedAgLnItmAtcs(pageNumberInTable,offVar)) ;
        }
        
    }
    
    public void gotoPreviousPageOfTable(){        
        if(pageNumberInTable!=1) {
            pageNumberInTable--; 
            offVar = offVar - 10;
        }
        if( viewMode == 'Product' || viewMode == 'ATC' )  {              
            ProcessToBuildWrapList(BuildPaginatedAgLnItmAtcs(pageNumberInTable));  
            
        }else {
            ProcessToBuildMergeList(BuildPaginatedAgLnItmAtcs(pageNumberInTable,offVar)) ;  
        }   
    }
    public void gotoLastPageOfTable (){          
        pageNumberInTable = totalPagesinTable;  
        if( viewMode == 'Product' || viewMode == 'ATC' )  {             
            ProcessToBuildWrapList(BuildPaginatedAgLnItmAtcs(pageNumberInTable));
        } else {
            offVar = (totalPagesinTable-1)*10;
            ProcessToBuildMergeList(BuildPaginatedAgLnItmAtcs(pageNumberInTable,offVar)) ;  
        }
    } 
    private List<Agreement_Line_Item_ATCs__c> BuildPaginatedAgLnItmAtcs(Integer pageNumber)
    {   
        List<Agreement_Line_Item_ATCs__c> tempAgLinItemATCs = new List<Agreement_Line_Item_ATCs__c>();          
        ssc1.setpageSize(pagesize);
        ssc1.setpageNumber(pageNumber);
        tempAgLinItemATCs = ssc1.getRecords();
        return tempAgLinItemATCs ;            
    }
    
    private List<Agreement_Line_Item_ATCs__c> BuildPaginatedAgLnItmAtcs(Integer pageNumber,Integer OffsetVar)
    {        
        lstATCVOrProductViewQuerySumm = lstATCVOrProductViewQuerySumm + ' limit 10 OFFSET ' + OffsetVar; 
        setProductName = setATCCode =setAccName = setOfCombination =  new set<String>();                                           
        for(AggregateResult aggR : database.query(lstATCVOrProductViewQuerySumm))//lstARSumm)
        {
            setProductName.add( String.valueOf(aggR.get('prodName')));
            setATCCode.add(String.valueOf( aggR.get('atcCode') ));
            setAccName.add( String.valueOf(aggR.get('AccName') ));
            //Building Set of unique combination
            setOfCombination.add(String.valueOf(aggR.get('prodName'))+'-'+String.valueOf( aggR.get('atcCode') )+'-'+String.valueOf(aggR.get('AccName') ));                 
        }           
        List<Agreement_Line_Item_ATCs__c> tempAgLinItemATCFiltered = new List<Agreement_Line_Item_ATCs__c>();      
        // Removing out extra records based on created set earlier
        for(Agreement_Line_Item_ATCs__c ALIATCTemp : database.query(lstATCVOrProductViewQuery))
        {
            if(setOfCombination.contains(ALIATCTemp.Agreement_Line_Item__r.ProductId__r.Name+'-'+ALIATCTemp.ATC__r.ATC_Code__c+'-'+ALIATCTemp.Agreement_Line_Item__r.AgreementId__r.Account__r.Name))
                tempAgLinItemATCFiltered.add(ALIATCTemp);
        }                                    
        lstATCVOrProductViewQuerySumm =  lstATCVOrProductViewQuerySumm.replace(lstATCVOrProductViewQuerySumm.subString(lstATCVOrProductViewQuerySumm.indexOf('limit'),lstATCVOrProductViewQuerySumm.length()),' ');
        return tempAgLinItemATCFiltered ;            
    }
    
    Private void ProcessToBuildWrapList(List<Agreement_Line_Item_ATCs__c> AggLineItemATCs)
    {   
        
        lstDataWrapper = new List<ProductDataWrapper>();
        lstATCViewWrapper = new List<ATCViewWrapper>();
        for(Agreement_Line_Item_ATCs__c objLineItemATC : AggLineItemATCs )
        {   
            if(viewMode == 'Product')
            {
                lstDataWrapper.add( new ProductDataWrapper(objLineItemATC ,objLineItemATC.ATC__r.ATC_Code__c,objLineItemATC.Non_Charge_deliver_of_ATC__c,ListToPlotDiv,minStartDateWithActualData ,maxEndDateWithActualData ));                     
            }
            else if(viewMode == 'ATC') 
            {   
                lstATCViewWrapper.add(new ATCViewWrapper(objLineItemATC ,objLineItemATC.ATC__r.ATC_Code__c,objLineItemATC.Non_Charge_deliver_of_ATC__c,ListToPlotDiv , minStartDateWithActualData ,maxEndDateWithActualData  ));
            }
        }            
        
        if(lstDataWrapper.size() > 0)
        {
            hasProductData = true;
            itemCount = lstDataWrapper.size()+2;
        }
        if(lstATCViewWrapper.size()>0 )
        {   
            hasProductData = true;
            itemCount = lstATCViewWrapper.size()+2;
        }           
    }
    
    public  boolean checkForWildChar(String searchByString) {
        String charcntString =  searchByString.replaceAll('\\*','');
        charcntString = charcntString.replaceAll('%','');
        if(charcntString.length() <= 0) {
            
            ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error, WILD_CHAR_ENTER_MSG );
            ApexPages.addMessage(infoMsg);
            return true ;
        }
        return false;
    }
    
    Private void ProcessToBuildMergeList(List<Agreement_Line_Item_ATCs__c> AggLineItemATCs)
    {   
        Map<String,ProductDataWrapper> mapRecordsProd = new Map<String,ProductDataWrapper>(); 
        Map<String,ATCViewWrapper> mapRecordsATC = new Map<String,ATCViewWrapper>(); 
        lstDataWrapper = new List<ProductDataWrapper>();
        lstATCViewWrapper = new List<ATCViewWrapper>();
        
        for(Agreement_Line_Item_ATCs__c objLineItemATC : AggLineItemATCs )
        {   
            String ATCCode = objLineItemATC.ATC__r.ATC_Code__c;
            String AgreementNumber= objLineItemATC .Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c;
            String acc = objLineItemATC .Agreement_Line_Item__r.AgreementId__r.Account__c;
            String ProductName = objLineItemATC.Agreement_Line_Item__r.ProductId__r.Name;
            date agreementStartDate = objLineItemATC.Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c;
            date aliContractStartDate  = objLineItemATC.Agreement_Line_Item__r.Contract_Start_Date__c ;
            datetime createdDate = objLineItemATC.Agreement_Line_Item__r.AgreementId__r.CreatedDate;
            Id aggId = objLineItemATC.Agreement_Line_Item__r.AgreementId__c;
            if(viewMode == 'ProductSumm')
            {
                if (!mapRecordsProd.containskey(acc + ProductName + ATCCode)) {
                    ProductDataWrapper prodWrap = new ProductDataWrapper(objLineItemATC ,objLineItemATC.ATC__r.ATC_Code__c,objLineItemATC.Non_Charge_deliver_of_ATC__c,ListToPlotDiv,minStartDateWithActualData ,maxEndDateWithActualData );
                    lstDataWrapper.add( prodWrap);                     
                    mapRecordsProd.put(acc + ProductName + ATCCode, prodWrap);
                }
                else {
                    if(mapRecordsProd.containskey(acc + ProductName + ATCCode)) {
                        ProductDataWrapper pdw = mapRecordsProd.get(acc + ProductName + ATCCode);
                        pdw.divList = ATC_Chart.buildDivList(objLineItemATC ,objLineItemATC.Non_Charge_deliver_of_ATC__c,pdw.divList,minStartDateWithActualData ,maxEndDateWithActualData); 
                        if( pdw.agreementStartDate < agreementStartDate) {
                            pdw.AgreementNumber = AgreementNumber; 
                            pdw.agreementStartDate = agreementStartDate;
                            pdw.aliContractStartDate =aliContractStartDate;
                            pdw.createdDate = createdDate;
                            pdw.AgreementId = aggId;
                        } else if( ( pdw.agreementStartDate == agreementStartDate ) && (pdw.aliContractStartDate < aliContractStartDate) ){
                            pdw.AgreementNumber = AgreementNumber; 
                            pdw.agreementStartDate = agreementStartDate;
                            pdw.aliContractStartDate =aliContractStartDate;
                            pdw.createdDate = createdDate;
                            pdw.AgreementId = aggId;
                        }else if( ( pdw.agreementStartDate == agreementStartDate ) && (pdw.aliContractStartDate == aliContractStartDate) &&  (pdw.AgreementNumber.subString( pdw.AgreementNumber.length()-7,pdw.AgreementNumber.length()) < AgreementNumber.subString( AgreementNumber.length()-7,AgreementNumber.length()) )) {
                            pdw.AgreementNumber = AgreementNumber; 
                            pdw.agreementStartDate = agreementStartDate;
                            pdw.aliContractStartDate =aliContractStartDate;
                            pdw.createdDate = createdDate; 
                            pdw.AgreementId = aggId;                            
                            
                            
                        }else if( ( pdw.agreementStartDate == agreementStartDate ) && (pdw.aliContractStartDate == aliContractStartDate) &&  (pdw.AgreementNumber.subString( pdw.AgreementNumber.length()-7,pdw.AgreementNumber.length()) == AgreementNumber.subString( AgreementNumber.length()-7,AgreementNumber.length()) ) && (pdw.createdDate < createdDate ) ) {
                            pdw.AgreementNumber = AgreementNumber; 
                            pdw.agreementStartDate = agreementStartDate;
                            pdw.aliContractStartDate =aliContractStartDate;
                            pdw.createdDate = createdDate; 
                            pdw.AgreementId = aggId;
                        } 
                    }
                    else {
                        lstDataWrapper.add( new ProductDataWrapper(objLineItemATC ,objLineItemATC.ATC__r.ATC_Code__c,objLineItemATC.Non_Charge_deliver_of_ATC__c,ListToPlotDiv,minStartDateWithActualData ,maxEndDateWithActualData )) ;
                    }
                }
            }
            else 
            {   
                if (!mapRecordsATC.containskey( acc + ProductName + ATCCode)) {
                    ATCViewWrapper ATCWrap = new ATCViewWrapper(objLineItemATC ,objLineItemATC.ATC__r.ATC_Code__c,objLineItemATC.Non_Charge_deliver_of_ATC__c,ListToPlotDiv,minStartDateWithActualData ,maxEndDateWithActualData );
                    lstATCViewWrapper.add( ATCWrap);                     
                    mapRecordsATC.put(acc + ProductName + ATCCode, ATCWrap);
                }
                else {
                    if(mapRecordsATC.containskey(acc + ProductName + ATCCode)) {
                        ATCViewWrapper adw = mapRecordsATC.get(acc + ProductName + ATCCode);
                        
                        
                        adw.divList = ATC_Chart.buildDivList(objLineItemATC ,objLineItemATC.Non_Charge_deliver_of_ATC__c,adw.divList,minStartDateWithActualData ,maxEndDateWithActualData); 
                        if( adw.agreementStartDate < agreementStartDate) {
                            adw.AgreementNumber = AgreementNumber;
                            adw.agreementStartDate = agreementStartDate;
                            adw.aliContractStartDate =aliContractStartDate;
                            adw.createdDate = createdDate;
                            adw.AgreementId = aggId;                            
                            
                            
                        } else if( ( adw.agreementStartDate == agreementStartDate ) && (adw.aliContractStartDate < aliContractStartDate) ){
                            adw.AgreementNumber = AgreementNumber;
                            adw.agreementStartDate = agreementStartDate;
                            adw.aliContractStartDate =aliContractStartDate;
                            adw.createdDate = createdDate;
                            adw.AgreementId = aggId;
                        }else if(( adw.agreementStartDate == agreementStartDate ) && (adw.aliContractStartDate == aliContractStartDate) &&  (adw.AgreementNumber.subString( adw.AgreementNumber.length()-7,adw.AgreementNumber.length()) < AgreementNumber.subString( AgreementNumber.length()-7,AgreementNumber.length())) ) {
                            adw.AgreementNumber = AgreementNumber;
                            adw.agreementStartDate = agreementStartDate;
                            adw.aliContractStartDate =aliContractStartDate;
                            adw.createdDate = createdDate; 
                            adw.AgreementId = aggId;                            
                            
                            
                        }else if( ( adw.agreementStartDate == agreementStartDate ) && (adw.aliContractStartDate == aliContractStartDate) &&  (adw.AgreementNumber.subString( adw.AgreementNumber.length()-7,adw.AgreementNumber.length()) == AgreementNumber.subString( AgreementNumber.length()-7,AgreementNumber.length())) && (adw.createdDate < createdDate ) ) {
                            adw.AgreementNumber = AgreementNumber;
                            adw.agreementStartDate = agreementStartDate;
                            adw.aliContractStartDate =aliContractStartDate;
                            adw.createdDate = createdDate; 
                            adw.AgreementId = aggId;                            
                        }
                        
                    }
                    else {
                        lstATCViewWrapper.add( new ATCViewWrapper(objLineItemATC ,objLineItemATC.ATC__r.ATC_Code__c,objLineItemATC.Non_Charge_deliver_of_ATC__c,ListToPlotDiv,minStartDateWithActualData ,maxEndDateWithActualData )) ;
                    }
                }
                
            }
            
            
            //By Nitin Detail : case Case 70078 : to sort list basis of Agreement Number
            list<String> keyList=new List<String>();
            Map<String,ATCViewWrapper> AtcMap=new Map<String,ATCViewWrapper>();
            Map<String,ProductDataWrapper> productMap=new Map<String,ProductDataWrapper>();
            if(lstDataWrapper.size()!=0)
            {
                for(ProductDataWrapper productObject : lstDataWrapper)
                {
                    keyList.add(productObject.ProductName+'-'+productObject.ATCCode+'-'+productObject.AgreementNumber);
                    productMap.put(productObject.ProductName+'-'+productObject.ATCCode+'-'+productObject.AgreementNumber,productObject);
                }
                keyList.sort();
                lstDataWrapper=new list<ProductDataWrapper>();
                for(String productKey : keyList)
                {
                    lstDataWrapper.add(productMap.get(productKey));
                } 
            }
            else if(lstATCViewWrapper.size()!=0)
            {
                for(ATCViewWrapper productObject : lstATCViewWrapper)
                {
                    keyList.add(productObject.ATCCode+'-'+productObject.AccountName+'-'+productObject.productName+'-'+productObject.AgreementNumber);
                    AtcMap.put(productObject.ATCCode+'-'+productObject.AccountName+'-'+productObject.productName+'-'+productObject.AgreementNumber,productObject);
                }
                keyList.sort();
                lstATCViewWrapper=new list<ATCViewWrapper >();
                for(String productKey : keyList)
                {
                    lstATCViewWrapper.add(AtcMap.get(productKey));
                } 
            } 
        }        
        if(lstDataWrapper.size() > 0)
        {
            hasProductData = true;
            itemCount = lstDataWrapper.size()+2;
        }
        if(lstATCViewWrapper.size()>0 )
        {   
            hasProductData = true;
            itemCount = lstATCViewWrapper.size()+2;
        }           
    }
}