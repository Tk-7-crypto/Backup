public class SLT_TPAAMAFeeMaster extends fflib_SObjectSelector {

    public static SLT_TPAAMAFeeMaster instance {
        get {
            if(instance == null) {
                instance = new SLT_TPAAMAFeeMaster();
            }
            return instance;
        }
        set;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                AMA_Fee_Master__c.Id,
                AMA_Fee_Master__c.Contract_Type__c,
                AMA_Fee_Master__c.Vendor_has_Licence__c,
                AMA_Fee_Master__c.Fee_Calculated__c,
                AMA_Fee_Master__c.Fee__c,
                AMA_Fee_Master__c.Year__c,
                AMA_Fee_Master__c.Proration_Rules_Applied__c,
                AMA_Fee_Master__c.LastModifiedDate,
                AMA_Fee_Master__c.CreatedDate };
                    }

    public Schema.SObjectType getSObjectType() {
        return AMA_Fee_Master__c.sObjectType;
    }

    public List<AMA_Fee_Master__c> selectByFilter(Set<String> fieldSet ,String filterCondition, String orderType) {
        return (List<AMA_Fee_Master__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).addOrdering(orderType, fflib_QueryFactory.SortOrder.DESCENDING).toSOQL());
    }

}