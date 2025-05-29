public class DAO_MajorIncident extends fflib_SObjectDomain {

    public DAO_MajorIncident(List<Major_Incident__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_MajorIncident(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        DAOH_MajorIncident.restrictNewMajorIncident((List<Major_Incident__c>)Records);
        DAOH_MajorIncident.SetReportSentDateTime((List<Major_Incident__c>)Records,null);
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_MajorIncident.restrictNewMajorIncident((List<Major_Incident__c>)Records);
        DAOH_MajorIncident.SetReportSentDateTime((List<Major_Incident__c>)Records,(Map<Id,Major_Incident__c>)existingRecords);
    }

    public override void onAfterInsert() {
        DAOH_MajorIncident.validateInternalEmailAddresses((List<Major_Incident__c>)Records);
        DAOH_MajorIncident.sendEmailtoAccountContactUsers((List<Major_Incident__c>)Records,null);
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords){
        DAOH_MajorIncident.validateInternalEmailAddresses((List<Major_Incident__c>)Records);
        DAOH_MajorIncident.sendEmailtoAccountContactUsers((List<Major_Incident__c>)Records,(Map<Id,Major_Incident__c>)existingRecords);
    }
}
