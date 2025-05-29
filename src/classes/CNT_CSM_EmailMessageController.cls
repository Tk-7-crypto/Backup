public class CNT_CSM_EmailMessageController {

    @AuraEnabled
    public static List<EmailMessage> getEmailMessages(String recordIdValue){
        return (List<EmailMessage>)Database.query('SELECT Id, ParentId, Subject, Status, TextBody, Incoming, HtmlBody, Headers, FromName, FromAddress, ToAddress, MessageDate, CcAddress, BccAddress FROM EmailMessage WHERE Id = :recordIdValue');
    }
    
    @AuraEnabled
    public static List<Case> getParentDetails(String parentId){
        return (List<Case>)Database.query('SELECT Id, CurrentQueue__c, LOS__c, RecordTypeId, RecordTypeName__c, From_EmailToCase__c, CaseNumber FROM Case WHERE Id = :parentId');
    }
    
    @AuraEnabled
    public static List<Queue_User_Relationship__c> getQueueRelatedEmailAddress(String LOS, String recordTypeId, String currentQueue){
        List<Queue_User_Relationship__c> queueUserList = new List<Queue_User_Relationship__c>();
        if(recordTypeId == CON_CSM.S_R_D_V_T || recordTypeId == CON_CSM.S_ACTIVITY_R_T || recordTypeId == CON_CSM.S_RDCASE){
            queueUserList = Database.query('SELECT Id, Name, Queue_Emails_Text__c, Type__c FROM Queue_User_Relationship__c WHERE Id = :currentQueue AND Type__c = \'Queue\' AND Queue_Emails_Text__c != null');
        }
        else if(recordTypeId == CON_CSM.S_TECHNOLOGY_R_T){
            queueUserList = Database.query('SELECT Id, Name, Queue_Emails_Text__c, Type__c FROM Queue_User_Relationship__c WHERE (Id = :currentQueue OR Name LIKE \'%Tech%\') AND Type__c = \'Queue\' AND Queue_Emails_Text__c != null');
        }
        else if(recordTypeId == CON_CSM.S_DATACASE){
            queueUserList = Database.query('SELECT Id, Name, Queue_Emails_Text__c, Type__c FROM Queue_User_Relationship__c WHERE (Id = :currentQueue OR Name LIKE \'%Data%\') AND Type__c = \'Queue\' AND Queue_Emails_Text__c != null');
        }
        return queueUserList;
    }
    
    @AuraEnabled
    public static boolean sendMailToUsers(String fromAddress, String toAddress, String ccAddress, String bccAddress, String subject, String mailBody, String caseId, List<Id> documentIds, String recordIdValue){
        boolean mailSent = false;
        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
        Map<String, List<String>> objectMap;
        Messaging.SingleEmailMessage mailRecord = new Messaging.SingleEmailMessage();
        Case caseRecord = Database.query('SELECT Id,Case_ThreadToken__c, RecordTypeName__c FROM Case WHERE Id = :caseId');
        /*if(subject.contains('Case.Thread_Id')){
            subject = subject.replace('{!Case.Thread_Id}', EmailMessages.getFormattedThreadingToken(caseId));
        }*/
        if(subject.contains('{!')){
            objectMap = new Map<String, List<String>>();
            String tempSubject = subject;
            String[] strArray = tempSubject.split('\\{!');
            for(String record : strArray){
                String splitRecord = record.split('}')[0];
                if(splitRecord.contains('.')){
                    String[] splittedRecord = splitRecord.split('\\.');
                    if(!objectMap.containsKey(splittedRecord[0])){
                        objectMap.put(splittedRecord[0], new List<String>{splittedRecord[1]});
                    }
                    else{
                        List<String> fieldList = objectMap.get(splittedRecord[0]);
                        if(!fieldList.contains(splittedRecord[1])){
                            fieldList.add(splittedRecord[1]);
                            objectMap.put(splittedRecord[0], fieldList);
                        }
                    }
                }
            }
            Map<String, String> sobjectMap = CNT_CSM_EmailMessageController.getRecordRelatedToFields(objectMap, caseId);
            Set<String> objectNameSet = sobjectMap.keySet();
            for(String keyItem : objectNameSet){
                if(subject.contains(keyItem)){
                    if(sobjectMap.get(keyItem) != null){
                        subject = subject.replace('{!'+keyItem+'}', sobjectMap.get(keyItem));
                    }
                }
            }
        }
        
        /*if(mailBody.contains('Case.Thread_Id')){
            mailBody = mailBody.replace('{!Case.Thread_Id}', EmailMessages.getFormattedThreadingToken(caseId));
        }*/
        if(mailBody.contains('{!')){
            objectMap = new Map<String, List<String>>();
            String tempMailBody = mailBody;
            String[] strArray = tempMailBody.split('\\{!');
            for(String record : strArray){
                String splitRecord = record.split('}')[0];
                if(splitRecord.contains('.')){
                    String[] splittedRecord = splitRecord.split('\\.');
                    if(!objectMap.containsKey(splittedRecord[0])){
                        objectMap.put(splittedRecord[0], new List<String>{splittedRecord[1]});
                    }
                    else{
                        List<String> fieldList = objectMap.get(splittedRecord[0]);
                        if(!fieldList.contains(splittedRecord[1])){
                            fieldList.add(splittedRecord[1]);
                            objectMap.put(splittedRecord[0], fieldList);
                        }
                    }
                }
            }
            Map<String, String> sobjectMap = CNT_CSM_EmailMessageController.getRecordRelatedToFields(objectMap, caseId);
            Set<String> objectNameSet = sobjectMap.keySet();
            for(String keyItem : objectNameSet){
                if(mailBody.contains(keyItem)){
                    if(sobjectMap.get(keyItem) != null){
                        mailBody = mailBody.replace('{!'+keyItem+'}', sobjectMap.get(keyItem));
                    }
                }
            }
        }
        /*if(!subject.contains('ref:_') && !mailBody.contains('ref:_')){
            mailBody = mailBody+'<br/><br/>['+EmailMessages.getFormattedThreadingToken(caseId)+']';
            subject = subject+'\t\t\t ['+EmailMessages.getFormattedThreadingToken(caseId)+']';
        }*/
        mailRecord.setHtmlBody(mailBody);
        mailRecord.setSubject(subject);
        mailRecord.setWhatId(caseId);
        mailRecord.setReferences(Cases.generateThreadingMessageId(caseId));
        List<OrgWideEmailAddress> orgWideList = Database.query('SELECT Id FROM OrgWideEmailAddress WHERE address = :fromAddress');
        if(orgWideList != null && orgWideList.size()>0){
            mailRecord.setOrgWideEmailAddressId(orgWideList[0].id);
        }
        List<String> toAddressList = toAddress.split(';');
        mailRecord.setToAddresses(toAddressList);
        if(ccAddress != null && ccAddress != 'undefined'){
            List<String> ccAddressList = ccAddress.split(';');
            mailRecord.setCcAddresses(ccAddressList);
        }
        if(bccAddress != null && bccAddress != 'undefined'){
            List<String> bccAddressList = bccAddress.split(';');
            mailRecord.setBccAddresses(bccAddressList);
        }
        mailRecord.setSaveAsActivity(false);
        if(documentIds.size()>0){
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for(ContentVersion versionFile : [SELECT Id, Title, VersionData, FileType, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :documentIds AND IsLatest = true]){
                Messaging.Emailfileattachment emailFileAttachment = new Messaging.Emailfileattachment();
                emailFileAttachment.setFileName(versionFile.Title+'.'+versionFile.FileExtension);
                emailFileAttachment.setBody(versionFile.VersionData);
                fileAttachments.add(emailFileAttachment);
            }
            mailRecord.setFileAttachments(fileAttachments);
        }
        mailList.add(mailRecord);
        
        if(mailList != null && mailList.size() > 0) {
            try{
                EmailMessage messageRecord = new EmailMessage();
                messageRecord.ToAddress = toAddress;
                messageRecord.FromAddress = fromAddress;
                messageRecord.CcAddress = ccAddress;
                messageRecord.BccAddress = bccAddress;
                messageRecord.ParentId = caseId;
                messageRecord.CreatedById = UserInfo.getUserId();
                messageRecord.CreatedDate = Datetime.now();
                messageRecord.Subject = subject;
                messageRecord.HtmlBody = mailBody;
                messageRecord.IsSendAsComment__c = true;
                messageRecord.Status = '3';
                messageRecord.ReplyToEmailMessageId = recordIdValue;
                insert messageRecord;
                if(documentIds.size()>0 && messageRecord.id != null){
                    List<ContentDocumentLink> docLinkList = new List<ContentDocumentLink>();
                    for(Id docId : new Set<Id>(documentIds)){
                        docLinkList.add(new ContentDocumentLink(LinkedEntityId = messageRecord.id,ContentDocumentId = docId ,ShareType = 'V',Visibility = 'AllUsers'));
                    }
                    if(!docLinkList.isEmpty()){
                        insert docLinkList;   
                    }
                }

                Messaging.sendEmail(mailList);
                mailSent = true;
            }
            catch(Exception ex){
                System.debug('Mail Exception: '+ex.getMessage());
            }
        }
        return mailSent;
    }
    
    @AuraEnabled
    public static List<ContentDocument> selectForwardDataForAttachment(String recordIdValue){
        List<ContentDocument> documentList = new List<ContentDocument>();
        System.debug('recordIdValue : '+recordIdValue);
        List<ContentDocumentLink> linkList = Database.query('select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility from ContentDocumentLink where LinkedEntityId =:recordIdValue');
        List<Id> docIds = new List<Id>();
        if(linkList != null && !linkList.isEmpty()){
            for(ContentDocumentLink l : linkList){
                docIds.add(l.ContentDocumentId);
            }
            documentList = Database.query('SELECT Id, CreatedById, CreatedDate, OwnerId, Title, Description, ContentSize, FileType, FileExtension, ParentId FROM ContentDocument WHERE Id In :docIds');
        }
        return documentList;
    }
    
    @AuraEnabled
    public static List<ContentDocument> loadDataForAttachment(String attachmentType){
        List<ContentDocument> documentList = new List<ContentDocument>();
        String userId = UserInfo.getUserId();
        if(attachmentType.equalsIgnoreCase('owned')){
            documentList = Database.query('SELECT Id, CreatedById, CreatedDate, OwnerId, Title, Description, ContentSize, FileType, FileExtension, ParentId FROM ContentDocument WHERE OwnerId = :userId');
        }
        return documentList;
    }
    
    @AuraEnabled
    public static List<EmailTemplate> loadEmailTemplatesForMail(String templateType, String templateFolder){
        List<EmailTemplate> templateList = new List<EmailTemplate>();
        Id userId = UserInfo.getUserId();
        if(templateType.equalsIgnoreCase('Classic')){
            if(templateFolder == null || templateFolder.equals('')){
                templateList = Database.query('SELECT Id, Name, Description, FolderName, CreatedBy.Name, CreatedDate FROM EmailTemplate WHERE RelatedEntityType = NULL AND UiType = \'ALOHA\'');
            }
            else{
                templateList = Database.query('SELECT Id, Name, Description, FolderName, CreatedBy.Name, CreatedDate FROM EmailTemplate WHERE RelatedEntityType = NULL AND UiType = \'ALOHA\' AND FolderId = :templateFolder');
            }
        }
        else if(userId != null && templateType.equalsIgnoreCase('AllLightning')){
            if(templateFolder == null || templateFolder.equals('')){
                templateList = Database.query('SELECT Id, Name, FolderId, FolderName, CreatedDate, CreatedBy.Name FROM EmailTemplate WHERE CreatedById = :userId AND UiType = \'SFX\'');
            }
            else{
                if(templateFolder.startsWith('005')){
                    templateList = Database.query('SELECT Id, Name, FolderId, FolderName, CreatedDate, CreatedBy.Name FROM EmailTemplate WHERE CreatedById = :userId AND UiType = \'SFX\' AND FolderId = :templateFolder');
                }
                else{
                    templateList = Database.query('SELECT Id, Name, FolderId, FolderName, CreatedDate, CreatedBy.Name FROM EmailTemplate WHERE (CreatedById = :userId OR RelatedEntityType = \'Case\') AND UiType = \'SFX\' AND FolderId = :templateFolder');
                }
            }
        }
        else if(templateType.equalsIgnoreCase('MyLightning')){
            if(templateFolder == null || templateFolder.equals('')){
                templateList = Database.query('SELECT Id, Name, FolderId, FolderName, CreatedDate, CreatedBy.Name FROM EmailTemplate WHERE CreatedById = :userId AND UiType = \'SFX\'');
            }
            else{
                templateList = Database.query('SELECT Id, Name, FolderId, FolderName, CreatedDate, CreatedBy.Name FROM EmailTemplate WHERE CreatedById = :userId AND UiType = \'SFX\' AND FolderId = :templateFolder');
            }
        }
        else if(templateType.equalsIgnoreCase('SampleLightning')){
            if(templateFolder == null || templateFolder.equals('')){
                templateList = Database.query('SELECT Id, Name, FolderId, FolderName, CreatedDate, CreatedBy.Name FROM EmailTemplate WHERE UiType = \'SFX_Sample\'');
            }
            else{
                templateList = Database.query('SELECT Id, Name, FolderId, FolderName, CreatedDate, CreatedBy.Name FROM EmailTemplate WHERE UiType = \'SFX_Sample\' AND FolderId = :templateFolder');
            }
        }
        return templateList;
    }
    
    @AuraEnabled
    public static List<EmailTemplate> addTemplateDataInMail(String templateId){
        return (List<EmailTemplate>)Database.query('SELECT Name, Subject, Body, HtmlValue, Markup FROM EmailTemplate WHERE Id = :templateId');
    }
    
    @AuraEnabled
    public static List<OrgWideEmailAddress> getOrgWideDefaultQueues(){
        return (List<OrgWideEmailAddress>)Database.query('SELECT Id, Address, DisplayName FROM OrgWIdeEmailAddress');
    }
    
    @AuraEnabled
    public static Map<Id, String> getFolderDetailsForTemplates(String templateType){
        Map<Id, String> folderMap = new Map<Id, String>();
        Id userId = UserInfo.getUserId();
        Organization orgRecord = Database.query('SELECT Id FROM Organization');
        if(templateType.equalsIgnoreCase('Classic')){
            folderMap.put(userId, 'My Personal Email Templates');
            folderMap.put(orgRecord.Id, 'Unfiled Public Classic Email Templates');
            List<Folder> folderList = Database.query('SELECT Id, Name FROM Folder WHERE Type = \'Email\' Order By Name ASC');
            if(folderList.size() > 0){
                for(Folder folderRecord : folderList){
                    folderMap.put(folderRecord.Id, folderRecord.Name);
                }
            }
        }
        else{
            folderMap.put(userId, 'Private Email Templates');
            folderMap.put(orgRecord.Id, 'Public Email Templates');
        }
        return folderMap;
    }
    
    @AuraEnabled
    public static Map<String, List<SObject>> getContactLeadUserDetails(String SearchValue){
        Integer count = 10;
        Map<String, List<SObject>> contactLeadUserMap = new Map<String, List<SObject>>();
        
        if(!SearchValue.contains('.')){
            List<String> nameList = SearchValue.split(' ');
            Integer recordCount = 1;
            String contactString = 'SELECT Name, Email FROM Contact WHERE ';
            String leadString = 'SELECT Name, Email FROM Lead WHERE ';
            String userString = 'SELECT Name, Email FROM User WHERE ';
            for(Integer i=0; i<nameList.size(); i++){
                contactString += 'FirstName Like \'%' + nameList[i] + '%\' OR MiddleName LIKE \'%'+nameList[i] +'%\' OR LastName LIKE\'%' + nameList[i] + '%\' OR ';
                leadString += 'FirstName Like \'%' + nameList[i] + '%\' OR MiddleName LIKE \'%'+nameList[i] +'%\' OR LastName LIKE\'%' + nameList[i] + '%\' OR ';
                userString += 'FirstName Like \'%' + nameList[i] + '%\' OR MiddleName LIKE \'%'+nameList[i] +'%\' OR LastName LIKE\'%' + nameList[i] + '%\' OR ';
            }
            contactString = contactString.subString(0, contactString.length()-3);
            List<Contact> contactRecordList = Database.query(contactString);
            List<Contact> contactList = new List<Contact>();
            for(Contact contactRecord : contactRecordList) {
                Integer j=0;
                for(Integer i=0; i<nameList.size();i++) {
                    if(contactRecord.Name.containsIgnoreCase(nameList[i])) {
                        j++;
                    } 
                }
                if(j == nameList.size()) {
                    if(recordCount < 5){
                        contactList.add(contactRecord);
                        recordCount++;
                    }
                }
            }
            count = count - contactList.size();
            contactLeadUserMap.put('Contact', contactList);
            
            leadString = leadString.subString(0, leadString.length()-3);
            List<Lead> leadRecordList = Database.query(leadString);
            List<Lead> leadList = new List<Lead>();
            recordCount = 1;
            for(Lead leadRecord : leadRecordList) {
                Integer j=0;
                for(Integer i=0; i<nameList.size();i++) {
                    if(leadRecord.Name.containsIgnoreCase(nameList[i])) {
                        j++;
                    } 
                }
                if(j == nameList.size()) {
                    if(recordCount< 5){
                        leadList.add(leadRecord);
                        recordCount++;
                    }
                }
            }
            count = count - leadList.size();
            contactLeadUserMap.put('Lead', leadList);
            
            userString = userString.subString(0, userString.length()-3);
            List<User> userRecordList = Database.query(userString);
            List<User> userList = new List<User>();
            recordCount = 1;
            for(User userRecord : userRecordList) {
                Integer j=0;
                for(Integer i=0; i<nameList.size();i++) {
                    if(userRecord.Name.containsIgnoreCase(nameList[i])) {
                        j++;
                    } 
                }
                if(j == nameList.size()) {
                    if(recordCount <= count){
                        userList.add(userRecord);
                        recordCount++;
                    }
                }
            }
            contactLeadUserMap.put('User', userList);
        }
        else{
            SearchValue = SearchValue+'%';
            List<Contact> contactList = Database.query('SELECT Name, Email FROM Contact WHERE Email LIKE :SearchValue LIMIT 4');
            contactLeadUserMap.put('Contact', contactList);
            count = count - contactList.size();
            List<Lead> leadList = Database.query('SELECT Name, Email FROM Lead WHERE Email LIKE :SearchValue LIMIT 4');
            contactLeadUserMap.put('Lead', leadList);
            count = count - leadList.size();
            List<User> userList = Database.query('SELECT Name, Email FROM User WHERE Email LIKE :SearchValue AND Name != \'System\' LIMIT :count');
            contactLeadUserMap.put('User', userList);
        }
        return contactLeadUserMap;
    }
    
    @AuraEnabled
    public static Map<String, String> getRecordRelatedToFields(Map<String, List<String>>objectMap, String caseId){
        Map<String, String> recordMap = new Map<String, String>();
        Set<String> objectKeys = objectMap.keySet();
        List<String> fieldList;
        for(String objectName : objectKeys){
            fieldList = objectMap.get(objectName);
            String fields = fieldList+'';
            fields = fields.replace('(', '');
            fields = fields.replace(')', '');
            if(objectName.equalsIgnoreCase('Account')){
                String query = 'SELECT '+fields+' FROM Account WHERE Id IN (SELECT AccountId FROM Case WHERE Id = :caseId)';
                List<Account> accountRecord = Database.query(query);
                for(String fieldName : fieldList){
                    recordMap.put(objectName+'.'+fieldName, String.valueOf(accountRecord[0].get(fieldName)));
                }
            }
            else if(objectName.equalsIgnoreCase('Case')){
                String query = 'SELECT '+fields+' FROM Case WHERE Id = :caseId';
                List<Case> caseRecord = Database.query(query);
                for(String fieldName : fieldList){
                    recordMap.put(objectName+'.'+fieldName, String.valueOf(caseRecord[0].get(fieldName)));
                }
            }
            else if(objectName.equalsIgnoreCase('Contact')){
                String query = 'SELECT '+fields+' FROM Contact WHERE Id IN (SELECT ContactId FROM Case WHERE Id = :caseId)';
                List<Contact> contactRecord = Database.query(query);
                for(String fieldName : fieldList){
                    recordMap.put(objectName+'.'+fieldName, String.valueOf(contactRecord[0].get(fieldName)));
                }
            }
            else if(objectName.equalsIgnoreCase('User')){
                Id userId = UserInfo.getUserId();
                String query = 'SELECT '+fields+' FROM User WHERE Id = :userId';
                List<User> userRecord = Database.query(query);
                for(String fieldName : fieldList){
                    recordMap.put(objectName+'.'+fieldName, String.valueOf(userRecord[0].get(fieldName)));
                }
            }
        }
        return recordMap;
    }
    
    @AuraEnabled 
    public static User getUserDetails(){
        Set<Id> ids = new Set<Id>();
        ids.add(userInfo.getUserId());
        return new SLT_User().selectUserByUserId(ids);
    }
}
