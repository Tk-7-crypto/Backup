public class DAO_QuotePlatformEvent {
    
    Public Static void updateQuoteFields(List<CPQ_Quote_Event__e> records) {
        List<Quote__c> quotesToUpdate = new List<Quote__c>();
        List<Apttus_Proposal__Proposal__c> proposalRecordUpdateList = new List<Apttus_Proposal__Proposal__c>(); 
        List<Apex_Error_Log__c> apexErrorLogList = new List<Apex_Error_Log__c>();
        
        for (CPQ_Quote_Event__e event : records) {
            if (event.Record_Id__c != null) {
                if (String.valueOf(Id.valueOf(event.Record_Id__c).getsobjecttype()).equals('Quote__c')) {
                    quotesToUpdate.add(new Quote__c(Id = event.Record_Id__c, Execution_Message__c = event.Error_Message__c));
                } else {
                    proposalRecordUpdateList.add(new Apttus_Proposal__Proposal__c(Id = event.Record_Id__c, Execution_Status__c = event.Error_Message__c));
                }
                apexErrorLogList.add(new Apex_Error_Log__c(Error_Message__c = event.Error_Message__c));
            }
        }
        
        if (!quotesToUpdate.isEmpty()) {
            try {
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Quote__c.SobjectType, Apex_Error_Log__c.SobjectType, Apttus_Proposal__Proposal__c.SobjectType
                    }
                );
                uowProposal.registerDirty(quotesToUpdate, new List<SObjectField>());
                uowProposal.registerDirty(proposalRecordUpdateList, new List<SObjectField>());
                uowProposal.registerNew(apexErrorLogList);
                uowProposal.commitWork();
            } catch (DmlException dmlEx) {
                System.debug('Error updating Quote__c records: ' + dmlEx.getMessage());
            }
        } 
    }
}