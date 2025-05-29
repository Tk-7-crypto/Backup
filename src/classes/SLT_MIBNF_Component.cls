/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for MIBNF_Component__c Object.
 */
public class SLT_MIBNF_Component extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_MIBNF_Component() {
        super(false, false, false);
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
        return MIBNF_Component__c.sObjectType;
    }
    
    /**
     * This method used to get MIBNF_Component__c by OpportunityId
     * @return List<MIBNF_Component__c>
     */
    public List<MIBNF_Component__c> selectByFilter(Set<ID> oppIdSet, Set<String> fieldSet ,String filterCondition) {
        return (List<MIBNF_Component__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }
    
    /**
     * This method used to get MIBNF_Component__c details
     * @return List<MIBNF_Component__c>
     */
    public List<MIBNF_Component__c> selectById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<MIBNF_Component__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
    
     /**
     * This method used to get MIBNF_Component__c by MIBNF
     * @return List<MIBNF_Component__c>
     */
        public List<MIBNF_Component__c> selectByMIBNFIdAndNotStatus(Set<String> fieldSet, Id mibnfId, Set<String> bnfStatus) {
            return (List<MIBNF_Component__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('MIBNF__c =:mibnfId AND BNF_Status__c NOT IN: bnfStatus').toSOQL());
        }
        
        
        public List<MIBNF_Component__c> getMibnfCompByIdsWithLineItem(Set<Id> mibnfCompIds, Set<String> mibnfCompFields, Set<String> lineItemFields){
            fflib_QueryFactory query = newQueryFactory(true).selectFields(mibnfCompFields).setCondition('Id IN :mibnfCompIds');
            new SLT_MIBNFLineItem().addQueryFactorySubselect(query,'MI_BNF_LineItems__r').selectFields(lineItemFields);
            system.debug(query.toSOQL());
            return (List<MIBNF_Component__c>)Database.query(query.toSOQL());
            //return [select id,(select id from MI_BNF_LineItems__r) from MIBNF_Component__c where Id IN :mibnfCompIds];
        }
    }