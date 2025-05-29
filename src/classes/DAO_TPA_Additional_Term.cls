public with sharing class DAO_TPA_Additional_Term extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TPA_Additional_Term(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TPA_Additional_Term(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the TPA Additional terms trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && !UTL_TPA.modifyAdditionalTerm ) {
        	DAOH_TPA_Additional_Term.onBeforeInsert((List<TPA_Additional_Term__c>)Records);
        }
    }

    /**
     * This method is used for before insert of the TPA Additional terms trigger.
     * @return void
     */
    public override void onAfterInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && !UTL_TPA.modifyAdditionalTerm) {
        	DAOH_TPA_Additional_Term.onAfterInsert((List<TPA_Additional_Term__c>)Records);
        }
    }

    /**
     * This method is used for before update of the TPA Additional terms trigger.
     * @params  existingRecords Map<Id, SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && !UTL_TPA.modifyAdditionalTerm) {
            DAOH_TPA_Additional_Term.onBeforeUpdate((List<TPA_Additional_Term__c>)Records, existingRecords.values(), new Map<Id, TPA_Additional_Term__c>((List<TPA_Additional_Term__c>)Records), (Map<Id, TPA_Additional_Term__c>)existingRecords);
        }
    }

    /**
     * This method is used for after update of the TPA Additional terms trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && !UTL_TPA.modifyAdditionalTerm) {
            DAOH_TPA_Additional_Term.onAfterUpdate((List<TPA_Additional_Term__c>)Records, existingRecords.values(), new Map<Id, TPA_Additional_Term__c>((List<TPA_Additional_Term__c>)Records), (Map<Id, TPA_Additional_Term__c>)existingRecords);
        }
    }

    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && !UTL_TPA.modifyAdditionalTerm) {
            DAOH_TPA_Additional_Term.onBeforeDelete((List<TPA_Additional_Term__c>)Records);
        }
    }

    /**
     * Override method After Delete Call
     */
    public override void onAfterDelete() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && !UTL_TPA.modifyAdditionalTerm) {
            DAOH_TPA_Additional_Term.onAfterDelete((List<TPA_Additional_Term__c>)Records);
        }
    }
}
