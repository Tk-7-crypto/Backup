public class DAOH_BNF2 {
    
    /**
     * method to update Related Opportunity Fields
     * @param List<BNF2__c> newList
     * @param Map<Id, BNF2__c> oldMap
     */
    public static void updateOpportunityFields(List<BNF2__c> newList, Map<Id, BNF2__c> oldMap){
        Boolean toCommit = false;
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { Opportunity_Extension__c.SobjectType } );
        
        if(Trigger.isInsert || Trigger.isDelete){
            Set<Id> oppIdSet = new Set<Id>();
            Map<Id, Opportunity_Extension__c> OppIdToOppExtMap = new Map<Id, Opportunity_Extension__c>();
            Map<Opportunity_Extension__c, Decimal> oppExtToBnfCount = new Map<Opportunity_Extension__c, Decimal>();
            
            for(BNF2__c bnf: newList){
                oppIdSet.add(bnf.Opportunity__c);
            }
            
            for(Opportunity_Extension__c OE : new SLT_Opportunity_Extension().getOpportunityExtensionByOppId(oppIdSet)){
                OppIdToOppExtMap.put(OE.Opportunity__c, OE);
            }
            
            for(BNF2__c bnf: newList){
                Opportunity_Extension__c oppExt = OppIdToOppExtMap.containsKey(bnf.Opportunity__c) ? OppIdToOppExtMap.get(bnf.Opportunity__c) : null;
                Decimal bnfCount = (oppExt != null && oppExt.BNF_Count__c != null) ? oppExt.BNF_Count__c : 0;
                bnfCount = (Trigger.isInsert ? (bnfCount +1) : (bnfCount -1));
                oppExtToBnfCount.put(oppExt, bnfCount);
            }
            
            for(Opportunity_Extension__c oppExt: oppExtToBnfCount.keySet()){
                if(oppExt != null){
                    oppExt.BNF_Count__c = oppExtToBnfCount.containsKey(oppExt) ? oppExtToBnfCount.get(oppExt) : 0;
                    toCommit = true;
                    uow.registerDirty(oppExt);
                }
            }
        }
        if(toCommit){
            UTL_ExecutionControl.stopTriggerExecution = true;
            uow.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
}