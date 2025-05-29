public class DAOH_IQ_Quote_Line_Item {
    public static Boolean ALLOW_QLI_DELETION = false;
    public static void allowQuoteLineItemDeletion(List<Quote_Line_Item__c> quoteLineItems) {
        for (Quote_Line_Item__c quoteLineItem : quoteLineItems) {
            if (!ALLOW_QLI_DELETION && quoteLineItem.Pathway__c == CON_CPQ.CONGA_PATHWAY) {
                quoteLineItem.addError('This record cannot be deleted.');
            }
        }
    }

    public static void quoteLineItemDeletionEvent(List<Quote_Line_Item__c> quoteLineItems) {
        List<QuoteLineItemEvent__e> eventsToPublish = new List<QuoteLineItemEvent__e>();
        for (Quote_Line_Item__c quoteLineItem : quoteLineItems) {
             eventsToPublish.add(new QuoteLineItemEvent__e(
                 Quote_Line_Item_Id__c = quoteLineItem.Id
             ));
        }
        if (!eventsToPublish.isEmpty()) {
             EventBus.publish(eventsToPublish);
        }
    }
}