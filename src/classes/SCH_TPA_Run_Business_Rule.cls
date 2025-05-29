global class SCH_TPA_Run_Business_Rule implements Schedulable {
    global void execute(SchedulableContext SC) {
        
        try {
            SCH_TPA_Run_Business_Rule.generateAgreementsWithoutTLLAReport();              
        }
        catch(Exception ex)
        {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SCH_TPA_Run_Business_Rule.execute', '');
        }
        
        BCH_TPA_Business_Rule_Notification notifications = new BCH_TPA_Business_Rule_Notification();
        Database.executebatch(notifications,1);
    }
    
    
    public static void generateAgreementsWithoutTLLAReport()
    {       
        List<String> templateName = new List<string>{'%TLLA%', '%CPC%'};
        String templateTLLA = '%TLLA%';
        String templateCPC = '%CPC%';
        String inReview = Label.TPA_In_Review_By_IQVIA_Status;
        String inAuto = 'In Auto Approval Process';
        String inAMAStatus = 'TPA Approved Awaiting AMA Approval';
        List<TPA_Request__c> listRequests = [select id,TPA_Approved_Awaiting_AMA_Approval__c,In_Auto_Approval_Process__c,In_IMS_Review__c,Request_Status__c,Requires_Manual_Review__c,Name,LastAction__c,(select id,name,createddate from Attachments where name like: templateTLLA or name like: templateCPC order by CreatedDate desc limit 10) 
                                                          ,(select id, name, Is_AMA_License_Required__c,Vendor_AMA_Fee_Response__c from AMA_Agreement_Details__r) //Added by Neha Bansal under ER-3592
                                                          from TPA_Request__c where (request_status__c =: inReview or request_status__c =: inAuto or request_status__c =: inAMAStatus) and Service_Provider_Address__c != null and Is_Potential_Vendor_Case__c = false ];
        string emailBody = '<div style="background-color=white;text-align=left;font-size:13px;font-family:arial;"><h1>TPA Requests without TLLA</h1><br /><br /><table style="border-collapse: collapse;">';
        emailBody += '<tr><th style="border: 1px solid #e0e3e5;font-size:13px;font-family:arial;padding: 5px 2px 4px 5px;background: #f2f3f3 none repeat scroll 0 0;">#</th>';
        emailBody += '<th style="border: 1px solid #e0e3e5;font-size:13px;font-family:arial;padding: 5px 2px 4px 5px;background: #f2f3f3 none repeat scroll 0 0;">Tpa#</th>';
        emailBody += '<th style="border: 1px solid #e0e3e5;font-size:13px;font-family:arial;padding: 5px 2px 4px 5px;background: #f2f3f3 none repeat scroll 0 0;">Record Id</th>';
        emailBody += '<th style="border: 1px solid #e0e3e5;font-size:13px;font-family:arial;padding: 5px 2px 4px 5px;background: #f2f3f3 none repeat scroll 0 0;">Status</th>';
        emailBody += '<th style="border: 1px solid #e0e3e5;font-size:13px;font-family:arial;padding: 5px 2px 4px 5px;background: #f2f3f3 none repeat scroll 0 0;">Status Changed To Auto On</th>';
        emailBody += '<th style="border: 1px solid #e0e3e5;font-size:13px;font-family:arial;padding: 5px 2px 4px 5px;background: #f2f3f3 none repeat scroll 0 0;">Status Changed To Manual On</th>';
        emailBody += '<th style="border: 1px solid #e0e3e5;font-size:13px;font-family:arial;padding: 5px 2px 4px 5px;background: #f2f3f3 none repeat scroll 0 0;">Status Changed To Awaiting AMA Approval On</th></tr>';
        Integer counter = 0;
        datetime maxDate;
        //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] address;
        Boolean isVendorAMAFeeProcess = false; 
    
        
        for(TPA_Request__c reqObj: listRequests)
        {   
            if(!reqObj.AMA_Agreement_Details__r.isEmpty() && String.isNotBlank(reqObj.AMA_Agreement_Details__r.get(0).Vendor_AMA_Fee_Response__c) )
            {
                isVendorAMAFeeProcess = true;
            }
            if(reqObj.In_Auto_Approval_Process__c != null && reqObj.In_IMS_Review__c != null && reqObj.TPA_Approved_Awaiting_AMA_Approval__c != null)
                maxDate = (reqObj.In_Auto_Approval_Process__c > reqObj.In_IMS_Review__c ? (reqObj.In_Auto_Approval_Process__c > reqObj.TPA_Approved_Awaiting_AMA_Approval__c ? reqObj.In_Auto_Approval_Process__c : (!isVendorAMAFeeProcess ? reqObj.TPA_Approved_Awaiting_AMA_Approval__c : null)) : (reqObj.In_IMS_Review__c > reqObj.TPA_Approved_Awaiting_AMA_Approval__c ? (!isVendorAMAFeeProcess ? reqObj.In_IMS_Review__c : null) : (!isVendorAMAFeeProcess ? reqObj.TPA_Approved_Awaiting_AMA_Approval__c : null)));
            else if(reqObj.In_Auto_Approval_Process__c != null && reqObj.In_IMS_Review__c != null)
                maxDate = reqObj.In_Auto_Approval_Process__c > reqObj.In_IMS_Review__c ? reqObj.In_Auto_Approval_Process__c : (!isVendorAMAFeeProcess ? reqObj.In_IMS_Review__c : null);
                    else if(reqObj.TPA_Approved_Awaiting_AMA_Approval__c != null && reqObj.In_IMS_Review__c != null)
                    maxDate = reqObj.TPA_Approved_Awaiting_AMA_Approval__c > reqObj.In_IMS_Review__c ? (!isVendorAMAFeeProcess ? reqObj.TPA_Approved_Awaiting_AMA_Approval__c : null) : (!isVendorAMAFeeProcess ? reqObj.In_IMS_Review__c : null);
                        else if(reqObj.TPA_Approved_Awaiting_AMA_Approval__c != null && reqObj.In_Auto_Approval_Process__c != null)
                        maxDate = reqObj.TPA_Approved_Awaiting_AMA_Approval__c > reqObj.In_Auto_Approval_Process__c ? (!isVendorAMAFeeProcess ? reqObj.TPA_Approved_Awaiting_AMA_Approval__c : null) : reqObj.In_Auto_Approval_Process__c;
            else if(reqObj.In_Auto_Approval_Process__c != null)
                maxDate = reqObj.In_Auto_Approval_Process__c;
            else if(reqObj.In_IMS_Review__c != null && !isVendorAMAFeeProcess)
                maxDate = reqObj.In_IMS_Review__c;
            else if(reqObj.TPA_Approved_Awaiting_AMA_Approval__c != null && !isVendorAMAFeeProcess)
                maxDate = reqObj.TPA_Approved_Awaiting_AMA_Approval__c;
            else if(reqObj.In_Auto_Approval_Process__c == null && reqObj.In_IMS_Review__c == null && reqObj.TPA_Approved_Awaiting_AMA_Approval__c == null) 
                continue; 
            if(reqObj.Attachments.size() == 0 || (maxDate != null && reqObj.Attachments[0].CreatedDate < maxDate))
            {
                counter++;
                emailBody += '<tr>';
                emailBody += '<td style="text-align:center;border: 1px solid #e0e3e5;padding: 4px 2px 4px 5px;font-size:13px;font-family:arial;">'+counter+'</td>';
                emailBody += '<td style="text-align:center;border: 1px solid #e0e3e5;padding: 4px 2px 4px 5px;font-size:13px;font-family:arial;">'+reqObj.Name+'</td>';
                emailBody += '<td style="text-align:center;border: 1px solid #e0e3e5;padding: 4px 2px 4px 5px;font-size:13px;font-family:arial;">'+reqObj.Id+'</td>';
                emailBody += '<td style="text-align:center;border: 1px solid #e0e3e5;padding: 4px 2px 4px 5px;font-size:13px;font-family:arial;">'+reqObj.Request_Status__c+'</td>';
                emailBody += '<td style="text-align:center;border: 1px solid #e0e3e5;padding: 4px 2px 4px 5px;font-size:13px;font-family:arial;">'+(reqObj.In_Auto_Approval_Process__c == null ? 'N/A' : '' + reqObj.In_Auto_Approval_Process__c)+'</td>';
                emailBody += '<td style="text-align:center;border: 1px solid #e0e3e5;padding: 4px 2px 4px 5px;font-size:13px;font-family:arial;">'+(reqObj.In_IMS_Review__c == null ? 'N/A' : '' + reqObj.In_IMS_Review__c)+'</td>';
                emailBody += '<td style="text-align:center;border: 1px solid #e0e3e5;padding: 4px 2px 4px 5px;font-size:13px;font-family:arial;">'+(reqObj.TPA_Approved_Awaiting_AMA_Approval__c == null ? 'N/A' : '' + reqObj.TPA_Approved_Awaiting_AMA_Approval__c)+'</td>';
                emailBody += '</tr>';
            }
        }
        emailBody += '</table><br /><br />';
        List<AsyncApexJob> apexJobObj = [select ApexClass.name, CreatedDate,CompletedDate,  JobType, LastProcessed, MethodName, ParentJobId, Status FROM AsyncApexJob WHERE JobType='BatchApex' and ApexClassID =: TPA_Settings__c.getInstance().TLLA_Batch_Class_Id__c order by CompletedDate desc limit 1];
        if(apexJobObj != null && apexJobObj.size() > 0){
            emailBody += '<div style = "font-size:13px;font-family:arial;"><u>TLLA Generation Batch Ran Last Time On</u>:<b>' + apexJobObj[0].CompletedDate + '</b></div>';
        }
        emailBody += '</div>';
        //mail.setSubject('List of the TPA Requests which have no TLLAs generated');
        //mail.setHtmlBody(emailBody);
        //mail.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
        List<string> recipients = new List<string>();
        if(TPA_Settings__c.getInstance().TPA_RequestSubmitted_Email__c != null)
            for(string strObj: TPA_Settings__c.getInstance().TPA_RequestSubmitted_Email__c.split(','))
                recipients.add(strObj);
        //recipients.add('neha.bansal@metacube.com');        
        if(recipients != null && recipients.size() > 0)
        {
            //mail.setToAddresses(recipients);
            if(!Test.isRunningTest())
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(recipients, null, 'SendEmail', null, null, null, 'List of the TPA Requests which have no TLLAs generated', false, emailBody, FALSE, FALSE, null);
        }
    }
    
}
