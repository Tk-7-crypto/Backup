public class QBL_TPA_AsyncVoidEnvelope implements Queueable, Database.AllowsCallouts {
    public Set<Id> requestIds = new Set<Id>();
    public string voidReason = '';
    public void execute(QueueableContext context) {
        SRV_TPA_DocusignEnvelope.voidEnvelope(requestIds , voidReason);
    }
}