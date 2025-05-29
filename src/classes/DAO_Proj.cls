/**
 * This is Project (pse__Proj__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Proj extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();
    private static boolean isRunningQUE_PSA_ApplyRDSProjectTaskTemplates = false;
    

    /**
     * Constructor of this class
     * @params sObjectList List<pse__Proj__c>
     */
    public DAO_Proj(List<pse__Proj__c> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Proj(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Project (pse__Proj__c) trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        CON_PSA.isSkipValidationFieldValidationsRDS = true;
        if (methodToRecordTypeMap.get('updateServiceLineProjectFields') != null) {
            DAOH_PSA_Project.updateServiceLineProjectFields((List<pse__Proj__c>) records, null, methodToRecordTypeMap);
        }
        if (methodToRecordTypeMap.get('setRDSProjectFields') != null) {
            DAOH_PSA_Project.setRDSProjectFields((List<pse__Proj__c>) records, null, methodToRecordTypeMap);
        }
        DAOH_OWF_Proj.checkExistingProjectForAgreement((List<pse__Proj__c>)records);
    }

    /**
    * This method is used for before update of the Project trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run in a normal sequence are included.  
        if (methodToRecordTypeMap.get('updateServiceLineProjectFields') != null) {
            DAOH_PSA_Project.updateServiceLineProjectFields((List<pse__Proj__c>) records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('setRDSProjectFields') != null) {
            DAOH_PSA_Project.setRDSProjectFields((List<pse__Proj__c>) records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('QUE_PSA_ApplyRDSProjectTaskTemplates') != null) {
            DAOH_PSA_Project.applyTemplateChecklistTasks((List<pse__Proj__c>)Records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }
        DAOH_PSA_Project.fieldValidationsRDS((List<pse__Proj__c>) records, (Map<Id,pse__Proj__c>) existingRecords);
        DAOH_PSA_Project.enableAccountChkboxForBatchProcessing((List<pse__Proj__c>) records , (Map<Id,pse__Proj__c>) existingRecords);
    }
    
    /**
     * This method is used for after insert of the Project (pse__Proj__c) trigger.
     * @return void
     */
    public override void onAfterInsert() {
        if (methodToRecordTypeMap.get('rollUpActuals') != null) {
            DAOH_PSA_Project.rollUpActuals((List<pse__Proj__c>)Records, null, methodToRecordTypeMap);
        }    

        /*if (methodToRecordTypeMap.get('cascadeToServiceLineProjects') != null) {
            CON_PSA.isSkipValidationFieldValidationsRDS = true;
            DAOH_PSA_Project.cascadeToServiceLineProjects((List<pse__Proj__c>)Records, null, methodToRecordTypeMap);
        }*/   
        
        DAOH_OWF_Proj.createRRBasedOnAgrAssociatedWithProj((List<pse__Proj__c>)records);
        DAOH_OWF_Proj.createClinicalBidRRsBasedOnBidNoOfProjects((List<pse__Proj__c>)records);
        DAOH_OWF_Proj.createRRForContractPostAwardBids((List<pse__Proj__c>)records);
        DAOH_OWF_Proj.createRRForCSSBids((List<pse__Proj__c>)records);
        UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
    }

    /**
     * This method is used for after update of the project trigger.
     * @return  void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {        
        if (methodToRecordTypeMap.get('updatePMFieldOnRR') != null) {
            DAOH_PSA_Project.updatePMFieldOnRR((List<pse__Proj__c>)Records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('updatePMFieldOnMilestones') != null) {
            DAOH_PSA_Project.updatePMFieldOnMilestones((List<pse__Proj__c>)Records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('closeRelatedAssignments') != null) {
            DAOH_PSA_Project.closeRelatedAssignments((List<pse__Proj__c>)Records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }

        if (methodToRecordTypeMap.get('rollUpActuals') != null) {
            DAOH_PSA_Project.rollUpActuals((List<pse__Proj__c>)Records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }   

        /*if (methodToRecordTypeMap.get('cascadeToServiceLineProjects') != null) {
            CON_PSA.isSkipValidationFieldValidationsRDS = true;
            DAOH_PSA_Project.cascadeToServiceLineProjects((List<pse__Proj__c>)Records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }*/   

        if(methodToRecordTypeMap.get('syncProjectScopeFields') != null) {
            CON_PSA.isSkipValidationFieldValidationsRDS = true;
            DAOH_PSA_Project.syncProjectScopeFields((List<pse__Proj__c>)Records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
        }
        DAOH_PSA_Project.updateAssignmentCheckListTaskOnChangeOrder((List<pse__Proj__c>) records , (Map<Id,pse__Proj__c>) existingRecords);
        DAOH_PSA_Project.updateProjectTask((List<pse__Proj__c>) records , (Map<Id,pse__Proj__c>) existingRecords);
        DAOH_PSA_Project.updateProjectTaskWorkFlowCondition((List<pse__Proj__c>) records , (Map<Id,pse__Proj__c>) existingRecords);
        DAOH_PSA_Project.deleteDeselectedSlScopeProjectTasks((List<pse__Proj__c>)Records, (Map<Id,pse__Proj__c>) existingRecords, methodToRecordTypeMap);
    }

    /**
     * This method is used for after insert of the Project (pse__Proj__c) trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        DAOH_OWF_Proj.deleteResourceRequestBasedOnProject((List<pse__Proj__c>)records);
        DAOH_PSA_Project.validateDeletion((List<pse__Proj__c>)Records);
    }
} 
