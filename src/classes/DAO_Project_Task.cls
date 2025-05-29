/**
 * This is Project Task trigger handler class.
 * version : 1.0
 */
public class DAO_Project_Task extends fflib_SObjectDomain {

    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();
    public static boolean taskValidationRanOnce = false;

    /**
     * Constructor of this class
     * @params sObjectList List<pse__Project_Task__c>
     */
    public DAO_Project_Task(List<pse__Project_Task__c> sObjectList) {
        super(sObjectList);
        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Project_Task(sObjectList);
        }
    }

    /**
    * This method is used for before insert of the Project Task trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if (methodToRecordTypeMap.get('setFieldUpdates') != null) {
            DAOH_PSA_Project_Task.setFieldUpdates((List<pse__Project_Task__c>)Records,null, methodToRecordTypeMap);
        }

        if (!taskValidationRanOnce) {
            if (methodToRecordTypeMap.get('taskValidationsRDS') != null) {
                DAOH_PSA_Project_Task.taskValidationsRDS((List<pse__Project_Task__c>)Records, null, methodToRecordTypeMap );
            }
        }

        if (methodToRecordTypeMap.get('applyDateOffsets') != null) {
            DAOH_PSA_Project_Task.applyDateOffsets((List<pse__Project_Task__c>)Records, methodToRecordTypeMap);
        }
        DAOH_PSA_Project_Task.setRDSProjTaskCheck((List<pse__Project_Task__c>)Records, null, methodToRecordTypeMap);
        DAOH_PSA_Project_Task.updateConditionForWorkFlow((List<pse__Project_Task__c>) Records, null);
        DAOH_PSA_Project_Task.updateTriggerPastDueWorkflowField((List<pse__Project_Task__c>) Records, null);
    }

    /**
    * This method is used for before update of the Project Task trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if (methodToRecordTypeMap.get('setFieldUpdates') != null) {
            DAOH_PSA_Project_Task.setFieldUpdates((List<pse__Project_Task__c>)Records,(Map<Id, pse__Project_Task__c>)existingRecords, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('captureTopLevelDeletion') != null) {
            DAOH_PSA_Project_Task.captureTopLevelDeletion((List<pse__Project_Task__c>)Records,(Map<Id, pse__Project_Task__c>)existingRecords, methodToRecordTypeMap);
        }

        if (!taskValidationRanOnce) {
            if (methodToRecordTypeMap.get('taskValidationsRDS') != null) {
                DAOH_PSA_Project_Task.taskValidationsRDS((List<pse__Project_Task__c>)Records, (Map<Id, pse__Project_Task__c>)existingRecords, methodToRecordTypeMap);
            }
        }

        if (methodToRecordTypeMap.get('applyDateOffsets') != null) {
            DAOH_PSA_Project_Task.applyDateOffsets((List<pse__Project_Task__c>)Records, methodToRecordTypeMap);
        }
        DAOH_PSA_Project_Task.setRDSProjTaskCheck((List<pse__Project_Task__c>)Records,(Map<Id, pse__Project_Task__c>)existingRecords, methodToRecordTypeMap);
        
        /*
         * IQVIAPSA-4514
         */
        DAOH_PSA_Project_Task.updateResource((List<pse__Project_Task__c>) Records, (Map<Id, pse__Project_Task__c>) existingRecords);
        DAOH_PSA_Project_Task.updateConditionForWorkFlow((List<pse__Project_Task__c>) Records, (Map<Id, pse__Project_Task__c>) existingRecords);
        DAOH_PSA_Project_Task.updateTriggerPastDueWorkflowField((List<pse__Project_Task__c>) Records, (Map<Id, pse__Project_Task__c>) existingRecords);
    }

    /**
    * This method is used for after insert of the Project Task trigger.
    * @return void
    */
    public override void onAfterInsert() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if (methodToRecordTypeMap.get('addPricingTasks') != null) {
            DAOH_PSA_Project_Task.addPricingTasks((List<pse__Project_Task__c>)Records,null, methodToRecordTypeMap);
        }
        if (methodToRecordTypeMap.get('addPricingTaskTemplateTasks') != null) {
            DAOH_PSA_Project_Task.addPricingTaskTemplateTasks((List<pse__Project_Task__c>)Records,null, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('rollUpActuals') != null) {
            DAOH_PSA_Project_Task.rollUpActuals((List<pse__Project_Task__c>)Records,null, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('allAuditMethods') != null) {
            DAOH_PSA_Project_Task.insertAuditLogOnUpdate((List<pse__Project_Task__c>)Records, null, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('crossReferenceAggregateReports') != null) {
            DAOH_PSA_Project_Task.crossReferenceAggregateReports((List<pse__Project_Task__c>)Records, null, methodToRecordTypeMap);
        }
    }

    /**
    * This method is used for after update of the Project Task trigger.
    * @return void
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if (methodToRecordTypeMap.get('rollUpActuals') != null) {
            DAOH_PSA_Project_Task.rollUpActuals((List<pse__Project_Task__c>)Records, (Map<Id, pse__Project_Task__c>)existingRecords, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('allAuditMethods') != null) {
            DAOH_PSA_Project_Task.insertAuditLogOnUpdate((List<pse__Project_Task__c>)Records, (Map<Id, pse__Project_Task__c>)existingRecords, methodToRecordTypeMap);
        }
    }

    /**
    * This method is used for before delete of the Project Task trigger.
    * @return void
    */
    public override void onBeforeDelete() {
        if (methodToRecordTypeMap.get('taskValidationsRDS') != null) {
            DAOH_PSA_Project_Task.taskValidationsRDS((List<pse__Project_Task__c>)Records, null, methodToRecordTypeMap);
        }
    }

    /**
    * This method is used for before delete of the Project Task trigger.
    * @return void
    */
    public override void onAfterDelete() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.

        if (methodToRecordTypeMap.get('rollUpActuals') != null) {
            DAOH_PSA_Project_Task.rollUpActuals((List<pse__Project_Task__c>)Records, null, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('deleteDeliverableTasks') != null) {
            DAOH_PSA_Project_Task.deleteDeliverableTasks((List<pse__Project_Task__c>)Records, null, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('allAuditMethods') != null) {
            DAOH_PSA_Project_Task.insertAuditLog((List<pse__Project_Task__c>)Records,'DELETE', methodToRecordTypeMap);
        }
    }
} 
