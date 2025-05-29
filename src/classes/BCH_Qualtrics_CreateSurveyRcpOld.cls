global class BCH_Qualtrics_CreateSurveyRcpOld implements Database.Batchable<Client_Sat_Survey__c>{
    String query;
    global Iterable<Client_Sat_Survey__c> start(Database.BatchableContext info){
        return [SELECT Id, Survey_Recipient_1__c, Survey_Recipient_1__r.FirstName, Survey_Recipient_1__r.LastName, 
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
                Survey_EM_Name__c, Survey_EM_EmployeeNumber__c
                FROM Client_Sat_Survey__c 
                WHERE Send_Survey__c =: CON_Qualtrics.SEND_SURVEY_YES
                AND Survey_Send_Date__c =: System.today()
                AND Survey_Initiation_Status__c =: CON_Qualtrics.SURVEY_APPROVED
                AND Survey_Method__c =: CON_Qualtrics.WEB_SURVEY
               ];
    }
    
    global void execute(Database.BatchableContext BC, List<Client_Sat_Survey__c> listOfSurvey) {
        try{
            
            List<Client_Sat_Survey_Recipient__c> listOfSurveyRecipient = new List<Client_Sat_Survey_Recipient__c>();
            if(!listOfSurvey.isEmpty()) {
                for(Client_Sat_Survey__c currentSurvey : listOfSurvey) {
                    for(Integer i = 1; i <= 3; i++) {
                        Client_Sat_Survey_Recipient__c surveyRecipient = new Client_Sat_Survey_Recipient__c();
                        Contact currentRecipient = (Contact)currentSurvey.getSObject(CON_Qualtrics.SURVEY_RECIPIENT + i + '__r');
                        if(currentRecipient == null) { 
                            continue;
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
                        listOfSurveyRecipient.add(surveyRecipient);
                    }
                    
                }
                if(!listOfSurveyRecipient.isEmpty()) {
                    insert listOfSurveyRecipient;
                }   
            }
        }catch(Exception exc) {
            Apex_Error_Log__c errorLog = new Apex_Error_Log__c(Error_Message__c = exc.getMessage());
            insert errorLog;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
}