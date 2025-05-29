/*
* This batch (executed using batch mode) is used to send email consisting of cumulative Project Tasks data in email body,
* covering Project Tasks who's pse__End_Date__c is lying in next 45 days from first day of month
* for every month to their assigned Service Line Lead/Parent Project's Project Manager for story IQVIAPSA-5636,
* to send email 14 days prior to Planned End Date of Project Task for story IQVIAPSA-5642,
* to send email 14 days prior to Planned End Date of Project Task for story IQVIAPSA-5643.
*/

public class BCH_PSA_ProjectTaskMailToServiceLineLead implements Database.Batchable<sObject>, Database.Stateful, BatchMode{
    public String batchMode = '';
    List<String> errorMessageList = new List <String>();
    Map<Id, List<pse__Project_Task__c>> contactIdToProjectTaskListMap = new Map<Id, List<pse__Project_Task__c>>();
    Date dateStartOfMonth = Date.today().toStartOfMonth();
    Date dateNextFortyFiveDaysFromStart = dateStartOfMonth.addDays(45);
    PSA_RDS_Settings__c psaRdsSettingsObj = PSA_RDS_Settings__c.getInstance();
    
    public void ExecuteMode(List<string> mode){
        for(String m : mode){
            batchMode = m;
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryString = '';
        
        if(batchMode == 'NEXT45DAYS'){
            queryString = 'SELECT Id, Name, pse__Status__c, Type__c, pse__Project__c, pse__Project__r.pse__Account__r.Name, pse__Project__r.Service_Line__r.Name, pse__Project__r.Service_Line_Lead__c, pse__Project__r.Service_Line_Lead__r.Name, pse__Project__r.Service_Line_Lead__r.Email, pse__Project__r.pse__Parent_Project__c, pse__Project__r.pse__Parent_Project__r.Project_Code__c, pse__End_Date__c, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Name, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email FROM pse__Project_Task__c WHERE RecordType.Name = \'' + CON_PSA.RDS_PROJECT_TASK + '\' AND Name LIKE \'%Complete Project Files Review%\' AND pse__Project__r.Service_Line__r.Name = \'' + CON_PSA.PV_SOLN_SRVC_NAME + '\' AND pse__End_Date__c >= :dateStartOfMonth AND pse__End_Date__c < :dateNextFortyFiveDaysFromStart AND (pse__Project__r.Service_Line_Lead__r.Email != NULL OR pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null)  AND pse__Status__c IN (\'' + CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS + '\', \'' + CON_PSA.PROJ_TASK_STATUS_NOT_STARTED + '\') AND Trigger_Email_Notification__c = TRUE ORDER BY pse__Project__r.Service_Line_Lead__r.Email, Parent_Project__r.pse__Project_Manager__r.Email';
        }else if(batchMode == '14DAYSPRIOR'){
            queryString = 'SELECT Id, Name, pse__Status__c, Type__c, pse__Project__c, pse__Project__r.pse__Account__r.Name, pse__Project__r.Service_Line__r.Name, pse__Project__r.Service_Line_Lead__c, pse__Project__r.Service_Line_Lead__r.Name, pse__Project__r.Service_Line_Lead__r.Email, pse__Project__r.pse__Parent_Project__c, pse__Project__r.pse__Parent_Project__r.Project_Code__c, pse__End_Date__c, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Name, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email FROM pse__Project_Task__c WHERE RecordType.Name = \'' + CON_PSA.RDS_PROJECT_TASK + '\' AND Name LIKE \'%Complete Project Files Review%\' AND pse__Project__r.Service_Line__r.Name = \'' + CON_PSA.PV_SOLN_SRVC_NAME + '\' AND pse__End_Date__c = ' + String.valueOf(Date.today().addDays(14)) + ' AND (pse__Project__r.Service_Line_Lead__r.Email != NULL OR pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null)  AND pse__Status__c IN (\'' + CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS + '\', \'' + CON_PSA.PROJ_TASK_STATUS_NOT_STARTED + '\') AND Trigger_Email_Notification__c = TRUE ORDER BY pse__Project__r.Service_Line_Lead__r.Email, Parent_Project__r.pse__Project_Manager__r.Email';
        }else if(batchMode == '3DAYSPRIOR'){
            queryString = 'SELECT Id, Name, pse__Status__c, Type__c, pse__Project__c, pse__Project__r.pse__Account__r.Name, pse__Project__r.Service_Line__r.Name, pse__Project__r.Service_Line_Lead__c, pse__Project__r.Service_Line_Lead__r.Name, pse__Project__r.Service_Line_Lead__r.Email, pse__Project__r.pse__Parent_Project__c, pse__Project__r.pse__Parent_Project__r.Project_Code__c, pse__End_Date__c, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Name, pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email FROM pse__Project_Task__c WHERE RecordType.Name = \'' + CON_PSA.RDS_PROJECT_TASK + '\' AND Name LIKE \'%Complete Project Files Review%\' AND pse__Project__r.Service_Line__r.Name = \'' + CON_PSA.PV_SOLN_SRVC_NAME + '\' AND pse__End_Date__c = ' + String.valueOf(Date.today().addDays(3)) + ' AND (pse__Project__r.Service_Line_Lead__r.Email != NULL OR pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null)  AND pse__Status__c IN (\'' + CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS + '\', \'' + CON_PSA.PROJ_TASK_STATUS_NOT_STARTED + '\') AND Trigger_Email_Notification__c = TRUE ORDER BY pse__Project__r.Service_Line_Lead__r.Email, Parent_Project__r.pse__Project_Manager__r.Email';
        }
        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<pse__Project_Task__c> records){
        if(batchMode == 'NEXT45DAYS'){
            //creating map of Service Line Lead/Project Manager Id to all of his assigned Project Tasks
            for(pse__Project_Task__c projectTaskRecord : records){
                if((projectTaskRecord.pse__Project__c != null && projectTaskRecord.pse__Project__r.Service_Line_Lead__c != null && projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email != null) && (contactIdToProjectTaskListMap.containskey(projectTaskRecord.pse__Project__r.Service_Line_Lead__c))){
                    contactIdToProjectTaskListMap.get(projectTaskRecord.pse__Project__r.Service_Line_Lead__c).add(projectTaskRecord);
                }else if((projectTaskRecord.pse__Project__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null) && (contactIdToProjectTaskListMap.containskey(projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c))){
                    contactIdToProjectTaskListMap.get(projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c).add(projectTaskRecord);
                }else if(projectTaskRecord.pse__Project__c != null && projectTaskRecord.pse__Project__r.Service_Line_Lead__c != null && projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email != null){
                    contactIdToProjectTaskListMap.put(projectTaskRecord.pse__Project__r.Service_Line_Lead__c, new List<pse__Project_Task__c>{projectTaskRecord});
                }else if(projectTaskRecord.pse__Project__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null){
                    contactIdToProjectTaskListMap.put(projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c, new List<pse__Project_Task__c>{projectTaskRecord});
                }
            }
        }else if(batchMode == '14DAYSPRIOR'){
            String currentLoggedInOrgURL = URL.getOrgDomainUrl().toExternalForm();
            List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
            String moduleName = CON_PSA.PSA_MODULE_NAME;
            String emailAction = CON_PSA.PROJ_TASK_EMAIL_TO_SERVICE_LINE_LEAD_EMAIL_ACTION_VAL;
            String emailSubject = '2nd Reminder to Complete Outstanding Compliance for Safety Project files review.';
            String emailOverallBodyContent = '';
            Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_1__c.getLength();
            Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_2__c.getLength();
            for(pse__Project_Task__c projectTaskRecord : records){
                if((projectTaskRecord.pse__Project__c != null && projectTaskRecord.pse__Project__r.Service_Line_Lead__c != null
                    && projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name != null && projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email != null)
                   || (projectTaskRecord.pse__Project__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__c != null
                       && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Name != null
                       && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null)){
                           Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
                           objWorkFlowEmail.Email_Action__c = emailAction;
                           objWorkFlowEmail.Module_Name__c = moduleName;
                           objWorkFlowEmail.To_Email_1__c = (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email != null ? (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email) : (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email));
                           objWorkFlowEmail.Email_Subject__c = emailSubject;
                           
                           if(psaRdsSettingsObj.Project_Task_Email_to_SLL_Recipient__c != null){
                               objWorkFlowEmail.To_Email_2__c = psaRdsSettingsObj.Project_Task_Email_to_SLL_Recipient__c;
                           }
                           
                           emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Dear '+  (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name != null ? (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name) : (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Name)) +',<br>';
                           emailOverallBodyContent += 'A Gentle Reminder<br>';
                           emailOverallBodyContent += 'We would like to remind you that you have a Safety Project files review to complete for the below project. If the project SPF “due date” is moved due to various reasons, please update the PSA task accordingly.<br><br>';
                           emailOverallBodyContent += '<table style="font-family: arial, sans-serif;border-collapse: collapse; width: 100%;">';
                           emailOverallBodyContent += '<tr><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Code</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Account</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Status</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Service Line</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">PVS Lead Name</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">PVS Lead LM Email</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Manager Email</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Task Name</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Type</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Planned End Date</th></tr>';
                           emailOverallBodyContent += '<tr><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.Project_Code__c != null ? (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.Project_Code__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.pse__Account__r.Name != null ? (projectTaskRecord.pse__Project__r.pse__Account__r.Name) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Status__c != null ? (projectTaskRecord.pse__Status__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + projectTaskRecord.pse__Project__r.Service_Line__r.Name  + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name != null ? (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email != null ? (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null ? (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + '<a href = \'' + currentLoggedInOrgURL + '/' + projectTaskRecord.Id + '\'>' + projectTaskRecord.Name + '</a>' + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.Type__c != null ? (projectTaskRecord.Type__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + projectTaskRecord.pse__End_Date__c.day() + '/' + projectTaskRecord.pse__End_Date__c.month() + '/' + projectTaskRecord.pse__End_Date__c.year() + '</td></tr>';
                           emailOverallBodyContent += '</table>';
                           emailOverallBodyContent += '<br><br>Please be informed if no response is received within a week in advance of the due date, CORE team will perform the SPF on behalf of the PVS lead and an Action log will be created in the PSA for missing SPF data points which PVS will have to complete within 45 days. Kindly prioritize your response to this email. <br><br>';
                           emailOverallBodyContent += 'Thank You<br><br>';
                           emailOverallBodyContent += 'Kind Regards,<br>PVS CORE Team<br>(Coordinate, Organize, Review & Engage)';
                           emailOverallBodyContent += '</div>';
                           
                           if(emailOverallBodyContent.length() < content1FieldLength){
                               objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                           }else{
                               objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength-1);
                               if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength-2 ) {
                                   objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength-1, emailOverallBodyContent.length());
                               } else {
                                   objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength-1, content1FieldLength+content2FieldLength-2);
                               }
                           }
                           workflowEmailRecList.add(objWorkFlowEmail);
                           //reset overall body content
                           emailOverallBodyContent = '';
                       }
            }
            if(workflowEmailRecList.size() > 0){
                Database.SaveResult[] results = Database.insert(workflowEmailRecList, false);
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        errorMessageList.add('Errors : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }else if(batchMode == '3DAYSPRIOR'){
            String currentLoggedInOrgURL = URL.getOrgDomainUrl().toExternalForm();
            List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
            String moduleName = CON_PSA.PSA_MODULE_NAME;
            String emailAction = CON_PSA.PROJ_TASK_EMAIL_TO_SERVICE_LINE_LEAD_EMAIL_ACTION_VAL;
            String emailSubject = 'FINAL reminder to Complete Outstanding Compliance for Safety Project files review.';
            String emailOverallBodyContent = '';
            Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_1__c.getLength();
            Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_2__c.getLength();
            for(pse__Project_Task__c projectTaskRecord : records){
                if((projectTaskRecord.pse__Project__c != null && projectTaskRecord.pse__Project__r.Service_Line_Lead__c != null
                    && projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name != null && projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email != null)
                   || (projectTaskRecord.pse__Project__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__c != null
                       && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__c != null && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Name != null
                       && projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null)){
                           Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
                           objWorkFlowEmail.Email_Action__c = emailAction;
                           objWorkFlowEmail.Module_Name__c = moduleName;
                           objWorkFlowEmail.To_Email_1__c = (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email != null ? (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email) : (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email));
                           objWorkFlowEmail.Email_Subject__c = emailSubject;
                           
                           if(psaRdsSettingsObj.Project_Task_Email_to_SLL_Recipient__c != null){
                               objWorkFlowEmail.To_Email_2__c = psaRdsSettingsObj.Project_Task_Email_to_SLL_Recipient__c;
                           }
                           
                           emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Dear '+  (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name != null ? (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name) : (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Name)) +',<br>';
                           emailOverallBodyContent += 'Good Day!!<br><br>';
                           emailOverallBodyContent += 'This is a gentle reminder to inform you that there is a project Task that is DUE in 3 Days. Please confirm if the planned end date is correct or if the review has already been completed.<br><br>';
                           emailOverallBodyContent += '<table style="font-family: arial, sans-serif;border-collapse: collapse; width: 100%;">';
                           emailOverallBodyContent += '<tr><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Code</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Account</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Status</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Service Line</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">PVS Lead Name</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">PVS Lead LM Email</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Manager Email</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Task Name</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Type</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Planned End Date</th></tr>';
                           emailOverallBodyContent += '<tr><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.Project_Code__c != null ? (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.Project_Code__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.pse__Account__r.Name != null ? (projectTaskRecord.pse__Project__r.pse__Account__r.Name) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Status__c != null ? (projectTaskRecord.pse__Status__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + projectTaskRecord.pse__Project__r.Service_Line__r.Name  + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name != null ? (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Name) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email != null ? (projectTaskRecord.pse__Project__r.Service_Line_Lead__r.Email) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null ? (projectTaskRecord.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + '<a href = \'' + currentLoggedInOrgURL + '/' + projectTaskRecord.Id + '\'>' + projectTaskRecord.Name + '</a>' + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecord.Type__c != null ? (projectTaskRecord.Type__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + projectTaskRecord.pse__End_Date__c.day() + '/' + projectTaskRecord.pse__End_Date__c.month() + '/' + projectTaskRecord.pse__End_Date__c.year() + '</td></tr>';
                           emailOverallBodyContent += '</table>';
                           emailOverallBodyContent += '<br><br>Please be informed if no response is received within EOB today, CORE team will perform the SPF on behalf of the PVS lead and an Action log will be created in the PSA for missing SPF data points which PVS will have to complete within 45 days. Kindly prioritize your response to this email.<br><br>';
                           emailOverallBodyContent += 'Kind Regards,<br>PVS CORE Team<br>(Coordinate, Organize, Review & Engage)';
                           emailOverallBodyContent += '</div>';
                           
                           if(emailOverallBodyContent.length() < content1FieldLength){
                               objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                           }else{
                               objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength-1);
                               if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength-2 ) {
                                   objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength-1, emailOverallBodyContent.length());
                               } else {
                                   objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength-1, content1FieldLength+content2FieldLength-2);
                               }
                           }
                           workflowEmailRecList.add(objWorkFlowEmail);
                           //reset overall body content
                           emailOverallBodyContent = '';
                       }
            }
            if(workflowEmailRecList.size() > 0){
                Database.SaveResult[] results = Database.insert(workflowEmailRecList, false);
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        errorMessageList.add('Errors : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        if(batchMode == 'NEXT45DAYS'){
            //sending cumulative email of project tasks to service line lead or parent project's project manager
            if(contactIdToProjectTaskListMap != null && !contactIdToProjectTaskListMap.isEmpty()){
                String currentLoggedInOrgURL = URL.getOrgDomainUrl().toExternalForm();
                List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
                String moduleName = CON_PSA.PSA_MODULE_NAME;
                String emailAction = CON_PSA.PROJ_TASK_EMAIL_TO_SERVICE_LINE_LEAD_EMAIL_ACTION_VAL;
                String projectTasksDatePeriodText = tranformDate(dateStartOfMonth) + ' till ' + tranformDate(dateNextFortyFiveDaysFromStart.addDays(-1));
                String emailSubject = 'Reminder to Complete Outstanding Compliance for Safety Project files review due for ' + projectTasksDatePeriodText;
                String emailOverallBodyContent = '';
                Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_1__c.getLength();
                Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_2__c.getLength();
                
                for(Id serviceLineLeadContactId : contactIdToProjectTaskListMap.keySet()){
                    if(contactIdToProjectTaskListMap.get(serviceLineLeadContactId) != null && contactIdToProjectTaskListMap.get(serviceLineLeadContactId).size() > 0){
                        Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
                        objWorkFlowEmail.Email_Action__c = emailAction;
                        objWorkFlowEmail.Module_Name__c = moduleName;
                        objWorkFlowEmail.To_Email_1__c = (contactIdToProjectTaskListMap.get(serviceLineLeadContactId)[0].pse__Project__r.Service_Line_Lead__r.Email != null ? (contactIdToProjectTaskListMap.get(serviceLineLeadContactId)[0].pse__Project__r.Service_Line_Lead__r.Email) : (contactIdToProjectTaskListMap.get(serviceLineLeadContactId)[0].pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email));
                        objWorkFlowEmail.Email_Subject__c = emailSubject;
                        
                        if(psaRdsSettingsObj.Project_Task_Email_to_SLL_Recipient__c != null){
                            objWorkFlowEmail.To_Email_2__c = psaRdsSettingsObj.Project_Task_Email_to_SLL_Recipient__c;
                        }
                        
                        emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Dear '+  (contactIdToProjectTaskListMap.get(serviceLineLeadContactId)[0].pse__Project__r.Service_Line_Lead__r.Name != null ? (contactIdToProjectTaskListMap.get(serviceLineLeadContactId)[0].pse__Project__r.Service_Line_Lead__r.Name) : (contactIdToProjectTaskListMap.get(serviceLineLeadContactId)[0].pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Name)) +',<br><br>As per PSA report, please note for the below projects are due for the Safety Project File review for ' + projectTasksDatePeriodText + '.'+'<br><br>For file review PVS CORE team can provide assistance to PV solution leads to complete the Safety file review for the below activities.<br><br>-Initiate APEX file review<br>-Review project file review (ELVIS/eTMF/ECM) against APEX checklist<br>-APEX documentation<br-Check list finalization><br>-PSA update<br><br>Kindly confirm if you would need assistance for the PV Solutions file review for above activities.<br><br>';
                        emailOverallBodyContent += '<table style="font-family: arial, sans-serif;border-collapse: collapse; width: 100%;">';
                        emailOverallBodyContent += '<tr><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Code</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Account</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Status</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Service Line</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">PVS Lead Name</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">PVS Lead LM Email</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Manager Email</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Project Task Name</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Type</th><th style="border: 1px solid #dddddd; text-align: left; padding: 8px;">Planned End Date</th></tr>';
                        
                        for(pse__Project_Task__c projectTaskRecordRelatedToSLL : contactIdToProjectTaskListMap.get(serviceLineLeadContactId)){
                            emailOverallBodyContent += '<tr><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecordRelatedToSLL.pse__Project__r.pse__Parent_Project__r.Project_Code__c != null ? (projectTaskRecordRelatedToSLL.pse__Project__r.pse__Parent_Project__r.Project_Code__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecordRelatedToSLL.pse__Project__r.pse__Account__r.Name != null ? (projectTaskRecordRelatedToSLL.pse__Project__r.pse__Account__r.Name) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecordRelatedToSLL.pse__Status__c != null ? (projectTaskRecordRelatedToSLL.pse__Status__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + projectTaskRecordRelatedToSLL.pse__Project__r.Service_Line__r.Name  + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecordRelatedToSLL.pse__Project__r.Service_Line_Lead__r.Name != null ? (projectTaskRecordRelatedToSLL.pse__Project__r.Service_Line_Lead__r.Name) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecordRelatedToSLL.pse__Project__r.Service_Line_Lead__r.Email != null ? (projectTaskRecordRelatedToSLL.pse__Project__r.Service_Line_Lead__r.Email) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecordRelatedToSLL.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email != null ? (projectTaskRecordRelatedToSLL.pse__Project__r.pse__Parent_Project__r.pse__Project_Manager__r.Email) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + '<a href = \'' + currentLoggedInOrgURL + '/' + projectTaskRecordRelatedToSLL.Id + '\'>' + projectTaskRecordRelatedToSLL.Name + '</a>' + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + (projectTaskRecordRelatedToSLL.Type__c != null ? (projectTaskRecordRelatedToSLL.Type__c) : ('')) + '</td><td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">' + projectTaskRecordRelatedToSLL.pse__End_Date__c.day() + '/' + projectTaskRecordRelatedToSLL.pse__End_Date__c.month() + '/' + projectTaskRecordRelatedToSLL.pse__End_Date__c.year() + '</td></tr>';
                        }
                        
                        emailOverallBodyContent += '</table>';
                        emailOverallBodyContent += '<br><br>PSA Action Required:<br>-Check PSA to make sure due Planned End Dates are correct and update if required<br>-Perform Safety file review as per SOPs/APEX tracker database (training PPT attached)<br>-Remember to add the date to PSA for Actual End Date and change the Status to Complete<br>-Delete the duplicate tasks in PSA if applicable<br><br>';
                        emailOverallBodyContent += 'URL for the Training Slide <a href = ' + psaRdsSettingsObj.Training_URL_for_Project_Task__c + '>' + psaRdsSettingsObj.Training_URL_for_Project_Task__c + '</a><br><br>';
                        emailOverallBodyContent += 'Kind Regards,<br>PVS CORE Team<br>(Coordinate, Organize, Review & Engage)';
                        emailOverallBodyContent += '</div>';
                        
                        if(emailOverallBodyContent.length() < content1FieldLength) {
                            objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                        } else {
                            objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength-1);
                            if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength-2 ) {
                                objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength-1, emailOverallBodyContent.length());
                            } else {
                                objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength-1, content1FieldLength+content2FieldLength-2);
                            }
                        }
                        workflowEmailRecList.add(objWorkFlowEmail);
                        //reset overall body content
                        emailOverallBodyContent = '';
                    }
                }
                //trigger email by inserting Workflow_Email_Record__c records [managed by flow after record insertion]
                if(workflowEmailRecList.size() > 0){
                    Database.SaveResult[] results = Database.insert(workflowEmailRecList, false);
                    for (Integer i=0; i< results.size(); i++){
                        if (!results[i].isSuccess()){
                            errorMessageList.add('Errors : ' + results[i].getErrors()[0].getMessage());
                        }
                    }
                    
                    //send error details through email
                    if (((errorMessageList != null && errorMessageList.size() > 0) || Test.isRunningTest()) && psaRdsSettingsObj.Project_Task_SLL_Failed_Batch_Email_Ids__c != null){
                        String errorList = '';
                        Integer counter = 0;
                        for(String errMsg : errorMessageList){
                            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, errMsg, 'PSA', 'Exception', 'ERROR', ':::BCH_PSA_ProjectTaskMailToServiceLineLead:::objWorkFlowEmail Insert Exception', null));
                            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), False);             
                            errorList += ++counter+'. '+ 'Error'+'----> ';
                            errorList += errMsg+'<br><br>  ';
                        }
                        String userName = System.UserInfo.getName();
                        List<String> toAddr = psaRdsSettingsObj.Project_Task_SLL_Failed_Batch_Email_Ids__c.split(';');
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toAddr);
                        mail.setReplyTo(CON_PSA.IQVIA_NO_REPLY_SUPPORT_EMAIL);
                        mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Batch execution error. (Monthly 45 days cumulative project tasks mail to service line lead/project manager) - '+System.today());
                        String emailBody = 'Dear User, <br><br>';
                        emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
                        emailBody += '<b>Batch Name:</b> BCH_PSA_ProjectTaskMailToServiceLineLead <br>';
                        emailBody += '<b>Batch Mode:</b> ' + batchMode + ' <br>';
                        emailBody += '<b>Time of execution:</b> '+ System.now()+ '<br>';
                        emailBody += '<b>Execution user:</b> '+userName+'<br>';
                        emailBody += '<b>Completion status:</b> Failed <br>';
                        emailBody += '<b>Error Description:</b> '+ errorList;
                        emailBody += '<br>Thank You';
                        mail.setHtmlBody(emailBody);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                    }
                }
            }
        }else if(batchMode == '14DAYSPRIOR'){
            //send error details through email
            if (((errorMessageList != null && errorMessageList.size() > 0) || Test.isRunningTest()) && psaRdsSettingsObj.Project_Task_SLL_Failed_Batch_Email_Ids__c != null){
                String errorList = '';
                Integer counter = 0;
                for(String errMsg : errorMessageList){
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, errMsg, 'PSA', 'Exception', 'ERROR', ':::BCH_PSA_ProjectTaskMailToServiceLineLead:::objWorkFlowEmail Insert Exception', null));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), False);             
                    errorList += ++counter+'. '+ 'Error'+'----> ';
                    errorList += errMsg+'<br><br>  ';
                }
                String userName = System.UserInfo.getName();
                List<String> toAddr = psaRdsSettingsObj.Project_Task_SLL_Failed_Batch_Email_Ids__c.split(';');
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddr);
                mail.setReplyTo(CON_PSA.IQVIA_NO_REPLY_SUPPORT_EMAIL);
                mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Batch execution error. (14 days prior project task \'Planned End Date\' mail to service line lead/project manager) - '+System.today());
                String emailBody = 'Dear User, <br><br>';
                emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
                emailBody += '<b>Batch Name:</b> BCH_PSA_ProjectTaskMailToServiceLineLead <br>';
                emailBody += '<b>Batch Mode:</b> ' + batchMode + ' <br>';
                emailBody += '<b>Time of execution:</b> '+ System.now()+ '<br>';
                emailBody += '<b>Execution user:</b> '+userName+'<br>';
                emailBody += '<b>Completion status:</b> Failed <br>';
                emailBody += '<b>Error Description:</b> '+ errorList;
                emailBody += '<br>Thank You';
                mail.setHtmlBody(emailBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        }else if(batchMode == '3DAYSPRIOR'){
            //send error details through email
            if (((errorMessageList != null && errorMessageList.size() > 0) || Test.isRunningTest()) && psaRdsSettingsObj.Project_Task_SLL_Failed_Batch_Email_Ids__c != null){
                String errorList = '';
                Integer counter = 0;
                for(String errMsg : errorMessageList){
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, errMsg, 'PSA', 'Exception', 'ERROR', ':::BCH_PSA_ProjectTaskMailToServiceLineLead:::objWorkFlowEmail Insert Exception', null));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), False);             
                    errorList += ++counter+'. '+ 'Error'+'----> ';
                    errorList += errMsg+'<br><br>  ';
                }
                String userName = System.UserInfo.getName();
                List<String> toAddr = psaRdsSettingsObj.Project_Task_SLL_Failed_Batch_Email_Ids__c.split(';');
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddr);
                mail.setReplyTo(CON_PSA.IQVIA_NO_REPLY_SUPPORT_EMAIL);
                mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Batch execution error. (3 days prior project task \'Planned End Date\' mail to service line lead/project manager) - '+System.today());
                String emailBody = 'Dear User, <br><br>';
                emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
                emailBody += '<b>Batch Name:</b> BCH_PSA_ProjectTaskMailToServiceLineLead <br>';
                emailBody += '<b>Batch Mode:</b> ' + batchMode + ' <br>';
                emailBody += '<b>Time of execution:</b> '+ System.now()+ '<br>';
                emailBody += '<b>Execution user:</b> '+userName+'<br>';
                emailBody += '<b>Completion status:</b> Failed <br>';
                emailBody += '<b>Error Description:</b> '+ errorList;
                emailBody += '<br>Thank You';
                mail.setHtmlBody(emailBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        }
    }
    
    //used to transform date to dd-Mmm-yyyy format
    private String tranformDate(Date inputDate){
        String monthOfDate = CON_PSA.monthNumberToMonthNameMediumFormatMap.get(inputDate.month());
        return ((inputDate.day() < 10 ? ('0' + String.valueOf(inputDate.day())) : String.valueOf(inputDate.day())) + '-' + monthOfDate + '-' + String.valueOf(inputDate.year()));
    }
}
