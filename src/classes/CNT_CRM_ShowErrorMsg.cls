public class CNT_CRM_ShowErrorMsg {
    
    @AuraEnabled(cacheable=true)
    public static Boolean getQueryResult (String recordId, String queryText){
        List<Sobject> listOfResult = Database.query(queryText);
        return (listOfResult.size() > 0);
    }
    
}