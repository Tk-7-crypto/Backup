/*
 * Version       : 1.0
 * Description   : Selector Class for TPA_Purpose_Category__c
 */
public class SLT_TPAPurposeCategory extends fflib_SObjectSelector {    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            TPA_Purpose_Category__c.Id,
            TPA_Purpose_Category__c.Name,
            TPA_Purpose_Category__c.Category_Name__c,
            TPA_Purpose_Category__c.isActive__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return TPA_Purpose_Category__c.sObjectType;
    }

    /**
     * This method used to get all active TPA_Purpose_Category__c records
     * @return  List<TPA_Purpose_Category__c>
     */
    public List<TPA_Purpose_Category__c> selectAllPurposeCategory(Set<String> fieldSet, String orderBy, String sortOrder) {
        fflib_QueryFactory.SortOrder sortingOrder = (sortOrder == 'asc') ? fflib_QueryFactory.SortOrder.ASCENDING : fflib_QueryFactory.SortOrder.DESCENDING;
        return (List<TPA_Purpose_Category__c>) Database.query(newQueryFactory(true)
                                                              .selectFields(fieldSet)
                                                              .setCondition('isActive__c = true')
                                                              .addOrdering(orderBy, sortingOrder)
                                                              .toSOQL());
    }

    public static SLT_TPAPurposeCategory instance {
        get {
            if(instance == null) {
                instance = new SLT_TPAPurposeCategory();
            }
            return instance;
        }
        set;
    }
}