public class DAO_ClientSatSurveyRecipient extends fflib_SObjectDomain{
    /**
    * Constructor of this class
    * @params sObjectList List<Client_Sat_Survey_Recipient__c>
    */
    public DAO_ClientSatSurveyRecipient(List<Client_Sat_Survey_Recipient__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ClientSatSurveyRecipient(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the Client Sat Survey Recipient trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_ClientSatSurveyRecipient.setOppDateFields((List<Client_Sat_Survey_Recipient__c>) records);
    }

}