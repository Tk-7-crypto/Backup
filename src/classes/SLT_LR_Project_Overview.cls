public class SLT_LR_Project_Overview extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_LR_Project_Overview() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_LR_Project_Overview(Boolean enforceFLS,Boolean enforceCRUD) {
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
        return LR_Project_Overview__c.sObjectType;
    }
    
    /**
     * This method used to query LR_Project_Overview__c
     * @return  List<LR_Project_Overview__c>
     */
    public List<LR_Project_Overview__c> getLRProjectOverViews(Set<String> fieldSet){
        return (List<LR_Project_Overview__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /**
     * This method used to query LR_Project_Overview__c By lRProjectOverViewId
     * @return  LR_Project_Overview__c 
     */
    public LR_Project_Overview__c getLRProjectOverViewFROMlRProjectOverViewId(String lRProjectOverViewId, Set<String> fieldSet){
        return (LR_Project_Overview__c) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id =:lRProjectOverViewId').toSOQL());
    }
    
    /**
     * This method used to query LR_Project_Overview__c By project Id
     * @return  LR_Project_Overview__c 
     */
    public List<LR_Project_Overview__c> getLRProjectOverViewFROMProjectId(Set<Id> ProjectId, Set<String> fieldSet){
        return (List<LR_Project_Overview__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project__c IN:ProjectId').toSOQL());
    }
    
    /**
     * This method used to query LR_Project_Overview__c By Key of Projects,Products, accounts and Lr types
     * @return  LR_Project_Overview__c 
     */
    public List<LR_Project_Overview__c> getLRProjectOverViewFromKey(Set<Id> projectIds, Set<String> accountIds, Set<String> productIds, Set<String> lrTypes, Set<String> fieldSet){
        return (List<LR_Project_Overview__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project__c IN : projectIds AND Account__c IN : accountIds AND Product__c IN : productIds AND LR_Type__c IN : lrTypes AND Status__c != \'Cancelled\'  AND Status__c !=\'Completed\' AND (Search_Strategy_Created__c = \'Pending\' OR Search_Strategy_Created__c =\'Yes\') ').toSOQL());
    }
    
    /**
     * This method used to query LR_Project_Overview__c By project Id
     * @return  LR_Project_Overview__c 
     */
    public List<LR_Project_Overview__c> getLRProjectOverViewFromProjectIdsForPagination(Set<Id> ProjectId, Set<String> fieldSet, Integer pageSize, Integer offset){
        return (List<LR_Project_Overview__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project__c IN:ProjectId').setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING, true).setLimit(pageSize).setOFFSET(offset).toSOQL());
    }
    
    /**
     * This method used to query LR_Project_Overview__c By  Id
     * @return  LR_Project_Overview__c 
     */
    public List<LR_Project_Overview__c> getLRProjectOverViewFROMId(Set<Id> lrIdSet){
        return (List<LR_Project_Overview__c>) Database.query(newQueryFactory(true).setCondition('Id IN:lrIdSet').toSOQL());
    }
    
    /**
     * This method used to query LR_Project_Overview__c By LR Id
     * @return  LR_Project_Overview__c 
     */
    public List<LR_Project_Overview__c> getLRProjectOverviewFromLRID(Set<Id> lrIdSet, Set<String> fieldSet){
        return (List<LR_Project_Overview__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN:lrIdSet').toSOQL());
    }
    
    /**
     * This method used to query LR_Project_Overview__c By Acc, project, product and LrType condition
     * @return  LR_Project_Overview__c 
     */
    public List<LR_Project_Overview__c> getLRDataOnCriteria(set<Id> accountIdSet, set<Id> projectIdSet, set<Id> productIdSet, set<String> lrTypeSet, Set<String> fieldSet, Set<String> lrStatus){
        return (List<LR_Project_Overview__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Account__c in :accountIdSet and LR_Type__c in :lrTypeSet and product__c in :productIdSet and Project__c in : projectIdSet and Status__c NOT IN :lrStatus AND ( Search_Strategy_Created__c =\'Yes\' OR Search_Strategy_Created__c =\'Pending\' )' ).toSOQL());
    }
}
