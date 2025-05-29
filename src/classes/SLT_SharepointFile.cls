public class SLT_SharepointFile extends fflib_SObjectSelector {
    public SLT_SharepointFile(){
    }
    
    public SLT_SharepointFile(Boolean enforceCRUD,Boolean enforceFLS){
        super(true, enforceCRUD, enforceFLS);
    }
    
    /**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Sharepoint_File__c.Id,
            Sharepoint_File__c.Parent_Id__c,
            Sharepoint_File__c.File_Url__c,
            Sharepoint_File__c.Name,
            Sharepoint_File__c.File_Name__c
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){
        return Sharepoint_File__c.sObjectType;
    }

    /**
    * This method used to get Sharepoint_File__c by Id
    * @return  List<Sharepoint_File__c>
    */
    public List<Sharepoint_File__c> selectById(Set<Id> idSet){
        return (List<Sharepoint_File__c>) selectSObjectsById(idSet);
    }

    /**
    * This method is use to query Sharepoint_File__c by Agreement Id
    * @return List<Sharepoint_File__c>
    */
    public List<Sharepoint_File__c> getSharepointFileByParentId(Set<Id> setParentId, Integer limitRecords) {
        fflib_QueryFactory factory = newQueryFactory(true);
        if(setParentId.size() > 0) {
            factory.setCondition('Parent_Id__c IN: setParentId');
        }
        factory.setOrdering(Sharepoint_File__c.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING, false);
        if (limitRecords>0) {
            factory.setLimit(limitRecords);
        }
        return Database.query(factory.toSOQL());
    }

    /**
    * This method is use to query Sharepoint_File__c by Agreement Id
    * @param setParentId is the set of parent ids
    * @param limitRecords is the limit of records
    * @param condition to fetch records basis on some condition.
    * @return List<Sharepoint_File__c>
    */
    public List<Sharepoint_File__c> getSharepointFileByParentIdAndFolder(Set<Id> setParentId, Integer limitRecords, 
        String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        if(String.isNotBlank(condition)) {
            factory.setCondition('Parent_Id__c IN: setParentId AND (' + condition + ')');
        }
        factory.setOrdering(Sharepoint_File__c.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING, false);
        if (limitRecords > 0) {
            factory.setLimit(limitRecords);
        }
        return Database.query(factory.toSOQL());
    }
}