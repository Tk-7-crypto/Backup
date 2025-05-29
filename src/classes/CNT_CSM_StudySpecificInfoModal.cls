public class CNT_CSM_StudySpecificInfoModal {
    @AuraEnabled
    public static String showAlertForRND(String caseId) {
        Case caseRecord = [SELECT Id, Study__c, Study__r.Study_Specific_Information__c,Is_Study_Attached_First_Time__c, RecordTypeName__c, CaseNumber FROM Case WHERE Id =:caseId];
        CaseAlertWrapper caseAlertWrapperInstance =  new CaseAlertWrapper();
        if(caseRecord != null && (caseRecord.RecordTypeName__c.containsIgnoreCase(CON_CSM.S_RDCASE) || caseRecord.RecordTypeName__c.containsIgnoreCase(CON_CSM.S_ACTIVITY_R_T) || caseRecord.RecordTypeName__c.containsIgnoreCase(CON_CSM.S_R_D_V_T))) {
            if(caseRecord.Study__c != null && caseRecord.Study__r.Study_Specific_Information__c != null && caseRecord.Study__r.Study_Specific_Information__c != '') {
                caseAlertWrapperInstance.caseRecord = caseRecord;
                List<CSM_QI_Data_Audit_Trail__c> caseStudyHistoryList = [SELECT Id, Study__c, Case__c FROM CSM_QI_Data_Audit_Trail__c WHERE Name =: CON_CSM.S_STUDY AND Case__c =: caseRecord.Id AND Action__c =: CON_CSM.S_CHANGED];
                List<String> caseRelatedToStudyList = new List<String>();
                if(caseStudyHistoryList != null && caseStudyHistoryList.size() > 0) {
                    for(CSM_QI_Data_Audit_Trail__c caseStudyHistory: caseStudyHistoryList) {
                        caseRelatedToStudyList.add(caseStudyHistory.Study__c);
                    }
                }
                if(caseRecord.Is_Study_Attached_First_Time__c && caseRelatedToStudyList.indexOf(caseRecord.Study__c) == -1) {
                    caseAlertWrapperInstance.isShowAlert = true;
                    caseRecord.Is_Study_Attached_First_Time__c = false;
                    update caseRecord;
                    return JSON.serialize(caseAlertWrapperInstance);
                }
            }
        }
        caseAlertWrapperInstance.caseRecord = caseRecord;
        caseAlertWrapperInstance.isShowAlert = false;
        return JSON.serialize(caseAlertWrapperInstance);
    }
    
    public class CaseAlertWrapper {
        public Case caseRecord;
        public Boolean isShowAlert;
    }
}
