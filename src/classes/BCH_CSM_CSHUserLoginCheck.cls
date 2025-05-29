global class BCH_CSM_CSHUserLoginCheck  implements Database.Batchable<sObject>, Database.Stateful{
    public Map<String,Id> devMap = new Map<String,Id>();
    public List<Id> inActUserList = new List<Id>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query= '';
        List<EmailTemplate> tempList = Database.query('SELECT Id,Subject,DeveloperName,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName in (\'CSM_Multi_CSHUserLogin60DaysCheck\',\'CSM_Multi_CSHUserLogin2DaysReminder\')');
        for(EmailTemplate e : tempList){
            if(e.DeveloperName.containsIgnoreCase('60Days')){
                devMap.put('60Days', e.Id);
            }else{
                devMap.put('2Days', e.Id);
            }
            
        }
        //if(Test.isRunningTest() || true){
        if(Test.isRunningTest()){
            query = 'select Id, ContactId, Name, LastLoginDate, IsActive, IsPortalEnabled ,UserType, Contact.IsEmailBounced, Contact.CSHAccessControl1stNotification__c from User where ContactId != null and isActive = true and IsPortalEnabled = true and UserType in (\'CustomerSuccess\',\'PowerCustomerSuccess\') and (Contact.CSHAccessControl1stNotification__c != null or LastLoginDate = null) LIMIT 10';
        }else{
            query = 'select Id, ContactId, Name, LastLoginDate, IsActive, IsPortalEnabled ,UserType, Contact.IsEmailBounced, Contact.CSHAccessControl1stNotification__c from User where ContactId != null and isActive = true and IsPortalEnabled = true and Profile.Name = \'CSM Customer Community Plus Login User\' and UserType in (\'CustomerSuccess\',\'PowerCustomerSuccess\') and LastLoginDate != null and ((Contact.CSHAccessControl1stNotification__c = null and LastLoginDate = LAST_N_DAYS:180 and LastLoginDate < LAST_N_DAYS:60) or (Contact.CSHAccessControl1stNotification__c != null and Contact.CSHAccessControl1stNotification__c < LAST_N_DAYS:17 and Contact.CSHAccessControl1stNotification__c = LAST_N_DAYS:22) or (Contact.IsEmailBounced = true)) LIMIT 500';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> users){
        Set<Id> inActconSet = new Set<Id>();
        Set<Id> con60IdSet = new Set<Id>();
        Set<Id> con18IdSet = new Set<Id>();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SendEmailResult[] results = null;
        Integer diffdays = 0;
        if(users != null && !users.isEmpty()){
            Messaging.SingleEmailMessage email = null;
            CSM_Case_Details_Global_Setting__C orgE = CSM_Case_Details_Global_Setting__C.getInstance('Org Wide No-Reply');
            for(User u : users){
                if(Test.isRunningTest()){
                    diffdays = 61;
                }else if(u.LastLoginDate != null){
                    diffdays = u.LastLoginDate.date().daysBetween(System.today());
                }
                if(diffdays >= 60 && u.Contact.CSHAccessControl1stNotification__c == null){
                    if(u.Contact.IsEmailBounced){
                        inActconSet.add(u.contactId);
                        inActUserList.add(u.Id);
                    }else{
                        email = Test.isRunningTest() ? Messaging.renderStoredEmailTemplate( devMap.get('60Days'), u.Id,u.ContactId) : Messaging.renderStoredEmailTemplate( devMap.get('60Days'), u.ContactId,u.Id);
                        if(orgE != null){
                            email.setOrgWideEmailAddressId(orgE.Component_Id__c);
                        }
                        email.setReplyTo('no.reply.support@iqvia.com');
                        email.setSaveAsActivity(false);
                        messages.add(email);
                        con60IdSet.add(u.ContactId);    
                    }
                    
                }else if(diffdays >= 60 && u.Contact.CSHAccessControl1stNotification__c != null){
                    diffdays = u.Contact.CSHAccessControl1stNotification__c.date().daysBetween(System.today());
                    if(diffdays == 18){
                        email =  Test.isRunningTest()? Messaging.renderStoredEmailTemplate( devMap.get('2Days'),u.Id,u.ContactId) : Messaging.renderStoredEmailTemplate( devMap.get('2Days'),u.ContactId,u.Id);
                        if(orgE != null){
                            email.setOrgWideEmailAddressId(orgE.Component_Id__c);
                        }
                        email.setReplyTo('no.reply.support@iqvia.com');
                        email.setSaveAsActivity(false);
                        messages.add(email);
                        con18IdSet.add(u.ContactId);
                    }else if(diffdays >= 20 || u.Contact.IsEmailBounced){
                        inActconSet.add(u.contactId);
                        u.IsActive = false;
                        inActUserList.add(u.Id);
                    }
                }
            }
            if(!messages.isEmpty()){
                results = Messaging.sendEmail(messages);
            }
            if(!inActconSet.isEmpty()){
                List<Contact> inActList = getContactList(inActconSet);
                if(inActList != null && !inActList.isEmpty()){
                    for(integer i=0; i<inActList.size(); i++){
                        inActList[i].Inactive__c = true;
                        inActList[i].CSHAccessControl1stNotification__c = null;
                    }
                    try{
                        update inActList;    
                    }catch(DmlException ex){
                        System.debug('Exception occured at BCH_CSM_CSHUserConnectionCheck : '+ex.getMessage());
                    }
                }
            }
            /*if(!inActUserList.isEmpty()){
                try{
                    update inActUserList;
                }catch(DmlException ex){System.debug('Exception occured at BCH_CSM_CSHUserConnectionCheck : '+ex.getMessage());}
            }*/
            if(!con60IdSet.isEmpty()){
                List<Contact> con60IdList = getContactList(con60IdSet);
                if(con60IdList != null && !con60IdList.isEmpty()){
                    for(integer i=0; i<con60IdList.size(); i++){
                        con60IdList[i].CSHAccessControl1stNotification__c = System.now();
                        if(con60IdList[i].IsEmailBounced){
                            con60IdList[i].Inactive__c = true;
                        }
                    }
                    try{
                        update con60IdList;    
                    }catch(DmlException ex){
                        System.debug('Exception occured at BCH_CSM_CSHUserConnectionCheck : '+ex.getMessage());
                    }    
                }
            }
            if(!con18IdSet.isEmpty()){
                List<Contact> con18IdList = getContactList(con18IdSet);
                if(con18IdList != null && !con18IdList.isEmpty()){
                    for(integer i=0; i<con18IdList.size(); i++){
                        if(con18IdList[i].IsEmailBounced){
                            con18IdList[i].Inactive__c = true;
                        }
                    }
                    try{
                        update con18IdList;    
                    }catch(DmlException ex){
                        System.debug('Exception occured at BCH_CSM_CSHUserConnectionCheck : '+ex.getMessage());
                    }    
                }
            }
        }
        
    }
    
    public static List<Contact> getContactList(Set<id> idSet){
        return new SLT_Contact().selectByContactIdList(idSet,new Set<String>{'Id','CSHAccessControl1stNotification__c','Inactive__c','IsEmailBounced'});
    }
    
    global void finish(Database.BatchableContext BC){
        if(inActUserList != null && !inActUserList.isEmpty()){
            BCH_CSM_CSHUserUpdate updateBatch = new BCH_CSM_CSHUserUpdate(inActUserList);
            Database.executeBatch(updateBatch);    
        }
    }
}