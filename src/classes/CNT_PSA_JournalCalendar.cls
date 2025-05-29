public with sharing class CNT_PSA_JournalCalendar {
    
    /**
* This method is check if user have editable permission
*/
    @AuraEnabled
    public static Boolean haveEditablePermission(Id userId) {
        boolean isEditable=false;
        Set<String> fieldSet=new Set<String>{'PermissionSet.Id','PermissionSet.Name'};
        Set<Id> userIDs=new Set<Id>{userId};
        List<PermissionSetAssignment> permissionsets=new SLT_PermissionSetAssignment().selectByUserIds(fieldSet,userIDs);
        for(PermissionSetAssignment pSet:permissionsets){
            if(pSet.permissionSet.Name == CON_PSA.PERMISSION_SET_RDS_ADMIN || pSet.permissionSet.Name == CON_PSA.PERMISSION_SET_RDS_LR_READ_AND_EDIT){
                isEditable = true;
                break;
            }
        }
        return isEditable;   
    }
    @AuraEnabled
    public static String updateReviewDate(List<Event_Journals__c> lstToUpdate) {
        String returnString = 'success';
        try{
            if(lstToUpdate.size() > 0){
                update lstToUpdate;
            } 
        }catch(DMLException e){
            returnString = e.getMessage();
        }
        
        return returnString;
    }
    @AuraEnabled
    public static List<Event_Journals__c> getRecord(List<String>  recordIds) {
        Set<String> ejIds = new Set<String>(recordIds);
        List<Event_Journals__c> ejList = new List<Event_Journals__c>();
        if(ejIds.size() > 0){
            for(Event_Journals__c ej : [ SELECT Id, Review_Dates__c,Frequency_of_Journal__c FROM Event_Journals__c WHERE Id IN : ejIds ]){
                if(ej.Review_Dates__c != null){
                    ejList.add(ej);
                }
            }
        }
        return ejList;
    }
    @AuraEnabled
    public static WPR_PSA_CalendarWrapper getjournals(String nextDate, String status, List<String> ejIdList, String serviceLineProjectId){
        Date startDate;
        Date endDate;
        Set<String> eventJournalFields = new Set<String>{'Id','Frequency_of_Journal__c','Date_Initial_Search_Started__c',
                                                         'Name','Account__c','Product__c','Project__c','LR_Type__c',
                                                         'Date_Next_Journal_Search_is_Due__c','Old_Frequency_of_Journal_Details__c',
                                                         'Review_Dates__c','Date_Last_Journal_Search_was_Performed__c'};
        Set<String> reviewDateSet = new Set<String>(); 
        List<WPR_PSA_ReviewDataExport> journalList = new List<WPR_PSA_ReviewDataExport>();
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Event_Journals__c.Frequency_of_Journal__c.getDescribe();
        List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
        List<Event_Journals__c> eventJournalList;
        List<String> dateFreDetailsList = new List<String>();
        List<String> reviewDateList = new List<String>();
        if(status == CON_PSA.JOURNAL_CALENDAR_VAR_FUTURE || status == CON_PSA.JOURNAL_CALENDAR_VAR_PRESENT){
            if(nextDate != null){
                startDate = Date.valueOf(nextDate);
                endDate= startDate.addDays(70);
            }
        }else if(status == CON_PSA.JOURNAL_CALENDAR_VAR_PAST){
            if(nextDate != null){
                endDate = Date.valueOf(nextDate);
                startDate = endDate.addDays(-63);
            }
        }
        for(Schema.PicklistEntry pickListVal : pickList){
            if(pickListVal.getLabel() != 'N/A' &&  pickListVal.getLabel() != 'Other'){
               pickListValuesList.add(pickListVal.getLabel()); 
            }
        }   
        if(serviceLineProjectId == null || serviceLineProjectId == ''){
            eventJournalList = new SLT_Event_Journals(false,false).getEventJournalsForCalendar(serviceLineProjectId,'Frequency_of_Journal__c != NULL AND Account__c != NULL AND Product__c != NULL AND Project__c != NULL AND LR_Type__c != \'\' AND Is_Clone_Record__c = \'Default\'',eventJournalFields);
        }else{
            eventJournalList = new SLT_Event_Journals(false,false).getEventJournalsForCalendar(serviceLineProjectId,'Frequency_of_Journal__c != NULL AND Account__c != NULL AND Product__c != NULL AND Project__c != NULL AND LR_Type__c != \'\' AND Is_Clone_Record__c = \'Default\' AND Project__c =: serviceLineProjectId',eventJournalFields);
        }
        if(eventJournalList != null && eventJournalList.size()>0){
            for(Event_Journals__c journal : eventJournalList){
                if(journal.Review_Dates__c != null){
                    Set<String> avoidDoubleCheckDate = new Set<String>();
                    for(String reviewDateString : journal.Review_Dates__c.split(',')){
                        if(Date.valueOf(reviewDateString) >= startDate &&  Date.valueOf(reviewDateString) <= endDate){
                            WPR_PSA_ReviewDataExport reviewWrapper = new WPR_PSA_ReviewDataExport();
                            reviewWrapper.Id = journal.Id;
                            reviewWrapper.name = journal.Name;
                            if(journal.Old_Frequency_of_Journal_Details__c != '' && journal.Old_Frequency_of_Journal_Details__c != null){
                                List<String> oldFreDetails = journal.Old_Frequency_of_Journal_Details__c.split(',');
                                if(oldFreDetails.size() > 0){
                                    for(String oldFreDetail : oldFreDetails){
                                        dateFreDetailsList = oldFreDetail.split('/');
                                        if(dateFreDetailsList.size() > 0 && dateFreDetailsList[0] != '' && dateFreDetailsList[1] != ''){
                                            if(Date.valueOf(dateFreDetailsList[0]) >= Date.valueOf(reviewDateString)){
                                                if(!avoidDoubleCheckDate.contains(reviewDateString)){
                                                    avoidDoubleCheckDate.add(reviewDateString);
                                                    reviewWrapper.frequency = dateFreDetailsList[1];  
                                                }
                                            }else{
                                                reviewWrapper.frequency = journal.Frequency_of_Journal__c;  
                                            }  
                                        } 
                                    }
                                }
                            }else{
                                reviewWrapper.frequency = journal.Frequency_of_Journal__c;
                            }
                            reviewWrapper.initialStartDate = journal.Date_Initial_Search_Started__c;
                            reviewWrapper.lastJournalSearchWasPerformed = journal.Date_Last_Journal_Search_was_Performed__c;
                            reviewWrapper.reviewDate = Date.valueOf(reviewDateString);
                            journalList.add(reviewWrapper);
                        }
                    }
                    
                    reviewDateList =  journal.Review_Dates__c.split(',');  
                    if(reviewDateList.size() > 0){
                        reviewDateSet.addAll(reviewDateList);  
                    }
                }
            }
            
        }
        WPR_PSA_CalendarWrapper response = new WPR_PSA_CalendarWrapper();
        response.pickListValuesList=pickListValuesList;
        response.showDates = CNT_PSA_JournalCalendar.getWeeks(String.valueOf(startDate),true, reviewDateSet, String.valueOf(endDate));
        response.dates = CNT_PSA_JournalCalendar.getWeeks(String.valueOf(startDate),false,reviewDateSet, String.valueOf(endDate));
        response.lstJournals=journalList;
        response.relationJournals= new List<String>();                                              
        return response;
    }
    
    public static List<String> getWeeks(String startDate , Boolean isForCreateDate, Set<String> lrReviewDates, String endDate){
        Map<String, String> monthNumberToMonthNameMap = new Map<String, String>{'01' => 'Jan','02' => 'Feb','03' => 'Mar','04' => 'Apr','05' => 'May','06' => 'Jun','07' => 'Jul','08' => 'Aug','09' => 'Sep','10' => 'Oct','11' => 'Nov','12' => 'Dec'};
        List<String> dateList = new List<String>();
        List<String> showDateList = new List<String>();
        Date startingDate = Date.valueOf(startDate);
        for(Integer i = 0; i < 10 ; i++){
            if(!lrReviewDates.contains(String.valueOf(startingDate))){
                dateList.add(String.valueOf(startingDate));
            }
            startingDate = startingDate.addDays(7);
        }
        for(String addReviewDate : lrReviewDates){
            if(Date.valueOf(addReviewDate) <= Date.valueOf(endDate) && Date.valueOf(addReviewDate) >= Date.valueOf(startDate)){
                dateList.add(addReviewDate);
            }
        }
        
        dateList.sort();
        if(isForCreateDate){
            for(String strShowDate : dateList){
                List<String> dateFormat = strShowDate.split('-');
                showDateList.add(String.valueOf(dateFormat[2]+'-'+monthNumberToMonthNameMap.get(dateFormat[1])+'-'+dateFormat[0]));
            }
            return showDateList;
        }
        return dateList;
    }
    
    @AuraEnabled
    public static List<WPR_PSA_ReviewDataExport> getjournalsForExport(String startDate,
                                                                      String endDate,
                                                                      List<String> frequecyList,
                                                                      List<String> ejIdList,
                                                                      String serviceLineProjectId
                                                                      ) 
    {	
        Set<String> eventJournalFields = new Set<String>{'Id','Frequency_of_Journal__c','Date_Initial_Search_Started__c',
                                                         'Name','Account__c','Product__c','Project__c','LR_Type__c',
                                                         'Date_Next_Journal_Search_is_Due__c','Old_Frequency_of_Journal_Details__c',
                                                         'Review_Dates__c','Date_Last_Journal_Search_was_Performed__c'};
        Date startDateValue = Date.valueOf(startDate);
        Date endDateValue  = Date.valueOf(endDate);
        Set<String> frequenciesSet = new Set<String>(frequecyList);
        List<WPR_PSA_ReviewDataExport> responseList = new List<WPR_PSA_ReviewDataExport>();
        List<Event_Journals__c> eventJournalList;
        List<String> oldFreDetailSet= new List<String>();
        List<String> dateFreDetailsList = new List<String>();
        if(serviceLineProjectId == null || serviceLineProjectId == ''){
            eventJournalList = new SLT_Event_Journals(false,false).getEventJournalsForCalendar(serviceLineProjectId,'Frequency_of_Journal__c != NULL AND Account__c != NULL AND Product__c != NULL AND Project__c != NULL AND LR_Type__c != \'\' AND Is_Clone_Record__c = \'Default\'',eventJournalFields);
        }else{
            eventJournalList = new SLT_Event_Journals(false,false).getEventJournalsForCalendar(serviceLineProjectId,'Frequency_of_Journal__c != NULL AND Account__c != NULL AND Product__c != NULL AND Project__c != NULL AND LR_Type__c != \'\' AND Is_Clone_Record__c = \'Default\' AND Project__c =: serviceLineProjectId',eventJournalFields);
        }
        if(eventJournalList != null && eventJournalList.size()>0){
            for(Event_Journals__c journal : eventJournalList){
                if(journal.Review_Dates__c != null){
                    Set<String> avoidDoubleCheckDate = new Set<String>();
                    for(String reviewDateString : journal.Review_Dates__c.split(',')){
                        if(Date.valueOf(reviewDateString) >= startDateValue &&  Date.valueOf(reviewDateString) <= endDateValue){
                            WPR_PSA_ReviewDataExport reviewWrapper = new WPR_PSA_ReviewDataExport();
                            reviewWrapper.Id = journal.Id;
                            reviewWrapper.name = journal.Name;
                            if(journal.Old_Frequency_of_Journal_Details__c != '' && journal.Old_Frequency_of_Journal_Details__c != null){
                                oldFreDetailSet = journal.Old_Frequency_of_Journal_Details__c.split(',');
                                if(oldFreDetailSet.size() > 0){
                                    for(String oldFreDetail : oldFreDetailSet){
                                        dateFreDetailsList = oldFreDetail.split('/');
                                        if(dateFreDetailsList.size() > 0  && dateFreDetailsList[0] != '' && dateFreDetailsList[1] != ''){
                                            if(Date.valueOf(dateFreDetailsList[0]) >= Date.valueOf(reviewDateString)){
                                                if(!avoidDoubleCheckDate.contains(reviewDateString)){
                                                    avoidDoubleCheckDate.add(reviewDateString);
                                                    reviewWrapper.frequency = dateFreDetailsList[1];
                                                }
                                            }else{
                                                reviewWrapper.frequency = journal.Frequency_of_Journal__c;  
                                            }  
                                        } 
                                    }
                                }
                            }else{
                                reviewWrapper.frequency = journal.Frequency_of_Journal__c;
                            }
                            reviewWrapper.initialStartDate = journal.Date_Initial_Search_Started__c;
                            reviewWrapper.lastJournalSearchWasPerformed = journal.Date_Last_Journal_Search_was_Performed__c;
                            reviewWrapper.reviewDate = Date.valueOf(reviewDateString);
                            if(frequenciesSet.contains(reviewWrapper.frequency)){
                                responseList.add(reviewWrapper);
                            }
                        }
                    }
                }  
            } 
        }
        return responseList;
    }
    public with sharing class WPR_PSA_ReviewDataExport{
        @AuraEnabled public String  Id {get;set;}
        @AuraEnabled public String  name {get;set;}
        @AuraEnabled public String frequency {get;set;}
        @AuraEnabled public Date initialStartDate {get;set;}
        @AuraEnabled public Date lastJournalSearchWasPerformed {get;set;}
        @AuraEnabled public Date reviewDate {get;set;}
    }
    
    public with sharing class WPR_PSA_CalendarWrapper{
        @AuraEnabled public List<String> pickListValuesList {get;set;}
        @AuraEnabled public List<String> showDates {get;set;}
        @AuraEnabled public List<String> dates {get;set;}
        @AuraEnabled public List<WPR_PSA_ReviewDataExport> lstJournals{get;set;}
        @AuraEnabled public List<String> relationJournals{get;set;}
        
    }
}