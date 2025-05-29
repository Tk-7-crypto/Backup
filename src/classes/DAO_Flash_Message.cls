/**
 * This is Flash_Message Domain class.
 * version : 1.0
 */
public class DAO_Flash_Message extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_Flash_Message(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Flash_Message(sObjectList);
        }
    }
    
      /**
     * This method is used for before insert of the Flash_Information trigger.
     * @return void
     */
    public override void onBeforeInsert() {
             //DAOH_Flash_Message.InsertRecords(Records);
    }
    public override void onAfterInsert() {
        DAOH_Flash_Message.InsertRecords(Records);
    }
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        DAOH_Flash_Message.UpdateRecord(Records,(Map<Id, Flash_Message__c>)existingRecords);
    }

}