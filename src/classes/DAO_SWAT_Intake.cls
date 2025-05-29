/**
 * This is SWAT_Intake Domain class.
 * version : 1.0
 */
public class DAO_SWAT_Intake extends fflib_SObjectDomain {
/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_SWAT_Intake(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_SWAT_Intake(sObjectList);
        }
    }
    
    
    /**
     * This method is used for before insert of the SWAT_Intake trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_SWAT_Intake.checkPreviousSwatRecord((List<SWAT_Intake__c>)Records, null);
    }
    /**
     * This method is used for after insert of the SWAT_Intake trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_SWAT_Intake.sendEmailToSwat((List<SWAT_Intake__c>)Records, null);
    }
    /**
     * This method is used for before update of the SWAT_Intake trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_SWAT_Intake.sendEmailToSwat((List<SWAT_Intake__c>)Records,  (Map<Id, SWAT_Intake__c>)existingRecords);
    }
    /**
     * This method is used for after update of the Account trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) { 
        
    }    
}