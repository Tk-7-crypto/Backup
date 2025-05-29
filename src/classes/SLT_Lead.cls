public class SLT_Lead  extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Lead() {
        super(false, true, false);
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
        return Lead.sObjectType;
    }
    
    /**
     * This method used to get Lead by Id
     * @return  Map<Id, Contact>
     */
    public Map<Id, Lead> selectByLeadId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Lead>((List<Lead>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }

    /**
     * This method used to get Lead by opprtunity Id
     * @return  Map<Id, Contact>
     */    
     public List<Lead> selectByConvertedOppId (Set<ID> opportunityIdSet){  
        return Database.query('SELECT Id, ConvertedOpportunityId , status , RecordTypeId FROM Lead WHERE ConvertedOpportunityId IN :opportunityIdSet');
    }
}