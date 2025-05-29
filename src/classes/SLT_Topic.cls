/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Topic
 */
public class SLT_Topic extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     */

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Topic.Id,
            Topic.NetworkId,
            Topic.Name,
            Topic.Description
        };
    }
    
     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Topic.sObjectType;
    }
    
    /**
     * This method used to get Topic by Id
     * @return  List<Topic>
     */
    public List<Topic> selectById(Set<ID> idSet) {
        return (List<Topic>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get all Topics
     * @return  List<Topic>
     */
    public List<Topic> selectAll() {
         return [SELECT Name, Id,  NetworkId  FROM Topic];
    }
    
    /**
     * This method used to get  Topics by name
     * @return  List<Topic>
     */
    public List<Topic> selectByName(Set<String> name) {
         return [SELECT Name, Id, Description, NetworkId  FROM Topic WHERE Name IN : name];
    }
    
    /**
     * This method used to selectByTopicId
     * @return  Map<Id, Topic>
     */
    public Map<Id, Topic> selectByTopicId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Topic>((List<Topic>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
}