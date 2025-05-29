public class DAO_ClientSatSurvey extends fflib_SObjectDomain{
    
    /**
    * Constructor of this class
    * @params sObjectList List<Client_Sat_Survey__c>
    */
    public DAO_ClientSatSurvey(List<Client_Sat_Survey__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ClientSatSurvey(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the Client Sat Survey trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_ClientSatSurvey.validateSurvey_HasBillableProject((List<Client_Sat_Survey__c>)Records); 
        //DAOH_ClientSatSurvey.validateSurvey_SurveyExists((List<Client_Sat_Survey__c>)Records);
        DAOH_ClientSatSurvey.updateSurvey_OpportunityProductCodes((List<Client_Sat_Survey__c>)Records);
        DAOH_ClientSatSurvey.updateSurvey_InitiationStatus((List<Client_Sat_Survey__c>)Records, null);
        DAOH_ClientSatSurvey.setClientSatSurveyFields((List<Client_Sat_Survey__c>)Records, null);
        Set<Client_Sat_Survey__c> declinedCSSet = DAOH_ClientSatSurvey.filterSurvey_DeclinedSurveys(
            (List<Client_Sat_Survey__c>)Records, null);
        DAOH_ClientSatSurvey.updateSurvey_DeclinedSurveyApproversContact(declinedCSSet);
        DAOH_ClientSatSurvey.setSurveyPIC((List<Client_Sat_Survey__c>)Records);
    }
    
    /**
    * This method is used for after insert of the Client Sat Survey trigger.
    * @return void
    */
    public override void onAfterInsert() {
        DAOH_ClientSatSurvey.updateSurvey_OpportunityRecord((List<Client_Sat_Survey__c>)Records);
    }
    
    /**
    * This method is used for after update of the Client Sat Survey trigger.
    * @params  existingRecords Map<Id, SObject>
    * @return  void
    */
    public override void  onAfterUpdate(Map<Id, SObject> existingRecords) {
    }
    
    /**
    * This method is used for before update of the Client Sat Survey trigger.
    * @params  existingRecords Map<Id, SObject>
    * @return  void
    */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) { 
        DAOH_ClientSatSurvey.validateSurveyLocked((List<Client_Sat_Survey__c>)Records,  (Map<Id, Client_Sat_Survey__c>)existingRecords);
        DAOH_ClientSatSurvey.setClientSatSurveyFields((List<Client_Sat_Survey__c>)Records,  (Map<Id, Client_Sat_Survey__c>)existingRecords);
        DAOH_ClientSatSurvey.updateSurvey_InitiationStatus((List<Client_Sat_Survey__c>)Records, (Map<Id, Client_Sat_Survey__c>)existingRecords);
        
        Set<Client_Sat_Survey__c> declinedCSSet = DAOH_ClientSatSurvey.filterSurvey_DeclinedSurveys(
            (List<Client_Sat_Survey__c>)Records, (Map<Id, Client_Sat_Survey__c>)existingRecords);
        
        
       // DAOH_ClientSatSurvey.reassignApprovalRequest((List<Client_Sat_Survey__c>)Records, (Map<Id, Client_Sat_Survey__c>)existingRecords);
        DAOH_ClientSatSurvey.updateSurvey_DeclinedSurveyApproversContact(declinedCSSet);
        DAOH_ClientSatSurvey.createContactForIntakeSolution((List<Client_Sat_Survey__c>)Records, (Map<Id, Client_Sat_Survey__c>)existingRecords);        
        DAOH_ClientSatSurvey.setSurveyPICFields((List<Client_Sat_Survey__c>)Records, (Map<Id, Client_Sat_Survey__c>)existingRecords);        
    }
    
    public override void onAfterDelete(){
        DAOH_ClientSatSurvey.resetOppFields((List<Client_Sat_Survey__c>)Records);
    }
}