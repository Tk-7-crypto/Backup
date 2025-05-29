global class BCH_TPA_CheckDiscrepentDSEnvelopes implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public list<watchListWrapper> watchListWrapperList {get; set{ watchListWrapperList = value;}}
    private String AG_RECORD_TYPE = 'CPC';
    private Boolean AG_IS_SUBMITTED = true;
    private String DS_STATUS_SENT = 'Sent';
    private String DS_STATUS_DELIVERED = 'Delivered';
    public String tpaReqNum {
        get {
            tpaReqNum  = 'TPA#';
            return tpaReqNum;
        }
        private set;
    }
    public String aggId {
        get{
            aggId = 'Agreement Id';
            return aggId;
        }
        private set;
    }
    public String dsEnvName {
        get{
            dsEnvName  = 'Envelope#';
            return dsEnvName;
        }
        private set;
    }
    public String dsEnvId {
        get{
            dsEnvId = 'Envelope Id';
            return dsEnvId;
        }
        private set;
    }
    public String dsEnvStatus {
        get{
            dsEnvStatus = 'Envelope Status at TPA';
            return dsEnvStatus;
        }
        private set;
    }
    public String dsEnvStatusAtDocuSign {
        get{
            dsEnvStatusAtDocuSign = 'Envelope Status at DocuSign';
            return dsEnvStatusAtDocuSign;
        }
        private set;
    }    
    public String dateCreated {
        get{
            dateCreated = 'Envelope Created Date';
            return dateCreated;
        }
        private set;
    }
    public String dateSent {
        get{
            dateSent = 'Envelope Sent Date';
            return dateSent;
        }
        private set;
    }
    public String dateCompleted {
        get{
            dateCompleted = 'Envelope Completed Date';
            return dateCompleted;
        }
        private set;
    }
    public String vName {
        get{
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
            reqStatus = 'TPA Request Status';
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

    public String fileName {
        get{
            fileName = 'TPADiscrepentDocusignEnvelopeStatusReport.xls';
            return fileName;
        }
        private set;
    }
    
    public TPA_Settings__c objTPASetting {
        get {
            if(objTPASetting == null){
                objTPASetting = TPA_Settings__c.getOrgDefaults();
            }
            return objTPASetting;
        }
        private set{ objTPASetting = value; }
    }

    public BCH_TPA_CheckDiscrepentDSEnvelopes() {
        watchListWrapperList = new list<watchListWrapper>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT id, Name, dsfs__DocuSign_Envelope_ID__c,  dsfs__Envelope_Status__c, CreatedDate, dsfs__Sent_Date_Time__c, dsfs__Completed_Date_Time__c, Related_TPA_Request_Number__c, TPA_Request__c, TPA_Request__r.Vendor_Name_f__c, TPA_Request__r.Client_Name__c,  TPA_Request__r.Request_Status__c FROM dsfs__DocuSign_Status__c WHERE TPA_Request__r.Is_Submitted__c = '+AG_IS_SUBMITTED+' AND TPA_Request__c != null AND dsfs__Envelope_Status__c IN (\''+DS_STATUS_SENT+'\', \''+DS_STATUS_DELIVERED+'\')';
        system.debug('####BCH_TPA_CheckDiscrepentDSEnvelopes.start query: '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> objList) {        
        for(sObject sobj: objList) {
            if(sobj instanceof dsfs__DocuSign_Status__c){
                dsfs__DocuSign_Status__c dsStatus = (dsfs__DocuSign_Status__c)sobj;
                system.debug('####BCH_TPA_CheckDiscrepentDSEnvelopes.execute dsStatus: '+dsStatus);
                String envelopeStatusAtDocusign = SRV_TPA_DocusignEnvelope.getEnvelopeStatus(dsStatus.dsfs__DocuSign_Envelope_ID__c.toLowerCase());
                system.debug('####BCH_TPA_CheckDiscrepentDSEnvelopes.execute envelopeStatusAtDocusign: '+envelopeStatusAtDocusign);
                if(dsStatus.dsfs__Envelope_Status__c != envelopeStatusAtDocusign) {
                    watchListWrapperList.add( new watchListWrapper(dsStatus, envelopeStatusAtDocusign));
                }
            }
        }        
    }

    global void finish(Database.BatchableContext bc) {
        String headerString = ''+tpaReqNum+' \t '+aggId+' \t '+dsEnvName+' \t '+dsEnvId+' \t '+dsEnvStatus+' \t '+dsEnvStatusAtDocuSign+' \t '+dateCreated+' \t '+dateSent+' \t '+dateCompleted+' \t '+vName+' \t '+cName+' \t '+reqStatus+' \t \n \n';
        String exceptionReportString  = headerString;
        exceptionReportString += createReportString(watchListWrapperList);
        Blob b = Blob.valueof(exceptionReportString);

        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
        efa.setBody(b);

        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setCharset('UTF-8');
        emailToSend.setPlainTextBody('This is the automated report to find out discrepancy in Docusign Envelope Status between TPA and Docusign end.');
        emailToSend.setSubject('TPA Discrepent Docusign Envelope Status Report');
        List<String> toRecipients = new List<String>();

        // Fecth and assign to-recepient
        if(objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Local__c != null && objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Local__c != '') {
            toRecipients.addAll(objTPASetting.TPA_Auto_Exception_Rpt_Recepients_Local__c.split(','));
    
            //toRecipients.add('vikram.singh@metacube.com');
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
            System.debug('####BCH_TPA_CheckDiscrepentDSEnvelopes TPADiscrepentDocusignEnvelopeStatusReport Email Failed: ' + e.getMessage());
        }
    }

    public class watchListWrapper {
        public string TPANumber {get; set;}
        public string agreementId {get; set;}        
        public string envelopeName {get; set;}
        public string envelopeId {get; set;}
        public string envelopeStatusInTPA {get; set;}
        public string envelopeStatusInDocusign {get; set;}
        public DateTime envelopeCreatedDate {get; set;}
        public DateTime envelopeSentDate {get; set;}
        public DateTime envelopeCompletedDate {get; set;}
        public String vendorName {get; set;}
        public String clientName {get; set;}
        public string reqStatus {get; set;}
        public string aggStatus {get; set;}

        public watchListWrapper(dsfs__DocuSign_Status__c dsStatus, String envelopeStatusAtDocusign) {
            this.TPANumber = dsStatus.Related_TPA_Request_Number__c;
            this.agreementId = dsStatus.TPA_Request__c;
            this.envelopeName = dsStatus.Name;
            this.envelopeId = dsStatus.dsfs__DocuSign_Envelope_ID__c;
            this.envelopeStatusInTPA = dsStatus.dsfs__Envelope_Status__c;
            this.envelopeStatusInDocusign = envelopeStatusAtDocusign != null ? envelopeStatusAtDocusign : 'Envelope not present at Docusign';
            this.envelopeCreatedDate = dsStatus.CreatedDate;
            this.envelopeSentDate = dsStatus.dsfs__Sent_Date_Time__c;
            this.envelopeCompletedDate = dsStatus.dsfs__Completed_Date_Time__c;
            this.vendorName = dsStatus.TPA_Request__r.Vendor_Name_f__c;
            this.clientName = dsStatus.TPA_Request__r.Client_Name__c;
            this.reqStatus = dsStatus.TPA_Request__r.Request_Status__c;
            this.aggStatus = dsStatus.TPA_Request__r.Request_Status__c;
        }
    }

    private String createReportString(List<watchListWrapper> content){
        String rptString = '';

        for(watchListWrapper w : content){
            system.debug('####BCH_TPA_CheckDiscrepentDSEnvelopes.createReportString row: '+w);
            rptString += '"'+w.TPANumber+'"\t'+'"'+w.agreementId+'"\t'+'"'+w.envelopeName+'"\t'+'"'+w.envelopeId+'"\t'+'"'+w.envelopeStatusInTPA+'"\t'+'"'+w.envelopeStatusInDocusign+'"\t'+'"'+w.envelopeCreatedDate.format();
                if(w.envelopeSentDate != null){
                    rptString += '"\t'+'"'+w.envelopeSentDate.format() ;
                }else{
                    rptString += '"\t"N/A';
                }
                if(w.envelopeCompletedDate != null){
                    rptString += '"\t'+'"'+w.envelopeCompletedDate.format() ;
                }else{
                    rptString += '"\t"N/A';
                }
                rptString += '"\t'+'"'+w.vendorName+'"\t'+'"'+w.clientName+'"\t'+'"'+w.reqStatus+'"\t\n';
        }
        system.debug('####BCH_TPA_CheckDiscrepentDSEnvelopes.createReportString reportString: '+rptString);
        return rptString;
    }
}