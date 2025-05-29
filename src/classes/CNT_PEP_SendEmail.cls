public class CNT_PEP_SendEmail {
    @AuraEnabled
    public static void sendAnnouncementMail(String announcementId){
        List<CSM_QI_Announcement__c> ann = new SLT_Announcements().selectAnnouncementById(announcementId);        
        String developerName ='Ann_ET02_PRM_SendAnnouncementEmail';
        Set<String> fieldSet = new Set<String>{'Id','Subject','HtmlValue','Body'};
        List<EmailTemplate> tempId = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(developerName,fieldSet);
        Set<Id> conId = new Set<Id>();
        List<String> usEmails = new List<String>();
        List<String> usIds = new List<String>();
        
        if(ann.size() > 0){
            Boolean isActive = ann[0].PRM_Active_Contract_Only__c;
            String partnerType = ann[0].Partner_Type__c;
            System.debug('Partner Type Before : : ' + partnerType);
            partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
            String pillar = ann[0].Pillar__c;
            pillar = '\'' + pillar.replace(';','\',\'') +'\'';
            
            List<CSM_QI_Announcement_Product_Relationship__c> cpr = new SLT_Announcements().selectAnnouncementByProduct(announcementId);
            System.debug('cpr size : ' + cpr);
            List<Contact> conList = new List<Contact>();
            if(cpr.size() > 0)
            {
                Set<Id> prodId = new Set<Id>();
                for(CSM_QI_Announcement_Product_Relationship__c cp : cpr)
                {
                    prodId.add(cp.Product__c);
                }
                
                List<Asset> asList = new SLT_Asset().selectAssetByProductId(prodId);
                System.debug('asset list : ' + asList);
                Set<String> assetNameSet = new Set<String>();
                Set<Id> accId = new Set<Id>();
                for(Asset ast : asList)
                {
                    accId.add(ast.AccountId);
                    assetNameSet.add(ast.Name);
                }
                if(isActive){
                    List<Contract> contList = new SLT_Contract().getContractByAssetName(accId,assetNameSet);
                    System.debug('Contract list : ' + contList);
                    Set<Id> accIds = new Set<Id>();
                    for(Contract cont : contList)
                    {
                        accIds.add(cont.AccountId);
                	}
                    conList = new SLT_Contact().selectContactsforEmail(partnerType,pillar,accIds);
                }else{
                    conList = new SLT_Contact().selectContactsforEmail(partnerType,pillar,accId);
                }    
                System.debug('Contact list : ' + conList);
            }
            else{                
                conList = new SLT_Contact().selectAllContactsforEmail(partnerType,pillar);
            }
            for(Contact con: conList)
            {
                conId.add(con.Id);
            }
            System.debug('conId : ' + conId);          
            Set<String> contactFields = new Set<String>{'ID','Email'};
            List<User> usList = new SLT_User().selectByContactId(conId,contactFields);           
            List<OrgWideEmailAddress> owa = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress('no.reply.support@iqvia.com',new Set<String>{'ID'});
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            for(User us: usList)
            {
                usEmails.add(us.Email);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //email.setToAddresses(usEmails);
                //email.setCcAddresses(new String[]{'rachit.nagar96@yopmail.com'});
                email.setTemplateId(tempId[0].Id);
                email.setTreatTargetObjectAsRecipient(true);
                email.setTargetObjectId(us.Id);
                email.setWhatId(ann[0].Id);
                email.setSaveAsActivity(false);
                email.setOrgWideEmailAddressId(owa[0].id);
                messages.add(email);
                System.debug('inside loop : ' + messages);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            System.debug('Results : ' + results);
            if(results.size() > 0)
            {
                if (results[0].success) {
                    Messaging.SingleEmailMessage emailToPSO = new Messaging.SingleEmailMessage();
                    emailToPSO.setToAddresses(new List<String>{'agency@iqvia.com'});
                    emailToPSO.setTemplateId(tempId[0].Id);
                    emailToPSO.setTreatTargetObjectAsRecipient(false);
                    emailToPSO.setTargetObjectId(usList[0].Id);
                    emailToPSO.setWhatId(ann[0].Id);
                    emailToPSO.setSaveAsActivity(false);
                    emailToPSO.setOrgWideEmailAddressId(owa[0].id);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToPSO});
                    ann[0].Email_Sent__c = true;
                    update ann[0];
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }
    }
    
    @AuraEnabled
    public static List<CSM_QI_Announcement__c> getAnnouncementDetails(String announcementId){
        List<CSM_QI_Announcement__c> ann = new SLT_Announcements().selectAnnouncementById(announcementId);
        return ann;
    }
    
    @AuraEnabled
    public static void sendAnnouncementMailForCSM(String announcementId){
        List<CSM_QI_Announcement__c> ann = new SLT_Announcements().selectAnnouncementById(announcementId);        
        String developerName ='Ann_ET01_CSM_SendAnnouncementEmail';
        Set<String> fieldSet = new Set<String>{'Id','Subject','HtmlValue','Body'};
        List<EmailTemplate> tempId = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(developerName,fieldSet);
        Set<Id> conId = new Set<Id>();
        List<String> usEmails = new List<String>();
        List<String> usIds = new List<String>();
        
        if(ann.size() > 0){
            String userType = ann[0].Contact_User_Type__c;
            userType = '\'' + userType.replace(';','\',\'') +'\'';
            String pillar = ann[0].Pillar__c;
            pillar = '\'' + pillar.replace(';','\',\'') +'\'';
            
            List<CSM_QI_Announcement_Product_Relationship__c> cpr = new SLT_Announcements().selectAnnouncementByProduct(announcementId);
            System.debug('cpr size : ' + cpr);
            List<Contact> conList = new List<Contact>();
            if(cpr.size() > 0)
            {
                Set<Id> prodId = new Set<Id>();
                for(CSM_QI_Announcement_Product_Relationship__c cp : cpr)
                {
                    prodId.add(cp.Product__c);
                }
                
                List<Asset> asList = new SLT_Asset().selectAssetByProductId(prodId);
                System.debug('asset list : ' + asList);
                Set<Id> accId = new Set<Id>();
                for(Asset ast : asList)
                {
                    accId.add(ast.AccountId);
                }
                                
                conList = new SLT_Contact().selectContactsforEmailCSM(userType,pillar,accId);
                System.debug('Contact list : ' + conList);
            }
            else{                
                conList = new SLT_Contact().selectAllContactsforEmailCSM(userType,pillar);
            }
            for(Contact con: conList)
            {
                conId.add(con.Id);
            }
            System.debug('conId : ' + conId);          
            Set<String> contactFields = new Set<String>{'ID','Email'};
            List<User> usList = new SLT_User().selectByContactId(conId,contactFields);           
            List<OrgWideEmailAddress> owa = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress('no.reply.support@iqvia.com',new Set<String>{'ID'});
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            for(User us: usList)
            {
                usEmails.add(us.Email);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(tempId[0].Id);
                email.setTreatTargetObjectAsRecipient(true);
                email.setTargetObjectId(us.Id);
                email.setWhatId(ann[0].Id);
                email.setSaveAsActivity(false);
                email.setOrgWideEmailAddressId(owa[0].id);
                messages.add(email);
                System.debug('inside loop : ' + messages);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            System.debug('Results : ' + results);
            if(results.size() > 0)
            {
                if (results[0].success) {
                    ann[0].Email_Sent_for_CSM__c = true;
                    update ann[0];
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }
        
    }
}
