public class CSM_Case_E2CEmailAlert {
    @InvocableMethod
    public static void sendEmailToUser(List<requestEmail> request){
        Set<Id> setOfCaseId = new Set<Id>();
        List<CSM_E2C_Email_Alert__c> listOfCaseE2C = new List<CSM_E2C_Email_Alert__c>();
        Case cs = [Select Id, ContactId, Contact.Email, Status, Contact.PreferredLanguage__c, Account.CSM_Forbidden_Email_to_Case__c, From_EmailToCase__c from Case where Id = :request[0].newCase.Id][0];
        String preferredLanguage = cs.Contact.PreferredLanguage__c;
        String forbid = cs.Account.CSM_Forbidden_Email_to_Case__c;
        String e2c = cs.From_EmailToCase__c;
        if(!request.isEmpty()) {
            /** listOfCaseE2C = [SELECT Id, Email_Template_Id__c, From_Email_Address__c, Account_Country__c FROM CSM_E2C_Email_Alert__c   WHERE  Case_Record_Type__c =: request[0].newCase.RecordTypeName__c AND Send_Email_Action__c =: request[0].caseAction]; **/

            if(forbid != null && e2c != null && forbid.contains(e2c) && request[0].newCase.RecordTypeName__c == 'TechnologyCase'){
                listOfCaseE2C = [select Id, Name, Account_Country__c, Case_Record_Type__c,Send_Email_Action__c , Email_Template_Id__c, From_Email_Address__c,Order__c from CSM_E2C_Email_Alert__c where ((Account_Country__c = :preferredLanguage and Send_Email_Action__c = :request[0].caseAction and Case_Record_Type__c = :request[0].newCase.RecordTypeName__c and From_Email_Address__c = :request[0].newCase.From_EmailToCase__c and Order__c = 12) OR (Send_Email_Action__c = :request[0].caseAction and Case_Record_Type__c = :request[0].newCase.RecordTypeName__c and Order__c = 11)) Order by Order__c desc];
            }else{
                listOfCaseE2C = [select Id, Name, Account_Country__c, Case_Record_Type__c,Send_Email_Action__c , Email_Template_Id__c, From_Email_Address__c,Order__c from CSM_E2C_Email_Alert__c where ((Account_Country__c = :preferredLanguage and Send_Email_Action__c = :request[0].caseAction and Case_Record_Type__c = :request[0].newCase.RecordTypeName__c and From_Email_Address__c = :request[0].newCase.From_EmailToCase__c and Order__c = 4) or (Send_Email_Action__c = :request[0].caseAction and Case_Record_Type__c = :request[0].newCase.RecordTypeName__c and From_Email_Address__c = :request[0].newCase.From_EmailToCase__c and Order__c = 3) or (Account_Country__c = :preferredLanguage and Send_Email_Action__c = :request[0].caseAction and Case_Record_Type__c = :request[0].newCase.RecordTypeName__c and Order__c = 2) or (Send_Email_Action__c = :request[0].caseAction and Case_Record_Type__c = :request[0].newCase.RecordTypeName__c  and Order__c = 1 )) Order by Order__c desc];
            }
        }
        String senderId;
        String emailTemplateName;
        String emailaddress;
        String emailTemplateId;
        if(!listOfCaseE2C.isEmpty()) {
            for(CSM_E2C_Email_Alert__c alert: listOfCaseE2C) {
                emailTemplateName = alert.Email_Template_Id__c;
                emailaddress = request[0].newCase.From_EmailToCase__c;
                break;
            }
        }
        List<EmailTemplate> listOfEmailTemplate = New SLT_EmailTemplate().selectEmailDTemplateByName(emailTemplateName, new Set<String> {'Id'});
        if(!listOfEmailTemplate.isEmpty()) {
            emailTemplateId = listOfEmailTemplate[0].Id;
        }
        List<OrgWideEmailAddress> listOfEmailAddress= new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress(
            emailaddress , new Set<String>{'id'});
        if(!listOfEmailAddress.isEmpty()) {
            senderId = listOfEmailAddress[0].Id;
        }
        CSM_case_Trigger_Handler__c csmOrgDefault = CSM_case_Trigger_Handler__c.getOrgDefaults();
        if(String.isEmpty(senderId)) {
            if(csmOrgDefault != null) {
                listOfEmailAddress= new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress(csmOrgDefault.CSM_Sender_Email_Id__c , new Set<String>{'id'});
            }
            if(!listOfEmailAddress.isEmpty()) {
                senderId = listOfEmailAddress[0].Id;
            }
        }
        List<String> toAddresses = new List<String>();
        if(request[0].newCase.RecordTypeName__c == 'TechnologyCase' && request[0].newCase.Status == CON_CSM.S_RESOLVED_WITH_C && cs.ContactId != null && cs.Contact.Email != null){
            toAddresses.add(cs.Contact.Email);
        }else{
            toAddresses.add(request[0].newCase.SuppliedEmail);
        }
        if(!toAddresses.isEmpty()){
            List<Messaging.SingleEmailMessage> dataSendEmailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
            mailMessage.setTemplateId(emailTemplateId);
            if(senderId != null ) {
                mailMessage.setOrgWideEmailAddressId(senderId);
            }
            mailMessage.setSaveAsActivity(false);
            if(request[0].newCase.ContactId != null) {
                mailMessage.setTargetObjectId(request[0].newCase.ContactId);
            } else if(csmOrgDefault != null){
                Contact newContact = [SELECT Id, Email from Contact where Id =: csmOrgDefault.Default_Contact_Id__c limit 1];
                mailMessage.setTargetObjectId(newContact.Id);
            }
            mailMessage.setWhatId(request[0].newCase.Id);
            mailMessage.setReferences(Cases.generateThreadingMessageId(request[0].newCase.Id));
            mailMessage.setTreatTargetObjectAsRecipient(false);
            mailMessage.setToAddresses(toAddresses);
            dataSendEmailList.add(mailMessage);                            
            if(dataSendEmailList != null && dataSendEmailList.size() > 0) {
                try{
                    Messaging.sendEmail(dataSendEmailList);
                }
                catch(Exception ex){
                    System.debug('Mail Exception: '+ex.getMessage());
                }
            }
        }
    }
    
    Public class requestEmail{
        @InvocableVariable
        public Case newCase;
        
        @InvocableVariable
        public String caseAction;
    }
}