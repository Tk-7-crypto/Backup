/**
 * This is Days Off trigger handler class.
 * version : 1.0
 */
public class DAO_Days_Off extends fflib_SObjectDomain {
    
    /**
     * Constructor of this class
     * @params sObjectList List<Days_Off__c>
     */
    public DAO_Days_Off(List<Days_Off__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Days_Off(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the Days Off trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.       
        DAOH_OWF_Day_Off.upsertRelatedAssignmentAndSchedule((List<Days_Off__c>)Records,null);
        
    }
    
    
    /**
     * This method is used for after update of the Days Off trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OWF_Day_Off.upsertRelatedAssignmentAndSchedule((List<Days_Off__c>)Records, (Map<Id, Days_Off__c>)existingRecords);
    }
    
    /**
     * This method is used for after delete of the Days Off trigger.
     * @return void
     */
     
    public override void onAfterDelete() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OWF_Day_Off.upsertRelatedAssignmentAndSchedule((List<Days_Off__c>)Records,null);
        
    }  
 
}