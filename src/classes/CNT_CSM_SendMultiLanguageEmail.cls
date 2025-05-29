public class CNT_CSM_SendMultiLanguageEmail {
    @InvocableMethod 
    public static void sendMultiLanguageEmailNotification(List<Id> caseIds){
        Case case1 = getCase(caseIds[0]);
        Contact contact = getContact(case1.ContactId);
        Multi_Language_Email_Templates__c cs = Multi_Language_Email_Templates__c.getValues(contact.PreferredLanguage__c);
        if(cs != null){
            getEmailTemplate(cs.Template_Id__c);   
        }
        
        
    }
    
    @future
    private static void getEmailTemplate(id templateID){
        EmailTemplate  emailLanguageSpecific ;
        try{
            if(templateID !=null){
                emailLanguageSpecific  = [Select id,HtmlValue  from EmailTemplate  where id =:templateID];
            }
            EmailTemplate  emailCommon = [Select id,HtmlValue  from EmailTemplate  where name ='ET TECH EN Case Pending Resolution for 2 Days'];
            if(emailLanguageSpecific !=null  &&  emailLanguageSpecific.HtmlValue != emailCommon.HtmlValue){
                emailCommon.HtmlValue = emailLanguageSpecific.HtmlValue;
                update emailCommon; 
            }
        }
        catch(System.QueryException ex){
            
        }
        
    }
    
    private static Contact getContact(Id contactId){
        return [SELECT Id, PreferredLanguage__c, Email FROM Contact WHERE Id = :contactId];
    }
    
    private static Case getCase(Id caseId){
        return [SELECT Id, ContactId FROM Case WHERE Id = :caseId];
    }
}