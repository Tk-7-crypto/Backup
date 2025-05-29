public class DAO_CSAT_Response extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<CSAT_Responses__c>
     */
    public DAO_CSAT_Response(List<CSAT_Responses__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_CSAT_Response(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the case trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_CSAT_Response.updateAnswer((List<CSAT_Responses__c>)Records);
    }
}