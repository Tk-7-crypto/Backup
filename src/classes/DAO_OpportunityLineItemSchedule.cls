/**
 * This is OpportunityLineItemSchedule Domain class.
 * version : 1.0
 */
public class DAO_OpportunityLineItemSchedule extends fflib_SObjectDomain {
    
    /**
     * Constructor of this class
     * @params sObjectList List<OpportunityLineItemSchedule>
     */
    public DAO_OpportunityLineItemSchedule(List<OpportunityLineItemSchedule> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_OpportunityLineItemSchedule(sObjectList);
        }
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_OpportunityLineItemSchedule.createOutboundMessageDeletionQueue((List<OpportunityLineItemSchedule>)Records);
    } 
}