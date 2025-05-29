//This Trigger Stop deletion of MIBNF if any child component has status other then New
trigger MI_BNF_Delete on MIBNF2__c (before delete) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        set<id> MIBNFIDset=new set<id>();
        set<id> SubmitttedMIBNFIDset=new set<id>();
        for (MIBNF2__c MIBNF:trigger.old)
        {
            MIBNFIDset.add(MIBNF.id);
        }
        
        List<MIBNF_Component__c> MIBNF_CompList=new List<MIBNF_Component__c>([select MIBNF__c from MIBNF_Component__c where BNF_Status__c!='new' and MIBNF__c in:MIBNFIDset]);
        
        for(MIBNF_Component__c MIBNF_Comp:MIBNF_CompList)
        {
            SubmitttedMIBNFIDset.add(MIBNF_Comp.MIBNF__c);
        } 
        
        for (MIBNF2__c MIBNF:trigger.old)
        {
            if(SubmitttedMIBNFIDset.contains(MIBNF.id))
                MIBNF.addError('MultiInvoice BNF Cannot be deleted once any related BNF\'s has been submitted.');
        }
    }
}