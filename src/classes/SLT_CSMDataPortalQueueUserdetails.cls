public class SLT_CSMDataPortalQueueUserdetails extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CSM_QI_Data_Portal_Queue_User_details__c.sObjectType;
    }
    
    /**
     * This method used to get CSM_QI_Data_Portal_Queue_User_details__c by Id
     * @return  List<CSM_QI_Data_Portal_Queue_User_details__c>
     */
    public List<CSM_QI_Data_Portal_Queue_User_details__c> selectById(Set<ID> idSet) {
        return (List<CSM_QI_Data_Portal_Queue_User_details__c>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get CSM_QI_Data_Portal_Queue_User_details__c by filter condition.
     * @params  Set<String> portalFields
     * @params  String filterCondition
     * @return  List<CSM_QI_Data_Portal_Queue_User_details__c>
     */
    public List<CSM_QI_Data_Portal_Queue_User_details__c> getDataWithFilter(Set<String> portalFields, String filterCondition) {
        fflib_QueryFactory productQueryFactory = newQueryFactory(true);
        String queryString = productQueryFactory.selectFields(portalFields).setCondition(filterCondition).toSOQL();
        return ((List<CSM_QI_Data_Portal_Queue_User_details__c>) Database.query(queryString));
    }
    
}