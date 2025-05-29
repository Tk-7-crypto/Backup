/**
 * This is Quote trigger handler class.
 * version : 1.0 
 */
public class DAO_Quote extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<Quote>
     */
    public DAO_Quote(List<Quote> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Quote(sObjectList);
        }
    }
    
    /**
     * This method is used for before update of the Quote trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        List<Quote> genericQuoteRecords = new List<Quote>();
        for(Quote quote: (List<Quote>)Records) {
            if(quote.recordTypeId == CON_CLM.QUOTE_GENERIC_RECORDTYPE){
                genericQuoteRecords.add(quote);
            }
        }
        if(!genericQuoteRecords.isEmpty()){
            DAOH_CLM_Quote.updateStatusChangeDateOnQuote(genericQuoteRecords, (Map<Id, Quote>) existingRecords);
        }
    }
    
    /**
    * This method is used for after insert of the Quote trigger.
    * @return void
    */
    public override void onAfterInsert() {
        List<Quote> quoteRecords = new List<Quote>();
        for(Quote quotes : (List<Quote>)Records) {
            if(quotes.recordTypeId == CON_CLM.QUOTE_GENERIC_RECORDTYPE) {
                quoteRecords.add(quotes);
            }
        }
        
        if(quoteRecords.size() > 0) {
            ID jobID = System.enqueueJob(new QUE_CLM_QuoteBoxFoldersJob(quoteRecords));
            DAOH_CLM_Quote.updateBidOnQuoteUpdate(quoteRecords, null);
        }
    }
    
    /**
    * This method is used for after update of the Quote trigger.
    * @return void
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<Quote> genericQuoteRecords = new List<Quote>();
        for(Quote quotes : (List<Quote>)Records) {
            if(quotes.recordTypeId == CON_CLM.QUOTE_GENERIC_RECORDTYPE) {
                genericQuoteRecords.add(quotes);
            }
        }
        
        if(!genericQuoteRecords.isEmpty()) {
            DAOH_CLM_Quote.updateBidOnQuoteUpdate(genericQuoteRecords, (Map<Id, Quote>) existingRecords);
        }
    }
}