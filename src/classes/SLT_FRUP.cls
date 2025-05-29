public with sharing class SLT_FRUP  extends fflib_SObjectSelector  {
    public SLT_FRUP() {
        super(false, true, false);
    }
    public SLT_FRUP(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return box__FRUP__c.sObjectType;
    }
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{box__FRUP__c.Id, box__FRUP__c.Name, box__FRUP__c.box__Object_Name__c};
    }
    public List<box__FRUP__c> getFRUPRecordsByRecordId(SET<Id> boxRecordIds){
        return([SELECT id, box__Record_ID__c, box__Object_Name__c 
                                        FROM box__FRUP__c
                                        WHERE  box__Record_ID__c IN: boxRecordIds]);
    }
    public box__FRUP__c getFolderId(Id recId, Set<String> fieldSet){
         return ((box__FRUP__c)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('box__Record_ID__c =: recId ').setLimit(1).toSOQL()));
    }
    
    /**
    * This method gives FRUP records on basis of BoxRecordIds
    * @return  List<box__FRUP__c>
    */ 
    public List<box__FRUP__c> getFRUPRecordsByBoxRecordId(Set<Id> boxRecordIds, Set<String> fieldSet, String condition) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        queryFactory.selectFields(fieldSet);
        if(String.isNotBlank(condition)) {
            queryFactory.setCondition(condition);
        }
        return (List<box__FRUP__c>) Database.query(queryFactory.toSOQL());
    }
}