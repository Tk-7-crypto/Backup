/**
 * This is Assignment trigger handler class.
 * version : 1.0
 */
public class DAO_Assignment extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();
    Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
    /**
     * Constructor of this class
     * @params sObjectList List<pse__Assignment__c>
     */
    public DAO_Assignment(List<pse__Assignment__c> sObjectList) {
        super(sObjectList);

        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());

    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Assignment(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the Assignment trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OWF_Assignment.updateRecordTypeId((List<pse__Assignment__c>)Records,null); 
        DAOH_OWF_Assignment.validateAssignmentForSubGroup((List<pse__Assignment__c>)Records);  
        DAOH_OWF_Assignment.updateAssignmentOwner((List<pse__Assignment__c>)Records,null);
        DAOH_OWF_Assignment.updateFieldsWhenStatusAndResourceChanged((List<pse__Assignment__c>)Records,null);
        DAOH_OWF_Assignment.updateEffortEstimation((List<pse__Assignment__c>)Records);
        DAOH_OWF_Assignment.insertOpportunityNameInAssignment((List<pse__Assignment__c>)Records); 
        DAOH_PSA_Assignment.validate_RDS_Assignment((List<pse__Assignment__c>)Records,null,methodToRecordTypeMap); 
        DAOH_PSA_Assignment.fieldUpdateOnCreation((List<pse__Assignment__c>)Records,null,methodToRecordTypeMap);
        if (methodToRecordTypeMap.get('fieldAutomations') != null) {
            DAOH_PSA_Assignment.fieldAutomations((List<pse__Assignment__c>)Records,null,methodToRecordTypeMap);
        }
        DAOH_PSA_Assignment.populateResourceLanguageSkillSet((List<pse__Assignment__c>)Records,null);
        DAOH_PSA_Assignment.updateActiveResourceOnProject((List<pse__Assignment__c>)Records,null);
    }
    
    /**
     * This method is used for after insert of the Assignment trigger.
     * @return void
     */
    public override void onAfterInsert() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OWF_Assignment.populateRollupAssignmentFieldsOnContact((List<pse__Assignment__c>)Records,null);
        //DAOH_OWF_Assignment.updateAgreementOwnerByAssignment((List<pse__Assignment__c>)Records,null);  
        //DAOH_OWF_Assignment.updateBudgetAnalystAssignedByAssignment((List<pse__Assignment__c>)Records, null);
        DAOH_OWF_Assignment.updateRrStatus((List<pse__Assignment__c>)Records,null); 
        UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
        if(DAOH_OWF_Assignment.runOnce() && !System.isBatch()){
            DAOH_OWF_Assignment.updateScheduleHours((List<pse__Assignment__c>)Records,null);
        }
        DAOH_OWF_Assignment.populateDueDateatAssignmentAndDateLeadPDAssigned((List<pse__Assignment__c>)Records,null);
        UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));

        if (methodToRecordTypeMap.get('syncServiceLineLeads') != null) {
            DAOH_PSA_Assignment.syncServiceLineLeads((List<pse__Assignment__c>)Records,null,methodToRecordTypeMap);
        }
        DAOH_OWF_Assignment.sendEmailbyWorkflowEmailRecord((List<pse__Assignment__c>) records, null);
    }
         
    /**
    * This method is used for Before update of the Assignment trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OWF_Assignment.updateAssignmentOwner((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
        DAOH_OWF_Assignment.updateFieldsWhenStatusAndResourceChanged((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
    	DAOH_OWF_Assignment.makeAssignmentTriggerReady((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
	    //DAOH_OWF_Assignment.validateEffortEstimation((List<pse__Assignment__c>)Records,(Map<Id, pse__Assignment__c>)existingRecords);
        DAOH_PSA_Assignment.updateActiveWhenStatusClosed((List<pse__Assignment__c>)Records,(Map<Id, pse__Assignment__c>)existingRecords);
        DAOH_PSA_Assignment.validate_RDS_Assignment((List<pse__Assignment__c>)Records,(Map<Id, pse__Assignment__c>)existingRecords,methodToRecordTypeMap); 
        if (methodToRecordTypeMap.get('fieldAutomations') != null) {
            DAOH_PSA_Assignment.fieldAutomations((List<pse__Assignment__c>)Records,(Map<Id, pse__Assignment__c>)existingRecords,methodToRecordTypeMap);
        }
        if(!mulesoftSetting.Ignore_Validation_Rules__c){
            DAOH_OWF_Assignment.restrictOWFUserForAssignmentStatusToCancelled((List<pse__Assignment__c>) Records, (Map<Id, pse__Assignment__c>) existingRecords);
        }
	DAOH_PSA_Assignment.updateActiveResourceOnProject((List<pse__Assignment__c>)Records,(Map<Id, pse__Assignment__c>)existingRecords);

    }
    
    /**
     * This method is used for after update of the Assignment trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if(DAOH_OWF_Assignment.runOnce() && !System.isBatch()){
            DAOH_OWF_Assignment.updateScheduleHours((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
        }
        UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
        
        if(!System.isBatch())
        {
        	DAOH_OWF_Assignment.createClinicalBidResRequestsOnAssignmentUpdate((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);    
        }
        
        UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
        DAOH_OWF_Assignment.createSkillCertRatingsOnAssignCompleted((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
        DAOH_OWF_Assignment.createSuggestedResourcesWhenAssignmentIsRejected((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
        DAOH_OWF_Assignment.populateRollupAssignmentFieldsOnContact((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
       	DAOH_OWF_Assignment.updateAgreementOwnerByAssignment((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
        DAOH_OWF_Assignment.updateBudgetAnalystAssignedByAssignment((List<pse__Assignment__c>)Records, (Map<Id, pse__Assignment__c>)existingRecords);
        DAOH_OWF_Assignment.updateRelatedFieldsOnRejected((List<pse__Assignment__c>)Records,(Map<Id, pse__Assignment__c>)existingRecords);
        DAOH_PSA_Assignment.updateScheduleEndDateWhenStatusClosed((List<pse__Assignment__c>)Records,(Map<Id, pse__Assignment__c>)existingRecords);
        UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));

        if (methodToRecordTypeMap.get('syncServiceLineLeads') != null) {
            DAOH_PSA_Assignment.syncServiceLineLeads((List<pse__Assignment__c>)Records,(Map<Id, pse__Assignment__c>)existingRecords,methodToRecordTypeMap);
        }
    }
    
    /**
     * This method is used for after delete of the Assignment trigger.
     * @return void
     */
     
    public override void onAfterDelete() {
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OWF_Assignment.populateRollupAssignmentFieldsOnContact((List<pse__Assignment__c>)Records,null);
        DAOH_PSA_Assignment.updateActiveResourceOnProject(null,(Map<Id, pse__Assignment__c>)existingRecords);
    }  
    public override void onBeforeDelete() {
    DAOH_PSA_Assignment.deleteNonBillableProject((Map<Id, pse__Assignment__c>)existingRecords);
}
}
