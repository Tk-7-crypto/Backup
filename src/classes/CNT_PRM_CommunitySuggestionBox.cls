public class CNT_PRM_CommunitySuggestionBox {
    
    @AuraEnabled
    public static void sendSuggetionEmail(String subject, String body){
        try {
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no.reply.support@iqvia.com'];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(new List<String>{getRecieverEmailAddress()});
            message.setSubject(subject);
            message.setHtmlBody(body);
            if(owea.size() > 0)
            	message.setOrgWideEmailAddressId(owea.get(0).Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getRecieverEmailAddress(){
        return PRM_BaseUrl__c.getOrgDefaults().Suggestion_Receiver_Email__c;
    }
}