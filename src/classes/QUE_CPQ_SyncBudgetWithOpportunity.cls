public class QUE_CPQ_SyncBudgetWithOpportunity implements Queueable
{
    Id budgetId;
    Boolean handleException;
    String pricingTool;
    String approvalStage;
    String bidCurrency;
    String oppCurrencyCode;
    Decimal requestedCurrencyConversionRate;
    Decimal currentCurrencyConversionRate;

    public string GUID {get; set;}
    
    public static string GUID {
        get {
            if(GUID == null) {
                GUID = UTL_LogFactory.Guid;
            }
            return GUID;
        }
        set;
    }

    public QUE_CPQ_SyncBudgetWithOpportunity(Id budgetId, Boolean handleException) {
        this.budgetId = budgetId;
        this.handleException = handleException;
    }
    
    public QUE_CPQ_SyncBudgetWithOpportunity(Id budgetId, Boolean handleException, String pricingTool, String approvalStage) {
        this.budgetId = budgetId;
        this.handleException = handleException;
        this.pricingTool = pricingTool;
        this.approvalStage = approvalStage;
    }

    public QUE_CPQ_SyncBudgetWithOpportunity(Id budgetId, Boolean handleException, String pricingTool, String approvalStage, String bidCurrency, String oppCurrencyCode, Decimal requestedCurrencyConversionRate, Decimal currentCurrencyConversionRate) {
        this.budgetId = budgetId;
        this.handleException = handleException;
        this.pricingTool = pricingTool;
        this.approvalStage = approvalStage;
        this.bidCurrency = bidCurrency;
        this.oppCurrencyCode = oppCurrencyCode;
        this.requestedCurrencyConversionRate = requestedCurrencyConversionRate;
        this.currentCurrencyConversionRate = currentCurrencyConversionRate;
    }

    public void execute(QueueableContext context) {
        SavePoint sp = Database.setSavePoint();
        try {
            if (pricingTool != null) {
                if (String.valueOf(budgetId.getsobjecttype()).equals('Quote__c')) {
                    CPQ_QuoteUtility.syncQuoteWithOpportunityDynamically(budgetId, pricingTool, approvalStage, bidCurrency, oppCurrencyCode, requestedCurrencyConversionRate, currentCurrencyConversionRate);
                } else {
                    if (approvalStage == 'In-Progress') {
                        CPQ_Utility.initialSyncBudgetWithOpportunity(budgetId, pricingTool);
                    } else {
                        CPQ_Utility.syncBudgetWithOpportunityDynamically(budgetId, pricingTool);
                    }
                }
            } else {
                CPQ_Utility.syncBudgetWithOpportunity(budgetId);
            }
        }
        catch(Exception ex) {
            if (handleException) {
                Database.rollback(sp);
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage() + '\n' + ex.getStackTraceString(), CON_CPQ.CPQ, CON_CPQ.CUSTOM, CON_CPQ.DEBUG, Null, budgetId));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                if (!test.isRunningTest()) {
                    CPQ_Quote_Event__e event = new CPQ_Quote_Event__e(Record_Id__c = budgetId, Error_Message__c = CON_CPQ.FAILED + ' : ' + ex.getMessage() + '\n' + ex.getStackTraceString());
                    EventBus.publish(new List<CPQ_Quote_Event__e> { event });
                    throw new CPQ_CustomException(ex.getMessage());
                }
            } else {
                throw ex;
            } 
        }
    }
}
