/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunityLineItemSchedule
 */
public class SLT_OpportunityLineItemSchedule extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_OpportunityLineItemSchedule() {
        super(false, true, true);
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return CON_CRM.SCHEDULE_ORDERING;
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
        return OpportunityLineItemSchedule.sObjectType;
    }
    
    /**
     * This method used to get OpportunityLineItemSchedule by oliId
     * @return List<OpportunityLineItemSchedule>
     */
    public List<OpportunityLineItemSchedule> selectByOpportunityLineItemId(Set<ID> oliIdSet, Set<String> fieldSet) {
        return (List<OpportunityLineItemSchedule>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('OpportunityLineItemId IN :oliIdSet').toSOQL());
    }
}