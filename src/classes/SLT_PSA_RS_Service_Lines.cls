/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for PSA Related Systems Service Lines
 */
public class SLT_PSA_RS_Service_Lines extends fflib_SObjectSelector{
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_PSA_RS_Service_Lines() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_PSA_RS_Service_Lines(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_PSA_RS_Service_Lines(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return PSA_Related_Systems_Service_Lines__c.sObjectType;
    }

    /**
     * This method returns a list of all PSA Related Systems
     */
    public List<PSA_Related_Systems_Service_Lines__c> getAll(){
        Set<String> fields = new Set<String>{'Id', 'PSA_Related_System__c','Service_Line__c', 'Service_Line__r.Name'};
        return ((List<PSA_Related_Systems_Service_Lines__c>) Database.query(newQueryFactory(false).selectFields(fields).toSOQL()));
    }
}