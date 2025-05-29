/**
 * This is Topics_of_Interest (Topics_of_Interest__C) trigger handler class.
 * version : 1.0
 */
public class DAO_Topics_of_Interest extends fflib_SObjectDomain{
    /**
     * Constructor of this class
     * @params sObjectList List<SD_Runs__c>
     */
    public DAO_Topics_of_Interest(List<Topics_of_Interest__C> sObjectList){
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Topics_of_Interest(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Topics_of_Interest  trigger.
     * @return void
     */
    public override void onBeforeInsert(){ 
        DAOH_Topics_of_Interest.populateTOIUniqueId((List<Topics_of_Interest__C>)Records,null);
        DAOH_Topics_of_Interest.validateTopicsOfInterestFields((List<Topics_of_Interest__C>)Records,null);
        DAOH_Topics_of_Interest.autoPopulateTopicsOfInterestFields((List<Topics_of_Interest__C>)Records,null);
    }  
    
    /**
    * This method is used for before update of the Topics_of_Interest  trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Topics_of_Interest.validateTopicsOfInterestFields((List<Topics_of_Interest__C>)Records,null);
        DAOH_Topics_of_Interest.autoPopulateTopicsOfInterestFields((List<Topics_of_Interest__C>)Records,null);
    }
     /**
     * This method is used for after insert of the PSSF__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Topics_of_Interest.insertAuditLogOnUpdate((List<Topics_of_Interest__C>)Records, null);
    }
    
    /**
     * This method is used for after update of the Topics_of_Interest__C trigger.
     * @return  void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_Topics_of_Interest.insertAuditLogOnUpdate((List<Topics_of_Interest__C>)Records, (Map<Id,Topics_of_Interest__C>) existingRecords);
    }
    
    /**
     * This method is used for after delete of the Topics_of_Interest__C trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_Topics_of_Interest.insertAuditLog((List<Topics_of_Interest__C>)Records,'DELETE');
    }
    /**
     * This method is used for after undelete of the Topics_of_Interest__C trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_Topics_of_Interest.insertAuditLog((List<Topics_of_Interest__C>)Records,'UNDELETE');
    }
}
