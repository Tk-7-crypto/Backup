/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Mulesoft_OpportunityLineItem_Sync__c
 */
public class SLT_MulesoftOpportunityLineItemSync extends fflib_SObjectSelector {

        /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mulesoft_OpportunityLineItem_Sync__c.Id,
            Mulesoft_OpportunityLineItem_Sync__c.Mulesoft_Incoming_Update_GUID__c,
            Mulesoft_OpportunityLineItem_Sync__c.Mulesoft_Sync_Status__c,
            Mulesoft_OpportunityLineItem_Sync__c.Mulesoft_Sync_Timestamp__c,
            Mulesoft_OpportunityLineItem_Sync__c.Mulesoft_Update_GUID__c,
            Mulesoft_OpportunityLineItem_Sync__c.OpportunityLineItemId__c,
            Mulesoft_OpportunityLineItem_Sync__c.LI_OpportunityLineItem_Id__c,
            Mulesoft_OpportunityLineItem_Sync__c.LQ_OpportunityLineItem_Id__c,
            Mulesoft_OpportunityLineItem_Sync__c.Mulesoft_Error_Message__c
        };
    }
    
     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Mulesoft_OpportunityLineItem_Sync__c.sObjectType;
    }
    
    /**
     * This method used to get Mulesoft opportunity lineitem by Id
     * @return  List<Mulesoft_OpportunityLineItem_Sync__c>
     */
    public List<Mulesoft_OpportunityLineItem_Sync__c> selectById(Set<ID> idSet) {
        return (List<Mulesoft_OpportunityLineItem_Sync__c>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get Mulesoft OpportunityLineItem Syncs by OpportunityLineItem Ids
     * @return  List<Mulesoft_OpportunityLineItem_Sync__c>
     */
    public List<Mulesoft_OpportunityLineItem_Sync__c> selectByOLIIds(Set<ID> oliIdSet) {
        return (List<Mulesoft_OpportunityLineItem_Sync__c>)Database.query(newQueryFactory(true).setCondition('OpportunityLineItemId__c IN :oliIdSet').toSOQL());
    }
}