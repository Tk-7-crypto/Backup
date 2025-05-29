global class BCH_CSM_SendReminderForApproval implements Database.Batchable<sObject>{
    global String[] errors = new List<String>();
    private String templateName;
    private String fromEmailAddress;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date last20Days = Date.today().addDays(-20);
        String query = 'SELECT Id, CaseNumber, Customer_Requested_Date__c, toLabel(OneKey_Country__c) FROM Case WHERE RecordTypeName__c = \'HCP_Onekey_Request\' AND Status = \'Request for Approval\' AND Customer_Requested_Date__c <= : last20Days ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        List<String> toAddresses = getEmailAddresses(); 
        if(!toAddresses.isEmpty()) {
            sendMail(caseList, toAddresses);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    @testVisible
    private List<String> getEmailAddresses(){
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
        CSM_Onekey_Email__c csmOnekeyEmail = CSM_Onekey_Email__c.getOrgDefaults();
        if(csmOnekeyEmail != null) {
            templateName = csmOnekeyEmail.Template_Name__c;
            fromEmailAddress = csmOnekeyEmail.From_Email_Address__c;
            if(csmOnekeyEmail.Public_Group_Name__c != null && csmOnekeyEmail.Public_Group_Name__c != '') {
                List<Group> grpList = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: csmOnekeyEmail.Public_Group_Name__c];
                for(Group grp : grpList){
                    for(GroupMember grpMember : grp.GroupMembers){
                        idList.add(grpMember.UserOrGroupId);
                    }
                }
                if(idList != null && idList.size() > 0) {
                    List<User> userList = [SELECT Email FROM User WHERE Id IN :idList and IsActive = true];
                    for(User u : userList) {
                        mailToAddresses.add(u.email);
                    } 
                }
            }
        }
        return mailToAddresses;
    }
    
    @TestVisible
    private void sendMail(List<Case> caseList, List<String> toAddresses) {
        OrgWideEmailAddress orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: fromEmailAddress LIMIT 1];
        EmailTemplate template = [SELECT Id, Name, Body, HtmlValue, Subject FROM EmailTemplate WHERE Name =: templateName LIMIT 1];        
        
        if(orgWideAddress != null && template != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            
            String tableBody = '<table style="font-family:Verdana,Arial;font-size:12px; border: 1px solid black; border-collapse: collapse" ><thead><tr><th style="border: 1px solid black;padding: 2px 4px;">Case Number</th><th style="border: 1px solid black;padding: 2px 4px;">Customer Requested Date</th><th style="border: 1px solid black;padding: 2px 4px;">Country </th></tr></thead><tbody>';
            for(Case caseRecord: caseList) {
                String recordURL = URL.getOrgDomainUrl().toExternalForm() + '/' + caseRecord.Id; 
                tableBody += '<tr><td style="border: 1px solid black;padding: 2px 4px;">' + '<a href='+recordURL+'>'+caseRecord.CaseNumber+'</a>' + '</td><td style="border: 1px solid black;padding: 2px 4px;">' + datetime.newInstance(caseRecord.Customer_Requested_Date__c, Time.newInstance(0,0,0,0)).format('MMMM d yyyy') + '</td><td style="border: 1px solid black;padding: 2px 4px;">' + caseRecord.OneKey_Country__c +'</td></tr>';
            }
            tableBody += '</tbody></table>';
            String htmlBody = template.HtmlValue.replace('TABLE_CONTENT', tableBody);
            
            mail.setSubject(template.Subject);
            mail.setHtmlBody(htmlBody);
            mail.setOrgWideEmailAddressId(orgWideAddress.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}