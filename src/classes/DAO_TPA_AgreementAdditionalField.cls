public class DAO_TPA_AgreementAdditionalField extends fflib_SObjectDomain { 
    
     /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TPA_AgreementAdditionalField(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
     /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TPA_AgreementAdditionalField(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the TPA Agreement Additional Field trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
        	DAOH_TPA_AgreementAdditionalField.onBeforeInsert((List<TPA_Agreement_Additional_Field__c>)Records);
        }
    }

    /**
     * This method is used for before update of the TPA Agreement Additional Field trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPA_AgreementAdditionalField.onBeforeUpdate((List<TPA_Agreement_Additional_Field__c>)Records, existingRecords.values(), new Map<Id, TPA_Agreement_Additional_Field__c>((List<TPA_Agreement_Additional_Field__c>)Records), (Map<Id, TPA_Agreement_Additional_Field__c>)existingRecords);
        }
    }
    
     /**
     * This method is used for after update of the TPA Agreement Additional Field trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPA_AgreementAdditionalField.onAfterUpdate((List<TPA_Agreement_Additional_Field__c>)Records, existingRecords.values(), new Map<Id, TPA_Agreement_Additional_Field__c>((List<TPA_Agreement_Additional_Field__c>)Records), (Map<Id, TPA_Agreement_Additional_Field__c>)existingRecords);
        }
    }

}