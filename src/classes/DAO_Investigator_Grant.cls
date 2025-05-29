/**
 * This is Investigator Grant trigger handler class.
 * version : 1.0
 */
public class DAO_Investigator_Grant extends fflib_SObjectDomain {
    

	public DAO_Investigator_Grant(List<Investigator_Grant__c> sObjectList) {
        super(sObjectList);
    }    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Investigator_Grant(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Investigator_grant_trigger__c){
        	DAOH_OWF_Investigator_Grant.populateAssignedInvestigator((List<Investigator_Grant__c>) records);
        }
    }
    
}