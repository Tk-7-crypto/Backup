public with sharing class CNT_CPQ_ATCAdminWizard {
    @AuraEnabled
    public static String updateATCOTCData(String excelJSONData, String quarter) {
        // JSON String to Object Conversion
        List<Object> recordData = (List<Object>)JSON.deserializeUntyped(excelJSONData);
        // store values to update
        Map<String, Decimal> migIdAndUpdatedMarketShareMap = new Map<String, Decimal>();
        for(Object traceRecordData : recordData){   
            Map<String, Object> singleRecordData = (Map<String, Object>) traceRecordData;
            migIdAndUpdatedMarketShareMap.put((String)singleRecordData.get(CON_CPQ.MIGRATION_ID), ((Decimal)singleRecordData.get(CON_CPQ.MARKET_SHARE))*100);
        }
        if(!migIdAndUpdatedMarketShareMap.containsKey(null)){
            BCH_CPQ_UpdateATCOTCData objbatch = new BCH_CPQ_UpdateATCOTCData(migIdAndUpdatedMarketShareMap, quarter);
            Id batchJobID = Database.executeBatch(objbatch);
            return batchJobID;
        }
        else{
            return CON_CPQ.ERROR;
        }
    }
    
    @AuraEnabled
    public static String checkBatchJobStatus(Id jobId){
        try {
            String jobStatus = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: jobId].Status;
            return jobStatus;
        } catch (Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getReportRecordId(String reportName) {
        return [SELECT Id, Name FROM Report WHERE DeveloperName =:reportName].Id;
    }
}
