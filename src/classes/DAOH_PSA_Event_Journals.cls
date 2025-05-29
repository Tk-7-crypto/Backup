public class DAOH_PSA_Event_Journals {
    public static void setDefaultFieldsValue(List<Event_Journals__c> newList, Map<Id, Event_Journals__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        for(Event_Journals__c newRec : newList){
            if(Trigger.isUpdate && oldMap.get(newRec.Id).Date_Next_Journal_Search_is_Due__c == newRec.Date_Next_Journal_Search_is_Due__c){
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_BI_ANNUAL){ 
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c.addDays(180);
                }
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_BI_MONTHLY){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c.addDays(60);
                }
                
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_BI_WEEKLY){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c.addDays(14);
                }
                
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_EVERY_9_MONTHS){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c.addDays(270);
                }
                
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_MONTHLY){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c.addDays(30);
                }
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_QUARTERLY){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c.addDays(90);
                }
                
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_WEEKLY){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c.addDays(7);
                }
                
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_YEARLY){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c.addDays(365);
                }
                
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_NA){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c;
                }
                
                if(newRec.Frequency_of_Journal__c == CON_PSA.FREQUENCY_OF_JOURNAL_OTHER){
                    newRec.Date_Next_Journal_Search_is_Due__c = newRec.Date_Last_Journal_Search_was_Performed__c;
                }  
            }else if(Trigger.isUpdate && oldMap.get(newRec.Id).Date_Next_Journal_Search_is_Due__c != newRec.Date_Next_Journal_Search_is_Due__c) {
                if(mulesoftSetting.Ignore_Validation_Rules__c == FALSE && newRec.Date_Next_Journal_Search_is_Due__c < System.today()){
                    newRec.addError('Date Next Journal Search is Due cannot be in the past');
                }
            }
        }
    }
    
    public static void createLREJRelationshipRecord(List<Event_Journals__c> newList, Map<Id, Event_Journals__c> oldMap){
        String keyEj;
        string key;
        Set<Id> projectIdSet = new Set<Id>();
        Map<String, Id> keyToSSMap = new Map<String, Id>();
        Set<String> lrStatus = new Set<String>{CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED, CON_PSA.LR_PROJECT_REVIEW_STATUS_CANCELLED};
        for(Event_Journals__c newRec : newList){
            projectIdSet.add(newRec.Project__c);
            key = newRec.Account__c+''+newRec.Product__c+''+newRec.Project__c+''+newRec.LR_Type__c;
            keyToSSMap.put(key, newRec.Id);
        }
        Map<Id, list<LR_Project_Overview__c>> projectIdToLRListMap = new Map<Id, list<LR_Project_Overview__c>>();
        Set<String> lrFieldSet = new Set<String>{'Id', 'Project__c', 'Account__c', 'Product__c', 'LR_Type__c', 'Status__c'};
        list<LR_Project_Overview__c> lrList = new SLT_LR_Project_Overview().getLRProjectOverViewFROMProjectId(projectIdSet,lrFieldSet);
        for(LR_Project_Overview__c newRec : lrList){
            if(projectIdToLRListMap.containsKey(newRec.Project__c)){
                projectIdToLRListMap.get(newRec.Project__c).add(newRec);
            }else{
                projectIdToLRListMap.put(newRec.Project__c, new List<LR_Project_Overview__c>{newRec});
            }            
        }
        
        List<LR_Event_Journals_Relationship__c> LREJListToCreate = new List<LR_Event_Journals_Relationship__c>();
        for(Event_Journals__c newRec : newList){
            if(projectIdToLRListMap.containsKey(newRec.Project__c)){
                keyEj = newRec.Account__c+''+newRec.Product__c+''+newRec.Project__c+''+newRec.LR_Type__c;
                List<LR_Project_Overview__c> lrList2 = projectIdToLRListMap.get(newRec.Project__c);
                for(LR_Project_Overview__c lrRec : lrList2){
                    if(!lrStatus.contains(lrRec.Status__c)){
                        key  = lrRec.Account__c+''+lrRec.Product__c+''+lrRec.Project__c+''+lrRec.LR_Type__c;
                        if(keyToSSMap.containsKey(key) && keyEj == key){
                            LR_Event_Journals_Relationship__c temp = new LR_Event_Journals_Relationship__c(LR_Project_Overview_M__c = lrRec.Id, Project__c = lrRec.Project__c , Event_Journals_M__c = newRec.Id, Account__c = newRec.Account__c, product__c = newRec.Product__c, LR_Type__c = newRec.LR_Type__c);
                            LREJListToCreate.add(temp);
                        }
                    }
                }                
            }            
        }        
        if(LREJListToCreate.size() > 0){
            insert LREJListToCreate;
        }
    }
    
    public static void deleteLREJRelationshipRecord(List<Event_Journals__c> newList, Map<Id, Event_Journals__c> oldMap){
        // We are Deleting These Record as their Search Strategy has been already Deleted and these records are not Required as these Record are not Valid releationship Record.
        Set<String> fieldSet = new Set<String>{'Id'};
        List<LR_Event_Journals_Relationship__c> lrEJDeleteRecord = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipDataWhereEJIdNull(fieldSet);
        delete lrEJDeleteRecord;
    }
    public static void setDefaultFieldsValueOfReviewDate(List<Event_Journals__c> newList, Map<Id, Event_Journals__c> oldMap){
        String dayOfWeek ='';
        Integer weekDay;
        List<String> reviewDateList = new List<String>();
        List<String> previousDatesList = new List<String>();
        List<String> reviewDatesList = new List<String>();
        List<String> reviewDatesNext5YearList = new List<String>();
        for(Event_Journals__c ej : newList){
            if(ej.Date_Initial_Search_Started__c != null 
               && ej.Frequency_of_Journal__c != null 
               && (Trigger.isInsert
                   || (Trigger.isUpdate && ej.Date_Initial_Search_Started__c != oldMap.get( ej.Id).Date_Initial_Search_Started__c)))
            {
                reviewDatesList = getReviewDates(String.valueOf(ej.Date_Initial_Search_Started__c), ej.Frequency_of_Journal__c, true);
                ej.Review_Dates__c = '';
                ej.Review_Dates__c = String.join(reviewDatesList, ',');
                ej.Old_Frequency_of_Journal_Details__c = '';
                weekDay = getWeekDay(ej.Date_Initial_Search_Started__c);
                dayOfWeek = (CON_PSA.weekDayNumberToWeekDayMap.containsKey(weekDay) && CON_PSA.weekDayNumberToWeekDayMap.get(weekDay) != null) ? CON_PSA.weekDayNumberToWeekDayMap.get(weekDay) : '';
                ej.Date_Initial_Search_Started__c = calculateDate(dayOfWeek, ej.Date_Initial_Search_Started__c) != null ? calculateDate(dayOfWeek, ej.Date_Initial_Search_Started__c) : ej.Date_Initial_Search_Started__c;
            }
            if(Trigger.isUpdate 
               && ej.Date_Last_Journal_Search_was_Performed__c != null 
               && ej.Frequency_of_Journal__c != oldMap.get(ej.Id).Frequency_of_Journal__c
               && ej.Date_Initial_Search_Started__c == oldMap.get(ej.Id).Date_Initial_Search_Started__c
              ){
                  if(ej.Review_Dates__c != ''){
                      previousDatesList = ej.Review_Dates__c.split(',');
                  }  
                  for(String reviewDate : previousDatesList){
                      if(Date.valueOf(reviewDate) <= ej.Date_Last_Journal_Search_was_Performed__c){
                          reviewDateList.add(reviewDate);
                      }
                  }
                  if(reviewDateList.size() > 0){
                      reviewDatesNext5YearList = getReviewDates(String.valueOf(Date.valueOf(reviewDateList[reviewDateList.size()-1])), ej.Frequency_of_Journal__c, false);
                      if(ej.Old_Frequency_of_Journal_Details__c == null){
                          ej.Old_Frequency_of_Journal_Details__c = reviewDateList[reviewDateList.size()-1]+'/'+oldMap.get(ej.Id).Frequency_of_Journal__c;  
                      }else{
                          ej.Old_Frequency_of_Journal_Details__c += ','+reviewDateList[reviewDateList.size()-1]+'/'+oldMap.get(ej.Id).Frequency_of_Journal__c;
                      }
                      reviewDateList.addAll(reviewDatesNext5YearList);
                      ej.Review_Dates__c = String.join(reviewDateList, ',');
                      
                  }else{
                      if(ej.Date_Initial_Search_Started__c != null){
                          reviewDatesNext5YearList = getReviewDates(String.valueOf(ej.Date_Initial_Search_Started__c), ej.Frequency_of_Journal__c, true);
                          reviewDateList.addAll(reviewDatesNext5YearList);
                          ej.Review_Dates__c = String.join(reviewDateList, ',');
                          ej.Old_Frequency_of_Journal_Details__c = '';
                      }
                  }
              }
        }
    }
    public static List<String> getReviewDates(String startDate, String frequency, Boolean isStartDateAdded){
        Integer weekDay;
        Integer count = 0;
        Integer repeat = 0;
        List< String> dates = new List< String>();
        Date startingDate = Date.valueOf(startDate);
        Date conditionStartingDate = startingDate;
        Date nextDate;
        String dayOfWeek =''; 
        
        if(CON_PSA.frequencyToDaysMap.get(frequency) != null){
           count = CON_PSA.frequencyToDaysMap.get(frequency);   
        }   
        
        if(CON_PSA.frequencyToRepeatMap.get(frequency) != null){
            repeat = CON_PSA.frequencyToRepeatMap.get(frequency);   
        }
        
        if(isStartDateAdded){
            dates.add(String.valueOf(startingDate));  
        }
        for(Integer i= 0; i < repeat ; i++){
            startingDate = startingDate.addDays(count);
            nextDate = startingDate;
            if(!dates.contains(String.valueOf(startingDate))){
                weekDay = getWeekDay(startingDate);
                dayOfWeek = (CON_PSA.weekDayNumberToWeekDayMap.containsKey(weekDay) && CON_PSA.weekDayNumberToWeekDayMap.get(weekDay) != null) ? CON_PSA.weekDayNumberToWeekDayMap.get(weekDay) : '';
                if(dayOfWeek == CON_PSA.FRIDAY || dayOfWeek == CON_PSA.SATURDAY || dayOfWeek == CON_PSA.SUNDAY){
                    conditionStartingDate = calculateDate(dayOfWeek, nextDate) != null ? calculateDate(dayOfWeek, nextDate) : conditionStartingDate;
                    if(!dates.contains(String.valueOf(conditionStartingDate))){
                        dates.add(String.valueOf(conditionStartingDate)); 
                    }
                }else{
                    dates.add(String.valueOf(startingDate)); 
                }
            }
        }
        dates.sort();
        return dates;
    }
    /**
    * This method used for getWeekDay
    **/
    public static Integer getWeekDay(Date dueDate){
        return math.mod(Date.newInstance(1900, 1, 7).daysBetween(dueDate), 7);
    }
    
    /**
    * This method used for calculateDate
    **/
    public static Date calculateDate(String dayOfWeek, Date nextDate){
        Date dateCalculate;
        if(dayOfWeek == CON_PSA.FRIDAY){
            dateCalculate = nextDate.addDays(3);
        }else if(dayOfWeek == CON_PSA.SATURDAY){
            dateCalculate = nextDate.addDays(2);
        }else if(dayOfWeek == CON_PSA.SUNDAY){
            dateCalculate = nextDate.addDays(1);
        }
        return dateCalculate;
    }
    
    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Drug
    **/
    public static void insertAuditLog(List<Event_Journals__c> insertList, String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList, operation);
    }
    
    /**
    * This method will insert record in Audit Log on Inserting/Updating Drug
    **/
    public static void insertAuditLogOnUpdate(List<Event_Journals__c> updatedList, Map<Id, Event_Journals__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList, existingRecords);
    }
}
