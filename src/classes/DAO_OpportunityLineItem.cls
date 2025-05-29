/**
 * This is OpportunityLineItem Domain class.
 * version : 1.0
 */
public class DAO_OpportunityLineItem extends fflib_SObjectDomain {
    
    /**
     * Constructor of this class
     * @params sObjectList List<Opportunity>
     */
    public DAO_OpportunityLineItem(List<OpportunityLineItem> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_OpportunityLineItem(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the opportunityLineItem trigger.
     * @return void
     */
    public override void onAfterInsert() {
        //This is the section where all the methods that needs to be run at first are included.
        //DAOH_OpportunityLineItem.upsertIqviaLiZquiMappingObject((List<OpportunityLineItem>)Records, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)Records), null);
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        //DAOH_OpportunityLineItem.createLineItemGroup((List<OpportunityLineItem>)Records);
        DAOH_OpportunityLineItem.setOLIS(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) records), null);
        DAOH_OpportunityLineItem.setLOBOnOpp((List<OpportunityLineItem>)Records);
        
        DAOH_OpportunityLineItem.verifyPrivacyAnalyticsTeamMember((List<OpportunityLineItem>)Records);
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will set the sync fields with the latest changes
        DAOH_OpportunityLineItem.setMulesoftSyncField((List<OpportunityLineItem>)Records, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)Records), null);
        //DAOH_OpportunityLineItem.setLIGRWEField((List<OpportunityLineItem>)Records);
        DAOH_OpportunityLineItem.setOpportunityFields((List<OpportunityLineItem>)Records);
    }
    
    /**
     * This method is used for before insert of the opportunityLineItem trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        //This is the section where all the methods that needs to be run at first are included.
        //This should be at the top since the trigger execution flags are reset in this method
        DAOH_OpportunityLineItem.resetTriggerExecutionFlag((List<OpportunityLineItem>)Records);
        DAOH_OpportunityLineItem.preventUpdateOrDeleteOLIRecord((List<OpportunityLineItem>)Records);        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if(!CON_CRM.IS_CLONE_OPPORTUNITY_FLOW && !CON_CRM.IS_CURRENCY_CHANGE_FLOW){
            DAOH_OpportunityLineItem.validationOnOliForProxyPA(null, (List<OpportunityLineItem>)Records);
        }
        DAOH_OpportunityLineItem.setOliFields((List<OpportunityLineItem>)records, null);
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will validate the OLI mulesoft field updates
        DAOH_OpportunityLineItem.validateMulesoftFieldUpdates((List<OpportunityLineItem>)Records, null, null);
        DAOH_OpportunityLineItem.setMC_CESAndSegmantFlag((List<OpportunityLineItem>)Records);
        //DAOH_OpportunityLineItem.addZeroValueProduct((List<OpportunityLineItem>)Records,null);
        DAOH_OpportunityLineItem.setRevenueDateFields((List<OpportunityLineItem>)records, null);
    }
    
    /**
     * This method is used for before update of the opportunityLineItem trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run at first are included.
        //This should be at the top since the trigger execution flags are reset in this method
        DAOH_OpportunityLineItem.resetTriggerExecutionFlag((List<OpportunityLineItem>)Records);
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OpportunityLineItem.setOLIS(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) records), (Map<Id, OpportunityLineItem>)existingRecords);
        //DAOH_OpportunityLineItem.calculateQuarterlyRevenueValues(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) records));
        if(!CON_CRM.IS_CLONE_OPPORTUNITY_FLOW && !CON_CRM.IS_CURRENCY_CHANGE_FLOW){
            DAOH_OpportunityLineItem.validationForProxyBNFApproval(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)Records), (Map<Id, OpportunityLineItem>)existingRecords);
            DAOH_OpportunityLineItem.validationOnOliForProxyPA((Map<Id, OpportunityLineItem>)existingRecords, (List<OpportunityLineItem>)Records);
        }
        DAOH_OpportunityLineItem.setOliFields((List<OpportunityLineItem>)records,  (Map<Id, OpportunityLineItem>)existingRecords);
        
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will validate the OLI mulesoft field updates
        DAOH_OpportunityLineItem.validateMulesoftFieldUpdates((List<OpportunityLineItem>)Records, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)Records), (Map<Id, OpportunityLineItem>)existingRecords);
        // commented by dheeraj kumar 27 Feb 2019
        //DAOH_OpportunityLineItem.preventUpdateOrDeleteOLIRecord((List<OpportunityLineItem>)Records);
        DAOH_OpportunityLineItem.setMC_CESAndSegmantFlag((List<OpportunityLineItem>)Records);
        DAOH_OpportunityLineItem.setOliTherapyArea((List<OpportunityLineItem>)Records);
        //DAOH_OpportunityLineItem.addZeroValueProduct((List<OpportunityLineItem>)Records,(Map<Id, OpportunityLineItem>)existingRecords);
        DAOH_OpportunityLineItem.setRevenueDateFields((List<OpportunityLineItem>)records, (Map<Id, OpportunityLineItem>)existingRecords);

    }
    
    /**
     * This method is used for after update of the opportunityLineItem trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run at first are included.
        //DAOH_OpportunityLineItem.upsertIqviaLiZquiMappingObject((List<OpportunityLineItem>)Records, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)Records), (Map<Id, OpportunityLineItem>)existingRecords);
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OpportunityLineItem.setMulesoftSyncField((List<OpportunityLineItem>)Records, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)Records), (Map<Id, OpportunityLineItem>)existingRecords);
        DAOH_OpportunityLineItem.setOLIS(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) records), (Map<Id, OpportunityLineItem>)existingRecords);
        if(!CON_CRM.IS_CLONE_OPPORTUNITY_FLOW && !CON_CRM.IS_CURRENCY_CHANGE_FLOW){
            DAOH_OpportunityLineItem.setProxyProjectFields(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) records), (Map<Id, OpportunityLineItem>)existingRecords);
        }  
        DAOH_BNF_OpportunityLineItem.MI_BNF_PriceUpdate((List<OpportunityLineItem>)Records, (Map<Id, OpportunityLineItem>)existingRecords);
        //This is the section where all the methods that needs to be run at last are included. 
    }
    
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        //This is the section where all the methods that needs to be run at first are included.
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_OpportunityLineItem.createOutboundMessageDeletionQueue((List<OpportunityLineItem>)Records);
        DAOH_OpportunityLineItem.preventUpdateOrDeleteOLIRecord((List<OpportunityLineItem>)Records);
        DAOH_OpportunityLineItem.validationOnOliForProxyPA(null, (List<OpportunityLineItem>)Records);
        DAOH_OpportunityLineItem.validationOnOliForProxyProject((List<OpportunityLineItem>)Records);
        //DAOH_OpportunityLineItem.setLIGRWEFieldToFalse(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)Records));
        //This is the section where all the methods that needs to be run at last are included.
    } 
    
    
    /**
     * Override method After Delete Call
     */
    public override void onAfterDelete() {
        //This is the section where all the methods that needs to be run at first are included.
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_BNF_OpportunityLineItem.MI_BNF_LineItem_Delete((List<OpportunityLineItem>)Records);   
        //This is the section where all the methods that needs to be run at last are included.
        DAOH_OpportunityLineItem.deleteIqviaLiZquiMappingObject((List<OpportunityLineItem>)Records);
        if(!CON_CRM.IS_CURRENCY_CHANGE_FLOW) {
            DAOH_OpportunityLineItem.setOpportunityFields((List<OpportunityLineItem>)Records);
        }
        
    } 
    
}