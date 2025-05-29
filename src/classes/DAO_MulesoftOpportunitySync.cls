public without sharing class DAO_MulesoftOpportunitySync extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<Mulesoft_Opportunity_Sync__c>
    */
    public DAO_MulesoftOpportunitySync(List<Mulesoft_Opportunity_Sync__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_MulesoftOpportunitySync(sObjectList);
        }
    }
    
    /**
    * This method is used for After insert of the Mulesoft_Opportunity_Sync__c trigger.
    * @return void
    */
    public override void onAfterInsert() {
        setOppFields(null);
    }   
    
    /**
    * This method is used for After update of the Mulesoft_Opportunity_Sync__c trigger.
    * @return void
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        setOppFields((Map<Id,Mulesoft_Opportunity_Sync__c>)Trigger.oldMap);
    } 
    
    public void setOppFields(Map<Id,Mulesoft_Opportunity_Sync__c> oldMap){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SobjectType
            }
        );
        Set<Id> oppIdSet = new Set<Id>();
        for(Mulesoft_Opportunity_Sync__c mos : (List<Mulesoft_Opportunity_Sync__c>) Trigger.new){
            oppIdSet.add(mos.Opportunity__c);
        }
        Set<String> oppFieldSet = new Set<String>{'Id', 'Mulesoft_Opportunity_Sync__c', 'LI_Opportunity_Id__c', 'LQ_Opportunity_Id__c', 'Legacy_IMS_Opportunity_Number__c', 'Legacy_Quintiles_Opportunity_Number__c', 'Update_Type__c', 'IsCurrencyChanged__c'};
        Map<Id, Opportunity> oppIdToOppMap = new SLT_Opportunity(true, false).getOpportunityById(oppIdSet, oppFieldSet);
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        Boolean isOppToUpdate = false;
        for(Mulesoft_Opportunity_Sync__c mos : (List<Mulesoft_Opportunity_Sync__c>) Trigger.new) {    
            isOppToUpdate = false;
            if(oppIdToOppMap.containsKey(mos.Opportunity__c)){
                if(oppIdToOppMap.get(mos.Opportunity__c).Mulesoft_Opportunity_Sync__c == null || (oppIdToOppMap.get(mos.Opportunity__c).LI_Opportunity_Id__c == null && mos.LI_Opportunity_Id__c != null) || (oppIdToOppMap.get(mos.Opportunity__c).LQ_Opportunity_Id__c == null && mos.LQ_Opportunity_Id__c != null) || (oppIdToOppMap.get(mos.Opportunity__c).Legacy_IMS_Opportunity_Number__c == null && mos.Legacy_IMS_Opportunity_Number__c != null) || (oppIdToOppMap.get(mos.Opportunity__c).Legacy_Quintiles_Opportunity_Number__c == null && mos.Legacy_Quintiles_Opportunity_Number__c != null)){
                    oppIdToOppMap.get(mos.Opportunity__c).Mulesoft_Opportunity_Sync__c = mos.id;
                    oppIdToOppMap.get(mos.Opportunity__c).LI_Opportunity_Id__c = mos.LI_Opportunity_Id__c;
                    oppIdToOppMap.get(mos.Opportunity__c).LQ_Opportunity_Id__c = mos.LQ_Opportunity_Id__c;
                    oppIdToOppMap.get(mos.Opportunity__c).Legacy_IMS_Opportunity_Number__c = mos.Legacy_IMS_Opportunity_Number__c;
                    oppIdToOppMap.get(mos.Opportunity__c).Legacy_Quintiles_Opportunity_Number__c = mos.Legacy_Quintiles_Opportunity_Number__c;
                    isOppToUpdate = true;
                }
                if(Trigger.isUpdate && oppIdToOppMap.get(mos.Opportunity__c).IsCurrencyChanged__c 
                   && ((oldMap.get(mos.id).LQ_Mulesoft_Sync_Status__c  == CON_CRM.MULESOFT_SYNC_STATUS_PENDING && (mos.LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED || mos.LQ_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED)) 
                        || (oldMap.get(mos.id).LI_Mulesoft_Sync_Status__c  == CON_CRM.MULESOFT_SYNC_STATUS_PENDING && (mos.LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED || mos.LI_Mulesoft_Sync_Status__c == CON_CRM.MULESOFT_SYNC_STATUS_FAILED)))){
                   oppIdToOppMap.get(mos.Opportunity__c).IsCurrencyChanged__c = false;
                   isOppToUpdate = true;
                } 
                if(isOppToUpdate){
                    oppToUpdateList.add(oppIdToOppMap.get(mos.Opportunity__c));
                }
            }   
        }
        if(oppToUpdateList.size() > 0){
            UTL_ExecutionControl.stopTriggerExecution = true;
            uow.registerDirty(oppToUpdateList);
            uow.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
}