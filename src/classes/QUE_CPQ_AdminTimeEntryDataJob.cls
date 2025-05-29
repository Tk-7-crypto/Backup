/**
* @File Name   : QUE_CPQ_AdminTimeEntryDataJob.cls
* @Description : This class is use to create Admin time entry data record then enqueueJob QUE_CPQ_ClinicalVisitFrequencyDataJob
* @Author      : Noorulain Ashrafi
**/
public class QUE_CPQ_AdminTimeEntryDataJob implements Queueable {
    private Set<Id> budgetIdSet;
    public QUE_CPQ_AdminTimeEntryDataJob(Set<Id> budgetIdSet) {
        this.budgetIdSet = budgetIdSet;
    }
    public void execute(QueueableContext context) {
        Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new SLT_Proposal().selectByProposalIds(budgetIdSet, new Set<String> {CON_CPQ.ID, CON_CPQ.DTE_STUDY});
        CPQ_RMUtility.createAdminTimeEntryQuoteData(proposalMap);
        If (!Test.isRunningTest()) System.enqueueJob(new QUE_CPQ_ClinicalVisitFrequencyDataJob(budgetIdSet));
    }
}