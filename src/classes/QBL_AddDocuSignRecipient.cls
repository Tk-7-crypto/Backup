/**
 * This is Queueable class for adding DocuSign Recipient.
 * version : 1.0 
 */
public class QBL_AddDocuSignRecipient implements Queueable,Database.AllowsCallouts {
    Id agreementId;
    public QBL_AddDocuSignRecipient(Id agreementId){
        this.agreementId = agreementId;
    }
    public void execute(QueueableContext SC) {   
        CNT_APTMS_AddDocusignRecipient.addDocuSignRecipient(this.agreementId);
    }
}