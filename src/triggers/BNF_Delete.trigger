// This Trigger stop MIBNF Component deletion if it's status is not equal to New
trigger BNF_Delete on MIBNF_Component__c (before delete) { 
    static boolean preventFurtherValidation = false;
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        for (MIBNF_Component__c MIBNF_Comp:trigger.old)
        {
            if(MIBNF_Comp.BNF_Status__c != 'New' && !MIBNF_Comp.BNF_Status__c.contains('Rejected')){
                MIBNF_Comp.addError('BNF\'s cannot be deleted once they have been submitted.');
                preventFurtherValidation = true;
            }
        }
        
        // Added by Anshita Issue-10862
        if(!preventFurtherValidation)
            DAO_BNF.stopDeletionOfBNF(trigger.oldMap);
        
    }
}