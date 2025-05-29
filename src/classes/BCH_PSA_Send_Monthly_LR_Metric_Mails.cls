/* IQVIAPSA-5583: Batch is used to trigger email(Monthly) to assignment resources with specific criteria*/

public class BCH_PSA_Send_Monthly_LR_Metric_Mails implements Database.Batchable<sObject>, Database.Stateful{
    @TestVisible List<String> errorMessageList = new List <String>();
    public Set<String> processedProjSet = new Set<String>(); 
    public Database.QueryLocator start(Database.BatchableContext bContext){
        Date startOfPrevMonth = Date.today().addMonths(-1).toStartOfMonth();
        Date endMonth = (startOfPrevMonth.addMonths(1)).addDays(-1);
        String endMonthStr = DateTime.newInstance(endMonth.year(),endMonth.month(),endMonth.day()).format('yyyy-MM-dd');
        String query =  'select Id, name, Project__c,Account__r.Name,Project__r.pse__Parent_Project__c, Project__r.Project_Email__c, Project__r.Service_Line__r.Name from LR_Project_Overview__c where Status__c = \'' +CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED + '\' And (Date_this_LR_Project_Completed__c >= :startOfPrevMonth and Date_this_LR_Project_Completed__c <= ' + endMonthStr + ') AND Project__c != null AND Project__r.Service_Line__c != null AND  Project__r.Service_Line__r.Name = \'Literature\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bC, List<LR_Project_Overview__c> records) {
        String subjText = '';
        String staticContent = '';
        String accountName = '';
        String projectParentCode = '';
        Date startOfPrevMonth = Date.today().addMonths(-1).toStartOfMonth();
        Date endMonth = (startOfPrevMonth.addMonths(1)).addDays(-1);
        Set<id> parentProjectIdSet = new Set<id>();
        List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        Map<String,Set<String>> parentProjectToEmailListMap = new Map<String,Set<String>>();
        Map<String,pse__Assignment__c> parentProjectIdToAssignmentMap = new Map<String,pse__Assignment__c>();
        String whereclause = 'pse__Project__r.pse__Parent_Project__c  IN :parentProjectIdSet AND Active__c = true AND ((pse__Project__r.Service_Line__r.Name =\'' +CON_PSA.LITERATURE+ '\' AND pse__Role__c =\'' +CON_PSA.SRVC_LINE_LEAD_ROLE + '\' AND Sub_role__c =\'' +CON_PSA.LIT_SARA_LEAD_SUB_ROLE+ '\' ) OR (pse__Project__r.Service_Line__r.Name =\'' +CON_PSA.LITERATURE+ '\' AND pse__Role__c =\'' + CON_PSA.Specialist_Junior_Role+ '\'  AND Sub_role__c =\'' + CON_PSA.LIT_SARA_SUB_ROLE+ '\' ) OR (pse__Project__r.Service_Line__r.Name = \'' +CON_PSA.LITERATURE+ '\' AND pse__Role__c =  \'' +CON_PSA.Specialist_Senior_Role+ '\' AND Sub_role__c =\'' + CON_PSA.LIT_SARA_SUB_ROLE+ '\' ) OR (pse__Project__r.Service_Line__r.Name =\'' +  CON_PSA.PV_SOLN_SRVC_NAME+ '\' AND pse__Role__c =\'' +  CON_PSA.SRVC_LINE_LEAD_ROLE+ '\'))AND RecordType.DeveloperName = \'RDS_Assignment\'';
        for(LR_Project_Overview__c lrOverview : records){
            if(!processedProjSet.contains(lrOverview.Project__r.pse__Parent_Project__c)){
                parentProjectIdSet.add(lrOverview.Project__r.pse__Parent_Project__c);
                processedProjSet.add(lrOverview.Project__r.pse__Parent_Project__c);
            }
        }
        if(parentProjectIdSet != null && parentProjectIdSet.size() > 0){
            assignmentList = new SLT_Assignment(false,false).getActiveAssignmentsByProjectLitratureANDPvSolution
                (parentProjectIdSet, whereclause, new Set<String>{'Id', 'pse__Project__r.Project_Email__c','pse__Project__r.pse__Parent_Project__r.Project_Code__c','pse__Project__r.pse__Account__r.Name','pse__Project__r.pse__Parent_Project__c','pse__Project__r.Service_Line__r.Name', 'pse__Project__c','pse__Project__r.Name', 'Active__c','pse__Resource__c','pse__Resource__r.Email'});
        }
        if(assignmentList != null && assignmentList.size() > 0){
            for(pse__Assignment__c assignment : assignmentList){
                if(!parentProjectIdToAssignmentMap.containsKey(assignment.pse__Project__r.pse__Parent_Project__c)){
                    parentProjectIdToAssignmentMap.put(assignment.pse__Project__r.pse__Parent_Project__c, assignment );
                }
                if(parentProjectToEmailListMap.containsKey(assignment.pse__Project__r.pse__Parent_Project__c)){
                    parentProjectToEmailListMap.get(assignment.pse__Project__r.pse__Parent_Project__c).add(assignment.pse__Resource__r.Email);
                    if(assignment.pse__Project__r.Service_Line__r.Name == CON_PSA.LITERATURE && assignment.pse__Project__r.Project_Email__c != null){
                        parentProjectToEmailListMap.get(assignment.pse__Project__r.pse__Parent_Project__c).add(assignment.pse__Project__r.Project_Email__c);
                    }
                }else{
                    parentProjectToEmailListMap.put(assignment.pse__Project__r.pse__Parent_Project__c, new Set<String>{assignment.pse__Resource__r.Email});
                    if(assignment.pse__Project__r.Service_Line__r.Name == CON_PSA.LITERATURE && assignment.pse__Project__r.Project_Email__c != null){
                        parentProjectToEmailListMap.get(assignment.pse__Project__r.pse__Parent_Project__c).add(assignment.pse__Project__r.Project_Email__c);
                    }
                }
            }
        }
        if(parentProjectToEmailListMap.size()>0){
            for(String parentProjectId : parentProjectToEmailListMap.keySet()){
                Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
                objWorkFlowEmail.Email_Action__c = CON_PSA.LR_DLP_LBI_SRCH_STRGY_EMAIL_ACTION_VAL;
                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                Integer toEmailCounter = 1;
                if(parentProjectToEmailListMap.get(parentProjectId).size() < 50){
                    for(String resourceEmail : parentProjectToEmailListMap.get(parentProjectId)){
                        objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', resourceEmail);
                        toEmailCounter++;
                    } 
                }else{
                    errorMessageList.add('Errors : ' + CON_PSA.ASSIGNMENTS_GRT_50 + ' for project ' +parentProjectIdToAssignmentMap.get(parentProjectId) != null ? parentProjectIdToAssignmentMap.get(parentProjectId).pse__Project__r.Name:'');
                }
                PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();
                if(parentProjectIdToAssignmentMap.containsKey(parentProjectId) 
                   && parentProjectIdToAssignmentMap.get(parentProjectId) != null 
                   && parentProjectIdToAssignmentMap.get(parentProjectId).pse__Project__r.pse__Account__r.Name != null)
                {
                    accountName = parentProjectIdToAssignmentMap.get(parentProjectId).pse__Project__r.pse__Account__r.Name; 
                }
                if(parentProjectIdToAssignmentMap.containsKey(parentProjectId) 
                   &&  parentProjectIdToAssignmentMap.get(parentProjectId) != null
                   && parentProjectIdToAssignmentMap.get(parentProjectId).pse__Project__r.pse__Parent_Project__r.Project_Code__c != null)
                {
                    projectParentCode = parentProjectIdToAssignmentMap.get(parentProjectId).pse__Project__r.pse__Parent_Project__r.Project_Code__c;
                    
                }
                subjText = 'Literature metrics entered for '+accountName+' - '+projectParentCode+' for the period '+startOfPrevMonth+ ' to '+endMonth;
                staticContent = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">Dear Colleague,<br> You are receiving this email because you are part of the team which has had literature metrics entered within the last month. <br><br>';
                staticContent += ' Please use the below link to view these metrics within Spotfire: <br><br>';
                staticContent += '<a href = ' + rdsSettings.Spotfire_link_for_LR_Metrics__c+ '><B> Spotfire Metrics Report link </B></a><br><br>';
                staticContent += 'Thank you for your support,<br>';
                staticContent += '<I>SARA Literature Center<I><br>';
                objWorkFlowEmail.Email_Subject__c = subjText;
                Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_1__c.getLength();
                Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_2__c.getLength();
                if(staticContent.length() < content1FieldLength) {
                    objWorkFlowEmail.content_1__c = staticContent;
                } else {
                    objWorkFlowEmail.content_1__c = staticContent.substring(0, content1FieldLength-1);
                    if(staticContent.length() < content1FieldLength+content2FieldLength-2 ) {
                        objWorkFlowEmail.content_2__c = staticContent.substring(content1FieldLength-1, staticContent.length());
                    } else {
                        objWorkFlowEmail.content_2__c = staticContent.substring(content1FieldLength-1, content1FieldLength+content2FieldLength-2);
                    }
                }
                workflowEmailRecList.add(objWorkFlowEmail);
            }
        }
        
        if(workflowEmailRecList.size() > 0){
            Database.SaveResult[] results = Database.insert(workflowEmailRecList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        errorMessageList.add('Errors : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext bContext){
        String errorList = '';
        Integer counter = 0;
        if (errorMessageList.size() > 0 || Test.isRunningTest()){
            for(String errMsg : errorMessageList){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, errMsg, 'PSA', 'Exception', 'ERROR', ':::BCH_PSA_SendEmailsForLR:::objWorkFlowEmail Insert Exception', null));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), False);             
                errorList += ++counter+'. '+ 'Error'+'----> ';
                errorList += errMsg+'<br><br>  ';
            }
            
            PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();
            if(rdsSettings.LR_failed_batches_email_ids__c != null){                    
                String userName = System.UserInfo.getName();
                List<String> toAddr = rdsSettings.LR_failed_batches_email_ids__c.split(';');
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddr);
                mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Literature functionality Batch execution error. (LR Monthly Metrics Emails) - '+System.today());
                String emailBody = 'Dear User, <br><br>';
                emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
                emailBody += '<b>Batch Name:</b> BCH_PSA_Send_Monthly_LR_Metric_Mails <br>';
                emailBody += '<b>Time of execution:</b> '+ System.now()+ '<br>';
                emailBody += '<b>Execution user:</b> '+userName+'<br>';
                emailBody += '<b>Completion status:</b> Failed <br>';
                emailBody += '<b>Error Description:</b> '+ errorList;
                emailBody += 'Thank you.';
                mail.setHtmlBody(emailBody);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }  
        }
        
    }   
}