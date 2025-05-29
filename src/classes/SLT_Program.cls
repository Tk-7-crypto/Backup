/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Program
 */
public class SLT_Program extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Program() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Program(Boolean enforceFLS) {
        super(false, true, enforceFLS);
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
        return Program__c.sObjectType;
    }

    /**
     * This method used to get Program by Id
     * @return  Map<Id, Program__c>
     */
    public Map<Id, Program__c> getProjectById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Program__c>((List<Program__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
     /**
     * This method used to get Program List by Id.
     * @return  List<Program__c>
     */
    public List<Program__c> selectByProgramIdList(Set<ID> idSet,Set<String> fieldSet) {
        return ((List<Program__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    /**
     * This method used to get Program by Id 
     * @return  Program__c
     */
    public Program__c selectByProgramId(Set<ID> idSet,Set<String> fieldSet) {
        return ((Program__c) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    /**
     * This method used to get Programs by Account Id 
     * @return  List<Program__c>
     */
    public List<Program__c> selectByAccount(Set<Id> accountIdSet, Set<String> fieldSet) {
        return ((List<Program__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Account__c IN :accountIdSet').toSOQL()));
    }
}