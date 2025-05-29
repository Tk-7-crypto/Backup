/* IQVIAPSA-5583: Batch is used to trigger email(Hourly) to assignment resources with specific criteria*/

public class BCH_PSA_Send_Mail_Updtd_LR_Metrics implements Database.Batchable<sObject>, Database.Stateful{
    @TestVisible List<String> errorMessageList = new List <String>();
    public Database.QueryLocator start(Database.BatchableContext bContext){
        String query = 'Select Id, Status__c,Name,Proj_Code__c,Project__r.pse__Parent_Project__c, Project__r.Project_Email__c, Project__r.Service_Line__r.Name,  Date_this_LR_Project_Completed__c, Project__c, Account__r.Name, Updated_Fields_for_Metrics_Email__c from LR_Project_Overview__c where To_be_tracked_by_batch__c = true AND Status__c =\'Completed\' AND Project__r.Service_Line__c != null AND  Project__r.Service_Line__r.Name = \'Literature\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bContext, List<LR_Project_Overview__c> records) {
        Set<Id> parentLRIdSet = new Set<Id>();
        Set<Id> lRIdSet = new Set<Id>();
        Set<Id> lrToProjectIdSet = new Set<Id>();
        Set<Id> wrkflwToRetrieveLRSet = new Set<Id>();
        Set<Id> lrToUpdateIdSet = new Set<Id>();
        List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
    	  Map<Id, LR_Project_Overview__c> lrIdToLrMap = new Map<Id, LR_Project_Overview__c>();
        List<LR_Project_Overview__c> lrRecToUpdtList = new List<LR_Project_Overview__c>();
        List<Workflow_Email_Record__c> successLineItems = new List<Workflow_Email_Record__c>();
        Set<id> parentProjectIdSet = new Set<id>();
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        Map<String,Set<String>> parentProjectToEmailListMap = new Map<String,Set<String>>();
        String whereClause = 'pse__Project__r.pse__Parent_Project__c  IN :parentProjectIdSet AND Active__c = true AND ((pse__Project__r.Service_Line__r.Name =\'' +CON_PSA.LITERATURE+ '\' AND pse__Role__c =\'' +CON_PSA.SRVC_LINE_LEAD_ROLE + '\' AND Sub_role__c =\'' +CON_PSA.LIT_SARA_LEAD_SUB_ROLE + '\' ) OR (pse__Project__r.Service_Line__r.Name =\'' +CON_PSA.LITERATURE+ '\' AND pse__Role__c =\'' + CON_PSA.Specialist_Junior_Role+ '\'  AND Sub_role__c =\'' + CON_PSA.LIT_SARA_SUB_ROLE+ '\' ) OR (pse__Project__r.Service_Line__r.Name = \'' +CON_PSA.LITERATURE+ '\' AND pse__Role__c =  \'' +CON_PSA.Specialist_Senior_Role+ '\' AND Sub_role__c =\'' + CON_PSA.LIT_SARA_SUB_ROLE+ '\' ) OR (pse__Project__r.Service_Line__r.Name =\'' +  CON_PSA.PV_SOLN_SRVC_NAME+ '\' AND pse__Role__c =\'' +  CON_PSA.SRVC_LINE_LEAD_ROLE+  '\'  AND Sub_role__c =\'' + CON_PSA.LIT_PVS_LEAD+ '\'))AND RecordType.DeveloperName = \'RDS_Assignment\'';
        Map<Id, List<LR_Project_Overview__History>> lrProjIdToRltdHstryListMap = new Map<Id, List<LR_Project_Overview__History>>();
        for(LR_Project_Overview__c rec : records){
            if(rec.Status__c == CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED && rec.Date_this_LR_Project_Completed__c <= System.today() && System.today() <= (rec.Date_this_LR_Project_Completed__c).addMonths(1) && rec.Project__r.Service_Line__r != null && rec.Project__r.Service_Line__r.Name == CON_PSA.LITERATURE){
                lrIdToLrMap.put(rec.Id, rec);
                lrToProjectIdSet.add(rec.Project__c);
                lRIdSet.add(rec.Id);
            }
            if(!parentProjectIdSet.contains(rec.Project__r.pse__Parent_Project__c)){
                parentProjectIdSet.add(rec.Project__r.pse__Parent_Project__c);
            }
        }
        
        List<LR_Project_Overview__History> relatedHistoryRecordsList = new SLT_LR_Project_Overview_History(false,false).getHistoryRecByParentLRId(lRIdSet, new Set<String>{'Id','CreatedDate','Field','NewValue','OldValue','ParentId'});
        Map<String, LR_Project_Overview__History> fieldToHistoryRecMap = new Map<String, LR_Project_Overview__History>();
        LR_Project_Overview__History sameFieldRec = new LR_Project_Overview__History();
        
        for(LR_Project_Overview__History lrOverviewHstry : relatedHistoryRecordsList){
            if(fieldToHistoryRecMap != null && fieldToHistoryRecMap.containskey(lrOverviewHstry.Field +','+lrOverviewHstry.ParentId)){                
                sameFieldRec = fieldToHistoryRecMap.get(lrOverviewHstry.Field +','+lrOverviewHstry.ParentId);
                if(sameFieldRec.CreatedDate < lrOverviewHstry.CreatedDate && sameFieldRec.ParentId == lrOverviewHstry.ParentId){
                    fieldToHistoryRecMap.remove(sameFieldRec.Field + ',' + sameFieldRec.ParentId);
                    fieldToHistoryRecMap.put((lrOverviewHstry.Field + ',' +lrOverviewHstry.ParentId), lrOverviewHstry);
                }
            }else{
                fieldToHistoryRecMap.put((lrOverviewHstry.Field + ',' +lrOverviewHstry.ParentId), lrOverviewHstry); 
            }
        }
        
        for(LR_Project_Overview__History lrOverviewHstry : fieldToHistoryRecMap.values()){
            parentLRIdSet.add(lrOverviewHstry.ParentId);
            if(lrProjIdToRltdHstryListMap.containskey(lrOverviewHstry.ParentId)){
                lrProjIdToRltdHstryListMap.get(lrOverviewHstry.ParentId).add(lrOverviewHstry);
            }else{
                lrProjIdToRltdHstryListMap.put(lrOverviewHstry.ParentId, new List<LR_Project_Overview__History>{lrOverviewHstry});
            }
        }
        
        if(parentProjectIdSet != null && parentProjectIdSet.size() > 0){
            assignmentList = new SLT_Assignment(false,false).getActiveAssignmentsByProjectLitratureANDPvSolution
                (parentProjectIdSet, whereClause, new Set<String>{'Id', 'pse__Project__r.Project_Email__c','pse__Project__r.pse__Parent_Project__r.Project_Code__c','pse__Project__r.pse__Account__r.Name','pse__Project__r.pse__Parent_Project__c','pse__Project__r.Service_Line__r.Name', 'pse__Project__c','pse__Project__r.Name', 'Active__c','pse__Resource__c','pse__Resource__r.Email'});
        }
        
        if(assignmentList != null && assignmentList.size() > 0){
            for(pse__Assignment__c assignment : assignmentList){
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

        for(Id lrProjOverviewId : lrIdToLrMap.keySet()){
            String subjText = '';
            String staticContent = '';
            Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
            objWorkFlowEmail.Email_Action__c = CON_PSA.LR_DLP_LBI_SRCH_STRGY_EMAIL_ACTION_VAL;
            objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
            Integer toEmailCounter = 1;
            LR_Project_Overview__c lrProjVal = lrIdToLrMap.get(lrProjOverviewId);
            List<LR_Project_Overview__History> rltdLRHstryList = new List<LR_Project_Overview__History>();
            
            if(lrProjIdToRltdHstryListMap != null || !lrProjIdToRltdHstryListMap.isEmpty()){
                if(lrProjIdToRltdHstryListMap.containsKey(lrProjOverviewId) && lrProjIdToRltdHstryListMap.get(lrProjOverviewId) != null){
                    rltdLRHstryList = lrProjIdToRltdHstryListMap.get(lrProjOverviewId);
                }
            }
            
            if(parentProjectToEmailListMap.get(lrProjVal.Project__r.pse__Parent_Project__c) != null && parentProjectToEmailListMap.get(lrProjVal.Project__r.pse__Parent_Project__c).size() < 50){
                for(String resourceEmail : parentProjectToEmailListMap.get(lrProjVal.Project__r.pse__Parent_Project__c)){
                    objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', resourceEmail);
                    toEmailCounter++;
                } 
            }else{
                errorMessageList.add('Errors : ' + CON_PSA.ASSIGNMENTS_GRT_50 + ' for ' +lrProjVal.Name);
                continue;
            }
            String type='LR_Project_Overview__c';
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType lrSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = lrSchema.getDescribe().fields.getMap();
            objWorkFlowEmail.Related_To_Object_Id__c = lrProjOverviewId;
            PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();
            Date timePeriodStartDt = ((lrProjVal.Date_this_LR_Project_Completed__c).addMonths(-1)).toStartOfMonth();
            Date timePeriodEndDt = (timePeriodStartDt.addMonths(1)).addDays(-1);
            subjText = 'Updates to Literature metrics entered for '+ lrProjVal.Account__r.Name + ' for the period '+timePeriodStartDt + ' to ' +timePeriodEndDt;
            staticContent = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">Dear Colleague,<br> You are receiving this email because you are part of the team which has had an update to the literature metrics entered for the period '+timePeriodStartDt + ' to ' +timePeriodEndDt+' <br><br>';
            staticContent += ' LR Event :'+lrProjVal.Name+ ' <br><br>';
            staticContent += '<B> Client: </B>'+lrProjVal.Account__r.Name+ '<br><br>';
            staticContent += ' Project Code :'+lrProjVal.Proj_Code__c+ ' <br><br>';
            if(null != rltdLRHstryList && rltdLRHstryList.size()>0){
                for(LR_Project_Overview__History hstryRec : rltdLRHstryList){
                    List<String> fieldList = new List<String>();
                    if(lrProjVal.Updated_Fields_for_Metrics_Email__c != null){
                        fieldList = lrProjVal.Updated_Fields_for_Metrics_Email__c.split(';');
                    }
                    if(hstryRec.Field == 'Date_this_LR_Project_Started__c' && fieldList.contains('Date_this_LR_Project_Started__c')){
                        
                        staticContent += fieldMap.get('Date_this_LR_Project_Started__c').getDescribe().getLabel()+' : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Date_this_LR_Project_Completed__c' && fieldList.contains('Date_this_LR_Project_Completed__c')){
                        
                        staticContent += fieldMap.get('Date_this_LR_Project_Completed__c').getDescribe().getLabel()+' : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }                        
                    if(hstryRec.Field == 'Abstracts_Reviewed__c' && fieldList.contains('Abstracts_Reviewed__c')){
                        
                        staticContent += fieldMap.get('Abstracts_Reviewed__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Full_Text_Articles_ordered__c' && fieldList.contains('Full_Text_Articles_ordered__c')){
                        
                        staticContent += fieldMap.get('Full_Text_Articles_ordered__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Countries_Searched__c' && fieldList.contains('Countries_Searched__c')){
                        
                        staticContent += fieldMap.get('Countries_Searched__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Journals_Screened_Reviewed__c' && fieldList.contains('Journals_Screened_Reviewed__c')){
                        
                        staticContent += fieldMap.get('Journals_Screened_Reviewed__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'of_ICSRs_Sent_to_Safety_Operation__c' && fieldList.contains('of_ICSRs_Sent_to_Safety_Operation__c')){
                        
                        staticContent += fieldMap.get('of_ICSRs_Sent_to_Safety_Operation__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'of_summaries_completed_for_AR_Report__c' && fieldList.contains('of_summaries_completed_for_AR_Report__c')){
                        
                        staticContent += fieldMap.get('of_summaries_completed_for_AR_Report__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'of_Citations_Identified_for_Signaling__c' && fieldList.contains('of_Citations_Identified_for_Signaling__c')){
                        
                        staticContent += fieldMap.get('of_Citations_Identified_for_Signaling__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Translation_Vendor__c' && fieldList.contains('Translation_Vendor__c')){
                        
                        staticContent += fieldMap.get('Translation_Vendor__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Translation_PO__c' && fieldList.contains('Translation_PO__c')){
                        
                        staticContent += fieldMap.get('Translation_PO__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Other_Translation_Vendor_Specify__c' && fieldList.contains('Other_Translation_Vendor_Specify__c')){
                        
                        staticContent += fieldMap.get('Other_Translation_Vendor_Specify__c').getDescribe().getLabel()+'  : This field has been edited.<br><br>' ;
                    }
                    if(hstryRec.Field == 'of_FTA_Translations_Ordered__c' && fieldList.contains('of_FTA_Translations_Ordered__c')){
                        
                        staticContent += fieldMap.get('of_FTA_Translations_Ordered__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Total_Cost_of_all_FTAs_ordered__c' && fieldList.contains('Total_Cost_of_all_FTAs_ordered__c')){
                        
                        staticContent += fieldMap.get('Total_Cost_of_all_FTAs_ordered__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Full_Text_Articles_Reviewed__c' && fieldList.contains('Full_Text_Articles_Reviewed__c')){
                        
                        staticContent += fieldMap.get('Full_Text_Articles_Reviewed__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                    if(hstryRec.Field == 'Total_Cost_of_all_Translations_Ordered__c' && fieldList.contains('Total_Cost_of_all_Translations_Ordered__c')){
                        
                        staticContent += fieldMap.get('Total_Cost_of_all_Translations_Ordered__c').getDescribe().getLabel()+'  : New value: '+hstryRec.NewValue+' Old value: '+hstryRec.OldValue+'<br><br>' ;
                    }
                }
            }
            staticContent += 'Please use the below link to view these metrics within Spotfire: <br><br>';
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
        if(workflowEmailRecList.size() > 0){                
            Database.SaveResult[] results = Database.insert(workflowEmailRecList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        errorMessageList.add('Errors : ' + results[i].getErrors()[0].getMessage());
                    }else if (results[i].isSuccess()){
                        wrkflwToRetrieveLRSet.add(results[i].getId());
                    }
                }
            }
            for (Workflow_Email_Record__c  li : workflowEmailRecList) {
                if (wrkflwToRetrieveLRSet.contains(li.Id)) {
                    successLineItems.add(li);
                }
            }
        }
        for(Workflow_Email_Record__c wrf : successLineItems){
            lrToUpdateIdSet.add(wrf.Related_To_Object_Id__c);  
        }
        for(Id lrIdCheck : lrToUpdateIdSet){
            if(lrIdToLrMap.get(lrIdCheck) != null){
                LR_Project_Overview__c newLr = new LR_Project_Overview__c();
                newLr = lrIdToLrMap.get(lrIdCheck);
                newLr.To_be_tracked_by_batch__c = false;
                newLr.Updated_Fields_for_Metrics_Email__c = null;
                lrRecToUpdtList.add(newLr);
            }
        }
        
        if(lrRecToUpdtList.size()>0){
            UTL_ExecutionControl.stopTriggerExecution = TRUE;
            Database.SaveResult[] results = Database.update(lrRecToUpdtList, false);
            UTL_ExecutionControl.stopTriggerExecution = FALSE;
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
                mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Literature functionality Batch execution error. (Updated LR Metrics Emails) - '+System.today());
                String emailBody = 'Dear User, <br><br>';
                emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
                emailBody += '<b>Batch Name:</b> BCH_PSA_Send_Mail_For_Updtd_LR_Metrics <br>';
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