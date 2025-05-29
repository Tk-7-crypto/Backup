public class QBL_TPA_HelpfulHintsAddendum implements Queueable,Database.AllowsCallouts { 
	public string requestId = ''; 
    public string GUID = '';
    public void execute(QueueableContext context) {
        CNT_TPA_Helpful_Hints_Addendum.generateHelpfulHintsAddendumDoc(requestId, 'pdf', GUID);
    }
}