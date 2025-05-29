/**
 * @description DAOH for Quote Object
 */
public class DAOH_CLM_Quote {
	
    /**
    * This method is update the status change date according to quote status change
    * @params  List<Quote> newQuoteList
    * @params  Map<Id, Quote> oldRecordsMap
    */
    public static void updateStatusChangeDateOnQuote(List<Quote> newQuoteList, Map<Id, Quote> oldRecordsMap){
        for(Quote quote : newQuoteList) {
            if(quote.Status != oldRecordsMap.get(quote.id).Status && quote.Status != '' && quote.Status != null){
                quote.Status_Change_Date__c = System.today();
            }
        }
    }
    /**
    * This method is to update Bid Due Date on update of Approval/Rejected/Completed Date
    * @params  List<Quote> newQuoteList
    * @params  Map<Id, Quote> oldRecordsMap
    */
    public static void updateBidOnQuoteUpdate(List<Quote> newQuoteList, Map<Id, Quote> oldMap) {
        List<BidHistoryWrapper> lstWrapper = new List<BidHistoryWrapper>();
        for(Quote quote : newQuoteList) {
            if(quote.Planned_Execution_Date__c != null 
                && quote.Bid_History__c != null
                && (oldMap == null || (oldMap != null && quote.Planned_Execution_Date__c != oldMap.get(quote.id).Planned_Execution_Date__c))){
                BidHistoryWrapper wrapper = new BidHistoryWrapper();
                wrapper.SObjectName = 'Quote';
                wrapper.bidHistoryId = quote.Bid_History__c;
                wrapper.plannedExecutionDate = quote.Planned_Execution_Date__c;
                lstWrapper.add(wrapper); 
            }
        }
        if(!lstWrapper.isEmpty()) {
            try {
                UTL_OWF.updateContractPostAwardbidFromOtherObject(lstWrapper);
            }
            catch(Exception e){
                for(Quote quote: newQuoteList) {
                    quote.addError('Error from related Bid while updating Bid Due Date - :'
                        + e.getMessage().substringBefore('Class.'));
                }
            }
        }
    }
    
}