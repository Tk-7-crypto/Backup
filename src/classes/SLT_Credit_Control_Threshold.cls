/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Credit_Control_Threshold
 */
public class SLT_Credit_Control_Threshold extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Credit_Control_Threshold() {
        super(false, true, false);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_Credit_Control_Threshold(Boolean enforceCRUD, Boolean enforceFLS) {
       super(false, enforceCRUD, enforceFLS);
   }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Credit_Control_Threshold__c.Id,
            Credit_Control_Threshold__c.Name,
            Credit_Control_Threshold__c.Description__c,
            Credit_Control_Threshold__c.Account__c,
            Credit_Control_Threshold__c.Country__c
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Credit_Control_Threshold__c.sObjectType;
    }
    
    /**
     * This method is used to get Credit_Control_Threshold with Account Id and Account Country Set
     * @params Set<Id> accIdSet
     * @params Set<String> accCountrySet
     * @return List<Credit_Control_Threshold__c>
     */
    public List<Credit_Control_Threshold__c> getCreditControlThresholdByAccountId(Set<Id> accIdSet, Set<String> accCountrySet){
        return [Select Id, Account__c, Country__c, Threshold_value_USD__c, Business_Unit__c From Credit_Control_Threshold__c Where Account__c IN :accIdSet OR Country__c IN :accCountrySet OR (Account__c = null AND Country__c = null) Order By Account__c DESC NULLS LAST,Country__c DESC NULLS LAST];
    }
    
    /**
     * This method is used to get Global Credit_Control_Threshold
     * @return List<Credit_Control_Threshold__c>
     */
    public List<Credit_Control_Threshold__c> getGlobalCreditControlThreshold(Set<String> fieldSet){
        return (List<Credit_Control_Threshold__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Account__c = null and Country__c = null').toSOQL());
    }
    
    /**
     * This method is used to get All Credit_Control_Threshold
     * @return List<Credit_Control_Threshold__c>
     */
    public List<Credit_Control_Threshold__c> getAllCreditControlThreshold(Set<String> fieldSet){
        return (List<Credit_Control_Threshold__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setLimit(50000).toSOQL());
    }

}