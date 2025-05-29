/**
 * This is Milestone (pse__Milestone__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Milestone extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<pse__Milestone__c>
     */
    public DAO_Milestone(List<pse__Milestone__c> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Milestone(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        DAOH_PSA_Milestone.setFieldsOnUpdate((List<pse__Milestone__c>)Records, (Map<Id,pse__Milestone__c>) existingRecords);
        if (methodToRecordTypeMap.get('setServiceMilestoneFields') != null) {
            DAOH_PSA_Milestone.setServiceMilestoneFields((List<pse__Milestone__c>)Records, methodToRecordTypeMap);
        }
    }

     /**
    * This method is used for before update of the Milestone trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Milestone.setFieldsOnUpdate((List<pse__Milestone__c>)Records, (Map<Id,pse__Milestone__c>) existingRecords);
        if (methodToRecordTypeMap.get('QUE_PSA_ApplyRDSMetricTemplates') != null) {
            DAOH_PSA_Milestone.applyTemplateMetrics((List<pse__Milestone__c>)Records, (Map<Id,pse__Milestone__c>) existingRecords, methodToRecordTypeMap);
        }
    }

    public override void onAfterInsert() {
        if (methodToRecordTypeMap.get('rollUpActuals') != null) {
            DAOH_PSA_Milestone.rollUpActuals((List<pse__Milestone__c>)Records, null, methodToRecordTypeMap);
        }    
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        if (methodToRecordTypeMap.get('updateProjectTaskBilling') != null) {
            DAOH_PSA_Milestone.updateProjectTaskBilling((List<pse__Milestone__c>)Records, (Map<Id, pse__Milestone__c>)existingRecords, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('rollUpActuals') != null) {
            DAOH_PSA_Milestone.rollUpActuals((List<pse__Milestone__c>)Records, (Map<Id, pse__Milestone__c>)existingRecords, methodToRecordTypeMap);
        }    
    }
    
    /**
     * This method is used for before delete of the Milestone (pse__Milestone__c) trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        DAOH_PSA_Milestone.validateDeletion((List<pse__Milestone__c>)records);
    }
}
