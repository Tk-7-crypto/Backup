/**
 * This is Resource Request trigger handler class.
 * version : 1.0
 */
public class DAO_Resource_Request extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<pse__Resource_Request__c>
     */
    public DAO_Resource_Request(List<pse__Resource_Request__c> sObjectList) {
        super(sObjectList);

        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Resource_Request(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the pse__Resource_Request__c trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        
        DAOH_OWF_Resource_Request.validateManualResourceRequestCreator((List<pse__Resource_Request__c>)Records);
        DAOH_OWF_Resource_Request.populateRRFieldsFromAgreement((List<pse__Resource_Request__c>)Records);
        DAOH_OWF_Resource_Request.populateBidCategoryOnRR((List<pse__Resource_Request__c>)Records);
        DAOH_OWF_Resource_Request.populateProjectOnRR((List<pse__Resource_Request__c>)Records);
        DAOH_OWF_Resource_Request.setResourceRequestName((List<pse__Resource_Request__c>)Records, null);
        DAOH_OWF_Resource_Request.updateComplexityScoreTotal((List<pse__Resource_Request__c>)Records,null);
        if (methodToRecordTypeMap.get('updateRRWhileInsert') != null) {
            DAOH_PSA_Resource_Request.updateRRWhileInsert((List<pse__Resource_Request__c>)Records,methodToRecordTypeMap);
        } 
        DAOH_OWF_Resource_Request.setLeadSupportFlagOnResourceRequest((List<pse__Resource_Request__c>)Records);
        DAOH_OWF_Resource_Request.populateOriginalAssigneeForPostAwards((List<pse__Resource_Request__c>)Records);
        DAOH_PSA_Resource_Request.updateResourceRequestStatus((List<pse__Resource_Request__c>) records, (Map<Id,pse__Resource_Request__c>) existingRecords);
        DAOH_OWF_Resource_Request.populateGroupOnResourceRequest((List<pse__Resource_Request__c>)Records);

    }
    
    /**
     * This method is used for after insert of the pse__Resource_Request__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_OWF_Resource_Request.createResourceSkillRequest((List<pse__Resource_Request__c>)Records);
        DAOH_OWF_Resource_Request.createResourceSkillRequestForGBO((List<pse__Resource_Request__c>)Records);
        DAOH_OWF_Resource_Request.createAssignments((List<pse__Resource_Request__c>)Records);
        DAOH_OWF_Resource_Request.createAssignmentsForClosedBDRR((List<pse__Resource_Request__c>)Records);
        UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
    }
    
    /**
     * This method is used for before update of the pse__Resource_Request__c trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_OWF_Resource_Request.validateStartEndDateforTriageManager((List<pse__Resource_Request__c>)Records, (Map<Id, pse__Resource_Request__c>)existingRecords);
        DAOH_OWF_Resource_Request.setResourceRequestName((List<pse__Resource_Request__c>)Records, (Map<Id, pse__Resource_Request__c>)existingRecords);
        DAOH_OWF_Resource_Request.updateComplexityScoreTotal((List<pse__Resource_Request__c>)Records,(Map<Id, pse__Resource_Request__c>)existingRecords);
        DAOH_OWF_Resource_Request.updateDataBasedOnOASetting((List<pse__Resource_Request__c>)Records, (Map<Id, pse__Resource_Request__c>)existingRecords);    
        DAOH_PSA_Resource_Request.updateResourceRequestStatus((List<pse__Resource_Request__c>) records, (Map<Id,pse__Resource_Request__c>) existingRecords);
}
    
    /**
     * This method is used for after update of the pse__Resource_Request__c trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        //IQVIACBEX-1804:Added a call to process the sync logic between Salesforce and Unity.
        DAOH_CBEx_Resource_Request.setUnityFlagSyncMechanism(new Map<Id, pse__Resource_Request__c>((List<pse__Resource_Request__c>)Records), (Map<Id, pse__Resource_Request__c>)existingRecords);
        DAOH_OWF_Resource_Request.cancelRelatedAssignments((List<pse__Resource_Request__c>)Records, (Map<Id, pse__Resource_Request__c>)existingRecords);
        DAOH_OWF_Resource_Request.populateRollupAssignmentFieldsOnContact((List<pse__Resource_Request__c>)Records, (Map<Id, pse__Resource_Request__c>)existingRecords);
        DAOH_OWF_Resource_Request.updateAssignmentStartAndEndDate((List<pse__Resource_Request__c>)Records, (Map<Id, pse__Resource_Request__c>)existingRecords);
    }
    
    /**
     * This method is used for before Delete of the pse__Resource_Request__c trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        DAOH_OWF_Resource_Request.deleteAssignmentBasedOnResourceRequest((List<pse__Resource_Request__c>)records);
    }
}