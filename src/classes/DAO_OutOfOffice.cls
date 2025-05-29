public class DAO_OutOfOffice extends fflib_SObjectDomain{
    /**
    * Constructor of this class
    * @params sObjectList List<SObject>
    */
    public DAO_OutOfOffice(List<SObject> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_OutOfOffice(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the OutOfOffice trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        
    }
    
    /**
    * This method is used for after insert of the OutOfOffice trigger.
    * @return void
    */
    public override void onAfterInsert() {
        DAOH_OutOfOffice.updateUserNameWithMessage((List<OutOfOffice>)records, null);
    }
    
    /**
    * This method is used for before update of the OutOfOffice trigger.
    * @params  Map<Id, SObject> existingRecords
    * @return void
    */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        
    }
    
    /**
    * This method is used for after update of the OutOfOffice trigger.
    * @params  Map<Id, SObject> existingRecords
    * @return void
    */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        DAOH_OutOfOffice.updateUserNameWithMessage((List<OutOfOffice>)records, (Map<Id, OutOfOffice>)existingRecords);
    }
    
    /**
    * This method is used for after delete of the OutOfOffice trigger.
    * @params  Map<Id, SObject> existingRecords
    * @return void
    */
    public override void onAfterDelete() {
        DAOH_OutOfOffice.updateUserNameWithMessage((List<OutOfOffice>)records, new Map<Id, OutOfOffice>((List<OutOfOffice>)Records));
    }
}