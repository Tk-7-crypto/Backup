public class SLT_LR_Search_Strategy_Relationship extends fflib_SObjectSelector{
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_LR_Search_Strategy_Relationship() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_LR_Search_Strategy_Relationship(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{LR_Search_Strategy_Relationship__c.Id, LR_Search_Strategy_Relationship__c.Name, LR_Search_Strategy_Relationship__c.Search_Strategy_M__c};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return LR_Search_Strategy_Relationship__c.sObjectType;
    }
    
    /*******************************/
    
    public List<LR_Search_Strategy_Relationship__c> getLRSearchStrategyRelationship(Set<String> fieldSet){
        return (List<LR_Search_Strategy_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    /************************/
     
    
    /**
     * This method used to query LR_Search_Strategy_Relationship__c By LR Project Overview Id
     * @return  LR_Search_Strategy_Relationship__c 
     */
    public List<LR_Search_Strategy_Relationship__c> getLRSSRelationshipFromLrId(set<Id> lRProjectOverViewId, Set<String> fieldSet){
        return (List<LR_Search_Strategy_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview_M__c IN:lRProjectOverViewId').toSOQL());
    }
    
    /**
     * This method used to query LR_Search_Strategy_Relationship__c By LR Project Overview Id
     * @return  LR_Search_Strategy_Relationship__c 
     */
    public List<LR_Search_Strategy_Relationship__c> getLRSSRelationshipFromLrIdLimit(set<String> lRProjectOverViewId, Set<String> fieldSet, Integer limitValue){
        return (List<LR_Search_Strategy_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview_M__c IN:lRProjectOverViewId').setLimit(limitValue).toSOQL());
    }
    
    /**
     * This method used to query LR_Search_Strategy_Relationship__c By LR Project Overview Id
     * @return  LR_Search_Strategy_Relationship__c 
     */
    public List<LR_Search_Strategy_Relationship__c> getLRSSRelationshipFromSsId(set<Id> ssIdSet, Set<String> fieldSet){
        return (List<LR_Search_Strategy_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Search_Strategy_M__c IN:ssIdSet').toSOQL());
    }
    
    /**
     * This method used to query LR_Search_Strategy_Relationship__c By Acc, project, product and LrType condition
     * @return  LR_Search_Strategy_Relationship__c 
     */
    public List<LR_Search_Strategy_Relationship__c> getLRSSRelationshipData(set<Id> accountIdSet, set<Id> projectIdSet, set<Id> productIdSet, set<String> lrTypeSet, Set<String> fieldSet, Set<String> lrStatus){
        return (List<LR_Search_Strategy_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Account__c in :accountIdSet and LR_Type__c in :lrTypeSet and product__c in :productIdSet and Project__c in : projectIdSet and LR_Status__c NOT IN :lrStatus').toSOQL());
    }
    
    /**
     * This method used to query LR_Search_Strategy_Relationship__c where LR Project Overview Id is null
     * @return  LR_Search_Strategy_Relationship__c 
     */
    public List<LR_Search_Strategy_Relationship__c> getLRSSRelationshipDataWhereLRIdNull(Set<String> fieldSet){
        return (List<LR_Search_Strategy_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview_M__c = null').toSOQL());
    }
    
    /**
     * This method used to query LR_Search_Strategy_Relationship__c where Search Strategy Id is null
     * @return  LR_Search_Strategy_Relationship__c 
     */
    public List<LR_Search_Strategy_Relationship__c> getLRSSRelationshipDataWhereSSIdNull(Set<String> fieldSet){
        return (List<LR_Search_Strategy_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Search_Strategy_M__c = null').toSOQL());
    }
    
    /**
     * This method is used to query LR_Search_Strategy_Relationship__c to get data for Annual Search Strategy Batch
     * @return  LR_Search_Strategy_Relationship__c 
     */
    public List<LR_Search_Strategy_Relationship__c> getLRSSRelationshipDataForEmailBatch(Set<Id> annualSrchStrategySet, Set<String> fieldSet){
        return (List<LR_Search_Strategy_Relationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Search_Strategy_M__c IN :annualSrchStrategySet AND (LR_Project_Overview_M__r.LR_Review_Period_Frequency__c = \''+CON_PSA.LR_SIX_MONTHLY_FREQ+'\' OR LR_Project_Overview_M__r.LR_Review_Period_Frequency__c =\''+CON_PSA.LR_ANNUAL_FREQ+'\') AND  (LR_Status__c != \''+CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED+'\' AND LR_Status__c != \''+CON_PSA.LR_PROJECT_OVERVIEW_STATUS_CANCELLED+'\')').toSOQL());
    }

}
