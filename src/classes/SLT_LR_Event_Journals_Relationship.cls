public class SLT_LR_Event_Journals_Relationship extends fflib_SObjectSelector{
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_LR_Event_Journals_Relationship() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_LR_Event_Journals_Relationship(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{LR_Event_Journals_Relationship__c.Id, LR_Event_Journals_Relationship__c.Name, LR_Event_Journals_Relationship__c.Event_Journals_M__c};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return LR_Event_Journals_Relationship__c.sObjectType;
    }
    
    /*******************************/
    
    public List<LR_Event_Journals_Relationship__c> getLRSearchStrategyRelationship(Set<String> fieldSet){
        return (List<LR_Event_Journals_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    /************************/
     
    
    /**
     * This method used to query LR_Event_Journals_Relationship__c By LR Project Overview Id
     * @return  LR_Event_Journals_Relationship__c 
     */
    public List<LR_Event_Journals_Relationship__c> getLREJRelationshipFromLrId(set<Id> lRProjectOverViewId, Set<String> fieldSet){
        return (List<LR_Event_Journals_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview_M__c IN:lRProjectOverViewId').toSOQL());
    }
    
    /**
     * This method used to query LR_Event_Journals_Relationship__c By LR Project Overview Id
     * @return  LR_Event_Journals_Relationship__c 
     */
    public List<LR_Event_Journals_Relationship__c> getLREJRelationshipFromEJId(set<Id> ejIdSet, Set<String> fieldSet){
        return (List<LR_Event_Journals_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Event_Journals_M__c IN:ejIdSet').toSOQL());
    }
    
    /**
     * This method used to query LR_Event_Journals_Relationship__c By Acc, project, product and LrType condition
     * @return  LR_Event_Journals_Relationship__c 
     */
    public List<LR_Event_Journals_Relationship__c> getLREJRelationshipData(set<Id> accountIdSet, set<Id> projectIdSet, set<Id> productIdSet, set<String> lrTypeSet, Set<String> fieldSet, Set<String> lrStatus){
        return (List<LR_Event_Journals_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Account__c in :accountIdSet and LR_Type__c in :lrTypeSet and product__c in :productIdSet and Project__c in : projectIdSet and LR_Status__c NOT IN :lrStatus').toSOQL());
    }
    
    /**
     * This method used to query LR_Event_Journals_Relationship__c where LR Project Overview Id is null
     * @return  LR_Event_Journals_Relationship__c 
     */
    public List<LR_Event_Journals_Relationship__c> getLRSSRelationshipDataWhereLRIdNull(Set<String> fieldSet){
        return (List<LR_Event_Journals_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview_M__c = null').toSOQL());
    }
    
    /**
     * This method used to query LR_Event_Journals_Relationship__c where Search Strategy Id is null
     * @return  LR_Event_Journals_Relationship__c 
     */
    public List<LR_Event_Journals_Relationship__c> getLREJRelationshipDataWhereEJIdNull(Set<String> fieldSet){
        return (List<LR_Event_Journals_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Event_Journals_M__c = null').toSOQL());
    }
}