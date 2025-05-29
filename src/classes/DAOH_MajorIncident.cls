public class DAOH_MajorIncident {

    public static void validateInternalEmailAddresses(List<Major_Incident__c> majorIncidentList) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern patt = null;
        Matcher match = null;
        List<Messaging.SingleEmailMessage> ccSendEmailList = new List<Messaging.SingleEmailMessage>();            
        for(Major_Incident__c majorIncidentRecord : majorIncidentList){
            if(majorIncidentRecord.Internal_Email_Addresses__c != null){
                for(String mail : majorIncidentRecord.Internal_Email_Addresses__c.split(';')){
                    patt = Pattern.compile(emailRegex);
                    match = patt.matcher(mail.trim());
                    if(!match.matches()){
                        majorIncidentRecord.addError('Invalid Email Address Format In Internal Email Addresses');
                    }
                }
            }
        }
    }

    public static void restrictNewMajorIncident(List<Major_Incident__c> majorIncidentList) {
        Set<String> fieldSet = new Set<String>();
        fieldSet.add(CON_CSM.S_IN_PROGRESS);
        fieldSet.add(CON_CSM.S_RESOLVED);
        Map<Id, Major_Incident__c> ongoingRecordMap =new SLT_MajorIncident().selectOnGoingMajorIncident(fieldSet);
        if(ongoingRecordMap != null && ongoingRecordMap.size()>0){
            for(Major_Incident__c majorIncidentRecord : majorIncidentList){
                if(!ongoingRecordMap.containsKey(majorIncidentRecord.Id)){
                    if(majorIncidentRecord.Status__c.equalsIgnoreCase(CON_CSM.S_IN_PROGRESS) || majorIncidentRecord.Status__c.equalsIgnoreCase(CON_CSM.S_RESOLVED)){
                        majorIncidentRecord.addError('New Major Incident can\'t be progressed while other is ongoing');
                    }
                }
            }
        }
    }
    
    public static void sendEmailtoAccountContactUsers(List<Major_Incident__c> newList, Map<Id,Major_Incident__c> oldMap) {
        Set<Id> miId = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<String> emails = new Set<String>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = null;
        Map<Id, Major_Incident__c> majorIncidentMap = new Map<Id, Major_Incident__c>();
        for(Major_Incident__c mi : newList){
            if(oldMap != null){
                if(mi.Status__c != oldMap.get(mi.Id).Status__c && (mi.Status__c == CON_CSM.S_IN_PROGRESS || mi.Status__c == CON_CSM.S_CLOSED)){
                    miId.add(mi.Id);
                    majorIncidentMap.put(mi.id, mi);
                }
            }
        }
        if(!miId.isEmpty()){
            List<MI_AccountRelationship__c> miAR = Database.query('SELECT Id, Accounts_Impacted__c, Major_Incident__c FROM MI_AccountRelationship__c WHERE Major_Incident__c IN :miId');
            for(MI_AccountRelationship__c mia : miAR){
                accIds.add(mia.Accounts_Impacted__c);
                majorIncidentMap.put(mia.Accounts_Impacted__c, majorIncidentMap.get(mia.Major_Incident__c));
            }
            if(!accIds.isEmpty()){
                Id MIStatusETId = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'ET TECH MI Status Template' LIMIT 1].Id;
                List<Contact> conList = new SLT_Contact().getCSMMINContactEmails(accIds);
                for(Contact c : conList){
                    mail = new Messaging.SingleEmailMessage();
                    if(majorIncidentMap.get(c.AccountId).Status__c.equalsIgnoreCase(CON_CSM.S_IN_PROGRESS) || 
                       majorIncidentMap.get(c.AccountId).Status__c.equalsIgnoreCase(CON_CSM.S_CLOSED)){
                           mail.setTemplateID(MIStatusETId);
                           mail.setTargetObjectId(c.id);
                           mail.setWhatId(majorIncidentMap.get(c.AccountId).Id);
                           mail.setSaveAsActivity(false);
                           emailList.add(mail);
                       }
                }
                try{
                    Messaging.sendEmail(emailList, false);
                }
                catch(Exception ex){
                    ex.getMessage();
                }
            }
        }
    }
    
	public static void SetReportSentDateTime(List<Major_Incident__c> newList, Map<Id,Major_Incident__c> oldMap){
        for(Major_Incident__c mi : newList){
            if(mi.Report_Sent__c == true && (Trigger.isInsert || (Trigger.isUpdate && oldMap != null && mi.Report_Sent__c != oldMap.get(mi.Id).Report_Sent__c))){
                mi.Report_Sent_Date_Time__c = datetime.now();
            }else if( oldMap != null && mi.Report_Sent__c != oldMap.get(mi.Id).Report_Sent__c  && !mi.Report_Sent__c){
                mi.addError('Report Sent check box can not be unchecked if it is checked once.');
            }
        } 
    }
}
