// Controller for Excel export of contract chart
public class Contract_Chart_Excel
    {
       //public properties
        public boolean showDataBlock{get;set;}
        public Map<Id,List<Agreement__c>> mapParentChildDetails {get;set;}
        public Map<Id,Agreement__c> mapAgreementList {get;set;}
        public List<ChartHierarchyDataWrapper> lstChartDataWrapper {get;set;}
        public set<id> lastNodeSet {get;set;}
        public Contract_Management_Setting__c contractColorSettings{get;set;}
        //Added By Sweta Details:ISSUE-7084 Date:08/05/2015 
        /***********START**********************/
        public String JPAggRecordTypeId;
        public String JPMasterRecordTypeId;
        /***************END DETAILS:ISSUE-7084********************/
        
        //constructor
        public Contract_Chart_Excel(ApexPages.StandardController controller) 
            {
                //initialization block
                showDataBlock = false;
                contractColorSettings = Contract_Management_Setting__c.getInstance();
                //ADDED BY SWETA Date:08/05/2015 Details: Issue-7084
                /***************Start********************************/     
                //Added these to apply record check in the query.           
                JPAggRecordTypeId =(contractColorSettings.Japan_Master_Agreement__c != null)?contractColorSettings.Japan_Agreement__c:''; 
                JPMasterRecordTypeId =(contractColorSettings.Japan_Master_Agreement__c != null)?contractColorSettings.Japan_Master_Agreement__c:'';
                /***************End Details:Issue-7084**************/
                //Show search results on page load
                searchResults();
            }
    
        //function to fetch and plot search results
        public void searchResults()
            {
                //fetch query parameters
                string ProductId = apexpages.currentPage().getParameters().get('prodId');
                string accountId = apexpages.currentPage().getParameters().get('accId');
                string contractStatus = apexpages.currentPage().getParameters().get('status');
                string contType = apexpages.currentPage().getParameters().get('type');
                string startDate = apexpages.currentPage().getParameters().get('startDate');
                string endDate = apexpages.currentPage().getParameters().get('endDate');

                List<String> contractType = new List<String>() ;
                if(contType != '' && contType != null) {
                    contractType  =  contType.split(',',-2);
                }
                    
                //initialize variables
                List<Agreement__c> lstAgreementData = new List<Agreement__c>();
                Map<id,Agreement__c> mapAgreementData = new Map<id,Agreement__c>();
                mapAgreementList =  new map<id,Agreement__c>();
                mapParentChildDetails = new Map<Id,List<Agreement__c>>();
                
                ProductId = ProductId.replace('[','').replace(']','');

                boolean conStatus = Boolean.valueOf(contractStatus);
                date dataPeriodStart;
                date dataPeriodEnd ;
                 List<Agreement__c> listAgree = new List<Agreement__c>();
                if(startDate != null && startDate != '' && startDate != 'null'){

                 dataPeriodStart = Date.valueOf(startDate);
                }
               if(endDate!= null && endDate != '' && endDate != 'null' )
                    dataPeriodEnd = Date.valueOf(endDate);

               String query ;
                if(ProductId != '')
                    {
                        set<Id> lstProductId = new set<id>();
                        for(string idValue : ProductId.split(','))
                            {
                                if(idValue != '')
                                    {
                                        lstProductId.add(ID.ValueOf(idvalue.trim()));
                                    }
                            }
                            if(contractStatus != 'All')
                            {
                                if(startDate != 'null' && endDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc '  ;
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                             
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) and Company_Signed_Date__c >= : Date.valueOf(startDate) and Company_Signed_Date__c <= : Date.valueOf(endDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) and Company_Signed_Date__c >= : Date.valueOf(startDate) and Company_Signed_Date__c <= : Date.valueOf(endDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }                                            
                                    }
                                else if(startDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc'  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart and Contract_Type__c =: contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc'  ;
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                                 
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) and Company_Signed_Date__c >= : Date.valueOf(startDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                            //    mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) and Company_Signed_Date__c >= : Date.valueOf(startDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );

       
                                            }
                                    }
                                else if(endDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                                
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) and Company_Signed_Date__c <= : Date.valueOf(endDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) and Company_Signed_Date__c <= : Date.valueOf(endDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c <= : dataPeriodEnd order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c <= : dataPeriodEnd and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }
                                    }    
                                else
                                    {
                                         if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus   and Contract_Type__c IN : contractType  order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus   and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId)  order by Contract_Start_Date__c desc,Name asc '  ;
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) order by Contract_Start_Date__c desc,Name asc]);

                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );

                                
                                            }
                                    }
                                
                            }
                        else
                            {
                                if(startDate != 'null' && endDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and  Company_Signed_Date__c >= : dataPeriodStart  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and  Company_Signed_Date__c >= : dataPeriodStart  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                                listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                              
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : Date.valueOf(startDate) and Company_Signed_Date__c <= : Date.valueOf(endDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : Date.valueOf(startDate) and Company_Signed_Date__c <= : Date.valueOf(endDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }
                                    }
                                else if(startDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and  Company_Signed_Date__c >= : dataPeriodStart    and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and  Company_Signed_Date__c >= : dataPeriodStart    and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                              
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : Date.valueOf(startDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : Date.valueOf(startDate)  order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : dataPeriodStart  order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : dataPeriodStart and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by  Contract_Start_Date__c desc,Name asc';
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                             }
                                    }
                                else if(endDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                              
                                              listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                               
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c <= : Date.valueOf(endDate) and Contract_Type__c =: contractType  order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c <= : Date.valueOf(endDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c <= : dataPeriodEnd order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c <= : dataPeriodEnd and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                                
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }
                                    }
                                else
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId   and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId   and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                               
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                               
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId  order by Contract_Start_Date__c desc,Name asc]);
                                                 //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId  order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId  and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                               
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }
                                    }
                            }
                    }
                else
                    {
                        if(contractStatus != 'All')
                            {
                                if(startDate != 'null' && endDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r  order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus  and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType  order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r  order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus  and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                              
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                               
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus)and Company_Signed_Date__c >= : Date.valueOf(startDate) and Company_Signed_Date__c <= : Date.valueOf(endDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                              //  mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus)and Company_Signed_Date__c >= : Date.valueOf(startDate) and Company_Signed_Date__c <= : Date.valueOf(endDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }
                                            
                                    }
                                else if(startDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and  Company_Signed_Date__c >= : dataPeriodStart  and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and  Company_Signed_Date__c >= : dataPeriodStart  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                               
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree ); 
                                           
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus)and Company_Signed_Date__c >= : Date.valueOf(startDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus)and Company_Signed_Date__c >= : Date.valueOf(startDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c >= : dataPeriodStart and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                               
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }        
                                    }
                                else if(endDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType  order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                              
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree ); 
                                         
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus)and Company_Signed_Date__c <= : Date.valueOf(endDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                              //  mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus)and Company_Signed_Date__c <= : Date.valueOf(endDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c <= : dataPeriodEnd order by Contract_Start_Date__c desc,Name asc'; 
                                              
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and Company_Signed_Date__c <= : dataPeriodEnd and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc'; 
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }
                                    }
                                else
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               // query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus   and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc'  ;
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus   and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc'  ;
                                                
                                              //String query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId and Active__c =:conStatus  and Company_Signed_Date__c >= : dataPeriodStart  and Contract_Type__c IN : contractType '  ;
                                             
                                                listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );              
                                            
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:Boolean.valueOf(contractStatus) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Active__c =:conStatus and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                               
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                           
                                            }
                                    }
                                    
                            }
                        else    
                            {
                                if(startDate != 'null' && endDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r  order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId  and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc '  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r  order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId  and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '  ;
                                               
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                               
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : Date.valueOf(startDate) and Company_Signed_Date__c <= : Date.valueOf(endDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : Date.valueOf(startDate) and Company_Signed_Date__c <= : Date.valueOf(endDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : dataPeriodStart and Company_Signed_Date__c <= : dataPeriodEnd and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                                
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                           }
                                    }
                                else if(startDate != 'null' )
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId  and  Company_Signed_Date__c >= : dataPeriodStart  and Contract_Type__c IN : contractType  order by Contract_Start_Date__c desc,Name asc '   ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId  and  Company_Signed_Date__c >= : dataPeriodStart  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '   ;
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree ); 
                                           
                                              //  mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : Date.valueOf(startDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                              //  mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : Date.valueOf(startDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : dataPeriodStart  order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c >= : dataPeriodStart and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                               
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                          }
                                    }
                                else if(endDate != 'null')
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType  order by Contract_Start_Date__c desc,Name asc '   ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId  and Company_Signed_Date__c <= : dataPeriodEnd  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc '   ;
                                              
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree ); 
                                         
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c <= : Date.valueOf(endDate) and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                            }
                                        else
                                            {
                                               // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c <= : Date.valueOf(endDate) order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                                //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c <= : dataPeriodEnd order by Contract_Start_Date__c desc,Name asc';
                                                query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Company_Signed_Date__c <= : dataPeriodEnd and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc';
                                               
                                                listAgree =  database.query(query);
                                                mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }
                                    }
                                else 
                                    {
                                        if(contractType != null && contractType.size()>0 && contractType.get(0)!= 'All')
                                            {
                                                 // mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and Contract_Type__c =: contractType order by Contract_Start_Date__c desc,Name asc]);
                                              
                                              
                                               //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                               //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
                                               //query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId  and Contract_Type__c IN : contractType order by Contract_Start_Date__c desc,Name asc'  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc  ) From Agreement__c where Account__c =: accountId  and Contract_Type__c IN : contractType and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc'  ;
                                                listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                             }
                                        else
                                            {
                                              //  mapAgreementData = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId order by Contract_Start_Date__c desc,Name asc]);
                                                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                                                //UPDATED by Sweta :: Date:08/05/2015 Details:Issue-7084 ::addedRecord type check
						// query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId  order by Contract_Start_Date__c desc,Name asc'  ;
                                               query = 'Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c,  (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc) From Agreement__c where Account__c =: accountId and (RecordTypeID=:JPAggRecordTypeId OR RecordTypeID=:JPMasterRecordTypeId) order by Contract_Start_Date__c desc,Name asc'  ;
                                              
                                               listAgree =  database.query(query);
                                               mapAgreementData = new Map<id,Agreement__c>(listAgree );
                                            }
                                    }
                            }
                    }
                  
              // lstAgreementData = mapAgreementData.values();
                lstAgreementData.addAll(listAgree);
                UpdateParentAgreement(lstAgreementData, mapAgreementData.keySet(),accountId);

                mapAgreementList =  new map<id,Agreement__c>();
                mapParentChildDetails = new Map<Id,List<Agreement__c>>();
                lstChartDataWrapper = new List<ChartHierarchyDataWrapper>();
                for(Agreement__c  objAgr : lstAgreementData )
                    {
                        mapAgreementList.put(objAgr.id,objAgr);
                        if(ProductId != '')
                            {
                                if(!mapParentChildDetails.containsKey(objAgr.id))
                                    {
                                        mapParentChildDetails.put(objAgr.id,new List<Agreement__c>());
                                    }
                                    
                                if(objAgr.Parent_Agreement__c != null)
                                    {
                                        if(!mapParentChildDetails.containsKey(objAgr.Parent_Agreement__c))
                                            {
                                                List<Agreement__c> lstTemp = new List<Agreement__c>();
                                                lstTemp.Add(objAgr);
                                                mapParentChildDetails.put(objAgr.Parent_Agreement__c,lstTemp);
                                            }
                                        else
                                            {
                                                List<Agreement__c> lstTemp = new List<Agreement__c>();
                                                if(mapParentChildDetails.containsKey(objAgr.Parent_Agreement__c))
                                                    {
                                                        lstTemp = mapParentChildDetails.get(objAgr.Parent_Agreement__c);
                                                        lstTemp.Add(objAgr);
                                                    }
                                                mapParentChildDetails.put(objAgr.Parent_Agreement__c,lstTemp);
                                            }
                                    }
                                Map<Id,List<Agreement__c>> mapParentChildDetailsTemp = new Map<Id,List<Agreement__c>>();
                                mapParentChildDetailsTemp  = mapParentChildDetails.clone();
                                
                                for(Id aggrId : mapParentChildDetailsTemp.keyset())
                                    {
                                    
                                        List<Agreement__c> lstAgreements = new List<Agreement__c>();
                                        lstAgreements =  mapParentChildDetailsTemp.get(aggrId);
                                        
                                        if(lstAgreements.size() == 0  && mapAgreementList.get(aggrId).AgreementLineItems__r.size() == 0)
                                         {
                                            mapParentChildDetails.remove(aggrId);
                                         }
                                         
                                    }
                                mapParentChildDetailsTemp  = mapParentChildDetails.clone();    
                                for(Id aggrId : mapParentChildDetailsTemp.keyset())
                                    {
                                    
                                        List<Agreement__c> lstAgreements = new List<Agreement__c>();
                                        List<Agreement__c> lstAgreementTemp = new List<Agreement__c>();
                                        lstAgreements =  mapParentChildDetails.get(aggrId);
                                        lstAgreementTemp = lstAgreements.clone();
                                        integer lstCounter = 0;
                                        for(Agreement__c objAggr : lstAgreements )
                                            {
                                                lstCounter ++;
                                                if(!mapParentChildDetailsTemp.containsKey(objAggr.id))
                                                    {
                                                         lstAgreementTemp.remove(lstCounter-1);
                                                         lstCounter --;
                                                    }
                                             }
                                         if(mapAgreementList.containsKey(aggrId))
                                             {
                                                 if(lstAgreementTemp.size() == 0 && mapAgreementList.get(aggrId).AgreementLineItems__r.size() == 0)
                                                     {
                                                        mapParentChildDetails.remove(aggrId);
                                                     }
                                                 else
                                                     {
                                                         mapParentChildDetails.put(aggrId,lstAgreementTemp );
                                                     }
                                             }
                                    }    
                            }
                        else
                            {
                                if(!mapParentChildDetails.containsKey(objAgr.id))
                                    {
                                        mapParentChildDetails.put(objAgr.id,new List<Agreement__c>());
                                    }
                                    
                                if(objAgr.Parent_Agreement__c != null)
                                    {
                                        if(!mapParentChildDetails.containsKey(objAgr.Parent_Agreement__c ))
                                            {
                                                List<Agreement__c> lstTemp = new List<Agreement__c>();
                                                lstTemp.Add(objAgr);
                                                mapParentChildDetails.put(objAgr.Parent_Agreement__c,lstTemp);
                                            }
                                        else
                                            {
                                                List<Agreement__c> lstTemp = new List<Agreement__c>();
                                                        
                                                if(mapParentChildDetails.containsKey(objAgr.Parent_Agreement__c))
                                                    {
                                                        lstTemp = mapParentChildDetails.get(objAgr.Parent_Agreement__c);
                                                        lstTemp.Add(objAgr);
                                                              
                                                    }
                                                mapParentChildDetails.put(objAgr.Parent_Agreement__c,lstTemp);  
                                            }
                                    }
                            }
                    }   

                GenerateHierarchy(mapParentChildDetails,lstAgreementData);
                if(lstChartDataWrapper.size() > 0 )
                    {
                        showDataBlock = true;
                    }
            }
        
        //function to set the parent in case the immediate parent is not part of search results
        public void UpdateParentAgreement(List<Agreement__c> lstAgreements, set<Id> setFilteredAgreementIds, string accountId)
            {
                //Updated By Rakesh : 1 Nov 2013 : ER-530 ::  Add Attach_Number__c (Agrement Line Item Level field) field to SOQL
                Map<id,Agreement__c> mapAllAgreements = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId order by Contract_Start_Date__c desc,Name asc]);//getAllAgreementsWithoutFilter();
                for(Agreement__c objAgr : lstAgreements)
                    {
                        objAgr.Parent_Agreement__c = getParent(objAgr,setFilteredAgreementIds,mapAllAgreements);
                    }
            }
          
        public Id getParent(Agreement__c objAgreement, set<Id> setFilteredAgreementIds, Map<id,Agreement__c> mapAllAgreements)
            {
                
               /* Updated By :Ranu Jain,Date : 5/30/2012
               *  Detail : Null Check for objAgreement 
               */
                if(objAgreement != null && objAgreement.Parent_Agreement__c != null)
                    {
                        if(setFilteredAgreementIds.contains(objAgreement.Parent_Agreement__c))
                            {
                               return objAgreement.Parent_Agreement__c;
                            }
                        else
                            {
                               return getParent(mapAllAgreements.get(objAgreement.Parent_Agreement__c),setFilteredAgreementIds,mapAllAgreements);
                            }
                    }
                else
                    {
                        return null;
                    }
            }
            
        //Identify the root nodes and generate the child records hierarchy recursively    
        public void GenerateHierarchy(Map<Id,List<Agreement__c>> mapData, List<Agreement__c> lstAgreementData)
            {
                lastNodeSet =  new set<id>();
                lstChartDataWrapper = new List<ChartHierarchyDataWrapper>();
                for(Agreement__c  objAgr : lstAgreementData)
                    { 
                        if(mapAgreementList.containsKey(objAgr.id) && mapData.containsKey(objAgr.id))
                            {
                                Agreement__c objAggrement = mapAgreementList.get(objAgr.id);
                                if(objAggrement.Parent_Agreement__c == null)
                                    {
                                        GetChildRecords(objAggrement.id,0,mapData,0,'',true);            
                                    }
                                /*else if(!mapAgreementList.containsKey(objAgr.Parent_Agreement__c))
                                    {
                                        GetChildRecords(objAggrement.id,0,mapData,0,'',true);
                                    }
                                */
                            }
                     }
            }   
        
        //function to get the child records hierarchy
        public void GetChildRecords(Id agreementId,integer count,Map<Id,List<Agreement__c>> mapData, integer sibCount,string tdString,boolean flag)
            {
                string prevString = '';
                count++;
                lstChartDataWrapper.add(new ChartHierarchyDataWrapper(mapAgreementList.get(agreementId),count,mapData,lastNodeSet,sibCount,tdString));
                tdString = tdString + '<td> </td>';
                integer siblingCount = 0;
                //Updated by Sandeep Singhal :Details:ER-0029 Date:04/15/2015 ::border-left-style:ridge; TOborder-left-style:solid;
                //string prevTdString = tdString.replace('border-top-width:3px;border-top-style:ridge;border-top-color:black','');
                string prevTdString = tdString.replace('border-top-width:3px;border-top-style:solid;border-top-color:black','');
                //Updated by Sandeep Singhal :Details:ER-0029 Date:04/15/2015 ::border-left-style:ridge; TOborder-left-style:solid;
                //prevTdString = prevTdString.replace('border-left-style:ridge;border-left-width:3px;border-left-color:black;','');
                prevTdString = prevTdString.replace('border-left-style:solid;border-left-width:3px;border-left-color:black;','');
                string temp ='';
                
                
                if(mapParentChildDetails.containsKey(agreementId) && mapParentChildDetails.get(agreementId) != null && mapParentChildDetails.get(agreementId).size() > 0 )
                    {    
                        //tdString = prevTdString + '<td style=\'border-left-width:3px;border-left-style:ridge;border-left-color:black;border-top-width:3px;border-top-style:ridge;border-top-color:black\'> </td>';
                        //Updated by Sandeep Singhal Details-0029 date:04/15/2015
                        //tdString = prevTdString + '<td style=\'border-left-width:3px;border-left-style:ridge;border-left-color:black;\'><table cellspacing=\'0\' cellpadding=\'0\' width=\'100%\'><tr><td colspan=\'2\'> </br></br></td></tr><tr><td colspan=\'2\' style=\'border-top-width:3px;border-top-style:ridge;border-top-color:black;\'> </br></br></br></br></br></br></td></tr></table></td>';
                        tdString = prevTdString + '<td style=\'border-left-width:3px;border-left-style:solid;border-left-color:black;\'><table cellspacing=\'0\' cellpadding=\'0\' width=\'100%\'><tr><td colspan=\'2\'> </br></br></br></br></td></tr><tr><td colspan=\'2\' style=\'border-top-width:3px;border-top-style:solid;border-top-color:black;\'> </br></br></br></td></tr></table></td>';
                    }
                    

                 if(mapParentChildDetails.containsKey(agreementId))  {
                for(Agreement__c objAgreement : mapParentChildDetails.get(agreementId))
                    {
                        siblingCount =siblingCount +1;
                        if(mapParentChildDetails.get(agreementId).size() ==1)
                            {
                                //tdString = prevTdString + '<td style=\'border-top-width:3px;border-top-style:ridge;border-top-color:black\'> </td>' ;
                                //Updated by Sandeep Singhal Details-0029 date:04/15/2015
                                //tdString = prevTdString + '<td ><table cellspacing=\'0\' cellpadding=\'0\' width=\'100%\'><tr><td style=\'border-left-style:ridge;border-left-width:3px;border-left-color:black;\'> </br></br></td></tr><tr><td colspan=\'2\' style=\'border-top-width:3px;border-top-style:ridge;border-top-color:black;\'> </td></tr></table></td>' ;
                                tdString = prevTdString + '<td ><table cellspacing=\'0\' cellpadding=\'0\' width=\'100%\'><tr><td style=\'border-left-style:solid;border-left-width:3px;border-left-color:black;\'> </br></br></br></br></td></tr><tr><td colspan=\'2\' style=\'border-top-width:3px;border-top-style:solid;border-top-color:black;\'> </td></tr></table></td>' ;
                            }
                                              
                        getChildRecords(objAgreement.Id,count,mapParentChildDetails,siblingCount,tdString ,true);
                        if(mapParentChildDetails.get(agreementId).size()-1 == siblingCount )
                            {
                                //tdString = prevTdString + '<td style=\'border-top-width:3px;border-top-style:ridge;border-top-color:black\'> </td>' ;
                                //Updated by Sandeep Singhal Details-0029 date:04/15/2015
                                //tdString = prevTdString + '<td ><table cellspacing=\'0\' cellpadding=\'0\' width=\'100%\'><tr><td style=\'border-left-style:ridge;border-left-width:3px;border-left-color:black;\'> </br></br></td></tr><tr><td colspan=\'2\' style=\'border-top-width:3px;border-top-style:ridge;border-top-color:black;\'> </br></br></br></br></td></tr></table></td>' ;
                                tdString = prevTdString + '<td ><table cellspacing=\'0\' cellpadding=\'0\' width=\'100%\'><tr><td style=\'border-left-style:solid;border-left-width:3px;border-left-color:black;\'> </br></br></br></br></td></tr><tr><td colspan=\'2\' style=\'border-top-width:3px;border-top-style:solid;border-top-color:black;\'> </br></br></br></br></td></tr></table></td>' ;
                            }
                    }

                 } 
            } 
        
        //wrapper class for agreement nodes   
        public class ChartHierarchyDataWrapper
            {
                public String AgreementName {get;set;}
                public String AgreementStatus {get;set;}
                public String AttachNumber {get;set;}
                public String ContractType {get;set;}
                public String AgreementTerm {get;set;}
                public String AgreementId {get;set;}
                public boolean hasChild {get;set;}
                public string tdStringData {get;set;}
                public string tdProductString {get;set;}
                public string AgreementNumber {get;set;}
                public date AgreementStartDate {get;set;}
                public string status {get;set;}
                public string bgColor {get;set;}
                public List<ChartLineItemDataWrapper> lstItems {get;set;} 
                public boolean IsLastNode{get;set;}
                public boolean hasParent {get;set;}
                public string ISOCode {get;set;}
                public Agreement__c objAgr{get;set;}
                
                public ChartHierarchyDataWrapper(Agreement__c objAgreement, integer count,Map<Id,List<Agreement__c>> mapData,set<ID> lastNodeSet,integer sibCount,string tdString)
                    {
                        tdStringData = '';
                        tdProductString ='';
                        lstItems = new List<ChartLineItemDataWrapper>();
                        Contract_Management_Setting__c contractSettings = Contract_Management_Setting__c.getInstance();
                        bgColor = contractSettings.Default_Node_Color__c; 
                        AgreementName = objAgreement.name;
                        AgreementId = objAgreement.id;
                        objAgr = new Agreement__c();
                        objAgr = objAgreement;
                        AgreementStatus = objAgreement.Status_Category__c;
                        AttachNumber = objAgreement.Attach_Number__c;
                        ContractType = objAgreement.Contract_Type__c;
                        AgreementTerm = objAgreement.Agreement_Term__c;
                        AgreementNumber = objAgreement.FF_Agreement_Number__c;
                        AgreementStartDate = objAgreement.Contract_Start_Date__c;
                        hasParent = true;
                        if(objAgreement.Total_Contract_Value__c != null)
                            {
                                ISOCode = objAgr.CurrencyISOCode;
                            }
                        else
                            {
                                ISOCode = '';
                            }
                            
                        if(objAgreement.Active__c)
                            {
                                status = 'Active';
                            }
                        else
                            {
                                status = 'InActive';
                            }
                        
                        // set the bg color of the agreement nodes
                        if(objAgreement.Contract_Type__c == 'Memorandum' || objAgreement.Contract_Type__c == 'Agreement' || objAgreement.Contract_Type__c == 'Order Form')
                            {
                                bgColor = contractSettings.Case1_Node_Color__c;
                            }
                        else if(objAgreement.Contract_Type__c == 'Third party access agreement' || objAgreement.Contract_Type__c == 'Co-promotion agreement' || objAgreement.Contract_Type__c == 'Non Disclosure Agreement' || objAgreement.Contract_Type__c == 'Personal information protection agreement' || objAgreement.Contract_Type__c == 'Other')
                            {
                                bgColor = contractSettings.Case2_Node_Color__c;
                            }
                        else if(objAgreement.Contract_Type__c == 'Information Service Agreement' || objAgreement.Contract_Type__c == 'Master Agreement of Consulting' || objAgreement.Contract_Type__c == 'Master Agreement of Services')
                            {
                                bgColor = contractSettings.Case3_Node_Color__c;
                            }
                        IsLastNode = false;
                        hasChild = false;
                        
                        if(mapData.containsKey(objAgreement.Parent_Agreement__c))
                            {
                                if(mapData.get(objAgreement.Parent_Agreement__c).size() == sibCount)
                                    {
                                       IsLastNode = true;
                                       lastNodeSet.add(objAgreement.id);
                                    }
                            }
                            
                        if(mapData.containsKey(objAgreement.id))
                            {
                                if(mapData.get(objAgreement.id).size() > 0)
                                    {
                                        hasChild = true;
                                    }
                            }
                        
                        if(objAgreement.Parent_Agreement__c == null)
                            {
                                tdStringData = tdString+ '<td> </td>';  
                                hasParent = false ;
                            }
                        else
                            {
                                //tdStringData = tdString+ '<td style=\'border-top-width:3px;border-top-style:ridge;border-top-color:black\'> </td>'; 
                                //Commented by Sandeep Singhal Details:ER-0029 Date:15/04/2015  
                                //tdStringData = tdString+ '<td ><table cellspacing=\'0\' cellpadding=\'0\' width=\'100%\'><tr><td> </br></br></td></tr><tr><td colspan=\'2\' style=\'border-top-width:3px;border-top-style:ridge;border-top-color:black\'> </td></tr></table></td>';
                                //Added by Sandeep Singhal Details:ER-0029 Date:15/04/2015  
                                tdStringData = tdString+ '<td ><table cellspacing=\'0\' cellpadding=\'0\' width=\'100%\'><tr><td> </br></br></br></br></td></tr><tr><td colspan=\'2\' style=\'border-top-width:3px;border-top-style:solid;border-top-color:black\'> </td></tr></table></td>';
                            }
                        // Updated by Sandeep Singhal :Details:ER-0029 Date:15/04/2015 ::border-left-style:ridge; TOborder-left-style:solid;
                        //tdProductString  = tdStringData.replace('border-top-width:3px;border-top-style:ridge;border-top-color:black','');
                        tdProductString  = tdStringData.replace('border-top-width:3px;border-top-style:solid;border-top-color:black','');
                        // Updated by sweta :Details:ER-0029 Date:15/04/2015 ::border-left-style:ridge; TOborder-left-style:solid;
                        //tdProductString  = tdProductString.replace('border-left-style:ridge;border-left-width:3px;border-left-color:black','');
                        tdProductString  = tdProductString.replace('border-left-style:solid;border-left-width:3px;border-left-color:black','');
                        for(Agreement_Line_Item__c objLI: objAgreement.AgreementLineItems__r)
                            {
                                lstItems.add(new ChartLineItemDataWrapper(objLI));
                            }
                        
                        if(lstItems.size() > 0)
                            {
                                lstItems[objAgreement.AgreementLineItems__r.size() - 1].IsLastNode = true;
                            }
                    }
            }
            
        //wrapper class for product nodes
        public class ChartLineItemDataWrapper
            {
                public string LineItemId {get;set;}
                public string ProductName {get;set;}
                public Agreement_Line_Item__c objALI{get;set;} 
                public Date ContractEndDate {get;set;}
                public Date terminationDate {get;set;}
                public boolean IsLastNode {get;set;}
                public string ISOCode {get;set;}
                public integer NetPrice {get;set;}
                public boolean isActive {get;set;}
                
                //Added By Rakesh : 1 Nov 2013 : ER-530
                public string attachNumber {get; set;}
                
                public ChartLineItemDataWrapper(Agreement_Line_Item__c objLI)
                    {
                        isActive = false;
                        LineItemId = objLI.id;
                        ProductName = objLI.ProductId__r.Name;
                        ContractEndDate = objLI.Contract_End_Date__c;
                        terminationDate = objLI.Termination_Date__c;
                        objALI = objLI;
                        NetPrice = Integer.valueOf(objLI.Net_Price__c);
                        
                        //Added By Rakesh : 1 Nov 2013 : ER-530
                        if(!string.isBlank(objLI.Attach_Number__c))
                        {
                        	attachNumber = objLI.Attach_Number__c;
                        } else
                        {
                        	attachNumber = '';
                        }
                        //**** End : ER-530 *****
                        
                        //Note - Now we are not using contract Start date
                        /*if((objLI.Contract_End_Date__c == null && objLI.Contract_Start_Date__c == null) || (objLI.Contract_End_Date__c >= Date.today() && objLI.Contract_Start_Date__c == null) || (objLI.Contract_End_Date__c == null && objLI.Contract_Start_Date__c >= Date.today()) || (objLI.Contract_End_Date__c >= Date.today() && objLI.Contract_Start_Date__c >= Date.today()))
                            {
                                isActive = true;
                            }
                        */
                        //Updated By : Ranu Jain,Date : 27th Sep,Detail : ER-0103
                        /*
                        if(objLI.Contract_End_Date__c == null || objLI.Contract_End_Date__c >= Date.today())
                            {
                                isActive = true;
                            }  */
                        if( (objLI.Termination_Date__c == null && objLI.Contract_End_Date__c == null) || (objLI.Termination_Date__c == null && objLI.Contract_End_Date__c >= Date.today() )) {
                           isActive = true;  
                        } else if( objLI.Termination_Date__c != null && objLI.Termination_Date__c >= Date.today() ) {
                          isActive = true;        
                        }
                        //End ER-0103
                            
                        if(objLI.Net_Price__c != null)
                            {
                                ISOCode = objLI.CurrencyISOCode;
                            }
                        else
                            {
                                ISOCode = '';
                            }
                        IsLastNode = false;
                    }
            }
   }