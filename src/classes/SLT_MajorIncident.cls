public class SLT_MajorIncident {

    public Map<Id, Major_Incident__c> selectOnGoingMajorIncident(Set<String> fieldSet) {
        return new Map<Id, Major_Incident__c>((List<Major_Incident__c>) Database.query('SELECT Id, Name, Major_Incident_Subject__c, Status__c FROM Major_Incident__c WHERE Status__c IN :fieldSet'));
    }
}