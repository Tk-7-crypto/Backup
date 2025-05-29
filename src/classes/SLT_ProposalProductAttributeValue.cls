/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for ProposalProductAttributeValue
 */public class SLT_ProposalProductAttributeValue extends fflib_SObjectSelector {

     /*
     * constructor to initialise CRUD and FLS
     */
    public SLT_ProposalProductAttributeValue() {
        super(false, true, false);
    }
     
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
    */ 
    public SLT_ProposalProductAttributeValue(Boolean enforceFLS) {
        super(false, true, enforceFLS);
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
        return Apttus_QPConfig__ProposalProductAttributeValue__c.sObjectType;
    }
     
     //Method use to return Proposal Product Attribute Value record based on Id and FieldSet.
     public Map<Id,Apttus_QPConfig__ProposalProductAttributeValue__c> getProposalAttributeRecords(Set<Id> recordIds, Set<String> fieldSet) {
         return new Map<Id, Apttus_QPConfig__ProposalProductAttributeValue__c>((List<Apttus_QPConfig__ProposalProductAttributeValue__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :recordIds').toSOQL()));
     }
    
}