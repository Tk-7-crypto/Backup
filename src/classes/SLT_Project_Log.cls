/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Project_Log
 */
public class SLT_Project_Log extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Log () {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Project_Log (Boolean enforceFLS) {
        super(false, true, enforceFLS);
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
    public Schema.SObjectType getSObjectType () {
        return Project_Log__c.sObjectType;
    }

    /*
     * finds project metrics for specific fields and conditions
     * fieldSet - specific fields to query
     * conditions - specific condition to apply
     */
    public Project_Log__c[] findBy (Set<String> fieldSet, String conditions) {
        return findByIds(fieldSet, conditions, null);
    }    

    /*
     * finds project metrics for specific fields and conditions
     * fieldSet - specific fields to query
     * conditions - specific condition to apply
     */
    public Project_Log__c[] findByIds (Set<String> fieldSet, String conditions, Set<Id> idSet) {
        fflib_QueryFactory soqlBuilder = newQueryFactory(true);
        soqlBuilder.selectFields(fieldSet);
        soqlBuilder.setCondition(conditions);
        return ((Project_Log__c[]) Database.query(soqlBuilder.toSOQL()));
    }    

}