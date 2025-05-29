/**
* @File Name   : QUE_CPQ_TimelineDataJob.cls
* @Description : This class is use to create or update time line record then enqueueJob QUE_CPQ_AdminTimeEntryDataJob
* @Author      : Noorulain Ashrafi
**/
public class QUE_CPQ_TimelineDataJob implements Queueable {
    private Set<Id> budgetIdSet;
    public QUE_CPQ_TimelineDataJob(Set<Id> budgetIdSet) {
        this.budgetIdSet = budgetIdSet;
    }
    public void execute(QueueableContext context) {
        CPQ_RMUtility.createTimelineAndPhaseQuoteData(budgetIdSet, true, true);
        If (!Test.isRunningTest()) System.enqueueJob(new QUE_CPQ_AdminTimeEntryDataJob(budgetIdSet));
    }
}