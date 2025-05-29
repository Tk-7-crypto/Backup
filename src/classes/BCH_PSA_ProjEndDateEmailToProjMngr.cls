public class BCH_PSA_ProjEndDateEmailToProjMngr implements Database.Batchable<sObject>, Database.Stateful{
    String date30DaysPrior = String.valueOf(Date.today().addDays(-30));
    public List<String> errorMessageList = new List<String>();
    PSA_RDS_Settings__c psaRdsSettingsObj = PSA_RDS_Settings__c.getInstance();
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String queryString = '';
        queryString = 'SELECT Id, Name, pse__Stage__c, pse__Group__c, pse__Project_Manager__c, pse__End_Date__c, pse__Project_Manager__r.Name, pse__Project_Manager__r.Email'
            +' FROM pse__Proj__c '
            +' WHERE RecordType.Name = \'' + CON_PSA.PROJ_REC_TYPE_RDS_PROJECT + '\' '
            +' AND pse__Project_Manager__c != null AND pse__Project_Manager__r.Email != null AND pse__Project_Manager__r.Name != null' 
            +' AND pse__Stage__c != \'' + CON_PSA.PROJ_STAGE_COMPLETED + '\' '
            +' AND pse__Group__r.Name = \'' + CON_PSA.PROJ_GROUP_RADDS + '\' '
            +' AND pse__End_Date__c = ' + date30DaysPrior;
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<pse__Proj__c> records){
        List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
        String moduleName = CON_PSA.PSA_MODULE_NAME;
        String emailAction = CON_PSA.PROJ_END_DATE_EMAIL_TO_PROJECT_MANAGER_EMAIL_ACTION_VAL;
        String emailSubject = 'Align project end date with Project Stage.';
        String emailOverallBodyContent = '';
        for(pse__Proj__c projectRecord : records){
            if(projectRecord.pse__Project_Manager__c != null && projectRecord.pse__Project_Manager__r.Email != null && projectRecord.pse__Project_Manager__r.Name != null 
               && projectRecord.pse__Group__c != null){
                   Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
                   objWorkFlowEmail.Email_Action__c = emailAction;
                   objWorkFlowEmail.Module_Name__c = moduleName;
                   objWorkFlowEmail.To_Email_1__c = projectRecord.pse__Project_Manager__r.Email;
                   objWorkFlowEmail.Email_Subject__c = emailSubject;
                   emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Dear '+  (projectRecord.pse__Project_Manager__r.Name != null ? (projectRecord.pse__Project_Manager__r.Name) : ('')) +', you are receiving this email because your project '+ (projectRecord.Name != null ? (projectRecord.Name) : ('')) + ' has a End Date of ' + projectRecord.pse__End_Date__c.day() + '/' + projectRecord.pse__End_Date__c.month() + '/' + projectRecord.pse__End_Date__c.year() + ' in PSA.<br><br>';
                   emailOverallBodyContent += 'Considering that 1 month has passed since the end date, and the project is still in Stage ' + (projectRecord.pse__Stage__c != null ? (projectRecord.pse__Stage__c) : ('')) + ', can you please review and: <br><br>';
                   emailOverallBodyContent += 'a) Move the project to Stage = Completed, if the project is now closed <br>';
                   emailOverallBodyContent += 'Or <br>';
                   emailOverallBodyContent += 'b) Update the end date of the project, if the project is still on going <br><br>';
                   emailOverallBodyContent += 'If the project is now completed, make sure you also untick the “Active” checkbox in PSA, under Project Attributes.<br><br>';
                   emailOverallBodyContent += 'Thanks for your attention to this request.<br><br>';
                   emailOverallBodyContent += 'If you have any question or require any support please contact RADDS PSA support team”';
                   emailOverallBodyContent += '</div>';
                   objWorkFlowEmail.content_1__c = emailOverallBodyContent;
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
    
    public void finish(Database.BatchableContext bc){
        //send error details through email
        if ((errorMessageList != null && errorMessageList.size() > 0) || test.isrunningtest()){
            String errorList = '';
            Integer counter = 0;
            for(String errMsg : errorMessageList){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, errMsg, 'PSA', 'Exception', 'ERROR', ':::BCH_PSA_ProjEndDateEmailToProjMngr:::objWorkFlowEmail Insert Exception', null));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), False);             
                errorList += ++counter+'. '+ 'Error'+'----> ';
                errorList += errMsg +'<br><br>';
            }
            String userName = System.UserInfo.getName();
            List<String> toAddr = psaRdsSettingsObj.Project_EndDate_Failed_Batch_Email_Ids__c.split(';');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddr);
            mail.setReplyTo(CON_PSA.IQVIA_NO_REPLY_SUPPORT_EMAIL);
            mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Batch execution error. (align project end date with project stage email to project manager) - '+System.today());
            String emailBody = 'Dear User, <br><br>';
            emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
            emailBody += '<b>Batch Name:</b> BCH_PSA_ProjEndDateEmailToProjMngr <br>';
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