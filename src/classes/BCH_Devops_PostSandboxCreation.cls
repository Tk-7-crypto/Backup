/**
* Batch to remove MFA permission set assignment from users.
*/ 
public class BCH_Devops_PostSandboxCreation implements Database.Batchable<Sobject>,Database.Stateful {
    public String errorMsg;
    
	public Database.QueryLocator start(Database.BatchableContext context) {
		String query = 'SELECT Id from PermissionSetAssignment WHERE PermissionSet.Label = \'Multi-Factor Authentication for UI Login\'';
        if(Test.isRunningTest()){
			query += ' LIMIT 1';
       	}
        return Database.getQueryLocator(query);
    }
    
    
    public void execute(Database.BatchableContext context, list<PermissionSetAssignment> records) {
        try {
        	delete records;
        } catch(Exception e) {
            errorMsg = e.getMessage();
        }
    }
    
    public void finish(Database.BatchableContext context) {}
}