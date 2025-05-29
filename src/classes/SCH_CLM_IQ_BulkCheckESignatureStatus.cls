/** 
* This scheduler class is used to check Docusign E Signatures status  
*/  
public class SCH_CLM_IQ_BulkCheckESignatureStatus implements Schedulable {
    String query;    
    
    public SCH_CLM_IQ_BulkCheckESignatureStatus(String query) {
        this.query = query;
    } 
    
    public void execute(SchedulableContext sc) {
        database.executebatch(new BCH_CLM_BulkCheckESignatureStatus(query), 1);
    }
}