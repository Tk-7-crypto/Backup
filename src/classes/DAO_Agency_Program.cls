public class DAO_Agency_Program extends fflib_SObjectDomain{
     /**
     * Constructor of this class
     * @params sObjectList List<DAO_Agency_Program>
     */
    public DAO_Agency_Program(List<Agency_Program__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Agency_Program(sObjectList);
        }
    }
    
    
    /**
     * This method is used for before insert of the Contract trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_Agency_Program.activateAgencyProgram(records, null);
    }
    
    /**
     * This method is used for before update of the Contract trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_Agency_Program.activateAgencyProgram(records, (Map<Id, Agency_Program__c>)existingRecords);
    }
    
    public override void onAfterInsert() {
    } 

}