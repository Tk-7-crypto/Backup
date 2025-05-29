/**
 * This is Schedule trigger handler class.
 * version : 1.0
 */
public class DAO_Schedule extends fflib_SObjectDomain {
    
    /**
     * Constructor of this class
     * @params sObjectList List<pse__Schedule__c>
     */
    public DAO_Schedule(List<pse__Schedule__c> sObjectList) {
        super(sObjectList);

    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Schedule(sObjectList);
        }
    }
    
    /**
     * This method is used for before delete of the Schedule trigger.
     * @return void
     */
     
    public override void onBeforeDelete() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_PSA_Schedule.validateDeletion((List<pse__Schedule__c>)Records);
    }  
    
}