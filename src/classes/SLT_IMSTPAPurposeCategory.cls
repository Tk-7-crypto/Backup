/*
 * Version       : 1.0
 * Description   : Selector Class for IMS_TPA_Purpose_Category__c
 */
public class SLT_IMSTPAPurposeCategory extends fflib_SObjectSelector {    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            IMS_TPA_Purpose_Category__c.Id,
            IMS_TPA_Purpose_Category__c.Name,
            IMS_TPA_Purpose_Category__c.IMS_TPA_Purpose__c,
            IMS_TPA_Purpose_Category__c.TPA_Purpose_Category__c,
            IMS_TPA_Purpose_Category__c.isActive__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return IMS_TPA_Purpose_Category__c.sObjectType;
    }

    /**
     * This method used to get all active IMS_TPA_Purpose_Category__c records
     * @return  List<IMS_TPA_Purpose_Category__c>
     */
    public List<IMS_TPA_Purpose_Category__c> selectAllActiveIMSTPAPurposeCategory(Set<String> fieldSet, String orderBy, String sortOrder) {
        fflib_QueryFactory.SortOrder sortingOrder = (sortOrder == 'asc') ? fflib_QueryFactory.SortOrder.ASCENDING : fflib_QueryFactory.SortOrder.DESCENDING;
        return (List<IMS_TPA_Purpose_Category__c>) Database.query(newQueryFactory(true)
                                                                  .selectFields(fieldSet)
                                                                  .setCondition('isActive__c = true AND IMS_TPA_Purpose__r.Is_Active__c = true AND TPA_Purpose_Category__r.isActive__c = true')
                                                                  .addOrdering(orderBy, sortingOrder)
                                                                  .toSOQL());
    }

    public static SLT_IMSTPAPurposeCategory instance {
        get {
            if(instance == null) {
                instance = new SLT_IMSTPAPurposeCategory();
            }
            return instance;
        }
        set;
    }
}