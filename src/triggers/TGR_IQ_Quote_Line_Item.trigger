trigger TGR_IQ_Quote_Line_Item on Quote_Line_Item__c (before delete, after delete) {
    if (Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_IQ_Quote_Line_Item_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_IQ_Quote_Line_Item.class);
    } 
}