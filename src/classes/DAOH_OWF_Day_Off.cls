/**
* This is Day Off trigger handler class.
* version : 1.0
*/
public class DAOH_OWF_Day_Off {
    /**
    * This method is used to upsert the related Assignment & Schedule records.
    * @params  newDaysOff List<Days_Off__c>
    * @params  oldDaysOff Map<Id,Days_Off__c>
    * @return  void
    */
    public static void upsertRelatedAssignmentAndSchedule(List<Days_Off__c> newDaysOffList, Map<Id,Days_Off__c> oldDaysOff){
        Map<Days_Off__c,pse__Assignment__c> DaysOffToAssignmentMap = new Map<Days_Off__c,pse__Assignment__c>();
        Map<pse__Assignment__c,pse__Schedule__c> assignmentToScheduleMap = new Map<pse__Assignment__c,pse__Schedule__c>();
        Set<Id> deleteAssignmentIdSet = new Set<Id>();
        Set<Id> resourceIdSet = new Set<Id>();
        Map<Id,Days_Off__c> assignmentIdToDaysOffMap = new Map<Id,Days_Off__c>();
        List<pse__Assignment__c> diferredDaysOffAssignmentList = new List<pse__Assignment__c>();
        CON_OWF.allowDaysOffStatusUpdate = true;
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        try{
            if(newDaysOffList != null){
                for(Days_Off__c dayOff : newDaysOffList){
                    
                    
                 if(oldDaysOff==null && dayOff.Status__c!='Approved' && dayOff.Assignment__c == null)
                        dayOff.Status__c ='Approved';

                    
                    if(dayOff.First_Day_Off__c > dayOff.Last_Day_Off__c){
                        dayOff.addError('Last day off needs to be greater than or equal to the first day off.');
                    }else if(oldDaysOff == null){
                        if(dayOff.Assignment__c != null){
                            deleteAssignmentIdSet.add(dayOff.Assignment__c);
                        }else{
                            pse__Schedule__c scheduleRecord = new pse__Schedule__c();
                            scheduleRecord.pse__Start_Date__c = dayOff.First_Day_Off__c;
                            scheduleRecord.pse__End_Date__c = dayOff.Last_Day_Off__c;
                            
                            pse__Assignment__c assignmentRecord = new pse__Assignment__c();
                            assignmentRecord.pse__Resource__c = dayOff.Employee__c;
                            assignmentRecord.Assignment_Type__c = 'Days Off';
                            assignmentRecord.pse__Bill_Rate__c = 0;
                            assignmentRecord.pse__Status__c = 'Days Off - Approved';
                            assignmentRecord.RecordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
                            assignmentToScheduleMap.put(assignmentRecord,scheduleRecord);
                            DaysOffToAssignmentMap.put(dayOff,assignmentRecord);
                            resourceIdSet.add(dayOff.Employee__c);
                        }
                    }else{
                        if(dayOff.First_Day_Off__c != oldDaysOff.get(dayOff.Id).First_Day_Off__c || dayOff.Last_Day_Off__c != oldDaysOff.get(dayOff.Id).Last_Day_Off__c){
                            assignmentIdToDaysOffMap.put(dayOff.Assignment__c,dayOff);
                        }  
                        if(dayOff.Status__c != oldDaysOff.get(dayOff.Id).Status__c && dayOff.Status__c == 'Cancelled' && dayOff.Assignment_Type__c=='Days Off')
                        {
                            pse__Assignment__c cancelDayOffAssignment = new pse__Assignment__c();
                            cancelDayOffAssignment.Id = dayOff.Assignment__c;
                            if(dayOff.First_Day_Off__c > System.today()){
                                cancelDayOffAssignment.pse__Status__c = 'Cancelled';
                                UTL_OWF.isAssignmentStatusUpdateAsCancelledBySystem = true;
                            }
                            else if(dayOff.First_Day_Off__c <= System.today()){
                                cancelDayOffAssignment.pse__Status__c = 'Closed';
                            }diferredDaysOffAssignmentList.add(cancelDayOffAssignment);
                        }
                        else if(dayOff.Status__c != oldDaysOff.get(dayOff.Id).Status__c && dayOff.Status__c != 'Cancelled' && oldDaysOff.get(dayOff.Id).Status__c == 'Cancelled')
                        {
                          dayOff.addError('Status of Cancelled Days Off Cannot be changed');  
                        }  
                    }
                    
                    
                }
            }
            if(diferredDaysOffAssignmentList.size()>0)
            {
                update diferredDaysOffAssignmentList;
            }
            
            if(!DaysOffToAssignmentMap.isEmpty()){
                insert assignmentToScheduleMap.values();
                List<pse__Proj__c> daysOffProject = [Select Id, Name from pse__Proj__c where Name = 'Annual Leave/Vacation' limit 1];
                if(daysOffProject.isEmpty()){
                    List<pse__Permission_Control__c> exisitngUserPermissionControl = [Select Id, pse__Group__c from pse__Permission_Control__c
                                                           where pse__Group__c != null AND pse__User__c =: UserInfo.getUserId() limit 1];
                    pse__Proj__c project = new pse__Proj__c(Name = 'Annual Leave/Vacation');
                    if(exisitngUserPermissionControl.size() > 0){
                        project.pse__Group__c = exisitngUserPermissionControl[0].pse__Group__c;
                    }
                    daysOffProject.add(project);
                    insert daysOffProject;
                }
                Map<Id,Contact> contactIdToContactMap = new Map<Id, Contact>([Select Id, Name from Contact where Id IN: resourceIdSet]);
                for(pse__Assignment__c assignment : DaysOffToAssignmentMap.values()){
                    if(assignmentToScheduleMap.containsKey(assignment)){
                        assignment.pse__Schedule__c = assignmentToScheduleMap.get(assignment).Id;
                        assignment.pse__Project__c = daysOffProject[0].Id;
                        if(contactIdToContactMap.containsKey(assignment.pse__Resource__c)){
                            assignment.name = contactIdToContactMap.get(assignment.pse__Resource__c).Name + ' - Non-Working Time';
                        }
                    }
                }
                insert DaysOffToAssignmentMap.values();
                for(Days_Off__c dayOff : newDaysOffList){
                    if(DaysOffToAssignmentMap.containsKey(dayOff)){
                        dayOff.Assignment__c = DaysOffToAssignmentMap.get(dayOff).Id;
                    }
                }
            }
            if(!deleteAssignmentIdSet.isEmpty()){
                List<pse__Assignment__c> deleteAssignmentList = new List<pse__Assignment__c>();
                for(Id i : deleteAssignmentIdSet){
                    pse__Assignment__c assignment = new pse__Assignment__c(Id = i);
                    deleteAssignmentList.add(assignment);
                }
                delete deleteAssignmentList;
            }
            if(!assignmentIdToDaysOffMap.isEmpty()){
                List<pse__Assignment__c> assignmentList = [Select id, pse__Schedule__c from pse__Assignment__c
                                                            where ID in: assignmentIdToDaysOffMap.keySet()];
                if(!assignmentList.isEmpty()){
                    List<pse__Schedule__c> updateScheduleList = new List<pse__Schedule__c>();
                    for(pse__Assignment__c assignment : assignmentList){
                        if(assignmentIdToDaysOffMap.containsKey(assignment.Id)){
                            pse__Schedule__c schedule = new pse__Schedule__c(Id = assignment.pse__Schedule__c);
                            schedule.pse__Start_Date__c = assignmentIdToDaysOffMap.get(assignment.Id).First_Day_Off__c;
                            schedule.pse__End_Date__c = assignmentIdToDaysOffMap.get(assignment.Id).Last_Day_Off__c;
                            updateScheduleList.add(schedule);
                        }
                    }
                    if(!updateScheduleList.isEmpty()){
                        update updateScheduleList;
                    }
                }
            }    
        }catch(Exception e){
            System.assert(false,'Exception Caught: ' + e.getMessage() +' on Line: ' + e.getLineNumber());
        }
    }
}
