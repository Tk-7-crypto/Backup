/*
 * Version       : 1.0
 * Description   : Queueable Apex for create box folder for quote object.
 */
public class QUE_CLM_QuoteBoxFoldersJob implements Queueable, Database.allowsCallouts 
{
    
    private List<Quote> quoteList;
    
    public QUE_CLM_QuoteBoxFoldersJob(List<Quote> quoteList) {
        Set<Id> quoteIdSet = new Set<Id>();
        for(Quote quote : quoteList) {
            quoteIdSet.add(quote.Id);
        }
        Set<String> fieldSet = new Set<String>{'AccountId','ContractId',
            'Project_Number__c', 'QuoteNumber', 'Account.Name'};
        this.quoteList = new SLT_Quote().getQuotesById(quoteIdSet, fieldSet);
    }
 
    public void execute(QueueableContext context) {
        Box.Toolkit toolkit = new Box.Toolkit();
        for (Quote quote : this.quoteList) {
            String folderName = quote.Account.Name + (quote.Project_Number__c != null ? ' '+ quote.Project_Number__c:'') + ' '+quote.QuoteNumber;
            String quoteFolderId = toolkit.createFolderForRecordId(quote.Id, folderName, false);
            
            if(quoteFolderId == null){
                system.debug('most recent error: ' + toolkit.mostRecentError);
            }
        }
        toolkit.commitChanges();
    }
}