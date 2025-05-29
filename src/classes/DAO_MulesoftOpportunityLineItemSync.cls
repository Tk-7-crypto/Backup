public class DAO_MulesoftOpportunityLineItemSync extends fflib_SObjectDomain {
    /**
    * Constructor of this class
    * @params sObjectList List<Mulesoft_OpportunityLineItem_Sync__c>
    */
    public DAO_MulesoftOpportunityLineItemSync(List<Mulesoft_OpportunityLineItem_Sync__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_MulesoftOpportunityLineItemSync(sObjectList);
        }
    }
    
    /**
    * This method is used for After insert of the Mulesoft_Opportunity_Sync__c trigger.
    * @return void
    */
    public override void onAfterInsert() {
        setOppFields();
    }   
    
    /**
    * This method is used for After update of the Mulesoft_Opportunity_Sync__c trigger.
    * @return void
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        setOppFields();
    } 
    
    public void setOppFields() {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                OpportunityLineItem.SobjectType
            }
        );
        Set<Id> oliIdSet = new Set<Id>();
        for(Mulesoft_OpportunityLineItem_Sync__c mls : (List<Mulesoft_OpportunityLineItem_Sync__c>) Trigger.new){
            oliIdSet.add(mls.OpportunityLineItemId__c);
        }
        Map<Id, OpportunityLineItem> oliIdToOppMap = new Map<Id, OpportunityLineItem>([select id, Mulesoft_OpportunityLineItem_Sync__c, LI_OpportunityLineItem_Id__c, LQ_OpportunityLineItem_Id__c from OpportunityLineItem where Id IN :oliIdSet]);
        List<OpportunityLineItem> oliToUpdateList = new List<OpportunityLineItem>();
        for(Mulesoft_OpportunityLineItem_Sync__c mos : (List<Mulesoft_OpportunityLineItem_Sync__c>) Trigger.new){
            if(oliIdToOppMap.containsKey(mos.OpportunityLineItemId__c)){
                if(oliIdToOppMap.get(mos.OpportunityLineItemId__c).Mulesoft_OpportunityLineItem_Sync__c == null || (oliIdToOppMap.get(mos.OpportunityLineItemId__c).LI_OpportunityLineItem_Id__c == null && mos.LI_OpportunityLineItem_Id__c != null) || (oliIdToOppMap.get(mos.OpportunityLineItemId__c).LQ_OpportunityLineItem_Id__c == null && mos.LQ_OpportunityLineItem_Id__c != null)) {
                    oliIdToOppMap.get(mos.OpportunityLineItemId__c).Mulesoft_OpportunityLineItem_Sync__c = mos.Id;
                    oliIdToOppMap.get(mos.OpportunityLineItemId__c).LI_OpportunityLineItem_Id__c = mos.LI_OpportunityLineItem_Id__c;
                    oliIdToOppMap.get(mos.OpportunityLineItemId__c).LQ_OpportunityLineItem_Id__c = mos.LQ_OpportunityLineItem_Id__c;
                    oliToUpdateList.add(oliIdToOppMap.get(mos.OpportunityLineItemId__c));
                }
            }
        }
        if(oliToUpdateList.size() > 0){
            UTL_ExecutionControl.stopTriggerExecution = true;
            uow.registerDirty(oliToUpdateList);
            uow.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
}