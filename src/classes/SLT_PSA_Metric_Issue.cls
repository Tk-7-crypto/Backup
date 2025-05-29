/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for PSA Metric Issue 
 */
public class SLT_PSA_Metric_Issue extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_PSA_Metric_Issue () {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_PSA_Metric_Issue (Boolean enforceFLS) {
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
        return PSA_Metric_Issue__c.sObjectType;
    }

    /*
     * finds PSA metric issues by Service Line 
     */
    public List<PSA_Metric_Issue__c> selectByServiceLine(Id serviceLineId, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        String queryString = queryFactory.selectFields(fieldSet).setCondition('Active__c = true AND PSA_Metric__r.Service_Line__c = :serviceLineId AND Service__c = null').toSOQL();
        return (List<PSA_Metric_Issue__c>) Database.query(queryString);
    }

    /*
     * finds PSA metric issues by Service 
     */
    public List<PSA_Metric_Issue__c> selectByService(Id serviceId, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        String queryString = queryFactory.selectFields(fieldSet).setCondition('Active__c = true AND Service__c = :serviceId').toSOQL();
        return (List<PSA_Metric_Issue__c>) Database.query(queryString);
    }
}