/**
 * @Author  : CLD Partners
 * @Purpose : Apply tasks from project task templates for RDS Projects
 */
public class QUE_PSA_ApplyRDSProjectTaskTemplates implements Queueable {
	private List<pse__Proj__c> projectList = new List<pse__Proj__c>();
    private Map<Id, pse__Proj__c> parentProjectIdMap = new Map<Id, pse__Proj__c>();
    private Map<String, List<pse__Project_Task__c>> keyToProjectTaskListMap = new Map<String, List<pse__Project_Task__c>>();
    private List<pse__Project_Task__c> insertTaskList = new List<pse__Project_Task__c>();

    public QUE_PSA_ApplyRDSProjectTaskTemplates(List<pse__Proj__c> projects) {
		this.projectList = projects;
	}

    public void execute(QueueableContext context) {

        Set<Id> parentProjectIdSet = new Set<Id>();
        Set<String> existingTaskNameSet = new Set<String>();
        Set<Id> inScopeProjectIds = new Set<Id>();
        List<pse__Proj__c> inScopeProjectList = new List<pse__Proj__c>();

        for(pse__Proj__c proj : projectList) {
            // only apply tasks if not a migrated project. 
            if (proj.Legacy_ID__c == null) {
                inScopeProjectList.add(proj);
                inScopeProjectIds.add(proj.id);
                if (proj.pse__Parent_Project__c != null) parentProjectIdSet.add(proj.pse__Parent_Project__c);
            }
        }

        if (inScopeProjectList.size() > 0 ) {
            parentProjectIdMap = new SLT_Project().getProjectById(parentProjectIdSet, new Set<String>{'Id', 'pse__Parent_Project__c', 'Project_Category__c', 'Project_Scope__c', 'Program__c', 'pse__Group__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'Go_Live_Date__c', 'Close_Out_Date__c' });

            // get custom setting template project id
            PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();
            Id taskRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Template_Task').getRecordTypeId();

            //loop through template tasks and create map of template tasks
            for (pse__Project_Task__c pt : [SELECT id, type__c, name, role__c, frequency__c, group__c, project_category__c, project_scope__c, service_line__c, template_task_id__c 
                                            FROM pse__Project_Task__c 
                                            WHERE pse__Project__c = :rdsSettings.Task_Template_ID__c 
                                                and Type__c in ('Close-out','Start-up','Maintenance')]) 
            {   
                string projectGroup = string.isblank(string.valueOf(pt.group__c)) ? '*' : string.valueOf(pt.group__c);
                string category = pt.project_category__c != null ? pt.project_category__c : '*';
                string scope = pt.project_scope__c != null ? pt.project_scope__c : '*';
                string serviceLine = string.valueOf(pt.service_line__c) != null ? string.valueOf(pt.service_line__c) : '*';
                string key = projectGroup + '-' + category + '-' + scope + '-' + serviceLine;

                List<pse__Project_Task__c> tempTasks = keyToProjectTaskListMap.get(key);

                if (tempTasks != null) {
                    tempTasks.add(pt);
                    keyToProjectTaskListMap.put(key,tempTasks);
                } else {
                    keyToProjectTaskListMap.put(key, new List<pse__Project_Task__c>{pt});
                }
            }

            //get existing tasks and add to set
            for (pse__Project_Task__c pt : [SELECT Id, Name, Template_Task_ID__c FROM pse__project_task__c WHERE pse__Project__c in :inScopeProjectIds]) {
                existingTaskNameSet.add(pt.Name);
            }
           
            for (pse__Proj__c proj: inScopeProjectList) {
                pse__Proj__c parentProj = parentProjectIdMap.get(proj.pse__Parent_Project__c);
                string projectGroup = string.valueOf(proj.pse__group__c) != null ? string.valueOf(proj.pse__group__c): '';
                string category = parentProj.project_category__c != null ? parentProj.project_category__c : '';
                string scope = parentProj.project_scope__c != null ? parentProj.project_scope__c : '';
                string serviceLine = string.valueOf(proj.service_line__c) != null ? string.valueOf(proj.service_line__c) : '';
                
                List<String> keyList = getKeyList(projectGroup, category, scope, serviceLine);

                for (String key : keyList) {
                    List<pse__Project_Task__c> tempTasks = keyToProjectTaskListMap.get(key);
                    if (tempTasks != null) {
                        for (pse__Project_Task__c pt : tempTasks) {
                            //check for existing
                            if ( existingTaskNameSet.contains(pt.Name) ) continue;

                            System.debug('QUEUE TASKS - Found new task: '+pt);
                            if (pt.Type__c == 'Maintenance' ) {
                                // add tasks for each year
                                if (pt.Frequency__c == 'Yearly') {
                                    // get number of years
                                    integer numYears = parentProj.pse__Start_Date__c.monthsBetween(parentProj.pse__End_Date__c) / 12;
                                    
                                    for (integer i = 0; i < numYears + 1; i++ ) {
                                        pse__Project_Task__c newMaintenanceTask = new pse__Project_Task__c();
                                        newMaintenanceTask = cloneTask(pt, proj);
                                        newMaintenanceTask.pse__Start_Date_Time__c = parentProj.pse__Start_Date__c.addYears(i);
                                        newMaintenanceTask.pse__End_Date_Time__c = parentProj.Go_Live_Date__c.addYears(i+1);
                                        insertTaskList.add(newMaintenanceTask);
                                        existingTaskNameSet.add(pt.Name);
                                    }
                                }
                            } else {
                                pse__Project_Task__c newTask = new pse__Project_Task__c();
                                newTask = cloneTask(pt, proj);
                                insertTaskList.add(newTask);
                                existingTaskNameSet.add(pt.Name);
                            }         
                        }
                    }
                }
            }

            if (insertTaskList.size() > 0) {
                try{
                    insert insertTaskList;
                }catch( Exception e ){
                    System.debug('Error '+ e.getMessage() +'  Line '+e.getLineNumber() );
                }
                
            }
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

    private pse__Project_Task__c cloneTask(pse__Project_Task__c origTask, pse__Proj__c origProj) {
        pse__Project_Task__c newTask = new pse__Project_Task__c();
        pse__Proj__c origParentProj = parentProjectIdMap.get(origProj.pse__Parent_Project__c);

        newTask.name = origTask.name;
        newTask.pse__Project__c = origProj.id;
        newTask.Parent_Project__c =  origProj.pse__Parent_Project__c;
        newTask.Program__c = parentProjectIdMap.get(origProj.pse__Parent_Project__c).Program__c;
        newTask.RecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Project_Task').getRecordTypeId();
        
        if (origTask.Type__c == 'Start-up') {
            newTask.pse__Start_Date_Time__c = origParentProj.pse__Start_Date__c;
            newTask.pse__End_Date_Time__c = origParentProj.Go_Live_Date__c;
        } else if (origTask.Type__c == 'Close-out' ) {
            newTask.pse__Start_Date_Time__c = origParentProj.Close_Out_Date__c;
            newTask.pse__End_Date_Time__c = origParentProj.pse__End_Date__c;
        } 

        newTask.Role__c = origTask.Role__c;
        newTask.Type__c = origTask.Type__c;
        newTask.Template_Task_ID__c = origTask.Id;

        return newTask;
    }
} 
