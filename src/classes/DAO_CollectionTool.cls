public class DAO_CollectionTool extends fflib_SObjectDomain{
    /**
    * Constructor of this class
    * @params sObjectList List<Bid_History__c>
	*/
    public DAO_CollectionTool(List<Bid_History__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_CollectionTool(sObjectList);
        }
    }
    
    /**
    * Unit of Work instance for CRUD operation
    */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
        new Schema.SObjectType[] {
            Outbound_Message_Deletion_queue__c.SobjectType
                }
    );
    
    public override void onApplyDefaults() {
    }
    
    /**
    * This method is used for before insert of the CollectionTool trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_CollectionTool_Trigger__c){		   
            //This is the section where all the methods that needs to be run in a normal sequence are included.
            DAOH_OWF_CollectionTool.updateRevLabID((List<CollectionTool__c>)records,null);
            
        }
    }
    
    /**
    * This method is used for after insert of the CollectionTool trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run at first are included.
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_CollectionTool_Trigger__c){
            DAOH_OWF_CollectionTool.updateRevLabID((List<CollectionTool__c>)records,(Map<Id, CollectionTool__c>)existingRecords);
            //This has to be the last function call. Any method calling should be above this	   		   
        }
    }
}