public class CPQ_ReplaceEmailPlaceHolders {
    
    public static void replaceMailBody(Messaging.SingleEmailMessage mailTemplate, Apttus_Proposal__Proposal__c proposal, Boolean isFinalSignOff) {
        try {	
            String htmlBody = mailTemplate.getHtmlBody();
            String blankPlaceholder = '';
            String dsbReviewer = replaceDSBReviewer(proposal);
            htmlBody = htmlBody.replaceFirst(CON_CPQ.PLACEHOLDER, Matcher.quoteReplacement(getApprovalList(proposal.Id, isFinalSignOff)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.PLACEHOLDER_MEDIC, Matcher.quoteReplacement(getMedicUser(proposal.Clinical_Bid__c)));
            htmlBody = htmlBody.replaceAll(CON_CPQ.OPPORTUNIY_NAME_PLACEHOLDER, Matcher.quoteReplacement((proposal.Apttus_Proposal__Opportunity__r.Name != null ? proposal.Apttus_Proposal__Opportunity__r.Name : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.OPPORTUNIY_ACCOUNT_PLACEHOLDER, Matcher.quoteReplacement((proposal.Apttus_Proposal__Account__r.Name != null ? proposal.Apttus_Proposal__Account__r.Name : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.DSB_REVIEWER_PLACEHOLDER, Matcher.quoteReplacement((dsbReviewer != '' ? dsbReviewer : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.INDICATION_PLACEHOLDER, Matcher.quoteReplacement((proposal.Clinical_Bid__r.Indication__c != null ? proposal.Clinical_Bid__r.Indication__c : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.OPPORTUNIY_NUMBER_PLACEHOLDER, Matcher.quoteReplacement((proposal.Opportunity_Number__c != null ? proposal.Opportunity_Number__c : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.BID_DUE_DATE_PLACEHOLDER, Matcher.quoteReplacement((proposal.Clinical_Bid__r.Bid_Due_Date__c != null ? proposal.Clinical_Bid__r.Bid_Due_Date__c.format() : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.SCENARIO_NUMBER_PLACEHOLDER, Matcher.quoteReplacement((proposal.Scenario_Number__c != null ? string.valueOf(proposal.Scenario_Number__c) : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.SCENARIO_PLACEHOLDER, Matcher.quoteReplacement((proposal.RFP_Scenario__c != null ? proposal.RFP_Scenario__c : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.SCENARIO_DESCRIPTION_PLACEHOLDER, Matcher.quoteReplacement((proposal.Scenario_Description__c != null ? proposal.Scenario_Description__c : blankPlaceholder)));
            htmlBody = htmlBody.replaceFirst(CON_CPQ.BUDGET_ITERATION_PLACEHOLDER, Matcher.quoteReplacement((proposal.Budget_Iteration__c != null ? string.valueOf(proposal.Budget_Iteration__c) : blankPlaceholder)));
            mailTemplate.setHtmlBody(htmlBody);
        } catch(Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }
    
    public static void replaceMailSubject(Messaging.SingleEmailMessage mailTemplate, String oppName, String accName) {
        try {
            String blankPlaceholder = '';
            String htmlSubject = mailTemplate.getSubject();
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.OPPORTUNIY_NAME_PLACEHOLDER, Matcher.quoteReplacement((oppName != null ? oppName : blankPlaceholder)));
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.OPPORTUNIY_ACCOUNT_PLACEHOLDER, Matcher.quoteReplacement((accName != null ? accName : blankPlaceholder)));
            mailTemplate.setSubject(htmlSubject);
        } catch(Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }
    
    public static void replaceMailSubjectFunctionalReview (Messaging.SingleEmailMessage mailTemplate, String accName, String oppName, 
        String oppNumber, String budgetType, Decimal scenarioNumber, String scenario, Decimal budgetIteration) {
        try {
            String blankPlaceholder = '';
            String htmlSubject = mailTemplate.getSubject();
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.OPPORTUNIY_ACCOUNT_PLACEHOLDER, Matcher.quoteReplacement((accName != null ? accName : blankPlaceholder)));
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.OPPORTUNIY_NAME_PLACEHOLDER, Matcher.quoteReplacement((oppName != null ? oppName : blankPlaceholder)));
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.OPPORTUNIY_NUMBER_PLACEHOLDER, Matcher.quoteReplacement((oppNumber != null ? oppNumber : blankPlaceholder)));
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.BUDGET_TYPE_PLACEHOLDER, Matcher.quoteReplacement((budgetType != null ? budgetType : blankPlaceholder)));
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.SCENARIO_NUMBER_PLACEHOLDER, Matcher.quoteReplacement((scenarioNumber != null ? string.valueOf(scenarioNumber) : blankPlaceholder)));
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.SCENARIO_PLACEHOLDER, Matcher.quoteReplacement((scenario != null ? scenario : blankPlaceholder)));
            htmlSubject = htmlSubject.replaceFirst(CON_CPQ.BUDGET_ITERATION_PLACEHOLDER, Matcher.quoteReplacement((budgetIteration != null ? string.valueOf(budgetIteration) : blankPlaceholder)));
            mailTemplate.setSubject(htmlSubject);
        } catch(Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }
    
    private static String replaceDSBReviewer(Apttus_Proposal__Proposal__c proposal) {
        String dsbReviewer = '';        
        Set<String> teamMemberFieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.USER_FIELD, CON_CPQ.MEMBER_ROLE, CON_CPQ.ROLE_FROM_RR, CON_CPQ.AGREEMENT_User_EMAIL, CON_CPQ.USER_NAME, CON_CPQ.CONTACT, CON_CPQ.CONTACT_NAME};
        List<Team_Member__c> teamMemberList =  new SLT_TeamMember().getTeamMemberByProposalIdANDRoleORMemberRole(new Set<Id> {proposal.Id}, teamMemberFieldSet, new List<String>{CON_CPQ.FUNCTIONAL_REVIEWER}, new List<String>{CON_CPQ.TSL, CON_CPQ.APPROVER_GROUP_PL});               
        if (teamMemberList.size() > 0) {
            Integer count = 24;
            Boolean isTSLProcessed = false;
            for (Team_Member__c teamMember : teamMemberList) {
                if (teamMember.Role_from_RR__c != null) {
                    String subGroup = teamMember.Role_from_RR__c;
                    String serviceLine = '';
                    String action = '';
                    String reviewerName = teamMember.User__c == null? (teamMember.Contact__c == null ? '' : teamMember.Contact__r.Name) : teamMember.User__r.Name;
                    if (subGroup == CON_CPQ.APPROVER_GROUP_PL) {
                        serviceLine = CON_CPQ.PL;
                        action = CON_CPQ.PLEASE_REVIEW_PL_SME;
                    }
                    else if (subGroup.contains(CON_CPQ.TSL) && !isTSLProcessed){
                        serviceLine = CON_CPQ.APPROVER_GROUP_TSSU;
                        action = CON_CPQ.PLEASE_REVIEW_TIMELINES_STRATEGY;
                        isTSLProcessed = true;
                    }
                    else if (subGroup.contains(CON_CPQ.DSB)) {
                        serviceLine = subGroup.contains(CON_CPQ.HYPHEN) ? subGroup.substringAfter(CON_CPQ.HYPHEN) : subGroup;
                        action = CON_CPQ.PLEASE_REVIEW;
                    }
                    else if (subGroup.contains(CON_CPQ.IQB)) {
                        serviceLine = subGroup.contains(CON_CPQ.HYPHEN) ? subGroup.substringAfter(CON_CPQ.HYPHEN) : subGroup;
                        action = CON_CPQ.PLEASE_REVIEW;
                    }
                    if (serviceLine != '' && action != '') {
                        dsbReviewer += '<tr><td><b>' + reviewerName + '</b></td><td>' + serviceLine + '</td><td> ' + action + '</td></tr>';
                        count--;
                    }
                }
            }
            if (string.isnotEmpty(dsbReviewer)) {
                dsbReviewer += '<tr><td><b>Enter Others Required</b></td><td></td><td></td></tr>';
                for(integer rowCount = 0; rowCount < count; rowCount++) {
                    dsbReviewer += '<tr><td><b>&nbsp;</b></td><td>&nbsp;</td><td>&nbsp;</td></tr>';
                }
            }
        }
        return dsbReviewer;
    }
    
    
    // helper method to get the list of approvals in HTML formet
    private static String getApprovalList(Id recordID, Boolean isFinalSignOff) {
        String approval = CON_CPQ.SALES_AND_ACCOUNT_MANAGEMENT + CON_CPQ.ADD_NAME;
        approval += CON_CPQ.HTML_BREAK_TAG + CON_CPQ.PROJECT_LEADERSHIP + CON_CPQ.ADD_NAME;
        if (!isFinalSignOff) {
            approval += CON_CPQ.HTML_BREAK_TAG + CON_CPQ.THERAPEUTIC_SCIENCE_AND_STRATEGY + CON_CPQ.ADD_NAME;
        }
        return approval;
    }
    
    // Method to get the medic user name
    public static String getMedicUser(Id recordID) {
        List<pse__Assignment__c> assignment = new SLT_Assignment().selectAssignmentByClinicalBidId(recordID, CON_CPQ.MEDICAL_MSL);
        if (assignment.size() > 0 && assignment[0].pse__Resource__c != null && assignment[0].pse__Resource__r.Salesforce_User__c != null) {
            return assignment[0].pse__Resource__r.Salesforce_User__r.Full_User_Name__c;
        }
        return '';
    }
        
    public static void replaceTotalStudyFees(Messaging.SingleEmailMessage mailTemplate, Decimal numberToBeReplaced){
        String htmlBody = mailTemplate.getHtmlBody();
        htmlBody = htmlBody.replaceFirst(CON_CPQ.TOTAL_STUDY_FEES_PLACEHOLDER, Matcher.quoteReplacement(numberToBeReplaced.setScale(2).format()));
        mailTemplate.setHtmlBody(htmlBody);
    }
    
    
    public static void replaceTotalIQVIAFeesCDS(Messaging.SingleEmailMessage mailTemplate, Apttus_Proposal__Proposal__c proposal, Decimal numberToBeReplaced){
        String htmlBody = mailTemplate.getHtmlBody();
        Decimal totalIqviaFeeCDS = proposal.Total_IQVIA_Fees_BID__c;        
        if (proposal.CurrencyIsoCode != CON_CPQ.USD) {
            
            Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(new Set<String>{proposal.CurrencyIsoCode,CON_CPQ.USD});
            totalIqviaFeeCDS = CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(CON_CPQ.USD).conversionRate, 
                isoCodeTocurrencyTypeMap.get(proposal.CurrencyIsoCode).conversionRate, (double)proposal.Total_IQVIA_Fees_BID__c); 	
        }
        htmlBody = htmlBody.replaceFirst(CON_CPQ.TOTAL_IQVIA_FEES_CDS_PLACEHOLDER, Matcher.quoteReplacement(string.valueOf(totalIqviaFeeCDS.setScale(2))));
        mailTemplate.setHtmlBody(htmlBody);   
        
        
    }

}