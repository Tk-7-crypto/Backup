global class SCH_TPA_Log_Report implements System.Schedulable {
    
    global void execute(SchedulableContext sc) {        
        SCH_TPA_Log_Report.runAndExportLogReport();
    }
    
    @future(callout = true)
    public static void runAndExportLogReport() {
        List<String> lstRecipients = new List<String>();
        String reportId = null;
        reportId  = UTL_TPA.tpaSetting.TPA_Log_Tracking_Report_Id__c;
        lstRecipients = UTL_TPA.tpaSetting.TPA_Log_Report_Recipients__c.split(',');
        ApexPages.PageReference report = new ApexPages.PageReference('/'+reportId+'?csv=1');
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('TPA Log Tracking Report.csv');
        if(!Test.isRunningTest())
            attachment.setBody(report.getContent());
        attachment.setContentType('text/csv');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        message.setSubject('TPA Log Tracking Report');
        message.setPlainTextBody('The report is attached.');
        message.setToAddresses(lstRecipients);
        if(!Test.isRunningTest() && UTL_TPA.isSendOutgoingEmails)
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
        
    }
}