public with sharing class SLT_CFI_Meetings extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_CFI_Meetings() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_CFI_Meetings(Boolean enforceFLS,Boolean enforceCRUD) {
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
        return CFI_Meetings__c.sObjectType;
    }
    
    /**
     * This method used to query CFI_Meetings__c
     * @return  List<CFI_Meetings__c>
     */
    public List<CFI_Meetings__c> getCFI_Meetings(Set<String> fieldSet){
        return (List<CFI_Meetings__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /**
     * This method used to query CFI_Meetings__c By lRProjectOverViewIds
     * @return  CFI_Meetings__c 
     */
    public List<CFI_Meetings__c> getCFIMeetingsBylRProjectOverViewIds( Set<String> lRProjectOverViewIds, Set<String> fieldSet ){
        return (List<CFI_Meetings__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview__c IN : lRProjectOverViewIds').toSOQL());
    }
}