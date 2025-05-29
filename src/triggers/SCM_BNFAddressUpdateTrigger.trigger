trigger SCM_BNFAddressUpdateTrigger on BNF2__c (before insert) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_BNF_Trigger__c) {   
        SCM_BNFAddressUpdateHelper triggerHelper = new SCM_BNFAddressUpdateHelper();
        
        if(ConstantClass.stopRecursiveTriggerBNF != true)
        {	
            triggerHelper.onBeforeInsert(trigger.new);
        }
    }
}