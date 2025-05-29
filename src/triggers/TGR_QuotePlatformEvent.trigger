trigger TGR_QuotePlatformEvent on CPQ_Quote_Event__e (after insert) {
    if (Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_IQVIA_Quote_Trigger__c) {
        DAO_QuotePlatformEvent.updateQuoteFields(Trigger.New);
    } 
}