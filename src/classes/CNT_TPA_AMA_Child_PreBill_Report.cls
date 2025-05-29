public class CNT_TPA_AMA_Child_PreBill_Report {
    public String recordString;
    private string headerString = '';
    public string AMAPreBillingReportString = '';
    private final string PAYMENT_PORTION = 'AMA Payment Portion';
    private final string ROYALTY_PORTION = 'AMA Royalty Portion';
    public List<TPA_AMA_Settings__c> amaSetting;
    private AMA_Agreement_Detail__c AMAAgrDetail;
    private String requestName;
    public Boolean AMAAgrCaptured{get;set;}

    public CNT_TPA_AMA_Child_PreBill_Report(){
        headerString = '\ncontrol #/invoice # \t project number \t Bill to Cust \t contact \t email address \t ship to Cust \t Purchase order number \t Opportunity/order number \t Header text \t material# \t line item text \t Billing date \t delivery date \t quantity \t Net Value \t currency\n'; 
        AMAPreBillingReportString = headerString;
        mailAttachmentContent();
    }

    public void mailAttachmentContent(){
		String amaAgrId = ApexPages.currentPage().getParameters().get('id');
        string query = 'SELECT Id, TPA_Request__r.Name, TPA_Account_SAP_Code__c, TPA_Request__r.Vendor_Contact_Name_f__c, ' +
       					'TPA_Request__r.Client_Company_Name_Address__r.Name, TPA_Request__r.Docusign_Custom_Picklist__c,TPA_Request__r.Authorized_Signer_Name__c,'+
            			'TPA_Request__r.Authorized_Signer_Email__c, Purchase_order_number__c, Current_Year_Fees__c,  Date_Agreement_Activated__c, Contract_Type__c,'+
            			'Current_Year__c, Invoice_Contact__c, Invoice_Contact_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c from AMA_Agreement_Detail__c where';
        query += ' id = \'' + amaAgrId + '\' limit 1'; 

        AMAAgrDetail = Database.query(query);
        if(AMAAgrDetail != null){
            AMAAgrCaptured = true;
            requestName = AMAAgrDetail.TPA_Request__r.Name;
            AMAPreBillingReportString += createAgreementRecordString(AMAAgrDetail, PAYMENT_PORTION);
            AMAPreBillingReportString += createAgreementRecordString(AMAAgrDetail, ROYALTY_PORTION);
        }
    }
    public void sendMails(){
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueof(AMAPreBillingReportString);
        String csvFileName = 'AMA Pre-bill Report ' + requestName + '.xls';
        csvAttc.setFileName(csvFileName);
        csvAttc.setBody(csvBlob);

        amaSetting = [Select id, CC_Address_for_AMA_PreBill_Report__c from TPA_AMA_Settings__c Limit 1];

        Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
       
        if(!Test.isRunningTest() && String.isNotBlank(amaSetting.get(0).CC_Address_for_AMA_PreBill_Report__c)) {
            List<String> lstAddresses = amaSetting.get(0).CC_Address_for_AMA_PreBill_Report__c.split(';');
            system.debug(lstAddresses);
            mailToSend.setToAddresses(lstAddresses);
        }
        mailToSend.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        mailToSend.setSubject('AMA Pre-bill Report ' + requestName);
        mailToSend.setPlainTextBody('');
        mailToSend.setHtmlBody('');
        try{
            if( !Test.isRunningTest() && UTL_TPA.isSendOutgoingEmails) { 
               Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailToSend});                
            }
        }
        catch(Exception e) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_Child_PreBill_Report.sendMail:::SAP Report Email Failed', AMAAgrDetail.id != null ?  AMAAgrDetail.id : '');
        }

    }
    private string createAgreementRecordString(AMA_Agreement_Detail__c AMAagg, String scenario) {
        system.debug('AMAagg: ' + AMAagg + ' for ' + scenario);
        recordString = '';
        String reqNo = '';
        String reqNoforOpp = '';
        if(String.isNotBlank(AMAagg.TPA_Request__r.Name)) {
            reqNo = AMAagg.TPA_Request__r.Name.replace('-','').replace('TPA','').replaceFirst( '^0+', '');
            reqNo = 'TPA' + reqNo;
            reqNoforOpp = AMAagg.TPA_Request__r.Name.replace('-','').replace('TPA','').replaceFirst( '^0+', '');
            reqNoforOpp = 'TP' + reqNoforOpp;
        }
        
        recordString =  '"'+reqNo+ '-' + AMAagg.Current_Year__c+'"\t'+ '" "\t'; 
        recordString += '="'+AMAagg.TPA_Account_SAP_Code__c +'"\t';  
        
        recordString +=  '"';
        if(String.isNotBlank(AMAagg.TPA_Request__r.Authorized_Signer_Name__c) && !AMAagg.TPA_Request__r.Authorized_Signer_Name__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c)){
            recordString += AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c + ';' + AMAagg.TPA_Request__r.Authorized_Signer_Name__c;
            System.debug('1');
        }else{
            recordString += AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c;
            System.debug('2');
        }
        if(String.isNotBlank(AMAagg.Invoice_Contact__c) && !AMAagg.Invoice_Contact__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Authorized_Signer_Name__c) && !AMAagg.Invoice_Contact__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c)){
            recordString += ';'+ AMAagg.Invoice_Contact__c;
        }
        recordString += '"\t';
        
        recordString +=  '"';
        if(String.isNotBlank(AMAagg.TPA_Request__r.Authorized_Signer_Email__c) && AMAagg.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Vendor_Contact_e_mail__c)){
            recordString += AMAagg.TPA_Request__r.Vendor_Contact_e_mail__c;
            System.debug('3');
        }
        else if(String.isNotBlank(AMAagg.TPA_Request__r.Authorized_Signer_Email__c) && !(AMAagg.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Vendor_Contact_e_mail__c) )) {
            recordString += AMAagg.TPA_Request__r.Vendor_Contact_e_mail__c +';'+AMAagg.TPA_Request__r.Authorized_Signer_Email__c;
            System.debug('4');
        }
        if(String.isNotBlank(AMAagg.Invoice_Contact_Email__c) && !AMAagg.Invoice_Contact_Email__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Vendor_Contact_e_mail__c) && !AMAagg.Invoice_Contact_Email__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Authorized_Signer_Email__c)) {
            recordString +=  ';'+AMAagg.Invoice_Contact_Email__c;
            System.debug('5');
        }
        recordString += '"\t';
        
        recordString += '="'+AMAagg.TPA_Account_SAP_Code__c +'"\t';  // Added by Vikram Singh under Er-3336 //modified by supriya Johari under ER-3534
        
        
        if(string.isBlank(AMAagg.TPA_Request__r.Docusign_Custom_Picklist__c) || AMAagg.TPA_Request__r.Docusign_Custom_Picklist__c == 'No'){
            recordString += '"N/A"\t';
        } else {
            recordString += '="'+AMAagg.Purchase_order_number__c+'"\t'; 
        }   
        
        // add opportunity or order Number
        recordString += '"'+reqNoforOpp+'"\t';
        
        //add header text
        recordString += '"'+AMAagg.TPA_Request__r.Name + ', ' + AMAagg.Current_Year__c +' AMA '+AMAagg.Contract_Type__c+' Fees working on behalf of '+AMAagg.TPA_Request__r.Client_Company_Name_Address__r.Name+'"\t';  
        
        // add material No.
        if(scenario.equalsIgnoreCase(payment_portion)){
            recordString += '"US_AMAROYSBF2"\t';   
        } 
        else if(scenario.equalsIgnoreCase(royalty_portion)){
            recordString += '"US_AMASBP"\t';   
        }        
        
        // add line item text 
        recordString += '""\t';  
        
        // add billing date
        if(AMAagg.Date_Agreement_Activated__c != null){
            recordString += '="'+ AMAagg.Date_Agreement_Activated__c.format('dd.MM.yyyy')+'"\t'; 
        } else {
            recordString += '""\t';
        }  
        
        // add delivery date
        if(AMAagg.Date_Agreement_Activated__c != null){
            recordString += '="'+ AMAagg.Date_Agreement_Activated__c.format('dd.MM.yyyy')+'"\t'; 
        } else{
            recordString += '""\t';
        }  
        
        // Quantity
        recordString += '"1"\t';
        
        // Net Value
        if(AMAagg.Current_Year_Fees__c == null|| AMAagg.Current_Year_Fees__c == 0){
            recordString += '"N/A"\t';    
        } else {
            recordString += getNetValueForScenarios(AMAagg.Current_Year_Fees__c,scenario)+'\t';
        } 
        
        // add currency
        recordString += '"USD"\t'; 
        
        recordString += '\n';
        recordString  = recordString.replace('null','');
        return recordString; 
    }
    private decimal getNetValueForScenarios(Decimal currentFee, String scenario){
        decimal feeValue = 1.00;
        if(currentFee == 21000){
            if(scenario.equalsIgnoreCase(payment_portion)){
               feeValue = 16000.00; 
            }
            else{
                feeValue = 5000.00;
            }
        } else if(currentFee == 10500 ){
            if(scenario.equalsIgnoreCase(payment_portion)){
                feeValue = 8000.00; 
            }
            else{
                feeValue = 2500.00; 
            }
        } else if(currentFee == 5250){
            if(scenario.equalsIgnoreCase(payment_portion)){
                feeValue = 4000.00;
            }
            else{
                feeValue = 1250.00;
            }  
        } else{
            feeValue = currentFee * 1.00;
        }
        return feeValue;
    }
}