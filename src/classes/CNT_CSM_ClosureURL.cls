public with sharing class CNT_CSM_ClosureURL {
    public Id caseId { get; set; }
    public String url {  
        get {
            CSM_Case_Details_Global_Setting__c qualtricsSettings = CSM_Case_Details_Global_Setting__c.getValues('CSM_qualtrics_closure_case');
            if (caseId != null && qualtricsSettings != null && qualtricsSettings.Component_Id__c != null) {
                String otherParams ='';
                List <Case> caseList = new SLT_Case().selectById(new Set<Id> { caseId });
                if(caseList != null && !caseList.isEmpty()) {
                    otherParams = '&casenumber=' + caseList[0].CaseNumber + '&subject='+caseList[0].Subject;
                }
                return CON_CSM.S_QUALTRICS_FORM_URL + qualtricsSettings.Component_Id__c + '?Id=' + caseId + otherParams;
            } else {
                return '#';
            }
        }
    }
}
