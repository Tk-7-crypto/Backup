
/*
* Version       : 0.0.1
* Description   : This Apex class is selector layer for SObject
* Created By    : Danish khan
* Created For   : Mapping layer API
*/  
public class SLT_MappingGateway extends fflib_SObjectSelector {

    private Schema.SObjectType objectType;

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_MappingGateway() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_MappingGateway(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
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
        return objectType;
    }

    public String selectSObjectByCondition(Schema.sObjectType sObjectType, String condition, Set<String> fieldNames, String orderBy, String limitation, List<UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor> subTokens) {
        objectType = sObjectType;
        fflib_QueryFactory qf = newQueryFactory(true).selectFields(fieldNames);

        if (String.isNotBlank(condition)) {
            qf.setCondition(condition);
        }

        if (String.isNotBlank(orderBy)) {
            qf.setOrdering(orderBy, fflib_QueryFactory.SortOrder.ASCENDING);
        }

        if (String.isNotBlank(limitation)) {
            qf.setLimit(Integer.valueOf(limitation));
        }
        for (UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor subToken : subTokens) {
            qf.subselectQuery(subToken.entity, true).selectFields(subToken.fields).setCondition(subToken.condition);
        }

        return JSON.serialize(Database.query(qf.toSOQL()));
    }
}
