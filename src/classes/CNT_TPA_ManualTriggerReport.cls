/**
 * Author: Sunny Bansal
 * Since: August 28, 2015
 * Name: TPA_ManualTriggerReportController
 * Description: Controller class to get the manual trigger reports filters
 *              Added under ER-2181
**/
public with sharing class CNT_TPA_ManualTriggerReport {
    
    public class allConditions{
		public String fromDate;
        public String toDate;
        public String countries;
    }
    public List<String> submittingCountries { get; set; }
    
    public CNT_TPA_ManualTriggerReport(){
        String country = '';
        submittingCountries = new List<String>();
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Client_Contact_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            country = f.getValue();
            country = country.replace('"', '\'');
            submittingCountries.add(country + '~');
        }
    }


    /**
     * Name: searchRequest
     * @param: fetchedConditions contains Conditions in json format, fetched from VF Page
     * @param: lastRecords constains Details of last calculated records which are updated during this call 
     * @return: RequestDataWrapper contains List of calculated records, total requests on which satisfies the fetchedConditions and ID of last record of lastRecords
     * Desc: search records by applying required conditions and return the List of records 
    **/
    @remoteAction
    public static RequestDataWrapper searchRequest(String lastRecords, String fetchedConditions)
    {
        RequestDataWrapper records;
        system.debug('fetchedConditions' + ' ' +fetchedConditions);
        if(lastRecords != null && lastRecords != ''){
            records = (RequestDataWrapper)JSON.deserialize(lastRecords,RequestDataWrapper.class);
        }else{
            records = new RequestDataWrapper();
            records.Data = new List<RequestWrapper>();
            records.lastRecordID = '';
            records.totalRequest = 0 ;
        }
        
        allConditions objSelectedConditions = (allConditions)JSON.deserializeStrict(fetchedConditions,allConditions.class);
        Date fromDate;
        Date toDate;
        String countriesfetched;
        if(objSelectedConditions.fromDate != null){
            fromDate = Date.parse(objSelectedConditions.fromDate);
        }
        if(objSelectedConditions.toDate != null){
            toDate = Date.parse(objSelectedConditions.toDate);
        }
        if(objSelectedConditions.countries != null){
            countriesfetched = objSelectedConditions.countries;
        }
        datetime lastRecordCretedDateTime;
        if(records.lastRecordID != null && records.lastRecordID != '') {
            lastRecordCretedDateTime = [Select CreatedDate from TPA_Request__c where Id = :records.lastRecordID][0].CreatedDate;
        }
        else {
            lastRecordCretedDateTime = fromDate.addDays(-1);
        }
    
        String query = 'Select Id, Client_Contact_Territory__c, Manual_Trigger_Reasons__c '
                     + 'from TPA_Request__c where Is_Submitted__c = true AND (Manual_Trigger_Reasons__c != null AND Manual_Trigger_Reasons__c != \'\')';
        
        query += ' AND ( CreatedDate >=: fromDate AND CreatedDate <: toDate  AND CreatedDate > :lastRecordCretedDateTime )';
        
        Set<String> countrySet = new Set<String>();
        if(countriesfetched != null && countriesfetched != ''){
            countriesfetched = countriesfetched.substring(0,countriesfetched.length()-1);
            system.debug('countriesfetched' + countriesfetched);
            for(String selectedCountry: countriesfetched.split(';')){
                countrySet.add(selectedCountry);
                countrySet.addAll(UTL_TPA_Multilingual.getCountryStateCodeSetWithName('C', selectedCountry));
            }
        }
		
        query += ' AND Client_Contact_Territory__c IN: countrySet   ';
        List<TPA_Request__c> agreements = Database.query( query + ' Order By CreatedDate Limit 1000' );
        return returnResult(agreements,records);
    }
    
    /**
     * Name: returnResult
     * @param: agreements are records which satisfy the required Conditions
     * @param: records contains last calculated records 
     * @return:  RequestDataWrapper contains List of calculated records, total requests on which satisfies the fetchedConditions and ID of last record of lastRecords
     * Desc: Search, filter, add/update records and return the final Result
     **/
    public static RequestDataWrapper returnResult(List<TPA_Request__c> agreements, RequestDataWrapper records ){
        if(agreements.size() != 0){
            Map<String,Integer> manualTriggerReasonsMap = new Map<String,Integer>();
            
            records.lastRecordID = agreements[agreements.size() - 1].id;
            
            for( TPA_Request__c agg : agreements )
            {
                List<String> reasonsList = new List<String>();
                if(agg.Manual_Trigger_Reasons__c != null && agg.Manual_Trigger_Reasons__c != '') {
                    reasonsList = agg.Manual_Trigger_Reasons__c.split(';');
                    for(String reason : reasonsList) {
                        if(!manualTriggerReasonsMap.containsKey(reason)) {
                            manualTriggerReasonsMap.put(reason,1);
                        } else {
                            manualTriggerReasonsMap.put(reason,manualTriggerReasonsMap.get(reason) + 1);
                        }
                    }
                }
            }
            
            for(String reasonKey : manualTriggerReasonsMap.keySet()) {
                boolean found = false;
                for(RequestWrapper Wrapper : records.Data){
                    if(Wrapper.manualTriggerName == reasonKey){
                        found = true;
                        Wrapper.countOfOccurance += manualTriggerReasonsMap.get(reasonKey);
                        break;
                    }
                }
                if(found == false){
                    records.Data.add( new RequestWrapper( reasonKey, manualTriggerReasonsMap.get(reasonKey) ));
                }
            }
            
            records.totalRequest += agreements.size();
            records.Data.sort();
        }
        return records;

    }  
    
    /**
     * Name: RequestWrapper
     * Desc: Wrapper class to bind trigger name with number of Occurances 
    **/
    
    public class RequestWrapper implements Comparable
    {
        public String manualTriggerName { get; set; }
        public Integer countOfOccurance { get; set; }

        public RequestWrapper( String reason, Integer reasonCount)
        {
            this.manualTriggerName = reason;
            this.countOfOccurance = reasonCount;
        }
        
        public Integer compareTo(Object obj) { 
            RequestWrapper rwObj = ((RequestWrapper)obj);
            if(this.countOfOccurance > rwObj.countOfOccurance)
                return -1;
            else
                return 1;
        }
    }
    /**
     * Name : RequestDataWrapper
     * Desc : Wrapper Class to bind List of Trigger Name with count, and total calculated Records after filtering
     **/
    public class RequestDataWrapper{
        List<RequestWrapper> Data;
        string lastRecordID;
        Integer totalRequest;
    }
}