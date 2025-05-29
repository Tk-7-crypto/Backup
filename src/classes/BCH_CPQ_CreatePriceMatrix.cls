public class BCH_CPQ_CreatePriceMatrix implements Database.Batchable<sobject> {
    
    List<Apttus_Config2__PriceMatrix__c> priceMatrixList = new List<Apttus_Config2__PriceMatrix__c>();
    String yearOfPricing;
    String pricingTool;
    Integer totalChunks;
    Integer currentState;
    List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixEntryList = new List<Apttus_Config2__PriceMatrixEntry__c>();
    
    public BCH_CPQ_CreatePriceMatrix(Map<String, List<SObject>> pmPMEListMap, String newYear, String pricingTool, Integer totalChunks, Integer currentState) { 
        this.yearOfPricing = newYear;
        this.priceMatrixList = pmPMEListMap.get('PriceMatrix');
        this.priceMatrixEntryList = pmPMEListMap.get('PriceMatrixEntry');
        this.pricingTool = pricingTool;
        this.totalChunks = totalChunks;
        this.currentState = currentState;
    }
    public List<Apttus_Config2__PriceMatrix__c> start(Database.BatchableContext bc) {
        return this.priceMatrixList;
    }
    public void execute(Database.BatchableContext bc, List<Apttus_Config2__PriceMatrix__c> sObjectList) {
        Database.insert(sObjectList);
    }
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob batchJob = new SLT_AsyncApexJob().getJobFieldsForId(bc.getJobId(), CON_CPQ.BATCH_JOB_FIELD_SET);
        
        if (batchJob.Status == CON_CPQ.COMPLETED && batchJob.NumberOfErrors == 0) {
            BCH_CPQ_CreatePriceMatrixEntry pmeBatch = new BCH_CPQ_CreatePriceMatrixEntry(this.priceMatrixEntryList, this.yearOfPricing, pricingTool, this.totalChunks, this.currentState);
            Id batchJobId = Database.executeBatch(pmeBatch);
            CNT_CPQ_PricingAdminController.updateBatchJobIdInCPQAdminSettings(batchJobId, pricingTool);
        }
    }
}
