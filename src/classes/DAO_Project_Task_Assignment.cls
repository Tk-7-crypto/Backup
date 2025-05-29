/**
 * This is Project Task Assignment trigger handler class.
 * version : 1.0
 */

public class DAO_Project_Task_Assignment extends fflib_SObjectDomain {

    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     */
    public DAO_Project_Task_Assignment(List<pse__Project_Task_Assignment__c> sObjectList) {
        super(sObjectList);

        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Project_Task_Assignment(sObjectList);
        }
    }

    /**
    * This method is used for after insert of the Project Task Assignmenttrigger.
    * @return void
    */
    public override void onBeforeInsert() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.       
        if (methodToRecordTypeMap.get('setPrimaryResourceOnTask') != null) {
            DAOH_PSA_Project_Task_Assignment.setPrimaryResourceOnTask((List<pse__Project_Task_Assignment__c>)Records,null, methodToRecordTypeMap);
        }
    }
         
    /**
    * This method is used for after update of the Project Task trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if (methodToRecordTypeMap.get('setPrimaryResourceOnTask') != null) {
            DAOH_PSA_Project_Task_Assignment.setPrimaryResourceOnTask((List<pse__Project_Task_Assignment__c>)Records, (Map<Id, pse__Project_Task_Assignment__c>)existingRecords, methodToRecordTypeMap);
        }      
    }
}