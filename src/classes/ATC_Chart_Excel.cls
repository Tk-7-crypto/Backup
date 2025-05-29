public with sharing class ATC_Chart_Excel {
    public List<ProductDataWrapper> lstDataWrapper {get;set;}
    public List<ATCViewWrapper> lstATCViewWrapper {get;set;}
    public List<Date> lstDates {get;set;}        
    public integer dataPeriodLength {get;set;}
    public integer itemCount {get;set;}
    public string ViewMode {get;set;}
    public boolean showDataBlock{get;set;}
    public boolean hasProductData {get;set;} 
    public boolean showResult {get;set;} 
    public Date dataPeriodStart{get;set;}        
    public Date dataPeriodEnd{get;set;} 
    public List<Integer> ListToPlotDiv{get;set;}
    public  Date  minStartDateWithActualData{get;set;}
    public  Date  maxEndDateWithActualData{get;set;}
    public Boolean Non_Chargedeliverof_ATC {get;set;}
    public List<Product2> productListToShowOnPage{get;set;}
    
    public String acc{get;set;} 
    public String aTCodeCriteria {get;set;}
    public String dataPerEnd {get;set;}
    public String dataPerStart {get;set;}
    public String atcCodeForPage {get;set;}
    
    private Id atcRecordTypeID;
    public ATC_Chart_Excel(ApexPages.StandardController controller) 
    {
        dataPeriodLength = 1;
        itemCount = 1;
        showResult = true;
        lstDates = new List<Date>();
        lstDataWrapper = new List<ProductDataWrapper>();
        lstATCViewWrapper = new List<ATCViewWrapper>();
        showDataBlock = false;
        hasProductData = false;
        atcRecordTypeID = ConstantClass.getRecordTypeId('ATC__c','ATC');
        searchResults();
    }
    
    public void searchResults()
    { 
        Try 
        {
            dataPeriodStart = Date.valueOf(apexpages.currentPage().getParameters().get('stDate'));
            dataPeriodEnd   = Date.valueOf(apexpages.currentPage().getParameters().get('endDate'));
            
            String accId    = apexpages.currentPage().getParameters().get('accId');
            ViewMode        = apexpages.currentPage().getParameters().get('view');
            aTCodeCriteria  = apexpages.currentPage().getParameters().get('atcCode');
            dataPerStart =   dataPeriodStart.format();
            dataPerEnd =   dataPeriodEnd.format();
            
            if(aTCodeCriteria.contains('$')) {
                aTCodeCriteria = aTCodeCriteria.replace('$', '%');
                atcCodeForPage = aTCodeCriteria ;
            }
            else {
                atcCodeForPage = aTCodeCriteria ;
            }
            
            if((aTCodeCriteria != '' && aTCodeCriteria != null) && ( aTCodeCriteria.contains('*')) ) {
                aTCodeCriteria = aTCodeCriteria.replace('*','%');
            }
            if(aTCodeCriteria != '' && aTCodeCriteria != null && (!aTCodeCriteria.endsWith('%')) )  {
                
                aTCodeCriteria = aTCodeCriteria + '%'; 
            }
            Non_Chargedeliverof_ATC = Boolean.valueOf(apexpages.currentPage().getParameters().get('Non_Chargedeliverof_ATC'));
            
            String ProductId = '';
            productListToShowOnPage = new List<Product2>();
            Set<id> lstProductId ;
            ProductId  = apexpages.currentPage().getParameters().get('SelectedProducts');
            
            if(ProductId != '' && ProductId != null)
            {   ProductId = ProductId.replace('[','').replace(']','').replace('--All--','');                
             lstProductId = new set<id>();
             for(string idValue : ProductId.split(','))
             {
                 if(idValue != '')
                 {
                     lstProductId.add(ID.ValueOf(idvalue.trim()));
                 }
             }              
             if(lstProductId != null && lstProductId.size()>0)
                 productListToShowOnPage = new List<Product2>([select Name from Product2 where id in :lstProductId  ]); 
            }
            lstDataWrapper = new List<ProductDataWrapper>();
            lstATCViewWrapper = new List<ATCViewWrapper>();
            hasProductData = false;
            showDataBlock = true;
            
            List<Agreement_Line_Item_ATCs__c> lstATCVOrProductView = new List<Agreement_Line_Item_ATCs__c>();                
            List<AggregateResult> groupResult ;
            List<AggregateResult> groupResult3 ;
            List<AggregateResult> groupResult1;
            
            if(accId != '' && accId != null) 
            {            
                Account accnt =  [select name from Account where id =: accId limit 1 ];
                acc = accnt.Name ;            
            } 
            
            String lstATCVOrProductViewQuery = ' select Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c,Agreement_Line_Item__r.Contract_Start_Date__c,Agreement_Line_Item__r.Contract_End_Date__c ,Agreement_Line_Item__r.AgreementId__c,Agreement_Line_Item__r.AgreementId__r.name,Agreement_Line_Item__r.AgreementId__r.Account__r.Name,Agreement_Line_Item__r.AgreementId__r.Active__c,Agreement_Line_Item__r.ProductId__r.Name,ATC__c,ATC__r.ATC_Code__c,ATC__r.RecordTypeId,Non_Charge_deliver_of_ATC__c,Period_of_Non_Charge_Deliver_Start__c,Period_of_Non_Charge_Deliver_End__c,Data_Period_Start__c,Data_Period_End__c,Termination_date__c,Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c,Agreement_Line_Item__r.AgreementId__r.CreatedDate from Agreement_Line_Item_ATCs__c ' ;
            //user can view the data either in Product view or ATC view. depending on user selection generate the desired view
            lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' where ';
            lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' ATC__r.RecordTypeId =: atcRecordTypeID and ' ;
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
                
                whereCondDC_NonChargeTrue_TerminationNotNull = 
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
                
                groupResultQuery = groupResultQuery + ' , MIN(Data_Period_Start__c) min_date , Max(Data_Period_End__c) max_date,MAX(Termination_Date__c) termination_date ' ;
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
                /*  ################  */
                groupResultQuery3 = tempQ + whereCondDC_NonChargeTrue_TerminationNotNull;
                
                groupResultQuery_terminationDt = tempQ + whereCondDateCompare_datPeriodStrtEnd_NonCDATCTrue;
                groupResultQuery = groupResultQuery + whereCondForDateCompare_datPeriodStrtEnd ;
                
            }else {
                groupResultQuery = groupResultQuery + whereCondForDateCompare ; 
            }     
            
            //user can view the data either in Product view or ATC view. depending on user selection generate the desired view
            if(ProductId != '')
            {
                lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + '  Agreement_Line_Item__r.ProductId__c in : lstProductId and '+whereConForNonChargeDeliverAtc + whereCondForDateCompare +  ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ';
                
                groupResultQuery = groupResultQuery + ' and Agreement_Line_Item__r.ProductId__c in : lstProductId '  + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ' ;
                
                groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and Agreement_Line_Item__r.ProductId__c in : lstProductId '  + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ' ;
                
                groupResultQuery3 = groupResultQuery3 + ' and Agreement_Line_Item__r.ProductId__c in : lstProductId '  + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ' ;
                
                if(aTCodeCriteria != '' && aTCodeCriteria != null) {
                    lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' and ATC__r.ATC_Code__c like : aTCodeCriteria ';
                    
                    //groupResult = [select MIN(Data_Period_Start__c) min_date , Max(Data_Period_End__c) max_date, MIN(Period_of_Non_Charge_Deliver_Start__c) min_date_NonDeliver , Max(Period_of_Non_Charge_Deliver_End__c) max_date_NonDeliver from Agreement_Line_Item_ATCs__c where  Agreement_Line_Item__r.ProductId__c in : lstProductId and   Non_Charge_deliver_of_ATC__c = : Non_Chargedeliverof_ATC and Data_Period_Start__c != null and Data_Period_End__c !=null and Data_Period_Start__c >= :dataPeriodStart AND Data_Period_End__c <= :dataPeriodEnd and ATC__r.ATC_Code__c like : aTCodeCriteria and Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ];
                    
                    groupResultQuery = groupResultQuery + ' and ATC__r.ATC_Code__c like : aTCodeCriteria ';
                    
                    groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and ATC__r.ATC_Code__c like : aTCodeCriteria ';
                    
                    groupResultQuery3 = groupResultQuery3 + ' and ATC__r.ATC_Code__c like : aTCodeCriteria ';
                    
                    
                }
            }
            else
            {
                if(accId == null  || accId == '') {
                    
                    lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + whereConForNonChargeDeliverAtc + whereCondForDateCompare + ' and ATC__r.ATC_Code__c like : aTCodeCriteria ';
                    
                    //groupResult = [select MIN(Data_Period_Start__c) min_date , Max(Data_Period_End__c) max_date, MIN(Period_of_Non_Charge_Deliver_Start__c) min_date_NonDeliver , Max(Period_of_Non_Charge_Deliver_End__c) max_date_NonDeliver from Agreement_Line_Item_ATCs__c where Non_Charge_deliver_of_ATC__c = : Non_Chargedeliverof_ATC and Data_Period_Start__c != null and Data_Period_End__c !=null and Data_Period_Start__c >= :dataPeriodStart AND Data_Period_End__c <= :dataPeriodEnd and ATC__r.ATC_Code__c like : aTCodeCriteria  ];
                    
                    groupResultQuery = groupResultQuery + ' and ATC__r.ATC_Code__c like : aTCodeCriteria ' ;
                    
                    groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and ATC__r.ATC_Code__c like : aTCodeCriteria ' ;
                    
                    groupResultQuery3 = groupResultQuery3 + ' and ATC__r.ATC_Code__c like : aTCodeCriteria ' ;
                }
                else {
                    if(aTCodeCriteria == '' || aTCodeCriteria == null)
                    {
                        lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + whereConForNonChargeDeliverAtc +  whereCondForDateCompare + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: accId   '; 
                        //groupResult = [select MIN(Data_Period_Start__c) min_date , Max(Data_Period_End__c) max_date, MIN(Period_of_Non_Charge_Deliver_Start__c) min_date_NonDeliver , Max(Period_of_Non_Charge_Deliver_End__c) max_date_NonDeliver from Agreement_Line_Item_ATCs__c where Non_Charge_deliver_of_ATC__c = : Non_Chargedeliverof_ATC and  Data_Period_Start__c != null and Data_Period_End__c !=null and Data_Period_Start__c >= :dataPeriodStart AND Data_Period_End__c <= :dataPeriodEnd and  Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ];
                        groupResultQuery = groupResultQuery + ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ';
                        
                        groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ';
                        
                        groupResultQuery3 = groupResultQuery3 + ' and Agreement_Line_Item__r.AgreementId__r.Account__c =: accId ';
                        
                        
                    }else {
                        lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + whereConForNonChargeDeliverAtc +  whereCondForDateCompare + ' and ATC__r.ATC_Code__c like : aTCodeCriteria and Agreement_Line_Item__r.AgreementId__r.Account__c =: accId  ';
                        //groupResult = [select MIN(Data_Period_Start__c) min_date , Max(Data_Period_End__c) max_date, MIN(Period_of_Non_Charge_Deliver_Start__c) min_date_NonDeliver , Max(Period_of_Non_Charge_Deliver_End__c) max_date_NonDeliver from Agreement_Line_Item_ATCs__c where Non_Charge_deliver_of_ATC__c = : Non_Chargedeliverof_ATC and  Data_Period_Start__c != null and Data_Period_End__c !=null and Data_Period_Start__c >= :dataPeriodStart AND Data_Period_End__c <= :dataPeriodEnd and ATC__r.ATC_Code__c like : aTCodeCriteria and Agreement_Line_Item__r.AgreementId__r.Account__c =: accId  ];
                        
                        groupResultQuery = groupResultQuery + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: accId and ATC__r.ATC_Code__c like : aTCodeCriteria ';
                        
                        groupResultQuery_terminationDt = groupResultQuery_terminationDt + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: accId and ATC__r.ATC_Code__c like : aTCodeCriteria '; 
                        
                        groupResultQuery3 = groupResultQuery3 + ' and  Agreement_Line_Item__r.AgreementId__r.Account__c =: accId and ATC__r.ATC_Code__c like : aTCodeCriteria '; 
                        
                    }
                }
                
            }
            groupResult =  database.query(groupResultQuery) ;
            if(!Non_Chargedeliverof_ATC) {
                groupResult3 =  database.query(groupResultQuery3) ;
                groupResult1 = database.query(groupResultQuery_terminationDt); 
                
            }
            
            if( viewMode == 'Product' || viewMode == 'ProductSumm') {
                lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' order by Agreement_Line_Item__r.ProductId__r.Name,ATC__r.ATC_Code__c ,Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c ';
            }
            else {
                lstATCVOrProductViewQuery = lstATCVOrProductViewQuery + ' order by ATC__r.ATC_Code__c,Agreement_Line_Item__r.AgreementId__r.Account__r.Name,Agreement_Line_Item__r.ProductId__r.Name,Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c ';
            }
            
            lstATCVOrProductView = database.query(lstATCVOrProductViewQuery);  
            
            if(lstATCVOrProductView != null && lstATCVOrProductView.size()>0)
            {  
                if( (groupResult != null && groupResult.size() >0) || (groupResult1 != null && groupResult1.size() > 0) || (groupResult3 != null && groupResult3.size() > 0) )
                {
                    // minimum Date period start  and maximum Date period end 
                    Date min1,max1,min2,max2,max3_terminationDate;
                    Date min1_terminationDate ;
                    
                    // minimum Non deliver Date period start  and Non deliver maximum Date period end
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
                    else {
                        minStartDateWithActualData = min2;
                        maxEndDateWithActualData = max2;
                    }
                    if(minStartDateWithActualData == null || minStartDateWithActualData < dataPeriodStart)
                        minStartDateWithActualData = dataPeriodStart;
                    if(maxEndDateWithActualData  == null || maxEndDateWithActualData > dataPeriodEnd) 
                        maxEndDateWithActualData = dataPeriodEnd ;
                }
                dataPeriodStart = minStartDateWithActualData ;
                dataPeriodEnd  = maxEndDateWithActualData ;                                       
                Date startDate = dataPeriodStart;
                Date endDate   = dataPeriodEnd;                 
                lstDates = new List<Date>();
                ListToPlotDiv = new List<Integer>();                        
                for(integer i=0; i<=startDate.monthsBetween(endDate);)
                {                       
                    lstDates.Add(startDate);
                    ListToPlotDiv.add(0);
                    startDate = startDate.AddMonths(1);
                }
                dataPeriodLength = lstDates.size();
            }
            if( viewMode == 'Product' || viewMode == 'ATC') { 
                ProcessToBuildWrapList(lstATCVOrProductView);
            } else {
                ProcessToBuildMergeList(lstATCVOrProductView); 
            }
        } catch(Exception e){}
    } 
    
    public class ProductDataWrapper
    {
        public String ProductName{get;set;}
        public String ATCCode{get;set;}
        public String Brand{get;set;}
        public String AgreementName {get;set;}
        public string AgreementNumber{get;set;}
        public string AgreementId {get;set;} 
        public date agreementStartDate{get;set;}
        public date aliContractStartDate{get;set;}
        public datetime createdDate{get;set;}  
        public List<Integer> divList{get;set;}               
        ProductDataWrapper(Agreement_Line_Item_ATCs__c aggli, string strATCCode,boolean NonchargeDeliver, List<Integer> ListToPlotDiv , Date dataPeriodStart ,Date dataPeriodEnd)
        {                
            ATCCode = strATCCode;
            AgreementId = aggli.Agreement_Line_Item__r.AgreementId__c;
            AgreementName = aggli.Agreement_Line_Item__r.AgreementId__r.Name;
            AgreementNumber = aggli.Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c;
            ProductName = aggli.Agreement_Line_Item__r.ProductId__r.Name;
            agreementStartDate = aggli.Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c;
            aliContractStartDate = aggli.Agreement_Line_Item__r.Contract_Start_Date__c ;
            createdDate = aggli.Agreement_Line_Item__r.AgreementId__r.CreatedDate;
            Brand = 'ATC';   //Updated By : Ranu Jain,Date : 17th Sep, Detail : ER-00919                                               
            divList = ATC_Chart_Excel.buildDivList(aggli,nonChargeDeliver,ListToPlotDiv,dataPeriodStart,dataPeriodEnd);                                                           
        }            
    } 
    
    public class ATCViewWrapper
    {
        public String ATCCode{get;set;}
        public String AccountName{get;set;}
        public String Brand{get;set;}                
        public integer RecordCount {get;set;}
        public string productName{get;set;}
        public string AgreementName {get;set;}
        public string AgreementNumber{get;set;}
        public String AgreementId {get;set;}
        public date agreementStartDate{get;set;}
        public date aliContractStartDate{get;set;}
        public datetime createdDate{get;set;}  
        
        public List<Integer> divList{get;set;}                           
        
        //constructor
        public  ATCViewWrapper(Agreement_Line_Item_ATCs__c aggli, string strATCCode,boolean nonChargeDeliver,List<Integer> ListToPlotDiv , Date dataPeriodStart ,Date dataPeriodEnd)
        {
            ATCCode = strATCCode ;
            Brand = 'ATC' ;  
            AgreementId   = aggli.Agreement_Line_Item__r.AgreementId__c ;
            AgreementName = aggli.Agreement_Line_Item__r.AgreementId__r.Name ;
            AgreementNumber = aggli.Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c;
            ProductName   = aggli.Agreement_Line_Item__r.ProductId__r.Name ;                        
            agreementStartDate = aggli.Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c;
            aliContractStartDate = aggli.Agreement_Line_Item__r.Contract_Start_Date__c ;
            createdDate = aggli.Agreement_Line_Item__r.AgreementId__r.CreatedDate;
            AccountName = aggli.Agreement_Line_Item__r.AgreementId__r.Account__r.Name ;
            divList = ATC_Chart_Excel.buildDivList(aggli,nonChargeDeliver,ListToPlotDiv,dataPeriodStart,dataPeriodEnd);                        
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
        } else {                                        
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
    
    Private void ProcessToBuildWrapList(List<Agreement_Line_Item_ATCs__c> AggLineItemATCs)
    {               
        lstDataWrapper = new List<ProductDataWrapper>();
        lstATCViewWrapper = new List<ATCViewWrapper>();
        for(Agreement_Line_Item_ATCs__c objLineItemATC : AggLineItemATCs )
        {   
            System.debug('AggLineItemATCs size'+AggLineItemATCs.size());
            
            if(viewMode == 'Product')
            {
                
                lstDataWrapper.add( new ProductDataWrapper(objLineItemATC ,objLineItemATC.ATC__r.ATC_Code__c,objLineItemATC.Non_Charge_deliver_of_ATC__c,ListToPlotDiv,dataPeriodStart,dataPeriodEnd));                     
            }
            else 
            {  
                
                lstATCViewWrapper.add(new ATCViewWrapper(objLineItemATC ,objLineItemATC.ATC__r.ATC_Code__c,objLineItemATC.Non_Charge_deliver_of_ATC__c,ListToPlotDiv , dataPeriodStart,dataPeriodEnd ));
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
                if (!mapRecordsProd.containskey( acc + ProductName + ATCCode)) {
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
                        }else if( (pdw.agreementStartDate == agreementStartDate) && (pdw.aliContractStartDate == aliContractStartDate) &&  (pdw.AgreementNumber.subString( pdw.AgreementNumber.length()-7,pdw.AgreementNumber.length()) < AgreementNumber.subString( AgreementNumber.length()-7,AgreementNumber.length())) ) {
                            pdw.AgreementNumber = AgreementNumber; 
                            pdw.agreementStartDate = agreementStartDate;
                            pdw.aliContractStartDate =aliContractStartDate;
                            pdw.createdDate = createdDate; 
                            pdw.AgreementId = aggId;                            
                            
                            
                        }else if( (pdw.agreementStartDate == agreementStartDate) && (pdw.aliContractStartDate == aliContractStartDate) && (pdw.AgreementNumber.subString( pdw.AgreementNumber.length()-7,pdw.AgreementNumber.length()) == AgreementNumber.subString( AgreementNumber.length()-7,AgreementNumber.length() )) && (pdw.createdDate < createdDate ) ) {
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
                        }else if( ( adw.agreementStartDate == agreementStartDate ) && (adw.aliContractStartDate == aliContractStartDate) &&  (adw.AgreementNumber.subString( adw.AgreementNumber.length()-7,adw.AgreementNumber.length()) < AgreementNumber.subString( AgreementNumber.length()-7,AgreementNumber.length()) )) {
                            adw.AgreementNumber = AgreementNumber;
                            adw.agreementStartDate = agreementStartDate;
                            adw.aliContractStartDate =aliContractStartDate;
                            adw.createdDate = createdDate; 
                            adw.AgreementId = aggId;                                
                        }else if( ( adw.agreementStartDate == agreementStartDate ) && (adw.aliContractStartDate == aliContractStartDate) && (adw.AgreementNumber.subString( adw.AgreementNumber.length()-7,adw.AgreementNumber.length()) == AgreementNumber.subString( AgreementNumber.length()-7,AgreementNumber.length() )) && (adw.createdDate < createdDate ) ) {
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
            
            //By Nitin Issue : 
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