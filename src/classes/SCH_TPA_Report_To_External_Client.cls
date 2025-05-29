/*
*@Author  : C.P.Pandey
*@Purpose : Create a sheduler class(SCH_TPA_Report_To_External_Client) to send TPA Requests status report to external clients : ER-3296
*@Date    : 09 Jan 2017
*/
global class SCH_TPA_Report_To_External_Client implements Schedulable {
    global void execute(SchedulableContext sc) {
        sendExternalClientEmail();
    }
    
    @future(callout=true)
    public static void sendExternalClientEmail() {
        TPA_Settings__c tpaSetting = UTL_TPA.tpaSetting;
        List<string> externClientReportSettList;
        List<string> externClientReportDetails;
        List<Messaging.SingleEmailMessage> msgListToBeSent = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message;
        List<string> toAddresses;
        List<string> ccAddresses;
        Blob data;
        if(tpaSetting.TPA_External_Client_Reports__c == null || tpaSetting.TPA_External_Client_Reports__c == '')
            return;
        externClientReportSettList = tpaSetting.TPA_External_Client_Reports__c.split(';');
        for(string externClienReportSettObj: externClientReportSettList) {
            toAddresses = new List<string>();
            if(tpaSetting.TPA_External_Client_Reports_Email_Copies__c != '')
                ccAddresses = tpaSetting.TPA_External_Client_Reports_Email_Copies__c.split(',');
            if(externClienReportSettObj == null || externClienReportSettObj == '')
                break;
            externClientReportDetails = externClienReportSettObj.split('~');
            if(externClientReportDetails.size() == 2 && externClientReportDetails[0] != '') {
                toAddresses.add(externClientReportDetails[1]);
                ApexPages.PageReference report = new ApexPages.PageReference('/'+externClientReportDetails[0]+'?export=1&enc=UTF-8&xf=xls');
                if(!test.isRunningTest()) {
                    data= report.getContent();
                } else {
                    data = blob.valueof('TEST');
                }
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Gilead TPA Requests Status.XLS');
                attachment.setBody(data);
                //Date d = Date.today();
                //string dateString = d.format();
                message = new Messaging.SingleEmailMessage();
                message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
                message.setSubject('Gilead TPA Request Status.XLS');
                String emailBody = '<div><p>Please find the status of the TPA Requests you have in '+Label.TPA_IQVIA_Keyword+' TPA system.  Please contact TP-US@us.imshealth.com with any questions.</p><p>[TPA_Email_Footer_En]</p></div>';
                message.setHtmlBody(SRV_TPA_TPARequest.addEmailFooter(emailBody));
                message.setToAddresses(toAddresses);
                message.setOrgWideEmailAddressId(tpaSetting.TPA_From_Orgwide_Email_Id__c);
                if(ccAddresses.size() > 0)
                    message.setCCAddresses(ccAddresses);
                msgListToBeSent.add(message);
            }
        }
        if(msgListToBeSent.size() > 0 && !Test.isRunningTest())
            Messaging.sendEmail( msgListToBeSent );
    }
}