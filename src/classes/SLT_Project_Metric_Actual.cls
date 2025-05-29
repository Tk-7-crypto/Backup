/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Project_Metric_Actual
 */
public class SLT_Project_Metric_Actual extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Metric_Actual () {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Project_Metric_Actual (Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        return fieldsMap.values();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return Project_Metric_Actual__c.sObjectType;
    }

    /**
     * This method used to get field set of field names for the sobject
     * @return  Set<String>
     */
    public Set<String> getSObjectFieldSet () {
        Set<String> fieldNames = new Set<String>();
        List<Schema.SObjectField> fields = getSObjectFieldList();
        if (fields != null && fields.size() > 0) {
            for (Schema.SObjectField sobjField : fields) {
                fieldNames.add(String.valueof(sobjField));
            }
        }
        return fieldNames;
    }

    // manual metric fields to retrieve (override by setting this attribute)
    public Set<String> selectFields {get {
        if (selectFields == null) {
            selectFields = getSObjectFieldSet();
        }
        return selectFields;
    } set;}

    /*
     * finds sobjects for specific ids and date range
     * projectMetricIds - specific ids to retrieve
     * rangeStart - Date for starting range
     * rangeEnd - Date for ending range
     */
    public Project_Metric_Actual__c[] findByProjectMetricIdsAndRange (Set<Id> projectMetricIds, Date rangeStart, Date rangeEnd) {
        fflib_QueryFactory soqlBuilder = newQueryFactory(true);
        soqlBuilder.selectFields(selectFields);
        soqlBuilder.setCondition('Project_Metric__c in :projectMetricIds AND Date__c >= :rangeStart AND Date__c <= :rangeEnd');
        return ((Project_Metric_Actual__c[]) Database.query(soqlBuilder.toSOQL()));
    }
    
    public List<Project_Metric_Actual__c> getProjectMetricByIdsForPagination(Set<id> projectMetricIds, Set<String> fieldSet,Integer pageSize, Integer offset ){
        return (List<Project_Metric_Actual__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN : projectMetricIds').setLimit(pageSize).setOFFSET(offset).toSOQL());
    }
    
    public List<Project_Metric_Actual__c> getProjectMetricRecordsFromProjectIdForListView(String recordId, Set<String> fieldSet){
        return (List<Project_Metric_Actual__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project__c =: recordId').setLimit(5).toSOQL());
    }
    
    public List<Project_Metric_Actual__c> getAllProjectMetricRecordsFromProjectId(String recordId, Set<String> fieldSet){
        return (List<Project_Metric_Actual__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project__c =: recordId').toSOQL());
    }
    
    public Integer getTotalNumberOfRecords(Set<id> ProjectMetricIdSet){
        Integer NumberOfRecords = 0;
        NumberOfRecords = [SELECT COUNT() FROM Project_Metric_Actual__c WHERE Id =: ProjectMetricIdSet];
        return NumberOfRecords;
    }  
    
    public List<Project_Metric_Actual__c> getSelectedRecordsForDeletion(List<String> selecRecords, Set<String> fieldSet){
        return (List<Project_Metric_Actual__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN : selecRecords').toSOQL());
    }

}
