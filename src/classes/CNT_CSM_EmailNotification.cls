public without sharing class  CNT_CSM_EmailNotification {
    
    private static final String CSM_NOTIFICATION_EMAIL = 'csm.notification@iqvia.com';
    private static List<OrgWideEmailAddress> orgAddress = null;
    public static EmailTemplate sendEmailNotificationForLQ(){
        List<EmailTemplate> emailTemp = [SELECT Id, Body, HTMLValue, Subject, Name FROM EmailTemplate WHERE Name IN ('CSM_LiquidPlanner_Template')];
        return emailTemp[0];
    }
    
    public static void sendEmailNotification(List<Case> caseData,List<id> userIds,String caseCommentBody){
        CNT_CSM_DispatchQueueable y = new CNT_CSM_DispatchQueueable(caseData,userIds,caseCommentBody);
        System.enqueueJob(y);
    }
    
}
