/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for MIBNF2__c Object.
 */
public class SLT_MIBNF extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_MIBNF() {
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
        return MIBNF2__c.sObjectType;
    }
    
    /**
     * This method used to get BNF by OpportunityId
     * @return List<MIBNF2__c>
     */
    public List<MIBNF2__c> selectByFilter(Set<ID> oppIdSet, Set<String> fieldSet ,String filterCondition) {
        return (List<MIBNF2__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }
    
    /**
     * This method used to get MIBNF and MIBNF_Component by MIBNF Id
     * @return List<MIBNF2__c>
     */
    public List<MIBNF2__c> selectMibnfByMibnfId(Set<ID> MibnfIdSet, Set<String> mibnfFieldSet, Set<String> mibnfCompFieldSet) {
        fflib_QueryFactory query = newQueryFactory();
        fflib_SObjectSelector bnfCompSelector = new SLT_MIBNF_Component();
        bnfCompSelector.addQueryFactorySubselect(query, 'MIBNF_Components__r').selectFields(mibnfCompFieldSet);
        String queryString = query.selectFields(mibnfFieldSet).setCondition('Id in :MibnfIdSet').toSOQL();
        return (List<MIBNF2__c>) Database.query( query.toSOQL() );
    }
    
}