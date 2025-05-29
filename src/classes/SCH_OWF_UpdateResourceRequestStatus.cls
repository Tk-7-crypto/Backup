/*
 * Version       : 1.0
 * Description   : This is scheduler class for BCH_OWF_UpdateResourceRequestStatus Batch job
 */
global class SCH_OWF_UpdateResourceRequestStatus implements Schedulable {
    global void execute(SchedulableContext SC) {
        OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_UPDATERESOURCEREQUESTSTATUS);
        Integer batchSize;
        if(batchConfig != null && batchConfig.Batch_Size__c != null)
            batchSize = (Integer)batchConfig.Batch_Size__c;
        else
            batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
        BCH_OWF_UpdateResourceRequestStatus batch = new BCH_OWF_UpdateResourceRequestStatus();
        database.executeBatch(batch, batchSize);
    }
}