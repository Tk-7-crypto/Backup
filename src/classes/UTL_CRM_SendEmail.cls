/**
* Utility class for creating and inserting Workflow_Email_Record__c record, these record further picked up by process builder to send the
* Email accordingly.
* version : 1.0
*/ 

public class UTL_CRM_SendEmail {
    /**
* This method process a list of EamilWrapper objects and create corresponding Workflow_Email_Record__c record and insert
* @param emails List<MessageWrapper> list of objects to be process
* if an #MessageWrapper object has staticContent then just add the content to
* Workflow_Email_Record__c.content_1__c directly otherwise generate the content using #Messaging.renderStoredEmailTemplate()
* an #MessageWrapper object must contain staticContent or (templateId, targetObjectId)
* @return boolean
*/
    public static String MODULE_NAME = 'CRM';
    public static String MODULE_ALERT_NAME = 'CRM_01_SendEmail';
    public static Integer CONTENT_LENGTH = 131072;
    public static void sendEmailThroughWorkflow(List<MessageWrapper> messageList){
        List<MessageWrapper> messages = new List<MessageWrapper>();
        
        for(MessageWrapper message : messageList){
            if((message.toEmails!=null && message.toEmails.size()>0) || (message.ccEmails!=null && message.ccEmails.size()>0)
               || (message.toUserIds!=null && message.toUserIds.size()>0) || (message.ccUserIds!=null && message.ccUserIds.size()>0)){
                   messages.add(message);
               }
        }
        
        if(messages.size() == 0)
            return;
			
        List<Workflow_Email_Record__c> workflowRecordList = new List<Workflow_Email_Record__c>();
        
        for(MessageWrapper message : messages){
            Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
            String content;
            if(message.staticContent!=null){
                content = message.staticContent;
                objWorkFlowEmail.Email_Subject__c = message.subject;
            }else{
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(message.templateId, message.targetObjectId, message.whatId);
                content = email.getHTMLBody()!=null?email.getHTMLBody():email.getPlainTextBody();
                objWorkFlowEmail.Email_Subject__c = email.getSubject();
            }
            
            if(content !=null && content.length() > CONTENT_LENGTH && content.length() < CONTENT_LENGTH*2 ){
                objWorkFlowEmail.content_1__c = content.substring(0, CONTENT_LENGTH);
                objWorkFlowEmail.content_2__c = content.substring(CONTENT_LENGTH, content.length());
            }else if(content !=null && content.length() > CONTENT_LENGTH && content.length() < CONTENT_LENGTH*3){
                objWorkFlowEmail.content_1__c = content.substring(0, CONTENT_LENGTH);
                objWorkFlowEmail.content_2__c = content.substring(CONTENT_LENGTH, CONTENT_LENGTH*2);
                objWorkFlowEmail.content_3__c = content.substring(CONTENT_LENGTH*2, content.length());
            }else if(content !=null && content.length() > CONTENT_LENGTH){
                objWorkFlowEmail.content_1__c = content.substring(0, CONTENT_LENGTH);
                objWorkFlowEmail.content_2__c = content.substring(CONTENT_LENGTH, CONTENT_LENGTH*2);
                objWorkFlowEmail.content_3__c = content.substring(CONTENT_LENGTH*2, CONTENT_LENGTH*3);
                objWorkFlowEmail.content_4__c = content.substring(CONTENT_LENGTH*3, CONTENT_LENGTH*4);
            }else{
                objWorkFlowEmail.content_1__c = content;
            }
            setWorkflowParameter(objWorkFlowEmail, message);
            workflowRecordList.add(objWorkFlowEmail);
        }

        system.debug('workflowRecordList:::'+workflowRecordList);
        
        try{
            insert workflowRecordList;
            System.debug(workflowRecordList);
        }
        catch(Exception ex) {
            system.debug('workFlowException:::'+ex.getMessage());
        }
    }
    
    /**
* This method maps the properties from email object to objworkFlwoEmail object.
* @param objWorkFlowEmail Workflow_Email_Record__c
* @param message Messagewrapper
* @return void
*/
    public static void setWorkflowParameter(Workflow_Email_Record__c objWorkFlowEmail, Messagewrapper message){
        if(message.whatId != null && message.whatId != '') {
            objWorkFlowEmail.Related_To_Object_Id__c = message.whatId;
            Id objId = message.whatId;
            objWorkFlowEmail.Related_To_Object_Api__c = objId.getSObjectType().getDescribe().getName();
        }else if(message.targetObjectId != null && message.targetObjectId != ''){
            objWorkFlowEmail.Related_To_Object_Id__c = message.targetObjectId;
            Id objId = message.targetObjectId;
            objWorkFlowEmail.Related_To_Object_Api__c = objId.getSObjectType().getDescribe().getName();
        }
        
        objWorkFlowEmail.Module_Name__c = MODULE_NAME;
        objWorkFlowEmail.Email_Action__c = MODULE_ALERT_NAME;
        
        List<Id> allUserIds = new List<Id>();
        List<Id> idsToInsert = new List<Id>(); // size() should not exceed #CON_CRM.MAX_USER_IDS_COUNT
        List<String> allEmails = new List<String>();
        
        if(message.toUserIds!=null && message.toUserIds.size()>0){
           allUserIds.addAll(message.toUserIds);
        }
        if(message.ccUserIds!=null && message.ccUserIds.size()>0){
            allUserIds.addAll(message.ccUserIds);
        }

        if(allUserIds.size() > CON_CRM.MAX_USER_IDS_COUNT){
            List<User> users = [Select Id, Email from User where IsActive = true AND Id in :allUserIds];
            for(Integer i = 0; i<users.size(); i++){
                if(i >= CON_CRM.MAX_USER_IDS_COUNT){
                    allEmails.add(users.get(i).Email);
                }else{
                    idsToInsert.add(users.get(i).Id);
                }
            }
        }else{
            idsToInsert =  allUserIds;
        }
        
        if(message.toEmails != null && message.toEmails.size() > 0) {
            allEmails.addAll(message.toEmails);
        }
        if(message.ccEmails != null && message.ccEmails.size() > 0) {
            allEmails.addAll(message.ccEmails);
        }

		Integer toEmailCounter = 1;
        Integer toUserCounter = 1;
        
        for(String userId: idsToInsert) {
            objWorkFlowEmail.put('To_User_'+toUserCounter+'__c', userId);
            toUserCounter++;
        }
        
        for(string email: allEmails) {
            if(isValidEmailId(email)) {
                objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', email);
                toEmailCounter++;
            }
            if(toEmailCounter==(CON_CRM.MAX_EMAILS_COUNT+1))
                break;
        }
    }
    
    /**
* This method determines whether a given email id is valid or not.
* @param emailId String
* @return boolean
*/
    public static boolean isValidEmailId(String emailId) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(emailId);
        
        if (!emailMatcher.matches())
            res = false;
        return res;
    }
    
    public class MessageWrapper{
        public List<String> toEmails{get; set;}
        public List<String> ccEmails{get; set;}
        public List<String> toUserIds{get; set;}
        public List<String> ccUserIds{get; set;}
        public String templateId{get; set;}
        public String whatId{get; set;}
        public String subject{get; set;}
        public String staticContent{get; set;}
        public String targetObjectId{get; set;}
        public boolean isTargetObjectAsRecipient{get; set;}
    }
}