/*
* This is a controller class used in LWC for Action Panel
*/  
public class CNT_CLM_ActionPanelIQVIA {

    /**
     * This function returns IQVIA agreement on the basis of agreementId
     * @param Id agreementId 
     * @return IQVIA_Agreement__c 
     */
    @AuraEnabled(cacheable = true)
    public static IQVIA_Agreement__c getAgreementDetails(Id agreementId) {
        SObjectAccessDecision decision;
        Set<String> fields = new Set<String>{'Generate_AP_Custom__c', 'Regenerate_AP_Custom__c',  
            'Agreement_Number__c', 'Status__c', 'Status_Category__c', 'Record_Type_Developer_Name__c', 
            'Subtype__c', 'Has_Conga__c', 'My_Team_s__c', 'Requestor__c', 'OwnerId','ImportOfflineDocument_AP_Custom__c', 'O365_Internal_Review_AP__c',
            'Helper__c','Is_Other_Agreement__c', 'Preview_AP__c', 'Version_Number__c',
            'Send_For_eSignature__c' ,'Check_eSignature_Status__c', 'Correct_E_Signature_Recipients__c', 'Recall_Void_E_Signature_Request__c' ,'Re_Send_e_Signatures_Reminder__c'};
        try {
            decision = Security.stripInaccessible(AccessType.READABLE, new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(new Set<Id>{agreementId}, fields));
        }
        catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return (IQVIA_Agreement__c)decision.getRecords()[0];
    }
        
    /**
     * This function accept the agreement
     * @param Id agreementId  
     */
    /*    
    @AuraEnabled
    public static void acceptAgreement(String recordId) {
        Id userId = UserInfo.getUserId();
        Boolean statusUpdateOnly = false;
        Boolean updateAgreement = false;
        Set<String> fields = new Set<String>{'Id', 'Name', 'OwnerId', 'Status__c', 'Conga_Agreement_Id__c'};
        List<IQVIA_Agreement__c> agreements = new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(new Set<Id>{recordId},
        fields);
        IQVIA_Agreement__c agreement = agreements[0];
        if(userId == agreement.OwnerId) {
            statusUpdateOnly = true;
            updateAgreement = true;
            agreement.Status__c = CON_CLM.ACCEPTED;
        }
        if(!statusUpdateOnly) {
            String condition = 'Contact__c != null AND Type__c=:firstParam AND Agreement__c IN: agreementIds AND Role__c INCLUDES (\'Contract Analyst\')';
            List<Contact> contacts = new List<Contact>();
            List<User> users = new List<User>();
            List<IQVIA_Agreement_Team__c> agrTeamList = new SLT_Agreement_Team().getAgreementTeamListByAgreementId(
                new Set<Id>{agreement.Id}, new Set<String>{'Id', 'Contact__c'}, condition, 
                CON_CLM.IQVIA_USER_CONTACT_TYPE, null, null);
            for(IQVIA_Agreement_Team__c agreementTeam: agrTeamList){
                contacts = new SLT_Contact().selectByContactIdList(new Set<Id>{agreementTeam.Contact__c},
                    new Set<String>{'EmployeeNumber__c'});
                break;
            }
            for(Contact contact: contacts) {
                users = new SLT_User().selectUserByEmployeeNumber(new Set<String>{contact.EmployeeNumber__c},
                    new Set<String>{'Id'});
                break;
            }
            for(User user: users) {
                agreement.OwnerId = user.Id;
                agreement.Status__c = CON_CLM.ACCEPTED;
                updateAgreement = true;
                break;
            }
        }
        if(updateAgreement) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        IQVIA_Agreement__c.SObjectType
                            }
                );
                uow.registerDirty(agreement);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }
    */
    /**
     * This function validate the accept Agreement request
     * @param Id agreementId  
     * @return String  
     */
    /*
    @AuraEnabled
    public static String validateAccept(String recordId) {
        String valid = 'You are not Authorized to Accept the Agreement';
        Id userId = UserInfo.getUserId();
        String condition = 'Contact__c != null AND Type__c=:firstParam AND Agreement__c IN: agreementIds AND Role__c INCLUDES (\'Team Lead\',\'Contract Analyst\')';
        List<IQVIA_Agreement_Team__c> agrTeamList = new SLT_Agreement_Team().getAgreementTeamListByAgreementId(
            new Set<Id>{recordId}, new Set<String>{'Id', 'Contact__c'}, condition, 
            CON_CLM.IQVIA_USER_CONTACT_TYPE, null, null);
        if(!agrTeamList.isEmpty()) {
            set<Id> contactIdSet = new Set<Id>();
            for(IQVIA_Agreement_Team__c teamLead: agrTeamList) {
                contactIdSet.add(teamLead.Contact__c);
            }
            List<Contact> contacts = new SLT_Contact().selectByContactIdList(contactIdSet, new Set<String>{'EmployeeNumber__c'});
            Set<String> employeeNumberSet = new Set<String>();
            for(Contact contact: contacts) {
                employeeNumberSet.add(contact.EmployeeNumber__c);
            }
            List<User> users = new List<User>();
            if(!employeeNumberSet.isEmpty()) {
                users = new SLT_User().selectUserByEmployeeNumber(employeeNumberSet, new Set<String>{'Id'});
            }
            for(User user: users) {
                if(user.Id == userId) {
                    valid = 'Success';
                }
            }
        }
        return valid;
    }*/
}