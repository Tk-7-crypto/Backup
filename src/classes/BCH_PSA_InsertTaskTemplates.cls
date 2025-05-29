/**
 * Insert tasks in smaller lots for performance improvement
 *  
 */
public with sharing class BCH_PSA_InsertTaskTemplates implements Database.Batchable<pse__Project_Task__c> {
    private List<pse__Project_Task__c> taskList = new List<pse__Project_Task__c>();
    private List<pse__Proj__c> projectList = new List<pse__Proj__c>();
    private Map<String, List<pse__Project_Task__c>> keyToCEVAProjectTaskListMap = new Map<String, List<pse__Project_Task__c>>();

    public static final Integer BATCH_SIZE = 25;

    public BCH_PSA_InsertTaskTemplates(List<pse__Proj__c> projects) {
        List<pse__Proj__c> inScopeProjectList = new List<pse__Proj__c>();
        //Filter projects to make sure we only process eligible ones
        for(pse__Proj__c proj : projects) {
            if (proj.Legacy_ID__c == null && proj.pse__Parent_Project__c != null) {
                inScopeProjectList.add(proj);
            }
        }
        this.projectList = inScopeProjectList;

        //OLD CODE
        if (inScopeProjectList.size() > 0 ) {
            pse__Proj__c currentProject = inScopeProjectList.get(0);
            pse__Proj__c parentProject  = new SLT_Project().selectByProjectId(new Set<Id>{currentProject.pse__Parent_Project__c}, new Set<String>{'Id', 'pse__Parent_Project__c', 'Project_Category__c', 'Project_Scope__c', 'Program__c', 'pse__Group__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'Go_Live_Date__c', 'Close_Out_Date__c','pse__Account__r.Name', 'Service_Line_Lead__c','pse__Stage__c' });
            Set<String> existingTaskNameSet = new Set<String>();
            Map<String, List<pse__Project_Task__c>> keyToProjectTaskListMap = new Map<String, List<pse__Project_Task__c>>();
            List<pse__Project_Task__c> tasksToInsert = new List<pse__Project_Task__c>();

            // get custom setting template project id
            PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();
            Set<Id> templateTaskIds= new  Set<Id>();
            templateTaskIds.add(rdsSettings.Task_Template_ID__c);
            String typeCondition = 'pse__Project__c IN :templateTaskIds and Type__c in (\'Close-out\',\'Start-up\',\'Maintenance\')';
            Set<String> projectTaskFields = new Set<string>{'Id','type__c','name','role__c','frequency__c','group__c','project_category__c','project_scope__c','service_line__c','template_task_id__c','Service_Line_Scope__c','Trigger_Email_Notification__c','Service_Line_Lead__c','pse__Status__c','pse__Project__c'};
            List< pse__Project_Task__c > templateTasks = new SLT_Project_Task().getProjectTasksByTaskTemplateIdwithTypeConditions( templateTaskIds, typeCondition,projectTaskFields );
            for (pse__Project_Task__c pt : templateTasks ) {
                string projectGroup = string.isblank(string.valueOf(pt.group__c)) ? '*' : string.valueOf(pt.group__c);
                string category = pt.project_category__c != null ? pt.project_category__c : '*';
                string scope = pt.project_scope__c != null ? pt.project_scope__c : '*';
                string serviceLine = string.valueOf(pt.service_line__c) != null ? string.valueOf(pt.service_line__c) : '*';
                string key = projectGroup + '-' + category + '-' + scope + '-' + serviceLine;
                
                string serviceLineScope = string.valueOf(pt.Service_Line_Scope__c) != null ? string.valueOf(pt.Service_Line_Scope__c) : '*';
                string cevaKey = projectGroup + '-' + category + '-' + scope + '-' + serviceLine + '-' + serviceLineScope;

                List<pse__Project_Task__c> tempTasks = keyToProjectTaskListMap.get(key);

                if (tempTasks != null) {
                    tempTasks.add(pt);
                    keyToProjectTaskListMap.put(key,tempTasks);
                } else {
                    keyToProjectTaskListMap.put(key, new List<pse__Project_Task__c>{pt});
                }
                if(serviceLine == rdsSettings.CEVA_Service_Line_Id__c) {
                    if(!keyToCEVAProjectTaskListMap.containsKey(cevaKey)) {
                        keyToCEVAProjectTaskListMap.put(cevaKey, new List<pse__Project_Task__c>());
                        keyToCEVAProjectTaskListMap.get(cevaKey).add(pt);
                    }
                    else{
                        keyToCEVAProjectTaskListMap.get(cevaKey).add(pt);
                    }
                }
            }
            //get existing tasks and add to set
            List< pse__Project_Task__c > currentProjectTasks = new SLT_Project_Task().getProjectTasksByServiceLineProject( new set<Id>{ currentProject.Id }, projectTaskFields );
            for (pse__Project_Task__c pt : currentProjectTasks ) {
                existingTaskNameSet.add(pt.pse__Project__c + pt.Name);
            }

            string projectGroup = string.valueOf(currentProject.pse__group__c) != null ? string.valueOf(currentProject.pse__group__c): '';
            string category = parentProject.project_category__c != null ? parentProject.project_category__c : '';
            string scope = parentProject.project_scope__c != null ? parentProject.project_scope__c : '';
            string serviceLine = string.valueOf(currentProject.service_line__c) != null ? string.valueOf(currentProject.service_line__c) : '';  
            
            //Apply template tasks for CEVA Service Line Projects.
            if(serviceLine == rdsSettings.CEVA_Service_Line_Id__c) {
                String serviceLineScope = string.valueOf(currentProject.Service_Line_Scope__c) != null ? string.valueOf(currentProject.Service_Line_Scope__c) : '';
                List<String> serviceLineScopeList = new List<String>();
                Set<String> keySet = new Set<String>();
                if (serviceLineScope <> '') {
                    serviceLineScopeList = serviceLineScope.split(';');
                }
                for (String sLSL : serviceLineScopeList){
                   keySet.addAll(getCevaKeyList(projectGroup, category, scope, serviceLine,serviceLineScopeList,sLSL));
                }
                for (String cevaProjectKey : keySet) {
                    if(keyToCEVAProjectTaskListMap.containsKey(cevaProjectKey)) {
                        for(pse__Project_Task__c pt : keyToCEVAProjectTaskListMap.get(cevaProjectKey)) {
                            if ( existingTaskNameSet.contains(currentProject.id + pt.Name) ){
                                continue;
                            }
                            
                            if (pt.Type__c == 'Maintenance' && pt.Frequency__c == 'Yearly' ) {
                            // add tasks for each year
                                
                                    // get number of years
                                    integer numYears = parentProject.pse__Start_Date__c.monthsBetween(parentProject.pse__End_Date__c) / 12;
                    
                                    for (integer i = 0; i < numYears + 1; i++ ) {
                                        pse__Project_Task__c newMaintenanceTask = new pse__Project_Task__c();
                                        newMaintenanceTask = cloneTask(pt, currentProject,parentProject);
                                        newMaintenanceTask.pse__Start_Date_Time__c = parentProject.pse__Start_Date__c.addYears(i);
                                        newMaintenanceTask.pse__End_Date_Time__c = parentProject.Go_Live_Date__c.addYears(i+1);
                                        tasksToInsert.add(newMaintenanceTask);
                                        existingTaskNameSet.add(currentProject.id + pt.Name);
                                    }
                            } 
                            else if(pt.Type__c != 'Maintenance' || (pt.Type__c == 'Maintenance' && pt.Frequency__c == 'Once')) {
                                pse__Project_Task__c newTask = new pse__Project_Task__c();
                                newTask = cloneTask(pt, currentProject,parentProject);
                                tasksToInsert.add(newTask);
                                existingTaskNameSet.add(currentProject.id + pt.Name);
                            }
                        }
                    }  
                }          
        } 
        else {
            
            List<String> keyList = getKeyList(projectGroup, category, scope, serviceLine);

            for (String key : keyList) {
                List<pse__Project_Task__c> tempTasks = keyToProjectTaskListMap.get(key);
                if (tempTasks != null) {
                    for (pse__Project_Task__c pt : tempTasks) {
                        //check for existing
                        if ( existingTaskNameSet.contains(currentProject.id + pt.Name) ){
                            continue;
                        }
                        if (pt.Type__c == 'Maintenance' && pt.Frequency__c == 'Yearly' ) {
                                // get number of years
                                integer numYears = parentProject.pse__Start_Date__c.monthsBetween(parentProject.pse__End_Date__c) / 12;
                                for (integer i = 0; i < numYears + 1; i++ ) {
                                    pse__Project_Task__c newMaintenanceTask = new pse__Project_Task__c();
                                    newMaintenanceTask = cloneTask(pt, currentProject, parentProject);
                                    newMaintenanceTask.pse__Start_Date_Time__c = parentProject.pse__Start_Date__c.addYears(i);
                                    newMaintenanceTask.pse__End_Date_Time__c = parentProject.Go_Live_Date__c.addYears(i+1);
                                    tasksToInsert.add(newMaintenanceTask);
                                    existingTaskNameSet.add(currentProject.id + pt.Name);
                                }
                        }
                         else if(pt.Type__c != 'Maintenance' || (pt.Type__c == 'Maintenance' && pt.Frequency__c == 'Once')) {
                            pse__Project_Task__c newTask = new pse__Project_Task__c();
                            newTask = cloneTask(pt, currentProject, parentProject);
                            tasksToInsert.add(newTask);
                            existingTaskNameSet.add(currentProject.id + pt.Name);
                        }
                    }
                }
            }  
         }          
            if(tasksToInsert.size() > 0){
                this.taskList = tasksToInsert;
            }
        }
    }

    /**
     * Pre-Configured static run command that lets us tweak the batch size in one place
     */
    public static Id batchRun (List<pse__Proj__c> projects) {
        return Database.executeBatch(new BCH_PSA_InsertTaskTemplates(projects), BATCH_SIZE);
    }

    public Iterable<pse__Project_Task__c> start(Database.BatchableContext info) {
        return this.taskList;
    }

    public void execute(Database.BatchableContext context, pse__Project_Task__c[] records){
        try{
            insert records;
        }catch( Exception e ){
            //System.debug('Error '+e.getMessage());
            e.getMessage();
        }
        
    }

    public void finish(Database.BatchableContext context) {
        List<pse__Proj__c> newProjects = new List<pse__Proj__c>();
        for(Integer i = 1; i < projectList.size(); i++){
            newProjects.add(projectList.get(i));
        }
        if(newProjects.size() > 0){
            Database.executeBatch(new BCH_PSA_InsertTaskTemplates(newProjects));
        }
    }

    /*
    *   Method to return a list of all needed key combinations
    */
    private List<String> getKeyList (string projGroup, string category, string scope, string serviceLine) {
        List<String> returnStringList = new List<String>();

        returnStringList.add(projGroup + '-' + category + '-' + scope  + '-' + serviceLine);
        returnStringList.add(projGroup + '-' + category + '-' + '*' + '-' + '*');
        returnStringList.add(projGroup + '-' + category + '-' + scope + '-' + '*');
        returnStringList.add(projGroup + '-' + category + '-' + '*' + '-' + serviceLine);
        returnStringList.add(projGroup + '-' + '*' + scope + '-' + serviceLine);
        returnStringList.add(projGroup + '-' + '*' + '-' + scope  + '-' + '*');
        returnStringList.add(projGroup + '-' + '*' + '-' + '*'  + '-' + serviceLine);
        returnStringList.add(projGroup + '-' + '*' + '-' + '*'  + '-' + '*');
        returnStringList.add('*' + '-' + category + '-' + scope  + '-' + serviceLine);
        returnStringList.add('*' + '-' + category + '-' + '*'  + '-' + serviceLine);
        returnStringList.add('*' + '-' + category + '-' + scope  + '-' + '*');
        returnStringList.add('*' + '-' + category + '-' + '*' + '*');
        returnStringList.add('*' + '-' + '*' + '-'  + scope  + '-' + serviceLine);
        returnStringList.add('*' + '-' + '*' + '-'  + scope  + '-' + '*');
        returnStringList.add('*' + '-' + '*' + '-'  + '*'  + '-' + serviceLine);

        return returnStringList;
    }

    /*
    *   Method to return a list of all needed key  for CEVA template tasks where Service Line Scope is present
    */
    private Set<String> getCevaKeyList (string projGroup, string category, string scope, string serviceLine, List<String> serviceLineScopeList, String serviceLineScopeValue) {
        Set<String> returnStringSet = new Set<String>();

        returnStringSet.add('*' + '-' + '*' + '-' + '*'  + '-' + serviceLine +'-' +  '*');
        returnStringSet.add('*' + '-' + category + '-' + scope  + '-' + serviceLine +'-' +  '*');
        returnStringSet.add(projGroup + '-' + '*' + '-' + scope  + '-' + serviceLine +'-' +  '*');
        returnStringSet.add('*' + '-' + '*' + '-' + scope  + '-' + serviceLine +'-' +  '*');
        returnStringSet.add(projGroup + '-' + '*' + '-' + '*'  + '-' + serviceLine +'-' +  '*');
        returnStringSet.add(projGroup + '-' + category + '-' + '*'  + '-' + serviceLine + '-' + '*');
        returnStringSet.add(projGroup + '-' + '*' + '-' + scope  + '-' + serviceLine + '-' + '*');
        returnStringSet.add('*' + '-' + category + '-' + '*'  + '-' + serviceLine +'-' +  '*');
        returnStringSet.add(projGroup + '-' + category + '-' + scope  + '-' + serviceLine + '-' + '*');

        if(serviceLineScopeList.size() > 0){
            returnStringSet.add(projGroup + '-' + category + '-' + scope  + '-' + serviceLine +'-' +  serviceLineScopeValue);
            returnStringSet.add('*' + '-' + category + '-' + scope  + '-' + serviceLine +'-' +  serviceLineScopeValue);
            returnStringSet.add('*' + '-' + '*' + '-' + scope  + '-' + serviceLine + '-' + serviceLineScopeValue);
            returnStringSet.add('*' + '-' + '*' + '-' + '*'  + '-' + serviceLine + '-' + serviceLineScopeValue);
            returnStringSet.add(projGroup + '-' + '*' + '-' + '*'  + '-' + serviceLine +'-' +  serviceLineScopeValue);
            returnStringSet.add('*' + '-' +  + category +'-' + '*'  + '-' + serviceLine + '-' + '-' + serviceLineScopeValue);
            returnStringSet.add(projGroup+ '-' + category + '-' + '*'  + '-' + serviceLine +'-' + serviceLineScopeValue);
            returnStringSet.add(projGroup + '-' + '*' + '-' + scope  + '-' + serviceLine + '-' + serviceLineScopeValue);
            returnStringSet.add('*' + '-' + '*' + '-' + category  + scope + serviceLine + '-' +  serviceLineScopeValue);
        
        }
        return returnStringSet;
    }

    private pse__Project_Task__c cloneTask(pse__Project_Task__c origTask, pse__Proj__c origProj, pse__Proj__c origParentProj) {
        pse__Project_Task__c newTask = new pse__Project_Task__c();

        newTask.name = origTask.name;
        newTask.pse__Project__c = origProj.id;
        newTask.Parent_Project__c =  origProj.pse__Parent_Project__c;
        newTask.Program__c = origParentProj.Program__c;
        newTask.RecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Project_Task').getRecordTypeId();
        
        if (origTask.Type__c == 'Start-up') {
            newTask.pse__Start_Date_Time__c = origParentProj.pse__Start_Date__c;
            // newTask.pse__End_Date_Time__c = origParentProj.Go_Live_Date__c;
        } else if (origTask.Type__c == 'Close-out' ) {
            newTask.pse__Start_Date_Time__c = origParentProj.Close_Out_Date__c;
            //newTask.pse__End_Date_Time__c = origParentProj.pse__End_Date__c;
        }
        
        
        /*
         * IQVIAPSA-4744 AC #1
         */
        if(origParentProj.pse__Stage__c== CON_PSA.PROJ_STAGE_CONDUCT ){
            if( origTask.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_NOT_APPLICABLE 
               && origTask.pse__Status__c!= CON_PSA.PROJ_TASK_STATUS_COMPLETE 
               && origTask.pse__Status__c!= CON_PSA.PROJ_TASK_STATUS_CANCELLED ){
                   
                   if(origTask.Type__c== CON_PSA.PROJ_TYPE_CLOSE_OUT ){
                       newTask.pse__End_Date_Time__c = origParentProj.pse__End_Date__c;
                   }
               }
        }
        /*
         * IQVIAPSA-4744 AC #2
         */
        if(origParentProj.pse__Stage__c == CON_PSA.PROJ_STAGE_STARTUP){
            if( origTask.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_NOT_APPLICABLE 
               && origTask.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_COMPLETE 
               && origTask.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_CANCELLED ){ 
                   if(origTask.Type__c == CON_PSA.PROJ_TYPE_START_UP ){
                       newTask.pse__End_Date_Time__c = origParentProj.Go_Live_Date__c;   
                   }
                   if(origTask.Type__c== CON_PSA.PROJ_TYPE_CLOSE_OUT ){
                       newTask.pse__End_Date_Time__c = origParentProj.pse__End_Date__c; 
                   }
               }
        }
        newTask.Role__c = origTask.Role__c;
        newTask.Frequency__c = origTask.Frequency__c;
        newTask.Type__c = origTask.Type__c;
        newTask.Template_Task_ID__c = origTask.Id;
        newTask.Trigger_Email_Notification__c = origTask.Trigger_Email_Notification__c;
        newTask.Service_Line_Lead__c = origProj.Service_Line_Lead__c;
        newTask.Service_Line__c = origProj.Service_Line__c;
        newTask.Account_Name__c = origParentProj.pse__Account__r.Name;
        if(origTask.Service_Line_Scope__c != null){
            newTask.Service_Line_Scope__c = origTask.Service_Line_Scope__c;
        }
        
        return newTask;
    }
}