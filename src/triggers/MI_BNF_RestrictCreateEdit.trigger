/******************************************************************************
* This Trigger Prevent user to Create New Multi Invoice BNF if there
* is any BNF submitted for Approval or there is Multi Invoice Already Created.
*/

trigger MI_BNF_RestrictCreateEdit on MIBNF2__c (before insert, before update) { 
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        set<id> MIBNFoppset=new set<id>();
        set<id> currentMIBNFoppset=new set<id>();
        set<id> MIBNFset=new set<id>();
        Set<Id> mibnfToOppIdSet = new Set<Id>();
        Map<id,String> oppIdToErrorMsgMap = new Map<id,String>();
        
        for(MIBNF2__c MIBNF : Trigger.New)
        {
            if(Trigger.isInsert){
                mibnfToOppIdSet.add(MIBNF.opportunity__c);
            }
        }
        
        if(mibnfToOppIdSet.size() > 0 ){
            oppIdToErrorMsgMap = CPQ_QuoteUtilityWO.validateQuoteSyncWithOpportunities(mibnfToOppIdSet);
        }
        if(oppIdToErrorMsgMap.size() > 0){
            for(MIBNF2__c MIBNF : Trigger.New)
            {
                if(Trigger.isInsert && oppIdToErrorMsgMap.containsKey(MIBNF.Opportunity__c) && oppIdToErrorMsgMap.get(MIBNF.Opportunity__c) == 'Success'){
                    MIBNF.Has_Pricing_Configuration__c = True ;
                }
            }
        }
        
        for(MIBNF2__c MIBNF : Trigger.New)
        {
            MIBNFoppset.add(MIBNF.opportunity__c);
            MIBNFset.add(MIBNF.id);
        }
        
        for(MIBNF2__c MIBNFList:[select Opportunity__c from MIBNF2__c where Opportunity__c in : MIBNFoppset])
        {
            currentMIBNFoppset.add(MIBNFList.Opportunity__c);
        }
        
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        for(MIBNF2__c MIBNF: Trigger.new)
        {
            // Check for Already Exist MIBNF
            if(bnfSetting.Enable_IQVIA_BNF_Validation__c && Trigger.isInsert && currentMIBNFoppset.contains(MIBNF.Opportunity__c))
                MIBNF.adderror('A Multi Invoice BNF already exists for this opportunity. Only one Multi Invoice BNF can be created per opportunity.');
        }
        
        
        //Added By kapil Jain on 04,Oct2013 against the ER-0122 ----------------  START HERE
        if(trigger.isUpdate)
        {
            system.debug('@@@@@START MI_BNF'); 
            Map<ID,MIBNF2__c> oldMIBnfMap = Trigger.oldMap;
            Map<ID,MIBNF2__c> newMIBnfMap = Trigger.newMap;
            set<ID> opportunityIdSet = new set<ID>(); 
            
            for(ID bnfId:newMIBnfMap.keySet()){
                MIBNF2__c newMIBnf = newMIBnfMap.get(bnfId);
                MIBNF2__c oldMIBnf = oldMIBnfMap.get(bnfId);
                
                if(newMIBnf.MIBNF_Status__c != oldMIBnf.MIBNF_Status__c && newMIBnf.MIBNF_Status__c == 'SAP Contract Confirmed'){
                    opportunityIdSet.add(newMIBnf.Opportunity__c);
                }
            }
            
            if(opportunityIdSet.size() > 0){
                //Psa_BatchToReIntegrateFailedPods.reIntegrateFailedPoDs(opportunityIdSet);
            }
            system.debug('@@@@@COMPLETE MI_BNF' + opportunityIdSet.size());
        }
        //Added By kapil Jain on 04,Oct2013 against the ER-0122 ----------------  END HERE 
    }
}