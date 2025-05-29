/*
 * @author Leo De Bruyn <ldebruyn@cldpartners.com>
 * Apex support methods for Custom Details Tab Lightning Web Component
 */

public with sharing class CNT_PSA_filteredDetailsTab {
    public CNT_PSA_filteredDetailsTab() {

    }

    @AuraEnabled(cacheable=true)
    public static List<String> getFieldSet(String type, String serviceCode, String serviceLineCode, String formSection){
        Set<String> formSectionsWithDefaults = new Set<String>{'Details', 'Billing', 'System'};
        Set<String> fieldsetNames = new Set<String>();
        List<String> fields = new List<String>();
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> mappings = new SLT_PSAServiceLineTaskFieldSetMapping().getTaskFieldSetMappings(type, serviceCode, serviceLineCode, formSection);
        if(mappings.size() == 0 && formSectionsWithDefaults.contains( formSection)){
            //Get the default one
            mappings = new SLT_PSAServiceLineTaskFieldSetMapping().getTaskFieldSetMappings(type, null, null, formSection);
        }
        if(CON_PSA.srvcLineToFieldMap.get(serviceCode) != null && formSection == CON_PSA.SRVC_LINE){
            fields = CON_PSA.srvcLineToFieldMap.get(serviceCode);
        }
        for(PSA_Service_Line_Task_Field_Set_Mapping__mdt mapping : mappings){
            fieldsetNames.add(mapping.Field_Set_Name__c);
        }
        if(formSection == 'Billing')
        {
            list<string> listToReturn = new SLT_Project_Task().getFieldListByFieldSetName(fieldsetNames);
            List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
            permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
            for(PermissionSetAssignment perRec: permissionSetList){
                if(perRec.PermissionSet.Name == 'RDS_ADMIN' || perRec.PermissionSet.Name == 'RDS_Project_Manager_and_Functional_Lead'){
                    listToReturn.add('Edit_Billing_Hold__c');
                    listToReturn.add('Edit_Exclude_from_Billing__c');
                }    
            }
            return listToReturn;
        }
        else{
            List<String> flm = new List<String>();
            if(fieldsetNames != null){
                flm = new SLT_Project_Task().getFieldListByFieldSetName(fieldsetNames);
            }
            if(fields != null){
                flm.addAll(fields);
            }
            return flm;
        }
    }

    @AuraEnabled
    public static List<Project_Metric__c> getValidMetricsForService(Id projectId, Id serviceLineId, Id serviceId){
        //Get PSA Metric Issues on Service Line
        SLT_PSA_Metric_Issue selector = new SLT_PSA_Metric_Issue();
        List<PSA_Metric_Issue__c> serviceLineIssues = selector.selectByServiceLine(serviceLineId, new Set<String>{'Id','PSA_Metric__c'});
        //Get PSA Metric Issues on Service
        List<PSA_Metric_Issue__c> serviceIssues = selector.selectByService(serviceId, new Set<String>{'Id','PSA_Metric__c'});
        //Extract PSA Metric Id from both
        Set<Id> psaMetricIds = new Set<Id>();
        for(PSA_Metric_Issue__c issue : serviceLineIssues){
            psaMetricIds.add(issue.PSA_Metric__c);
        }
        for(PSA_Metric_Issue__c issue : serviceIssues){
            psaMetricIds.add(issue.PSA_Metric__c);
        }

        //Get project metrics, filtering by PSA Metric Id
        Set<String> fields = new Set<String>{'Id', 'Metric_Name__c', 'PSA_Metric__r.Validation_Target_Field__c', 'PSA_Metric__r.Validation_Actual_Field__c', 'PSA_Metric__r.Validation_Type__c', 'PSA_Metric__r.Validation_Service_Codes__c'};
        String conditions = 'PSA_Metric__r.Validation_Actual_Field__c != null AND Project__c = \''+projectId+'\' AND PSA_Metric__c IN :idSet';
        return new SLT_Project_Metric().findByIds(fields, conditions, psaMetricIds);
    }

    @AuraEnabled
    public static List<Project_Log__c> createMisses(List<Project_Metric__c> metrics, Id deliverableId, String serviceLineName, Map<String,String> actualDates ){
        Map<String, Schema.RecordTypeInfo> rectypeInfo = Project_Log__c.getSobjectType().getDescribe().getRecordTypeInfosByName();
        Id recTypeId = rectypeInfo.get('RADDS Metric Issue').recordTypeId;
        List<Project_Log__c> logs = new List<Project_Log__c>();
        for(Project_Metric__c metric : metrics){
            Date actualDate = Date.today();
            String issueType = (metric.PSA_Metric__r.Validation_Type__c == 'Actual date is late') ? 'Performance Miss' : 'Quality Issue';
            Project_Log__c miss = new Project_Log__c(
                RecordTypeId=recTypeId,
                Project_Metric__c=metric.Id,
                Service_Line__c=serviceLineName,
                Deliverable__c=deliverableId,
                Date_Occurred__c=(issueType == 'Quality Issue') ? Date.today() : actualDate,
                //Status__c='In Progress',
                Issue_Type__c=issueType,
                Date_Discovered__c=Date.today()
            );
            logs.add(miss);
        }
        insert logs;
        return logs;
    }

    @AuraEnabled(cacheable=true)
    public static List<Project_Log__c> getExistingMisses(Id deliverableId){
        Set<String> fields = new Set<String>{'Id', 'Project__c', 'Program__c', 'Deliverable__c', 'Project_Metric__r.PSA_Metric__c'};
        Set<Id> ids = new Set<Id>{deliverableId};
        String condition = 'Deliverable__c IN :idSet';
        return new SLT_Project_Log().findByIds(fields, condition, ids);
    }

    /**
     * Performs an Apex/SOSL search (for use in custom lookup field)
     */
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<UTL_LookupSearchResult> searchDrug(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';

        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Drug__c(Id, Name, Program__r.Name, Active__c WHERE Program__c IN :selectedIds and Active__c=TRUE)
            LIMIT :MAX_RESULTS
        ];

        List<UTL_LookupSearchResult> results = new List<UTL_LookupSearchResult>();

        String drugIcon = 'custom:custom8';
        for (Drug__c drug: (List<Drug__c>) searchResults[0]) {
            results.add(
                new UTL_LookupSearchResult(
                    drug.Id,
                    'Drug__c',
                    drugIcon,
                    drug.Name,
                    'Drug'
                )
            );
        }

        results.sort();
        return results;
    }

    public static final String RELATED_DRUG_FIELD_NAME = 'Drug__c';
    public static final String NONE_SELECTED_LABEL = '--None--';

    /**
     * Retrieves the Project custom combo / dependent lookup values for Resource__c field
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProjectDependentOptions (Id projectId) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('Resource__c', new Map<String, Object>{ 'options' => buildRelatedProjectResourceOptions(projectId)});
        return response;
    }

    /**
     * Retrieves the Drug custom combo / dependent lookup values for Trade_Name__c and Formulation__c fields
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDrugDependentOptions (Id drugId) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('Trade_Name__c', new Map<String, Object>{ 'options' => buildRelatedTradeNameOptions(Schema.Trade_Name__c.getSObjectType(), drugId)});
        response.put('Formulation__c', new Map<String, Object>{ 'options' => buildRelatedFormulationOptions(Schema.Formulation__c.getSObjectType(), drugId)});
        return response;
    }

    /**
     * Generates options for the trade name custom comboboxes controlled by Drug!
     */
    private static List<Map<String, Object>> buildRelatedProjectResourceOptions (Id projectId) {
        List<Map<String, Object>> typeOptions = new List<Map<String, Object>>();
        if (projectId != null) {
            String conditions = 'pse__Project__c = \''+projectId+'\'' + ' AND Active__c = true';
            Set<String> fields = new Set<String>{'Id', 'Name', 'pse__Resource__c', 'pse__Resource__r.Name'};
            pse__Assignment__c[] projAssignments = new SLT_Assignment().getAssignmentByResourceAndCondition(null, null,  conditions, fields);
            typeOptions.add(new Map<String, Object>{ 'label' => NONE_SELECTED_LABEL, 'value' => null });
            for (pse__Assignment__c sobj : projAssignments) {
                typeOptions.add(new Map<String, Object>{
                    'label' => sobj.pse__Resource__r.Name,
                    'value' => sobj.pse__Resource__c
                });
            }
        }
        return typeOptions;
    }

    /**
     * Generates options for the trade name custom comboboxes controlled by Drug!
     */
    private static List<Map<String, Object>> buildRelatedTradeNameOptions (Schema.sObjectType sObjectType, Id drugId) {
        List<Map<String, Object>> typeOptions = new List<Map<String, Object>>();
        if (drugId != null) {
            Sobject[] relatedOptions = new SLT_SObject().selectSObjectByLookup(sObjectType, RELATED_DRUG_FIELD_NAME, drugId, new Set<String>{'Id', 'Name'});
            typeOptions.add(new Map<String, Object>{ 'label' => NONE_SELECTED_LABEL, 'value' => null });
            for (SObject sobj : relatedOptions) {
                typeOptions.add(new Map<String, Object>{
                    'label' => sobj.get('Name'),
                    'value' => sobj.get('Id')
                });
            }
        }
        return typeOptions;
    }

    /**
     * Generates options for the formulation name custom comboboxes  controlled by Drug!
     * (builds custom label Strength | Dosage Form for combobox)
     */
    private static List<Map<String, Object>> buildRelatedFormulationOptions (Schema.sObjectType sObjectType, Id drugId) {
        List<Map<String, Object>> typeOptions = new List<Map<String, Object>>();
        if (drugId != null) {
            Set<String> fieldNames = new Set<String>{'Id', 'Name', 'Strength__c', 'Dosage_Form__c'};
            Sobject[] relatedOptions = new SLT_SObject().selectSObjectByLookup(sObjectType, RELATED_DRUG_FIELD_NAME, drugId, fieldNames);
            typeOptions.add(new Map<String, Object>{ 'label' => NONE_SELECTED_LABEL, 'value' => null });
            for (SObject sobj : relatedOptions) {
                String strength = String.valueOf(sobj.get('Strength__c'));
                String dosage = String.valueOf(sobj.get('Dosage_Form__c'));
                String label = strength + ' | ' + dosage;
                typeOptions.add(new Map<String, Object>{
                    'label' => label,
                    'value' => sobj.get('Id')
                });
            }
        }
        return typeOptions;
    }
}