public class UTL_CSM_SendMail {
	public static String MODULE_NAME = 'CSM';
    public static String MODULE_ALERT_NAME = 'CSM_01_SendEmail';
    public static String UPDATE_NAME='';
    public static String OLD_OWNER='';
    public static String NEW_OWNER='';
    public static String OLD_OWNER_NAME='';
    public static String NEW_OWNER_NAME='';
    public static String OLD_QUEUE_ID='';
    public static String NEW_QUEUE_ID='';
    public static List<Id> idsToInsert;
    public static Set<String> allEmails;
    public static List<String> queues;
    public static List<User> users;
    public static List<Id> queueids;
    public static List<Queue_User_Relationship__c> queue_detail;
	public static EmailTemplate et = Database.query('Select Id, Name, Subject, HtmlValue, Body from EmailTemplate where Name like \'CSM_Case_Update_Watchlist_Mail\'');
    
    public static void sendMailToWatchListUser(List<MessageWrapper> messageList){
        List<MessageWrapper> messages = new List<MessageWrapper>();
        for(MessageWrapper message : messageList){
            if((message.toEmails!=null && message.toEmails.size()>0)){
            	messages.add(message);
            }
        }
        if(messages.size() == 0)
            return;
			
        List<Workflow_Email_Record__c> workflowRecordList = new List<Workflow_Email_Record__c>();
        queueids = new List<id>();
        idsToInsert = new List<Id>();
        allEmails = new Set<String>();
        for(MessageWrapper message : messages){
            if(message.toEmails != null && !Test.isRunningTest())
        	idsToInsert = message.toEmails;
            if(message.lastModify != null && !Test.isRunningTest())
                idsToInsert.add(message.lastModify);
            if(message.changes == 'Owner Change'){
                List<String> owner = message.changeValue.split('/');
                OLD_OWNER = owner[0].trim()+','+owner[2].trim();
                if(owner[3].trim() != 'null')
                	NEW_OWNER =  owner[1].trim()+','+owner[3].trim();
                else
                    NEW_OWNER =  owner[1].trim();
                idsToInsert.add(owner[0].trim());
                idsToInsert.add(owner[1].trim());
                queueids.add(owner[2].trim());
                if(owner[3].trim() != 'null')
                	queueids.add(owner[3].trim());
            }
        }
        
        users = [Select Id, Email,Name from User where IsActive = true AND Id in :idsToInsert];
        //users = [Select Id, Email,Name from User where Id in :idsToInsert];
        if(queueids != null && !queueids.isEmpty() && !Test.isRunningTest()){
            queue_detail = [SELECT Id,Name from Queue_User_Relationship__c where Id in :queueids];
        } 
        for(MessageWrapper message : messages){
            Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
            
            setWorkflowParameter(objWorkFlowEmail, message);
            if(objWorkFlowEmail.To_Email_1__c != '' && objWorkFlowEmail.To_Email_1__c != null){
            	workflowRecordList.add(objWorkFlowEmail); 
            }
        }
        try{
            if(workflowRecordList != null && !workflowRecordList.isEmpty()){
            	insert workflowRecordList;    
            }
        }
        catch(Exception ex) {
            system.debug('workFlowException:::'+ex.getMessage());
        }
    }
    
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
        
        if(users != null && !users.isEmpty()){
            for(Integer i = 0; i < users.size(); i++){
                if(message.lastModify == users.get(i).Id && !Test.isRunningTest()){
                    UPDATE_NAME = users.get(i).Name;
                }else{
                    allEmails.add(users.get(i).Email);
                }
                if(message.changes == 'Owner Change'){
                    if(OLD_OWNER.contains(users.get(i).Id) && users.get(i).Name != null){
                        OLD_OWNER_NAME = users.get(i).Name;
                    }
                    if(NEW_OWNER.contains(users.get(i).Id) && users.get(i).Name != null){
                        if(OLD_OWNER_NAME != users.get(i).Name)
                        	NEW_OWNER_NAME = users.get(i).Name;
                    }
                }
            }
        }
        if(queue_detail != null && !queue_detail.isEmpty()){
            for(Integer i = 0; i < queue_detail.size(); i++){
                if(message.changes == 'Owner Change'){
                    if(queue_detail != null && OLD_OWNER.contains(queue_detail.get(i).Id) && !Test.isRunningTest() && (OLD_OWNER_NAME == null || OLD_OWNER_NAME == '')){
                        OLD_OWNER_NAME = queue_detail.get(i).Name;
                    }
                    if(queue_detail != null && NEW_OWNER.contains(queue_detail.get(i).Id) && !Test.isRunningTest() && (NEW_OWNER_NAME == null || NEW_OWNER_NAME == '')){
                        NEW_OWNER_NAME = queue_detail.get(i).Name;
                    }
                }
            }
        }
        
		Integer toEmailCounter = 1;
        if(allEmails != null && !allEmails.isEmpty()){
            for(string email: allEmails) {
                if(isValidEmailId(email)) {
                    objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', email);
                    toEmailCounter++;
                }
                if(toEmailCounter==(CON_CRM.MAX_EMAILS_COUNT+1))
                    break;
            }
       }
        updateContent(message);
        objWorkFlowEmail.content_1__c = message.content;
        objWorkFlowEmail.Email_Subject__c = message.subject;
    }
    
    public static void updateContent(Messagewrapper message){
        String domainURL = URL.getOrgDomainUrl().toExternalForm();
        String subject = message.subject;
        subject = subject.replace('{!Case.CaseNumber}', message.caseNumber);
        subject = subject.replace('{!Case.Priority}', message.priority);
        message.subject = subject;
        
        String content = message.content;
        content = content.replace('{!Case.Link}', domainURL+'/lightning/r/Case/'+message.whatId+'/view');
        content = content.replace('{!Case.CaseNumber}', message.caseNumber);
        content = content.replace('{!Case.Priority}', message.priority);
        if(message.changes != null){
            if(message.changes == 'Status Change'){
                content = content.replace('UpdateTitle',message.changes);
                content = content.replace('Updatefield',message.changeValue);    
                content = content.replace('NewComment','');	
            }else if(message.changes == 'Owner Change'){
                content = content.replace('UpdateTitle',message.changes);
                message.changeValue = OLD_OWNER_NAME +' / '+NEW_OWNER_NAME;
                content = content.replace('Updatefield',message.changeValue);
                content = content.replace('NewComment','');	
            }else if(message.changes.contains('Post')){
                content = content.replace('UpdateTitle',message.changes);
                content = content.replace('NewComment',message.changeValue);
                content = content.replace('Updatefield','');
            }else{
                content = content.replace('UpdateTitle',message.changes);
                content = content.replace('Updatefield','');
                content = content.replace('NewComment','');	    
            }
        }
        if(message.title != null)
        	content = content.replace('{!Case.Subject}',message.title);
        else
            content = content.replace('{!Case.Subject}','');
        if(message.origin != null)
        	content = content.replace('{!Case.Origin}',message.origin);
        else
            content = content.replace('{!Case.Origin}','');
        
        content = content.replace('{!Case.ProductName__c}',message.product);
        content = content.replace('LastChange',UPDATE_NAME);
        
        message.content = content;
    }
    
    public static boolean isValidEmailId(String emailId) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(emailId);
        
        if (!emailMatcher.matches())
            res = false;
        return res;
    }
    
    public static void updateEmailMessageMail(String type,List<Case> outgoingEmailCases,Map<Id, Case> incomingEmailCases){
        List<Case> cases = new List<Case>();
        List<UTL_CSM_SendMail.MessageWrapper> messageList = new List<UTL_CSM_SendMail.MessageWrapper>();
        if(incomingEmailCases != null){
            for(Case cs : incomingEmailCases.Values()) {
                cases.add(cs);
            }
        }
        if(outgoingEmailCases != null){
            cases = outgoingEmailCases;
        }
        if(!cases.isEmpty()){

            String[] emails;
            List<String> queue = new List<String>(); 
            List<Queue_User_Relationship__c> qeueUserList = new List<Queue_User_Relationship__c>();
            for(Case cs : cases){
                if(cs.Watch_List_User__c != null && cs.Watch_List_User__c != ''){
                    emails = cs.Watch_List_User__c.split(',');
                    if(emails != null && !emails.isEmpty()) { 
                        for(integer i = 0; i < emails.size(); i++) {     
                            if(emails[i].startsWith('00G')){
                                queue.add(emails[i]);
                            }
                        }
                    }
                }
            }

            if (queue != null && queue.size()>0 ) {
                qeueUserList = [select Id, User__c, Group_Id__c from Queue_User_Relationship__c where Group_Id__c in :queue and Type__c = 'User'];
            }

            for(Case cs : cases){
                if(cs.Watch_List_User__c != null && cs.Watch_List_User__c != ''){
                    UTL_CSM_SendMail.MessageWrapper message = new UTL_CSM_SendMail.MessageWrapper();
                    emails = cs.Watch_List_User__c.split(',');
                    if (qeueUserList != null && qeueUserList.size() > 0 && emails != null && !emails.isEmpty()) {
                        for(Queue_User_Relationship__c u : qeueUserList) {
                            if(emails.contains(u.Group_Id__c))
                                emails.add(u.User__c);
                        } 

                        for(integer i = 0; i < emails.size(); i++) {     
                            if(emails[i].startsWith('00G')){
                               emails.remove(i);
                                i--;
                            }
                        }
                    }
                    String emailbody = et.HtmlValue;
                    String after_replace = emailbody.replace('<![CDATA[','');
                    String after_replace1= after_replace.replace(']]>','');
                    if(emails.size()>0){
                        message.toEmails = emails;
                    }
                    message.targetObjectId = cs.ContactId;
                    message.isTargetObjectAsRecipient = false;
                    message.whatId= cs.Id;
                    if(type.contains('Email')){
                    	message.changes = 'New Email';    
                    }else if(type.contains('Call')){
                        message.changes = 'New Phone Call Activity';
                    }
                    message.caseNumber = cs.CaseNumber;
                    message.priority = cs.Priority;
                    message.lastModify = cs.LastModifiedById;
                    message.title = cs.Subject;
                    if(CON_CSM.S_RDCASE == cs.RecordTypeName__c || CON_CSM.S_R_D_V_T == cs.RecordTypeName__c || CON_CSM.S_ACTIVITY_R_T == cs.RecordTypeName__c){
                        if(cs.LOS__c !=null)
                            message.product = cs.LOS__c;
                        else
                            message.product = '';
                    }else{
                        if(cs.ProductName__c !=null)
                            message.product = cs.ProductName__c;
                        else
                            message.product = '';
                    }
                    message.origin = cs.Origin;
                    message.templateId = et.Id;
                    message.subject = et.Subject;
                    message.content = after_replace1;
                    messageList.add(message);
                }
            }
        }
        if(messageList != null && messageList.size()>0){
        	sendMailToWatchListUser(messageList);
     	}
     }
    
    public static void updateTaskMail(String type,Set<Id> caseIds){
        List<Case> cases = Database.query('SELECT Id,CaseNumber,LOS__c,Priority,RecordTypeName__c,Subject,LastModifiedById,ProductName__c,Origin,Watch_List_User__c,ContactId from Case where Id IN :caseIds');
        updateEmailMessageMail(type,cases,null);
    }
    
    public static void updatePostMail(List<FeedItem> newList,List<Id> caseIds){
        Map<Id,FeedItem> posts = new Map<Id,FeedItem>();
        List<UTL_CSM_SendMail.MessageWrapper> messageList = new List<UTL_CSM_SendMail.MessageWrapper>();
        if(!newList.isEmpty() && !caseIds.isEmpty()){
        	for(FeedItem item : newList){
                if(item.ParentId != null){
                    posts.put(item.ParentId, item);
                }
            }
            List<Case> cases = Database.query('SELECT Id,CaseNumber,LOS__c,Priority,RecordTypeName__c,Subject,LastModifiedById,ProductName__c,Origin,Watch_List_User__c,ContactId from Case where Id IN :caseIds');
            if(!cases.isEmpty()){

                String[] emails;
                List<String> queue = new List<String>(); 
                List<Queue_User_Relationship__c> qeueUserList = new List<Queue_User_Relationship__c>();
                for(Case cs : cases){
                    if(cs.Watch_List_User__c != null && cs.Watch_List_User__c != ''){
                        emails = cs.Watch_List_User__c.split(',');
                        if(emails != null && !emails.isEmpty()) { 
                            for(integer i = 0; i < emails.size(); i++) {     
                                if(emails[i].startsWith('00G')){
                                    queue.add(emails[i]);
                                }
                            }
                        }
                    }
                }

                if (queue != null && queue.size()>0 ) {
                    qeueUserList = [select Id, User__c, Group_Id__c from Queue_User_Relationship__c where Group_Id__c in :queue and Type__c = 'User'];
                }
                
                for(Case cs : cases){
                    if(cs.Watch_List_User__c != null && cs.Watch_List_User__c != ''){
                        UTL_CSM_SendMail.MessageWrapper message = new UTL_CSM_SendMail.MessageWrapper();
                        emails = cs.Watch_List_User__c.split(',');
                        if (qeueUserList != null && qeueUserList.size() > 0 && emails != null && !emails.isEmpty()) {
                            for(Queue_User_Relationship__c u : qeueUserList) {
                                if(emails.contains(u.Group_Id__c))
                                    emails.add(u.User__c);
                            } 

                            for(integer i = 0; i < emails.size(); i++) {     
                                if(emails[i].startsWith('00G')){
                                emails.remove(i);
                                    i--;
                                }
                            }
                        }
                       /* if(!Test.isRunningTest())
                        	emails = cs.Watch_List_User__c.split(',');*/
                        String emailbody = et.HtmlValue;
                        String test = emailbody.replace('<![CDATA[','');
                        String test1= test.replace(']]>','');
                        if(emails.size()>0){
                            message.toEmails = emails;
                        }
                        message.targetObjectId = cs.ContactId;
                        message.isTargetObjectAsRecipient = false;
                        message.whatId= cs.Id;
                        message.changes = 'New Comment or Post';
                        message.changeValue = posts.get(cs.Id).Body;
                        message.caseNumber = cs.CaseNumber;
                        message.priority = cs.Priority;
                        message.lastModify = posts.get(cs.Id).CreatedById;
                        message.title = cs.Subject;
                        if(CON_CSM.S_RDCASE == cs.RecordTypeName__c || CON_CSM.S_R_D_V_T == cs.RecordTypeName__c || CON_CSM.S_ACTIVITY_R_T == cs.RecordTypeName__c){
                            if(cs.LOS__c !=null)
                                message.product = cs.LOS__c;
                            else
                                message.product = '';
                        }else{
                            if(cs.ProductName__c !=null)
                                message.product = cs.ProductName__c;
                            else
                                message.product = '';
                        }
                        message.origin = cs.Origin;
                        message.templateId = et.Id;
                        message.subject = et.Subject;
                        message.content = test1;
                        messageList.add(message);
                    }
                }
            }
    	}
        if(messageList != null && messageList.size()>0){
        	sendMailToWatchListUser(messageList);
        }
    }
    
    public static void updateCaseCommentMail(Map<Id,String> posts){
        Set<Id> keys = posts.keySet();
        List<UTL_CSM_SendMail.MessageWrapper> messageList = new List<UTL_CSM_SendMail.MessageWrapper>();
        List<Case> cases = Database.query('SELECT Id,CaseNumber,LOS__c,Priority,RecordTypeName__c,Subject,LastModifiedById,ProductName__c,Origin,Watch_List_User__c,ContactId from Case where Id IN :keys');
        if(!cases.isEmpty()){
            String[] emails;
            List<String> queue = new List<String>(); 
            List<Queue_User_Relationship__c> qeueUserList = new List<Queue_User_Relationship__c>();
            for(Case cs : cases){
                if(cs.Watch_List_User__c != null && cs.Watch_List_User__c != ''){
                    emails = cs.Watch_List_User__c.split(',');
                    if(emails != null && !emails.isEmpty()) { 
                        for(integer i = 0; i < emails.size(); i++) {     
                            if(emails[i].startsWith('00G')){
                                queue.add(emails[i]);
                            }
                        }
                    }
                }
            }

            if (queue != null && queue.size()>0 ) {
                qeueUserList = [select Id, User__c, Group_Id__c from Queue_User_Relationship__c where Group_Id__c in :queue and Type__c = 'User'];
            }
            for(Case cs : cases){
                if(cs.Watch_List_User__c != null && cs.Watch_List_User__c != ''){
                    UTL_CSM_SendMail.MessageWrapper message = new UTL_CSM_SendMail.MessageWrapper();
                    emails = cs.Watch_List_User__c.split(',');
                    if (qeueUserList != null && qeueUserList.size() > 0 && emails != null && !emails.isEmpty()) {
                        for(Queue_User_Relationship__c u : qeueUserList) {
                            if(emails.contains(u.Group_Id__c))
                                emails.add(u.User__c);
                        } 

                        for(integer i = 0; i < emails.size(); i++) {     
                            if(emails[i].startsWith('00G')){
                            emails.remove(i);
                                i--;
                            }
                        }
                    }
                    /*
                    if(!Test.isRunningTest())
                        emails = cs.Watch_List_User__c.split(',');
                    */
                        
                    String emailbody = et.HtmlValue;
                    String test = emailbody.replace('<![CDATA[','');
                    String test1= test.replace(']]>','');
                    if(emails.size()>0){
                        message.toEmails = emails;
                    }
                    message.targetObjectId = cs.ContactId;
                    message.isTargetObjectAsRecipient = false;
                    message.whatId= cs.Id;
                    message.changes = 'New Comment or Post';
                    message.changeValue = posts.get(cs.Id);
                    message.caseNumber = cs.CaseNumber;
                    message.priority = cs.Priority;
                    message.lastModify = cs.LastModifiedById;
                    message.title = cs.Subject;
                    if(CON_CSM.S_RDCASE == cs.RecordTypeName__c || CON_CSM.S_R_D_V_T == cs.RecordTypeName__c || CON_CSM.S_ACTIVITY_R_T == cs.RecordTypeName__c){
                        if(cs.LOS__c !=null)
                            message.product = cs.LOS__c;
                        else
                            message.product = '';
                    }else{
                        if(cs.ProductName__c !=null)
                            message.product = cs.ProductName__c;
                        else
                            message.product = '';
                    }
                    message.origin = cs.Origin;
                    message.templateId = et.Id;
                    message.subject = et.Subject;
                    message.content = test1;
                    messageList.add(message);
                }
            }
        }
        if(messageList != null && messageList.size()>0){
        	sendMailToWatchListUser(messageList);
     	}
    }
    
     public class MessageWrapper{
        public List<String> toEmails{get; set;}
        public String templateId{get; set;}
        public String whatId{get; set;}
        public String subject{get; set;}
        public String content{get; set;}
        public String targetObjectId{get; set;}
        public boolean isTargetObjectAsRecipient{get; set;}
        public String changes{get; set;}
        public String changeValue{get; set;}
        public String caseNumber{get; set;}
        public String priority{get; set;}
        public String lastModify{get; set;}
        public String title{get; set;}
        public String product{get; set;}
        public String origin{get; set;}   
    }
}