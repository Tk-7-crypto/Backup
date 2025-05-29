public without sharing class CNT_CSM_PortalCaseDetails {

    @AuraEnabled
    public static void updateLastLogin() {
        DateTime lastLogin;
        User userRecord = new SLT_User().selectUserByUserId(new Set<Id> {userInfo.getUserId()});
        lastLogin = userRecord.LastLoginDate;
        Contact contactRecord = new SLT_Contact().selectContactBasedOnId(new Set<Id>{userRecord.ContactId})[0];
        if(lastLogin != userRecord.LastLoginValue__c){
            userRecord.LastLoginValue__c = userRecord.LastLoginDate;
            update userRecord;
            contactRecord.CSH_User_Last_connection_date__c = lastLogin;
            update contactRecord;
        }
    }
    
    @AuraEnabled
    public static void updateMailCCList(id recordId, string mailCC) {
        Case caseRecord = new SLT_Case().selectByCaseIdList(new Set<id>{recordId}, new Set<String>{'Mail_CC_List__c'})[0];
        if(mailCC!= null){
            caseRecord.Mail_CC_List__c = mailCC;
        }
        try{
            update caseRecord;
        }
        catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
        
    }
 
    @AuraEnabled
    public static Case getCloneCaseAsParentForFollowUp(String recordId, String followUpDescription, Boolean retrieveOnly) {
        String clonedCaseId;
        if(!retrieveOnly) {
            Case closedCase = new Case(Id = recordId);
            try {
                Case clonedCase =  new DynamicClone().insertClonedCase(closedCase, followUpDescription);
                if(clonedCase != null && clonedCase.Id != null) {
                    clonedCaseId = clonedCase.Id;
                    closedCase.ParentId = clonedCase.Id;
                    DAOH_Case.isClosedCaseUpdatableTechno = true;
                    update closedCase;
                }
            } catch(Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
        } else {
            clonedCaseId = recordId;
        }
        List<Case> caseList = new SLT_Case().selectByCaseIdList(new Set<id>{clonedCaseId}, new Set<String>{'Id', 'CaseNumber', 'Description', 'Subject', 'Status'});
        Case caseToReturn = (caseList != null && caseList.size() > 0) ? caseList[0] : null;
        return caseToReturn;
    }
    
    public Without Sharing class DynamicClone {
        public Case insertClonedCase(Case caseToBeCloned, String followUpDescription) {
            List<Case> clonedCaseList = (List<Case>)UTL_GBL_DynamicClone.cloneObjects(new List<sObject>{(sObject)caseToBeCloned}, caseToBeCloned.getsObjectType());
            Case clonedCase;
            if(clonedCaseList != null && clonedCaseList.size() > 0) {
                clonedCase = clonedCaseList[0];
                clonedCase.Description = followUpDescription;
                clonedCase.Status = CON_CSM.S_NEW;
                clonedCase.ParentId = null;
                clonedCase.ClosedBy__c = null;
                clonedCase.Followed_Case_Id__c = caseToBeCloned.Id;
                clonedCase.EntitlementId = null;
                clonedCase.Resolution__c = '';
                clonedCase.Device__c = '';
                clonedCase.RootCause__c = '';
                clonedCase.FirstCallResolution__c = false;
                clonedCase.TaskMilestone__c = null;
                insert clonedCase;
            }
            return clonedCase;
        }
    }
}