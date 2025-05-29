/**
* Created by Ronak Mehta on 19-Jun-2023
* Description : Selector Class for MDM_Invoicing_Transaction__c
*/
public class SLT_MDM_Invoicing_Transaction extends fflib_SObjectSelector{
    
    /************constructor************/
    public SLT_MDM_Invoicing_Transaction(){
        super(true, true, true);
    }
    
    /************param constructor************/
    public SLT_MDM_Invoicing_Transaction(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    /************Method used to get field list of sobject************/
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> { MDM_Invoicing_Transaction__c.Id, MDM_Invoicing_Transaction__c.SAP_Contact_1__c, MDM_Invoicing_Transaction__c.SAP_Contact_2__c, MDM_Invoicing_Transaction__c.SAP_Contact_3__c, MDM_Invoicing_Transaction__c.Address__c, MDM_Invoicing_Transaction__c.Sales_Org__c};
            }
    
    /************Method used to set up type of sobject************/
    public Schema.SObjectType getSObjectType(){
        return MDM_Invoicing_Transaction__c.sObjectType;
    }
    
    /**
     * This Method Used to get invoice by Condition
     * @params Set<String> fieldSet
     * @params String condition
     * @return List<MDM_Invoicing_Transaction__c>
     */
    public List<MDM_Invoicing_Transaction__c> getInvoiceByCondition(Set<String> fieldSet, String condition){
        return (List<MDM_Invoicing_Transaction__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
        
    }
    
    /**
     * This Method Used to get invoice by Sap Contact Id
     * @params Set<String> fieldSet
     * @params String sapContactIdSet
     * @return List<MDM_Invoicing_Transaction__c>
     */
    public List<MDM_Invoicing_Transaction__c> getInvoiceBySapContact(Set<String> fieldSet, Set<Id> sapContactIdSet){
        return (List<MDM_Invoicing_Transaction__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Marked_For_Deletion__c = false AND (SAP_Contact_1__c IN :sapContactIdSet OR SAP_Contact_2__c IN :sapContactIdSet OR SAP_Contact_3__c IN :sapContactIdSet)').toSOQL());
        
    }
    
}