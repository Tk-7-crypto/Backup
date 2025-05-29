public class DAO_CountrySalesHead extends fflib_SObjectDomain{
	/**
     * Constructor of this class
     * @params sObjectList List<Country_Sales_Head__c>
     */
    public DAO_CountrySalesHead(List<Country_Sales_Head__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_CountrySalesHead(sObjectList);
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
        DAOH_CountrySalesHead.inActiveOldRecord((List<Country_Sales_Head__c>) records);
    }
}