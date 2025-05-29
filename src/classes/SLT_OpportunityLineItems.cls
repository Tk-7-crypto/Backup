/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunityLineItems
 */
public class SLT_OpportunityLineItems extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_OpportunityLineItems() {
        super(false, true, false);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_OpportunityLineItems(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_OpportunityLineItems(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceFLS, enforceCRUD);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return OpportunityLineItem.sObjectType;
    }
    
    /**
     * This method used to get OpportunityLineItems by OpportunityId
     * @return  Map<Id, OpportunityLineItem>
     */
    public Map<Id, OpportunityLineItem> selectByOpportunityId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('OpportunityId in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get OpportunityLineItems by opportunityId
     * @return  List<OpportunityLineItem>
     */
    public List<OpportunityLineItem> selectByOpportunityIds(Set<ID> idSet, Set<String> fieldSet) {
        return (List<OpportunityLineItem>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('OpportunityId in :idSet').toSOQL());
    }
    
    /**
     * This method used to get OpportunityLineItems by oliId
     * @return  List<OpportunityLineItem>
     */
    public List<OpportunityLineItem> selectByOLIIds(Set<ID> oliIdSet, Set<String> fieldSet) {
        return (List<OpportunityLineItem>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Id in :oliIdSet').toSOQL());
    }
    
    /**
     * This method used to get OpportunityLineItems by OpportunityId
     * @return  Map<Id, OpportunityLineItem>
     */
    public Map<Id, OpportunityLineItem> getOliWithSchedules(Set<ID> idSet, Set<String> oliFieldSet, Set<String> schFieldSet) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
        new SLT_OpportunityLineItemSchedule().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE, true).selectFields(schFieldSet);
        String queryString = opportunitiesQueryFactory.selectFields(oliFieldSet).setCondition('Id in :idSet').toSOQL();
        return new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(queryString));
    }
    
    /**
     * This method used to get OpportunityLineItems by Opportunity Id
     * @return  Map<Id, OpportunityLineItem>
     */
    public Map<Id, OpportunityLineItem> getOlisWithSchedules(Set<ID> idSet, Set<String> oliFieldSet, Set<String> schFieldSet) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
        new SLT_OpportunityLineItemSchedule().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE, true).selectFields(schFieldSet);
        String queryString = opportunitiesQueryFactory.selectFields(oliFieldSet).setCondition('OpportunityId in :idSet').toSOQL();
        return new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(queryString));
    }
    
    /**
     * This method used to get OpportunityLineItems by LI OLI Id
     * @return  Map<Id, OpportunityLineItem>
     */
    public Map<Id, OpportunityLineItem> selectByLIOLIId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LI_OpportunityLineItem_Id__c in :idSet').toSOQL()));
    }
	
    /**
     * This method used to get OpportunityLineItems by Opportunity Id
     * @params Set<Id> oppIdset
     * @return List<OpportunityLineItem> 
     */
    public List<OpportunityLineItem> selectOLIByOpportunityId(Set<ID> oppIdSet) {
        return [SELECT OpportunityId, PricebookEntry.Product2.Global_Product_Code__c, Delivery_Country__c, Product2Id, Billing_System__c, Agreement_Line_Item_Id__c , Revenue_Start_Date__c, Revenue_End_Date__c
                FROM OpportunityLineItem 
                WHERE OpportunityId IN : oppIdSet
               ];
    }
    
    /**
    * This method used to get AggregateResult[] by Opportunity Id
    * @params Set<Id> oppIdset
    * @return AggregateResult[]
    * ESPCRMINT-103
    */
    public AggregateResult[] fetchOfferingGroupResult(Set<ID> oppIdSet) {
        return [SELECT COUNT_DISTINCT(Offering_Type__c) groupCount, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN : oppIdSet  GROUP BY OpportunityId ];
    }
    public List<OpportunityLineItem> selectByOpportunityIdProductCode(Set<ID> idSet,Set<String> productCodeSet, Set<Id> oliIds,Set<String> fieldSet) {
        return (List<OpportunityLineItem>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('OpportunityId in :idSet AND ProductCode IN :productCodeSet AND Id NOT IN :oliIds').toSOQL());
    }
    /**
     * This method is used to get OpportunityLineItems by Opportunity Id AND Product Code
     * @params Set<ID> oppIdSet
     * @params Set<String> fieldSet
     * @params Set<String> productCodeSet
     * @returns List<OpportunityLineItem> 
     */ 
    public List<OpportunityLineItem> getOLIByOppIdAndProductCode(Set<Id> oppIdSet, Set<String> fieldSet, Set<String> productCodeSet) {
        return (List<OpportunityLineItem>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('OpportunityId IN :oppIdSet AND ProductCode IN :productCodeSet').toSOQL());
    }
    public List<OpportunityLineItem> selectByOLIProductCode(Set<ID> oppIdSet,List<String> productCodeSet,Set<String> fieldSet) {
        return (List<OpportunityLineItem>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('OpportunityId in :oppIdSet AND ProductCode IN :productCodeSet').toSOQL());
    }
    
    /**
     * This method used to get OpportunityLineItems by Opportunity Id and Filter Condition
     * @return  List<OpportunityLineItem>
     */
    public List<OpportunityLineItem> selectByOpportunityIdandFilterCondition(Set<Id> oppIdSet, Set<String> fieldSet, String filterCondition) {
        return (List<OpportunityLineItem>)Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('OpportunityId IN :oppIdSet ' + filterCondition).toSOQL());
    }
    
    public List<AggregateResult> getOLICountGroupByOpp(Set<ID> oppIdSet) {
        return [SELECT COUNT(Id) recordCount, OpportunityId FROM OpportunityLineItem where OpportunityId in :oppIdSet AND 
            ((Product_Material_Type_Text__c = 'ZQUI' AND Product2.ZQUI_Product__c = true)) GROUP BY OpportunityId];
    }
    
    public List<OpportunityLineItem> selectByOppIdandInactive(Set<ID> oppIdSet, Set<String> fieldSet) {
        return (List<OpportunityLineItem>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('OpportunityId in :oppIdSet AND PricebookEntry.IsActive = false').toSOQL());
    }
    
    /**
     * This method used to get OpportunityLineItems by Opportunity Id
     * @return  Map<Id, OpportunityLineItem>
     */
    public Map<Id, OpportunityLineItem> getActiveOlisWithSchedules(Set<ID> idSet, Set<String> oliFieldSet, Set<String> schFieldSet) {
        fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory(true);
        fflib_QueryFactory.SortOrder fieldSortOrder = fflib_QueryFactory.SortOrder.ASCENDING;
        new SLT_OpportunityLineItemSchedule().addQueryFactorySubselect(opportunitiesQueryFactory, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE, true).selectFields(schFieldSet);
        String queryString = opportunitiesQueryFactory.selectFields(oliFieldSet).setCondition('OpportunityId in :idSet and PricebookEntry.IsActive = true').toSOQL();
        return new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(queryString));
    }
    
    public List<AggregateResult> getRecentProductId(){
        return [SELECT product2Id,Max(CreatedDate) FROM OpportunityLineItem Where CreatedDate >= LAST_N_MONTHS:3 AND CreatedById =:UserInfo.getUserId() Group by product2Id order by Max(CreatedDate) desc limit 50];
    }
    
    public List<OpportunityLineItem> getComponentData(Id opportunityId){
        return [SELECT o.Id,o.PricebookEntry.Product2.Name,o.PricebookEntry.Product2.Id,o.TotalPrice,
                o.PricebookEntry.Product2.Material_Type__c,o.PricebookEntry.Product2.ZQUI_Product__c, o.PricebookEntry.Product2.Product_Group__c 
                FROM OpportunityLineItem o 
                WHERE o.OpportunityId = :opportunityId AND o.PSA_Budget__c  = null 
                AND (o.PricebookEntry.Product2.Material_Type__c = 'ZREP' OR 
                (o.PricebookEntry.Product2.Material_Type__c = 'ZQUI' AND o.PricebookEntry.Product2.ZQUI_Product__c = true ))
                ORDER BY o.PricebookEntry.Product2.Name ASC];
    }
    /**
     * This method is used to get OpportunityLineItems by Opportunity Id AND Product Code
     * @params Set<ID> oppIdSet
     * @params Set<String> fieldSet
     * @params Set<String> productCodeSet
     * @returns Map<Id, OpportunityLineItem> 
     */ 
    public Map<Id, OpportunityLineItem> getOLIByOppIdAndProductCodeMap(Set<ID> oppIdSet,Set<String> productCodeSet,Set<String> fieldSet) {
        return new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('OpportunityId in :oppIdSet AND ProductCode IN :productCodeSet').toSOQL()));
    }
 
}
