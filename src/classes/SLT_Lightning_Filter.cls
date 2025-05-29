/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Lightning Filters
 */
public class SLT_Lightning_Filter extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Lightning_Filter() {
        super(true, false, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to get field set of field names for the sobject
     * @return  Set<String>
     */
    public Set<String> getSObjectFieldSet () {
        Set<String> fieldNames = new Set<String>();
        List<Schema.SObjectField> fields = getSObjectFieldList();
        if (fields != null && fields.size() > 0) {
            for (Schema.SObjectField sobjField : fields) {
                fieldNames.add(String.valueof(sobjField));
            }
        }        
        return fieldNames;
    }    

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Lightning_Filter__c.sObjectType;
    }

    /**
     * This method used to get filter by Program, and optionally inserts one and returns if it doesn't exist
     * @return Lightning_Filter__c 
     */
    public Lightning_Filter__c getLightningFilterByProgram(Id programId, Set<String> fieldSet){
        List<Lightning_Filter__c> filters = Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Program__c = :programId').toSOQL());
        if(filters != null && filters.size() > 0){
            return filters.get(0);
        }
        return null;
    }
}