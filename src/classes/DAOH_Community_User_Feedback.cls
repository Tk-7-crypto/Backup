public without sharing class DAOH_Community_User_Feedback {
    public static void feedbackAlert(List<Community_User_Feedback__c> comUserFeedBackList){
        Set<String> articleNo = new Set<String>();
        List<String> emailList = new List<String>();
        Map<String,String> mapEmailToId = new Map<String,String>();
        for(Community_User_Feedback__c comUserFeedBackObj : comUserFeedBackList){
            if(String.isNotBlank(comUserFeedBackObj.ArticleNumber__c)){
                articleNo.add(comUserFeedBackObj.ArticleNumber__c); 
            }
        }
        for(Knowledge__VersionHistory knowlegeVersionObj : [SELECT CreatedBy.Name, parent.CreatedBy.Email, CreatedDate,CreatedBy.Email,VersionId,EventType  FROM Knowledge__VersionHistory WHERE VersionId != null AND Parent.ArticleNumber IN :articleNo AND EventType IN('KavPublished','created','KavPublishedNew')]) {
            if(knowlegeVersionObj.parent.CreatedBy.Email != null){
                if(!emailList.contains(knowlegeVersionObj.parent.CreatedBy.Email)){
                    emailList.add(knowlegeVersionObj.parent.CreatedBy.Email); 
                    mapEmailToId.put(knowlegeVersionObj.parent.CreatedBy.Email,knowlegeVersionObj.VersionId);
                    
                } 
            }
            
            if(knowlegeVersionObj.CreatedBy.Email != null){
                if(!emailList.contains(knowlegeVersionObj.CreatedBy.Email)){
                    emailList.add(knowlegeVersionObj.CreatedBy.Email); 
                    mapEmailToId.put(knowlegeVersionObj.CreatedBy.Email,knowlegeVersionObj.VersionId);
                }
                
            }
            
            
        } 
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templateList = Database.query('SELECT id,HtmlValue,Body FROM EmailTemplate WHERE Name=\'ET TECH EN New KB Feedback\' LIMIT 1');
        for(String emailAddObj : emailList){ 
            if(templateList != null && !templateList.isEmpty() && mapEmailToId.containsKey(emailAddObj)){
                Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templateList[0].id,UserInfo.getUserId(),mapEmailToId.get(emailAddObj));
                message.toAddresses = new String[] {emailAddObj};
                message.setTemplateId(templateList[0].id);
                message.setTargetObjectId(UserInfo.getUserId());
                message.setTreatTargetObjectAsRecipient(false);
                message.setSaveAsActivity(False);
                emailMessageList.add(message);    
            }
        }
        
        try{
            if(emailMessageList.size()>0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessageList); 
                for(Messaging.SendEmailResult result : results){
                    if(result.isSuccess()){
                       system.debug('Mail Sent succesfully');  
                    }
                    else {
                        system.debug('Error in sending Email' +result.getErrors());
                    }
                }
            }
            
        }
        catch(Exception e){
            System.debug('Mail Exception: '+e.getMessage());
        }
        
        
    }
    
}