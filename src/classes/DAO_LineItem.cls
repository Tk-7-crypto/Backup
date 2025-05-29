public class DAO_LineItem extends fflib_SObjectDomain{
/**
     * Constructor of this class
     * @params sObjectList List<Apttus_Config2__LineItem__c>
     */
    public DAO_LineItem(List<Apttus_Config2__LineItem__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_LineItem(sObjectList);
        }
    }

    /**
    * Unit of Work instance for CRUD operation
    */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork (
        new Schema.SObjectType[] { Outbound_Message_Deletion_queue__c.SobjectType }
    );
    
    public override void onApplyDefaults() {}

    /**
     * This method is used for before insert of the Line Item trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_LineItem.trackChangeOnLineItem((List<Apttus_Config2__LineItem__c>)Records, null);
    }
    
    /**
     * This method is used for after insert of the Line Item trigger.
     * @return void
     */
    public override void onAfterInsert() {}
    
    /**
     * This method is used for before update of the Line Item trigger.
     * @params  existingRecords Map<Id, SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_LineItem.trackChangeOnLineItem((List<Apttus_Config2__LineItem__c>)Records, (Map<Id, Apttus_Config2__LineItem__c>)existingRecords);
    }
    
    /**
     * This method is used for after update of the Line Item trigger. 
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {}
	
    /**
     * This method is used for before Delete of the Line Item trigger.
     * @return void
     */
    public override void onBeforeDelete() {}
	
    /**
     * This method is used for after Delete of the Line Item trigger.
     * @return void
     */
    public override void onAfterDelete() {}
}