public class SLT_QC_Tracker extends fflib_SObjectSelector{

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_QC_Tracker() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_QC_Tracker(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
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
        return QC_Tracker_Result__c.sObjectType;
    }
    
    /*******************************/
    
    public List<QC_Tracker_Result__c> getActiveQCTrackerRecords(Id rltdAggRepId ,Set<String> fieldSet, Integer specLimit, String whereClause, String orderByField){
        return (List<QC_Tracker_Result__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(whereClause).addOrdering(orderByField, fflib_QueryFactory.SortOrder.DESCENDING).setLimit(specLimit).toSOQL());
    }
    
    public List<QC_Tracker_Result__c> getActiveQCTrackerRecordsGenView(Id rltdAggRepId ,Set<String> fieldSet, String whereClause, String orderByField){
        return (List<QC_Tracker_Result__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(whereClause).addOrdering(orderByField, fflib_QueryFactory.SortOrder.DESCENDING).toSOQL());
    }
    
    public Integer getTotalNumberOfRecords(Set<id> qcTrackerIdSet){
        Integer NumberOfRecords = 0;
        NumberOfRecords = [SELECT COUNT() FROM QC_Tracker_Result__c WHERE Id IN : qcTrackerIdSet AND Date_Deleted__c = null];
        return NumberOfRecords;
    }
    
    public Map<Id, List<QC_Tracker_Result__c>> getActiveQCTrackerRecordsforAggReps(Set<Id> rltdAggRepId ,Set<String> fieldSet, String whereClause){
        List<QC_Tracker_Result__c> activeQCTList =  Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(whereClause).toSOQL());
        Map<Id, List<QC_Tracker_Result__c>> aggRepIdToQCTListMap = new Map<Id, List<QC_Tracker_Result__c>>();
        if(activeQCTList.size()>0){
            for(QC_Tracker_Result__c qct: activeQCTList){
                if(aggRepIdToQCTListMap.containskey(qct.Aggregate_Report__c) && aggRepIdToQCTListMap.get(qct.Aggregate_Report__c) != null){
                    aggRepIdToQCTListMap.get(qct.Aggregate_Report__c).add(qct);
                }else{
                    aggRepIdToQCTListMap.put(qct.Aggregate_Report__c, new List<QC_Tracker_Result__c>{qct});
                }
            }
        }
        return aggRepIdToQCTListMap;
    }
}
