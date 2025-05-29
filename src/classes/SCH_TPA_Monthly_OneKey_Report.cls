global class SCH_TPA_Monthly_OneKey_Report implements System.Schedulable{
    global void execute(SchedulableContext sc) {
        SCH_TPA_Monthly_OneKey_Report.runOneKeyReport();
    }
    
    @future(callout=true)
    public static void runOneKeyReport() {
        TPA_Settings__c tpaSetting = UTL_TPA.tpaSetting;
        List<string> oneKeyReportSettList;
        List<String> userIds = new List<string>();
        if(tpaSetting.Monthly_OneKey_Report__c == null || tpaSetting.Monthly_OneKey_Report__c == '')
            return;
        oneKeyReportSettList = tpaSetting.Monthly_OneKey_Report__c.split('~');
        if(oneKeyReportSettList.size() == 2 && oneKeyReportSettList[0] != '' && oneKeyReportSettList[1] != '')
        {
            userIds = oneKeyReportSettList[1].split(';');
            String subjText = 'One Key Report';
            String emailBody = '<div style = "font-size : 13px; font-family: arial;">Please find the One Key Report Link below</div>';
            
            emailBody += '<div style="background-color=white; text-align=left; font-size : 13px; font-family: arial;"><br><br>';
            emailBody += tpaSetting.Internal_SFDC_URL__c + '/' + oneKeyReportSettList[0];
            emailBody += '</div>';
            
            if(!Test.isRunningTest() && UTL_TPA.isSendOutgoingEmails)
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(userIds, null, 'SendEmail', null, null, null, subjText, FALSE, emailBody, FALSE, FALSE, null);
        }
        
    }
    
}
