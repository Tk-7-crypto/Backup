public with sharing class CNT_PSA_MyPersonalCalendar { 
    @AuraEnabled(cacheable=true)
    public static List<CalendarWrapper> getData(String currentUserName, Id CurrentUserId, String getMonth)
    {
        List<Contact> listOfResource = new SLT_Contact(false,false).selectByPseSalesforceUserIdList(new Set<Id>{CurrentUserId},new Set<String>{'Name'});
        Integer month = Integer.valueOf(getMonth);
        month=month+1;
        List<CalendarWrapper> response = new List<CalendarWrapper>();
        Set<String> fieldNameSet = new Set<String>{'Id','Event_Name__c','Event_Due_Date__c','LR_Project_Overview__r.Name',
                                                    'LR_Project_Overview__r.DLP_Enter_only_for_Aggregate_Reports__c',
            							'LR_Project_Overview__r.LR_LBI_Period_Stop_Date__c',
                                                    'LR_Project_Overview__c','LR_Project_Overview__r.Project__r.Active_Resources__c',
                                                    'PSA_Event__r.Planned_Date_Field__c','LR_Project_Overview__r.Project__c'
        };
        List<Project_Event__c> projectEvents = new SLT_Project_Event(false,false).getProjectEventsForCalendar(month,fieldNameSet);
        if(projectEvents.size() > 0){
            for(Project_Event__c  projectEvent :  projectEvents){
                CalendarWrapper record = new CalendarWrapper();
                record.lrProjectName = projectEvent.LR_Project_Overview__r.Name;
                record.lrProjectId = projectEvent.LR_Project_Overview__c;
                record.eventProjectId = projectEvent.Id;
                record.eventProjectName = projectEvent.Event_Name__c;
                record.eventDueDate = projectEvent.Event_Due_Date__c;
                if(projectEvent.PSA_Event__r.Planned_Date_Field__c == 'LR_LBI_Period_Stop_Date__c'){
                    record.isDLP = FALSE;
                }else if(projectEvent.PSA_Event__r.Planned_Date_Field__c == 'DLP_Enter_only_for_Aggregate_Reports__c'){
                    record.isDLP = TRUE;
                }
                if(listOfResource.size() > 0){
                    if(listOfResource[0].Name != null && 
                       projectEvent.LR_Project_Overview__c != null
                       && projectEvent.LR_Project_Overview__r.Project__c != null
                       && projectEvent.LR_Project_Overview__r.Project__r.Active_Resources__c != null
                       && (projectEvent.LR_Project_Overview__r.Project__r.Active_Resources__c.contains(currentUserName)
                           || projectEvent.LR_Project_Overview__r.Project__r.Active_Resources__c.contains(listOfResource[0].Name)))
                    {
                        response.add(record); 
                    }
                }
            }
        }
        
        return response; 
    }
    public Class CalendarWrapper{
        @AuraEnabled
        public String lrProjectName{get;set;} 
        @AuraEnabled
        public String lrProjectId{get;set;} 
        @AuraEnabled
        public String eventProjectId{get;set;} 
        @AuraEnabled
        public String eventProjectName{get;set;}  
        @AuraEnabled
        public Date eventDueDate{get;set;} 
        @AuraEnabled
        public Boolean isDLP{get;set;}
    }
}
