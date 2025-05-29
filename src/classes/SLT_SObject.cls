/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for a generic sObject
 */
public class SLT_SObject extends fflib_SObjectSelector {

    private Schema.SObjectType objectType;

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_SObject() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_SObject(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_SObject(Boolean enforceFLS,Boolean enforceCRUD) {
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

    public List<sObject> selectSObjectByLookup(Schema.sObjectType sObjectType, String relatedFieldName, Id relatedFieldTarget, Set<String> fieldNames){
        objectType = sObjectType;
        return Database.query(newQueryFactory(true).selectFields(fieldNames).setCondition(relatedFieldName+' = :relatedFieldTarget').toSOQL());
    }

    /**
     * Returns active/non-deleted sobject type records by ids and field names
     * @param {Schema.sObjectType} sobject to query
     * @param {Set<String>} sobject ids
     * @param {Set<String>} query fields
     */
    public Map<Id, SObject> selectSObjectRowsByIds(Schema.sObjectType sObjectType, Set<String> recordIds, Set<String> fieldNames) {
        return selectSObjectRowsByIds(sObjectType, recordIds, fieldNames, false);
    }

    /**
     * Returns sobject type records by ids and field names
     * @param {Schema.sObjectType} sobject to query
     * @param {Set<String>} sobject ids
     * @param {Set<String>} query fields
     * @param {Boolean} - when true uses 'ALL ROWS' in the query to allow for grabbing records from Recycle Bin.
     */
    public Map<Id, SObject> selectSObjectRowsByIds(Schema.sObjectType sObjectType, Set<String> recordIds, Set<String> fieldNames, Boolean queryAll) {
        objectType = sObjectType;
        String soql = newQueryFactory(true).setCondition('Id in :recordIds').selectFields(fieldNames).toSOQL();
        if (queryAll) { soql += ' ALL ROWS '; }
        return new Map<Id, SObject>((SObject[]) Database.query(soql));
    }
	
    /**
     * Returns sobject type records by ids and field names
     * @param {Schema.sObjectType} sobject to query
     * @param {Set<String>} sobject ids
     * @param {Set<String>} query fields
     */
    public List<SObject> selectSObjectListByIds(Schema.sObjectType sObjectType, Set<String> recordIds, Set<String> fieldNames) {
        objectType = sObjectType;
        String soql = newQueryFactory(true).setCondition('Id in :recordIds').selectFields(fieldNames).toSOQL();
	    return new List<SObject>((List<SObject>) Database.query(soql));
    }
}