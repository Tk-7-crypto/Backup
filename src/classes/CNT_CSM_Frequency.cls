public class CNT_CSM_Frequency {

    @AuraEnabled
    public static List<SObject> getParentRecord(String objName, Id recordId){
        List<SObject> objects = new List<SObject>();
        if(objName == 'CSM_QI_CaseAutomationScheduler__c'){
            objects = new SLT_CaseAutomationScheduler().selectById(new Set<Id> {recordId});
        }
        return objects;
    }
    
    @AuraEnabled
    public static List<CSM_QI_Frequency__c> fetchFrequencyRecord(Id frequencyId){
        List<CSM_QI_Frequency__c> frequencyList = new List<CSM_QI_Frequency__c>();
        frequencyList = new SLT_Frequency().selectById(new Set<Id>{frequencyId});
        return frequencyList;
    }
    
    @AuraEnabled
    public static void saveFrequency(String jsonString, Id recordId){
        CSM_QI_Frequency__c frequencyRecord = (CSM_QI_Frequency__c)JSON.deserialize(jsonString, CSM_QI_Frequency__c.class);
        List<CSM_QI_Frequency__c> frequencyList = new List<CSM_QI_Frequency__c>();
        CSM_QI_Frequency__c newRecord = new CSM_QI_Frequency__c();
        newRecord.Frequency__c = frequencyRecord.Frequency__c;
        if(frequencyRecord.Frequency__c == CON_CSM.S_FREQUENCY_WEEKLY){
            newRecord.Weekday__c = frequencyRecord.Weekday__c;
        }
        else if(frequencyRecord.Frequency__c == CON_CSM.S_FREQUENCY_MONTHLY){
            newRecord.Month_Interval__c = frequencyRecord.Month_Interval__c;
            if(frequencyRecord.Month_Date__c != null && frequencyRecord.Month_Date__c != ''){
                newRecord.Month_Date__c = frequencyRecord.Month_Date__c;
            }
            else if((frequencyRecord.Week__c != null && frequencyRecord.Week__c != '') && 
                    (frequencyRecord.Weekday__c != null && frequencyRecord.Weekday__c != '')){
                        newRecord.Week__c = frequencyRecord.Week__c;
                        newRecord.Weekday__c = frequencyRecord.Weekday__c;
                    }
        }
        frequencyList.add(newRecord);
        if(frequencyList != null && !frequencyList.isEmpty()){
            insert frequencyList;
            CSM_QI_Frequency__c freqRecord = frequencyList[0];
            List<CSM_QI_CaseAutomationScheduler__c> automationList = new SLT_CaseAutomationScheduler().selectById(new Set<Id>{recordId});
            if(automationList != null && !automationList.isEmpty()){
                List<CSM_QI_CaseAutomationScheduler__c> newList = new List<CSM_QI_CaseAutomationScheduler__c>();
                CSM_QI_CaseAutomationScheduler__c automationRecord = automationList[0];
                automationRecord.FrequencyId__c = freqRecord.Id;
                if(freqRecord.Month_Interval__c == '3'){
                    automationRecord.Frequency__c = CON_CSM.S_FREQUENCY_QUARTERLY;
                }
                else{
                    automationRecord.Frequency__c = freqRecord.Frequency__c;
                }
                automationRecord = calculateNextDate(automationRecord, freqRecord, CON_CSM.S_INTERNAL_EXECUTED);
                newList.add(automationRecord);
                if(newList != null && !newList.isEmpty()){
                    update newList;
                }
            }
        }
    }
    
    public static CSM_QI_CaseAutomationScheduler__c calculateNextDate(CSM_QI_CaseAutomationScheduler__c automationRecord, CSM_QI_Frequency__c frequencyRecord, String executedFrom){
        Datetime currentDate = Date.today();
        Datetime startDate;
        if(executedFrom == CON_CSM.S_INTERNAL_EXECUTED){
            startDate = automationRecord.Start_Date__c;
        }
        else if(executedFrom == CON_CSM.S_BATCH_EXECUTED){
            startDate = automationRecord.Next_Run_Date__c;
        }
        Map<String, Integer> weekMap = new Map<String, Integer>();
        weekMap.put('Sunday', 1); 
        weekMap.put('Monday', 2); 
        weekMap.put('Tuesday', 3); 
        weekMap.put('Wednesday', 4);
        weekMap.put('Thursday', 5); 
        weekMap.put('Friday', 6); 
        weekMap.put('Saturday', 7);
        List<Integer> thirtyOneDaysMonth = new List<Integer>{1, 3, 5, 7, 8, 10, 12};
        List<Integer> thirtyDaysMonth = new List<Integer>{4, 6, 9, 11};
            
        if(frequencyRecord.Frequency__c == CON_CSM.S_FREQUENCY_DAILY){
            Date nextDate;
            if(startDate > currentDate){
                automationRecord = nextDateOnStartDateDailyFrequency(nextDate, startDate, frequencyRecord, automationRecord);
            }
            else if(startDate == currentDate){
                automationRecord = nextDateOnDailyFrequency(nextDate, startDate, frequencyRecord, automationRecord);
            }
            else if(startDate < currentDate){
                automationRecord = nextDateOnDailyFrequency(nextDate, currentDate, frequencyRecord, automationRecord);
            }
        }
        else if(frequencyRecord.Frequency__c == CON_CSM.S_FREQUENCY_WEEKLY){
            Date nextDate;
            if(startDate > currentDate){
                automationRecord = nextDateOnWeeklyFrequency(nextDate, startDate, frequencyRecord, automationRecord, weekMap);
            }
            else if(startDate == currentDate){
                String startWeekday = startDate.format('EEEE');
                String freqWeekday = frequencyRecord.Weekday__c;
                if(weekMap.get(startWeekday) >= weekMap.get(freqWeekday)){
                    nextDate = startDate.date();
                    Date weekStartDate = nextDate.toStartOfWeek();
                    Date tempDate = weekStartDate+6+(weekMap.get(freqWeekday));
                    automationRecord.Next_Run_Date__c = tempDate;
                }
                else if(weekMap.get(startWeekday) < weekMap.get(freqWeekday)){
                    nextDate = startDate.date();
                    Date weekStartDate = nextDate.toStartOfWeek();
                    Date tempDate = (weekStartDate-1)+(weekMap.get(freqWeekday));
                    automationRecord.Next_Run_Date__c = tempDate;
                }
            }
            else if(startDate < currentDate){
                automationRecord = nextDateOnWeeklyFrequency(nextDate, currentDate, frequencyRecord, automationRecord, weekMap);
            }
        }
        else if(frequencyRecord.Frequency__c == CON_CSM.S_FREQUENCY_MONTHLY){
            if(frequencyRecord.Month_Interval__c == '1'){
                if(frequencyRecord.Month_Date__c != null && frequencyRecord.Month_Date__c != ''){
                    if(startDate >= currentDate){
                        automationRecord = nextDateOnMonthlyDateFrequency(startDate, frequencyRecord, automationRecord, thirtyDaysMonth, thirtyOneDaysMonth);
                    }
                    else if(startDate < currentDate){
                        automationRecord = nextDateOnMonthlyDateFrequency(currentDate, frequencyRecord, automationRecord, thirtyDaysMonth, thirtyOneDaysMonth);
                    }
                }
                else if((frequencyRecord.Week__c != null && frequencyRecord.Week__c != '') && (frequencyRecord.Weekday__c != null && frequencyRecord.Weekday__c != '')){
                    if(startDate >= currentDate){
                        automationRecord = nextDateOnMonthlyWeekFrequency(startDate, frequencyRecord, automationRecord, thirtyDaysMonth, thirtyOneDaysMonth, weekMap);
                    }
                    else if(startDate < currentDate){
                        automationRecord = nextDateOnMonthlyWeekFrequency(currentDate, frequencyRecord, automationRecord, thirtyDaysMonth, thirtyOneDaysMonth, weekMap);
                    }
                }
            }
            else if(frequencyRecord.Month_Interval__c == '3'){
                if(frequencyRecord.Month_Date__c != null && frequencyRecord.Month_Date__c != ''){
                    if(startDate >= currentDate){
                        automationRecord = nextDateOnQuarterlyDateFrequency(startDate, frequencyRecord, automationRecord);
                    }
                    else if(startDate < currentDate){
                        automationRecord = nextDateOnQuarterlyDateFrequency(currentDate, frequencyRecord, automationRecord);
                    }
                }
                else if((frequencyRecord.Week__c != null && frequencyRecord.Week__c != '') && (frequencyRecord.Weekday__c != null && frequencyRecord.Weekday__c != '')){
                    if(startDate >= currentDate){
                        automationRecord = nextDateOnQuarterlyWeekFrequency(startDate, frequencyRecord, automationRecord, weekMap);
                    }
                    else if(startDate < currentDate){
                        automationRecord = nextDateOnQuarterlyWeekFrequency(currentDate, frequencyRecord, automationRecord, weekMap);
                    }
                }
            }
        }
        return automationRecord;
    }
    
    private static Integer getWeekOfMonth(Date weekDate){
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
        
        Date beginDate = weekDate.toStartOfMonth().addDays(-1);
        Date firstWeekend = beginDate.toStartOfWeek().addDays(6);
        startWeekResidue = beginDate.daysBetween(firstWeekend);
        
        Date lastWeekend = weekDate.toStartOfWeek().addDays(-1);
        endWeekResidue = lastWeekend.daysBetween(weekDate);
        
        weekCount = (weekDate.day() - (startWeekResidue + endWeekResidue))/7;
        weekCount += (startWeekResidue > 0 ? 1:0)+(endWeekResidue > 0 ? 1:0);
        return weekCount;
    }
    
    public static CSM_QI_CaseAutomationScheduler__c nextDateOnStartDateDailyFrequency(Date nextDate, Datetime startDate, CSM_QI_Frequency__c frequencyRecord, CSM_QI_CaseAutomationScheduler__c automationRecord){
        Datetime tempStartDate;
        if(startDate.format('EEEE') == 'Saturday'){
            tempStartDate = startDate + 2;
        }
        else if(startDate.format('EEEE') == 'Sunday'){
            tempStartDate = startDate + 1;
        }
        else{
            tempStartDate = startDate;
        }
        nextDate = tempStartDate.date();
        automationRecord.Next_Run_Date__c = nextDate;
        return automationRecord;
    }
    
    private static CSM_QI_CaseAutomationScheduler__c nextDateOnDailyFrequency(Date nextDate, Datetime startDate, CSM_QI_Frequency__c frequencyRecord, CSM_QI_CaseAutomationScheduler__c automationRecord){
        Datetime tempStartDate;
        if(startDate.format('EEEE') == 'Friday'){
            tempStartDate = startDate + 3;
        }
        else if(startDate.format('EEEE') == 'Saturday'){
            tempStartDate = startDate + 2;
        }
        else{
            tempStartDate = startDate + 1;
        }
        nextDate = tempStartDate.date();
        automationRecord.Next_Run_Date__c = nextDate;
        return automationRecord;
    }
    
    private static CSM_QI_CaseAutomationScheduler__c nextDateOnWeeklyFrequency(Date nextDate, Datetime startDate, CSM_QI_Frequency__c frequencyRecord, CSM_QI_CaseAutomationScheduler__c automationRecord, Map<String, Integer> weekMap){
        String startWeekday = startDate.format('EEEE');
        String freqWeekday = frequencyRecord.Weekday__c;
        if(weekMap.get(startWeekday) > weekMap.get(freqWeekday)){
            nextDate = startDate.date();
            Date weekStartDate = nextDate.toStartOfWeek();
            Date tempDate = weekStartDate+6+(weekMap.get(freqWeekday));
            automationRecord.Next_Run_Date__c = tempDate;
        }
        else if(weekMap.get(startWeekday) == weekMap.get(freqWeekday)){
            nextDate = startDate.date();
            automationRecord.Next_Run_Date__c = nextDate;
        }
        else if(weekMap.get(startWeekday) < weekMap.get(freqWeekday)){
            nextDate = startDate.date();
            Date weekStartDate = nextDate.toStartOfWeek();
            Date tempDate = (weekStartDate-1)+(weekMap.get(freqWeekday));
            automationRecord.Next_Run_Date__c = tempDate;
        }
        return automationRecord;
    }
    
    private static CSM_QI_CaseAutomationScheduler__c nextDateOnMonthlyDateFrequency(Datetime startDate, CSM_QI_Frequency__c frequencyRecord, CSM_QI_CaseAutomationScheduler__c automationRecord, List<Integer> thirtyDaysMonth, List<Integer> thirtyOneDaysMonth){
        Integer startDay = startDate.day();
        Integer startMonth = startDate.month();
        Integer startYear = startDate.year();
        Integer nextMonth;
        Date tempDate;
        Integer nextYear;
        if(!frequencyRecord.Month_Date__c.equalsIgnoreCase('last')){
            Integer monthDay = Integer.valueOf(frequencyRecord.Month_Date__c.trim());
            if(startDay >= monthDay){
                if(startMonth != 12){
                    nextMonth = startMonth + 1;
                    if((nextMonth == 2 && monthDay > 28) || (thirtyDaysMonth.contains(nextMonth) && monthDay == 31)){
                        nextMonth = nextMonth + 1;
                    }
                    tempDate = Date.parse(nextMonth+'/'+monthDay+'/'+startYear);
                }
                else{
                    nextMonth = 1;
                    nextYear = startYear + 1;
                    tempDate = Date.parse(nextMonth+'/'+monthDay+'/'+nextYear);
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
            else if(startDay < monthDay){
                tempDate = Date.parse(startMonth+'/'+monthDay+'/'+startYear);
                automationRecord.Next_Run_Date__c = tempDate;
            }
        }
        else if(frequencyRecord.Month_Date__c.equalsIgnoreCase('last')){
            Integer lastDay;
            if(thirtyDaysMonth.contains(startMonth)){
                lastDay = 30;
                if(startDay == lastDay){
                    nextMonth = startMonth + 1;
                    if(thirtyOneDaysMonth.contains(nextMonth)){
                        lastDay = 31;
                    }
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                    automationRecord.Next_Run_Date__c = tempDate;
                }
                else if(startDay < lastDay){
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                    automationRecord.Next_Run_Date__c = tempDate;
                }
            }
            else if(thirtyOneDaysMonth.contains(startMonth)){
                lastDay = 31;
                if(startDay == lastDay){
                    if(startMonth != 12){
                        nextMonth = startMonth + 1;
                        if(nextMonth == 2){
                            if(Date.isLeapYear(startYear)){
                                lastDay = 29;
                            }
                            else{
                                lastDay = 28;
                            }
                        }
                        else if(thirtyDaysMonth.contains(nextMonth)){
                            lastDay = 30;
                        }
                        tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                        automationRecord.Next_Run_Date__c = tempDate;
                    }
                    else{
                        nextMonth = 1;
                        nextYear = startYear + 1;
                        tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+nextYear);
                        automationRecord.Next_Run_Date__c = tempDate;
                    }
                }
                else if(startDay < lastDay){
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                    automationRecord.Next_Run_Date__c = tempDate;
                }
            }
            else if(Date.isLeapYear(startYear)){
                lastDay = 29;
                if(startDay == lastDay){
                    nextMonth = 3;
                    lastDay = 31;
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                    automationRecord.Next_Run_Date__c = tempDate;
                }
                else if(startDay < lastDay){
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                    automationRecord.Next_Run_Date__c = tempDate;
                }
            }
            else{
                lastDay = 28;
                if(startDay == lastDay){
                    nextMonth = 3;
                    lastDay = 31;
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                    automationRecord.Next_Run_Date__c = tempDate;
                }
                else if(startDay < lastDay){
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                    automationRecord.Next_Run_Date__c = tempDate;
                }
            }
        }
        return automationRecord;
    }
    
    private static CSM_QI_CaseAutomationScheduler__c nextDateOnMonthlyWeekFrequency(Datetime startDate, CSM_QI_Frequency__c frequencyRecord, CSM_QI_CaseAutomationScheduler__c automationRecord, List<Integer> thirtyDaysMonth, List<Integer> thirtyOneDaysMonth, Map<String, Integer> weekMap){
        Date tempDate;
        Date nextDate;
        Integer nextMonth;
        Integer nextYear;
        Date weekStartDate;
        Integer startMonth = startDate.month();
        Integer startYear = startDate.year();
        if(!frequencyRecord.Week__c.equalsIgnoreCase('last')){
            Integer week = Integer.valueOf(frequencyRecord.Week__c.trim());
            Date tempStartDate = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
            Integer startWeek = getWeekOfMonth(tempStartDate);
            String weekDay = frequencyRecord.Weekday__c;
            String startWeekDay = startDate.format('EEEE');
            if(startWeek > week){
                if(startMonth != 12){
                    nextMonth = startMonth + 1;
                    tempDate = Date.parse(nextMonth+'/'+1+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    Integer nextWeek = getWeekOfMonth(tempDate);
                    Datetime tempDatetime = (Datetime)tempDate;
                    String tempWeekDay = tempDatetime.format('EEEE');
                    If(nextWeek == week){
                        if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        }
                        else{
                            nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                        }
                    }
                    else if(nextWeek < week){
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 12){
                    nextMonth = 1;
                    nextYear = startYear + 1;
                    tempDate = Date.parse(nextMonth+'/'+1+'/'+nextYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    Integer nextWeek = getWeekOfMonth(tempDate);
                    Datetime tempDatetime = (Datetime)tempDate;
                    String tempWeekDay = tempDatetime.format('EEEE');
                    If(nextWeek == week){
                        if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        }
                        else{
                            nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                        }
                    }
                    else if(nextWeek < week){
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
            }
            else if(startWeek == week){
                if(weekMap.get(startWeekDay) >= weekMap.get(weekDay)){
                    if(startMonth != 12){
                        nextMonth = startMonth + 1;
                        tempDate = Date.parse(nextMonth+'/'+1+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        Integer nextWeek = getWeekOfMonth(tempDate);
                        Datetime tempDatetime = (Datetime)tempDate;
                        String tempWeekDay = tempDatetime.format('EEEE');
                        If(nextWeek == week){
                            if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            }
                            else{
                                nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                            }
                        }
                        else if(nextWeek < week){
                            nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        }
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                    else{
                        nextMonth = 1;
                        nextYear = startYear + 1;
                        tempDate = Date.parse(nextMonth+'/'+1+'/'+nextYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        Integer nextWeek = getWeekOfMonth(tempDate);
                        Datetime tempDatetime = (Datetime)tempDate;
                        String tempWeekDay = tempDatetime.format('EEEE');
                        If(nextWeek == week){
                            if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            }
                            else{
                                nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                            }
                        }
                        else if(nextWeek < week){
                            nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        }
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                }
                else{
                    Date temp = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                    weekStartDate = temp.toStartOfWeek();
                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                }
                automationRecord.Next_Run_Date__c = nextDate;
            }
            else if(startWeek < week){
                Date temp = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                tempDate = temp.toStartOfMonth();
                weekStartDate = tempDate.toStartOfWeek();
                nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                automationRecord.Next_Run_Date__c = nextDate;
            }
        }
        else if(frequencyRecord.Week__c.equalsIgnoreCase('last')){
            Integer lastDay;
            String weekDay = frequencyRecord.Weekday__c;
            if(thirtyDaysMonth.contains(startMonth)){
                lastDay = 30;
                tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
            }
            else if(thirtyOneDaysMonth.contains(startMonth)){
                lastDay = 31;
                tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
            }
            else{
                if(Date.isLeapYear(startYear)){
                    lastDay = 29;
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                }
                else{
                    lastDay = 28;
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                }
            }
            weekStartDate = tempDate.toStartOfWeek();
            Date midDate = (weekStartDate - 1) + weekMap.get(weekDay);
            if(startMonth != midDate.month()){
                midDate = midDate - 7;
            }
            if(startDate >= midDate){
                if(startMonth != 12){
                    nextMonth = startMonth + 1;
                    if(thirtyDaysMonth.contains(nextMonth)){
                        lastDay = 30;
                    }
                    else if(thirtyOneDaysMonth.contains(nextMonth)){
                        lastDay = 31;
                    }
                    else if(Date.isLeapYear(startYear)){
                        lastDay = 29;
                    }
                    else{
                        lastDay = 28;
                    }
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(nextDate.month() != nextMonth){
                        nextDate = nextDate - 7;
                    }
                }
                else if(startMonth == 12){
                    nextMonth = 1;
                    nextYear = startYear + 1;
                    lastDay = 31;
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+nextYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(nextDate.month() != nextMonth){
                        nextDate = nextDate - 7;
                    }
                }
                automationRecord.Next_Run_Date__c = nextDate;
            }
            else if(startDate < midDate){
                nextDate = midDate;
            }
            automationRecord.Next_Run_Date__c = nextDate;
        }
        return automationRecord;
    }
    
    public static CSM_QI_CaseAutomationScheduler__c nextDateOnQuarterlyDateFrequency(Datetime startDate, CSM_QI_Frequency__c frequencyRecord, CSM_QI_CaseAutomationScheduler__c automationRecord){
        List<Integer> quarterOne = new List<Integer>{1, 2, 3};
        List<Integer> quarterTwo = new List<Integer>{4, 5, 6};
        List<Integer> quarterThree = new List<Integer>{7, 8, 9};
        List<Integer> quarterFour = new List<Integer>{10, 11, 12};
        Integer quarterMonth;
        Date tempDate;
        Integer startDay = startDate.day();
        Integer startMonth = startDate.month();
        Integer startYear = startDate.year();
        if(!frequencyRecord.Month_Date__c.equalsIgnoreCase('last')){
            Integer monthDay = Integer.valueOf(frequencyRecord.Month_Date__c.trim());
            if(quarterOne.contains(startMonth)){
                if(startMonth != 3){
                    quarterMonth = 3;
                    tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                }
                else{
                    if(startDay >= monthDay){
                        quarterMonth = 6;
                        tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                    }
                    else if(startDay < monthDay){
                        quarterMonth = 3;
                        tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                    }
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
            else if(quarterTwo.contains(startMonth)){
                if(startMonth != 6){
                    quarterMonth = 6;
                    tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                }
                else{
                    if(startDay >= monthDay){
                        quarterMonth = 9;
                        tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                    }
                    else if(startDay < monthDay){
                        quarterMonth = 6;
                        tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                    }
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
            else if(quarterThree.contains(startMonth)){
                if(startMonth != 9){
                    quarterMonth = 9;
                    tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                }
                else{
                    if(startDay >= monthDay){
                        quarterMonth = 12;
                        tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                    }
                    else if(startDay < monthDay){
                        quarterMonth = 9;
                        tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                    }
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
            else if(quarterFour.contains(startMonth)){
                if(startMonth != 12){
                    quarterMonth = 12;
                    tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                }
                else{
                    if(startDay >= monthDay){
                        Integer nextYear = startYear + 1;
                        quarterMonth = 3;
                        tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+nextYear);
                    }
                    else if(startDay < monthDay){
                        quarterMonth = 12;
                        tempDate = Date.parse(quarterMonth+'/'+monthDay+'/'+startYear);
                    }
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
        }
        else if(frequencyRecord.Month_Date__c.equalsIgnoreCase('last')){
            Integer lastDay;
            if(quarterOne.contains(startMonth)){
                lastDay = 31;
                if(startMonth != 3){
                    quarterMonth = 3;
                    tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                }
                else{
                    if(startDay == lastDay){
                        lastDay = 30;
                        quarterMonth = 6;
                        tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                    }
                    else if(startDay < lastDay){
                        quarterMonth = 3;
                        tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                    }
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
            else if(quarterTwo.contains(startMonth)){
                lastDay = 30;
                if(startMonth != 6){
                    quarterMonth = 6;
                    tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                }
                else{
                    if(startDay == lastDay){
                        lastDay = 30;
                        quarterMonth = 9;
                        tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                    }
                    else if(startDay < lastDay){
                        quarterMonth = 3;
                        tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                    }
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
            else if(quarterThree.contains(startMonth)){
                lastDay = 30;
                if(startMonth != 9){
                    quarterMonth = 9;
                    tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                }
                else{
                    if(startDay == lastDay){
                        lastDay = 31;
                        quarterMonth = 12;
                        tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                    }
                    else if(startDay < lastDay){
                        quarterMonth = 9;
                        tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                    }
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
            else if(quarterFour.contains(startMonth)){
                lastDay = 31;
                if(startMonth != 12){
                    quarterMonth = 12;
                    tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                }
                else{
                    if(startDay == lastDay){
                        lastDay = 31;
                        quarterMonth = 3;
                        Integer nextYear = startYear + 1;
                        tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+nextYear);
                    }
                    else if(startDay < lastDay){
                        quarterMonth = 12;
                        tempDate = Date.parse(quarterMonth+'/'+lastDay+'/'+startYear);
                    }
                }
                automationRecord.Next_Run_Date__c = tempDate;
            }
        }
        return automationRecord;
    }
    
    public static CSM_QI_CaseAutomationScheduler__c nextDateOnQuarterlyWeekFrequency(Datetime startDate, CSM_QI_Frequency__c frequencyRecord, CSM_QI_CaseAutomationScheduler__c automationRecord, Map<String, Integer> weekMap){
        List<Integer> quarterOne = new List<Integer>{1, 2, 3};
        List<Integer> quarterTwo = new List<Integer>{4, 5, 6};
        List<Integer> quarterThree = new List<Integer>{7, 8, 9};
        List<Integer> quarterFour = new List<Integer>{10, 11, 12};
        Date tempDate;
        Integer quarterMonth;
        Integer startDay = startDate.day();
        Integer startMonth = startDate.month();
        Integer startYear = startDate.year();
        Integer nextMonth;
        Date nextDate;
        String startWeekday = startDate.format('EEEE');
        String weekDay = frequencyRecord.Weekday__c;
        Date weekStartDate;
        if(!frequencyRecord.Week__c.equalsIgnoreCase('last')){
            Integer week = Integer.valueOf(frequencyRecord.Week__c.trim());
            Date tempStartDate = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
            Integer startWeek = getWeekOfMonth(tempStartDate);
            Integer quarterDay = 1;
            Integer nextWeek;
            if(quarterOne.contains(startMonth)){
                if(startMonth != 3){
                    quarterMonth = 3;
                    tempDate = Date.parse(quarterMonth+'/'+quarterDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextWeek = getWeekOfMonth(tempDate);
                    Datetime tempDatetime = (Datetime)tempDate;
                    String tempWeekDay = tempDatetime.format('EEEE');
                    If(nextWeek == week){
                        if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        }
                        else{
                            nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                        }
                    }
                    else if(nextWeek < week){
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 3){
                    if(startWeek > week){
                        nextMonth = 6;
                        tempDate = Date.parse(nextMonth+'/'+quarterDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextWeek = getWeekOfMonth(tempDate);
                        Datetime tempDatetime = (Datetime)tempDate;
                        String tempWeekDay = tempDatetime.format('EEEE');
                        If(nextWeek == week){
                            if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            }
                            else{
                                nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                            }
                        }
                        else if(nextWeek < week){
                            nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        }
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                    else if(startWeek == week){
                        if(weekMap.get(startWeekday) >= weekMap.get(weekDay)){
                            nextMonth = 6;
                            tempDate = Date.parse(nextMonth+'/'+quarterDay+'/'+startYear);
                            weekStartDate = tempDate.toStartOfWeek();
                            nextWeek = getWeekOfMonth(tempDate);
                            Datetime tempDatetime = (Datetime)tempDate;
                            String tempWeekDay = tempDatetime.format('EEEE');
                            If(nextWeek == week){
                                if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                                }
                                else{
                                    nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                                }
                            }
                            else if(nextWeek < week){
                                nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                            }
                            automationRecord.Next_Run_Date__c = nextDate;
                        }
                        else if(weekMap.get(startWeekday) < weekMap.get(weekDay)){
                            tempDate = Date.parse(startMonth+'/'+quarterDay+'/'+startYear);
                            weekStartDate = tempDate.toStartOfWeek();
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            automationRecord.Next_Run_Date__c = nextDate;
                        }
                    }
                    else if(startWeek < week){
                        tempDate = Date.parse(startMonth+'/'+quarterDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                }
            }
            else if(quarterTwo.contains(startMonth)){
                if(startMonth != 6){
                    quarterMonth = 6;
                    tempDate = Date.parse(quarterMonth+'/'+quarterDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextWeek = getWeekOfMonth(tempDate);
                    Datetime tempDatetime = (Datetime)tempDate;
                    String tempWeekDay = tempDatetime.format('EEEE');
                    If(nextWeek == week){
                        if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        }
                        else{
                            nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                        }
                    }
                    else if(nextWeek < week){
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 6){
                    if(startWeek > week){
                        nextMonth = 9;
                        tempDate = Date.parse(nextMonth+'/'+quarterDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextWeek = getWeekOfMonth(tempDate);
                        Datetime tempDatetime = (Datetime)tempDate;
                        String tempWeekDay = tempDatetime.format('EEEE');
                        If(nextWeek == week){
                            if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            }
                            else{
                                nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                            }
                        }
                        else if(nextWeek < week){
                            nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        }
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                    else if(startWeek == week){
                        if(weekMap.get(startWeekday) >= weekMap.get(weekDay)){
                            nextMonth = 9;
                            tempDate = Date.parse(nextMonth+'/'+quarterDay+'/'+startYear);
                            weekStartDate = tempDate.toStartOfWeek();
                            nextWeek = getWeekOfMonth(tempDate);
                            Datetime tempDatetime = (Datetime)tempDate;
                            String tempWeekDay = tempDatetime.format('EEEE');
                            If(nextWeek == week){
                                if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                                }
                                else{
                                    nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                                }
                            }
                            else if(nextWeek < week){
                                nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                            }
                            automationRecord.Next_Run_Date__c = nextDate;
                        }
                        else if(weekMap.get(startWeekday) < weekMap.get(weekDay)){
                            tempDate = Date.parse(startMonth+'/'+quarterDay+'/'+startYear);
                            weekStartDate = tempDate.toStartOfWeek();
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            automationRecord.Next_Run_Date__c = nextDate;
                        }
                    }
                    else if(startWeek < week){
                        tempDate = Date.parse(startMonth+'/'+quarterDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                }
            }
            else if(quarterThree.contains(startMonth)){
                if(startMonth != 9){
                    quarterMonth = 9;
                    tempDate = Date.parse(quarterMonth+'/'+quarterDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextWeek = getWeekOfMonth(tempDate);
                    Datetime tempDatetime = (Datetime)tempDate;
                    String tempWeekDay = tempDatetime.format('EEEE');
                    If(nextWeek == week){
                        if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        }
                        else{
                            nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                        }
                    }
                    else if(nextWeek < week){
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 9){
                    if(startWeek > week){
                        nextMonth = 12;
                        tempDate = Date.parse(nextMonth+'/'+quarterDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextWeek = getWeekOfMonth(tempDate);
                        Datetime tempDatetime = (Datetime)tempDate;
                        String tempWeekDay = tempDatetime.format('EEEE');
                        If(nextWeek == week){
                            if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            }
                            else{
                                nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                            }
                        }
                        else if(nextWeek < week){
                            nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        }
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                    else if(startWeek == week){
                        if(weekMap.get(startWeekday) >= weekMap.get(weekDay)){
                            nextMonth = 12;
                            tempDate = Date.parse(nextMonth+'/'+quarterDay+'/'+startYear);
                            weekStartDate = tempDate.toStartOfWeek();
                            nextWeek = getWeekOfMonth(tempDate);
                            Datetime tempDatetime = (Datetime)tempDate;
                            String tempWeekDay = tempDatetime.format('EEEE');
                            If(nextWeek == week){
                                if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                                }
                                else{
                                    nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                                }
                            }
                            else if(nextWeek < week){
                                nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                            }
                            automationRecord.Next_Run_Date__c = nextDate;
                        }
                        else if(weekMap.get(startWeekday) < weekMap.get(weekDay)){
                            tempDate = Date.parse(startMonth+'/'+quarterDay+'/'+startYear);
                            weekStartDate = tempDate.toStartOfWeek();
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            automationRecord.Next_Run_Date__c = nextDate;
                        }
                    }
                    else if(startWeek < week){
                        tempDate = Date.parse(startMonth+'/'+quarterDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                }
            }
            else if(quarterFour.contains(startMonth)){
                if(startMonth != 12){
                    quarterMonth = 12;
                    tempDate = Date.parse(quarterMonth+'/'+quarterDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextWeek = getWeekOfMonth(tempDate);
                    Datetime tempDatetime = (Datetime)tempDate;
                    String tempWeekDay = tempDatetime.format('EEEE');
                    If(nextWeek == week){
                        if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        }
                        else{
                            nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                        }
                    }
                    else if(nextWeek < week){
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 12){
                    Integer nextYear;
                    if(startWeek > week){
                        nextMonth = 1;
                        nextYear = startYear + 1;
                        tempDate = Date.parse(nextMonth+'/'+quarterDay+'/'+nextYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextWeek = getWeekOfMonth(tempDate);
                        Datetime tempDatetime = (Datetime)tempDate;
                        String tempWeekDay = tempDatetime.format('EEEE');
                        If(nextWeek == week){
                            if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            }
                            else{
                                nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                            }
                        }
                        else if(nextWeek < week){
                            nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        }
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                    else if(startWeek == week){
                        if(weekMap.get(startWeekday) >= weekMap.get(weekDay)){
                            nextMonth = 1;
                            nextYear = startYear + 1;
                            tempDate = Date.parse(nextMonth+'/'+quarterDay+'/'+nextYear);
                            weekStartDate = tempDate.toStartOfWeek();
                            nextWeek = getWeekOfMonth(tempDate);
                            Datetime tempDatetime = (Datetime)tempDate;
                            String tempWeekDay = tempDatetime.format('EEEE');
                            If(nextWeek == week){
                                if(WeekMap.get(tempWeekDay) <= WeekMap.get(weekDay)){
                                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                                }
                                else{
                                    nextDate = (weekStartDate - 1) + 7 + weekMap.get(weekDay);
                                }
                            }
                            else if(nextWeek < week){
                                nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                            }
                            automationRecord.Next_Run_Date__c = nextDate;
                        }
                        else if(weekMap.get(startWeekday) < weekMap.get(weekDay)){
                            tempDate = Date.parse(startMonth+'/'+quarterDay+'/'+startYear);
                            weekStartDate = tempDate.toStartOfWeek();
                            nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                            automationRecord.Next_Run_Date__c = nextDate;
                        }
                    }
                    else if(startWeek < week){
                        tempDate = Date.parse(startMonth+'/'+quarterDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextDate = (weekStartDate - 1) + ((week - 1) * 7) + weekMap.get(weekDay);
                        automationRecord.Next_Run_Date__c = nextDate;
                    }
                }
            }
        }
        else if(frequencyRecord.Week__c.equalsIgnoreCase('last')){
            Integer lastDay;
            Date midDate;
            if(quarterOne.contains(startMonth)){
                lastDay = 31;
                if(startMonth != 3){
                    nextMonth = 3;
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(nextDate.month() != nextMonth){
                        nextDate = nextDate - 7;
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 3){
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    midDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(midDate.month() != startMonth){
                        midDate = midDate - 7;
                    }
                    
                    if(startDay >= midDate.day()){
                        nextMonth = 6;
                        lastDay = 30;
                        tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        if(nextDate.month() != nextMonth){
                            nextDate = nextDate - 7;
                        }
                    }
                    else if(startDay < midDate.day()){
                        nextDate = midDate;
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
            }
            else if(quarterTwo.contains(startMonth)){
                lastDay = 30;
                if(startMonth != 6){
                    nextMonth = 6;
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(nextDate.month() != nextMonth){
                        nextDate = nextDate - 7;
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 6){
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    midDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(midDate.month() != startMonth){
                        midDate = midDate - 7;
                    }
                    
                    if(startDay >= midDate.day()){
                        nextMonth = 9;
                        lastDay = 30;
                        tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        if(nextDate.month() != nextMonth){
                            nextDate = nextDate - 7;
                        }
                    }
                    else if(startDay < midDate.day()){
                        nextDate = midDate;
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
            }
            else if(quarterThree.contains(startMonth)){
                lastDay = 30;
                if(startMonth != 9){
                    nextMonth = 9;
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(nextDate.month() != nextMonth){
                        nextDate = nextDate - 7;
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 9){
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    midDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(midDate.month() != startMonth){
                        midDate = midDate - 7;
                    }
                    
                    if(startDay >= midDate.day()){
                        nextMonth = 12;
                        lastDay = 31;
                        tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        if(nextDate.month() != nextMonth){
                            nextDate = nextDate - 7;
                        }
                    }
                    else if(startDay < midDate.day()){
                        nextDate = midDate;
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
            }
            else if(quarterFour.contains(startMonth)){
                lastDay = 31;
                if(startMonth != 12){
                    nextMonth = 12;
                    tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(nextDate.month() != nextMonth){
                        nextDate = nextDate - 7;
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
                else if(startMonth == 12){
                    tempDate = Date.parse(startMonth+'/'+lastDay+'/'+startYear);
                    weekStartDate = tempDate.toStartOfWeek();
                    midDate = (weekStartDate - 1) + weekMap.get(weekDay);
                    if(midDate.month() != startMonth){
                        midDate = midDate - 7;
                    }
                    
                    if(startDay >= midDate.day()){
                        nextMonth = 3;
                        lastDay = 31;
                        Integer nextYear = startYear + 1;
                        tempDate = Date.parse(nextMonth+'/'+lastDay+'/'+nextYear);
                        weekStartDate = tempDate.toStartOfWeek();
                        nextDate = (weekStartDate - 1) + weekMap.get(weekDay);
                        if(nextDate.month() != nextMonth){
                            nextDate = nextDate - 7;
                        }
                    }
                    else if(startDay < midDate.day()){
                        nextDate = midDate;
                    }
                    automationRecord.Next_Run_Date__c = nextDate;
                }
            }
        }
        return automationRecord;
    }
}
