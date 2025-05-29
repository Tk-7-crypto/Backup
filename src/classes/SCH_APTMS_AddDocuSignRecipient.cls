/**
 * @description Schedule class to invoke CNT_APTMS_AddDocusignRecipient.addDocuSignRecipientForPartiallySigned and CNT_APTMS_AddDocusignRecipient.addDocuSignRecipient
 */
public class SCH_APTMS_AddDocuSignRecipient implements Schedulable {
    Id agreementId;
    public SCH_APTMS_AddDocuSignRecipient(Id agreementId){
        this.agreementId = agreementId;
    }
    
    public void execute(SchedulableContext SC) {
        System.enqueueJob(new QBL_AddDocuSignRecipient(this.agreementId));
        for(CronTrigger ct :  [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name like '%DocuSign add recipient%']){
            System.abortJob(ct.id);
        }
    }
}