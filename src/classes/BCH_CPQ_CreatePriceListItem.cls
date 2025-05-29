public class BCH_CPQ_CreatePriceListItem implements Database.Batchable<sobject> {
    
    List<Apttus_Config2__PriceListItem__c> priceListItemList = new List<Apttus_Config2__PriceListItem__c>();
    String yearOfPricing;
    String pricingTool;
    Integer totalChunks;
    Integer currentState;
    Map<String, List<SObject>> pmPMEListMap = new Map<String, List<SObject>>();

    public BCH_CPQ_CreatePriceListItem(Map<String, List<SObject>> objectListMap, String newYear, String pricingTool, Integer totalChunks, Integer currentState){ 
        this.priceListItemList = objectListMap.get('PriceListItem');
        this.yearOfPricing = newYear;
        objectListMap.remove('PriceListItem');
        this.pmPMEListMap = objectListMap;
        this.pricingTool = pricingTool;
        this.totalChunks = totalChunks;
        this.currentState = currentState;
    }
    public List<Apttus_Config2__PriceListItem__c> start(Database.BatchableContext bc) {
        return this.priceListItemList;
    }
    public void execute(Database.BatchableContext bc, List<Apttus_Config2__PriceListItem__c> sObjectList) {
        Database.insert(sObjectList);
    }
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob batchJob = new SLT_AsyncApexJob().getJobFieldsForId(bc.getJobId(), CON_CPQ.BATCH_JOB_FIELD_SET);

        if (batchJob.Status == CON_CPQ.COMPLETED && batchJob.NumberOfErrors == 0) {
            BCH_CPQ_CreatePriceMatrix pmBatch = new BCH_CPQ_CreatePriceMatrix(this.pmPMEListMap, this.yearOfPricing, this.pricingTool, this.totalChunks, this.currentState);
            Id batchJobId = Database.executeBatch(pmBatch);
            CNT_CPQ_PricingAdminController.updateBatchJobIdInCPQAdminSettings(batchJobId, pricingTool);
        }
    }
}
