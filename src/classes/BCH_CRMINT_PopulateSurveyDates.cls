global class BCH_CRMINT_PopulateSurveyDates implements Database.Batchable<Sobject>,Database.Stateful {
    
    String msgStr = '';
    Date nearestFurtureDate = Date.today();
    Date adjustedDate = Date.today();
    Set<String> RDSlobSet = new Set<String>{'Clinical','Data Sciences','Early Clinical Development','Connected Devices'};
    Integer intakeSurveyDelay = 0;
    
    global BCH_CRMINT_PopulateSurveyDates(Date nearestDate, Date adjustedDt) {
        nearestFurtureDate = nearestDate;
        adjustedDate = adjustedDt;
        if(Survey_Setting__c.getInstance() != null && Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c != null) {
            intakeSurveyDelay = (Integer) Survey_Setting__c.getInstance().Intake_Survey_Delay_Duration__c;   
        }
    }
    
    global Database.QueryLocator start( Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, Name, Line_of_Business__c, Previous_survey_sent_date__c, Next_Survey_Send_Date__c, Upcoming_Survey_Send_Date__c, Contract_Start_Date__c, Contract_End_Date__c, 
                                         Expected_Project_Start_Date__c, Expected_Project_End_Date__c, 
                                         Is_Survey_Eligible_for_Non_RDS__c, Is_Survey_Eligible_for_RDS_Auto__c FROM Opportunity 
                                         WHERE (StageName = '7a. Closed Won' OR StageName = 'In-Hand') 
                                         AND ((Is_Survey_Eligible_for_RDS_Auto__c = TRUE
                                         AND ((Line_of_Business__c IN :RDSlobSet AND Expected_Project_End_Date__c >= :nearestFurtureDate) 
                                         OR (Line_of_Business__c NOT IN :RDSlobSet AND Contract_End_Date__c >= :nearestFurtureDate))) 
                                         OR (Is_Survey_Eligible_for_Non_RDS__c = TRUE AND Contract_End_Date__c >= :nearestFurtureDate))]);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> scope) {
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        Boolean needUpdate = false;
        Date nearestFurture = null;
        for(Opportunity opp : scope) {
            needUpdate = false;
            nearestFurture = null;
            if(opp.Upcoming_Survey_Send_Date__c == NULL && (opp.Is_Survey_Eligible_for_RDS_Auto__c)) {
                if(RDSlobSet.contains(opp.Line_of_Business__c) && opp.Expected_Project_Start_Date__c != NULL && opp.Expected_Project_End_Date__c != NULL) {
                    nearestFurture = opp.Previous_survey_sent_date__c != NULL ? opp.Previous_survey_sent_date__c : opp.Expected_Project_Start_Date__c;
                    while(nearestFurture < nearestFurtureDate) {
                        nearestFurture = nearestFurture.addMonths(6);
                    }
                    if(nearestFurture >= opp.Expected_Project_End_Date__c) {
                        nearestFurture = opp.Expected_Project_End_Date__c;
                    }
                    needUpdate = true;
                    
                } else if(!RDSlobSet.contains(opp.Line_of_Business__c) && opp.Contract_Start_Date__c != NULL && opp.Contract_End_Date__c != NULL) {
                    nearestFurture = opp.Previous_survey_sent_date__c != NULL ? opp.Previous_survey_sent_date__c : opp.Contract_Start_Date__c;
                    while(nearestFurture < nearestFurtureDate) {
                        nearestFurture = nearestFurture.addMonths(6);
                    }
                    if(nearestFurture >= opp.Contract_End_Date__c) {
                        nearestFurture = opp.Contract_End_Date__c;
                    }
                    needUpdate = true;
                }
            } else if (opp.Is_Survey_Eligible_for_Non_RDS__c && opp.Contract_Start_Date__c != NULL && opp.Contract_End_Date__c != NULL) {
                nearestFurture = opp.Previous_survey_sent_date__c != NULL ? opp.Previous_survey_sent_date__c : opp.Contract_Start_Date__c;
                while(nearestFurture < nearestFurtureDate) {
                    nearestFurture = nearestFurture.addYears(1);
                }
                if(nearestFurture >= opp.Contract_End_Date__c) {
                    nearestFurture = opp.Contract_End_Date__c.addDays(10);
                }
                needUpdate = true;
            }
            if(needUpdate) {
                if(nearestFurture >= nearestFurtureDate && nearestFurture <= nearestFurtureDate.addDays(intakeSurveyDelay)) {
                    nearestFurture = adjustedDate;
                }
                opp.Next_Survey_Send_Date__c = nearestFurture;
                opp.Upcoming_Survey_Send_Date__c = nearestFurture;
                oppToUpdateList.add(opp);
            }
        }
        if(oppToUpdateList.size() > 0) {
            UTL_ExecutionControl.stopTriggerExecution = true;
            Database.SaveResult[] sr = Database.update(oppToUpdateList, false);
            if(sr.size() > 0) {
                
                for(Integer i = 0; i < sr.size(); i++) {   
                    Opportunity opp = oppToUpdateList.get(i);     
                    if(sr[i] != null && !sr[i].isSuccess()) {
                        msgStr += '<br/><br/>--Opportunity Refrence--------------------' + Opp.Id + '-------------------------'+ '<br/>';
                        Database.Error[] err = sr[i].getErrors(); 
                        if (err != null ) {
                            for(integer j = 0; j < err.size(); j++) {                             
                                msgStr += err[j].getStatusCode() + ' ' + err[j].getMessage();
                            }
                        }
                    }
                } 
            }
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
    
    global void finish(Database.BatchableContext info) {
        if(!Test.isRunningTest()){
            sendErrorMailNotification(msgStr, CON_Qualtrics.CLIENT_SAT_ADMINS);
        }
    }

    @testVisible
    public static void sendErrorMailNotification(String msgStr, String GroupName) {
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        List<User> listOfUser = [SELECT Id, Name, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.name =: groupName)];
        List<String> toAddresses = new List<String>();
        if(!listOfUser.isEmpty()) {
            for(User userToSendEmail : listOfUser) {
                toAddresses.add(userToSendEmail.Email);
            } 
        }
        String body ='<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Populate Survey Dates Status ***<br><br>The automated process for setting Next or Upcomming Survey Send date in Opportunity :<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Message:</td><td>'+ msgStr +'</td></tr></table></p></td></tr></table>';
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = toAddresses;
        message.subject = 'BCH_CRMINT_PopulateSurveyDates Batch Status';
        message.staticContent = body;
        messageList.add(message);
        UTL_CRM_SendEmail.MODULE_NAME = 'CRMINT';
        UTL_CRM_SendEmail.MODULE_ALERT_NAME = 'CRMINT_01_SendEmail';
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
}