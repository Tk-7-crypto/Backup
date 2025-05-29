public class QUE_CPQ_TimeDelayForSchedule implements Queueable {
    Id budgetId;
    Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleListByOliId;
    
    public QUE_CPQ_TimeDelayForSchedule(Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleListByOliId, Id budgetId) {
        this.lineItemScheduleListByOliId = lineItemScheduleListByOliId;
        this.budgetId = budgetId;
    }
    public void execute(QueueableContext context)
    {
        try {
            CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
            Integer timeDelay = (Integer)cpqSetting.Delay_in_revenue_schedule__c;
            timeDelay = (timeDelay == null || timeDelay == 0) ? 15 : timeDelay;
            DateTime startTime = System.now();
            DateTime currentTime = System.now();
            while(currentTime <= startTime.addSeconds(timeDelay)) { 
                currentTime = System.now();
            }
            if(!test.isRunningTest()) {
                QUE_CPQ_ScheduleUpdate scheduleUpdate = new QUE_CPQ_ScheduleUpdate(lineItemScheduleListByOliId, budgetId, True ); 
                Id jobId = System.enqueueJob(scheduleUpdate);    
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}