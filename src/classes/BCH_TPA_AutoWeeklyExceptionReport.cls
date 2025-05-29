public with sharing class BCH_TPA_AutoWeeklyExceptionReport implements Database.Batchable<sObject>,Database.Stateful {
    public String action = '';

    transient public String jsonData { get; set; }
    public list<watchListWrapper> watchListWrapperList {get; set;}
    
    //table headers
    public String tpaReqNum {
        get { 
            tpaReqNum  = 'TPA #';
            return tpaReqNum; 
        } 
        private set;
    }
    public String vName {
        get { 
            vName = 'Vendor Name';
            return vName; 
        }  
        private set;
    }
    public String cName { 
        get{
            cName = 'Client Name';
            return cName;
        }
        private set;
    }
    public String reqStatus { 
        get{
            reqStatus = 'Request Status';
            return reqStatus;
        }
        private set;
    }
    public String aggStatus { 
        get{
            aggStatus = 'Agreement Status';
            return aggStatus;
        }
        private set;
    }
    public String dsEnvStatus { 
        get{
            dsEnvStatus = 'Docusign Envelope Status';
            return dsEnvStatus;
        }
        private set;
    }
    public String dateC { 
        get{
            dateC = 'Date Created';
            return dateC;
        }
        private set;
    }
    public String dateDAE { 
        get{
            dateDAE = 'Data Access End Date';
            return dateDAE;
        }
        private set;
    }
    public String disReason { 
        get{
            disReason = 'Discrepancy Reason';
            return disReason;
        }
        private set;
    }
    
    public String reqCountry { 
        get{
            reqCountry = 'Requesting Country';
            return reqCountry;
        }
        private set;
    }
    public String reqForCountry { 
        get{
            reqForCountry = 'Requesting For Country';
            return reqForCountry;
        }
        private set;
    }
    public String amaRequired { 
        get{
            amaRequired = 'Is AMA Required';
            return amaRequired;
        }
        private set;
    }
    
    //filename
    public String fileName {
        get{ 
            fileName = 'TPAAutomatedWeeklyExceptionsReport.xls';
            return fileName; 
        }
        private set;
    }
    
    //custom setting
    public TPA_Settings__c objTPASetting {
        get { 
            if(objTPASetting == null){
                objTPASetting = TPA_Settings__c.getOrgDefaults();
            }
            return objTPASetting;
        }
        private set{ objTPASetting = value; }
    }
    
    //different statuses
    private final String DS_VOIDED = 'Voided';  
    private final String DS_SENT = 'Sent';  
    private final String DS_DECLINED = 'Declined';
    private final String DS_DELIVERED = 'Delivered';
    private final String DS_COMPLETED = 'Completed';
    private final String STATUS_AwaitVendSubm = 'Awaiting Vendor Submission';
    private final String STATUS_InRevByIMS = Label.TPA_In_Review_By_IMS_Status;
    private final String STATUS_InRevByQuintilesIMS = Label.TPA_In_Review_By_IQVIA_Status;
    private final String STATUS_AwaitVendSign = 'Awaiting Vendor Signature';
    private final String STATUS_InEffect = 'In Effect';
    private final String STATUS_IMSDenied = Label.TPA_IQVIA_Denied_Status;
    private final String STATUS_Expired = 'Expired';
    private final String STATUS_Cancelled = 'Cancelled';
    private final String STATUS_VendorCancelled = 'Vendor Canceled ‘17 AMA-TPA Exp-12/31/16';
    private final String STATUS_AMACancelled = 'AMA Cancelled'; 
    private final String STATUS_AMADiscontinued = 'AMA Discontinued';
    private final String STATUS_ClientDiscontinued = 'Client Discontinued';
    private final String STATUS_InitializingVendor = 'Initializing Vendor';
    private final String STATUS_ClientSubmitted = 'Client Submitted';
    private final String STATUS_InAutoApproval = 'In Auto Approval Process';
    private final String Closed_IQVIA_Affiliate = 'Closed-IQVIA Affiliate';
    
    /**************
     * Constructor
     **************/
    
    public BCH_TPA_AutoWeeklyExceptionReport(String act)
    {
      //  searchData();
        action = act;        
    }
    
    
    /***************
     Public Methods
    ****************/
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        //return listOfContracts;
        if(action == 'check TPA requests'){
			String query = 'SELECT id FROM TPA_Request__c  WHERE Is_Submitted__c = true'; 
        
            // Escape all in incomplete requests
            query += ' AND Request_Status__c != \'Client Draft\' AND Request_Status__c != \'Draft Closed\''; 
        
            // Include/exclude test record data
            if(!objTPASetting.Include_Test_Records_in_Exception_Report__c){
                query += ' AND (NOT Client_Address__r.Name LIKE \'Test_%\')  AND (NOT Service_Provider_Address__r.Name LIKE \'Test_%\')';
            }
        
            // Escape all the valid expired requests
            query += ' AND Request_Status__c NOT IN (\''+STATUS_AMACancelled+'\', \''+STATUS_AMADiscontinued+'\', \''+STATUS_Cancelled+'\', \''+STATUS_ClientDiscontinued+'\', \''+STATUS_Expired+'\', \''+STATUS_VendorCancelled+'\', \''+STATUS_IMSDenied+'\', \''+STATUS_AwaitVendSubm+'\', \''+Closed_IQVIA_Affiliate+'\')';
                        
            // Add order by
            query += ' ORDER BY Request_Status__c';
        
            if(Test.isRunningTest())
            {
                query += ' LIMIT 5' ;
            }

            
            return Database.getQueryLocator(query);
        }
        else if(action == 'check vendor address extension') {
            String query = 'Select Id FROM TPA_Master_Extension_Information__c WHERE TPA_Accounts_Address__c != null and TPA_Accounts_Address__r.Is_TPA_Account__c =true and Return_Destruction_Ack_Outstanding__c = true ';
	
            return Database.getQueryLocator(query);
        }
        else {
            return null;
        }
    }

    public void execute(Database.BatchableContext context, List<sObject> scope){
         if(action == 'check TPA requests'){
            if(watchListWrapperList == null){
                watchListWrapperList = new list<watchListWrapper>();
            }
            String query = 'SELECT id, Name, Request_Status__c, Service_Provider_Address__r.Name, Client_Address__r.Name, CreatedDate, Data_Access_End_Date__c, Client_Contact_Territory__c, Secondary_Client_Contact_Territory__c,Vendor_App_Sent__c, Vendor_App_Submitted__c, In_Auto_Approval_Process__c,  Sent_for_Signature__c, In_Effect_Date__c,'
                        +' (SELECT Id, dsfs__Envelope_Status__c, CreatedDate FROM DocuSign_Status__r ORDER BY CreatedDate DESC LIMIT 1),'
                        +' (select id, name, Is_AMA_License_Required__c from AMA_Agreement_Details__r),'
                        +' (select id, name, Status__c from TPA_Commercial_Reviews__r)'
                        +' FROM TPA_Request__c'
                        +' WHERE id in: scope'; 
        
            try{
                List<TPA_Request__c> requests = Database.query(query);
                Map<String,List<Task>> requestWithTasks = new Map<String,List<Task>>();
                List<Task> taskLists = [Select Id, WhatId, ActivityDate, Status, Subject, CallObject 
                                from Task 
                                where whatid in : scope 
                                and (Subject like '%Data Release Notification Sent%' or Subject like '%Copy of executed%' or Subject like '%Client Courtesy Email%')];
                if(taskLists != null && taskLists.size() > 0){
                    for(Task taskrecord: taskLists){
                        List<Task> taskListToAdd = new List<Task>();
                        if(requestWithTasks.containsKey(taskrecord.WhatId)){
                            taskListToAdd = requestWithTasks.get(taskrecord.WhatId);
                            taskListToAdd.add(taskrecord);
                        }
                        else{
                            taskListToAdd.add(taskrecord);
                        }
                        requestWithTasks.put(taskrecord.WhatId,taskListToAdd);
                    }
                }                                    
            
                for(TPA_Request__c agg : requests)
                {
                    DateTime createddT = agg.CreatedDate;
                    Date cD = createddT != null ? createddT.Date() : null;
                    Date dataAccessEndd = agg.Data_Access_End_Date__c;
                    Date daeD = dataAccessEndd != null ? dataAccessEndd.addDays(1) : null;
                    String envStatus, discrReason;
                    Long diffof_InitializingVendor_FromNow = null;
                    Long diffof_ClientSubmission_FromNow = null;
                    Long diffof_InAutoApproval_FromNow = null;
                    Boolean allCompleted = true;
                    Boolean noComReviewPresent = false;
                    Boolean isDRNMailSent = false;
                    Boolean isCopyofSignedSent = false;
                    Boolean isClientCourtesySent = false;
                    Integer dayDiffSentForSign = 0;
                    Integer dayDiffInEffect = 0;
                    Date todayDate = Date.today();
                    Date sentforsignature;
                    Date inEffectDate;
                
                    if(agg.DocuSign_Status__r != null && agg.DocuSign_Status__r.size() > 0){
                        for(dsfs__DocuSign_Status__c aggDsStatus : agg.DocuSign_Status__r){
                            envStatus = aggDsStatus.dsfs__Envelope_Status__c != null ? aggDsStatus.dsfs__Envelope_Status__c : '' ;
                        }
                        // Check for Request and Agreement request status
                        /*if(agg.Request_Status__c != agg.Request_Status__c){
							discrReason = 'Status mismatch between Request and Agreement.';
							watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
							}
						else{*/
                        // Case1: When agreement status is 'Awaiting Vendor Signature' then DocuSign Status must be 'Sent'
                        if(agg.Request_Status__c == STATUS_AwaitVendSign && envStatus != '' && envStatus != DS_SENT && envStatus != DS_DELIVERED){
                            discrReason = 'Envelope Status is not in sync with agreement.';
                            watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                        }
                        // Case2: When agreement status is 'In Effect' then DocuSign Status must be 'Completed'
                        if(agg.Request_Status__c == STATUS_InEffect && envStatus != '' && envStatus != DS_COMPLETED){
                            discrReason = 'Envelope Status is not in sync with agreement.';
                            watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                        }
                        // Case3: When agreement status is 'In Review By IMS' then DocuSign Status must be 'Voided'/'Declined'
                        if((agg.Request_Status__c == STATUS_InRevByIMS ||agg.Request_Status__c == STATUS_InRevByQuintilesIMS ) && (envStatus != '' && envStatus != DS_VOIDED && envStatus != DS_DECLINED)){
                            discrReason = 'Envelope Status is not in sync with agreement.';
                            watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                        }
                        // Case4: When agreement 'Data Access End Date' has passed the Agreement status must be 'AMA Canceled'/'AMA Discontinued'/'Cancelled'/'Expired'/'Client Discontinued'/'Vendor Canceled ‘17 AMA-TPA Exp-12/31/16'
                        if(daeD < Date.today() && (agg.Request_Status__c != STATUS_AMACancelled && agg.Request_Status__c != STATUS_AMADiscontinued && agg.Request_Status__c != STATUS_Cancelled && agg.Request_Status__c != STATUS_ClientDiscontinued && agg.Request_Status__c != STATUS_Expired && agg.Request_Status__c != STATUS_VendorCancelled)){
                            discrReason = 'Data Access End Date has been passed.';
                            watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                        }
                        //}
                    }
                    /*else{
                        // Case5: Check for Request and Agreement request status
                        if(agg.Request_Status__c != agg.Request_Status__c){
                            envStatus = 'N/A';
                            discrReason = 'Status mismatch between Request and Agreement.';
                            watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                        }
                    }*/
                    
                    if(agg.TPA_Commercial_Reviews__r != null && agg.TPA_Commercial_Reviews__r.size() > 0){
                        for(TPA_Commercial_Review__c comReview : agg.TPA_Commercial_Reviews__r){
                            if(comReview.Status__c != null && !comReview.Status__c.contains('Combination Approved') && !comReview.Status__c.contains('Combination Approved and Future Approved') && comReview.Status__c != 'Complete' ){
                                allCompleted = false;
                                Break;
                            }
                        }
                    }
                    else if(agg.TPA_Commercial_Reviews__r.size() == 0){
                        noComReviewPresent = true;
                    }
                    if(agg.Sent_for_Signature__c != null){
                        sentforsignature = date.newinstance(agg.Sent_for_Signature__c.year(), agg.Sent_for_Signature__c.month(), agg.Sent_for_Signature__c.day());
                        dayDiffSentForSign = sentforsignature.daysBetween(todayDate);
                    }
                    if(agg.In_Effect_Date__c != null){
                        inEffectDate = date.newinstance(agg.In_Effect_Date__c.year(), agg.In_Effect_Date__c.month(), agg.In_Effect_Date__c.day());
                        dayDiffInEffect = inEffectDate.daysBetween(todayDate);
                    }
                    if(!allCompleted && ((agg.Request_Status__c == STATUS_InEffect && dayDiffInEffect > 0 && dayDiffInEffect <= 30) || (agg.Request_Status__c == STATUS_AwaitVendSign && dayDiffSentForSign > 0 && dayDiffSentForSign <= 30)) ){
                        discrReason = 'Related Commercial Review Records are still pending but TPA Request Status was in In Effect/Awaiting Sent for Signature. ';
                        watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                    }
                    if((allCompleted || noComReviewPresent) && agg.Request_Status__c == STATUS_InRevByQuintilesIMS){
                        discrReason = 'Related Commercial Review Records were already completed/Not Present but TPA Request Status was in In review by IQVIA. ';
                        watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                    }
                    
                    List<Task> mailTaskLists = requestWithTasks.get(agg.Id);
                    if(mailTaskLists != null && mailTaskLists.size() > 0){
                        for(Task taskrecord: mailTaskLists){
                            if(taskrecord.Subject.containsIgnoreCase('Data Release Notification Sent')){
                                isDRNMailSent = true;
                            }
                            if(taskrecord.Subject.containsIgnoreCase('Copy of executed')){
                                isCopyofSignedSent = true;
                            }
                            if(taskrecord.Subject.containsIgnoreCase('Client Courtesy Email')){
                                isClientCourtesySent = true;
                            }
                        }
                    }
                    
                    if(!isClientCourtesySent && agg.Request_Status__c == STATUS_AwaitVendSign && dayDiffSentForSign > 0 && dayDiffSentForSign <= 30){
                        discrReason = 'Client Courtesy Email was not sent. ';
                        watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                    }
                    if((!isDRNMailSent || !isCopyofSignedSent) && agg.Request_Status__c == STATUS_InEffect && dayDiffInEffect > 0 && dayDiffInEffect <= 30){
                        if(!isDRNMailSent){
                            discrReason = 'DRN Email was not sent. ';
                        	watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                        }
                        if(!isCopyofSignedSent){
                            discrReason = 'Copy of Executed Email was not sent. ';
                        	watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                        }
                    }

                    if(agg.Vendor_App_Submitted__c != null ){
                        diffof_InitializingVendor_FromNow = (system.now().getTime() - agg.Vendor_App_Submitted__c.getTime())/3600000 ;
                    }
                    if(agg.Request_Status__c == STATUS_InitializingVendor && diffof_InitializingVendor_FromNow != null && diffof_InitializingVendor_FromNow >= 72)
                    {
                        envStatus = 'N/A';
                        discrReason = 'Request is stuck in Initializing Vendor Status for more than 72 Hours. ';
                        watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                    }
                    if(agg.Vendor_App_Sent__c != null){
                        diffof_ClientSubmission_FromNow = (system.now().getTime() - agg.Vendor_App_Sent__c.getTime())/3600000 ;
                    }
                    
                    if(agg.Request_Status__c == STATUS_ClientSubmitted && diffof_ClientSubmission_FromNow != null && diffof_ClientSubmission_FromNow >= 24)
                    {
                        envStatus = 'N/A';
                        discrReason = 'Request is stuck in Client Submission Status for more than 24 Hours. ';
                        watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                    }
                    if(agg.In_Auto_Approval_Process__c != null){
                        diffof_InAutoApproval_FromNow = (system.now().getTime() - agg.In_Auto_Approval_Process__c.getTime())/3600000 ;
                    }
                    if(agg.Request_Status__c == STATUS_InAutoApproval && diffof_InAutoApproval_FromNow != null && diffof_InAutoApproval_FromNow >= 24)
                    {
                        envStatus = 'N/A';
                        discrReason = 'Request is stuck in In Auto Approval Process Status for more than 24 Hours. ';
                        watchListWrapperList.add( new watchListWrapper(agg, envStatus, cD, discrReason));
                    }
                }
                jsonData = '';
                jsonData = JSON.serialize( watchListWrapperList );
                jsonData = String.escapeSingleQuotes(jsonData);
                }catch(Exception e){
                System.debug('####TPA_Auto_Weekly_Exceptions_Report_Ctrl.searchData ~ Error: '+e.getMessage()+', Line: '+e.getLineNumber()+', Cause: '+e.getCause());
                }
         }
        else if(action == 'check vendor address extension'){
				String query = 'SELECT Id, DDN_Ack_Pending_Requests__c,TPA_Accounts_Address__c,TPA_Accounts_Address__r.Name ';
            query += 'FROM TPA_Master_Extension_Information__c WHERE Id in: scope';
            
            if(watchListWrapperList == null){
                watchListWrapperList = new List<watchListWrapper>();
            }
            try{
                List<TPA_Master_Extension_Information__c> extensionRecords = Database.query(query);
                for(TPA_Master_Extension_Information__c extensionRec: extensionRecords){
                    if(extensionRec.DDN_Ack_Pending_Requests__c != null){
                        List<String> tpaRequestsName = new List<String>();
                        tpaRequestsName.addAll(extensionRec.DDN_Ack_Pending_Requests__c.split(', '));
                        List<TPA_Request__c> tpaRequestWithVora = [SELECT Id,Name,Service_Provider_Address__c, Service_Provider_Address__r.Name FROM TPA_Request__c	WHERE Name in: tpaRequestsName and Id in (select TPA_Request__c from Vendor_Offering_Return_Acknowledgment__c)];
                        if(tpaRequestWithVora.size() > 0){
                            watchListWrapperList.add(new watchListWrapper(tpaRequestWithVora,extensionRec,null,'Vendor Address hold is not valid'));
                        }
                    }
                }
            }
            catch(Exception e){
                System.debug('####TPA_Auto_Weekly_Exceptions_Report_Ctrl.searchData ~ Error: '+e.getMessage()+', Line: '+e.getLineNumber()+', Cause: '+e.getCause());
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        if(action == 'check TPA requests'){
            BCH_TPA_AutoWeeklyExceptionReport bchObj = new BCH_TPA_AutoWeeklyExceptionReport('check vendor address extension');
            bchObj.watchListWrapperList = watchListWrapperList;
            Database.executeBatch(bchObj,1);
        }
        else if(action == 'check vendor address extension'){
            sendTPAAutomatedWeeklyExceptionsReport(false);
        }
        //Database.executeBatch(new BCH_TPA_AMA_New_Client_Vendor_Script(), 200);
    }


    public void sendTPAAutomatedWeeklyExceptionsReport(Boolean isLegalNotification){
        
        // Create the string format of the attchment
        String headerString = ''+tpaReqNum+' \t '+vName+' \t '+cName+' \t '+reqStatus+' \t '+aggStatus+' \t '+dsEnvStatus+' \t '+dateC+' \t '+dateDAE+' \t '+reqCountry+' \t '+reqForCountry+' \t '+amaRequired+' \t '+disReason+' \t \n \n';
        String exceptionReportString  = headerString;
        exceptionReportString += createReportString(watchListWrapperList);
        Blob b = Blob.valueof(exceptionReportString);
        
        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
        efa.setBody(b);
        
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setCharset('UTF-8');
        emailToSend.setHtmlBody('<div style = "font-size : 13px; font-family: arial;">This is the automated report to find out discrepancy in TPA Requests.</div>');
        emailToSend.setSubject('TPA Automated Weekly Exceptions Report');
        List<String> toRecipients = new List<String>();
        
        // Fecth and assign to-recepient
        if(objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Local__c != null && objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Local__c != '') {
            
            if(!isLegalNotification){
                toRecipients.addAll(objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Local__c.split(','));
            }else{
                toRecipients.addAll(objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Legal__c.split(','));
            }
            emailToSend.setToAddresses(toRecipients);
        }

        // Associate the attachment to email
        emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        try
        {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) { 
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
            }
        }
        catch(Exception e) 
        {
            System.debug('####TPA_Auto_Weekly_Exceptions_Report_Ctrl.sendTPAAutomatedWeeklyExceptionsReport TPAAutomatedWeeklyExceptions Report Email Failed: ' + e.getMessage());
        }
    }
    
    public class watchListWrapper
    {
        public string TPANumber {get; set;}
        public String vendorName {get; set;}
        public String clientName {get; set;}
        public string reqStatus {get; set;}
        public string aggStatus {get; set;}
        public string envelopeStatus {get; set;}
        public Date createdDate {get; set;}
        public Date dataAccessEndDate {get; set;}
        public string discrepencyReason {get; set;}
        public string requestingCountry {get; set;}
        public string requestingForCountry {get; set;}
        public string isAMARequired {get; set;}
        
        //constructor overloading for two types of action

        public watchListWrapper(TPA_Request__c req, string envelopeStatus, Date createdDate, string discrepencyReason)
        {
            this.TPANumber = req != null ? req.Name : 'N/A';
            this.vendorName = req.Service_Provider_Address__r != null ? req.Service_Provider_Address__r.Name : 'N/A';
            this.clientName = req.Client_Address__r != null ? req.Client_Address__r.Name : 'N/A';
            this.reqStatus = req != null ? req.Request_Status__c : 'N/A';
            this.aggStatus = req.Request_Status__c;
            this.envelopeStatus = envelopeStatus;
            this.createdDate = createdDate;
            this.dataAccessEndDate = req.Data_Access_End_Date__c;
            this.discrepencyReason = discrepencyReason;
            this.requestingCountry = req.Client_Contact_Territory__c != null ? req.Client_Contact_Territory__c : 'N/A';
            this.requestingForCountry = req.Secondary_Client_Contact_Territory__c != null ? req.Secondary_Client_Contact_Territory__c : 'N/A';
            if(req.AMA_Agreement_Details__r != null && req.AMA_Agreement_Details__r.size() > 0){
                this.isAMARequired = '' + req.AMA_Agreement_Details__r[0].Is_AMA_License_Required__c;
            }else{
                this.isAMARequired = 'N/A';
            }
            
        }
        public watchListWrapper(List<TPA_Request__c> reqs, TPA_Master_Extension_Information__c extensionRec, Date createdDate, string discrepencyReason)
        {
            //combine request numbers
            String reqNumbers = '';
            for(Integer i=0;i<reqs.size();i++){
                reqNumbers += reqs[i].Name;
                if(i != reqs.size() -1){
                    reqNumbers += ', ';
                }
            }
            
            this.TPANumber = reqNumbers;
            //this.vendorName = reqs[0].Service_Provider_Address__c != null ? reqs[0].Service_Provider_Address__r.Name +' / ' + reqs[0].Service_Provider_Address__c : 'N/A';
            this.vendorName = extensionRec.TPA_Accounts_Address__r.Name + ' / ' + extensionRec.TPA_Accounts_Address__c;
            this.discrepencyReason = discrepencyReason;
            this.clientName = 'N/A';
            this.reqStatus = 'N/A';
            this.aggStatus = 'N/A';
            this.envelopeStatus = 'N/A';
            this.createdDate = null;
            this.dataAccessEndDate = null;
            this.requestingCountry = 'N/A';
            this.requestingForCountry = 'N/A';
            this.isAMARequired = 'N/A';
        }
    }
    
    
    /***************
     Private Methods
    ****************/
    
    private String createReportString(List<watchListWrapper> content){
        String rptString = '';
        if(content != null){
            for(watchListWrapper w : content){
                rptString += '"'+w.TPANumber+'"\t'+'"'+w.vendorName+'"\t'+'"'+w.clientName+'"\t'+'"'+w.reqStatus+'"\t'+'"'+w.aggStatus+'"\t'+'"'+w.envelopeStatus+'"\t'+'"'+(w.createdDate != null? w.createdDate.format() : 'N/A')+'"\t'+'"'+(w.dataAccessEndDate != null ? w.dataAccessEndDate.format(): 'N/A')+'"\t'+'"'+w.requestingCountry+'"\t'+'"'+w.requestingForCountry+'"\t'+'"'+w.isAMARequired+'"\t'+'"'+w.discrepencyReason+'"\t\n'; 
            }
        }
        return rptString;
    }
    
}
