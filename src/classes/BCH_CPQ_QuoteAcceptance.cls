public class BCH_CPQ_QuoteAcceptance implements Database.Batchable<sobject>, Database.Stateful {						
    Set<Id> recordIdsSet = new Set<Id>();
    Map<Id, List<String>> errorsByIdMap = new Map<Id, List<String>>();
    Map<Id, Apttus_Proposal__Proposal__c> proposalByIdMap = new Map<Id, Apttus_Proposal__Proposal__c>();
    Set<Id> bidIdSet = new Set<Id>();
    public BCH_CPQ_QuoteAcceptance() {

    }
    
    public Iterable<sObject> start (Database.BatchableContext BC) {
        Set<String> budgetTypes = new Set<String>{CON_CPQ.INITIAL, CON_CPQ.REBID};
        Datetime now = System.now();
        Map<Id, Apttus_Proposal__Proposal__c> proposalsByBidIdMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> proposaList = [SELECT Id, Name, Clinical_Bid__c FROM Apttus_Proposal__Proposal__c WHERE RFP_Scenario__c !=: CON_CPQ.INACTIVE AND Apttus_Proposal__Approval_Stage__c =: CON_CPQ.PRESENTED AND Apttus_Proposal__Proposal_Category__c IN: budgetTypes AND Clinical_Bid__r.Related_Quote_Status__c =: CON_CPQ.READY_TO_AWARD AND Clinical_Bid__r.Awarded_Date__c <=: now];
        for (Apttus_Proposal__Proposal__c proposal: proposaList) {
            if (!bidIdSet.contains(proposal.Clinical_Bid__c)) {
                bidIdSet.add(proposal.Clinical_Bid__c);
                proposalsByBidIdMap.put(proposal.Clinical_Bid__c, proposal);
            } else {
                if (proposalsByBidIdMap.containsKey(proposal.Clinical_Bid__c)) {
                    proposalsByBidIdMap.remove(proposal.Clinical_Bid__c);
                }
            }
        }	  
        return proposalsByBidIdMap.values(); 
    }
    
    public void execute (Database.BatchableContext BC, List<Apttus_Proposal__Proposal__c> proposaList) {
        for (Apttus_Proposal__Proposal__c proposal : proposaList) {
            proposalByIdMap.put(proposal.Id, proposal);
            proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.ACCEPTED;
        }
        
        Database.SaveResult[] results = Database.update(proposaList, false);
        handleResults(results);
    }
    
    public void finish(Database.BatchableContext BC) {
        if (recordIdsSet.size() > 0 || Test.isRunningTest()) {
            sendEmailToNotifier(recordIdsSet, proposalByIdMap, errorsByIdMap);
        }
        if (proposalByIdMap.size() > 0) {
            Database.executeBatch(new BCH_CPQ_SyncToOpp(proposalByIdMap));
        }
    }

    public void handleResults(Database.SaveResult[] results) {
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                proposalByIdMap.remove(sr.getId());
                recordIdsSet.add(sr.getId());     
                List<String> errorList = new List<String>();    
                for (Database.Error err : sr.getErrors()) {
                    errorList.add(err.getMessage());
                }
                errorsByIdMap.put(sr.getId(), errorList);
            }
        }
    }

    public void sendEmailToNotifier(Set<Id> recordIdsSet, Map<Id, Apttus_Proposal__Proposal__c> proposalByIdMap, Map<Id, List<String>> errorsByIdMap) {
        String table = '<html><head><style>table {  font-family: arial, sans-serif;  border-collapse: collapse;}td, th {  border: 1px solid black;  text-align: left;  padding: 8px;}</style></head>';
        table += '<body>Hi all,<br><br>This is to inform you that there is a failure in the batch while accepting the quotes.<br><br>';
        table += '<table><tr><th>Name</th><th>Error</th></tr>';
        for (String key: errorsByIdMap.keySet()) {
            String quoteLink = URL.getOrgDomainUrl().toExternalForm() + '/' + key;
            table += '<tr><td><a href=\'' + quoteLink + '\'>' + proposalByIdMap.get(key).Name + '</a></td><td>' + errorsByIdMap.get(key)[0] + '</td></tr>';
        }
        table += '</table><br>Please take appropriate actions further.<br><br>Thanks,<br>IQVIA IT Admin</body></html>';
        Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
        try {
            objWorkFlowEmail.Related_To_Object_Api__c = CON_CPQ.APTTUS_PROPOSAL_PROPOSAL;
            objWorkFlowEmail.Module_Name__c = CON_CPQ.CPQ;
            objWorkFlowEmail.Email_Action__c = 'CPQ_02_SendEmail';
            objWorkFlowEmail.Email_Subject__c = 'Error in Quote Acceptance Batch';
            objWorkFlowEmail.content_1__c = table;
            insert objWorkFlowEmail;
        }
        catch (Exception ex) {
            System.debug('Exception:'+ex.getMessage());
        }
    }
}
