public class CNT_CSM_CaseCSATDetails {
    @AuraEnabled
    public static CSATSurveyWrapper getCustomerRatings(String caseId) {
        Decimal overallSatisfactionForContact = 0;
        Decimal avgSatisfactionForCase = 0;
        Decimal lowestResponseScore = 0;
        List<CSAT_Responses__c> csatResponsesForContact;
        List<Case> caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{caseId}, new Set<String>{'Id','ContactId', 'CSAT_Reviewed__c', 'CSAT_Reviewed_by__c','CSAT_Responded__c'});
        Case caseRecord = (caseList != null && caseList.size() > 0) ? caseList[0] : null;
        AggregateResult[] aggregateResponseForCase = [SELECT SUM(Answer_Numeric__c) answerSumForCase, COUNT(Id) totalQuestions, MIN(Answer_Numeric__c) lowestResponse FROM CSAT_Responses__c WHERE Case__c =: caseId ];
        Decimal totalResponses = (Decimal)aggregateResponseForCase[0].get('totalQuestions');
        if(aggregateResponseForCase != null && aggregateResponseForCase.size() > 0 && totalResponses > 0){
            Decimal answerSumForCase = (Decimal)aggregateResponseForCase[0].get('answerSumForCase');
            Decimal totalQuestions = totalResponses;
            lowestResponseScore = (Decimal)aggregateResponseForCase[0].get('lowestResponse');
            lowestResponseScore = lowestResponseScore != null ? lowestResponseScore : 0;
            avgSatisfactionForCase = (totalQuestions != null && answerSumForCase != null && totalQuestions > 0)  ? answerSumForCase / totalQuestions : 0;
        }
        if(caseRecord.ContactId != null) {
            csatResponsesForContact = [SELECT Question__c, Answer__c, Answer_Numeric__c FROM CSAT_Responses__c WHERE Contact__c =: caseRecord.ContactId ];
            Decimal answerSum = 0;
            Decimal question1Count = 0;
            if(csatResponsesForContact != null && csatResponsesForContact.size() > 0) {
                for(CSAT_Responses__c csat: csatResponsesForContact) {
                    if(csat.Question__c != null && CON_CSM.S_CSAT_QUESTION_1.equalsIgnoreCase(csat.Question__c) && csat.Answer_Numeric__c != null) {
                        answerSum += csat.Answer_Numeric__c;
                        question1Count++;
                    }
                }
            }
            overallSatisfactionForContact = question1Count > 0 ? answerSum / question1Count : 0;
        }
        CSATSurveyWrapper CSATSurveyWrapperInstance = new CSATSurveyWrapper();
        CSATSurveyWrapperInstance.overallSatisfactionForContact = overallSatisfactionForContact.setScale(2);
        CSATSurveyWrapperInstance.avgSatisfactionForCase = avgSatisfactionForCase.setScale(2);
        CSATSurveyWrapperInstance.lowestResponseScore = lowestResponseScore.setScale(2);
        CSATSurveyWrapperInstance.caseRecord = caseRecord;
        CSATSurveyWrapperInstance.isCSATResponseAvailable = ((csatResponsesForContact != null && csatResponsesForContact.size() > 0)
                                                             || (totalResponses > 0 && aggregateResponseForCase != null && aggregateResponseForCase.size() > 0)) ? true : false;
        return CSATSurveyWrapperInstance;
    }
    
    @AuraEnabled
    public static Case saveCase(Case caseRecord) {
        caseRecord.CSAT_Reviewed_by__c = (caseRecord.CSAT_Reviewed_by__c != null && caseRecord.CSAT_Reviewed_by__c != '') ? 
            caseRecord.CSAT_Reviewed_by__c +', '+ System.now().format('dd/MM/yyyy HH:mm') : caseRecord.CSAT_Reviewed_by__c;
        DAOH_Case.isClosedCaseUpdatableTechno = true;
        DAOH_Case.isCaseUpdated = true;
        try{
            update caseRecord;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return caseRecord;
    }
    
    @AuraEnabled
    public static Case saveSLAReviewer(Case caseRecord) {
        if(caseRecord.FCR_Review_Escalation__c != '' && caseRecord.FCR_Review_Escalation__c != null) {
            caseRecord.SLA_FCR_Reviewed_By__c = (caseRecord.SLA_FCR_Reviewed_By__c == null || caseRecord.SLA_FCR_Reviewed_By__c == '') ? 
                UserInfo.getName() +', '+ System.now().format('dd/MM/yyyy HH:mm') : caseRecord.SLA_FCR_Reviewed_By__c;            
        }
        else {
            caseRecord.SLA_FCR_Reviewed_By__c = caseRecord.SLA_FCR_Reviewed__c ? caseRecord.SLA_FCR_Reviewed_By__c : '';
        }
        if(caseRecord.SLA_IRT_Reviewed__c) {
            caseRecord.SLA_IRT_Reviewed_By__c = (caseRecord.SLA_IRT_Reviewed_By__c == null || caseRecord.SLA_IRT_Reviewed_By__c == '') ? 
                UserInfo.getName() +', '+ System.now().format('dd/MM/yyyy HH:mm') : caseRecord.SLA_IRT_Reviewed_By__c;
        }
        else {
            caseRecord.SLA_IRT_Reviewed_By__c = '';
        }
        DAOH_Case.isClosedCaseUpdatableTechno = true;
        DAOH_Case.isCaseUpdated = true;
        try{
            update caseRecord;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return caseRecord;
    }
    public class CSATSurveyWrapper {
        @AuraEnabled
        public Decimal overallSatisfactionForContact; 
        @AuraEnabled
        public Decimal avgSatisfactionForCase;
        @AuraEnabled
        public Decimal lowestResponseScore;
        @AuraEnabled
        public Case caseRecord;
        @AuraEnabled
        public Boolean isCSATResponseAvailable;
        
        public CSATSurveyWrapper() {
            this.overallSatisfactionForContact = 0;
            this.avgSatisfactionForCase = 0;
            this.lowestResponseScore = 0;
            this.caseRecord = new Case();
            this.isCSATResponseAvailable = true;
        }
    }
}