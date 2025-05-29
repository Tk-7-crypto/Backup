/**
 * This is Campaign Domain class.
 * version : 1.0
 */
public class DAO_Campaign extends fflib_SObjectDomain  {
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_Campaign(List<SObject> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Campaign(sObjectList);
        }
    }
    
    /**
    * Override method Before Insert Call
    */
    public override void onBeforeInsert(){
        DAOH_Campaign.updateHierarchyField((List<Campaign>)Records, Null);
    }
    
    /**
    * Override method Before Update Call
    * @params  existingRecords Map<Id,SObject>
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Campaign.updateHierarchyField((List<Campaign>)Records, (Map<Id, Campaign>)existingRecords);
        DAOH_Campaign.countMQlInHirearchy((List<Campaign>)Records, (Map<Id, Campaign>)existingRecords);
    }
    
    /**
    * Override method Before Delete Call
    */
    public override void onBeforeDelete() {
        DAOH_Campaign.checkCampaignOwner((List<Campaign>)Records);
        DAOH_Campaign.updateHierarchyInCampaign((List<Campaign>)Records);
    }
}