/**
 * @Name : TPA_AllRequestsTTController
 * @Author : Babita Dadarwal
 * @Date : 5 Jan 2016
 * @purpose : Controller for TPA_All_Request_TurnAround_Time_Report page
 */

public class CNT_TPA_AllReqTATReport {

    public String reportHeading {get;set;}
    public Set<String> category{get;set;}
    public Map<String,String> countryToTpAssignedTPProcessorEmail{get;set;}
    public string getCountryToTPProcessorMap(){
        return JSON.serialize(countryToTpAssignedTPProcessorEmail);
    }
    
    public CNT_TPA_AllReqTATReport(){
        String RequestsType = ApexPages.currentPage().getParameters().get('RequestType');
        reportHeading = 'All TPA Requests Turnaround Time Report';
        if(RequestsType.Trim() == 'AMA')
        {
            reportHeading = 'AMA Requests Turnaround Time Report';
        }
        category = new Set<String>();
        category.add('ALL');
        category.add('ALL excluding US');
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Client_Contact_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            category.add(f.getValue());
        }
        

        Map<String,String> countryToTPProcessor = new Map<String,String>();
        countryToTpAssignedTPProcessorEmail = new  Map<String,String>();
        for(TPA_Region_Country__c reagionCountry:[select TP_Processor__c,Country__c, TP_Processor__r.region__c,
                                                TP_Processor__r.TP_Processor_Name__c,
                                                TP_Processor__r.TPA_Processor_Contact__c,
                                                TP_Processor__r.TPA_Processor_Contact__r.accountid,
                                                TP_Processor__r.TP_Processor_Email__c, 
                                                TP_Processor__r.Assigned_TP_Processors__c
                                            from TPA_Region_Country__c]){

            if(!countryToTPProcessor.containsKey(reagionCountry.Country__c)) {
                countryToTPProcessor.put(reagionCountry.TP_Processor__c, reagionCountry.Country__c);
            }
        }
        Map<String,String> tPProcessorToAssignedTPProcessor = new Map<String,String>();
        for(TPA_TP_Processor__c Obj:[select id,TP_Processor_Email__c,(select id,Email__c,Initials__c,Is_Active__c from TPA_Assigned_TP_Processors__r),
                                       (select id,Country__c from TPA_Region_Countries__r)
                                    from TPA_TP_Processor__c]){
            if((Obj.TPA_Region_Countries__r != null && Obj.TPA_Region_Countries__r.size() > 0) && Obj.TP_Processor_Email__c != '')  {
                for(TPA_Region_Country__c regionCountryObj : Obj.TPA_Region_Countries__r){
                    if(!countryToTpAssignedTPProcessorEmail.containsKey(regionCountryObj.Country__c)){
                        countryToTpAssignedTPProcessorEmail.put(regionCountryObj.Country__c, Obj.TP_Processor_Email__c);
                    }
                }
            } 
        }
    }
    
    public class allConditions {
    	public Datetime fromDate;
    	public Datetime toDate;
    	public string RequestType;
    	public string requestingContry;
  	}
    
    @remoteAction
    public static ReturnWrapper getfinalReport(String selectedConditions, Integer noOfReqToProcess, String lastResults)
    {
        ReturnWrapper lastCalcResults;
        if(lastResults != null && lastResults != ''){
        	lastCalcResults	= (ReturnWrapper)JSON.deserialize(lastResults,ReturnWrapper.class);
        }
        else{
            lastCalcResults = new ReturnWrapper();
            lastCalcResults.venSubToInReviewCf = new CalculationField();
            lastCalcResults.inReviewToAwiatSignCf = new CalculationField();
            lastCalcResults.venSubToInEffectCf = new CalculationField();
        }
        
        List<TPA_Request__c> requestList = new List<TPA_Request__c>();
        datetime lastRecordCretedDateTime;
        if(lastCalcResults.lastRecId != null) {
            lastRecordCretedDateTime = [Select CreatedDate from TPA_Request__c where Id = :lastCalcResults.lastRecId][0].CreatedDate;
        }
        allConditions objSelectedConditions = (allConditions)JSON.deserialize(selectedConditions,allConditions.class);
        Datetime fromDate;
        Datetime toDate;
        if(objSelectedConditions.fromDate != null){
            fromDate = Datetime.newInstance(objSelectedConditions.fromDate.year(),objSelectedConditions.fromDate.month(),objSelectedConditions.fromDate.day(),0,0,0);
        }
        if(objSelectedConditions.toDate != null){
            toDate = Datetime.newInstance(objSelectedConditions.toDate.year(),objSelectedConditions.toDate.month(),objSelectedConditions.toDate.day()+1,0,0,0);
        }
        system.debug('fromDate'+fromDate);
        system.debug('toDate'+toDate);
        
        List<String> submittingCountries = new List<String>();

        Map<String,String> assignedTPProcessorNameWithID = new Map<String,String>();

        for(TPA_Assigned_TP_Processor__c assignedTP : [select id,Email__c,Initials__c,Is_Active__c from TPA_Assigned_TP_Processor__c ]){
            if(assignedTP.Email__c != null && assignedTP.Email__c != '' && !assignedTPProcessorNameWithID.containsKey(assignedTP.Email__c + '(' + assignedTP.Initials__c + ')')){
                assignedTPProcessorNameWithID.put(assignedTP.Email__c + '(' + assignedTP.Initials__c + ')', assignedTP.id);
            }
        }

        Set<String> countrySet = new Set<String>();
        String query = 'Select Id, Name, Data_Access_Start_Date__c, Data_Access_End_Date__c, CreatedDate, '
                       + 'Client_Request_Submission__c, Vendor_App_Sent__c, Vendor_App_Submitted__c, '
                       + 'In_IMS_Review__c, Sent_for_Signature__c, In_Effect_Date__c, Signature_Received__c, '
                       + 'Signature_Under_Validation__c, IMS_Denied__c, Cancelled__c, Expired_Date__c '
                       + 'from TPA_Request__c '
                       + 'where CreatedDate >= :fromDate and CreatedDate < :toDate '
                       + 'and Is_Submitted__c = true ';

        

        if(Test.isRunningTest()) {
            fromDate = Date.today().addDays(-3);
            toDate = Date.today().addDays(360);
        }
        else {
            if(objSelectedConditions.requestingContry != null && objSelectedConditions.requestingContry != ''){
            objSelectedConditions.requestingContry = objSelectedConditions.requestingContry.substring(0,objSelectedConditions.requestingContry.length()-1);
            system.debug('objSelectedConditions.requestingContry' + objSelectedConditions.requestingContry);
            
                if(objSelectedConditions.requestingContry == 'ALL excluding US'){
                        countrySet.addAll(UTL_TPA_Multilingual.getCountryStateCodeSetWithName('C', 'United States'));
                        countrySet.add('United States');
                        query += ' and Client_Contact_Territory__c Not in : countrySet ';
                }
                else if(objSelectedConditions.requestingContry != 'ALL'){
                    for(String selectedCountry: objSelectedConditions.requestingContry.split(';')){
                        countrySet.add(selectedCountry);
                        countrySet.addAll(UTL_TPA_Multilingual.getCountryStateCodeSetWithName('C', selectedCountry));
                    }
                    query += ' and Client_Contact_Territory__c in : countrySet ';
                }
            }
        }        

        String RequestsType = objSelectedConditions.RequestType;
                    
                       
        if(RequestsType != null)
        {
            if(RequestsType.Trim() == 'AMA')
            {
                query += 'and AMA_USPrescriberData__c = \'Yes\' ';
            }
        }
        
        if(Test.isRunningTest())
            query += 'and In_Effect_Date__c != null ';
        
        if(lastRecordCretedDateTime != null) {
            query += ' AND CreatedDate > :lastRecordCretedDateTime';
        }
            
        requestList = Database.query( query + ' Order By CreatedDate Limit ' + noOfReqToProcess ); 
        
        return getResult(requestList,lastCalcResults);
    }
    
    public static ReturnWrapper getResult(List<TPA_Request__c> requestList,ReturnWrapper lastresultData){
        if(requestList.size() > 0)
        {
            Integer intiatedToInReview = 0, inReviewToSign = 0, initToInfEff = 0,intiatedToInReviewRecs = 0, inReviewToSignRecs = 0, initToInfEffRecs = 0 ;
            lastresultData.lastRecId = requestList[requestList.size() - 1].Id;
            for(TPA_Request__c agg :requestList)
            {
                if(agg.Client_Request_Submission__c != null)
                {
                    if(agg.In_IMS_Review__c != null && agg.Client_Request_Submission__c <= agg.In_IMS_Review__c)
                    {
                        intiatedToInReview += agg.Client_Request_Submission__c.date().daysBetween(agg.In_IMS_Review__c.date());
                        intiatedToInReviewRecs += 1;
                        if(agg.Sent_for_Signature__c != null && agg.Sent_for_Signature__c >= agg.In_IMS_Review__c )
                        {
                            inReviewToSign += agg.In_IMS_Review__c.date().daysBetween(agg.Sent_for_Signature__c.date());
                            inReviewToSignRecs += 1;
                        }
                    }
                    if(agg.In_Effect_Date__c != null )
                    {
                        initToInfEff += agg.Client_Request_Submission__c.date().daysBetween(agg.In_Effect_Date__c.date());
                        initToInfEffRecs += 1;
                    }
                }
            }
            lastResultData.venSubToInReviewCf.totalNoOfDays += intiatedToInReview;
            lastResultData.venSubToInReviewCf.totalNoOfRecords += intiatedToInReviewRecs;
            
            lastResultData.inReviewToAwiatSignCf.totalNoOfDays += inReviewToSign;
            lastResultData.inReviewToAwiatSignCf.totalNoOfRecords += inReviewToSignRecs;
            
            lastResultData.venSubToInEffectCf.totalNoOfDays += initToInfEff;
            lastResultData.venSubToInEffectCf.totalNoOfRecords += initToInfEffRecs;
                    
            lastResultData.noOfReqProcessed = requestList.size();
            lastResultData.totalNoOfReqProcessed += requestList.size();
        }
        System.debug('//'+lastResultData);
        return lastResultData;
    }
    
    public class ReturnWrapper{
        CalculationField venSubToInReviewCf;
        CalculationField inReviewToAwiatSignCf;
        CalculationField venSubToInEffectCf;
        Integer noOfReqProcessed = 0;
        Integer totalNoOfReqProcessed = 0;
        String lastRecId;
    }
    
    public class CalculationField{
        Integer totalNoOfDays = 0;
        Integer totalNoOfRecords = 0;
    }
}
