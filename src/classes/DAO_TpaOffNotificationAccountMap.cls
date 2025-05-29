public class DAO_TpaOffNotificationAccountMap extends fflib_SObjectDomain {

	/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TpaOffNotificationAccountMap(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TpaOffNotificationAccountMap(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the TPA_Off_Notification_Account_Mapping__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        	DAOH_TpaOffNotificationAccountMap.updateParentRules((List<TPA_Off_Notification_Account_Mapping__c>)Records);
        }
    }
    
    /**
     * This method is used for after update of the TPA_Off_Notification_Account_Mapping__c trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TpaOffNotificationAccountMap.updateParentRules((List<TPA_Off_Notification_Account_Mapping__c>)Records);
        }
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onAfterDelete() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TpaOffNotificationAccountMap.updateParentRules((List<TPA_Off_Notification_Account_Mapping__c>)Records);
        }
    }
}