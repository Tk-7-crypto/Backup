/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for PSA Related System
 */
public class SLT_PSA_Related_System extends fflib_SObjectSelector{
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_PSA_Related_System() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_PSA_Related_System(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_PSA_Related_System(Boolean enforceFLS,Boolean enforceCRUD) {
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
        return PSA_Related_System__c.sObjectType;
    }

    /**
     * This method returns a list of all PSA Related Systems
     */
    public List<PSA_Related_System__c> getAllPSARelatedSystems(){
        Set<String> fields = new Set<String>{'Id','Name','Type__c','System_Name__c','Hosted_By__c'};
        return ((List<PSA_Related_System__c>) Database.query(newQueryFactory(false).selectFields(fields).toSOQL()));
    }
}