public class CNT_CSM_DispatchQueueable implements Queueable {
    
    
    private List<Case> caseData;
    private List<ID> userIds;
    private string caseCommentBody;
    private static final String CSM_NOTIFICATION_EMAIL = 'csm.notification@iqvia.com';
    private static List<OrgWideEmailAddress> orgAddress = null;
    public CNT_CSM_DispatchQueueable(List<Case> records, List<ID> id,String Comments) {
        this.caseData = records;
        this.userIds = id;
        this.caseCommentBody = Comments;
    }
    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail;
        Map<String, String> templateBodyMap = setEmailTemplateWithHtmlValues('HTML');
        Map<String,String> templateSubjectMap = setEmailTemplateWithHtmlValues('Subject');
        List<Messaging.RenderEmailTemplateBodyResult> resList = new List<Messaging.RenderEmailTemplateBodyResult>();
        List<Messaging.RenderEmailTemplateBodyResult> resListSubject = new List<Messaging.RenderEmailTemplateBodyResult>();
        List<String> sendTo = new List<String>();
        orgAddress = [SELECT Id, Address FROM OrgWideEmailAddress where Address =:CSM_NOTIFICATION_EMAIL];
        for(Id userId : userIds){
            mail = new Messaging.SingleEmailMessage();
            if(Test.isRunningTest()){
                sendTo.add('Akansha.gupta@metacube.com');
            }
            if(templateBodyMap != null && templateBodyMap.size() > 0 && templateSubjectMap != null && templateSubjectMap.size() >0 ){
                for(Case caseRecord : caseData){
                    if(caseRecord.RecordTypeName__c =='DATACase'){
                        if(caseRecord.Origin =='Email' && (caseRecord.LastModifiedDate == caseRecord.CreatedDate ) && caseCommentBody =='Dispatch to Queue'){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('CAS_ET_CSM_Data_EscalationNotification_2')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('CAS_ET_CSM_Data_EscalationNotification_2')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, UserInfo.getUserEmail(),resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                        else if(caseCommentBody =='Dispatch to queue'){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('CAS_ET01_CSM_CaseEscalationNotificationTemplate')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('CAS_ET01_CSM_CaseEscalationNotificationTemplate')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, UserInfo.getUserEmail(),resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                        else if(caseCommentBody =='Assign to User'){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('CAS_ET_CSM_Data_AssignNotification')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('CAS_ET_CSM_Data_AssignNotification')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, UserInfo.getUserEmail(),resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                    }
                    else if(caseRecord.RecordTypeName__c =='TechnologyCase'){
                        if(caseCommentBody.contains('CaseComment')){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('has a new Work Note')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('has a new Work Note')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, CSM_NOTIFICATION_EMAIL,resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                        else if(caseRecord.Origin =='Email' && (caseRecord.LastModifiedDate == caseRecord.CreatedDate ) &&   caseCommentBody =='Dispatch to queue'){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('CAS_ET_CSM_Techno_EscalationNotification_2')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('CAS_ET_CSM_Techno_EscalationNotification_2')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, CSM_NOTIFICATION_EMAIL,resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                        else if(caseCommentBody =='Dispatch to queue'){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('CAS_ET_CSM_Techno_EscalationNotification')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('CAS_ET_CSM_Techno_EscalationNotification')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, CSM_NOTIFICATION_EMAIL,resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                        else if(caseCommentBody =='Assign to User'){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('CAS_ET_CSM_Techno_AssignNotification')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('CAS_ET_CSM_Techno_AssignNotification')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, CSM_NOTIFICATION_EMAIL,resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                        else if(caseCommentBody == CON_CSM.S_REMAINING_2_HOURS){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('CAS_ET_CSM_TECH_SLA_2H_before')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('CAS_ET_CSM_TECH_SLA_2H_before')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, CSM_NOTIFICATION_EMAIL,resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                        else if(caseCommentBody == CON_CSM.S_REMAINING_8_HOURS){
                            resList = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateBodyMap.get('CAS_ET_CSM_TECH_SLA_8H_before')});
                            resListSubject = Messaging.renderEmailTemplate(userId, caseRecord.id, new List<String> {templateSubjectMap.get('CAS_ET_CSM_TECH_SLA_8H_before')});
                            mails.add(setMailBody(resList[0].getMergedBody(), userId, CSM_NOTIFICATION_EMAIL,resListSubject[0].getMergedBody(), caseRecord.id));
                        }
                    }
                    
                }
            }
        }
        
        if(!mails.isEmpty()){
            try{
                Messaging.sendEmail(mails);
            }catch(Exception ex){
                System.debug('Class : CNT_CSM_EmailNotification >> Mail Exception : ' + ex.getMessage());
            }
        }
    }
    
    private static Messaging.SingleEmailMessage setMailBody(String htmlBody, String userId, String setReplyEmail ,String subject,Id caseId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setCharset('UTF-8');
        mail.setHtmlBody(htmlBody);
        mail.setTargetObjectId(userId);
        mail.setReplyTo(setReplyEmail);
        mail.saveAsActivity = false;
        mail.setSubject(subject);
        if(setReplyEmail == CSM_NOTIFICATION_EMAIL){
            mail.setOrgWideEmailAddressId(orgAddress[0].id);
            mail.setReferences(Cases.generateThreadingMessageId(caseId));
        }
        
        //mail.setSenderDisplayName(setReplyEmail);
        return mail;
    }
    
    private static Map<String, String> setEmailTemplateWithHtmlValues(string checkForValue){
        List<EmailTemplate> emailTemp = [SELECT Id, Body, HTMLValue, Subject, Name FROM EmailTemplate WHERE Name IN ('CAS_ET_CSM_Techno_Case_Internal_Comment','CAS_ET01_CSM_CaseEscalationNotificationTemplate','CAS_ET_CSM_Techno_AssignNotification','CAS_ET_CSM_Data_AssignNotification','CAS_ET_CSM_Techno_EscalationNotification','CAS_ET_CSM_Data_EscalationNotification_2','CAS_ET_CSM_Techno_EscalationNotification_2','CAS_ET_CSM_TECH_SLA_2H_before','CAS_ET_CSM_TECH_SLA_8H_before')];
        Map<String, String> templateBodyMap = new Map<String, String>();
        for(EmailTemplate et : emailTemp){
            if(checkForValue =='HTML'){
                if(et.Subject.contains('has a new Work Note')){
                    templateBodyMap.put('has a new Work Note', et.HTMLValue);
                }else{
                    templateBodyMap.put(et.Name, et.HTMLValue);
                }
            }else if (checkForValue =='Subject'){
                if(et.Subject.contains('has a new Work Note')){
                    templateBodyMap.put('has a new Work Note', et.Subject);
                }else{
                    templateBodyMap.put(et.Name, et.Subject);
                }
            }
        }
        return templateBodyMap;
        }
}
