public class QUE_CPQ_SyncProtocolNumberToOpp implements Queueable {
    Id budgetId;
    Boolean handleException;
    public string GUID {get; set;}
    public static string GUID {
        get {
            if (GUID == null) {
                GUID = UTL_LogFactory.Guid;
            }
            return GUID;
        }
        set;
    }
    
    public QUE_CPQ_SyncProtocolNumberToOpp(Id budgetId, Boolean handleException) {
        this.budgetId = budgetId;
        this.handleException = handleException;
    }
    
    public void execute(QueueableContext context) {
        SavePoint sp = Database.setSavePoint();
        try {
            if (String.isNotBlank(budgetId)) {
                Set<Id> quoteIdSet = new Set<Id>();
                quoteIdSet.add(budgetId);
                List<Opportunity> listOfOppToBeUpdate = new List<Opportunity>();
                Set<Id> oppIdSet = new Set<Id>();
                String condition = 'Id IN :quoteIdSet AND Record_Type_Developer_Name__c = \'RDS_Budget\'';
                for (Apttus_Proposal__Proposal__c proposal : new SLT_Proposal().getProposalByQuoteIds(new Set<String> {CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.APTTUS_PROPOSAL_OPPORTUNITY, CON_CPQ.APPROVAL_STAGE, CON_CPQ.PROTOCOL_NUMBER, 'Apttus_Proposal__Opportunity__r.Protocol_Number__c'}, condition, quoteIdSet)) {
                    if (String.isBlank(proposal.Apttus_Proposal__Opportunity__r.Protocol_Number__c) && String.isNotBlank(proposal.Protocol_Number__c)) {
                        Opportunity opp = new Opportunity();
                        opp.Id = proposal.Apttus_Proposal__Opportunity__c;
                        opp.Protocol_Number__c = proposal.Protocol_Number__c;
                        listOfOppToBeUpdate.add(opp);
                        oppIdSet.add(opp.Id);  
                    }
                }
                if (listOfOppToBeUpdate.size() > 0) {
                    UTL_ExecutionControl.stopTriggerExecution = true;
                    update listOfOppToBeUpdate;
                    if (!Test.isRunningTest()) {
                        System.enqueueJob(new CNT_RFP_UnityFlag_Queuable(CON_CBEx.OPPORTUNITY_OBJECT, new List<Id>(oppIdSet)));
                    }
                    UTL_ExecutionControl.stopTriggerExecution = false;
                }
            } else {
                throw new CPQ_CustomException('Record Id not found.');
            }
        } catch (Exception ex) {
            if (handleException) {
                Database.rollback(sp);
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, GUID, ex.getMessage() + '\n' + ex.getStackTraceString(), CON_CPQ.CPQ, CON_CPQ.CUSTOM, CON_CPQ.DEBUG, Null, budgetId));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            } else {
                throw new CPQ_CustomException(ex.getMessage());
            }
        }
    }
}