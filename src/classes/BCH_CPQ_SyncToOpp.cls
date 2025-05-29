public class BCH_CPQ_SyncToOpp implements Database.Batchable<sobject>{

    Map<Id, Apttus_Proposal__Proposal__c> proposalByIdMap = new Map<Id, Apttus_Proposal__Proposal__c>();
    Apttus_Proposal__Proposal__c proposal;
    public BCH_CPQ_SyncToOpp(Map<Id, Apttus_Proposal__Proposal__c> proposalByIdMap) {
        this.proposalByIdMap = proposalByIdMap;
        this.proposal = proposalByIdMap.values()[0];
        this.proposalByIdMap.remove(this.proposal.Id);
    }

    public Iterable<sObject> start (Database.BatchableContext BC) {
        return new List<Apttus_Proposal__Proposal__c>{this.proposal};
    }
    
    public void execute (Database.BatchableContext BC, List<Apttus_Proposal__Proposal__c> proposaList) {
        if (proposaList != null & proposaList.size() > 0) {
            try {
                QUE_CPQ_SyncBudgetWithOpportunity syncBudgetWithOpportunityJob = new QUE_CPQ_SyncBudgetWithOpportunity(proposaList[0].Id, True);
                Id jobId = System.enqueueJob(syncBudgetWithOpportunityJob);
            }
            catch(Exception ex) {
                String errorMessage = ex.getMessage() + '\n' + ex.getStackTraceString();
                CPQ_Utility.createApexErrorLogRecord(proposal.Id, errorMessage, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        if (proposalByIdMap.size() > 0) {
            Database.executeBatch(new BCH_CPQ_SyncToOpp(proposalByIdMap));
        }
    }
}