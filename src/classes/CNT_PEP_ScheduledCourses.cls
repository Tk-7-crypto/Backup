/*
 * Version       : 1.0
 * Description   : Apex Controller for Scheduled Courses component
 */
public with sharing class CNT_PEP_ScheduledCourses {
    @AuraEnabled
    public static List<Classroom_Course__c> getCourse(){
        String uid = UserInfo.getUserId();        
        return [SELECT Id,Name,Classroom_label__c,LMS_Classroom_Course_URL__c,Salesforce_User_ID__c,Location_address__c
                ,Scheduled_start_date__c,Duration__c,Enrollment_status__c  
                FROM Classroom_Course__c 
                WHERE Salesforce_User_ID__c =: uid AND Scheduled_start_date__c >= TODAY
                AND Enrollment_status__c IN ('ENROLLED','WAITLISTED','CANCELLED')
                ORDER BY Scheduled_start_date__c DESC];
    }
}