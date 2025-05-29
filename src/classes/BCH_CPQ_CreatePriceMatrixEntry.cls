public class BCH_CPQ_CreatePriceMatrixEntry implements Database.Batchable<sobject> {
    
    List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixEntryList = new List<Apttus_Config2__PriceMatrixEntry__c>();
    String yearOfPricing;
    String pricingTool;
    Integer totalChunks;
    Integer currentState;
    
    public BCH_CPQ_CreatePriceMatrixEntry(List<Apttus_Config2__PriceMatrixEntry__c> newPMEList, String newYear, String pricingTool, Integer totalChunks, Integer currentState) { 
        this.priceMatrixEntryList = newPMEList;
        this.yearOfPricing = newYear;
        this.pricingTool = pricingTool;
        this.totalChunks = totalChunks;
        this.currentState = currentState;
    }
    public List<Apttus_Config2__PriceMatrixEntry__c> start(Database.BatchableContext bc) {
        return this.priceMatrixEntryList;
    }
    public void execute(Database.BatchableContext bc, List<Apttus_Config2__PriceMatrixEntry__c> sObjectList) {
        Database.insert(sObjectList);
    }
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob batchJob = new SLT_AsyncApexJob().getJobFieldsForId(bc.getJobId(), CON_CPQ.BATCH_JOB_FIELD_SET);
        if (batchJob.Status == CON_CPQ.COMPLETED && batchJob.NumberOfErrors == 0) {
            if (this.totalChunks == this.currentState) {
                CNT_CPQ_PricingAdminController.updateBatchJobIdInCPQAdminSettings('Completed', pricingTool);
            } else {
                CNT_CPQ_PricingAdminController.updateBatchJobIdInCPQAdminSettings(('Processed : ' + this.currentState + '/' + this.totalChunks), pricingTool);
            }
        }
    }
}
