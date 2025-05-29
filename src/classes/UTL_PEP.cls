public class UTL_PEP  {
    public static void sendMail(String contractId,String developerName,String[] toAddresses,String[] toCC) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Contract con=[SELECT ID FROM CONTRACT WHERE ID =:contractId];
        List<OrgWideEmailAddress> owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address ='no.reply.support@iqvia.com' LIMIT 1];
        List<EmailTemplate> tempId = [SELECT Id,Subject,HtmlValue, Body FROM EmailTemplate WHERE developername=: developerName];
        email.setToAddresses(toAddresses);
        email.setCcAddresses(toCC);
        email.setTemplateId(tempId[0].Id);
        email.setTreatTargetObjectAsRecipient(false);
        email.setTargetObjectId(c.Id);
        email.setWhatId(con.Id);
        email.setSaveAsActivity(false);
        email.setOrgWideEmailAddressId(owa[0].id);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {email};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
}