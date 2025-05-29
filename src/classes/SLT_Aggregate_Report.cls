/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Aggregate Reports
 */
public class SLT_Aggregate_Report extends fflib_SObjectSelector{
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Aggregate_Report() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Aggregate_Report(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Aggregate_Report(Boolean enforceFLS,Boolean enforceCRUD) {
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
        return Aggregate_Report__c.sObjectType;
    }

    /**
     * This method returns a list of Aggregate reports with desire fields
     */
    public List<Aggregate_Report__c> selectAggregateReportsById(Set<Id> aggregateReportIdSet, Set<String> requestedFields){
        return ((List<Aggregate_Report__c>) Database.query(newQueryFactory(false).selectFields(requestedFields).setCondition('Id IN :aggregateReportIdSet').toSOQL()));
    }
    
    /**
     * This method returns a list of Aggregate reports with desire fields
     */
    public List<Aggregate_Report__c> selectAggregateReportsByID(Set<Id> aggregateReportIdSet, Set<String> requestedFields,String filterField){
        return ((List<Aggregate_Report__c>) Database.query(newQueryFactory(false).selectFields(requestedFields).setCondition(filterField +' IN :aggregateReportIdSet').toSOQL()));
    }

    /**
     * This method returns a Map of Aggregate Report name to Id of Aggregate Report record
     */
    public Map<String,Id> selectAggregateReportsByName(Set<String> aggregateReportNameSet, Set<String> requestedFields){
    	List<Aggregate_Report__c> agRepList = (List<Aggregate_Report__c>) Database.query(newQueryFactory(false).selectFields(requestedFields).setCondition('Name IN :aggregateReportNameSet').toSOQL());
        Map<String,Id> resultMap = new Map<String,Id>(); 
        for(Aggregate_Report__c agRep : agRepList){
        	resultMap.put(agRep.Name, agRep.Id);
        }
        return resultMap;
    }

    /**
     * This method returns a map of Parent Projects to lists of Aggregate Reports 
     */
    public Map<Id,List<Aggregate_Report__c>> getAggregateReportsByParentProject(Set<Id> parentProjectIdSet, Set<String> requestedFields){
        requestedFields.add('Service_Milestone__c');
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(requestedFields);
        queryFactory.setCondition('Service_Milestone__r.pse__Project__r.pse__Parent_Project__c IN :parentProjectIdSet OR Project__r.pse__Parent_Project__c IN :parentProjectIdSet');
        String queryString = queryFactory.toSOQL();

        List<Aggregate_Report__c> agRepList = (List<Aggregate_Report__c>) Database.query(queryString);
        Map<Id,List<Aggregate_Report__c>> resultMap = new Map<Id,List<Aggregate_Report__c>>();
        for(Aggregate_Report__c agRep : agRepList){
            Id parentProjectId = (agRep.Service_Milestone__c != null) ? agRep.Service_Milestone__r.pse__Project__r.pse__Parent_Project__c : agRep.Project__r.pse__Parent_Project__c;
            if( resultMap.get(parentProjectId) == null ){
                resultMap.put(parentProjectId, new List<Aggregate_Report__c>());
            }
            resultMap.get(parentProjectId).add(agRep);
        }
        return resultMap;
    }

}