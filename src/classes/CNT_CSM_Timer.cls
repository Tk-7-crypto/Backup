public class CNT_CSM_Timer {

    public static void updateStopTimefromCase(Set<Id> caseIds,String message){
        String userId = UserInfo.getUserId();
        List<TimeSheet__c> sheetList = new List<TimeSheet__c>();
        sheetList = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c,Case__r.RecordTypeName__c,Comment__c From TimeSheet__c Where Case__c in :caseIds and LastModifiedById =:userId and Status__c = \'start\'');
        if(!sheetList.isEmpty()){
            for(TimeSheet__c sheet: sheetList){
                DateTime start = sheet.StartTime__c;
                DateTime now = System.now();
                Long milliseconds = now.getTime() - start.getTime();
                
                Long minutes = milliseconds / (60*1000);
                Long hours = milliseconds / (60*60*1000);
                //Long days = hours / 24;
                Double min = Double.valueof(Math.mod(minutes, 60))/60;
               if(minutes < 0 || minutes > 120){
                    hours = 0; 
                    min = 0.01;
                }
                if(min == 0){ min = 0.01;}
                sheet.Timeinhours__c = hours + min;
                sheet.Status__c = 'stop';
                sheet.Comment__c = message;
            }
            update sheetList;
        }
        
    }        
    
    @AuraEnabled
    public static TimeSheet__c insertorUpdateTime(String caseId,String timeType,String recordType){
        String userId = UserInfo.getUserId();
        List<TimeSheet__c> sheetList = new List<TimeSheet__c>();
        TimeSheet__c ts = new TimeSheet__c();
        List<String> statusList = CON_CSM.S_C_TECH_STATUS;
        boolean isauto = false;
        List<Case> cs = null;
        if(caseId != null){
            if(recordType == null){
                cs = Database.query('Select Id, Status,CaseNumber,RecordTypeName__c From Case Where Id =:caseId LIMIT 1');
                if(cs != null && !cs.isEmpty()){
                    recordType = cs[0].RecordTypeName__c;
                }
            }
            sheetList = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c, Case__r.CaseNumber, Case__r.Status,Case__r.RecordTypeName__c From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c in (\'autostop\',\'start\') Order by LastModifiedDate desc LIMIT 1');
        }
        if(recordType != CON_CSM.S_DataCreateService_R_T){
            if(!sheetList.isEmpty()){
                for(TimeSheet__c t : sheetList){
                    if(t.Case__c != null && (!statusList.contains(t.Case__r.Status) || t.Case__r.Status == CON_CSM.S_RESOLVED_WITH_C)){
                        if(t.Status__c == 'start'){
                            ts = t;
                            break;
                        }else if(t.Status__c == 'autostop'){
                            ts = t;
                            ts.StartTime__c = System.now();
                            ts.Status__c = 'start';
                            ts.Timeinhours__c = 0;
                            isauto = true;
                            break;
                        }
                    }
                }
                if(isauto){
                    update ts;
                }
            }else if(sheetList.isEmpty()){
                //Fetch PSA detail of last stop record and assign into new record
                List<TimeSheet__c> lstSheet = new List<TimeSheet__c>();
                TimeSheet__c sheet = new TimeSheet__c();
                lstSheet = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c, Case__r.CaseNumber,ProjectId__c,AssignmentId__c,MilestoneId__c From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c = \'stop\' order by LastModifiedDate  desc LIMIT 1');
                
                if(!lstSheet.isEmpty()){
                    sheet = new TimeSheet__c(Type__c = 'System',StartTime__c = System.now(), Case__c = caseId, Status__c = 'start',
                                             Time_Type__c = lstSheet[0].Time_Type__c,ProjectId__c = lstSheet[0].ProjectId__c, AssignmentId__c =lstSheet[0].AssignmentId__c, MilestoneId__c=lstSheet[0].MilestoneId__c);
                }
                else{
                    sheet = new TimeSheet__c(Type__c = 'System',StartTime__c = System.now(), Case__c = caseId, Status__c = 'start',Time_Type__c = timeType);
                }
                insert sheet;
                sheetList = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c, Case__r.CaseNumber From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c = \'start\' LIMIT 1');
                ts = sheetList[0];
            }
        }    
        return ts;
    }  
   
    @AuraEnabled
    public static TimeSheet__c updateStopTime(String caseId,String Id,String timeType){
        String userId = UserInfo.getUserId();
        List<TimeSheet__c> sheet = new List<TimeSheet__c>();
        sheet = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c, Case__r.CaseNumber, Case__r.RecordTypeName__c From TimeSheet__c Where Id = :Id and Case__c =:caseId and LastModifiedById =:userId LIMIT 1');
        if(!sheet.isEmpty()){
          
            DateTime start = sheet[0].StartTime__c;
            DateTime now = System.now();
            Long milliseconds = now.getTime() - start.getTime();
            
            Long minutes = milliseconds / (60*1000);
            Long hours = milliseconds / (60*60*1000);
            //Long days = hours / 24;
            Double min = Double.valueof(Math.mod(minutes, 60))/60;
            if(min == 0){ min = 0.01;}
            sheet[0].Timeinhours__c = hours + min;
            sheet[0].Status__c = 'stop';
            sheet[0].Time_Type__c = timeType;
            update sheet[0];
        }
        return sheet[0];
    } //No refrence found
         
    
    
    
    @AuraEnabled
    public static TimeSheet__c getTimeSheet(String caseId,String prvCaseId){
        List<TimeSheet__c> sheet = new List<TimeSheet__c>();
        String userId = UserInfo.getUserId();
        List<String> statusList = CON_CSM.S_C_TECH_STATUS;
        List<Case> cs = Database.query('Select Id, Status,CaseNumber,RecordTypeName__c From Case Where Id =:caseId LIMIT 1');
        if(cs != null && !cs.isEmpty() && (cs[0].RecordTypeName__c == CON_CSM.S_TECHNO_SOL || cs[0].RecordTypeName__c == CON_CSM.S_RDCASE || cs[0].RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs[0].RecordTypeName__c == CON_CSM.S_R_D_V_T || cs[0].RecordTypeName__c == CON_CSM.S_R_D_CTP || cs[0].RecordTypeName__c == CON_CSM.S_R_D_CDP) && (!statusList.contains(cs[0].Status) || cs[0].Status == CON_CSM.S_RESOLVED_WITH_C)){        
            sheet = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c, Case__r.CaseNumber,ProjectId__c,AssignmentId__c,MilestoneId__c From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c = \'start\' order by LastModifiedDate desc LIMIT 1');
            //need to fetch last Stop and Manual Rerord
            if(!sheet.isEmpty()){
                Datetime dt = sheet[0].StartTime__c;
                Long hours = (Datetime.now().getTime() - dt.getTime()) / (60*60*1000);
                if(( dt.date() < Date.today() || hours >= 1)){
                    sheet[0].StartTime__c = Datetime.now();
                    update sheet[0];
                }
                return sheet[0]; 
            }else if(prvCaseId == null && cs != null && !cs.isEmpty() && (cs[0].RecordTypeName__c == CON_CSM.S_TECHNO_SOL || cs[0].RecordTypeName__c == CON_CSM.S_RDCASE || cs[0].RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs[0].RecordTypeName__c == CON_CSM.S_R_D_CTP || cs[0].RecordTypeName__c == CON_CSM.S_R_D_CDP || cs[0].RecordTypeName__c == CON_CSM.S_R_D_V_T) && (!statusList.contains(cs[0].Status) || cs[0].Status == CON_CSM.S_RESOLVED_WITH_C)){
                return insertorUpdateTime(caseId,null,cs[0].RecordTypeName__c);
            }
        }
        return null;
    }
    
     @AuraEnabled
    public static TimeSheet__c getManaulTimeSheet(String caseId,String prvCaseId){
        List<TimeSheet__c> sheet = new List<TimeSheet__c>();
        String userId = UserInfo.getUserId();
        List<String> statusList = CON_CSM.S_C_TECH_STATUS;
        List<Case> cs = Database.query('Select Id, Status,CaseNumber,RecordTypeName__c From Case Where Id =:caseId LIMIT 1');
        if(cs != null && !cs.isEmpty() && (cs[0].RecordTypeName__c == CON_CSM.S_DataCreateService_R_T || cs[0].RecordTypeName__c == CON_CSM.S_TECHNO_SOL || cs[0].RecordTypeName__c == CON_CSM.S_RDCASE || cs[0].RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs[0].RecordTypeName__c == CON_CSM.S_R_D_V_T || cs[0].RecordTypeName__c == CON_CSM.S_R_D_CTP || cs[0].RecordTypeName__c == CON_CSM.S_R_D_CDP) && (!statusList.contains(cs[0].Status) || cs[0].Status == CON_CSM.S_RESOLVED_WITH_C)){        
            sheet = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c, Case__r.CaseNumber,ProjectId__c,AssignmentId__c,MilestoneId__c From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c = \'stop\' and Type__c=\'Manual\' order by LastModifiedDate desc LIMIT 1');
            //need to fetch last Stop and Manual Rerord
            if(!sheet.isEmpty()){
               /* Datetime dt = sheet[0].StartTime__c;
                Long hours = (Datetime.now().getTime() - dt.getTime()) / (60*60*1000);
                if(( dt.date() < Date.today() || hours >= 1)){
                    sheet[0].StartTime__c = Datetime.now();
                    update sheet[0];
                }*/
                return sheet[0]; 
            }else if(prvCaseId == null && cs != null && !cs.isEmpty() && (cs[0].RecordTypeName__c == CON_CSM.S_DataCreateService_R_T || cs[0].RecordTypeName__c == CON_CSM.S_TECHNO_SOL || cs[0].RecordTypeName__c == CON_CSM.S_RDCASE || cs[0].RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || cs[0].RecordTypeName__c == CON_CSM.S_R_D_V_T || cs[0].RecordTypeName__c == CON_CSM.S_R_D_CTP || cs[0].RecordTypeName__c == CON_CSM.S_R_D_CDP) && (!statusList.contains(cs[0].Status) || cs[0].Status == CON_CSM.S_RESOLVED_WITH_C)){
                return insertorUpdateTime(caseId,null,cs[0].RecordTypeName__c);
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static TimeSheet__c insertTime(String caseId,String timeType){
        String userId = UserInfo.getUserId();
        List<TimeSheet__c> sheetList = new List<TimeSheet__c>();
        if(caseId != null){
            sheetList = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c, Case__r.CaseNumber From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c = \'start\' LIMIT 1');    
        }
        if(sheetList.isEmpty()){
            List<Case> cs = Database.query('Select Id, Status,CaseNumber,RecordTypeName__c From Case Where Id =:caseId LIMIT 1');
            TimeSheet__c sheet = new TimeSheet__c(Type__c = 'System',StartTime__c = System.now(), Case__c = caseId, Status__c = 'start', Time_Type__c = timeType);
            insert sheet;
            sheetList = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,Case__c, Case__r.CaseNumber From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c = \'start\' LIMIT 1');    
        }
            
        return sheetList[0];
    }
    
    
    
    @AuraEnabled
    public static TimeSheet__c updateAutoStopTime(String caseId, String Id,String ttype, String ProjectId, String AssignmentId, String MilestoneId){  
        String userId = UserInfo.getUserId();
        List<TimeSheet__c> sheet = new List<TimeSheet__c>();
        sheet = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case_Record_Type__c,Time_Type__c,ProjectId__c,AssignmentId__c,MilestoneId__c,Case__c, Case__r.CaseNumber,Case__r.RecordTypeName__c From TimeSheet__c Where Id = :Id and Case__c =:caseId and LastModifiedById =:userId  and Status__c = \'start\' LIMIT 1');
        if(!sheet.isEmpty()){
            if(String.isNotBlank(ttype)){
                sheet[0].Time_Type__c = ttype;
            }
            if(String.isBlank(ProjectId)){
                sheet[0].ProjectId__c = '';
                sheet[0].AssignmentId__c = '';
                sheet[0].MilestoneId__c = '';
            }
            if(String.isNotBlank(ProjectId) && String.isNotBlank(AssignmentId)){
                sheet[0].ProjectId__c = ProjectId;
                sheet[0].AssignmentId__c = AssignmentId;
                sheet[0].MilestoneId__c = MilestoneId;
            }
            update sheet[0];
            
            return sheet[0];
        }
        else
            return null;
        
        /*if(!sheet.isEmpty() && ttype == null){
            sheet[0].Status__c = 'autostop'; //Need to re-check
            update sheet[0];
            return null;
            }else if(!sheet.isEmpty() && ttype != null){
            sheet[0].Time_Type__c = ttype;
            update sheet[0];
            return sheet[0];
            }*/
        //sreturn null;
    }
    
    public static Boolean CheckForValidation(String ttype, String ProjectId, String AssignmentId, String MilestoneId){
        Boolean IsValidationPassed = true;
        Proj__x project = null;
        if(String.isBlank(ProjectId) && (String.isNotBlank(AssignmentId) || String.isNotBlank(MilestoneId) )) IsValidationPassed = false;
        //else if(String.isBlank(ttype))    IsValidationPassed = false;
        else{
            if(String.isNotBlank(ProjectId)){
                if(String.isBlank(AssignmentId))    IsValidationPassed = false;
                project = [Select Timecards_require_Milestone_c__c from Proj__x where ExternalId =:ProjectId  limit 1];
                if(String.isBlank(MilestoneId) && project != null && project.Timecards_require_Milestone_c__c)    IsValidationPassed = false;      
            } 
        }
        return IsValidationPassed;
    }
    
    public static Boolean CheckForValidation(String ProjectId, String AssignmentId, String MilestoneId){
        Boolean IsValidationPassed = true;
        Proj__x project = null;
        if(String.isBlank(ProjectId)) IsValidationPassed = false;
        else if(String.isBlank(ProjectId) && String.isBlank(AssignmentId) && String.isBlank(MilestoneId))    IsValidationPassed = false;        
        else{
            if(String.isNotBlank(ProjectId)){
                if(String.isBlank(AssignmentId))    IsValidationPassed = false;
                project = [Select Timecards_require_Milestone_c__c from Proj__x where ExternalId =:ProjectId  limit 1];
                if(String.isBlank(MilestoneId) && project != null && project.Timecards_require_Milestone_c__c)    IsValidationPassed = false;      
            } 
        }
        return IsValidationPassed;
    }
       
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getTimeTypeList(String caseId){
        /*List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        Schema.DescribeFieldResult F = TimeSheet__c.Time_Type__c.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pf : entries) {
            options.add(new EXT_CSM_CheckboxDetails(pf.getValue(), pf.getLabel(),pf.isActive()));
        }*/
        String recordType = null;
        if(caseId != null){
         Case c = [Select Id,RecordTypeName__c From Case where id=:caseId];
            recordType = c.RecordTypeName__c;
        }
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        if(recordType != null){
           List<CSM_RecordType_Based_Picklist_Setting__mdt> recordTypeBasedSettings = Database.query('SELECT DeveloperName, PicklistValues__c FROM CSM_RecordType_Based_Picklist_Setting__mdt WHERE RecordType_Name__c =: recordType AND ObjectName__c =\'TimeSheet__c\' AND PicklistFieldName__c =\'Time_Type__c\' LIMIT 1');
            if(recordTypeBasedSettings != null && !recordTypeBasedSettings.isEmpty()) {
               List<String> typeList = recordTypeBasedSettings[0].PicklistValues__c.split(';');
                for (String pf : typeList) {
                    options.add(new EXT_CSM_CheckboxDetails(pf, pf,true));
                }
            }
        }
        
        return options;
    }
    
    @AuraEnabled
    public static string saveTimeSheet(String caseId,Double timeInHours, String comment,String timeType, String ProjectId, String AssignmentId, String MilestoneId, Integer caseVolumeManual){
         List<TimeSheet__c> cCETimeSheet = [SELECT Id FROM TimeSheet__c WHERE Case__c  =: caseId AND Time_Type__c = 'Case Completion Effort'];						 
        List<Case> cs = Database.query('Select Id, Status,CaseNumber,RecordTypeName__c From Case Where Id =:caseId LIMIT 1');
        if(CheckForValidation(timeType, ProjectId, AssignmentId, MilestoneId)){
            if(timeInHours != null && cs != null){
                for(Case c: cs){
                    if(c.RecordTypeName__c == CON_CSM.S_DataCreateService_R_T){
                        timeInHours = timeInHours/60;
                    }
                }
            }
            if (cCETimeSheet.size() > 0 && timeType == 'Case Completion Effort') {
                return 'Error: There is already one timesheet record for PSA-RWS, it is not allowed to have more than one per case. please cancel your operation.';
            } else {
				TimeSheet__c sheet = new TimeSheet__c(Type__c = 'Manual',StartTime__c = System.now(), Case__c = caseId, Timeinhours__c = timeInHours,
													  Comment__c = comment, Status__c = 'stop',Time_Type__c = timeType,ProjectId__c = ProjectId,AssignmentId__c=AssignmentId,MilestoneId__c=MilestoneId, Case_Volume__c = caseVolumeManual);
				insert sheet;
				//updateStartRecord(caseId,timeType, ProjectId, AssignmentId, MilestoneId);
				return 'Success:Time Entry has successfully created.';
			}
		}
        return 'Error:Error occurred while saving Time entry.';
    } 
    
    /*public static void updateStartRecord(String caseId,String timeType, String ProjectId, String AssignmentId, String MilestoneId){
        string userId = UserInfo.getUserId();
        List<TimeSheet__c> lstSheet = new List<TimeSheet__c>();
        lstSheet = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Time_Type__c,Case__c, Case__r.CaseNumber,ProjectId__c,AssignmentId__c,MilestoneId__c From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c = \'start\' order by LastModifiedDate  desc LIMIT 1');
        if(!lstSheet.isEmpty()){
            lstSheet[0].ProjectId__c = ProjectId;
            lstSheet[0].AssignmentId__c = AssignmentId;
            lstSheet[0].MilestoneId__c = MilestoneId;
            lstSheet[0].Time_Type__c = timeType; 
            update lstSheet; 
        }        
    }*/
    
    @AuraEnabled
    public static List<LIAssignment__x> getAssignmentsAndProjects(){
        String userId = UserInfo.getUserId();
        List<User> users =[Select EmployeeNumber from User where Id =: userId limit 1];
        List<LIAssignment__x> Assignments = new List<LIAssignment__x>();
        if(users != null && users.size()> 0 && users[0].EmployeeNumber != '' && users[0].EmployeeNumber != null){
            Assignments =[SELECT Id,ExternalId,Name__c,pse_Project_c__c,pse_Start_Date_c__c,pse_End_Date_c__c,pse_Status_c__c,pse_Closed_for_Time_Entry_c__c,ResourceEmployeeNumber_c__c,pse_Project_c__r.Name__c,pse_Project_c__r.Timecards_require_Milestone_c__c,pse_Project_c__r.pse_Start_Date_c__c, pse_Project_c__r.pse_End_Date_c__c, pse_Project_c__r.pse_Stage_c__c, pse_Project_c__r.pse_Closed_for_Time_Entry_c__c FROM LIAssignment__x  WHERE ResourceEmployeeNumber_c__c =: Users[0].EmployeeNumber AND pse_Status_c__c in ('Scheduled','Tentative','Open') AND pse_Closed_for_Time_Entry_c__c = false AND pse_Start_Date_c__c <=:Date.today() AND pse_End_Date_c__c >=:Date.today()];
        }
        //Assignments =[SELECT Id,ExternalId,Name__c,pse_Project_c__c,pse_Start_Date_c__c,pse_End_Date_c__c,pse_Status_c__c,pse_Closed_for_Time_Entry_c__c,ResourceEmployeeNumber_c__c,pse_Project_c__r.Name__c,pse_Project_c__r.Timecards_require_Milestone_c__c,pse_Project_c__r.pse_Start_Date_c__c, pse_Project_c__r.pse_End_Date_c__c, pse_Project_c__r.pse_Stage_c__c, pse_Project_c__r.pse_Closed_for_Time_Entry_c__c FROM LIAssignment__x  WHERE ResourceEmployeeNumber_c__c ='0055600000AXcswAAD' AND pse_Status_c__c in ('Scheduled','Tentative','Open') AND pse_Closed_for_Time_Entry_c__c = false AND pse_Start_Date_c__c <=:Date.today() AND pse_End_Date_c__c >=:Date.today()];
        List<LIAssignment__x> filteredAssignments = new List<LIAssignment__x>();
        for(LIAssignment__x assignment : Assignments){
            if(assignment.pse_Start_Date_c__c>=assignment.pse_Project_c__r.pse_Start_Date_c__c && assignment.pse_End_Date_c__c<=assignment.pse_Project_c__r.pse_End_Date_c__c
               && assignment.pse_Project_c__r.pse_Start_Date_c__c <= Date.today() && assignment.pse_Project_c__r.pse_End_Date_c__c >= Date.today() 
               && assignment.pse_Project_c__r.pse_Closed_for_Time_Entry_c__c == false 
               && (assignment.pse_Project_c__r.pse_Stage_c__c =='In Progress (At Risk)' ||assignment.pse_Project_c__r.pse_Stage_c__c =='In Progress')){               
                 filteredAssignments.add(assignment);
               }            
        }
        return filteredAssignments;
        
    }
    
    @AuraEnabled
    public static Object[] getAssignmentsAndMilestones(string projectId){
        List<LIAssignment__x> filteredAssignments = getAssignmentsAndProjects();
        List<LIMilestone__x> fileteredMileStones = (projectId != null && projectId != '')? getMilestones(projectId): null;
        //Array[] result = new Array[]{filteredAssignments,fileteredMileStones};
        Object[] result =(projectId != null && projectId != '')? new Object[] {filteredAssignments, fileteredMileStones}:new Object[] {filteredAssignments, null};
        return result;
        
        
    }
    
    
    @AuraEnabled
    public static List<LIMilestone__x> getMilestones(string projectId){
        System.debug('projectId : '+projectId);
        List<LIMilestone__x> Milestones = new List<LIMilestone__x>();
        if(projectId!=''){
            Proj__x project = [Select Id,pse_Start_Date_c__c,pse_End_Date_c__c from Proj__x where ExternalId =:ProjectId  limit 1];
            if(project!=null){
                Milestones = [Select Id,ExternalId,Name__c,Start_Date_c__c,End_Date_c__c,pse_Closed_for_Time_Entry_c__c  from LIMilestone__x 
                               where pse_Project_c__r.Id  =: projectId and pse_Status_c__c ='Open' and pse_Closed_for_Time_Entry_c__c = false and
                              Start_Date_c__c <=:Date.today() AND End_Date_c__c >=:Date.today() and
                              Start_Date_c__c >=:project.pse_Start_Date_c__c and End_Date_c__c <=:project.pse_End_Date_c__c];
            }
        }
        return Milestones;
    }
    
    @AuraEnabled
    public static TimeSheet__c getTimesheetRecordById(string recordId){
        TimeSheet__c ts = [Select Id, Name,ProjectId__c,AssignmentId__c,MilestoneId__c,PSA_Sync_Status__c,PSA_Sync_Count__c From TimeSheet__c Where Id =:recordId LIMIT 1];
        return ts;
    }
    
    @AuraEnabled
    public static TimeSheet__c updateDataPSA(String Id, String ProjectId, String AssignmentId, String MilestoneId){ 
        system.debug('Inside lwc Calling'+Id +' : '+ProjectId +' : '+AssignmentId+' : '+MilestoneId);
        List<TimeSheet__c> sheet = new List<TimeSheet__c>();
        sheet = Database.query('Select Id,ProjectId__c,AssignmentId__c,MilestoneId__c From TimeSheet__c Where Id = :Id  LIMIT 1');
        if(CheckForValidation(ProjectId, AssignmentId, MilestoneId)){
            if(String.isNotBlank(ProjectId))sheet[0].ProjectId__c = ProjectId;
            if(String.isNotBlank(AssignmentId))sheet[0].AssignmentId__c = AssignmentId;
            //if(String.isNotBlank(MilestoneId))
            sheet[0].MilestoneId__c = MilestoneId;
            update sheet[0];
        }
        return sheet[0];
    }
    
    @AuraEnabled
    public static string SendDataFromUser(){
        system.debug('### SendDataFromUser');
        return SRV_PSA_SyncCSMTimecard.manualSyncPSATimecard();
    }
    
    @AuraEnabled
    public static  List<Object> RecordCreatedThisWeek_Count(){
        CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
        Integer numberOfSyncAttempts = (Integer)csmCustomsetting.SyncNumberOfAttempts__c;
        
        DateTime dT = System.now();
        Date today = date.newinstance(dT.year(), dT.month(), dT.day());
        date monday = today.toStartofWeek().addDays(1);
        date friday = monday.addDays(4);
        DateTime fridayWithTime = DateTime.newInstance(friday.year(), friday.month(), friday.day(), 23, 59, 59);
        String userId = UserInfo.getUserId();
        List<TimeSheet__c> totalRecords=[SELECT ID from TimeSheet__c where CreatedById =: userId and CreatedDate <=: fridayWithTime and CreatedDate >=: monday];
        List<TimeSheet__c> synced=[SELECT ID from TimeSheet__c where CreatedById =: userId and CreatedDate <=: fridayWithTime 
                                   and CreatedDate >=: monday and ProjectId__c != null and  PSA_Sync_Date__c != null and PSA_Sync_Status__c = 'Success'];
        List<TimeSheet__c> notSynced=[SELECT ID from TimeSheet__c where CreatedById =: userId 
                                      AND StartTime__c != null
                                      AND ProjectId__c != null AND Status__c = 'stop'
                                      AND (PSA_Sync_Date__c = null OR (PSA_Sync_Date__c !=null AND PSA_Sync_Status__c ='Failed' AND PSA_Sync_Count__c <: numberOfSyncAttempts) )];
      
        
        Integer total_count=totalRecords.size();
        Integer synced_count=synced.size();
        Integer notSynced_count = notSynced.size();
        List<Object> myObject = new List<Object>{total_count,synced_count,notSynced_count};
        return myObject;
    }
    
    @AuraEnabled
    public static Boolean checkIfEligibleToUpdatePSADetails(string recordId){
        TimeSheet__c ts = getTimesheetRecordById(recordId);
        CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
        Integer numberOfSyncAttempts = (Integer)csmCustomsetting.SyncNumberOfAttempts__c;
        return (ts!= null && (ts.PSA_Sync_Status__c == null || (ts.PSA_Sync_Status__c == 'Failed' && ts.PSA_Sync_Count__c < numberOfSyncAttempts )));
    }
    
    @AuraEnabled
    public static Boolean checkEligibilityForExplictUpdate(string recordId){
        String userId = UserInfo.getUserId();
        
        CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
        boolean stopTimecradSync=csmCustomsetting.StopCSMTimesheetSync__c;
        boolean enablePartialTimecardSync = csmCustomsetting.EnableTimesheetPartialDataSync__c;
        Integer numberOfSyncAttempts = (Integer)csmCustomsetting.SyncNumberOfAttempts__c;
        Date SyncStartDate = csmCustomsetting.DateFromSyncCSMTimesheetData__c;
        DateTime dT = System.now();
        Date today = date.newinstance(dT.year(), dT.month(), dT.day());
        
        CSM_case_Trigger_Handler__c userSetting = CSM_case_Trigger_Handler__c.getValues(UserInfo.getUserId());
        if((userId != recordId) ||
           (stopTimecradSync) ||
           (SyncStartDate != null && SyncStartDate >= today) ||
           (stopTimecradSync == false && enablePartialTimecardSync == true && (userSetting == null || userSetting.EnableTimesheetPartialDataSync__c==false))
          )
            return false;
        else
            return true;
        
    }
    
    @AuraEnabled
    public static Boolean showPSAFieldsBasedOnProfile() {
        If([SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name == 'EXT Service User')
            return false;
        else
            return true;
    }
}
