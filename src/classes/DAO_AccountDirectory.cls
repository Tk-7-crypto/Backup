public class DAO_AccountDirectory extends fflib_SObjectDomain{
	/**
     * Constructor of this class
     * @params sObjectList List<Account_Directory__c>
     */
    public DAO_AccountDirectory(List<Account_Directory__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_AccountDirectory(sObjectList);
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
    
    
    public override void onBeforeInsert() {
        DAOH_AccountDirectory.inActiveOldRecord((List<Account_Directory__c>) records);
    }

}