public class DAO_TPAMasterExtensionInformation extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TPAMasterExtensionInformation(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TPAMasterExtensionInformation(sObjectList);
        }
    }

    /**
     * This method is used for before update of the TPA Master Extension Information trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPAMasterExtensionInformation.onBeforeUpdate((List<TPA_Master_Extension_Information__c>)Records, existingRecords.values(), new Map<Id, TPA_Master_Extension_Information__c>((List<TPA_Master_Extension_Information__c>)Records), (Map<Id, TPA_Master_Extension_Information__c>)existingRecords);
        }
    }
    
    /**
     * This method is used for after update of the TPA_Master_Extension_Information__c trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPAMasterExtensionInformation.onAfterUpdate((List<TPA_Master_Extension_Information__c>)Records, existingRecords.values(), new Map<Id, TPA_Master_Extension_Information__c>((List<TPA_Master_Extension_Information__c>)Records), (Map<Id, TPA_Master_Extension_Information__c>)existingRecords);
        }
    }

}