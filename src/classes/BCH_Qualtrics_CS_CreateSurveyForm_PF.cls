global class BCH_Qualtrics_CS_CreateSurveyForm_PF {
    
    public BCH_Qualtrics_CS_CreateSurveyForm_PF(){
    }
    
    /*implements Database.Batchable<Proxy_Project__c>{
    global Iterable<Proxy_Project__c> start(Database.BatchableContext info){
        checkInactiveApprovers();
        
        Date Date6Back = Date.today().addMonths(-6);
        Integer currMon = Date.today().Month();
        Integer currDay = Date.today().Day();
        Integer currYear = Date.today().year();
        date Date6more = DAte.today().addMonths(6);
        
        Integer day1Back = Date.today().addDays(-1).Day();
        Integer mon1Back = Date.today().addDays(-1).Month();
        date Date6more1Back = DAte.today().addMonths(6).addDays(-1);
        
        Integer day2Back = Date.today().addDays(-2).Day();
        Integer mon2Back = Date.today().addDays(-2).Month();
        date Date6more2Back = DAte.today().addMonths(6).addDays(-2);
        
        Integer day3Back = Date.today().addDays(-3).Day();
        Integer mon3Back = Date.today().addDays(-3).Month();
        date Date6more3Back = DAte.today().addMonths(6).addDays(-3);
        
        Date REF_DATE = Date.NewInstance(2013, 12, 16);
        
        List<Proxy_Project__c> pList = new List<Proxy_Project__c>();
        CS_Config__c csConfigSetting = CS_Config__c.getInstance();
        String batchCondition = csConfigSetting.Batch_Condition__c;
        if(batchCondition == null){
            batchCondition = '';
        }
        String query = 'SELECT id, Opportunity__c, Opportunity__r.name, Project_Start_Date__c, '+
            +'Opportunity__r.ownerId, Opportunity__r.Principle_inCharge__c, Opportunity__r.Principle_inCharge__r.Country__c, '+
            +'Delivery_PIC_Email__c,'+
            +'Opportunity__r.Survey_Recipient__c, Opportunity__r.Survey_Recipient_2__c, '+
            +'Opportunity__r.Survey_Recipient_3__c, Project_End_Date__c, Opportunity__r.BidTeam_2__r.Salesforce_User__r.Name, '+
            +'Master_Project__c, Opportunity__r.StageName,Delivery_PIC_User_Country__c, Delivery_PIC_EmployeeNumber__c, '+
            +'Opportunity__r.Principle_inCharge__r.Salesforce_User__r.Name,Delivery_PIC_Name__c, '+
            +'Opportunity__r.Amount_In_USD__c, Project_Manager_name__c, Project_Manager_Email__c, Project_Manager_EmployeeNumber__c '+
            +'FROM Proxy_Project__c WHERE ( opportunity__r.stagename in (\'In-Hand\',\'7a. Closed Won\') '+
            +'and Record_Type_Name__c =\'Engagement\' and opportunity__r.Is_Survey_Eligible__c = true '+
            +'and opportunity__r.Survey_Recipient__c != null and (DaysTotal__c > 365) and Project_End_Date__c <= TODAY and calendar_year(Project_Start_Date__c )< 2019) '+batchCondition;
        Map<Id, Proxy_Project__c> pMap = new Map<Id, Proxy_Project__c>((List<Proxy_Project__c>)Database.query(query));
        List<Proxy_Project__c> retList = new List<Proxy_Project__c>();
        if(!pMap.isEmpty()){
            pList = [SELECT Master_Project__c FROM Proxy_Project__c 
                     WHERE Record_Type_Name__c =: CON_Qualtrics.RECORD_TYPE_PROJECT 
                     AND Master_Project__c in :pMap.keySet()];
            Set<id> engIdSet = new Set<id>();
            for(Proxy_Project__c p1 : pList) {
                engIdSet.add(p1.Master_Project__c);
            }
            for(Proxy_Project__c p : pMap.values()){
                if(engIdSet.contains(p.id)) retList.add(p);
            }
        }
        return retList;
    }
    
    global void execute(Database.BatchableContext info, List<Proxy_Project__c> scope){
        List<Client_Sat_Survey__c> csList = new List<Client_Sat_Survey__c>();
        for(Proxy_Project__c p : scope) {
            Client_Sat_Survey__c cs = new Client_Sat_Survey__c();
            cs.Opp_Engagement__c = p.Opportunity__r.name;
            cs.Opp_Engagement_start_date__c = p.Project_Start_Date__c;
            cs.Opportunity__c = p.Opportunity__c;
            cs.Opportunity_Owner__c = p.Opportunity__r.ownerId;
            cs.PIC_Country__c = (p.Delivery_PIC_User_Country__c != null)?p.Delivery_PIC_User_Country__c : p.Opportunity__r.Principle_inCharge__r.Country__c;
            cs.Send_Survey__c = null;
            cs.Survey_EM_Name__c = (p.Project_Manager_name__c != null) ? p.Project_Manager_name__c : p.Opportunity__r.BidTeam_2__r.Salesforce_User__r.Name;        
            cs.Survey_EM_EmployeeNumber__c = p.Project_Manager_EmployeeNumber__c;
            cs.Survey_EM_Email__c = p.Project_Manager_Email__c;
            cs.Survey_EM_Email1__c = p.Project_Manager_Email__c;
            cs.Survey_Initiation_Status__c = CON_Qualtrics.NEW_SURVEY;
            cs.Survey_PIC_Name__c = (p.Delivery_PIC_Name__c != null) ? p.Delivery_PIC_Name__c : p.Opportunity__r.Principle_inCharge__r.Salesforce_user__r.name;
            cs.Survey_PIC_EmployeeNumber__c = p.Delivery_PIC_EmployeeNumber__c;
            cs.Survey_PIC_Email__c = p.Delivery_PIC_Email__c;
            cs.Survey_PIC_Email1__c = p.Delivery_PIC_Email__c;
            cs.Survey_Recipient_1__c = p.Opportunity__r.Survey_Recipient__c;
            cs.Survey_Recipient_2__c = p.Opportunity__r.Survey_Recipient_2__c;
            cs.Survey_Recipient_3__c = p.Opportunity__r.Survey_Recipient_3__c;
            cs.Survey_Send_Date__c = (p.Project_End_Date__c <= System.today())? System.today().addDays(10) : System.today();
            cs.Survey_Type__c = (p.Project_End_Date__c <= System.today())? CON_Qualtrics.END_OF_ENGAGEMENT : CON_Qualtrics.ONGOING;
            cs.Survey_Method__c = CON_Qualtrics.WEB_SURVEY;
            //List<Contact> surveyEMContactList = new SLT_Contact().getContactByUserEmployeeNumber(p.Project_Manager_EmployeeNumber__c);
            //List<Contact> surveyPICContactList = new SLT_Contact().getContactByUserEmployeeNumber(p.Delivery_PIC_EmployeeNumber__c);
            //cs.Survey_EM__c = (surveyEMContactList.size() > 0 && surveyEMContactList != null) ? surveyEMContactList[0].Id : p.Opportunity__r.BidTeam_2__c;
            //cs.Survey_PIC__c = (surveyPICContactList.size() > 0 && surveyPICContactList != null) ? surveyEMContactList[0].Id : p.Opportunity__r.Principle_inCharge__c;
            csList.add(cs);
        }
        try{
            Database.SaveResult[] sr = Database.insert(csList, false);
            String msgStr = CON_Qualtrics.MAIL_BEING_SENT_FOR_MONITORING_PURPOSE;
            msgStr += CON_Qualtrics.INSERTION_WILL_FAIL_DUE_TO_VALIDATIONS;
            for(Integer i = 0; i < sr.size(); i++){   
                Client_Sat_Survey__c csObj = csList.get(i);  
                msgStr += '---------------------------------'+ csObj.Opportunity__c + '---------------------------------'+ '\n';          
                if(sr[i] != null && !sr[i].isSuccess()) {                 
                    Database.Error[] err = sr[i].getErrors(); 
                    if (err != null ) {
                        for(integer j = 0; j < err.size(); j++) {                             
                            msgStr += err[j].getStatusCode() + ' ' + err[j].getMessage() + '\n';
                            
                        }
                        sendErrorMailNotification(msgStr, CON_Qualtrics.CLIENT_SAT_ADMINS);
                    }
                } else {
                    msgStr += CON_Qualtrics.SURVEY_CREATED_SUCCESSFULLY + '\n';
                } 
            }
        } catch (Exception ex) {
            sendMailNotification(ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext info){
           
    }
    
    private void checkInactiveApprovers(){
        List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList = [SELECT BusinessUnit__c, DeclinedSurveyApproverGroup__c, PeopleSoft_User_Country__c, 
                                                                          MainDeliveryCountry__c, PeopleSoftProductOfferingType__c, Priority__c
                                                                          FROM DeclinedSurveyApproverGroup__c 
                                                                          ORDER BY Priority__c
                                                                         ];
        Set<String> declinedSurveyApproverGroupSet = new Set<String>();
        for(DeclinedSurveyApproverGroup__c declinedGroup : declinedApproverGroupList){
            declinedSurveyApproverGroupSet.add(declinedGroup.DeclinedSurveyApproverGroup__c);
        }
        Set<Id> userIdSet = new Set<Id>();
        List<Group> grpList = 
            [SELECT Id, Name, (SELECT UserOrGroupId FROM GroupMembers) FROM Group g WHERE Name IN : declinedSurveyApproverGroupSet];
        for(Group grp : grpList){
            for(GroupMember grpMember : grp.GroupMembers){
                userIdSet.add(grpMember.UserOrGroupId);
            }
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN : userIdSet AND IsActive = false]);
        if(userMap.size() > 0){
            List<String> inactiveGroupMemberList = new List<String>();
            for(Group grp : grpList){
                for(GroupMember grpMember : grp.GroupMembers){
                    if(userMap.containsKey(grpMember.UserOrGroupId)){
                        inactiveGroupMemberList.add(grp.Name + ':' + userMap.get(grpMember.UserOrGroupId).Name);
                    }
                }
            }
            sendInactiveApproversMail(inactiveGroupMemberList);
        }
    }
    
    @testVisible
    private void sendInactiveApproversMail(List<String> inactiveGroupWithMemberList) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
        String address = Label.CS_Notification_User_Email_Ids;
        String[] toAddresses = address.split(';');
        mail.setToAddresses(toAddresses);
        mail.setSubject('***** '+CON_Qualtrics.INACTIVE_APPROVERS_EXISTS_IN_CLIENT_SAT_APPROVER_GROUP);
        String htmlBody = '<table style="font-family:Verdana,Arial;font-size:12px;" border="1" width="500"><tr><th colspan="2">*** Inactive Approvers ***</th></tr><tr><th>Group Name</th><th>Inactive Member Name</th></tr>';
        for(String inactiveGroupWithMember: inactiveGroupWithMemberList){
            List<String> groupAndMember = inactiveGroupWithMember.split(':');
            htmlBody += '<tr><td>' + groupAndMember.get(0) + '</td><td>' + groupAndMember.get(1) + '</td></tr>';
        }
        htmlBody += '</table><br>Please replace these users with active Client Sat Approver Group Members';
        mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    @testVisible
    private void sendMailNotification(String errMsg) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
        String address = Label.CS_Notification_User_Email_Ids;
        String[] toAddresses = address.split(';');
        mail.setToAddresses(toAddresses);
        mail.setSubject(CON_Qualtrics.CLIENT_SAT_BATCH_CLONING_ERROR);
        mail.setHtmlBody('<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Client Sat Batch failed ***<br><br>The automated process creating Client Sat Records failed:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Error Mesage:</td><td>'+ errMsg +'</td></tr></table></p></td></tr></table>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    @testVisible
    private void sendErrorMailNotification(String errMsg, String GroupName) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        List<User> listOfUser = [SELECT Id, Name, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.name =: groupName)];
        List<String> toAddresses = new List<String>();
        if(!listOfUser.isEmpty()) {
            for(User userToSendEmail : listOfUser) {
                toAddresses.add(userToSendEmail.Email);
                
            } 
        }
        mail.setToAddresses(toAddresses);
        mail.setSubject(CON_Qualtrics.CLIENT_SAT_SURVEY_INSERTION_FAILED);
        mail.setHtmlBody('<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Client Sat Batch failed ***<br><br>The automated process creating Client Sat Records failed:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Error Mesage:</td><td>'+ errMsg +'</td></tr></table></p></td></tr></table>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    */
}