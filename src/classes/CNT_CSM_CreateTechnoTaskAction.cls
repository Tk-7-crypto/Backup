public class CNT_CSM_CreateTechnoTaskAction {

    @AuraEnabled
    public static List<SObject> getCaseRecord(String recordId){
        List<SObject> objects = new List<SObject>();  
            objects = new SLT_Case().selectById(new Set<Id> { recordId });
        return objects;
    }
    
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getCaseTechnoTaskList(String recordId,String TaskMilestone){
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        Schema.DescribeFieldResult F = Case.CaseTaskAction__c.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        List<CaseMilestone> cms = new List<CaseMilestone>();
        Map<String,String> ms = new Map<String,String>();
        Map<String,String> msComp = new Map<String,String>();
        List<String> milestoneNames = new List<String>{CON_CSM.S_COMMUNICATION_UPD,CON_CSM.S_RCA, CON_CSM.S_PROBLEM_RESO,CON_CSM.S_RESOLUTION_PLAN,CON_CSM.S_MS_P_T3_RP};
        cms = [select Id, MilestoneType.Name,completionDate,IsCompleted,Case.TaskMilestone__c from CaseMilestone cm where caseId =:recordId and cm.MilestoneType.Name in :milestoneNames];
        for(CaseMilestone cm : cms){
            if(!cm.IsCompleted && cm.CompletionDate == null ){
                ms.put(cm.MilestoneType.Name,cm.Case.TaskMilestone__c);    
            }else if(cm.IsCompleted){
                msComp.put(cm.MilestoneType.Name,cm.Case.TaskMilestone__c);  
            }
        }
        for (Schema.PicklistEntry pf : entries) {
            if(ms != null && !ms.isEmpty() && ms.containsKey(CON_CSM.S_COMMUNICATION_UPD) && CON_CSM.S_CASE_UPD_PRD == pf.value){
                options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));
            }else if(ms != null && !ms.isEmpty() && (ms.containsKey(CON_CSM.S_PROBLEM_RESO) || ms.containsKey(CON_CSM.S_RESOLUTION_PLAN)) && CON_CSM.S_RESOLUTION_PLAN_PROVID == pf.value){
                options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));
            }else if(ms != null && !ms.isEmpty() && ms.containsKey(CON_CSM.S_RCA) && CON_CSM.S_RCA_DELIVERED == pf.value){
                options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));  
            }else if(ms != null && !ms.isEmpty() && ms.containsKey(CON_CSM.S_MS_P_T3_RP) && CON_CSM.S_TS_PP_T3 == pf.value){
                options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));  
            }else if(CON_CSM.S_RCA_REQ == pf.value &&  ((ms != null && !ms.isEmpty() && ms.containsKey(CON_CSM.S_RCA)) || (msComp != null && !msComp.isEmpty() && msComp.containsKey(CON_CSM.S_RCA)))) {
            
            }else if(CON_CSM.S_RCA_REQ == pf.value) {
                options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));
            }else if(CON_CSM.S_TS_IR_T3 == pf.value && TaskMilestone != null && TaskMilestone.contains('T3') &&
                    !((ms != null && !ms.isEmpty() && ms.containsKey(CON_CSM.S_MS_P_T3_RP)) || (msComp != null && !msComp.isEmpty() && msComp.containsKey(CON_CSM.S_MS_P_T3_RP)))) {
                options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));
            }
            
        } 
        
        return options;
    }
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getCasePostUserQueueMembers(String caseId,String queue,String firstEscById){
        Set<Id> users = new Set<Id>();
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        List<Queue_User_Relationship__c> userList = null;
        if(queue.contains('T1') || queue.contains('L1')){
            userList = Database.query('SELECT Name, User__c,User__r.Name  FROM Queue_User_Relationship__c WHERE ((Name = :queue AND QueueManager__c = true) OR User__c = :firstEscById) AND Type__c  =\'User\'');
        }else{
            userList = Database.query('SELECT Name, User__c,User__r.Name  FROM Queue_User_Relationship__c WHERE ((Name = :queue AND QueueManager__c = true AND TECH_QueueUser__r.Tier__c =\'Tier 1\' ) OR User__c = :firstEscById) AND Type__c  =\'User\'');
        }
        for(Queue_User_Relationship__c q : userList){
            if(!users.contains(q.User__c)){
                options.add(new EXT_CSM_CheckboxDetails(q.User__c, q.User__r.Name,true));
                users.add(q.User__c);    
            }
        }
        return options;
    }
    @AuraEnabled
    public static void saveTasktoCreate(sObject updateObject,String recordId, String selectTask){
        DateTime completionDate = System.now();
        List<Id> technoCaseId = new List<Id>();
        Case updCase =  (case)updateObject;
        technoCaseId.add(updCase.Id);
        if(selectTask != null){
            updCase.CaseTaskAction__c = selectTask;
        }
        if(updCase.TaskMilestone__c != null && !updCase.TaskMilestone__c.contains(selectTask)){
            updCase.TaskMilestone__c += ';' + selectTask;
        }else if(updCase.TaskMilestone__c == null){
            updCase.TaskMilestone__c = selectTask;
        }
        if(CON_CSM.S_RCA_REQ.equalsIgnoreCase(selectTask) && CON_CSM.S_RESOLVED_WITH_C.equalsIgnoreCase(updCase.Status)){
            updCase.SubStatus__c = CON_CSM.S_RCA;
        }else if(CON_CSM.S_RCA_DELIVERED.equalsIgnoreCase(selectTask) && CON_CSM.S_RESOLVED_WITH_C.equalsIgnoreCase(updCase.Status)){
            updCase.SubStatus__c = null;
        }
        try{
                update updCase;
                if(CON_CSM.S_RCA_DELIVERED.equalsIgnoreCase(selectTask)){
                    DAOH_Case.completeMilestone(technoCaseId, CON_CSM.S_RCA,completionDate);
                }if(CON_CSM.S_TS_PP_T3.equalsIgnoreCase(selectTask)){
                    DAOH_Case.completeMilestone(technoCaseId, CON_CSM.S_MS_P_T3_RP,completionDate);
                }else if(CON_CSM.S_RESOLUTION_PLAN_PROVID.equalsIgnoreCase(selectTask)){
                    DAOH_Case.completeMilestone(technoCaseId,new List<String> {CON_CSM.S_RESOLUTION_PLAN,CON_CSM.S_PROBLEM_RESO}, completionDate);
                }else if(CON_CSM.S_CASE_UPD_PRD.equalsIgnoreCase(selectTask)){
                    DAOH_Case.completeMilestone(technoCaseId, CON_CSM.S_COMMUNICATION_UPD,completionDate);
                }
            
            Task tsk = new Task(WhatId = updCase.Id , WhoId = updCase.ContactId, subject = selectTask, type = selectTask, status = CON_CSM.S_COMPLETED, ActivityDate= System.today(), recordtypeid = '0126A000000hDGpQAM');
            insert tsk;
                
        }catch(System.DmlException e){
            
        }
        return;
    }
}
