/*
* Version       : 1.0
* Description   : This is scheduler class for BCH_PSA_DeleteEstVsActuals Batch job
*/
global class SCH_PSA_DeleteEstVsActuals implements Schedulable {
    global void execute(SchedulableContext SC) {
        Integer batchSize = 200;
        BCH_PSA_DeleteEstVsActuals batch = new BCH_PSA_DeleteEstVsActuals();
        Database.executeBatch(batch, batchSize);
    }
}