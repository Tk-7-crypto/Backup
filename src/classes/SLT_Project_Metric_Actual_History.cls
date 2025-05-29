/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Project_Metric_Actual_History
 */
public class SLT_Project_Metric_Actual_History extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Metric_Actual_History () {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Project_Metric_Actual_History (Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        return new List<Schema.SObjectField>();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return Project_Metric_Actual__History.sObjectType;
    }

    // manual history fields to retrieve (override by setting this attribute)
    public Set<String> selectFields {
        get {
            if (selectFields == null) {
                // defaults
                selectFields = new Set<String>{
                    'CreatedById',
                    'CreatedBy.Name',
                    'CreatedDate',
                    'Field',
                    'Id',
                    'NewValue',
                    'OldValue',
                    'ParentId',
                    'Parent.Date__c',
                    'Parent.Project_Metric__r.Frequency__c',
                    'Parent.PSA_Metric__r.Service_Line__c',
                    'Parent.Project_Metric__r.Metric_Name__c',
                    'Parent.Project_Metric__r.Project__c'
                };
            }
            return  selectFields;
        }
        set {}
    }

    /*
     * Retrieves Project Metric Actual History records for a specific project
     *
     * projectMetricIds - specific ids to retrieve
     */
    public Project_Metric_Actual__History[] findByProjectIdAndRange (Id projectId, String frequency, String serviceLineId,  Date rangeStart, Date rangeEnd) {
        String commentsField = 'Comments__c';
        String andConditions = String.join(new String[]{
            'Parent.Project_Metric__r.Project__c = :projectId',
            'Field = :commentsField',
            'Parent.Project_Metric__r.Frequency__c = :frequency',
            'Parent.PSA_Metric__r.Service_Line__c = :serviceLineId',
            'Parent.Date__c >= :rangeStart',
            'Parent.Date__c <= :rangeEnd'
        }, ' AND ');

        fflib_QueryFactory soqlBuilder = newQueryFactory(true);
        soqlBuilder.selectFields(selectFields);
        soqlBuilder.setCondition(andConditions);
        soqlBuilder.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

        return ((Project_Metric_Actual__History[]) Database.query(soqlBuilder.toSOQL()));
    }
}