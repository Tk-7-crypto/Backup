/*********************************************************************************************************************************
* Created  By  : Sneha Rathi
* Created Date : 6th June 2012
* Last Modified By  :Ekta Sharma
* Detail       : This class is basically used for AgreementLocator Page to diaplay Agreement /Agreement Line item Level(if any)  
                 In this class transient variable is used for reduce view state size.
* against input filter criteria 
**********************************************************************************************************************************/
public class AgreementLocatorController {
    
    /**--- Properties dclaration/definition ---**/
    
    //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    /********************start*******************/
    public Integer recordNum{get;set;}
    transient Map<String,Sobject> accToAggMap;
    transient List<String> accName;
    transient public List<AgreementWrapper> aggWrapperList{get;set;}
    public Integer totalAgreement{get;set;}
    public Integer pageNum{get;set;}
    public Integer totalPageNum{get;set;}
    /********************End*******************/
 
    public string quickSearchby{get; set;}
    public string quickSearchByStr{get; set;}
    public String atcCodeStr{get;set;}
    public string timeFrame{get; set;}
    public string contractType{get; set;}
    public string agreementTerm{get; set;}
    public string active{get; set;}    
    public  string excelactive{get; set;}
    public String excelATCode{get; set;}
   //Updated By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    //public String hiddenvalue{get;set;}
    public  string exceltimeFrame{get; set;}
    public string excelcontractType{get; set;}
    public string excelagreementTerm{get; set;}
    public string excelquickSearchby{get; set;}
    public  string excelquickSearchByStr{get; set;}
   
    //public Agreement__c filterDateValuesAgreement{get; set;}
    public Integer currentYear{get; set;}
    public  date excelStartDate{get; set;}
    public date excelEndDate{get; set;}
    public Date dataPeriodStart{get;set;}
    public Date dataPeriodEnd{get;set;}
    public Integer totalNoofResults {get;set;}
    
    
    private Id atcRecordTypeID ; // this contains id for record type 'ATC' on ATC__c object
    private String modifySearchString ;
    
    private static final String SRIPT_STATEMENT_ERROR = Label.Refine_Criteria_Message;
    private static final String WILD_CHAR_ENTER_MSG = Label.WILD_CHAR_ENTER_MSG;

	//Added By Rakesh : 30 Oct 2013 :: ER-530
	public string attachNumber {get; set;}
	public string excelAttachNumber {get; set;}
	//Added By Rakesh : 11 Nov 2013 : Issue-3111, 3112, 3113
	private string modifiedAttachNumber ;
	//******* End : ER-530 *******

    /**-Filter Criteria: Account Name /Opp Name /Agreement No etc--**/
    public List<SelectOption> getLstQuickSearchBy() 
    {
        List<SelectOption> lstQuicSrchBy = new List<SelectOption>();
        lstQuicSrchBy.add(new SelectOption('None',Label.Please_Select));
        lstQuicSrchBy.add(new SelectOption('Opportunity Number', Label.Opportunity_Number));
        lstQuicSrchBy.add(new SelectOption('Account Name', Label.Account_Name));
        lstQuicSrchBy.add(new SelectOption ('Account Local Name',Label.Account_Local_Name));
        lstQuicSrchBy.add(new SelectOption('Agreement Number',Label.Agreement_Number));
        lstQuicSrchBy.add(new SelectOption('Product Name', Label.Product_Name));
       
        return lstQuicSrchBy;
    }
    
    /**-Filter Criteria: Time-Period--**/
    public List<SelectOption> getLstTimeFrame()
    {
        List<SelectOption> lstTmFrm = new List<SelectOption>();
        lstTmFrm.add(new SelectOption('None', Label.Please_Select));
        lstTmFrm.add(new SelectOption('Agreement Start Date', Label.Agreement_Start_Date));
        lstTmFrm.add(new SelectOption('Agreement End Date', Label.Agreement_End_Date));
        lstTmFrm.add(new SelectOption('Signed Date', Label.Signed_Date));
        lstTmFrm.add(new SelectOption('Data Period Start (Product)', Label.Data_Period_Start_Product));
        lstTmFrm.add(new SelectOption('Data Period End (Product)', Label.Data_Period_End_Product));
        lstTmFrm.add(new SelectOption('Data Period Start (ATC)',Label.Data_Period_Start_ATC));
        lstTmFrm.add(new SelectOption('Data Period End (ATC)', Label.Data_Period_End_ATC));
        return lstTmFrm;
    }
    
    /**-Filter Criteria : Agreement/Contract Type--**/
    public List<SelectOption> getLstContractType()
    {
        List<SelectOption> options = new List<SelectOption>();   
        Schema.DescribeFieldResult fieldResult = Agreement__c.Contract_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();   
        options.add(new SelectOption('None', Label.Please_Select));  
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }   
    
    /**-Filter Criteria : Agreement/Contract Term--**/
    public List<SelectOption> getLstAgreementTerm()
    {
        List<SelectOption> options = new List<SelectOption>();   
        Schema.DescribeFieldResult fieldResult = Agreement__c.Agreement_Term__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();   
        options.add(new SelectOption('None', Label.Please_Select));  
        for( Schema.PicklistEntry f : ple)
        {
        	//Update By Dhruv : Er 1068 : date-5/2/2015
        	if(f.getLabel()!='Renewal')
        	{
            options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            //Ended By Dhruv : Er 1068 : date-5/2/2015
        }       
        return options;
    }
    
    
    /**-Filter Criteria : whether Agreement is active or not--**/
    public List<SelectOption> getLstActive()
    {
        List<SelectOption> options = new List<SelectOption>();   
        options.add(new SelectOption('None', Label.Please_Select)); 
        options.add(new SelectOption('Active', Label.Active)); 
        options.add(new SelectOption('NotActive', Label.InActive)); 
        return options;
    }
    
    /** Search result on the basis of given time period --**/
    public void timeFrameChanged()
    {
        if(timeFrame == 'None')
        {
            dataPeriodStart = null;
            dataPeriodEnd = null;
        }
        else
        {
            dataPeriodStart = date.newInstance(currentYear, 1, 1);
            dataPeriodEnd = date.newInstance(currentYear, 12, 31);
        }
    } 
    
    /** CONSTRUCTOR --**/
    public AgreementLocatorController()
    {   
        currentYear = System.today().year();
        
        //filterDateValuesAgreement = new Agreement__c();
        //Updated By : Ranu Jain,Date : 19th Aug,Detail : filter records for 'ATC' record type
        atcRecordTypeID = [SELECT Id,Name FROM RecordType WHERE SobjectType='ATC__c' and Name = 'ATC' limit 1].Id;
        resetFilters();
        //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
        recordNum=0;
        pageNum=0;
        totalAgreement = 0;

    }
    
    /** To reset all criterias from the Screen --**/        
    public PageReference resetFilters()
    {  
        PageReference pageRef = ApexPages.currentPage();//new PageReference('/apex/AgreementLocator');//;ApexPages.currentPage();
        pageRef.setRedirect(true);      
        return pageRef; 
    }  
    
    //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    public void applyFilter()
    {
        recordNum=0;  
        totalAgreement = 0;
        displayList();
        if(aggWrapperList != Null && aggWrapperList.size()>0)
           pageNum=1;  
    }
    //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    public void displayList()
    {
       
        search();
        if(accName != Null && accName.size() != 0)
        {
                if(math.mod(totalNoofResults , 10)==0)
                        totalPageNum=totalNoofResults/10;
                else
                       totalPageNum=totalNoofResults/10+1;
                Sobject record;    
                aggWrapperList = new List<AgreementWrapper>(); 
                Integer count=recordNum;
                for(Integer i=recordNum;i<count+10 && i<totalNoofResults;i++)
               {
                     record=accToAggMap.get(accName.get(i));
                     if(record.getsObjectType() == Agreement_Line_Item_ATCs__c.sObjectType)
                    {
                         aggWrapperList.add(new AgreementWrapper((Agreement_Line_Item_ATCs__c)record));
                     }
                  else if(record.getsObjectType() == Agreement_Line_item__c.sObjectType)
                 {
                        aggWrapperList.add(new AgreementWrapper((Agreement_Line_item__c)record));
                  }
                else if(record.getsObjectType() == Agreement__c.sObjectType)
               {
                   aggWrapperList.add(new AgreementWrapper((Agreement__c)record));
                }
           }
        }
    }
    /** Searching Method --**/
    //Updated By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    public void search() 
    {   
        Try{ 
             
             accToAggMap=new Map<String,Sobject>();
             accName=new List<String>();
             String ATCQuery='';
             String agliQuery='';
             String aggQuery='';
             List<Agreement_Line_Item_ATCs__c> atcList=new List<Agreement_Line_Item_ATCs__c>();
             List<Agreement_Line_item__c> agliList=new List<Agreement_Line_item__c>();
             List<Agreement__c> aggList=new List<Agreement__c>();
             Set<Id> aggIdSet=new Set<Id>();
             String accountName;
            
            ATCQuery=ATCLevelQry();
            if(ATCQuery == Null)
                return ;
           
            
            System.debug('****testQuery*****'+ATCQuery);
            atcList = Database.Query(ATCQuery);
               
            If((atcCodeStr == null ||atcCodeStr == '') && timeFrame != 'Data Period Start (ATC)' && timeFrame != 'Data Period End (ATC)' )  
            {            
                agliQuery=AGLILevelQry();
                if(agliQuery== Null)
                return ;
                 System.debug('****testQuery*****'+agliQuery);
                agliList = Database.Query(agliQuery);
                
            }
            
            //Updated By Rakesh : 31 Oct 2013 : ER-530 :: Add string.isblank(attachNumber) check
            //If((atcCodeStr == null ||atcCodeStr == '') && quickSearchby != 'Product Name'&& timeFrame != 'Data Period Start (Product)' && timeFrame != 'Data Period End (Product)' && timeFrame != 'Data Period Start (ATC)'&& timeFrame != 'Data Period End (ATC)')
            If((atcCodeStr == null ||atcCodeStr == '') && quickSearchby != 'Product Name'&& timeFrame != 'Data Period Start (Product)' && timeFrame != 'Data Period End (Product)' && timeFrame != 'Data Period Start (ATC)'&& timeFrame != 'Data Period End (ATC)' && string.isBlank(attachNumber))   
            {
                aggQuery=agreementLevelQry();
                if(aggQuery== Null)
                return ;
                aggList = Database.Query(aggQuery);
            }
            
            
            for(Agreement_Line_Item_ATCs__c atc:atcList)
            {
                accountName = atc.Agreement_Line_Item__r.AgreementId__r.Account__r.Name;
                if(accountName == Null || accountName == '')
                    accountName = ' '+'-'+atc.Agreement_Line_Item__r.AgreementId__c+'-'+atc.Id;
                else
                    accountName = accountName.toLowercase() +'-'+atc.Agreement_Line_Item__r.AgreementId__c+'-'+atc.Id;
                accName.add(accountName);
                accToAggMap.put(accountName,atc);
                aggIdSet.add(atc.Agreement_Line_Item__r.AgreementId__c);
            }
            atcList.clear();
            for(Agreement_Line_item__c agli:agliList)
            {
                accountName = agli.AgreementId__r.Account__r.Name;
                if(accountName == Null || accountName == '')
                    accountName = ' '+'-'+agli.AgreementId__c+'-'+agli.Id;
                else
                    accountName = accountName.toLowercase()+'-'+agli.AgreementId__c+'-'+agli.Id;
                accName.add(accountName);
                accToAggMap.put(accountName,agli);
                aggIdSet.add(agli.AgreementId__c);
            }
            agliList.clear();
            for(Agreement__c agg:aggList)
            {
                accountName = agg.Account__r.Name;
                if(accountName == Null || accountName == '')
                    accountName = ' '+'-'+agg.Id;
                else
                    accountName= accountName.toLowercase()+'-'+agg.Id;
                accName.add(accountName);
                accToAggMap.put(accountName,agg);
                aggIdSet.add(agg.Id);
            }
            aggList.clear();
            accName.sort();
            
            excelquickSearchby      = quickSearchby;
            excelquickSearchByStr   = quickSearchByStr;
            exceltimeFrame          = timeFrame;
            excelcontractType       = contractType; 
            excelagreementTerm      = agreementTerm;
            excelactive             = active;
            excelStartDate          = dataPeriodStart ;
            excelEndDate            = dataPeriodEnd ;
            excelATCode             = atcCodeStr;
            
            //Added by Rakesh : 31 Oct 2013 : ER-530
            excelAttachNumber = attachNumber;
            
            totalAgreement = aggIdSet.size();
            totalNoofResults = accName.size();                
            return ;
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
            return ;
        }    
    }
    //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    private String AGLILevelQry()
    {
        //Updated By Rakesh : 30 Oct 2013 : ER-530 ::  Add Attach_Number__c field to SOQL
        String agliQryStr='Select  Data_Period_Start__c, Data_Period_End__c,AgreementId__r.FF_Agreement_Number__c ,AgreementId__r.Account__r.Name,AgreementId__r.Account__r.NameLocal,ProductId__c, AgreementId__r.Account__c, AgreementId__c, ProductId__r.Name, AgreementId__r.Contract_Type__c, AgreementId__r.Name, AgreementId__r.Attach_Number__c, AgreementId__r.Agreement_Term__c, AgreementId__r.Active__c, AgreementId__r.Related_Opportunity__r.Opportunity_Number__c, AgreementId__r.Related_Opportunity__c ,AgreementId__r.Contract_Start_Date__c ,AgreementId__r.Contract_End_Date__c, AgreementId__r.Company_Signed_Date__c ,AgreementId__r.Other_Party_Signed_Date__c, Attach_Number__c from Agreement_Line_item__c where id NOT IN (Select Agreement_Line_Item__c from Agreement_Line_Item_ATCs__c where ATC__r.RecordTypeId =: atcRecordTypeID)';
        String whereConditionALI='';
            if(quickSearchby != 'None' && quickSearchByStr.trim() !='')
            {   
              // wild char handling for "QuichSearch By" , Updated By :Ranu Jain , Date : 12th July
              if(checkForWilChar(quickSearchByStr)) {
                   return null;
              }
              whereConditionALI = whereConditionALI +' and '+ quickSearchQueryCondition();   
            }
             
            /** Searching results on the Basis of given Time period--**/
            if(timeFrame != 'None')
            {
                if(dataPeriodStart == null )
                    dataPeriodStart = date.newInstance(currentYear, 1, 1);
                
                if(dataPeriodEnd == null)
                    dataPeriodEnd = date.newInstance(currentYear, 12, 31);
                
                DateTime startDt = dataPeriodStart;
                String StrtDateStr = startDt.formatGmt('yyyy-MM-dd');
            
                DateTime endDt = dataPeriodEnd;
                String EndDateStr = endDt.formatGmt('yyyy-MM-dd');
               
                whereConditionALI = whereConditionALI  + ' and '+ timeFrameQueryCondition(StrtDateStr, EndDateStr);
                
           }
            
            /** Searching results on the Basis of given Contract Type--**/
            if(contractType != 'None')
            {
                
                whereConditionALI = whereConditionALI  + ' and '+ ' AgreementId__r.Contract_Type__c = \'' + contractType + '\'';
            }
            
            /** Searching results on the Basis of given Agreement Term--**/
            if(agreementTerm != 'None')
            {
                whereConditionALI = whereConditionALI + ' and ' + ' AgreementId__r.Agreement_Term__c = \'' + agreementTerm + '\'';
            }
            
            /** Searching results If Agreement is active or not--**/
            if(active != 'None')
            {
                whereConditionALI = whereConditionALI  + ' and '+ ' AgreementId__r.Active__c = ';
                if(active == 'Active')
                    whereConditionALI += ' true ';
                else
                    whereConditionALI += ' false ';
            }
            
            //********* Added By Rakesh : 30 Oct 2013 :: ER-530  : START***********
	        if(!string.isBlank(attachNumber))
	        {
				//Updated By Rakesh : 11 Nov 2013 : Issue-3111, 3112, 3113
				//whereConditionALI = whereConditionALI+ ' and ' + ' Attach_Number__c = \'' + attachNumber + '\'';
				if(checkForWilChar(attachNumber.trim())) 
	                return null;
	            modifiedAttachNumber =  modifySearchStr(attachNumber);
	            whereConditionALI = whereConditionALI+ ' and ' + ' Attach_Number__c like : modifiedAttachNumber'; 
	            //End : Issue-3111, 3112, 3113     	
	        }
	        //********* End : ER-530  ***********
            
            return agliQryStr+' '+whereConditionALI ;
    }
    /** To add quickSearch criteria(If any ) in query **/ 
    public string quickSearchQueryCondition()
    {
        String str = '';        
        if(quickSearchby == 'Account Local Name')
        {
             str = ' AgreementId__r.Account__r.NameLocal Like \'' + modifySearchStr(quickSearchByStr) +'\'';
        }
        if(quickSearchby == 'Account Name')
        {
             str = ' AgreementId__r.Account__r.Name Like \'' + modifySearchStr(quickSearchByStr) +'\'';
        }
        else if(quickSearchby == 'Opportunity Number')
        {
             str = ' AgreementId__r.Related_Opportunity__r.Opportunity_Number__c Like \'' + modifySearchStr(quickSearchByStr) +'\''; 
        }        
        else if(quickSearchby == 'Product Name')
        {
            str = ' ProductId__r.Name like \'' + modifySearchStr(quickSearchByStr) +'\'';
        }
        else if(quickSearchby == 'Agreement Number')
            str = ' AgreementId__r.FF_Agreement_Number__c like \'%' + modifySearchStr(quickSearchByStr) +'%\'';
        return str;
    }
    /** To add Time Frame criteria(If any ) in query **/
    public string timeFrameQueryCondition(String strtDt, String endDt)
    {
        String str = '';
        if(timeFrame == 'Agreement Start Date')
        {
            str =  ' AgreementId__r.Contract_Start_Date__c >= ' + strtDt + ' and AgreementId__r.Contract_Start_Date__c <= ' + endDt; 
        
        }
        else if(timeFrame == 'Agreement End Date')
        {
            str =  ' AgreementId__r.Contract_End_Date__c >= ' + strtDt + ' and AgreementId__r.Contract_End_Date__c <= ' + endDt;
        }
        else if(timeFrame == 'Signed Date')
        {
            str =  ' AgreementId__r.Company_Signed_Date__c >= ' + strtDt + ' and AgreementId__r.Company_Signed_Date__c <= ' + endDt;
        }
        else if(timeFrame == 'Data Period Start (Product)')
        {
            str = ' Data_Period_Start__c >= '+ strtDt + ' and Data_Period_Start__c <= ' + endDt;
        }
        else if(timeFrame == 'Data Period End (Product)')
        {
            str = ' Data_Period_End__c >= '+ strtDt + ' and Data_Period_End__c <= ' + endDt;
        }
        
        
        return str;
        
    }
       
    /** To Build query for Agreement who does not contain any LineItem  **/
    private String agreementLevelQry()
    {
        
        String agreeQryStr = 'Select Id,FF_Agreement_Number__c, Account__r.Name,Account__r.NameLocal ,Account__c,Contract_Type__c, Name, Attach_Number__c, Agreement_Term__c,Active__c,Related_Opportunity__r.Opportunity_Number__c, Related_Opportunity__c ,Contract_Start_Date__c ,Contract_End_Date__c,Company_Signed_Date__c ,Other_Party_Signed_Date__c  from Agreement__c where Id Not IN (select AgreementId__c from Agreement_Line_item__c)';
        String tempQry = '';
            
        if(quickSearchby != 'None' && quickSearchByStr.trim() !='')
        {    
            if(checkForWilChar(quickSearchByStr)) {
                   return null;
              }
            tempQry = tempQry + quickSearchQueryForAggLevel();            
        }
                
        if(timeFrame != 'None')
        {
            if(dataPeriodStart == null )
                dataPeriodStart = date.newInstance(currentYear, 1, 1);
            
            if(dataPeriodEnd == null)
                dataPeriodEnd = date.newInstance(currentYear, 12, 31);
            
            DateTime startDt = dataPeriodStart;
            String StrtDateStr = startDt.formatGmt('yyyy-MM-dd');
        
            DateTime endDt = dataPeriodEnd;
            String EndDateStr = endDt.formatGmt('yyyy-MM-dd');
            
            String resultfromTimeFrame = timeFrameQueryforAggLevel(StrtDateStr, EndDateStr);
                if(tempQry.trim() != '' && resultfromTimeFrame != ''){
                    tempQry = tempQry + ' and ';
                }
                tempQry = tempQry + resultfromTimeFrame;//timeFrameQueryforAggLevel(StrtDateStr, EndDateStr);                     
        }
        
        if(contractType != 'None')
        {
            if(tempQry.trim() != '')
                    tempQry = tempQry + ' and ';
            tempQry = tempQry + ' Contract_Type__c = \'' + contractType + '\'';
        }
        
        if(agreementTerm != 'None')
        {
            if(tempQry.trim() != '')
                    tempQry = tempQry + ' and ';
            tempQry = tempQry + ' Agreement_Term__c = \'' + agreementTerm + '\'';
        }
        
        if(active != 'None')
        {
            if(tempQry.trim() != '')
                    tempQry = tempQry + ' and ';
            tempQry = tempQry + ' Active__c = ';
            if(active == 'Active')
                tempQry += ' true ';
            else
                tempQry += ' false ';
        }
        If(tempQry.trim() != '')
            agreeQryStr += 'AND'+ tempQry;
        
        return agreeQryStr;
    }
    
    /** To add quickSearch criteria(If any ) in query **/
    private  string quickSearchQueryForAggLevel()
    {
        String str = '';
        if(quickSearchby == 'Account Local Name')
        {
             str = ' Account__r.NameLocal Like \'' + modifySearchStr(quickSearchByStr) +'\'';
        }
        if(quickSearchby == 'Account Name')
        {
             str = ' Account__r.Name Like \'' + modifySearchStr(quickSearchByStr) +'\'';
        }
        else if(quickSearchby == 'Opportunity Number')
        {
             str = ' Related_Opportunity__r.Opportunity_Number__c Like \'' + modifySearchStr(quickSearchByStr) +'\''; 
        }        
        else if(quickSearchby == 'Agreement Number')
            str = ' FF_Agreement_Number__c like \'%' + modifySearchStr(quickSearchByStr) +'%\'';
        
        return str;
    }
    
    /** To add Time Frame criteria(If any ) in query **/
    public string timeFrameQueryforAggLevel(String strtDt, String endDt)
    {
        String str = '';
        if(timeFrame == 'Agreement Start Date')
        {
            str =  ' Contract_Start_Date__c >= ' + strtDt + ' and Contract_Start_Date__c <= ' + endDt; 
        
        }
        else if(timeFrame == 'Agreement End Date')
        {
            str =  ' Contract_End_Date__c >= ' + strtDt + ' and Contract_End_Date__c <= ' + endDt;
        }
        else if(timeFrame == 'Signed Date')
        {
            str =  ' Company_Signed_Date__c >= ' + strtDt + ' and Company_Signed_Date__c <= ' + endDt;
        }        
        return str;
    }
    
     //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967 
     /** To Build query for ATC Market Defination **/
    private String ATCLevelQry()
    { 
     
        //Updated By Rakesh : 30 Oct 2013 : ER-530 ::  Add Agreement_Line_Item__r.Attach_Number__c field to SOQL
        String ATCQryStr = 'Select ATC_Code__c, Data_Period_End__c, Data_Period_Start__c,Agreement_Line_Item__r.ProductId__c,Agreement_Line_Item__r.AgreementId__r.Id,Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c, Agreement_Line_Item__r.AgreementId__r.Account__r.Name,Agreement_Line_Item__r.AgreementId__r.Account__r.NameLocal ,Agreement_Line_Item__r.AgreementId__r.Account__c,Agreement_Line_Item__r.AgreementId__r.Contract_Type__c, Agreement_Line_Item__r.AgreementId__r.Name, Agreement_Line_Item__r.AgreementId__r.Attach_Number__c, Agreement_Line_Item__r.AgreementId__r.Agreement_Term__c,Agreement_Line_Item__r.AgreementId__r.Active__c,Agreement_Line_Item__r.AgreementId__r.Related_Opportunity__r.Opportunity_Number__c, Agreement_Line_Item__r.AgreementId__r.Related_Opportunity__c ,Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c ,Agreement_Line_Item__r.AgreementId__r.Contract_End_Date__c,Agreement_Line_Item__r.AgreementId__r.Company_Signed_Date__c ,Agreement_Line_Item__r.AgreementId__r.Other_Party_Signed_Date__c,Agreement_Line_Item__r.ProductId__r.Name,Agreement_Line_Item__r.Data_Period_Start__c,Agreement_Line_Item__r.Data_Period_End__c, Agreement_Line_Item__r.Attach_Number__c  from Agreement_Line_Item_ATCs__c ';
        String tempQry = ' where ';
            
        if(quickSearchby != 'None' && quickSearchByStr.trim() !='')
        {   
           if(checkForWilChar(quickSearchByStr)) {
                   return null;
              } 
            tempQry = tempQry + quickSearchATCCondition();            
        }
                
        if(timeFrame != 'None')
        {
            if(dataPeriodStart == null )
                dataPeriodStart = date.newInstance(currentYear, 1, 1);
            
            if(dataPeriodEnd == null)
                dataPeriodEnd = date.newInstance(currentYear, 12, 31);
            
            DateTime startDt = dataPeriodStart;
            String StrtDateStr = startDt.formatGmt('yyyy-MM-dd');
        
            DateTime endDt = dataPeriodEnd;
            String EndDateStr = endDt.formatGmt('yyyy-MM-dd');
            
            String resultfromTimeFrame = timeFrameATCCondition(StrtDateStr, EndDateStr);
                if(tempQry.trim() != 'where' && resultfromTimeFrame != ''){
                    tempQry = tempQry + ' and ';
                }
                tempQry = tempQry + resultfromTimeFrame;                    
        }
        
        if(contractType != 'None')
        {
            if(tempQry.trim() != 'where')
                    tempQry = tempQry + ' and ';
            tempQry = tempQry + ' Agreement_Line_Item__r.AgreementId__r.Contract_Type__c = \'' + contractType + '\'';
        }
        
        if(agreementTerm != 'None')
        {
            if(tempQry.trim() != 'where')
                    tempQry = tempQry + ' and ';
            tempQry = tempQry + ' Agreement_Line_Item__r.AgreementId__r.Agreement_Term__c = \'' + agreementTerm + '\'';
        }
        
        if(active != 'None')
        {
            if(tempQry.trim() != 'where')
                    tempQry = tempQry + ' and ';
            tempQry = tempQry + ' Agreement_Line_Item__r.AgreementId__r.Active__c = ';
            if(active == 'Active')
                tempQry += ' true ';
            else
                tempQry += ' false ';
        }
        If(atcCodeStr != null && atcCodeStr != '') 
        {
            if(checkForWilChar(atcCodeStr.trim())) 
            return null;
            modifySearchString =  modifySearchStr(atcCodeStr);
            if(tempQry.trim() != 'where' ){
                    tempQry = tempQry + ' and ';
            }
            tempQry = tempQry +' ATC_Code__c like :modifySearchString ';     
       }
       
       //********* Added By Rakesh : 30 Oct 2013 :: ER-530  : START***********
       if(!string.isBlank(attachNumber))
       {
			//Updated By Rakesh : 11 Nov 2013 : Issue-3111, 3112, 3113
			/*
			if(tempQry.trim() != 'where')
			{
				tempQry = tempQry + ' and ';
			}  
			tempQry = tempQry + ' Agreement_Line_Item__r.Attach_Number__c = \'' + attachNumber + '\'';
			*/
			if(checkForWilChar(attachNumber.trim())) 
                return null;
            modifiedAttachNumber =  modifySearchStr(attachNumber);
            if(tempQry.trim() != 'where' ){
                    tempQry = tempQry + ' and ';
            }
            tempQry = tempQry +' Agreement_Line_Item__r.Attach_Number__c like :modifiedAttachNumber '; 
            //End : Issue-3111, 3112, 3113     	
       }
       //********* End : ER-530  ***********
       
        If(tempQry.trim() != 'where')
            ATCQryStr +=  tempQry +'and ATC__r.RecordTypeId =: atcRecordTypeID  ';
        
        return ATCQryStr ;
    }
     
      //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
     /** To add quickSearch criteria(If any ) in query **/ 
    public string quickSearchATCCondition()
    {
        String str = '';        
        if(quickSearchby == 'Account Local Name')
        {
             str = ' Agreement_Line_Item__r.AgreementId__r.Account__r.NameLocal Like \'' + modifySearchStr(quickSearchByStr) +'\'';
        }
        if(quickSearchby == 'Account Name')
        {
             str = ' Agreement_Line_Item__r.AgreementId__r.Account__r.Name Like \'' + modifySearchStr(quickSearchByStr) +'\'';
        }
        else if(quickSearchby == 'Opportunity Number')
        {
             str = ' Agreement_Line_Item__r.AgreementId__r.Related_Opportunity__r.Opportunity_Number__c Like \'' + modifySearchStr(quickSearchByStr) +'\''; 
        }        
        else if(quickSearchby == 'Product Name')
        {
            str = ' Agreement_Line_Item__r.ProductId__r.Name like \'' + modifySearchStr(quickSearchByStr) +'\'';
        }
        else if(quickSearchby == 'Agreement Number')
            str = ' Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c like \'%' + modifySearchStr(quickSearchByStr) +'%\'';
        return str;
    }
    
     //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    /** To add Time Frame criteria(If any ) in query **/
    public string timeFrameATCCondition(String strtDt, String endDt)
    {
        String str = '';
        if(timeFrame == 'Agreement Start Date')
        {
            str =  ' Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c >= ' + strtDt + ' and Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c <= ' + endDt; 
        
        }
        else if(timeFrame == 'Agreement End Date')
        {
            str =  ' Agreement_Line_Item__r.AgreementId__r.Contract_End_Date__c >= ' + strtDt + ' and Agreement_Line_Item__r.AgreementId__r.Contract_End_Date__c <= ' + endDt;
        }
        else if(timeFrame == 'Signed Date')
        {
            str =  ' Agreement_Line_Item__r.AgreementId__r.Company_Signed_Date__c >= ' + strtDt + ' and Agreement_Line_Item__r.AgreementId__r.Company_Signed_Date__c <= ' + endDt;
        }
        else if(timeFrame == 'Data Period Start (Product)')
        {
            str = ' Agreement_Line_Item__r.Data_Period_Start__c >= '+ strtDt + ' and Agreement_Line_Item__r.Data_Period_Start__c <= ' + endDt;
        }
        else if(timeFrame == 'Data Period End (Product)')
        {
            str = ' Agreement_Line_Item__r.Data_Period_End__c >= '+ strtDt + ' and Agreement_Line_Item__r.Data_Period_End__c <= ' + endDt;
        }
        else if(timeFrame == 'Data Period Start (ATC)')
        {
            str =  ' Data_Period_Start__c >= ' + strtDt + ' and Data_Period_Start__c <= ' + endDt;
        }
        else if(timeFrame == 'Data Period End (ATC)')
        {
            str =  ' Data_Period_End__c >= ' + strtDt + ' and Data_Period_End__c <= ' + endDt;
        }
        
        return str;
        
    }
    
    
    
      /** Method to construct comma seperated strings for the list of options **/
    public String CommaSeperatedvalues(List<ID> lstStr)
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
    
    /** Method to remove all single quotes from Strings **/
    public String modifySearchStr (String searchByString)
    {
        if(searchByString.contains('\''))
            searchByString =string.escapeSingleQuotes(searchByString);
        String modifiedSearchByString = searchByString;
        if(searchByString.contains('*')){
            modifiedSearchByString = searchByString.replace('*', '%');
        }
        return modifiedSearchByString;
    }
    
    /* Method Created By: Ranu Jain, Date : 12th July
    * Detail : this method is created to handle wild char in "Quick Search By" and "ATC Code" Search
    */
    public  boolean checkForWilChar(String searchByString) {
        String charcntString =  searchByString.replaceAll('\\*','');
           charcntString = charcntString.replaceAll('%','');
            if(charcntString.length() <= 0) {
              ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error, WILD_CHAR_ENTER_MSG );
              ApexPages.addMessage(infoMsg);
             // return;     
            return true ;
            }
          return false;
    
    }
    
    //Updated By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    /** TO generate Excel Sheet of Page --**/
    public pageReference ExcelExport()
    {
       
        search();
        Sobject record;    
        aggWrapperList = new List<AgreementWrapper>();
        for(String acc:accName)
        {
            if(aggWrapperList.size()>=999)
            {
                 ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error, SRIPT_STATEMENT_ERROR );
                 ApexPages.addMessage(infoMsg);
                 return null;
            } 
            record=accToAggMap.get(acc);
            if(record.getsObjectType() == Agreement_Line_Item_ATCs__c.sObjectType)
            {
                aggWrapperList.add(new AgreementWrapper((Agreement_Line_Item_ATCs__c)record));
            }
            else if(record.getsObjectType() == Agreement_Line_item__c.sObjectType)
            {
                aggWrapperList.add(new AgreementWrapper((Agreement_Line_item__c)record));
            }
            else if(record.getsObjectType() == Agreement__c.sObjectType)
            {
                aggWrapperList.add(new AgreementWrapper((Agreement__c)record));
            }
        }        

        PageReference retUrl = Page.AgreementLocatorExcel;   
        retUrl.setRedirect(false);
        return retUrl;       
    }
    
    //Updated By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
      /**-----------Wrapper Class------------**/
    public class AgreementWrapper
    {
        transient public Agreement_Line_item__c agreementLI{get; set;}
        transient public Agreement_Line_Item_ATCs__c agreementLIATC{get; set;}
        transient public Agreement__c agreement{get;set;}
        
        //---Agreement Object's fields 
        transient public String agreementAttachNo{get;set;}
        transient public String agreementAccountName {get;set;}
        transient public String agreementAccountId {get;set;}
        transient public String agreeAccLoclName{get;set;}
        transient public String agreementName{get;set;}
        transient public String agreementId{get;set;}             
        transient public String agreementRelatedOppNo{get;set;}       
        transient public String agreeContractType{get;set;}
        transient public String agreementTerm{get;set;}
        transient public boolean agreementISActive{get;set;}
        transient public String agreementRelatedOpportunityId{get;set;}
        transient public Date agreementSTARTDate{get;set;}
        transient public Date agreementENDDate {get;set;}
        transient public Date agreementCmpanySignedDate {get;set;}
        transient public Date agreementOtherPartySignedDate {get;set;}
        
        //---Agreement LineItem's fields 
        transient public String agreementNumber{get;set;}
        transient public String agreeLIProdId{get;set;}
        transient public String agreeLIProdName{get;set;}
        transient public Date agreeLIDataMonthStart {get;set;}
        transient public Date agreeLIDataMonthEnd {get;set;}
        
        //Added By Rakesh : 30 Oct 2013 : ER-530
        transient public String agliAttachNo{get;set;}
        
        //---Agreement LineItem ATC's fields 
        transient public String agreementLIATCcode{get;set;}
        transient public Date agreementLIATCstartDate{get;set;}
        transient public Date agreementLIATCendDate{get;set;}
        
        //-- Wrapper Class COnstructor used when Agreement Line item level Search       
        public agreementWrapper(Agreement_Line_Item_ATCs__c agreeLIATC)
        {
            
            agreementLIATC = agreeLIATC;            
            
            //---Agreement LineItem's fields 
            agreementAccountId            = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Account__c;
            agreementAccountName          = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Account__r.Name;
            agreeAccLoclName              = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Account__r.NameLocal;
            agreementId                   = agreeLIATC.Agreement_Line_Item__r.AgreementId__c;
            agreementName                 = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Name;
            agreementAttachNo             = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Attach_Number__c;            
            agreementRelatedOppNo         = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Related_Opportunity__r.Opportunity_Number__c;
            agreementRelatedOpportunityId = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Related_Opportunity__c;
            agreeContractType             = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Contract_Type__c;
            agreementTerm                 = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Agreement_Term__c;
            agreementISActive             = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Active__c;
            agreementNumber               = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.FF_Agreement_Number__c;
            agreementSTARTDate            = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Contract_Start_Date__c;
            agreementENDDate              = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Contract_End_Date__c ;
            agreementCmpanySignedDate     = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Company_Signed_Date__c;
            agreementOtherPartySignedDate = agreeLIATC.Agreement_Line_Item__r.AgreementId__r.Other_Party_Signed_Date__c;            
            agreeLIProdId                 = agreeLIATC.Agreement_Line_Item__r.ProductId__c;
            agreeLIProdName               = agreeLIATC.Agreement_Line_Item__r.ProductId__r.Name;
            agreeLIDataMonthStart         = agreeLIATC.Agreement_Line_Item__r.Data_Period_Start__c ;
            agreeLIDataMonthEnd           = agreeLIATC.Agreement_Line_Item__r.Data_Period_End__c ;
            
            agreementLIATCcode      = agreeLIATC.ATC_Code__c ;
            agreementLIATCstartDate = agreeLIATC.Data_Period_Start__c;
            agreementLIATCendDate   = agreeLIATC.Data_Period_End__c ;
            
            //Added By Rakesh : 30 Oct 2013 : ER-530
            agliAttachNo = agreeLIATC.Agreement_Line_Item__r.Attach_Number__c;
            
        }        
        //-- Wrapper Class COnstructor used when Agreement Line item level Search When they don't have AgreementLineItemATC to fix [issue #115]--//
        public agreementWrapper(Agreement_Line_item__c agreeLI)
        {
            agreementLI = agreeLI;                       
            
            //---Agreement LineItem's fields 
            agreementAccountId            = agreeLI.AgreementId__r.Account__c;
            agreementAccountName          = agreeLI.AgreementId__r.Account__r.Name;
            agreeAccLoclName              = agreeLI.AgreementId__r.Account__r.NameLocal;
            agreementId                   = agreeLI.AgreementId__c;
            agreementName                 = agreeLI.AgreementId__r.Name;
            agreementAttachNo             = agreeLI.AgreementId__r.Attach_Number__c;            
            agreementRelatedOppNo         = agreeLI.AgreementId__r.Related_Opportunity__r.Opportunity_Number__c;
            agreementRelatedOpportunityId = agreeLI.AgreementId__r.Related_Opportunity__c;
            agreeContractType             = agreeLI.AgreementId__r.Contract_Type__c;
             


            agreementTerm                 = agreeLI.AgreementId__r.Agreement_Term__c; 
            agreementISActive             = agreeLI.AgreementId__r.Active__c;
            agreementNumber               = agreeLI.AgreementId__r.FF_Agreement_Number__c;
            agreementSTARTDate            = agreeLI.AgreementId__r.Contract_Start_Date__c;
            agreementENDDate              = agreeLI.AgreementId__r.Contract_End_Date__c ;
            agreementCmpanySignedDate     = agreeLI.AgreementId__r.Company_Signed_Date__c;
            agreementOtherPartySignedDate = agreeLI.AgreementId__r.Other_Party_Signed_Date__c;            
            agreeLIProdId                 = agreeLI.ProductId__c;
            agreeLIProdName               = agreeLI.ProductId__r.Name;
            agreeLIDataMonthStart         = agreeLI.Data_Period_Start__c ;
            agreeLIDataMonthEnd           = agreeLI.Data_Period_End__c ;
            
            //Added By Rakesh : 30 Oct 2013 : ER-530
            agliAttachNo = agreeLI.Attach_Number__c;
        } 
        
        //-- Wrapper Class COnstructor used when Agreement does not contains Line-items  
        public agreementWrapper(Agreement__c agree)
        {
            //---Agreement Object's fields
            agreement               = agree;
            agreementAccountId      = agree.Account__c;
            agreementAccountName    = agree.Account__r.Name;
            agreeAccLoclName        = agree.Account__r.NameLocal;
            agreementId             = agree.id;
            agreementName           = agree.Name;            
            agreementAttachNo       = agree.Attach_Number__c;
            agreementRelatedOppNo   = agree.Related_Opportunity__r.Opportunity_Number__c;
            agreementRelatedOpportunityId = agree.Related_Opportunity__c;
            agreeContractType       = agree.Contract_Type__c;
            agreementTerm           = agree.Agreement_Term__c;
            agreementISActive       = agree.Active__c;
            agreementNumber         = agree.FF_Agreement_Number__c;
            agreementSTARTDate            = agree.Contract_Start_Date__c;
            agreementENDDate              = agree.Contract_End_Date__c ;
            agreementCmpanySignedDate     = agree.Company_Signed_Date__c;
            agreementOtherPartySignedDate = agree.Other_Party_Signed_Date__c;
            
        }
        
    }
    
    //Added By:-Ekta ,Date-31st May,2013 ,Details:-Issue-00967
    /*************************start****************************/
     public void gotoNextPage()
    {  
        recordNum+=10;
        pageNum++;
        displayList() ;
    }
    public void gotoPreviousPage()
    {
       recordNum-=10; 
       pageNum--;
       displayList() ;
    }
    public void gotoFirstPage()
    {
       recordNum=0; 
       pageNum=0; 
       displayList() ;
    }
    public void gotoLastPage()
    {
       if( math.mod(totalNoofResults , 10) == 0)
           recordNum= totalNoofResults - 10;
       else
           recordNum= totalNoofResults - math.mod(totalNoofResults , 10); 
       pageNum = recordNum/10 + 1;
       displayList() ;
    }
    
     /*************************End****************************/
}