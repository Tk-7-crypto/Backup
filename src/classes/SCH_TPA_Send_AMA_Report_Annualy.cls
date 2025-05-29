global class SCH_TPA_Send_AMA_Report_Annualy implements Schedulable {
    global void execute(SchedulableContext SC){
        runReport();
    }
    
    @future(callout = true)
    global static void runReport(){
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        String reportId = amaSetting.get(0).TPA_AMA_Annual_Report__c;
        Blob data;
        ApexPages.PageReference report;
        if(UserInfo.getUiTheme() == 'Theme4d'){
          report = new ApexPages.PageReference('/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=' + reportId);
        }else{
          report = new ApexPages.PageReference('/'+reportId+'?export=1&enc=UTF-8&xf=xls');
        }
        if(!test.isRunningTest()){
            data= report.getContent();
        }else{
            data = blob.valueof('TEST');
        }
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('AMA Third Party Annual Billing Report.xls');
        attachment.setBody(data);
        Date d = Date.today();
        string dateString = d.format();
        String[]  toAddresses = amaSetting.get(0).TP_US_Email_Id__c.split(';');
        //String[] toAddresses = new String[]{'shaikshavali.shaik@metacube.com'};
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setCharset('UTF-8');
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        message.setSubject('AMA Third Party Billing Annual Report for Billing '+dateString);
        message.setHtmlBody(SRV_TPA_TPARequest.addEmailFooter(Label.Annual_Report_Mail_Body));
        if(toAddresses.size() > 0){
            message.setToAddresses(toAddresses);
        }
        if(amaSetting.get(0).CC_Address_To_send_Report_Mail_Annua__c != null){
            message.setCcAddresses((List<String>)amaSetting.get(0).CC_Address_To_send_Report_Mail_Annua__c.split(';'));
        }
        message.setUseSignature(false);
        if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()){
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
        }
    }
    
    global static void start(String CRON_EXP){
      System.schedule('TPA_AMA Third Party Annual Billing Report', CRON_EXP, new SCH_TPA_Send_AMA_Report_Annualy());
    }
}