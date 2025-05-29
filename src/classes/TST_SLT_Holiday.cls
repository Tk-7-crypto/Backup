@isTest
public class TST_SLT_Holiday {
    testmethod static void testHoliday(){
        pse__Work_Calendar__c wrkCalc = new pse__Work_Calendar__c();
        wrkCalc.Name = 'TestCal';
        wrkCalc.pse__Monday_Hours__c = 8.0;
        wrkCalc.pse__Tuesday_Hours__c = 8.0;
        wrkCalc.pse__Wednesday_Hours__c = 8.0;
        wrkCalc.pse__Thursday_Hours__c = 8.0;
        wrkCalc.pse__Friday_Hours__c = 8.0;
        insert wrkCalc;
        pse__HolidayObj__c holiday =  new pse__HolidayObj__c();
        holiday.pse__Date__c = system.today();
        holiday.pse__Work_Calendar__c = wrkCalc.Id;
        holiday.pse__Work_Hours__c = 9.0;
        insert holiday; 
        List<Schema.SObjectField> schema = new SLT_Holiday().getSObjectFieldList();
        Set<String> fieldSet =  new SLT_Holiday().getSObjectFieldSet();
        Map<Id, pse__HolidayObj__c> holidayMap = new SLT_Holiday(false,false).getHolidayMapByWorkCalendarId(new Set<Id>{wrkCalc.id},new Set<String>{'Name'});
        
    }
}
