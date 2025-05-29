global class BCH_Qualtrics_CreateSurveyRecipient implements Database.Batchable<Client_Sat_Survey__c>,Database.Stateful{
    String query;
    String exception_msg;
    String msgStr;
    Map<Id, List<Client_Sat_Survey_Recipient__c>> surveyToRecipientMap = new Map<Id, List<Client_Sat_Survey_Recipient__c>>();
    Map<Id, Opportunity> surveyToOppMap = new Map<Id, Opportunity>();
    Map<Id, Id> surveyToOppIdMap = new Map<Id, Id>();
    Map<Id, Id> oppIdToSurveyIdMap = new Map<Id, Id>();
    List<Client_Sat_Survey_Recipient__c> recipientList;
    Map<Id, Integer> oppToDifference = new Map<Id, Integer>();
    String surveyLogEmailId;
    
    public BCH_Qualtrics_CreateSurveyRecipient(){
        surveyLogEmailId = Survey_Setting__c.getInstance()!= null? Survey_Setting__c.getInstance().Survey_Log_Email_Id__c : '';
        exception_msg = '';
        msgStr = CON_Qualtrics.MAIL_BEING_SENT_FOR_MONITORING_PURPOSE;
        msgStr += CON_Qualtrics.INSERTION_WILL_FAIL_DUE_TO_VALIDATIONS;
    }
    
    global Iterable<Client_Sat_Survey__c> start(Database.BatchableContext info){
        return [SELECT Id, Name, Survey_Recipient_1__c, Survey_Recipient_1__r.FirstName, Survey_Recipient_1__r.LastName, 
                Survey_Recipient_1__r.Email, Survey_Recipient_1__r.Phone, Survey_Recipient_1__r.Primary_Language__c, 
                Survey_Recipient_1__r.Account.Region_Territory__c,  Survey_Recipient_2__c, Survey_Recipient_2__r.FirstName, 
                Survey_Recipient_2__r.LastName, Survey_Recipient_2__r.Email, Survey_Recipient_2__r.Phone, 
                Survey_Recipient_2__r.Primary_Language__c, Survey_Recipient_2__r.Account.Region_Territory__c, 
                Survey_Recipient_3__c, Survey_Recipient_3__r.FirstName, Survey_Recipient_3__r.LastName, Survey_Recipient_3__r.Email, 
                Survey_Recipient_3__r.Phone, Survey_Recipient_3__r.Primary_Language__c, Survey_Recipient_3__r.Account.Region_Territory__c , 
                Send_Survey__c, Survey_Initiation_Status__c, Survey_Method__c,
                Opportunity__r.Type, Opportunity_Amount__c, Opportunity_Name__c, 
                Opportunity__r.pse__Primary_Project__c, Opportunity__r.Opportunity_Number__c, 
                Opportunity__r.Account.Parent.Name, Opportunity__r.Account.Parent.SAP_Reference__c, 
                Opportunity__r.Account.Name, Opportunity__r.Account.SAP_Reference__c,
                Opportunity__r.Legacy_IMS_Opportunity_Number__c, Opportunity__r.Name,          
                PIC_Country__c, Survey_Type__c, Opportunity_Product_Codes__c, Survey_Send_Date__c, Survey_Language_for_Recipient_1__c, 
                Survey_Language_for_Recipient_2__c, Survey_Language_for_Recipient_3__c,
                Survey_PIC_Name__c, Survey_PIC_Email__c, Survey_PIC_EmployeeNumber__c, Survey_EM_Email__c,
                Survey_EM_Name__c, Survey_EM_EmployeeNumber__c, Response_Category__c, Survey_Title__c,
                Opportunity__r.Business_Unit__c, Opportunity__r.Therapy_Area__c, Opportunity__r.Main_Delivery_Country__c,
                Opportunity__r.Project_Code__c, Opportunity__r.Global_project_unit__c,
                Opportunity__r.FSP__c, Opportunity__r.Protocol_Number__c,
                Opportunity__r.Drug_Product_Name__c, Opportunity__r.Previous_survey_sent_date__c, 
                Opportunity__r.Is_Survey_eligible_for_RDS_Auto__c, Opportunity__r.Is_Survey_eligible_for_RDS_Manual__c, Opportunity__c,
                Opportunity__r.Line_of_Business__c,Opportunity__r.Is_Survey_Eligible_for_Non_RDS__c
                FROM Client_Sat_Survey__c 
                WHERE (Send_Survey__c =: CON_Qualtrics.SEND_SURVEY_YES
                       AND Survey_Send_Date__c =: System.today()
                       AND Survey_Initiation_Status__c =: CON_Qualtrics.SURVEY_APPROVED
                       AND Survey_Method__c =: CON_Qualtrics.WEB_SURVEY)
                OR (Send_Survey__c = Null AND Survey_Initiation_Status__c =: CON_Qualtrics.NEW_SURVEY AND Survey_Send_Date__c =: System.today() AND (Opportunity__r.Is_Survey_Eligible_for_Non_RDS__c = TRUE AND ( Opportunity__r.Line_of_Business__c = Null OR Opportunity__r.Line_of_Business__c ='Other')))  
               ];
    }
    
    global void execute(Database.BatchableContext BC, List<Client_Sat_Survey__c> listOfSurvey) {
      
       
        try{
            Set<Id> oppIdSet = new Set<Id>();
            List<Client_Sat_Survey__c> surveyWithoutPICApprovalset = new List<Client_Sat_Survey__c>();
            for(Client_Sat_Survey__c survey : listOfSurvey) {
                oppIdSet.add(survey.Opportunity__c);
            }
            for(Integer i=0;i<listofSurvey.size();i++){
                if(listofSurvey[i].Send_Survey__c == Null && listofSurvey[i].Survey_Initiation_Status__c == CON_Qualtrics.NEW_SURVEY && listofSurvey[i].Survey_Send_Date__c == System.today() && listofSurvey[i].Opportunity__r.Is_Survey_Eligible_for_Non_RDS__c && ( listofsurvey[i].Opportunity__r.Line_of_Business__c == 'Other' || listofsurvey[i].Opportunity__r.Line_of_Business__c == Null )){
                    listofSurvey[i].Send_Survey__c = CON_Qualtrics.SEND_SURVEY_YES;
                    listofSurvey[i].Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_SENT_WITHOUT_PIC_ACTION; 
                    surveyWithoutPICApprovalset.add(listofSurvey[i]);
                }
            }
            
            
            Map<Id, Opportunity> oppIdWithLineItemsMap = new Map<Id, Opportunity>([SELECT Id, (SELECT Id, Offering_Group__c, Product_Name__c, Offering_Type__c, Offering_Segment__c, COE_Name__c,ProductCode FROM OpportunityLineItems) from Opportunity WHERE Id IN :oppIdSet]);
            List<Client_Sat_Survey_Recipient__c> listOfSurveyRecipient = new List<Client_Sat_Survey_Recipient__c>();
            List<Opportunity> oppListSurveydateupdate = new List<Opportunity>();
            if(!listOfSurvey.isEmpty()) {
                
                UTL_ExecutionControl.stopTriggerExecution = true;
                Database.SaveResult[] sr_swpa = Database.update(surveyWithoutPICApprovalset,false);
                UTL_ExecutionControl.stopTriggerExecution = false;
                
				 List<ID> surveyWithoutPICApprovalErrorSet = new List<ID>();
                
                for(integer i=0;i<sr_swpa.size();i++){
                    Client_Sat_Survey__c clisatsur = surveyWithoutPICApprovalset.get(i);
                    if(sr_swpa[i] != null && !sr_swpa[i].isSuccess()){
                      surveyWithoutPICApprovalErrorSet.add(clisatsur.id); 
                    }
                }
				
                for(Client_Sat_Survey__c currentSurvey : listOfSurvey) {
				if(surveyWithoutPICApprovalErrorSet.contains(currentSurvey.Id)){
                        continue;
                    }
                    recipientList = new List<Client_Sat_Survey_Recipient__c>();
                    for(Integer i = 1; i <= 3; i++) {
                        Client_Sat_Survey_Recipient__c surveyRecipient = new Client_Sat_Survey_Recipient__c();
                        Contact currentRecipient = (Contact)currentSurvey.getSObject(CON_Qualtrics.SURVEY_RECIPIENT + i + '__r');
                        if(currentRecipient == null) { 
                            continue;
                        }
                        if(currentRecipient.FirstName != null){
                            surveyRecipient.Name = currentRecipient.FirstName +' '+ currentRecipient.LastName;
                        }else {
                            surveyRecipient.Name = currentRecipient.LastName;
                        }
                        surveyRecipient.Contact__c = currentRecipient.Id;
                        surveyRecipient.First_Name__c = currentRecipient.FirstName;
                        surveyRecipient.Last_Name__c = currentRecipient.LastName;
                        surveyRecipient.Email__c = currentRecipient.Email;
                        surveyRecipient.Phone__c = currentRecipient.Phone;
                        surveyRecipient.Primary_Language__c = currentRecipient.Primary_Language__c;
                        surveyRecipient.Account_Region_Territory__c = currentRecipient.Account.Region_Territory__c;
                        String currentRecipientName = CON_Qualtrics.SURVEY_RECIPIENT + i + '__c';
                        if(currentRecipientName == CON_Qualtrics.SURVEY_RECIPIENT_1 ) {
                            surveyRecipient.Qualtrics_Survey_Language__c = currentSurvey.Survey_Language_for_Recipient_1__c;                     
                        } else if(currentRecipientName == CON_Qualtrics.SURVEY_RECIPIENT_2) {
                            surveyRecipient.Qualtrics_Survey_Language__c = currentSurvey.Survey_Language_for_Recipient_2__c;                     
                        } else if(currentRecipientName == CON_Qualtrics.SURVEY_RECIPIENT_3) {
                            surveyRecipient.Qualtrics_Survey_Language__c = currentSurvey.Survey_Language_for_Recipient_3__c;                     
                        }      
                        surveyRecipient.Send_Survey__c = currentSurvey.Send_Survey__c;
                        surveyRecipient.Survey_PIC_Email__c = currentSurvey.Survey_PIC_Email__c;
                        surveyRecipient.Survey_PIC_Name__c = currentSurvey.Survey_PIC_Name__c;
                        surveyRecipient.Survey_PIC_Employee_Number__c = currentSurvey.Survey_PIC_EmployeeNumber__c;
                        surveyRecipient.Survey_EM_Email__c = currentSurvey.Survey_EM_Email__c;
                        surveyRecipient.Survey_EM_Name__c = currentSurvey.Survey_EM_Name__c;
                        surveyRecipient.Survey_EM_Employee_Number__c = currentSurvey.Survey_EM_EmployeeNumber__c;
                        surveyRecipient.Opportunity_Type__c = currentSurvey.Opportunity__r.Type;
                        surveyRecipient.Opportunity_Amount__c = currentSurvey.Opportunity_Amount__c;
                        surveyRecipient.Opportunity_Name__c = currentSurvey.Opportunity_Name__c;
                        String selectedEngagementName = currentSurvey.Opportunity__r.Legacy_IMS_Opportunity_Number__c + '-' + currentSurvey.Opportunity__r.Name;
                        // truncate if too long
                        if(selectedEngagementName.length() > 60)
                            selectedEngagementName = selectedEngagementName.substring(0, 60);
                        surveyRecipient.Opportunity_Primary_Project__c = selectedEngagementName;
                        surveyRecipient.Opportunity_Number__c = currentSurvey.Opportunity__r.Opportunity_Number__c;
                        surveyRecipient.Opportunity_Account_Parent_Name__c = currentSurvey.Opportunity__r.Account.Parent.Name;
                        surveyRecipient.Opportunity_Account_Parent_SAP_Ref__c = currentSurvey.Opportunity__r.Account.Parent.SAP_Reference__c;
                        surveyRecipient.Opportunity_Account_Name__c = currentSurvey.Opportunity__r.Account.Name;
                        surveyRecipient.Opportunity_Account_SAP_Ref__c = currentSurvey.Opportunity__r.Account.SAP_Reference__c;
                        surveyRecipient.Survey_PIC_Country__c = currentSurvey.PIC_Country__c;
                        surveyRecipient.Survey_Type__c = currentSurvey.Survey_Type__c;
                        surveyRecipient.Opportunity_Product_Codes__c = currentSurvey.Opportunity_Product_Codes__c;
                        surveyRecipient.Survey_Send_Date__c = currentSurvey.Survey_Send_Date__c;
                        surveyRecipient.Client_Sat_Survey__c = currentSurvey.Id;
                        
                        surveyRecipient.Response_Category__c = currentSurvey.Response_Category__c;
                        surveyRecipient.Client_Sat_Survey_ID__c = currentSurvey.Id;
                        surveyRecipient.Customer_Survey_Record_ID__c = currentSurvey.Name;
                        surveyRecipient.Survey_Title__c = currentSurvey.Survey_Title__c;
                        surveyRecipient.Business_Unit__c = currentSurvey.Opportunity__r.Business_Unit__c;
                        surveyRecipient.Therapy_Area__c = currentSurvey.Opportunity__r.Therapy_Area__c;
                        surveyRecipient.Main_Delivery_Country__c = currentSurvey.Opportunity__r.Main_Delivery_Country__c;
                        surveyRecipient.Project_Code__c = currentSurvey.Opportunity__r.Project_Code__c;
                        
                        surveyRecipient.Global_Project_Unit__c = currentSurvey.Opportunity__r.Global_project_unit__c;
                        surveyRecipient.FSP__c = currentSurvey.Opportunity__r.FSP__c;
                        surveyRecipient.Protocol_Number__c = currentSurvey.Opportunity__r.Protocol_Number__c;
                        surveyRecipient.Drug_Product_Name__c = currentSurvey.Opportunity__r.Drug_Product_Name__c;
                        String productNames = '';
                        String offeringGroups = '';
                        String offeringTypes = '';
                        String offeringSegments = '';
                        String coeNames = '';
                        String productCodes = '';
                        for(OpportunityLineItem lineItem : oppIdWithLineItemsMap.get(currentSurvey.Opportunity__c).OpportunityLineItems) {
                            productNames += lineItem.Product_Name__c + ';';
                            offeringGroups += lineItem.Offering_Group__c + ';';
                            offeringTypes += lineItem.Offering_Type__c + ';';
                            offeringSegments += lineItem.Offering_Segment__c + ';';
                            coeNames += lineItem.COE_Name__c + ';';
                            productCodes += lineItem.ProductCode + ';';
                        }
                        surveyRecipient.Offering_Group__c = offeringGroups;
                        surveyRecipient.Product__c = productNames;
                        surveyRecipient.Offering_Type__c = offeringTypes;
                        surveyRecipient.Offering_Segment__c = offeringSegments;
                        surveyRecipient.COE_Name__c = coeNames;
                        surveyRecipient.Product_Code__c = productCodes;
                        listOfSurveyRecipient.add(surveyRecipient);
                        recipientList.add(surveyRecipient);
                    }
                    surveyToRecipientMap.put(currentSurvey.id, recipientList);
                }
                if(!listOfSurveyRecipient.isEmpty()) {
                    Database.SaveResult[] sr = Database.insert(listOfSurveyRecipient, false);
                    if(sr.size() > 0){
                        for(Integer i = 0; i < sr.size(); i++){   
                            Client_Sat_Survey_Recipient__c csRecObj = listOfSurveyRecipient.get(i);  
                            msgStr += '<br/><br/>Client Sat Survey Reference-------'+csRecObj.Client_Sat_Survey__c + '<br/>';          
                            if(sr[i] != null && !sr[i].isSuccess()) {                 
                                Database.Error[] err = sr[i].getErrors(); 
                                if (err != null ) {
                                    for(integer j = 0; j < err.size(); j++) {                             
                                        msgStr += err[j].getStatusCode() + ' ' + err[j].getMessage();
                                    }
                                }
                            } else {
                                msgStr += 'Status : ' +  CON_Qualtrics.RECIPIENT_CREATED_SUCCESSFULLY;
                            }
                        }                         
                    }
                }   
            }
        }catch(Exception exc) {
            exception_msg += exc.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        if(!Test.isRunningTest()){
            sendMailFuture(exception_msg,msgStr,surveyLogEmailId);
        }
    }
    
    public static void sendMailFuture(String exception_msg, String msgStr, String surveyLogEmailId){
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
        String body = '<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Client Sat Survey Recipient Batch failed ***<br><br>The automated process creating Client Sat Survey Recipient Records failed:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Error Mesage:</td><td>'+ exception_msg +'</td></tr></table></p></td></tr></table>';
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = toAddresses;
        message.subject = CON_Qualtrics.CLIENT_SAT_RECIPIENT_BATCH_CLONING_ERROR;
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
        String body ='<table style="font-family:Verdana,Arial;font-size:12px;" border="0" width="500"><tr><td>*** Client Sat Survey Recipient Batch Status ***<br><br>The automated process creating Client Sat Survey Recipient Records status:<br><br><table style="font-family:Verdana,Arial;font-size:12px;border: 1px solid #666666;" cellpadding="5"><tr><td>Message:</td><td>'+ msgStr +'</td></tr></table></p></td></tr></table>';
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = toAddresses;
        message.subject = CON_Qualtrics.CLIENT_SAT_RECIPIENT_CREATION_STATUS;
        message.staticContent = body;
        messageList.add(message);
        UTL_CRM_SendEmail.MODULE_NAME = 'CRMINT';
        UTL_CRM_SendEmail.MODULE_ALERT_NAME = 'CRMINT_01_SendEmail';
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
}