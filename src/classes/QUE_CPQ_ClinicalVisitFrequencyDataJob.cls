/**
* @File Name   : QUE_CPQ_ClinicalVisitFrequencyDataJob.cls
* @Description : This class is use to create Clinical visit frequency data record
* @Author      : Noorulain Ashrafi
**/
public class QUE_CPQ_ClinicalVisitFrequencyDataJob implements Queueable {
    private Set<Id> budgetIdSet;
    public QUE_CPQ_ClinicalVisitFrequencyDataJob(Set<Id> budgetIdSet) {
        this.budgetIdSet = budgetIdSet;
    }
    public void execute(QueueableContext context) {
        CPQ_RMUtility.createClinicalVisitFrequencyQuoteData(budgetIdSet);
    }
}