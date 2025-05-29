public class DAO_IQ_Quote_Line_Item extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<Quote_Line_Item__c>
     */
    public DAO_IQ_Quote_Line_Item(List<Quote_Line_Item__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_IQ_Quote_Line_Item(sObjectList);
        }
    }

    /**
     * This method is used for before Delete of the IQVIA Quote Line Item trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        DAOH_IQ_Quote_Line_Item.allowQuoteLineItemDeletion((List<Quote_Line_Item__c>)Records);
    }

    /**
     * This method is used for after Delete of the IQVIA Quote Line Item trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_IQ_Quote_Line_Item.quoteLineItemDeletionEvent((List<Quote_Line_Item__c>)Records); 
    }
}