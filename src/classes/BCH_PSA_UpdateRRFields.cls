/**
 * Update resource request fields with data pulled from the project
 */
public class BCH_PSA_UpdateRRFields implements Database.Batchable<sObject> {
    private Set<Id> projectIdSet;

    public BCH_PSA_UpdateRRFields(Set<Id> projectIds){
        this.projectIdSet = projectIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query =  'SELECT Id, Project_Manager__c, Service_Line_Lead__c, '+
                        'pse__Project__r.pse__Project_Manager__c, pse__Project__r.Service_Line_Lead__c '+
                        'FROM pse__Resource_Request__c WHERE pse__Project__c IN :projectIdSet';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<pse__Resource_Request__c> records) {
        for(pse__Resource_Request__c rRequest : records){
            rRequest.Project_Manager__c = rRequest.pse__Project__r.pse__Project_Manager__c;
            rRequest.Service_Line_Lead__c = rRequest.pse__Project__r.Service_Line_Lead__c;
        }
        update records;
    }

    public void finish(Database.BatchableContext BC){}

}