public class BCH_PSA_Send_Mails_Annual_Srch_Strategy implements Database.Batchable<sObject>, Database.Stateful{
    @TestVisible List<String> errorMessageList = new List <String>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query =  'select Id, name, Notification_Date__c, Event_Actual_Date__c, Event_Due_Date__c,LR_Project_Overview__c,Event_Name__c,Project__c, Project__r.Service_Line__r.Name, Search_Strategy__c   from Project_Event__c where Search_Strategy__c!= null and Notification_Date__c = TODAY AND Project__c != null AND Project__r.Service_Line__c != null AND  Project__r.Service_Line__r.Name = \'Literature\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Project_Event__c> records) {
        Set<Id> annualSrchStrategySet = new Set<Id>();
        Set<Id> lrToProjectIdSet = new Set<Id>();
        for(Project_Event__c pje : records){
            if(pje.Project__c != null && pje.Project__r.Service_Line__r != null && pje.Project__r.Service_Line__r.Name == CON_PSA.LITERATURE){
                annualSrchStrategySet.add(pje.Search_Strategy__c);
                lrToProjectIdSet.add(pje.Project__c); 
            }
        }
        List<LR_Search_Strategy_Relationship__c> lrSrchStgyList = new SLT_LR_Search_Strategy_Relationship(false, false).getLRSSRelationshipDataForEmailBatch(annualSrchStrategySet, new Set<String>{'id', 'name','LR_Project_Overview_M__r.Name', 'LR_Project_Overview_M__r.Status__c', 'LR_Project_Overview_M__r.LR_Review_Period_Frequency__c', 'Search_Strategy_M__r.Name' , 'LR_Project_Overview_M__r.Countries__c', 'LR_Project_Overview_M__c', 'Account__r.Name', 'LR_Project_Overview_M__r.Product__r.Name', 'LR_Project_Overview_M__r.Proj_Code__c', 'Search_Strategy_M__r.Comments__c', 'Search_Strategy_M__r.Date_Annual_Search_Strategy_Due__c', 'Search_Strategy_M__c', 'product__r.Name', 'LR_Status__c', 'Project__c'});
        if(lrSrchStgyList.size() > 0){
            Set<Id> contactEmailIdSet = new Set<Id>();
            //Fetching all the active assignments of the projects related to the LR proj overview rec.
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(false,false).getActiveAssignmentsByProject
                (lrToProjectIdSet, new Set<String>{'Id', 'Name', 'pse__Project__c', 'pse__Status__c', 'Active__c','Closed_for_Unit_Entry__c','pse__Closed_for_Time_Entry__c', 'pse__Schedule__c', 'pse__Schedule__r.pse__End_Date__c','pse__Resource__c'});
            
            Map<Id, List<pse__Assignment__c>> projectIdToAssignmentMap = new Map<Id, List<pse__Assignment__c>>();
            for(pse__Assignment__c assignment: assignmentList){
                if(projectIdToAssignmentMap.containskey(assignment.pse__Project__c) && projectIdToAssignmentMap.get(assignment.pse__Project__c)!= null){
                    projectIdToAssignmentMap.get(assignment.pse__Project__c).add(assignment);
                }else{
                    projectIdToAssignmentMap.put(assignment.pse__Project__c,new List<pse__Assignment__c>{assignment});
                }
            }
            for(Id proj : projectIdToAssignmentMap.keySet()){
                List<pse__Assignment__c> assignmentListForProj = new List<pse__Assignment__c>();
                if(projectIdToAssignmentMap != null || !projectIdToAssignmentMap.isEmpty()){
                    if(projectIdToAssignmentMap.containsKey(proj) && projectIdToAssignmentMap.get(proj) != null){
                        assignmentListForProj = projectIdToAssignmentMap.get(proj);
                    }
                }
                if(assignmentListForProj.size()>0){
                    for(pse__Assignment__c assignment : assignmentListForProj){
                        contactEmailIdSet.add(assignment.pse__Resource__c);
                    }
                }
            }
            Map<Id,Contact> contactMap = new SLT_Contact().selectByContactId(contactEmailIdSet, new Set<String>{'Id', 'Name', 'Email'});
            List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
            for(LR_Search_Strategy_Relationship__c lSSR : lrSrchStgyList){
                String staticContent = '';
                Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
                objWorkFlowEmail.Email_Action__c = CON_PSA.LR_DLP_LBI_SRCH_STRGY_EMAIL_ACTION_VAL;
                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                Integer toEmailCounter = 1;
                String subjText = '';
                if( null != lSSR.LR_Project_Overview_M__c && null != lSSR.Account__r.Name &&  null != lSSR.LR_Project_Overview_M__r.Proj_Code__c){
                    subjText = 'Annual Search Strategy DUE DATE ALERT: '+lSSR.Account__r.Name+ ' - '+lSSR.LR_Project_Overview_M__r.Proj_Code__c+ ' - '+lssr.Search_Strategy_M__r.Name;
                    staticContent = '<div style="background-color=white;text-align=left;"><p style="font-size:13px;font-family:arial;">Dear Colleague(s),<br> This is to notify you that a literature project\'s  ' + lSSR.Account__r.Name + '-' +lSSR.product__r.Name+' - '+lSSR.LR_Project_Overview_M__r.Proj_Code__c+ ' search strategy revision (Date Annual Search Strategy Due) '+lssr.Search_Strategy_M__r.Date_Annual_Search_Strategy_Due__c+ ' is approaching. Please perform your task and update the PSA tracker: <br><br>';                      
                    staticContent += '<B> Status: </B>'+lssr.LR_Status__c+ '<br><br>';
                    staticContent += '<B> Client: </B>'+lSSR.Account__r.Name+ '<br><br>';
                    staticContent += '<B> Product: </B>'+lSSR.product__r.Name+ '<br><br>';
                    staticContent += '<B> Project Code: </B>'+lSSR.LR_Project_Overview_M__r.Proj_Code__c+ '<br><br>';
                    staticContent += '<B> Countries: </B>'+lssr.LR_Project_Overview_M__r.Countries__c+ '<br><br>';
                    staticContent += '<B> Comments (from search strategy): </B>'+lssr.Search_Strategy_M__r.Comments__c+ '<br><br>';
                    staticContent += '<B> Date Annual Search Strategy Due: </B>'+lssr.Search_Strategy_M__r.Date_Annual_Search_Strategy_Due__c+ '<br><br>';
                    staticContent += '<a href = ' + URL.getOrgDomainUrl().toExternalForm()+'/'+lssr.Search_Strategy_M__c+ '><B> Go to Event </B></a><br><br>';
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
                    List<pse__Assignment__c> rltdAssignmentList = new List<pse__Assignment__c>();
                    if(lSSR.Project__c != null && (projectIdToAssignmentMap != null || !projectIdToAssignmentMap.isEmpty())){
                        if(projectIdToAssignmentMap.containsKey(lSSR.Project__c) && projectIdToAssignmentMap.get(lSSR.Project__c) != null){
                            rltdAssignmentList = projectIdToAssignmentMap.get(lSSR.Project__c);
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
                                System.debug('To email '+con.Email+ ' con name '+con.Name);
                                objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', con.Email);
                                toEmailCounter++;
                            }
                        }else {
                            System.debug('err res greater than 50');
                            errorMessageList.add('Errors : ' + CON_PSA.ASSIGNMENTS_GRT_50 + ' for search strategy batch with LR - ' +lSSR.LR_Project_Overview_M__r.Name);
                            continue;
                        }
                    }
                    //Comments for test failuer
                    //test log history
                    //objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', 'ratna.com');
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
                mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Literature functionality Batch execution error. (Annual search strategy emails) - '+System.today());
                String emailBody = 'Dear User, <br><br>';
                emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
                emailBody += '<b>Batch Name:</b> BCH_PSA_Send_Mails_Annual_Srch_Strategy <br>';
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
