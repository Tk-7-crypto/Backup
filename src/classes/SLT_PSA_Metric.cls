/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Project_Metric
 */
public class SLT_PSA_Metric extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_PSA_Metric () {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_PSA_Metric (Boolean enforceFLS) {
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
        return PSA_Metric__c.sObjectType;
    }

    /*
     * finds sobjects for specific fields and conditions
     * fieldSet - specific fields to query
     * conditions - specific condition to apply
     */
    public PSA_Metric__c[] findBy (Set<String> fieldSet, String conditions) {
        fflib_QueryFactory soqlBuilder = newQueryFactory(true);
        soqlBuilder.selectFields(fieldSet);
        soqlBuilder.setCondition(conditions);
        return ((PSA_Metric__c[]) Database.query(soqlBuilder.toSOQL()));
    }
    
    /**
     * This method returns List<PSA_Metric__c> from IDs
     */
    public List<PSA_Metric__c> getPSA_MetricsFromIds(Set<Id> psaMetricIds, Set<String> requestedFields){
    	List<PSA_Metric__c> psaMetrics = (List<PSA_Metric__c>) Database.query(newQueryFactory(true).selectFields(requestedFields).setCondition('Id IN :psaMetricIds').toSOQL());
        return psaMetrics;
    }
} 
