global class SCH_TPA_Agreement_UpdateStatus implements Schedulable {
    public static string  offeringWBReportFltr = '';
    global void execute(SchedulableContext sc) {
        BCH_TPA_Agreement_UpdateStatus agrmntsUpdate= new BCH_TPA_Agreement_UpdateStatus();
        Database.executebatch(agrmntsUpdate,1);
        
        BCH_TPA_CPC_Renewal_Expiration_Mail batchCPCRenewalExpiration = new BCH_TPA_CPC_Renewal_Expiration_Mail();
        Database.executebatch(batchCPCRenewalExpiration,1);
        
        BCH_TPA_UpdateAwaitingSubmissionReq batchUpdateAwaitingSubSign = new BCH_TPA_UpdateAwaitingSubmissionReq();
        Database.executebatch(batchUpdateAwaitingSubSign,1);
        
        BCH_TPA_Vendor_Notification_Mail vendorNotificationTrigger = new BCH_TPA_Vendor_Notification_Mail();
        Database.executebatch(vendorNotificationTrigger,1);
        
        BCH_TPA_Vendor_Notification_Mail vendorRemainderTrigger = new BCH_TPA_Vendor_Notification_Mail();
        vendorRemainderTrigger.remindTPProcessortype = true;
        Database.executebatch(vendorRemainderTrigger,1);

        BCH_TPA_Permanent_Com_Owner_Email_Update permanentCoEmailUpdate = new BCH_TPA_Permanent_Com_Owner_Email_Update();
        Database.executeBatch(permanentCoEmailUpdate, 1);

        BCH_TPA_Commercial_Review commercialReminderTrigger = new BCH_TPA_Commercial_Review();
        Database.executeBatch(commercialReminderTrigger, 1);

        BCH_TPA_Commercial_Review expiredTemporaryCommercialEmailTrigger = new BCH_TPA_Commercial_Review(TRUE);
        Database.executeBatch(expiredTemporaryCommercialEmailTrigger, 1);

        BCH_TPA_Vendor_Off_Return_Ack vendorOffReturnAck = new BCH_TPA_Vendor_Off_Return_Ack();
        Database.executebatch(vendorOffReturnAck,1);
        
        BCH_TPA_ManageDraftRequests draftRequestManager = new BCH_TPA_ManageDraftRequests();
        Database.executebatch(draftRequestManager,1);
        
        BCH_TPA_VendorSpeNoti_Reminder VSNManager = new BCH_TPA_VendorSpeNoti_Reminder();
        Database.executebatch(VSNManager,1);
        
        // Trigger pending TPA requests report to individual tp processors
        DateTime todaysDate = System.now();
        String dayOfWeek = todaysDate.format('E');// dayOfWeek is Sun, Mon, Tue, etc.
        //system.debug('Today is ' + dayOfWeek);
        List<TPA_Text_Editor__c> editorDataList = [select id, Page_Name__c, Content__c, Page_Title__c from TPA_Text_Editor__c WHERE Page_Type__c = 'Report Frequency'];
        for(TPA_Text_Editor__c editorRecord: editorDataList) {
            if(editorRecord.Page_Title__c == 'Pending TPA Req Report Frequency') {
                if(editorRecord.Content__c.contains(dayOfWeek) || Test.isRunningTest() ) {
                    sendPendingTPARequestsReport();
                }   
            }
            if(editorRecord.Page_Title__c == 'Country Offering workbook Report') {
                if(editorRecord.Content__c.contains(dayOfWeek) || Test.isRunningTest() ) {
                    sendCountryOfferingWorkbookReport();
                }   
            }
        }          
    }
    
    public static void start() {
        if(Test.isRunningTest()){
            System.schedule('SCH_TPA_Agreement_UpdateStatus_Test', '0 0 1 1/1 * ? *', new SCH_TPA_Agreement_UpdateStatus());
        }else{
            System.schedule('SCH_TPA_Agreement_UpdateStatus', '0 0 1 1/1 * ? *', new SCH_TPA_Agreement_UpdateStatus());
        }
    }

    //Send the Pending TPA Requests report to the individual TP Processors
    @future
    public static void sendPendingTPARequestsReport() {

        //map<string, string> tpReqCountryMap = SRV_TPA_TPARequest.getCountryCodeMap('TPA_Region_Country__c', 'Country__c');

        List<TPA_TP_Processor__c> tpProcessorsList = new List<TPA_TP_Processor__c>();
        if(UTL_TPA.runBatchForTestRecords('Pending TPA Req Report Frequency Run Report')){
            tpProcessorsList = [SELECT id, Name, TP_Processor_Name__c, TP_Processor_Email__c,  
            (SELECT Id, Country__c from TPA_Region_Countries__r), (SELECT Id, Email__c, Is_Active__c from TPA_Assigned_TP_Processors__r) 
            FROM TPA_TP_Processor__c where Region__c = 'United States'];

        }
        else{
            tpProcessorsList = [SELECT id, Name, TP_Processor_Name__c, TP_Processor_Email__c,  
            (SELECT Id, Country__c from TPA_Region_Countries__r), (SELECT Id, Email__c, Is_Active__c from TPA_Assigned_TP_Processors__r) 
            FROM TPA_TP_Processor__c];
        }
        
        string reportId;
        if(UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Pending TPA Request Report' + 'English') != null) {
            reportId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Pending TPA Request Report' + 'English').Translated_Template_Id__c;
        }
        
        string templateId;
        if(UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA Send Pending TPA Request Report' + 'English') != null) {
            templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA Send Pending TPA Request Report' + 'English').Translated_Template_Id__c;
        }

        String subjText;
        String emailBody;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, null);
        if(emailNotToSend != null) {
            subjText = emailNotToSend.getSubject();     
            
            for(TPA_TP_Processor__c tpprocessor : tpProcessorsList) {
                //String requestCountries = '';
                String tpProcessorName = '';
                String tpProcessorEmail = '';
                List<String> toAddresses;
                List<String> ccAddressesList;
                //if(tpprocessor.TPA_Region_Countries__r.size() > 0) {
                    
                    //for(TPA_Region_Country__c regionCountry : tpprocessor.TPA_Region_Countries__r) {
                        //requestCountries += tpReqCountryMap.get(regionCountry.Country__c.toLowerCase()) + ',';
                    //}
                    //system.debug('countryCode' + requestCountries);
                    
                    
                String reportURL = '';

                if(tpprocessor.TP_Processor_Name__c != null && tpprocessor.TP_Processor_Name__c != ''){
                    tpProcessorName = tpprocessor.TP_Processor_Name__c.toLowerCase();
                    tpProcessorEmail = tpprocessor.TP_Processor_Email__c.toLowerCase();
                    reportURL = '/' + 'lightning/r/Report/' + reportId + '/view?fv0=' + tpProcessorName + '&pv0=' + tpProcessorName + '&fv3=' + tpProcessorEmail + '&pv3=' + tpProcessorEmail;
                    
                }
                
                //system.debug(reportURL);
                String bodyText = '';
                String bodyPendingText ='';

                ApexPages.PageReference ref = new ApexPages.PageReference(TPA_Settings__c.getOrgDefaults().Base_Url__c + reportURL);
                bodyText += '<a href=' + ref.getURL() + '>' + 'Click here'+ '</a>';
                
                
              

                emailBody = emailNotToSend.getHTMLBody();
                emailBody = emailBody.replace('[Report_URL]', bodyText);
               
                
                toAddresses = new List<String> {tpprocessor.TP_Processor_Email__c};
                
                if(tpprocessor.TPA_Assigned_TP_Processors__r.size() > 0) {
                    ccAddressesList = new List<String>();
                    for(TPA_Assigned_TP_Processor__c assignedtpprocessor : tpprocessor.TPA_Assigned_TP_Processors__r) {
                        if(assignedtpprocessor.Is_Active__c && assignedtpprocessor.Email__c != null && assignedtpprocessor.Email__c != '') {
                            ccAddressesList.add(assignedtpprocessor.Email__c);
                            //system.debug('ccAddressesList'+ccAddressesList);
                        }
                    }
                }
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddresses, ccAddressesList, 'SendEmail', null, null, null, subjText, FALSE, emailBody, FALSE, FALSE, null);
            }
        }
    }

    //Send the Country Offering workbook report to the individual TP Processors
    @future
    public static void sendCountryOfferingWorkbookReport() {

        map<string, string> tpReqCountryMap = SRV_TPA_TPARequest.getCountryCodeMap('IMS_Data_Asset__c', 'BU__c');

        List<TPA_TP_Processor__c> tpProcessorsList = new List<TPA_TP_Processor__c>();
        if(UTL_TPA.runBatchForTestRecords('Country Offering workbook Report Run Report')){
            tpProcessorsList = [SELECT id, Name, TP_Processor_Email__c,  
            (SELECT Id, Country__c from TPA_Region_Countries__r), (SELECT Id, Email__c, Is_Active__c from TPA_Assigned_TP_Processors__r) 
            FROM TPA_TP_Processor__c where Region__c = 'United States'];
        }
        else{
            tpProcessorsList = [SELECT id, Name, TP_Processor_Email__c,  
            (SELECT Id, Country__c from TPA_Region_Countries__r), (SELECT Id, Email__c, Is_Active__c from TPA_Assigned_TP_Processors__r) 
            FROM TPA_TP_Processor__c];
        }
        
        
        string reportId;
        if(UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Report Global Offerings Report' + 'English') != null) {
            reportId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Report Global Offerings Report' + 'English').Translated_Template_Id__c;
        }

        string workBookReportId;
        if(UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Report Country Offerings WB Report' + 'English') != null) {
            workBookReportId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Report Country Offerings WB Report' + 'English').Translated_Template_Id__c;
        }
        
        string templateId;
        if(UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Country Offering Workbook Report' + 'English') != null) {
            templateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Country Offering Workbook Report' + 'English').Translated_Template_Id__c;
        }
        
        String subjText;
        String emailBody;
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, null);
        if(emailNotToSend != null) {
            subjText = emailNotToSend.getSubject();     
            
            List<String> submittingCountries = new List<String>();
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('IMS_Data_Asset__c').getDescribe();
            DescribeFieldResult fieldResult = objResult.fields.getMap().get('BU__c').getDescribe();
            
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry entry : ple) {
                submittingCountries.add(entry.getValue().toLowerCase());
            }
            system.debug('submittingCountries: ' + submittingCountries);
            for(TPA_TP_Processor__c tpprocessor : tpProcessorsList) {
                String requestCountries = '';
                List<String> toAddresses;
                List<String> ccAddressesList;
                if(tpprocessor.TPA_Region_Countries__r.size() > 0) {
                    
                    for(TPA_Region_Country__c regionCountry : tpprocessor.TPA_Region_Countries__r) {
                        //system.debug('regionCountry: ' + regionCountry);
                        if(tpReqCountryMap.get(regionCountry.Country__c.toLowerCase()) != null) {
                            list<string> tempCountryCodes = tpReqCountryMap.get(regionCountry.Country__c.toLowerCase()).split(',');
                            //system.debug('tempCountryCodes: ' + tempCountryCodes);
                            for(string countryCode : tempCountryCodes) {
                                if(submittingCountries.contains(countryCode)) {
                                    requestCountries += countryCode + ',';
                                }
                            }
                        }                        
                        //requestCountries += tpReqCountryMap.get(regionCountry.Country__c) + ',';
                    }
                    //system.debug('countryCode: ' + requestCountries);
                    if(requestCountries != '') {
                        offeringWBReportFltr = requestCountries.substring(0, requestCountries.length()-1);
                    }
                    //system.debug('offeringWBReportFltr: ' + offeringWBReportFltr);
                    String reportURL = '/' + 'lightning/r/Report/' + reportId + '/view';
                    //system.debug(reportURL);
                    
                    ApexPages.PageReference ref = new ApexPages.PageReference(TPA_Settings__c.getOrgDefaults().Base_Url__c + reportURL);
                    emailBody = emailNotToSend.getHTMLBody();
                    emailBody = emailBody.replace('[Report_URL]', ref.getURL());
                    
                    toAddresses = new List<String> {tpprocessor.TP_Processor_Email__c};
                }
                if(tpprocessor.TPA_Assigned_TP_Processors__r.size() > 0) {
                    ccAddressesList = new List<String>();
                    for(TPA_Assigned_TP_Processor__c assignedtpprocessor : tpprocessor.TPA_Assigned_TP_Processors__r) {
                        if(assignedtpprocessor.Is_Active__c && assignedtpprocessor.Email__c != null && assignedtpprocessor.Email__c != '') {
                            ccAddressesList.add(assignedtpprocessor.Email__c);
                            //system.debug('ccAddressesList'+ccAddressesList);
                        }
                    }
                }
                //SRV_TPA_TPARequest.isReportAttachment = true;
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddresses, ccAddressesList, 'SendCountryOfferingReport', null, workBookReportId, null, subjText, FALSE, emailBody, FALSE, FALSE, NULL);
                //SRV_TPA_TPARequest.isReportAttachment = false;
                offeringWBReportFltr = '';
            }
        }
    }
}
