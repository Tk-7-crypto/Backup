public class BCH_CSM_SendEmailRnDKBAccountMgmt implements Database.Batchable<sObject>{
    set<Id> userIds;
    String htmlBody;
    public BCH_CSM_SendEmailRnDKBAccountMgmt(){
        userIds = new set<Id>();
        htmlBody = '<table style="border-collapse: collapse;border: 0.1px solid black;"> <tr> <th style="border: 1px solid black;">Article Number</th> <th style="border: 1px solid black;">Article Title</th> <th style="border: 1px solid black;">LOS</th> <th style="border: 1px solid black;">Version Number</th> <th style="border: 1px solid black;">Last Published Date</th> </tr> <tbody>';
        List<Queue_User_Relationship__c> userLit = Database.query('select Id,Name, User__c,User_Email__c FROM Queue_User_Relationship__c where Name like \'Rnd%Account Management%\' and Type__c =\'User\' and User__r.IsActive =true');
        for (Queue_User_Relationship__c q : userLit) {
            userIds.add(q.User__c);
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'select Id,ArticleNumber,Title, ProductName__c, VersionNumber,LastPublishedDate from Knowledge__kav where PublishStatus =\'Online\' and Pillar__c =\'R&D\' and ProductName__c =\'Account Management\'';
        if(!Test.isRunningTest())
            query +=' and LastPublishedDate = YESTERDAY';
        else
            query +=' and LastPublishedDate = TODAY';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Knowledge__kav> kbList){
        Integer count = 0;
        if(kbList != null && !kbList.isEmpty()){
            for(Knowledge__kav k : kbList){
                htmlBody = htmlBody +'<td style="border: 1px solid black;">'+k.ArticleNumber+'</td><td style="border: 1px solid black;"><a href="'+URL.getOrgDomainUrl().toExternalForm()+'/lightning/r/Knowledge__kav/'+k.Id+'/view">'+k.Title+'</a></td><td style="border: 1px solid black;">'+k.ProductName__c+'</td><td style="border: 1px solid black;">'+k.VersionNumber+'</td><td style="border: 1px solid black;">'+k.LastPublishedDate+'</td></tr>';
            }
            htmlBody+='</table>';
            EmailTemplate template=[SELECT HtmlValue,Body FROM EmailTemplate WHERE DeveloperName='ET_CSM_RnD_KBArticleAccountMgmtUser'];
            List<OrgWideEmailAddress> owa = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress('no.reply.support@iqvia.com',new Set<String>{'ID'});
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = null;
            if(!userIds.isEmpty())
            {
                String  hbody = template.HtmlValue;
                hbody = hbody.replace('<<--table-->>',htmlBody);
                for(Id e : userIds){
                    email = new Messaging.SingleEmailMessage();
                    email.setReplyTo('no.reply.support@iqvia.com');
                    email.setOrgWideEmailAddressId(owa[0].id);
                    email.setTargetObjectId(e);
                    email.setHtmlBody(hbody);
                    email.setSaveAsActivity(false);
                    email.setSubject('A new KB article or an update has been published for your LOS. Please be sure to familiarize yourself with the new/updated article.');
                    messages.add(email);    
                }
                System.debug('inside loop : ' + messages);
                if(!messages.isEmpty()) Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
            
            
        }
        
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }

}