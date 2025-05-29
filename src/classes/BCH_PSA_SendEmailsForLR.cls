public class BCH_PSA_SendEmailsForLR implements Database.Batchable<sObject>, Database.Stateful{
    @TestVisible List<String> errorMessageList = new List <String>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query =  'select Id, name, Notification_Date__c, Event_Actual_Date__c, Event_Due_Date__c,LR_Project_Overview__c,Event_Name__c,Send_Missed_Due_Date_Noti_Date__c,Project__c, Project__r.Service_Line__r.Name   from Project_Event__c where LR_Project_Overview__c!= null and (Notification_Date__c = TODAY OR Send_Missed_Due_Date_Noti_Date__c = TODAY ) AND Project__c != null AND Project__r.Service_Line__c != null AND  Project__r.Service_Line__r.Name = \'Literature\' ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Project_Event__c> records) {
        Set<Id> lrOverviewSet = new Set<Id>();
        List<LR_Project_Overview__c> lrProjList = new List<LR_Project_Overview__c>();
        Set<Id> contactEmailIdSet = new Set<Id>();
        Set<Id> lrToProjectIdSet = new Set<Id>();        
        for(Project_Event__c pje : records){
            if(pje.Project__c != null && pje.Project__r.Service_Line__r != null && pje.Project__r.Service_Line__r.Name == CON_PSA.LITERATURE){
                lrOverviewSet.add(pje.LR_Project_Overview__c);
                lrToProjectIdSet.add(pje.Project__c);  
            }
            
        }
        //Fetching all the active assignments of the projects related to the LR proj overview rec.
        List<pse__Assignment__c> assignmentList = new SLT_Assignment(false,false).getActiveAssignmentsByProject
            (lrToProjectIdSet, new Set<String>{'Id', 'Name', 'pse__Project__c', 'pse__Status__c', 'Active__c','Closed_for_Unit_Entry__c','pse__Closed_for_Time_Entry__c', 'pse__Schedule__c', 'pse__Schedule__r.pse__End_Date__c','pse__Resource__c'});
        Map<Id, List<pse__Assignment__c>> projectIdToAssignmentMap = new Map<Id, List<pse__Assignment__c>>();
        for(pse__Assignment__c assignment: assignmentList){
            if(projectIdToAssignmentMap.containskey(assignment.pse__Project__c)){
                projectIdToAssignmentMap.get(assignment.pse__Project__c).add(assignment);
            }else{
                projectIdToAssignmentMap.put(assignment.pse__Project__c, new List<pse__Assignment__c>{assignment});
            }
        }
        for(Id proj : projectIdToAssignmentMap.keySet()){
            List<pse__Assignment__c> assignmentListForProj = new List<pse__Assignment__c>();
            if(projectIdToAssignmentMap != null && projectIdToAssignmentMap.containsKey(proj) && projectIdToAssignmentMap.get(proj) != null){
                    assignmentListForProj = projectIdToAssignmentMap.get(proj);
            }
            if(assignmentListForProj.size()>0){
                for(pse__Assignment__c assignment : assignmentListForProj){
                    contactEmailIdSet.add(assignment.pse__Resource__c);
                }
            }
        }
        Map<Id,Contact> contactMap = new SLT_Contact().selectByContactId(contactEmailIdSet, new Set<String>{'Id', 'Name', 'Email'});
        lrProjList = new SLT_LR_Project_Overview(false, false).getLRProjectOverviewFromLRID(lrOverviewSet , new Set<String>{'Id', 'Name', 'Status__c', 'Account__r.Name', 'Product__r.name','Project__c','Proj_Code__c'});
        List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
        Map<Id, LR_Project_Overview__c> pjeToRltdLROverviewMap = getPJEToLROverviewMap(records, lrProjList);
        for(Project_Event__c pje : records){
            LR_Project_Overview__c relatedLrRecord;
            if(pjeToRltdLROverviewMap.containsKey(pje.Id) && pjeToRltdLROverviewMap.get(pje.Id) != null){
               relatedLrRecord = pjeToRltdLROverviewMap.get(pje.Id);
            }
            if(relatedLrRecord != null){                            
                String staticContent = '';
                Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
                objWorkFlowEmail.Email_Action__c = CON_PSA.LR_DLP_LBI_SRCH_STRGY_EMAIL_ACTION_VAL;
                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                Integer toEmailCounter = 1;
                String subjText = '';
                if(pje.Notification_Date__c == System.today()){
                    if(relatedLrRecord != null && relatedLrRecord.Account__c != null  &&  relatedLrRecord.Project__c != null  && relatedLrRecord.Proj_Code__c != null){
                        if(pje.Event_Name__c == CON_PSA.LR_PROJECT_DLP_APPROACHING_EMAIL_30_DAYS || pje.Event_Name__c == CON_PSA.LR_PROJECT_DLP_APPROACHING_EMAIL_60_DAYS){
                            subjText = 'DLP DUE DATE ALERT: '+relatedLrRecord.Account__r.Name+ ' - '+relatedLrRecord.Proj_Code__c+ ' - '+relatedLrRecord.Name;
                            staticContent = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">Dear Colleague(s),<br> This is to notify you that a literature project\'s  ' + relatedLrRecord.Account__r.Name + '-' +relatedLrRecord.Product__r.name+' - '+relatedLrRecord.Proj_Code__c+ ' with datalock point '+relatedLrRecord.DLP_Enter_only_for_Aggregate_Reports__c+ ' is approaching. Please perform your task and update the PSA tracker: <br><br>';
                        }else if(pje.Event_Name__c == CON_PSA.LR_PROJECT_LBI_PERIOD_APPROACHING_EMAIL_07_DAYS){
                            subjText = 'LBI DUE DATE ALERT: '+relatedLrRecord.Account__r.Name+ ' - '+relatedLrRecord.Proj_Code__c+ ' - '+relatedLrRecord.Name;
                            staticContent = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">Dear Colleague(s),<br> This is to notify you that a literature project\'s  ' + relatedLrRecord.Account__r.Name + '-' +relatedLrRecord.Product__r.name+' - '+relatedLrRecord.Proj_Code__c+ ' with datalock point '+relatedLrRecord.LR_LBI_Period_Stop_Date__c+ ' is approaching. Please perform your task and update the PSA tracker: <br><br>';
                        }
                    }
                    staticContent += '<B> Status: </B>'+relatedLrRecord.Status__c+ '<br><br>';
                    staticContent += '<B> Client: </B>'+relatedLrRecord.Account__r.Name+ '<br><br>';
                    staticContent += '<B> Product: </B>'+relatedLrRecord.Product__r.name+ '<br><br>';
                    staticContent += '<B> Project Code: </B>'+relatedLrRecord.Proj_Code__c+ '<br><br>';
                    staticContent += '<B> Countries: </B>'+relatedLrRecord.Countries__c+ '<br><br>';
                    staticContent += '<B> LR Review Period Start Date: </B>'+relatedLrRecord.LR_Review_Period_Start_Date__c+ '<br><br>';
                    staticContent += '<B> LR Review Period Stop Date or DLP: </B>'+relatedLrRecord.LR_Review_Period_stop_Date__c+ '<br><br>';
                    staticContent += '<B> LR LBI Period Start Date: </B>'+relatedLrRecord.LR_LBI_Period_Start_Date__c+ '<br><br>';
                    staticContent += '<B> LR LBI Period Stop Date: </B>'+relatedLrRecord.LR_LBI_Period_Stop_Date__c+ '<br><br>';
                    staticContent += '<B> Date this LR Project Started: </B>'+relatedLrRecord.Date_this_LR_Project_Started__c+ '<br><br>';
                    staticContent += '<B> LR Database As per APEX LR Tracker: </B>'+relatedLrRecord.LR_Database__c+ '<br><br>';
                    staticContent += '<B> Comments: </B>'+relatedLrRecord.Comments__c+ '<br><br>';
                    staticContent += '<a href = ' + URL.getOrgDomainUrl().toExternalForm()+'/'+relatedLrRecord.Id+ '><B> Go to Event </B></a><br><br>';
                    staticContent += '<B> Please make sure you are logged into Literature Tracker before clicking this link. </B><br><br>';
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
                }else if(pje.Send_Missed_Due_Date_Noti_Date__c == System.today() && relatedLrRecord.Status__c != CON_PSA.LR_PROJECT_REVIEW_STATUS_INPROGRESS){
                    if( null != relatedLrRecord && null != relatedLrRecord.Account__c &&  null != relatedLrRecord.Project__c && null != relatedLrRecord.Proj_Code__c){
                        if(pje.Event_Name__c == CON_PSA.LR_PROJECT_DLP_APPROACHING_EMAIL_30_DAYS || pje.Event_Name__c == CON_PSA.LR_PROJECT_DLP_APPROACHING_EMAIL_60_DAYS){
                            subjText = ' DLP OVERDUE ALERT: '+relatedLrRecord.Account__r.Name+ ' - '+relatedLrRecord.Proj_Code__c+ ' - '+relatedLrRecord.Name; 
                            staticContent = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">Dear Colleague(s),<br> This is to notify you that a literature project\'s  ' + relatedLrRecord.Account__r.Name + '-' +relatedLrRecord.Product__r.name+' - '+relatedLrRecord.Proj_Code__c+ ' with datalock point '+relatedLrRecord.DLP_Enter_only_for_Aggregate_Reports__c+ ' is overdue. Please update the status to \'in-progress\' and perform your task and update the PSA tracker <br><br>';
                            staticContent += '<B> Status: </B>'+relatedLrRecord.Status__c+ '<br><br>';
                            staticContent += '<B> Client: </B>'+relatedLrRecord.Account__r.Name+ '<br><br>';
                            staticContent += '<B> Product: </B>'+relatedLrRecord.Product__r.name+ '<br><br>';
                            staticContent += '<B> Project Code: </B>'+relatedLrRecord.Proj_Code__c+ '<br><br>';
                            staticContent += '<B> Countries: </B>'+relatedLrRecord.Countries__c+ '<br><br>';
                            staticContent += '<B> DLP: </B>'+relatedLrRecord.DLP_Enter_only_for_Aggregate_Reports__c+ '<br><br>';
                            staticContent += '<B> Comments(from LR Project Overview): </B>'+relatedLrRecord.Comments__c+ '<br><br>';
                            staticContent += '<a href = ' + URL.getOrgDomainUrl().toExternalForm()+'/'+relatedLrRecord.Id+ '><B> Go to Event </B></a><br><br>';
                            staticContent += '<B> Please make sure you are logged into Literature Tracker before clicking this link. </B><br><br>';
                            staticContent += 'Thank you for your support,<br>';
                            staticContent += '<I>SARA Literature Center<I><br>';
                        }else if(pje.Event_Name__c == CON_PSA.LR_PROJECT_LBI_PERIOD_APPROACHING_EMAIL_07_DAYS){
                            subjText = 'LBI DLP DUE ALERT: '+relatedLrRecord.Account__r.Name+ ' - '+relatedLrRecord.Proj_Code__c+ ' - '+relatedLrRecord.Name;
                            staticContent = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">Dear Colleague(s),<br> This is to notify you that a literature project\'s  ' + relatedLrRecord.Account__r.Name + '-' +relatedLrRecord.Product__r.name+' - '+relatedLrRecord.Proj_Code__c+ ' with LBI period stop date '+relatedLrRecord.LR_LBI_Period_Stop_Date__c+ ' is due today. Please perform your task and update the PSA tracker: <br><br>';
                            staticContent += '<B> Status: </B>'+relatedLrRecord.Status__c+ '<br><br>';
                            staticContent += '<B> Client: </B>'+relatedLrRecord.Account__r.Name+ '<br><br>';
                            staticContent += '<B> Product: </B>'+relatedLrRecord.Product__r.name+ '<br><br>';
                            staticContent += '<B> Project Code: </B>'+relatedLrRecord.Proj_Code__c+ '<br><br>';
                            staticContent += '<B> Countries: </B>'+relatedLrRecord.Countries__c+ '<br><br>';
                            staticContent += '<B> LR Review Period Start Date: </B>'+relatedLrRecord.LR_Review_Period_Start_Date__c+ '<br><br>';
                            staticContent += '<B> LR Review Period Stop Date or DLP: </B>'+relatedLrRecord.LR_Review_Period_stop_Date__c+ '<br><br>';
                            staticContent += '<B> LR LBI Period Start Date: </B>'+relatedLrRecord.LR_LBI_Period_Start_Date__c+ '<br><br>';
                            staticContent += '<B> LR LBI Period Stop Date: </B>'+relatedLrRecord.LR_LBI_Period_Stop_Date__c+ '<br><br>';
                            staticContent += '<B> Date this LR Project Started: </B>'+relatedLrRecord.Date_this_LR_Project_Started__c+ '<br><br>';
                            staticContent += '<B> LR Database As per APEX LR Tracker: </B>'+relatedLrRecord.LR_Database__c+ '<br><br>';
                            staticContent += '<B> Comments: </B>'+relatedLrRecord.Comments__c+ '<br><br>';
                            staticContent += '<a href = ' + URL.getOrgDomainUrl().toExternalForm()+'/'+relatedLrRecord.Id+ '><B> Go to Event </B></a><br><br>';
                            staticContent += '<B> Please make sure you are logged into Literature Tracker before clicking this link. </B><br><br>';
                            staticContent += 'Thank you for your support,<br>';
                            staticContent += '<I>SARA Literature Center<I><br>';
                        }
                    }
                    
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
                }
                List<pse__Assignment__c> rltdAssignmentList = new List<pse__Assignment__c>();
                if(pje.Project__c != null && (projectIdToAssignmentMap != null || !projectIdToAssignmentMap.isEmpty())){
                    if(projectIdToAssignmentMap.containsKey(pje.Project__c) && projectIdToAssignmentMap.get(pje.Project__c) != null){
                        rltdAssignmentList = projectIdToAssignmentMap.get(pje.Project__c);
                    }
                }
                if(rltdAssignmentList.size()>0){
                    Set<Id> resourceIds = new Set<Id>();
                    for(pse__Assignment__c assignment : rltdAssignmentList){
                        resourceIds.add(assignment.pse__Resource__c);
                    }
                    if(resourceIds.size() <= 50){
                        for(Id resId : resourceIds){
                        Contact con = contactMap.get(resId);
                        objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', con.Email);
                        toEmailCounter++;
                    	}
                    }else {
                        errorMessageList.add('Errors : ' + CON_PSA.ASSIGNMENTS_GRT_50 + ' for 1' +relatedLrRecord.Name);
                        continue;
                    }
                }
                //Comments are for case Failuer
                //test log history
                //objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', 'abcd.com');
                //toEmailCounter++;
                
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
    
    private Map<Id, LR_Project_Overview__c> getPJEToLROverviewMap(List<Project_Event__c> records, List<LR_Project_Overview__c> lrProjList){
        Map<Id, LR_Project_Overview__c> pJEToLROverviewMap = new Map<Id, LR_Project_Overview__c>();
        Map<Id, LR_Project_Overview__c> idToLROverviewMap = new Map<Id, LR_Project_Overview__c>(lrProjList);
        for(Project_Event__c pje : records){
            if(idToLROverviewMap.containsKey(pje.LR_Project_Overview__c)){
                pJEToLROverviewMap.put(pje.Id, idToLROverviewMap.get(pje.LR_Project_Overview__c));
            }
        }
        return pJEToLROverviewMap;
    }

    public void finish(Database.BatchableContext BContext){
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
                mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Literature functionality Batch execution error. (LR DLP/LBI emails) - '+System.today());
                String emailBody = 'Dear User, <br><br>';
                emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
                emailBody += '<b>Batch Name:</b> BCH_PSA_SendEmailsForLR <br>';
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
