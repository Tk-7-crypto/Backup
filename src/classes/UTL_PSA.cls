/**
 * @author	: Leo De Bruyn <ldebruyn@cldpartners.com>
 * Commonly used PSA utility methods
 */

public class UTL_PSA {
    public UTL_PSA() {

    }

    private static Set<String> FIELDS_ID = new Set<String>{'Id'};                                                
    private static Set<String> FIELDS_PROJECT = new Set<String>{'Id', 'Closed_for_Unit_Entry__c'};
    private static Set<String> FIELDS_MILESTONE = new Set<String>{'Id', 'Closed_for_Unit_Entry__c'};
    private static Set<String> FIELDS_TASK = new Set<String>{'Id', 'Reason_for_Deletion__c'};

    public static String getString(String s) {
        if (s == null) {return '';} else {return s;}
    }

    /**
     * Remove an entire project hierarchy from the Program level on down
     */
    public static void deleteProjectHierarchy(Set<Id> programIds){
        Database.executeBatch(new BCH_PSA_DeleteRDSProject(programIds), 1);
    }

    public static void deleteProjectHierarchy(Id programId){
        deleteProjectHierarchy(programId, null, null, true);
    }

    public static void deleteProjectHierarchy(Id programId, Boolean deleteParent){
        deleteProjectHierarchy(programId, null, null, deleteParent);
    }

    public static void deleteProjectHierarchyByProject(Id projectId){
        deleteProjectHierarchy(null, projectId, null, true);

    }

    public static void deleteProjectHierarchyByServiceLine(Id serviceLineId){
        deleteProjectHierarchy(null, null, serviceLineId, true);
    }

    /*
        This method lets you delete all or part of a hierarchy. Note that the highest level you submit will be used-- it will ignore lower level Ids unless the higher ones are null. 
        You can also set whether to delete the parent or just its children
    */
    public static void deleteProjectHierarchy(Id programId, Id projectId, Id serviceLineId, Boolean deleteParent){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Program__c.SObjectType,
                pse__Proj__c.SObjectType,
                Pricing_task__c.SObjectType,
                pse__Budget__c.sObjectType,
                Project_Metric__c.sObjectType,
                pse__Milestone__c.sObjectType, 
                pse__Resource_Request__c.sObjectType,
                pse__Project_Task__c.sObjectType
            }
        );
        Program__c program;
        List<pse__Proj__c> projects;
        List<pse__Proj__c> serviceLines;
        List<pse__Project_Task__c> projectTasks;

        if(programId != null){
            program = new Program__c(Id = programId);
            if( deleteParent) {
                uow.registerDeleted(program);
            }
            projects = new SLT_Project().selectByProgramId(new Set<Id>{programId}, FIELDS_PROJECT);
            uow.registerDeleted(projects);
        } else if (projectId != null){
            projects = new SLT_Project().getProjectById(new Set<Id>{projectId}, FIELDS_PROJECT).values();
            if( deleteParent) {
                uow.registerDeleted(projects);
            }
        }  else if (serviceLineId != null){
            serviceLines = new SLT_Project().getProjectById(new Set<Id>{serviceLineId}, FIELDS_PROJECT).values();
            if( deleteParent) {
                uow.registerDeleted(serviceLines);
            }
        }

        if(projects != null){
            for(pse__Proj__c project : projects){
                if(project.Closed_for_Unit_Entry__c) {
                    project.Closed_for_Unit_Entry__c = false;
                    uow.registerDirty(project);
                }
            }
            Set<Id> projectIds = new Map<Id,pse__Proj__c>(projects).keySet();
            serviceLines = new SLT_Project().selectServiceLineByParentProject(projectIds, FIELDS_PROJECT);
            uow.registerDeleted(serviceLines);
            List<Pricing_Task__c> pricingTasks = new SLT_Pricing_Task().selectByProject(projectIds, FIELDS_ID);
            uow.registerDeleted(pricingTasks);
            List<pse__Budget__c> budgets = new SLT_Budget().selectByProject(projectIds, FIELDS_ID);
            uow.registerDeleted(budgets);
            List<Project_Metric__c> projectMetrics = new SLT_Project_Metric().selectByProject(projectIds, FIELDS_ID);
            uow.registerDeleted(projectMetrics);
        }

        if(serviceLines != null){
            for(pse__Proj__c project : serviceLines){
                if(project.Closed_for_Unit_Entry__c) {
                    project.Closed_for_Unit_Entry__c = false;
                    uow.registerDirty(project);
                }
            }
            Set<Id> serviceLineProjectIds = new Map<Id,pse__Proj__c>(serviceLines).keySet();
            List<pse__Milestone__c> milestones = new SLT_Milestone().selectMilestoneByProjectId(serviceLineProjectIds, FIELDS_MILESTONE);
            for(pse__Milestone__c milestone : milestones){
                if(milestone.Closed_for_Unit_Entry__c) {
                    milestone.Closed_for_Unit_Entry__c = false;
                    uow.registerDirty(milestone);
                }
            }
            uow.registerDeleted(milestones);
            List<pse__Resource_Request__c> requests = new SLT_Resource_Request().getResourceRequestByProjectID(serviceLineProjectIds, FIELDS_ID).values();
            uow.registerDeleted(requests);
            projectTasks = new SLT_Project_Task().getProjectTasksByServiceLineProject(serviceLineProjectIds, FIELDS_TASK);
        }

        if(projectTasks != null){
            for(pse__Project_Task__c task : projectTasks){
                task.Reason_for_Deletion__c = 'Deleted by a utility process';
            }
            uow.registerDirty(projectTasks);
            uow.registerDeleted(projectTasks);
        }

        uow.commitWork();
    }

    /**********************************************************************
    // Name: calculateEndDate
    // Description: Calculates the end date given the start date and number of business days required.
    **********************************************************************/
    public static Date calculateEndDate(Date startDate, Integer numberRequired) {
        Date endDate = startDate;
        
        for (Integer i = 0; i < numberRequired; i++){
	    if (Math.MOD(DATE.newInstance(1900,1,6).daysBetween(endDate),7) == 0) { // saturday
                endDate = endDate.addDays(2);
            } else if (Math.MOD(DATE.newInstance(1900,1,6).daysBetween(endDate),7) == 6) { //friday}
                endDate = endDate.addDays(3);
            } else {
                endDate = endDate.addDays(1);
            }
        }

        return endDate;
    }

    /**********************************************************************
    // Name: makeReportValid
    // Description: Takes aggregate report Id and sets all fields on that report into some state that will pass validations
    **********************************************************************/
    public static void makeReportValid(Id agReportId){
        SLT_Aggregate_Report slt = new SLT_Aggregate_Report();
        Set<String> arFields = new Set<String>();
        for( Schema.SObjectField field : slt.getSObjectFieldList() ){
            arFields.add( String.valueOf(field));
        } 
        Aggregate_Report__c ar = slt.selectAggregateReportsById(new Set<Id>{agReportId}, arFields).get(0);
        DAOH_Aggregate_Report.makeReportValid(ar);
        update ar;
    }

	/***************************************************************************
	 // Method to return Target records that are activated on the given Program.
    ****************************************************************************/    
    public static List<Target__c> getTargetRecords(string projectID){
        Map<Id, pse__Proj__c> projectMap = new SLT_Project().getProjectById(new Set<Id>{projectID}, new Set<String>{'pse__Parent_Project__c'});
        List<Project_Target__c> projectTargetList = [select id,Target__c,Active__c,Target__r.id,Target__r.Active__c
                                                     from Project_Target__c 
                                                     where Target__r.RecordType.name = 'RDS Product Line' 
                                                     and Project__c =: projectMap.get(projectID).pse__Parent_Project__c 
                                                     and Target__r.Active__c = true
                                                     and Target__c != null
                                                     order by createdDate];
        Map<id,Project_Target__c> idProjectTargetMap = new Map<id,Project_Target__c>();
        for(Project_Target__c ProjTargetRec: projectTargetList ){
            idProjectTargetMap.put(ProjTargetRec.Target__r.id,ProjTargetRec);
        }
        Set<Id> targetIdSet = new Set<Id>();
        for(Project_Target__c projtarget : idProjectTargetMap.values()) {
            if(projtarget.Active__c == true){
                targetIdSet.add(projtarget.Target__c);
            }
        }
        List<Target__c> targetList = new List<Target__c>();
        targetList = new SLT_Target().getTargetById(targetIdSet, new Set<String>{'Id','Name','Drug__r.name','Drug_Trade_Name__r.name','Formulation__r.name','Single_Country__c'});
           
        return targetList;
    }
    public static Boolean checkWorkingDay(Set<String> holidayDateList, String dateString){
        if(holidayDateList.contains(dateString)){
            return true;
        }
        return false;
    }
    public static Integer getWeekDay(Date dueDate){
        return math.mod(Date.newInstance(1900, 1, 7).daysBetween(dueDate), 7);
    }
    public static Date calculateDate(String dayOfWeek, Date nextDate){
        Date dateCalculate;
        if(dayOfWeek == CON_PSA.SATURDAY){
            dateCalculate = nextDate.addDays(2);
        }else if(dayOfWeek == CON_PSA.SUNDAY){
            dateCalculate = nextDate.addDays(1);
        }
        return dateCalculate;
    }
     public static Date calculateWorkingDate(Date reviewDate, Integer shiftdays, Set<String> holidayList){
        Date WorkingDate = reviewDate;
        Date calculdateWorkingDate;
        Integer getWeekDay = 0;
        for(integer i = 1; i <= shiftdays ;i++){
            workingDate = workingDate.addDays(1);
            calculdateWorkingDate = null;
            getWeekDay = getWeekDay(workingDate);
            if(CON_PSA.weekDayNumberToWeekDayMap.containsKey(getWeekDay)){
                calculdateWorkingDate = calculateDate(CON_PSA.weekDayNumberToWeekDayMap.get(getWeekDay), workingDate);
                if(calculdateWorkingDate != null){
                    workingDate = calculdateWorkingDate;
                }
            }
            if(holidayList != null && holidayList.size() > 0){
                while(checkWorkingDay(holidayList, String.valueOf(workingDate))){
                    workingDate = workingDate.addDays(1);
                    calculdateWorkingDate = null;
                    getWeekDay = getWeekDay(workingDate);
                    if(CON_PSA.weekDayNumberToWeekDayMap.containsKey(getWeekDay)){
                        calculdateWorkingDate = calculateDate(CON_PSA.weekDayNumberToWeekDayMap.get(getWeekDay), workingDate);
                        if(calculdateWorkingDate != null){
                            workingDate = calculdateWorkingDate;
                        }
                    }
                }
            }
        }
        return WorkingDate;
    }
      public static void updateActiveResourceLitertureProjectList(Set<Id> projectIdSet){
          List<String> listOfStrings;
          Set<Id> updatedProjectIdSet = new Set<Id>();  
          String assignmentCondition = 'pse__Project__c IN : sObjectIdset AND Active__c = TRUE '+
              'AND pse__Resource__r.pse__Is_Resource_Active__c = TRUE '+
              'AND pse__Project__r.Service_Line__r.Name =\'Literature\' '+
              'AND pse__Status__c != \'Closed\' '+
              'AND pse__Status__c != \'Cancelled\' '+
	      'AND RecordType.name = \'RDS Assignment\'';
          List<pse__Proj__c> projectUpdateList = new List<pse__Proj__c>();
          Map<Id,pse__Assignment__c> activeResourceAssignmentIdToAssignmentMap;
          Map<String,Set<String>> projectIdToResourceNameSetMap = new Map<String,Set<String>>();
          if(!projectIdSet.isEmpty()){
              activeResourceAssignmentIdToAssignmentMap =  new SLT_Assignment().selectAssignmentsByIdSet(projectIdSet, assignmentCondition, new Set<String>{'Id','pse__Resource__r.name','pse__Project__c','Active__c'});
              if(!activeResourceAssignmentIdToAssignmentMap.isEmpty()){
                  for(pse__Assignment__c assignment : activeResourceAssignmentIdToAssignmentMap.values()){
                      if(projectIdToResourceNameSetMap.containsKey(assignment.pse__Project__c)){
                          projectIdToResourceNameSetMap.get(assignment.pse__Project__c).add(assignment.pse__Resource__r.name);
                      }else{
                          projectIdToResourceNameSetMap.put(assignment.pse__Project__c, new Set<String>{assignment.pse__Resource__r.name});
                      }
                  }
              }
          }
          if(!projectIdToResourceNameSetMap.isEmpty()){
              for(String projectId : projectIdToResourceNameSetMap.keySet()){
                  updatedProjectIdSet.add(projectId);
                  listOfStrings = new List<String>(projectIdToResourceNameSetMap.get(projectId));
                  projectUpdateList.add(new pse__Proj__c(Id = projectId, Active_Resources__c = String.join(listOfStrings,',')));
              }
          }
          if(!projectIdSet.isEmpty()){
              for(String projectId : projectIdSet){
                  if(!updatedProjectIdSet.contains(projectId)){
                      projectUpdateList.add(new pse__Proj__c(Id = projectId, Active_Resources__c =''));
                  }
              }
          }  
          if(!projectUpdateList.isEmpty()){
              update projectUpdateList;
          }
      }
}
