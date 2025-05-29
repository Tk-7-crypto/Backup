global class CNT_TPA_Run_AMA_Business_Rule {
    public String amaErrorMessage {get; set;}
    public static AMA_Agreement_Detail__c amaAgreementDetails;

    public CNT_TPA_Run_AMA_Business_Rule() {
        string amaAgrId = ApexPages.currentPage().getParameters().get('id');
        System.debug('In CNT_TPA_Run_AMA_Business_Rule: amaAgrId: ' + amaAgrId);
        if(amaAgrId != null && amaAgrId != ''){
            loadDefaultValues(amaAgrId);
        }
    }

    public void loadDefaultValues(string amaAgrId) {
        
        String errMsg = '';
        Boolean holdForAMAFeeConfirmation = false;
        List<String> applicableContract = System.Label.TPA_AMA_Fee_Applicable_Contract.split(';');
        
        AMA_Agreement_Detail__c amaAgr = [Select id, Name, Ex_DBL__c, Agreement_Start_Date__c, Agreement_End_Date__c, Is_Prorated__c, 
                                Fee_Reduced__c, TPA_Request__c, Vendor_Legal_Name__c,Client__c,Contract_Type__c,
                                Current_Year_Fees__c, DBL__c,Current_Year__c,Final_End_Year__c,Next_Year__c,
                                 Initial_Termination_Date__c,Max_Fee_Reached__c,Is_AMA_License_Required__c,
                                 AMA_Manual_Review__c,TPA_Request__r.TPA_Request_Temporary_Status__c,
                                 TPA_Request__r.Pending_Acknowledgements__c,TPA_Request__r.Id, 
                                 TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, 
                                 TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c,
                                 TPA_Request__r.Request_Status__c, Template__c, Next_Year_Fees__c
                                 from AMA_Agreement_Detail__c  where id =: amaAgrId];

                                 
        if(amaAgr.Contract_Type__c == null || amaAgr.Contract_Type__c == '') {
            errMsg  = '<li>Please Select CONTRACT TYPE</li>'; 
        } 
        if(amaAgr.DBL__c == null || amaAgr.DBL__c == '') {
            errMsg  += '<li>Please Select DBL</li>';
        } 
        if(amaAgr.Is_AMA_License_Required__c == null || amaAgr.Is_AMA_License_Required__c == false) {
            errMsg  += '<li>Please Select IS AMA LICENSE REQUIRED Checkbox</li>';
        } 
        /*if(amaAgr.Template__c == null) {
            errMsg  += '<li>Please Select TEMPLATE</li>';
        } */
        if(amaAgr.AMA_Manual_Review__c == true ) {
            errMsg  += '<li>Please uncheck AMA MANUAL REVIEW checkbox</li>';
        } 
        if(amaAgr.Next_Year__c == amaAgr.Current_Year__c && (amaAgr.Next_Year_Fees__c != null && amaAgr.Next_Year_Fees__c != 0)) {  
            errMsg  += '<li>Next Year fee is not applicable</li>'; 
        } 
        if(((amaAgr.Current_Year_Fees__c > 0 || amaAgr.Next_Year_Fees__c > 0 ) && 
               (amaAgr.Contract_Type__c == 'Service Bureau II' || amaAgr.Contract_Type__c == 'Contract Sales Force'))
        && (amaAgr.TPA_Request__r.Request_Status__c !=  Label.TPA_In_Review_By_IQVIA_Status
        && amaAgr.TPA_Request__r.Request_Status__c !=  'TPA Approved Awaiting AMA Approval')) {  
            errMsg  += '<li>Request status should be either In Review By IQVIA Or TPA Approved Awaiting AMA Approval</li>'; 
        } 

        for(string amaContract : applicableContract)
        {
            if(amaAgr.Contract_Type__c == amaContract){
                if((amaAgr.Next_Year__c == amaAgr.Current_Year__c) && (amaAgr.Current_Year_Fees__c == null || amaAgr.Current_Year_Fees__c == 0)){
                    errMsg  += '<li>Please check that you have updated the AMA Fees section with consideration of proration and TPA time periods.</li>'; 
                }
                else if((amaAgr.Next_Year__c != amaAgr.Current_Year__c) && (amaAgr.Next_Year_Fees__c == null || amaAgr.Next_Year_Fees__c == 0)){
                    errMsg  += '<li>Please check that you have updated the AMA Fees section with consideration of proration and TPA time periods.</li>'; 
                }    
            }
        }
        
        if(errMsg == '' && (amaAgr!= null && amaAgr.Is_AMA_License_Required__c && (amaAgr.Current_Year_Fees__c > 0 || amaAgr.Next_Year_Fees__c > 0 ) && (amaAgr.Contract_Type__c == 'Service Bureau II' || amaAgr.Contract_Type__c == 'Contract Sales Force') )) {
            holdForAMAFeeConfirmation = true;
        }

        if(errMsg != '') {
            errMsg = '<ul>' + errMsg + '</ul>';
        }
        
        amaErrorMessage = errMsg;                     

    }

    
    public void sendMails(){

        
        string amaAgrId = ApexPages.currentPage().getParameters().get('id');
        AMA_Agreement_Detail__c amaAgr = [Select id, Name, Ex_DBL__c, Vendor_AMA_Fee_Response__c, Agreement_Start_Date__c, Agreement_End_Date__c, Is_Prorated__c, 
                                Fee_Reduced__c, TPA_Request__c, Vendor_Legal_Name__c,Client__c,Contract_Type__c,
                                Current_Year_Fees__c, DBL__c,Current_Year__c,Final_End_Year__c,Next_Year__c,
                                 Initial_Termination_Date__c,Max_Fee_Reached__c,Is_AMA_License_Required__c,
                                 AMA_Manual_Review__c,TPA_Request__r.TPA_Request_Temporary_Status__c,
                                 TPA_Request__r.Pending_Acknowledgements__c,TPA_Request__r.Id, 
                                 TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, 
                                 TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c,
                                 TPA_Request__r.Request_Status__c, Template__c, Next_Year_Fees__c
                                 from AMA_Agreement_Detail__c  where id =: amaAgrId];
        
        if(amaAgr != null && amaAgr.TPA_Request__c != null){
            QBL_TPA_AsyncGenerateDoc asyncGenerateDocCall= new QBL_TPA_AsyncGenerateDoc();
            asyncGenerateDocCall.requestId = amaAgr.TPA_Request__r.Id;
            asyncGenerateDocCall.GUID = UTL_LogFactory.GUID;
            System.enqueueJob(asyncGenerateDocCall);
            SRV_TPA_DocusignEnvelope.generateAmaDocForSign(amaAgr.TPA_Request__r.Id, UTL_LogFactory.GUID); 
        }
        

        Boolean holdForAMAFeeConfirmation = false;

        if(amaAgr!= null && amaAgr.Is_AMA_License_Required__c && (amaAgr.Current_Year_Fees__c > 0 || amaAgr.Next_Year_Fees__c > 0 ) && (String.isBlank(amaAgr.Vendor_AMA_Fee_Response__c) || !(amaAgr.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('acknowledged') )) && (amaAgr.Contract_Type__c == 'Service Bureau II' || amaAgr.Contract_Type__c == 'Contract Sales Force') ) {
            holdForAMAFeeConfirmation = true;
        }

        if( (amaAgr.TPA_Request__r.Request_Status__c ==  Label.TPA_In_Review_By_IQVIA_Status
            || amaAgr.TPA_Request__r.Request_Status__c ==  'TPA Approved Awaiting AMA Approval')
            &&  holdForAMAFeeConfirmation){
                
                amaAgr.TPA_Request__r.TPA_Request_Temporary_Status__c = amaAgr.TPA_Request__r.Request_Status__c;
                amaAgr.TPA_Request__r.Request_Status__c = 'Pending Vendor AMA Fee Acknowledgement';
                if(amaAgr.TPA_Request__r.Pending_Acknowledgements__c == null || amaAgr.TPA_Request__r.Pending_Acknowledgements__c == ''){
                    amaAgr.TPA_Request__r.Pending_Acknowledgements__c =  'AMA Fee Acknowledgement' ;
                }
                else if(amaAgr.TPA_Request__r.Pending_Acknowledgements__c.indexOf('AMA Fee Acknowledgement') == -1){
                    amaAgr.TPA_Request__r.Pending_Acknowledgements__c = amaAgr.TPA_Request__r.Pending_Acknowledgements__c + ';AMA Fee Acknowledgement' ;
                }

                amaAgr.Vendor_AMA_Fee_Response__c = '';
                
                update amaAgr;
                update amaAgr.TPA_Request__r;

                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                            FALSE, 
                                                                            UTL_LogFactory.GUID, 
                                                                            'Check: Hold For AMA Fee Confirmation', 
                                                                            'TPA', 
                                                                            'Custom', 
                                                                            'INFO', 
                                                                            ':::CNT_TPA_Run_AMA_Business_Rule:::Fee Acknowledgement sending mail', 
                                                                            (amaAgr.TPA_Request__r.Id != null) ? amaAgr.TPA_Request__r.Id : ''));
                
                List<String> toAddress = new List<String>();
                if(String.isNotBlank(amaAgr.TPA_Request__r.Authorized_Signer_Email__c) && String.isNotBlank(amaAgr.TPA_Request__r.Vendor_Contact_e_mail__c) && !amaAgr.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(amaAgr.TPA_Request__r.Vendor_Contact_e_mail__c))
                {
                    toAddress.add(amaAgr.TPA_Request__r.Authorized_Signer_Email__c);
                    toAddress.add(amaAgr.TPA_Request__r.Vendor_Contact_e_mail__c);
                }
                else
                {
                    if(String.isNotBlank(amaAgr.TPA_Request__r.Vendor_Contact_e_mail__c))
                        toAddress.add(amaAgr.TPA_Request__r.Vendor_Contact_e_mail__c);
                    else
                        toAddress.add(amaAgr.TPA_Request__r.Authorized_Signer_Email__c);
                }
                addAMAFeeInvoicedBeforeSignConfirmationMail(amaAgr, toAddress);  
                               
        }
        return;
        
    }

    public void addAMAFeeInvoicedBeforeSignConfirmationMail(AMA_Agreement_Detail__c  amaAgreement, List<String> toAddress)
    {
        system.debug('In method where sending mail to vendor for invoiced confirmation before sending agreements for signatures' + amaAgreement);
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgreement.TPA_Request__c];
        List<String> ccTo = new List<String>();
        
        if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c)) {
            ccTo = tpaCustomSettings.TP_US_Mail_Id__c.split(',');
            if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)) {
                List<String> addCCTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
                ccTo.addAll(addCCTo);
            }
        }
        
        if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
           List<String> bccTo = new List<String>();
           bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
        }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
         
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Fees_Invoice_Confirm_BeforeSign_Template__c, amaAgreement.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);

        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
    }
}
