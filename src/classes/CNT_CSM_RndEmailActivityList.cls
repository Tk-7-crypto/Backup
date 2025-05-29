public class CNT_CSM_RndEmailActivityList {

    @AuraEnabled
    public static List<EmailActivityWrapper> getEmailActivityList(String caseId){
        Map<Id,EmailActivityWrapper> eaMap = new Map<Id,EmailActivityWrapper>();
        EmailActivityWrapper ea = null;
        List<Activity__c> actList = new SLT_ActivityC().selectByEmailActivityCaseId(new Set<Id>{caseId});
        if(actList != null && !actList.isEmpty()){
            for(Activity__c a : actList){
                if(a.EmailMessageId__c != null){
                    ea = new EmailActivityWrapper();
                    ea.emailId = a.EmailMessageId__c;
                    ea.caseId = caseId;
                    ea.name = a.Name;
                    ea.activityId = a.Id;
                    ea.actType = a.Type__c;
                    ea.emailCategorization = a.Email_Categorization__c;
                    ea.astatus = a.Status__c;
                    ea.activityUrl = system.URL.getOrgDomainUrl().toExternalForm()+'/lightning/r/Activity__c/'+a.Id+'/view';
                    eaMap.put(ea.emailId,ea);    
                }
            }
            Set<Id> emIds = eaMap.keySet();
            if(emIds != null){
                List<EmailMessage> emailList = Database.query('select Id,FromAddress,ToAddress,Subject,MessageDate,toLabel(Status) Status from EmailMessage where ParentId != null and ParentId = :caseId and Id in :emIds');
                if(emailList != null && !emailList.isEmpty()){
                    for(EmailMessage e : emailList){
                        if(eaMap.containsKey(e.Id)){
                            EmailActivityWrapper eaw = eaMap.get(e.Id);
                            eaw.subject = e.Subject;
                            eaw.fromAddress = e.FromAddress;
                            eaw.toAddress = e.ToAddress;
                            eaw.messageDate = e.MessageDate;
                            eaw.estatus = e.Status;
                            eaw.emailUrl = system.URL.getOrgDomainUrl().toExternalForm()+'/lightning/r/EmailMessage/'+e.Id+'/view';
                        }
                    }
                }
            }
        }
        return eaMap.values();
    }
    
    @AuraEnabled
    public static List<string> getEmailCategorizationList(String fieldName){
        List<String> options =  new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Activity__c').getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.picklistEntry f:ple)
        {
            options.add(f.getValue());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<EmailActivityWrapper> updateEmailActivityWrapperList(List<EmailActivityWrapper> emailActivityList){
        String caseId = null;
        Map<Id,EmailActivityWrapper> actidMap = new Map<Id,EmailActivityWrapper>();
        if(emailActivityList != null && !emailActivityList.isEmpty()){
            for(EmailActivityWrapper w: emailActivityList){
                if(w.activityId != null){
                    actidMap.put(w.activityId,w);
                    if(caseId == null){
                        caseId = w.caseId;
                    }
                }
            }
            if(!actidMap.isEmpty()){
                Set<Id> idSet = actidMap.keySet();
                if(idSet != null){
                    List<Activity__c> actList = Database.query('Select Id,Email_Categorization__c,Status__c From Activity__c  where Id in :idSet');
                    if(actList != null && !actList.isEmpty()){
                        for(Activity__c a : actList){
                            if(actidMap.containsKey(a.Id)){
                                a.Email_Categorization__c = actidMap.get(a.Id).emailCategorization;
                                a.Status__c = actidMap.get(a.Id).astatus;
                            }
                        }
                        update actList;
                    }
                }
                
            }
        }
        
        return getEmailActivityList(caseId);
    }
    
    public Class EmailActivityWrapper{
        @AuraEnabled
        public String emailUrl{ get; set;}
        @AuraEnabled
        public String activityUrl{ get; set;}
        @AuraEnabled
        public String subject{ get; set;}
        @AuraEnabled
        public String fromAddress{ get; set;}
        @AuraEnabled
        public String toAddress{ get; set;}
        @AuraEnabled
        public Datetime messageDate{ get; set;}
        @AuraEnabled
        public String estatus{ get; set;}
        @AuraEnabled
        public String emailId{ get; set;}
        @AuraEnabled
        public String activityId{ get; set;}
        @AuraEnabled
        public String name{ get; set;}
        @AuraEnabled
        public String actType{ get; set;}
        @AuraEnabled
        public String emailCategorization{ get; set;}
        @AuraEnabled
        public String astatus{ get; set;}
        @AuraEnabled
        public String caseId{ get; set;}
    }
}
