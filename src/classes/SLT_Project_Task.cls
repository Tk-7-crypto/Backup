public class SLT_Project_Task extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Task() {
        super(true, false, false);
    }
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return pse__Project_Task__c.sObjectType;
    }

    /**
     * This method gets a list of field names from a fieldset, by fieldset name
     */
    public List<String> getFieldListByFieldSetName(String fieldsetName){
        List<String> fieldNames = new List<String>();
        List<Schema.FieldSetMember> fields = Schema.SObjectType.pse__Project_Task__c.fieldSets.getMap().get(fieldsetName).getFields();
        for(Schema.FieldSetMember field : fields){
            fieldNames.add(field.getFieldPath());
        }
        return fieldNames;
    }

    /**
     * This method gets a list of field names from a fieldset, by fieldset name
     */
    public List<String> getFieldListByFieldSetName(Set<String> fieldsetNames){
        Set<String> fieldNames = new Set<String>();
        Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.pse__Project_Task__c.fieldSets.getMap();
        for(String fieldsetName : fieldsetNames) {
            if(fieldSetMap.get(fieldsetName) == null){
                throw new SelectorException('Cannot find field set with name "'+fieldsetName+'" on Project Task. Please check your deliverable field set mapping metadata settings.');
            }
            List<Schema.FieldSetMember> fields = fieldSetMap.get(fieldsetName).getFields();
            for(Schema.FieldSetMember field : fields){
                fieldNames.add(field.getFieldPath());
            }
        }
        return new List<String>(fieldNames);
    }

    /**
     * This method used to get Project Task by Id
     * @return  Map<Id, pse__Project_Task__c >
     */
    public Map<Id, pse__Project_Task__c > getProjectTaskById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, pse__Project_Task__c >((List<pse__Project_Task__c >) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    /**
     * This method used to get Project Task by Id Set and Condition
     * @return  List<pse__Project_Task__c >
     */
    public List<pse__Project_Task__c > getProjectTaskByIdAndCondition(Set<ID> idSet, Set<String> fieldSet, String projectTaskCondition) {
        fflib_QueryFactory taskQueryFactory = newQueryFactory(true);
        String PROJ_STAGE_CANCELED = CON_PSA.PROJ_STAGE_CANCELED;
        String PROJ_STAGE_COMPLETED = CON_PSA.PROJ_STAGE_COMPLETED;
        String PROJ_STAGE_ON_HOLD = CON_PSA.PROJ_STAGE_ON_HOLD;
        Id RDS_Project_Id = Id.valueOf(CON_PSA.PROJ_REC_TYPE_ID_RDS_PROJECT);
        Id RDS_Service_Line_Id = Id.valueOf(CON_PSA.PROJ_REC_TYPE_ID_RDS_SERVICELINE);
        
        String idSetCondition = (projectTaskCondition.length() == 0) ? ' Id IN: idSet' : ' AND Id IN: idSet';
        String queryString = taskQueryFactory.selectFields(fieldSet).setCondition(projectTaskCondition + idSetCondition).toSOQL();
        return (List<pse__Project_Task__c>) Database.query(queryString);
    }
    
    /**
     * This method used to get Project Task by service code
     */
    public List<pse__Project_Task__c > getTemplateTasksByServiceCode(Set<String> idSet, Set<String> fieldSet) {
        Id templateRecordTypetId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Template_Task').getRecordTypeId();
        return new List<pse__Project_Task__c >((List<pse__Project_Task__c >) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Service_Code__c in :idSet and RecordTypeId = :templateRecordTypetId').toSOQL()));
    }

    /**
     * This method used to get Project Task by service line
     */
    public List<pse__Project_Task__c> getTemplateTasksByServiceLine(Set<String> idSet, Set<String> fieldSet) {
        Id templateRecordTypetId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Template_Task').getRecordTypeId();
        return new List<pse__Project_Task__c >((List<pse__Project_Task__c >) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Service_Line__c in :idSet and RecordTypeId = :templateRecordTypetId and Type__c = \'Deliverable Task\' and Pricing_Task_ID__c = null').toSOQL()));
    }

    /**
     * This method used to get Deliverables by service milestone 
     */
    public List<pse__Project_Task__c> getDeliverableByServiceMilestone(Set<String> idSet, Set<String> fieldSet) {
        Id deliverableRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable').getRecordTypeId();
        Id deliverableTaskRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable_Task').getRecordTypeId();
        Set <Id> recordTypes = new Set<Id>();
        recordTypes.add(deliverableRecordTypeId);
        recordTypes.add(deliverableTaskRecordTypeId);
        return new List<pse__Project_Task__c >((List<pse__Project_Task__c >) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Milestone__c in :idSet and RecordTypeId in :recordTypes').toSOQL()));
    }

    /**
     * This method gets project tasks by Program__c
     * @return List<pse__Project_Task__c>
     */
     public List<pse__Project_Task__c> getProjectTasksByProgram(Set<Id> programIdSet, Set<String> fieldSet){
        fflib_QueryFactory taskQueryFactory = newQueryFactory(true);
        String queryString = taskQueryFactory.selectFields(fieldSet).setCondition('Program__c IN :programIdSet').toSOQL();
        return (List<pse__Project_Task__c>) Database.query(queryString);
     }

    /**
     * This method gets project tasks by service Line project 
     * @return List<pse__Project_Task__c>
     */
     public List<pse__Project_Task__c> getProjectTasksByServiceLineProject(Set<Id> projectIdSet, Set<String> fieldSet){
        fflib_QueryFactory taskQueryFactory = newQueryFactory(true);
        String queryString = taskQueryFactory.selectFields(fieldSet).setCondition('pse__Project__c IN :projectIdSet').toSOQL();
        return (List<pse__Project_Task__c>) Database.query(queryString);
     }
    
    /**
     * This method gets project tasks by service Task Template Id with type conditions
     * @return List<pse__Project_Task__c>
     */
     public List<pse__Project_Task__c> getProjectTasksByTaskTemplateIdwithTypeConditions( Set<Id> templateTaskIds, String typeConditions, Set<String> fieldSet){
        fflib_QueryFactory taskQueryFactory = newQueryFactory(true);
        String queryString = taskQueryFactory.selectFields(fieldSet).setCondition(typeConditions).toSOQL();
        return (List<pse__Project_Task__c>) Database.query(queryString);
     }
    
    /*
     * This method gets project tasks by service Line project where RecordType.Name = 'RDS Project Task'
     * @return List<pse__Project_Task__c>
     */
     public List<pse__Project_Task__c> getRDSRecordTypeProjectTasksByServiceLineProject(Set<Id> projectIdSet, Set<String> fieldSet){
        fflib_QueryFactory taskQueryFactory = newQueryFactory(true);
        String queryString = taskQueryFactory.selectFields(fieldSet).setCondition('pse__Project__c IN :projectIdSet and RecordType.Name = \'RDS Project Task\'' ).toSOQL();
        return (List<pse__Project_Task__c>) Database.query(queryString);
     }
    
    /*
     * This method gets project tasks by RDS project where RecordType.Name = 'RDS Project Task'
     * @return List<pse__Project_Task__c>
     */
     public List<pse__Project_Task__c> getRDSRecordTypeProjectTasksByRDSProject(Set<Id> projectIdSet, Set<String> fieldSet){
        fflib_QueryFactory taskQueryFactory = newQueryFactory(true);
        String queryString = taskQueryFactory.selectFields(fieldSet).setCondition('Parent_Project__c IN :projectIdSet and RecordType.Name = \'RDS Project Task\'' ).toSOQL();
        return (List<pse__Project_Task__c>) Database.query(queryString);
     }

    /**
     * This method gets subtask based on id chain
     * @return List<pse__Project_Task__c>
     */
     public List<pse__Project_Task__c> getDeliverableTasksforDeletion(Set<Id> projectParentTaskIdSet, Set<String> fieldSet){
        fflib_QueryFactory taskQueryFactory = newQueryFactory(true);
        id taskRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable_Task').getRecordTypeId();
        String queryString = taskQueryFactory.selectFields(fieldSet).setCondition('pse__Top_Level_Parent_Task__c in :projectParentTaskIdSet and recordtypeid = :taskRecordTypeId').toSOQL();
        return (List<pse__Project_Task__c>) Database.query(queryString);
     }

    /**
     * This method used to get template Project Task list by Pricing Task Id
     * @return  Map<Id, pse__Project_Task__c> key: Pricing_Task_Id --> pse__Project_Task__c
     */
    public Map<String, List<pse__Project_Task__c>> selectByPricingTaskId(Set<String> idSet,Set<String> fieldSet) {
        Map<String, List<pse__Project_Task__c>> returnMap = new Map<String, List<pse__Project_Task__c>>();

        Id templateRecordTypetId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Template_Task').getRecordTypeId();
        for (pse__Project_Task__c pt : (List<pse__Project_Task__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Pricing_Task_ID__c in :idSet and RecordTypeId = :templateRecordTypetId').toSOQL())) {
            
            List<pse__Project_Task__c> tempList = returnMap.get(pt.Pricing_Task_ID__c);
            
            if (tempList != null) {
                tempList.add(pt);
                returnMap.put(pt.Pricing_Task_ID__c, tempList);
            } else {
                returnMap.put(pt.Pricing_Task_ID__c, new List<pse__Project_Task__c>{pt});
            }
        }

        return returnMap;
    }

    /**
     * This method gets project tasks by their aggregate report
     */
    public List<pse__Project_Task__c> getProjectTasksByAggregateReport(Set<Id> reportIdSet, Set<String> fieldSet){
        return new List<pse__Project_Task__c>((List<pse__Project_Task__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Aggregate_Report__c IN :reportIdSet').toSOQL()));
    }

    /**
     * This method used to get Project Task list by Milestone Id
     */
    public List<pse__Project_Task__c> getProjectTasksByMilestone(Set<Id> milestoneIdSet, Set<String> fieldSet){
        return new List<pse__Project_Task__c>((List<pse__Project_Task__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Milestone__c IN :milestoneIdSet').toSOQL()));
    }

    /**
     * This method used to get Project Task list by Billing Milestone Id
     */
    public List<pse__Project_Task__c> getProjectTasksByBillingMilestone(Set<Id> milestoneIdSet, Set<String> fieldSet){
        return new List<pse__Project_Task__c>((List<pse__Project_Task__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Billing_Milestone__c IN :milestoneIdSet').toSOQL()));
    }
    
    /**
     * This method used to get All Eligible Project Tasks by ServiceName 
     * @return  Map<Id, pse__Project_Task__c >
     */
    public List<pse__Project_Task__c > selectAllEligibleDeliverables(String milestoneID, Set<String> fieldSet) {
        String EligibleForBilling='Yes';
        return ((List<pse__Project_Task__c >) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Milestone__r.id = :milestoneID and Eligible_for_Billing__c = :EligibleForBilling and Service__r.Name != null').toSOQL()));
    }
     
     /**
     * This method used to get All Hold Tasks by ServiceName 
     * @return  Map<Id, pse__Project_Task__c >
     */
    public List<pse__Project_Task__c > selectAllHoldDeliverables(String milestoneID,Set<String> fieldSet) {
        return ((List<pse__Project_Task__c >) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Milestone__r.id = :milestoneID and Billing_Hold__c = true and Service__r.Name != null').toSOQL()));
    }

   /**
     * This method used to get Project Task list by Milestone Id
     */
    public List<pse__Project_Task__c> getEligibleProjectTasksByMilestone(Set<Id> milestoneIdSet, Set<String> fieldSet){
        String EligibleForBilling='Yes';
        return new List<pse__Project_Task__c>((List<pse__Project_Task__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Milestone__c IN :milestoneIdSet and Eligible_for_Billing__c = :EligibleForBilling').toSOQL()));
    }

    /**
     * This method gets project tasks by their sd runs
     */
    public List<pse__Project_Task__c> getProjectTasksBySDRuns(Set<Id> reportIdSet, Set<String> fieldSet){
        return new List<pse__Project_Task__c>((List<pse__Project_Task__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('SD_Run_ID__c IN :reportIdSet').toSOQL()));
    }

    /**
     * This method gets project tasks by their Signal
     */
    public List<pse__Project_Task__c> getProjectTasksBySignal(Set<Id> signalIdSet, Set<String> fieldSet){
        return new List<pse__Project_Task__c>((List<pse__Project_Task__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Signal__c IN :signalIdSet').toSOQL()));
    }
    
    /**
     * This method used to get RDS Project Task list by Project Id
     * @return  Map<Id, pse__Project_Task__c> key: 
     */
    public Map<Id, List<pse__Project_Task__c>> selectProjTasksByProjId(Set<String> idSet,Set<String> fieldSet) {
        Map<Id, List<pse__Project_Task__c>> returnMap = new Map<Id, List<pse__Project_Task__c>>();

        Id rdsProjTaskRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Project_Task').getRecordTypeId();
        for (pse__Project_Task__c pt : (List<pse__Project_Task__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Project__c in :idSet and RecordTypeId = :rdsProjTaskRecordTypeId').toSOQL())) {
            
            List<pse__Project_Task__c> tempList = returnMap.get(pt.pse__Project__c);
            
            if (tempList != null) {
                tempList.add(pt);
                returnMap.put(pt.pse__Project__c, tempList);
            } else {
                returnMap.put(pt.pse__Project__c, new List<pse__Project_Task__c>{pt});
            }
        }

        return returnMap;
    }
	 /**
     * This method used to get projectTasks
     * @params  Set<Id> sObjectIdset
     * @params  Set<String> fieldSet
     * @return  List<pse__Project_Task__c>
     */
    public List<pse__Project_Task__c> getProjectTaskByIdSet(Set<Id> sObjectIdset, String condition, Set<String> fieldSet) {
        fflib_QueryFactory assignmentQueryFactory = newQueryFactory(true);
        String queryString = assignmentQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return new List<pse__Project_Task__c> ((List<pse__Project_Task__c>)Database.query(queryString));
    }

    /**
        Exception for failures in the selector class
     */
    public class SelectorException extends Exception {}
} 
