public class CNT_CPQ_CNFLinking {

    @AuraEnabled
    public static WPR_CPQ_Info getCNFRecords(String recordId) {
        try {
            WPR_CPQ_Info info = new WPR_CPQ_Info();
            Apttus_Proposal__Proposal__c prop = new SLT_Proposal().getProposalDetails(recordId, new Set<String>{CON_CPQ.APTTUS_PROPOSAL_OPPORTUNITY, CON_CPQ.RFP_SCENARIO, CON_CPQ.APPROVAL_STAGE});
            info.Scenario = prop.RFP_Scenario__c;
            Set<String> fieldSet = new Set<String>{
                CON_CPQ.ID,
                CON_CPQ.RELATED_CHANGE_ORDER,
                CON_CPQ.NAME,
                CON_CPQ.RFP_SCENARIO,
                CON_CPQ.CHNAGE_ORDER_NUMBER,
                CON_CPQ.CNF_STATUS,
                CON_CPQ.CURRENCYISOCODE,
                CON_CPQ.ACTUAL_QUOTE_AMOUNT,
                CON_CPQ.CNF_APPROVAL_DATE
            };

            String condition = ' Apttus_Proposal__Proposal_Category__c = \'' + CON_CPQ.CNF + '\' AND Apttus_Proposal__Opportunity__c IN :opportunityIdSet AND CNF_Status__c != \''
                                + CON_CPQ.REJECTED_STATUS + '\' AND RFP_Scenario__c != \'' + CON_CPQ.INACTIVE + '\' AND Related_Change_Order__r.Apttus_Proposal__Approval_Stage__c != \'' + CON_CPQ.ACCEPTED + '\'';
            List<Apttus_Proposal__Proposal__c> propList = new SLT_Proposal().getQuoteByRelatedOpportunity(new Set<Id>{prop.Apttus_Proposal__Opportunity__c}, fieldSet, condition);
            if (propList.size() > 0) {
                info.propList = proplist;
            }
            Set<String> fieldSet1 = new Set<String>{
                CON_CPQ.ID,
                CON_CPQ.NAME,
                CON_CPQ.RFP_SCENARIO,
                CON_CPQ.APPROVAL_STAGE
            };

            String condition1 = ' Apttus_Proposal__Proposal_Category__c = \'' + CON_CPQ.CHANGE_ORDER + '\' AND Apttus_Proposal__Opportunity__c IN :opportunityIdSet AND Apttus_Proposal__Approval_Stage__c != \''
                                + CON_CPQ.CANCELLED_STATUS + '\' AND RFP_Scenario__c = \'' + prop.RFP_Scenario__c  + '\'';
            List<Apttus_Proposal__Proposal__c> coList = new SLT_Proposal().getQuoteByRelatedOpportunity(new Set<Id>{prop.Apttus_Proposal__Opportunity__c}, fieldSet1, condition1);
            if (coList.size() > 0) {
                info.coId = coList[0].Id;
            }
            return info;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateCNFs(List<Apttus_Proposal__Proposal__c> records, Boolean flag, String recordId) {
        List<Apttus_Proposal__Proposal__c> updateCNF = new List<Apttus_Proposal__Proposal__c>();
        fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus_Proposal__Proposal__c.SobjectType
            }
        );
            
        try {
            if (flag) {
                for (Apttus_Proposal__Proposal__c prop : records) {
                    updateCNF.add(new Apttus_Proposal__Proposal__c(Id = prop.Id, Related_Change_Order__c = recordId, Change_Order_Number__c = prop.Change_Order_Number__c));
                }
            }
            if (records.size() > 0) {
                uowProposal.registerDirty(updateCNF);
                uowProposal.commitWork();
            }
            return CON_CPQ.SUCCESS;
        } catch (DmlException ex) {
            return ex.getDmlMessage(0);
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    public class WPR_CPQ_Info {
        @AuraEnabled
        public String Scenario { get; set; }
        @AuraEnabled
        public List<Apttus_Proposal__Proposal__c> propList { get; set; }
        @AuraEnabled
        public String coId { get; set; }
    }
}
