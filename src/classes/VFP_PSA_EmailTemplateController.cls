public without sharing class VFP_PSA_EmailTemplateController {
    public String recordId{get;set;} 
    public String fieldName{get;set;} 
    public VFP_PSA_EmailTemplateController(){ 
    }
    
    public string getEmailBody(){
        String dataToDisplay = '';
        if(recordId != null && Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Project_Event__c'){
            dataToDisplay = getProjectEventEmailBody();            
        } else if(recordId != null && Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Aggregate_Report__c'){
            dataToDisplay = getAggregateReportEmailBody();
            
        }
        return dataToDisplay; 
    }
    private string getProjectEventEmailBody() {
        String dataToDisplay = '';
        List<Project_Event__History> records = [SELECT Id, ParentId,  Field, DataType, OldValue, NewValue 
                                                from Project_Event__History 
                                                where CreatedDate = TODAY 
                                                and ParentId =: recordId ORDER BY CreatedDate DESC];
        
        List<Project_Event__c> projectEvents = [Select Id, Event_Due_Date__c, Notification_Date__c, Event_Actual_Date__c, Event_Name__c
                                                From Project_Event__c 
                                                WHERE Id =: recordId ];
        
        if(projectEvents.size() > 0){
            Project_Event__c projectEvent =projectEvents[0];
            Map<String, Project_Event__History> fieldUpdates = new Map<String, Project_Event__History>();
            fieldUpdates.put('Event_Due_Date__c', null);
            
            for(Project_Event__History  peHistory : records) {
                if(fieldUpdates.containsKey(peHistory.Field) && fieldUpdates.get(peHistory.Field) == null) {
                    fieldUpdates.put(peHistory.Field, peHistory);
                }
            }  
            
            DateTime dueDate;
            String formattedDate;
            Project_Event__History history = fieldUpdates.get('Event_Due_Date__c');
            if(history != null && projectEvent.Event_Due_Date__c != history.NewValue 
               && projectEvent.Event_Name__c == 'Planned Date for Medical Review Sent') {
                dueDate = Date.valueOf(history.NewValue);
                formattedDate = dueDate.format('MM/dd/yyyy');
                dataToDisplay += 'Old Due Date: ' + formattedDate + '<br/>';
                dueDate = projectEvent.Event_Due_Date__c;
                formattedDate = dueDate.format('MM/dd/yyyy'); 
                dataToDisplay += 'New Due Date: ' + formattedDate + '<br/>';
            } else {
                dataToDisplay += 'Due Date: ';
                dueDate = projectEvent.Event_Due_Date__c;
                formattedDate = dueDate.format('MM/dd/yyyy'); 
                dataToDisplay += projectEvent.Event_Due_Date__c != null ? formattedDate : '';
                dataToDisplay +='<br />';
            }
            
        }
        return dataToDisplay;
    }
    
 Private string getAggregateReportEmailBody() {
        String dataToDisplay = '';
        Set<String> emailSet = new Set<String>();
        List<Contact> contactList = new List<Contact>();
        List<Aggregate_Report__c> AggregateReports = [Select Id, Prior_Primary_Medical_Reviewer_Email__c, Prior_Secondary_Medical_Reviewer_Email__c 
                                                      From Aggregate_Report__c 
                                                      WHERE Id =: recordId ];
        
        
        if(!AggregateReports.isEmpty()){
            if(AggregateReports[0].Prior_Primary_Medical_Reviewer_Email__c != null
               && fieldName == 'Primary_Medical_Reviewer__c'){
                emailSet.add(AggregateReports[0].Prior_Primary_Medical_Reviewer_Email__c); 
            }
            if(AggregateReports[0].Prior_Secondary_Medical_Reviewer_Email__c != null 
               && fieldName == 'Secondary_Medical_Reviewer__c'){
                emailSet.add(AggregateReports[0].Prior_Secondary_Medical_Reviewer_Email__c); 
            }
        }
        if(!emailSet.isEmpty()){
            contactList = [Select id,Email,Name From Contact Where Email IN :emailSet];
            for(Contact con : contactList){
                if(AggregateReports[0].Prior_Primary_Medical_Reviewer_Email__c == con.Email 
                   && emailSet.contains(AggregateReports[0].Prior_Primary_Medical_Reviewer_Email__c)
                   && fieldName == 'Primary_Medical_Reviewer__c')
                {
                    dataToDisplay = '';
                    dataToDisplay+= 'The old Primary Medical Reviewer is: '+con.Name+'<br/>';
                }
                else if(AggregateReports[0].Prior_Secondary_Medical_Reviewer_Email__c == con.Email 
                   && emailSet.contains(AggregateReports[0].Prior_Secondary_Medical_Reviewer_Email__c)
                   && fieldName == 'Secondary_Medical_Reviewer__c')
                {
                    dataToDisplay = '';
                    dataToDisplay+= 'The old Secondary Medical Reviewer is: '+con.Name+'<br/>';
                }
            }
        }
        return dataToDisplay;
    }
}
