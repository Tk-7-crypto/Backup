/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Product_Group_Relationship__c
 */
public without sharing class SLT_CollaborationGroup extends fflib_SObjectSelector  {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CollaborationGroup.MemberCount,
            CollaborationGroup.Name,
            CollaborationGroup.Id,
            CollaborationGroup.LastFeedModifiedDate,
            CollaborationGroup.LastModifiedDate,
            CollaborationGroup.OwnerId,
            CollaborationGroup.CollaborationType,
            CollaborationGroup.MediumPhotoUrl,      
            CollaborationGroup.Description,
            CollaborationGroup.FullPhotoUrl,
            CollaborationGroup.SmallPhotoUrl,
            CollaborationGroup.InformationTitle,
            CollaborationGroup.InformationBody,
            CollaborationGroup.NetworkId,
            CollaborationGroup.IsArchived,
            CollaborationGroup.GroupEmail,  
            CollaborationGroup.BannerPhotoUrl
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CollaborationGroup.sObjectType;
    }
    
    /**
     * This method used to get CollaborationGroup by Id
     * @return  List<CollaborationGroup>
     */
    public List<CollaborationGroup> selectById(Set<ID> idSet) {
        return (List<CollaborationGroup>) selectSObjectsById(idSet);
    }
    
    /**
    * This method used to get listsof ChatterGroup
    * @return  list
    */
    public List<CollaborationGroup> getChatterGroups(Set<String> fields, String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        system.debug('factory.toSOQL() = '+factory.toSOQL());
        return Database.query(factory.toSOQL());
    }
    
    /**
    * This method used to get listsof ChatterGroup
    * @return  list
    */
    public List<CollaborationGroup> getChatterGroupsById(Set<String> fieldSet, Set<Id> idSet) {
        return (List<CollaborationGroup>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
}