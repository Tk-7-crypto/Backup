public class SLT_Solution extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Solution() {
        super(false, true, true);
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
        return Solution.sObjectType;
    }
    
    /**
     * This method used to get Solution by Id
     * @return  Map<Id, Solution>
     */
    public Map<Id, Solution> selectBySolutionId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Solution>((List<Solution>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
}