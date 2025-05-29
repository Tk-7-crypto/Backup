public class CNT_PSA_Search_Strategy_ListView {
    
    @AuraEnabled(cacheable=true)
    public static List<Search_Strategy__c> getSearchStrategyData(String recordId){
        Set<String> lrSsFieldSet = new Set<String>{'Id', 'Search_Strategy_M__c', 'LR_Project_Overview_M__c','LR_Project_Overview_M__r.Search_Strategy_Created__c'};
        Set<Id> lridSet = new Set<Id>();
        lridSet.add(recordId);
        List<LR_Search_Strategy_Relationship__c> lrssList = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipFromLrId(lridSet, lrSsFieldSet);
        Set<Id> SearchStrategyIdSet = new Set<Id>();
        for(LR_Search_Strategy_Relationship__c lrss : lrssList){
            SearchStrategyIdSet.add(lrss.Search_Strategy_M__c);
        }
        Set<String> ssFieldSet = new Set<String>{'Id', 'Name', 'Version_of_Search_Strategy__c', 'Date_Search_Strategy_got_Client_Approval__c','Date_Annual_Search_Strategy_Due__c', 'Comments__c'};
        return new SLT_Search_Strategy().getSearchStrategiesByIds(SearchStrategyIdSet, ssFieldSet);
    }
    
    @AuraEnabled(cacheable=false)
    public static LR_Project_Overview__c  getLRData(String recordId){
        Set<String> lrFieldSet = new Set<String>{'Id', 'Account__c', 'LR_Type__c', 'Project__c', 'Product__c'};
        return new SLT_LR_Project_Overview().getLRProjectOverViewFROMlRProjectOverViewId(recordId, lrFieldSet);
    }
    
    @AuraEnabled(cacheable=false)
    public static String lrProjectOverviewValidation( String  recordId ){
        String result;
        Set<String> SearchStrategyCreatedSet = new Set<String>{'No', 'Client Responsible', 'N/A'};
        LR_Project_Overview__c projectOverview = new SLT_LR_Project_Overview().getLRProjectOverViewFROMlRProjectOverViewId( recordId, new Set<String>{'Account__c', 'Project__c', 'Product__c', 'Project_Codes__c','LR_Type__c','Status__c', 'Search_Strategy_Created__c'} );
        if( projectOverview.Status__c == CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED || projectOverview.Status__c == CON_PSA.LR_PROJECT_OVERVIEW_STATUS_CANCELLED ){
            result = 'NotValidForCompleteAndCancelled';
        }
        if( SearchStrategyCreatedSet.contains(projectOverview.Search_Strategy_Created__c) || projectOverview.Search_Strategy_Created__c == null ){
            result = 'NotValidForSearchStrategyCreated';
        }
        if( projectOverview.Account__c == null || projectOverview.Product__c == null || projectOverview.Project__c == null || projectOverview.LR_Type__c == ''){
            result = 'NotValidDataFromLR';
        }
        return result;
    }
    @AuraEnabled(cacheable=false)
    public static  String  getFilterData( String  recordId, Integer pageSize, Integer pageNumber,Integer totalRecords ){
        String jsonObjItm = '';
        Set<String> lrSsFieldSet = new Set<String>{'Id', 'Search_Strategy_M__c','LR_Project_Overview_M__r.Search_Strategy_Created__c','LR_Project_Overview_M__c'};
        Set<Id> lridSet = new Set<Id>();
        lridSet.add(recordId);
        List<LR_Search_Strategy_Relationship__c> lrssList = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipFromLrId(lridSet, lrSsFieldSet);
        Set<Id> SearchStrategyIdSet = new Set<Id>();
        for(LR_Search_Strategy_Relationship__c lrss : lrssList){
            SearchStrategyIdSet.add(lrss.Search_Strategy_M__c);       
        }
        Set<String> ssFieldSet = new Set<String>{'Id', 'Name', 'Version_of_Search_Strategy__c', 'Date_Search_Strategy_got_Client_Approval__c','Date_Annual_Search_Strategy_Due__c', 'Comments__c'};
        Integer offset = (pageNumber - 1) * pageSize;         
        if( totalRecords == 0 ){
            totalRecords = [SELECT COUNT() FROM Search_Strategy__c WHERE Id =: SearchStrategyIdSet];
        }
        Integer recordEnd = pageSize * pageNumber;
        SearchStrategyItemWrapper ssObj =  new SearchStrategyItemWrapper();  
        ssObj.pageNumber = pageNumber;
        ssObj.pageSize = pageSize;        
        ssObj.recordStart = offset + 1;
        ssObj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        ssObj.totalRecords = totalRecords;
        ssObj.searchStrategies = new SLT_Search_Strategy().getSearchStrategiesByIdsForPagination(SearchStrategyIdSet, ssFieldSet,pageSize,offset);
        jsonObjItm = JSON.serialize(ssObj);
        return jsonObjItm;
    }
    public class SearchStrategyItemWrapper {       
        public Integer recordStart {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordEnd {get;set;}
        public Integer pageSize {get;set;}       
        public List<Search_Strategy__c> searchStrategies {get;set;}
    }

}