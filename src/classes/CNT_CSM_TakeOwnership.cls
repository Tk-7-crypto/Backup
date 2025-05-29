public class CNT_CSM_TakeOwnership {
    @AuraEnabled
    public static List<String> getStatusPicklist(Id caseId){
        List<Case> caseList = new SLT_Case().selectById(new Set<Id>{caseId});
        List<String> options = new List<String>();
        List<String> statusOption;
        if(caseList[0].RecordTypeName__c == CON_CSM.S_R_D_CTP || caseList[0].RecordTypeName__c == CON_CSM.S_R_D_CDP || caseList[0].RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || caseList[0].RecordTypeName__c == CON_CSM.S_RDCASE || caseList[0].RecordTypeName__c == CON_CSM.S_DATACASE){
            statusOption = new List<String>{'New', 'Acknowledged', 'In Progress', 'Waiting for', 'Resolved', 'Closed', 'Canceled'};
        }
        else if(caseList[0].RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
            statusOption = new List<String>{'New', 'In Progress', 'Awaiting', 'Internal Solution Provided', 'Resolved with Customer', 'Abandoned', 'Closed'};
        }
        else if(caseList[0].RecordTypeName__c == CON_CSM.S_DataCreateService_R_T){
            statusOption = new List<String>{'New','Coding','Verification','Rework','Review','Closed'};
        }
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pick: pList) {
            for(String validOption :statusOption){
                if(pick.getLabel() == validOption){
                    options.add(pick.getLabel());
                }
            }
        }
        return options;
    }
    @AuraEnabled
    public static List<Case> getCurrentStatus(String caseId){ 
        List<Case> caseStatus = [Select id, Status ,SubStatus__c,CurrentQueue__c,CurrentQueue__r.Name,RecordTypeName__c,Internal_Follow_Up__c from Case where id =:caseId];
        return caseStatus;
    }
    
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getAssignCurrentQueues(String caseId){ 
        List<Queue_User_Relationship__c> queueList = new SLT_QueueUserRelationshipC().selectBasedOnUserGroupTOwner(new Set<Id>{UserInfo.getUserId()});
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        if(queueList != null){
            for(Queue_User_Relationship__c q : queueList){
                options.add(new EXT_CSM_CheckboxDetails(q.Id, q.Name,true));
            }
            
        }
        return options;
    }
    
    @AuraEnabled
    public static List<string> getSubStatusValueChange(string status){
        List<String> inprogresssubstatusOption = new List<String>{'CIO','Response Received','In QA','Product Development','Standard Change Request','Work Order','Awaiting Internal Information'};
        List<String> awaitingsubstatusOption = new List<String>{'Customer Info','External vendor','Pending Problem Resolution','Schedule'};
        List<String> resolvedsubstatusOption = new List<String>{'Root cause analysis','Pending Resolution Confirmation'};
        if(status == 'In progress'){
            return inprogresssubstatusOption; 
        }
        else if(status == 'Awaiting'){
            return awaitingsubstatusOption; 
        }
        else if(status == 'Resolved with customer'){
            return resolvedsubstatusOption; 
        }
        else{
            List<string> picList= getPickListOptions('SubStatus__c');
            return picList;
        }
        
    }
     public static List<String> getPickListOptions(String fld){
        List<String> options =  new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get(fld).getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
        for(Schema.picklistEntry pic:ple)
        {
            options.add(pic.getValue());
        }
        return options;
    }
    @AuraEnabled
    public static String Save(Case con,String recordId)
    {
        Case c = [Select Status,ownerId,AssignCaseToCurrentUser__c,PreviousQueueUser__c,Previous_User__c,Previous_Queue__c,CaseNumber,CurrentQueue__c,SubStatus__c,IsEscalated,RecordTypeName__c,TaskMilestone__c,SupportTier__c,Internal_Follow_Up__c from case where Id =:recordId];
        c.Status = con.Status;
        String returnString;
        if(con.SubStatus__c != null && con.SubStatus__c != c.SubStatus__c){
            c.SubStatus__c = con.SubStatus__c;
        }
        if(con.Internal_Follow_Up__c != c.Internal_Follow_Up__c){
                c.Internal_Follow_Up__c = con.Internal_Follow_Up__c;
        }
        List<Queue_User_Relationship__c> queueUser  = new List<Queue_User_Relationship__c>();
        try{
            if(con.CurrentQueue__c != null){
                queueUser = [Select id ,Name,Tier__C from Queue_User_Relationship__c where Id = :con.CurrentQueue__c];
                c.Previous_User__c = con.Previous_User__c;
                c.Previous_Queue__c = con.Previous_Queue__c;
                c.CurrentQueue__c = con.CurrentQueue__c;
                c.AssignCaseToCurrentUser__c = true;
            }else{
                c.AssignCaseToCurrentUser__c = false;
            }
            c.CaseOwnerModifiedDate__c = System.now();
            c.CaseUpdatedTime__c = System.now();
            c.OwnerId = UserInfo.getUserId();
            if(CON_CSM.S_TECHNOLOGY_R_T == c.RecordTypeName__c && !queueUser.isEmpty() && queueUser[0].Name != null){
                if(queueUser[0].Name.containsIgnoreCase(CON_CSM.S_PRODOPS) ){
                    if(c.TaskMilestone__c == null){
                        c.TaskMilestone__c = CON_CSM.S_PRODOPS;
                    }else if(c.TaskMilestone__c != null){
                        c.TaskMilestone__c += ';' + CON_CSM.S_PRODOPS;
                    }
                }
                String selectTask = DAOH_Case.SanofiTaskMilestone(queueUser[0].Name);
                //c.SupportTier__c = (selectTask.containsIgnoreCase('T1') ? 'Tier 1': selectTask.containsIgnoreCase('T2') ? 'Tier 2':selectTask.containsIgnoreCase('T3') ? 'Tier 3':selectTask.containsIgnoreCase('T4') ? 'Tier 4' :'');
                if(queueUser[0].Tier__C!= null){
                    c.SupportTier__c = queueUser[0].Tier__C;
                }
                if(c.TaskMilestone__c != null && !c.TaskMilestone__c.containsIgnoreCase(selectTask)){
                    c.TaskMilestone__c += ';' + selectTask;
                }else if(c.TaskMilestone__c == null){
                    c.TaskMilestone__c = selectTask; 
                }
                if(queueUser[0].Name == CON_CSM.S_TECH_GPSQ && !c.TaskMilestone__c.containsIgnoreCase(CON_CSM.S_TECH_GPSQ)){
                    if(c.TaskMilestone__c == null){
                        c.TaskMilestone__c = CON_CSM.S_TECH_GPSQ;
                    }else if(c.TaskMilestone__c != null){
                        c.TaskMilestone__c += ';' + CON_CSM.S_TECH_GPSQ;
                    }                    
                }
            }
            update c;
        }
         catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return returnString;
    }
 
    @AuraEnabled
    public static boolean checkUserFromCurrentQueue(string caseId){
        List<Case> caseList = new SLT_Case().selectById(new Set<Id>{caseId});
        if(caseList[0].RecordTypeName__c == CON_CSM.S_DataCreateService_R_T && String.valueOf(caseList[0].OwnerId).startsWith('005') && UserInfo.getUserId() != caseList[0].OwnerId){
            List<Queue_User_Relationship__c> currentRecord =[SELECT Group_Id__c from Queue_User_Relationship__c  where ID  =: caseList[0].CurrentQueue__c Limit 1];
            if(!currentRecord.isEmpty() )  {  
                Boolean isUserInQueue = [SELECT Id 
                                         FROM Queue_User_Relationship__C 
                                         WHERE User__C = :UserInfo.getUserId() 
                                         AND Group_Id__c = :currentRecord[0].Group_Id__c 
                                         LIMIT 1].size() > 0;
                
                return isUserInQueue;
            }
            else
                return true;
        }
        else{
            return true;
        }
    }
}
