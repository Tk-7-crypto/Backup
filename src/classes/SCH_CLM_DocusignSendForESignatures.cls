/** 
* This scheduler class is used to check Docusign E Signatures status  
*/  
public class SCH_CLM_DocusignSendForESignatures implements Schedulable {
    String query;    
    
    public SCH_CLM_DocusignSendForESignatures(String query) {
        this.query = query;
    } 
    
    public void execute(SchedulableContext sc) {
        database.executebatch(new BCH_APTMS_BulkCheckESignatureStatus(query), 1);
    }
}