/*
 * Version       : 1.0
 * Description   : Queueable Apex for create box folder for budget object.
 */
public class QUE_CPQ_BudgetBoxFoldersJob implements Queueable, Database.allowsCallouts 
{
    
    private List<Apttus_Proposal__Proposal__c> budgetList;
    
    public QUE_CPQ_BudgetBoxFoldersJob(List<Apttus_Proposal__Proposal__c> budgetList) 
    {
        Set<Id> budgetIdSet = new Set<Id>();
        for(Apttus_Proposal__Proposal__c budget : budgetList) 
        {
            budgetIdSet.add(budget.Id);
        }
        Set<String> fieldSet = new Set<String>{CON_CPQ.PROPOSAL_CATEGORY, CON_CPQ.PROPOSAL_RELATED_ACCOUNT_NAME, 
            CON_CPQ.PROPOSAL_RELATED_OPPORTUNITY_QUINTILES_NUMBER, CON_CPQ.NAME, CON_CPQ.AGREEMENT_BID_NUMBER, CON_CPQ.BUDGET_TOOL_VERSION_DATE};
        this.budgetList = new SLT_Proposal().getProposalsById(budgetIdSet, fieldSet);
    }

    public void execute(QueueableContext context) 
    {
        Box.Toolkit toolkit = new Box.Toolkit();
        CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
        String boxDefaultPath = cpqSetting.Box_Path__c;
        for (Apttus_Proposal__Proposal__c budget : this.budgetList) 
        {
            String folderName = '';
            if(budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL
              || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID)    
            {
                folderName = budget.Apttus_Proposal__Opportunity__r.Legacy_Quintiles_Opportunity_Number__c + ' - ' + 
                    budget.Bid_Number__c;
            }
            else
            {
                folderName = budget.Apttus_Proposal__Account__r.Name + ' ' + 
                    budget.Apttus_Proposal__Opportunity__r.Legacy_Quintiles_Opportunity_Number__c + ' ' + budget.Name;
            }
            String budgetFolderId = toolkit.createFolderForRecordId(budget.Id, folderName, false);
            if(budget.Budget_Tool_Version_Date__c >= cpqSetting.SFC_Template_Date__c) {
                if(budgetFolderId != null){
                    budget.External_Link__c = boxDefaultPath.replace('0', budgetFolderId);
                }
                else {
                    budget.External_Link__c = boxDefaultPath;
                }
            }
            else {
                budget.External_Link__c = CON_CPQ.BLANK;
            }
            if(budgetFolderId == null)
                system.debug('most recent error: ' + toolkit.mostRecentError);
        }
        update this.budgetList;
        toolkit.commitChanges();
    }
}