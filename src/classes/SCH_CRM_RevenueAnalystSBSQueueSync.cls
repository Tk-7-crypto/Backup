/*
 * Author    : 
 * Purpose    : Batch to maintain Revenue Analyst Users according to Queue
 */
global class SCH_CRM_RevenueAnalystSBSQueueSync implements Schedulable {
    global void execute(SchedulableContext ctx) {
      Integer numberOfRunningBatch = [SELECT Count() FROM AsyncApexJob Where Status = 'Processing' And JobType = 'BatchApex'];
      if(numberOfRunningBatch < 5) {
        BCH_CRM_RevenueAnalystSBSQueueSync revenueAnalystSBSQueueSync = new BCH_CRM_RevenueAnalystSBSQueueSync();
          DataBase.executeBatch(revenueAnalystSBSQueueSync, 1);  
      } 
    }
}