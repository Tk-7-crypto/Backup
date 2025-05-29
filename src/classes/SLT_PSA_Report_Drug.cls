/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Report Drugs
 */
public class SLT_PSA_Report_Drug extends fflib_SObjectSelector{
 /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_PSA_Report_Drug() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_PSA_Report_Drug(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_PSA_Report_Drug(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Report_Drug__c.sObjectType;
    }

    /**
     * This method returns a list of Report Drugs with desire fields
     */
    public List<Report_Drug__c> getReportDrugsByAggregateReportId(Set<Id> aggregateReportIdSet, Set<String> requestedFields){
        return ((List<Report_Drug__c>) Database.query(newQueryFactory(false).selectFields(requestedFields).setCondition('Aggregate_Report__c IN :aggregateReportIdSet AND Drug__c != null').toSOQL()));
    }
 }
