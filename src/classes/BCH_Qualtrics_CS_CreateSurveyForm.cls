global class BCH_Qualtrics_CS_CreateSurveyForm implements Database.Batchable<Sobject>,Database.Stateful {
   
    String exception_msg;
    List<String> inactiveGroupMember_List;
    String msgStr;
    String surveyLogEmailId;
    Set<Id> OppIdSet = new Set<Id>();
    
    public BCH_Qualtrics_CS_CreateSurveyForm(){
       setSurveyDetails(); 
    }
    
    public BCH_Qualtrics_CS_CreateSurveyForm(Set<Id> OpportunityIds){ 
		setSurveyDetails();
        this.OppIdSet = OpportunityIds;
    }
    
    public void setSurveyDetails(){
        surveyLogEmailId = Survey_Setting__c.getInstance()!= null? Survey_Setting__c.getInstance().Survey_Log_Email_Id__c : '';
        exception_msg = '';
        msgStr = CON_Qualtrics.MAIL_BEING_SENT_FOR_MONITORING_PURPOSE;
        msgStr += CON_Qualtrics.INSERTION_WILL_FAIL_DUE_TO_VALIDATIONS;
        
     //   inactiveGroupMember_List = new List<String>();
    }
    
    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    global Database.QueryLocator start( Database.BatchableContext context ) {
        Integer intakeSurveyDelay = 0;
        if(Survey_Setting__c.getInstance() != null && Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c != null) {
            intakeSurveyDelay = (Integer) Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c;   
        }
        Date Date6more = System.today().addDays(intakeSurveyDelay).addMonths(6);
        Date todayWithThirtyDayMore = System.today().addDays(intakeSurveyDelay);
        Set<String> RDSlobSet = new Set<String>{'Clinical','Data Sciences','Early Clinical Development','Connected Devices','Patient & DCT Solutions'};
          
            if(!OppIdSet.isEmpty()) {
                return Database.getQueryLocator([SELECT id ,Is_Survey_Eligible_for_Non_RDS__c, is_Survey_eligible_for_RDS_Auto__c, Contract_Start_Date__c, Contract_End_Date__c, 
                                                 Expected_Project_Start_Date__c, Expected_Project_End_Date__c, Line_of_Business__c,
                                                 Name, ownerId, Survey_Recipient__c,Survey_Recipient_2__c,Survey_Recipient_3__c,  BidTeam_2__r.Salesforce_User__r.Name, BidTeam_2__r.Salesforce_User__r.Email, StageName,
                                                 Amount_In_USD__c,ZREP_Product_Count__c, (SELECT Opportunity__c, Id ,Survey_Type__c, CreatedDate FROM Client_Sat_Surveys__r ORDER BY CreatedDate DESC Limit 1)                                                               
                                                 FROM Opportunity WHERE (Upcoming_Survey_Send_Date__c =:todayWithThirtyDayMore OR Next_Survey_Send_Date__c =:todayWithThirtyDayMore) 
                                                 AND( (is_Survey_eligible_for_RDS_Auto__c = true AND (StageName =:CON_Qualtrics.CLOSED_WON OR StageName =:CON_Qualtrics.IN_HAND)) OR
                                                     (StageName =:CON_Qualtrics.IN_HAND AND Is_Survey_Eligible_for_Non_RDS__c = true)) AND id in :OppIdSet]);
            }else{
                
                return Database.getQueryLocator([SELECT id ,Is_Survey_Eligible_for_Non_RDS__c, is_Survey_eligible_for_RDS_Auto__c, Contract_Start_Date__c, Contract_End_Date__c, 
                                                 Expected_Project_Start_Date__c, Expected_Project_End_Date__c, Line_of_Business__c,
                                                 Name, ownerId, Survey_Recipient__c,Survey_Recipient_2__c,Survey_Recipient_3__c,  BidTeam_2__r.Salesforce_User__r.Name, BidTeam_2__r.Salesforce_User__r.Email, StageName,
                                                 Amount_In_USD__c,ZREP_Product_Count__c, (SELECT Opportunity__c, Id ,Survey_Type__c, CreatedDate FROM Client_Sat_Surveys__r ORDER BY CreatedDate DESC Limit 1)                                                               
                                                 FROM Opportunity WHERE (Upcoming_Survey_Send_Date__c =:todayWithThirtyDayMore OR Next_Survey_Send_Date__c =:todayWithThirtyDayMore) 
                                                 AND( (is_Survey_eligible_for_RDS_Auto__c = true AND (StageName =:CON_Qualtrics.CLOSED_WON OR StageName =:CON_Qualtrics.IN_HAND)) OR
                                                     (StageName =:CON_Qualtrics.IN_HAND AND Is_Survey_Eligible_for_Non_RDS__c = true))]);
            }
    }
  
    global void execute(Database.BatchableContext context, List<Opportunity> scope) {
        Integer intakeSurveyDelay = 0;
        if(Survey_Setting__c.getInstance() != null && Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c != null) {
            intakeSurveyDelay = (Integer) Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c;   
        }
        Set<Id> opportunityIDs = new Set<Id> {};
        Map<Id,Proxy_Project__c> proxyProjectMap = new Map<Id,Proxy_Project__c>();
        boolean isSurveyIncludeEndDate = false;
        boolean isSurveyIncludeEndDateNonRDS = false;
        Set<String> RDSlobSet = new Set<String>{'Clinical','Data Sciences','Early Clinical Development','Connected Devices','Patient & DCT Solutions'};
        List<Client_Sat_Survey__c> surveyList = new List<Client_Sat_Survey__c>();
        for(Opportunity opp : scope) {
            opportunityIDs.add(opp.Id);
        }
        proxyProjectMap = new SLT_proxy_Project().getProxyProjectByOppIDAndRecordTypeName(opportunityIDs, 'Engagement', new Set<String>{'ID','Name','Opportunity__c','Project_Start_Date__c', 'Project_End_Date__c'});
        for(Opportunity opp : scope) {
            Client_Sat_Survey__c survey = new Client_Sat_Survey__c();
            if(opp.Client_Sat_Surveys__r.size() >0 ) {
                if(opp.Client_Sat_Surveys__r[0].Survey_Type__c  == CON_Qualtrics.END_OF_ENGAGEMENT){
                    msgStr += '<br/><br/>Opportunity Refrence--------------------'+ opp.Id + '-------------------------'+ '<br/>';
                    msgStr += 'Survey already created with End of Engagement type';
                    continue;
                }
            }
            if(opp.is_Survey_eligible_for_RDS_Auto__c) {
                if(opp.ZREP_Product_Count__c > 0 && (proxyProjectMap.containsKey(opp.ID))) {
                    isSurveyIncludeEndDate = (proxyProjectMap.get(opp.ID).Project_End_Date__c >= System.today().addDays(intakeSurveyDelay)) ? true :false;
                    survey.Opp_Engagement_start_date__c =  proxyProjectMap.get(opp.ID).Project_Start_Date__c;
                }
                else if(RDSlobSet.contains(opp.Line_of_Business__c)) {
                    isSurveyIncludeEndDate = (opp.Expected_Project_End_Date__c >= System.today().addDays(intakeSurveyDelay)) ? true :false;
                    survey.Opp_Engagement_start_date__c =  opp.Expected_Project_Start_Date__c;
                } else {
                    isSurveyIncludeEndDate = (opp.Contract_End_Date__c >= System.today().addDays(intakeSurveyDelay)) ? true :false;
                    survey.Opp_Engagement_start_date__c =  opp.Contract_Start_Date__c;
                }
                survey.Survey_Send_Date__c = System.today().addDays(intakeSurveyDelay);
                survey.Survey_Type__c =  isSurveyIncludeEndDate ? CON_Qualtrics.END_OF_ENGAGEMENT : CON_Qualtrics.ONGOING;
            } else if(opp.Is_Survey_Eligible_for_Non_RDS__c) {
                if (opp.ZREP_Product_Count__c > 0 && (proxyProjectMap.containsKey(opp.ID))) {
                    isSurveyIncludeEndDateNonRDS = (proxyProjectMap.get(opp.ID).Project_End_Date__c >= System.today().addDays(intakeSurveyDelay)) ? true :false;
                    survey.Opp_Engagement_start_date__c = proxyProjectMap.get(opp.ID).Project_Start_Date__c;
                } else{
                    isSurveyIncludeEndDateNonRDS = (opp.Contract_End_Date__c >= System.today().addDays(intakeSurveyDelay)) ? true :false;
                    survey.Opp_Engagement_start_date__c = opp.Contract_Start_Date__c;
                }
                
                survey.Survey_Send_Date__c = isSurveyIncludeEndDateNonRDS ? System.today().addDays(10 + intakeSurveyDelay) : System.today().addDays(intakeSurveyDelay);
                survey.Survey_Type__c = isSurveyIncludeEndDateNonRDS ? CON_Qualtrics.END_OF_ENGAGEMENT : CON_Qualtrics.ONGOING;  
                survey.Survey_EM_Name__c = opp.BidTeam_2__r.Salesforce_User__r.Name;
                survey.Survey_EM_Email__c = opp.BidTeam_2__r.Salesforce_User__r.Email;
                survey.Survey_EM_Email1__c = opp.BidTeam_2__r.Salesforce_User__r.Email;
            }
            survey.Opp_Engagement__c = opp.name;
            survey.Opportunity__c = opp.Id;
            survey.Opportunity_Owner__c = opp.ownerId;
            survey.Send_Survey__c = null;
            survey.Survey_Initiation_Status__c = CON_Qualtrics.NEW_SURVEY;
            survey.Survey_Recipient_1__c = opp.Survey_Recipient__c;
            survey.Survey_Recipient_2__c = opp.Survey_Recipient_2__c;
            survey.Survey_Recipient_3__c = opp.Survey_Recipient_3__c;
            survey.Survey_Method__c = CON_Qualtrics.WEB_SURVEY;
            surveyList.add(survey);
        }
        try{
            Database.SaveResult[] sr = Database.insert(surveyList, false);
            if(sr.size() > 0){
                for(Integer i = 0; i < sr.size(); i++){   
                    Client_Sat_Survey__c csObj = surveyList.get(i);  
                    msgStr += '<br/><br/>Opportunity Refrence--------------------'+ csObj.Opportunity__c + '-------------------------'+ '<br/>';          
                    if(sr[i] != null && !sr[i].isSuccess()) {                 
                        Database.Error[] err = sr[i].getErrors(); 
                        if (err != null ) {
                            for(integer j = 0; j < err.size(); j++) {                             
                                msgStr += err[j].getStatusCode() + ' ' + err[j].getMessage();
                            }
                        }
                    } else {
                        msgStr += 'Status : '+ CON_Qualtrics.SURVEY_CREATED_SUCCESSFULLY;
                    } 
                }}
        } catch (Exception ex) {
            exception_msg += ex.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext info){
        if(!Test.isRunningTest()){
            sendMailFuture(exception_msg,inactiveGroupMember_List,msgStr,surveyLogEmailId);
        }
    }
    
    public static void sendMailFuture(String exception_msg, List<String> inactiveGroupMemberList, String msgStr, String surveyLogEmailId){
        if(msgStr != null && !String.isBlank(msgStr)){
            sendErrorMailNotification(msgStr, CON_Qualtrics.CLIENT_SAT_ADMINS, surveyLogEmailId);
        }
        if(exception_msg != null && !String.isBlank(exception_msg)){
            sendMailNotification(exception_msg);  
        }
    }
    
    @testVisible
    public static void sendMailNotification(String exception_msg) { 
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        String address = Label.CS_Notification_User_Email_Ids;
        String[] toAddresses = address.split(';');
        String body = '<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Client Sat Batch failed ***<br><br>The automated process creating Client Sat Records failed:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Error Mesage:</td><td>'+ exception_msg +'</td></tr></table></p></td></tr></table>';
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = toAddresses;
        message.subject = CON_Qualtrics.CLIENT_SAT_BATCH_CLONING_ERROR;
        message.staticContent = body;
        messageList.add(message);
        UTL_CRM_SendEmail.MODULE_NAME = 'CRMINT';
        UTL_CRM_SendEmail.MODULE_ALERT_NAME = 'CRMINT_01_SendEmail';
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
    
    @testVisible
    public static void sendErrorMailNotification(String msgStr, String GroupName, String surveyLogEmailId) {
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        List<User> listOfUser = [SELECT Id, Name, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.name =: groupName)];
        List<String> toAddresses = new List<String>();
        if(!listOfUser.isEmpty()) {
            for(User userToSendEmail : listOfUser) {
                toAddresses.add(userToSendEmail.Email);
            } 
        }
        if(surveyLogEmailId != ''){
            toAddresses.add(surveyLogEmailId);
        }
        String body ='<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Client Sat Batch Status ***<br><br>The automated process creating Client Sat Records status:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Message:</td><td>'+ msgStr +'</td></tr></table></p></td></tr></table>';
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = toAddresses;
        message.subject = CON_Qualtrics.CLIENT_SAT_SURVEY_CREATION_STATUS;
        message.staticContent = body;
        messageList.add(message);
        UTL_CRM_SendEmail.MODULE_NAME = 'CRMINT';
        UTL_CRM_SendEmail.MODULE_ALERT_NAME = 'CRMINT_01_SendEmail';
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
}