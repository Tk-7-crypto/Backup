/*
 * Version       : 1.0
 * Description   : This is scheduler class for BCH_PSA_CDCHealthCheckup Batch job
 */
global class SCH_PSA_CDCHealthCheckup implements Schedulable {
    global void execute(SchedulableContext SC) {
        Integer batchSize = 4;
        
        BCH_PSA_CDCHealthCheckup batch = new BCH_PSA_CDCHealthCheckup();
        database.executeBatch(batch, batchSize);
    }
}