/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Knowledge__kav
 */
public class SLT_MulesoftOpportunitySync extends fflib_SObjectSelector {
    
    
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mulesoft_Opportunity_Sync__c.Id,
            Mulesoft_Opportunity_Sync__c.LI_Mulesoft_Error_Message__c,
            Mulesoft_Opportunity_Sync__c.LI_Mulesoft_Sync_Status__c,
            Mulesoft_Opportunity_Sync__c.LI_Mulesoft_Sync_Timestamp__c,
            Mulesoft_Opportunity_Sync__c.LI_Mulesoft_Update_GUID__c	,
            Mulesoft_Opportunity_Sync__c.LQ_Mulesoft_Error_Message__c,
            Mulesoft_Opportunity_Sync__c.LQ_Mulesoft_Sync_Status__c,
            Mulesoft_Opportunity_Sync__c.LQ_Mulesoft_Sync_Timestamp__c,
            Mulesoft_Opportunity_Sync__c.LQ_Mulesoft_Update_GUID__c,
            Mulesoft_Opportunity_Sync__c.Mulesoft_LI_Incoming_Update_GUID__c,
            Mulesoft_Opportunity_Sync__c.Mulesoft_LQ_Incoming_Update_GUID__c,
            Mulesoft_Opportunity_Sync__c.Opportunity__c,
            Mulesoft_Opportunity_Sync__c.Legacy_IMS_Opportunity_Number__c,
            Mulesoft_Opportunity_Sync__c.Legacy_Quintiles_Opportunity_Number__c,
            Mulesoft_Opportunity_Sync__c.LQ_Opportunity_Id__c,
            Mulesoft_Opportunity_Sync__c.LI_Opportunity_Id__c
                
        };
    }
    
     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Mulesoft_Opportunity_Sync__c.sObjectType;
    }
    
    /**
     * This method used to get Mulesoft Opportunity Syncs by Id
     * @return  List<Mulesoft_Opportunity_Sync__c>
     */
    public List<Mulesoft_Opportunity_Sync__c> selectById(Set<ID> idSet) {
        return (List<Mulesoft_Opportunity_Sync__c>) selectSObjectsById(idSet);
    }
    
    
    /**
     * This method used to get Mulesoft Opportunity Syncs by Opportunity Ids
     * @return  List<Mulesoft_Opportunity_Sync__c>
     */
    public List<Mulesoft_Opportunity_Sync__c> selectByOppIds(Set<ID> oppIdSet) {
        return (List<Mulesoft_Opportunity_Sync__c>)Database.query(newQueryFactory(true).setCondition('Opportunity__c IN :oppIdSet').toSOQL());
    }
}