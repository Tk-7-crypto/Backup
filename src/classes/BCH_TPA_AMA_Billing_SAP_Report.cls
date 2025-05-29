/**
 *@Author  : Supriya Johari
 *@Purpose : Create and send AMA Billing - Excel Template to match IMS Finance SAP format : ER-2916
 *@Date    : 9 Aug 2016
 */
global class BCH_TPA_AMA_Billing_SAP_Report implements Database.Batchable<sObject>, Database.Stateful {
    private string headerString = '';
    private string AMABillingReportString = '';
    private string recordString = '';
    private string payment_portion = 'AMA Payment Portion';
    private string royalty_portion = 'AMA Royalty Portion';
    private List<TPA_AMA_Settings__c> amaSetting; 
    private List<AMA_Agreement_Detail__c> listToBeUpdated; 
    private AMA_Agreement_Detail__c AMAagg;
    public Boolean includeTestDataOnly{
		get{
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}

    public Boolean includebusinessDataOnly{
		get{
			if(includebusinessDataOnly == null) {
				includebusinessDataOnly = false;
			}
			return includebusinessDataOnly;
		}
		set;
	}
    
    global BCH_TPA_AMA_Billing_SAP_Report()
    {
        headerString = '\ncontrol #/invoice # \t project number \t Bill to Cust \t contact \t email address \t ship to Cust \t Purchase order number \t Opportunity/order number \t Header text \t material# \t line item text \t Billing date \t delivery date \t quantity \t Net Value \t currency \t Billed in Advance \t Credit \t Activated Date \t  Current Year \t Vendor Company Name \t Next Year Net Value \t Next Year \t Current Year Invoice \t Next Year Invoice \t id \n'; // modified by Supriya Johari under ER-3336 // Updated By Neha Bansal Under ER-4081 //Modified by Rajendra under ER-12121 //Updated by Rajendra under ER-12313
        AMABillingReportString  = headerString ;
        
        if(amaSetting == null)
        {
          amaSetting = TPA_AMA_Settings__c.getAll().values();
        }
        
        listToBeUpdated = new List<AMA_Agreement_Detail__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        string query = 'SELECT Id, Name, TPA_Request__r.Name, Client__c, Vendor_Legal_Name__c, TPA_Account_SAP_Code__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Client_Company_Name_Address__r.Name,TPA_Request__r.Docusign_Custom_Picklist__c,TPA_Request__r.Authorized_Signer_Name__c,TPA_Request__r.Authorized_Signer_Email__c, Purchase_order_number__c, Current_Year_Fees__c, Next_Year_Fees__c, Date_Agreement_Activated__c,Contract_Type__c, AMA_Amount_to_be_Credited_Billed__c, Activated_for_SAP_Report__c, Current_Year__c, Invoice_Contact__c, Invoice_Contact_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, Next_Year__c, Billed_in_Advance__c,Current_Year_Invoice__c,Next_Year_Invoice__c from AMA_Agreement_Detail__c where Date_Agreement_Activated__c != null and (Contract_Type__c = \'Service Bureau II\'  OR Contract_Type__c = \'Contract Sales Force\')'; 
        
        if(!Test.isRunningTest())
            query  += 'and (TPA_Request__r.Request_Status__c = \'In Effect\' OR TPA_Request__r.Request_Status__c = \'Expired\')';
        
        query += ' and (Current_Year_Fees__c > 0 OR Next_Year_Fees__c > 0) and Current_Year__c =\''+String.valueOf(Date.today().year())+'\''; 
        
        if(includeTestDataOnly){
            query += ' and (Client__c Like \'Test_'+'%\'  OR Vendor_Legal_Name__c Like \'Test_'+'%\' )';
        }

        if(includebusinessDataOnly){
            query += ' and ((NOT Client__c Like \'Test_'+'%\')  AND (NOT Vendor_Legal_Name__c Like \'Test_'+'%\' ))';
        }
             

        query += ' order by Date_Agreement_Activated__c DESC';
        if(Test.isRunningTest())
        {
            query += ' limit 1' ;
        }
        return Database.getQueryLocator(query);
    }
    
    TPA_Settings__c TPASetting;
    global void execute(Database.BatchableContext bc, List<Sobject> objList)
    {
        
        TPASetting = TPA_Settings__c.getOrgDefaults();
        for(SObject obj : objList)
        {
            AMAagg = (AMA_Agreement_Detail__c)obj;
            AMABillingReportString += createAgreementRecordString(AMAagg, payment_portion); // scenario is AMA Payment Portion
            AMABillingReportString += createAgreementRecordString(AMAagg, royalty_portion); // scenarios is AMA Royalty Portion
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueof(AMABillingReportString);
        String csvFileName = 'AMA Billing Template to match IMS Finance SAP Format.xls';
        csvAttc.setFileName(csvFileName);
        csvAttc.setBody(csvBlob);
        
        List<TPA_AMA_Settings__c> amaSetting = [Select id, AMA_SAP_Report_Mail_Template_Id__c, CC_Address_for_AMA_SAP_Report__c, To_Address_for_AMA_SAP_Report__c from TPA_AMA_Settings__c Limit 1];
            
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        try
        {
            email = Messaging.renderStoredEmailTemplate(amaSetting.get(0).AMA_SAP_Report_Mail_Template_Id__c, NULL, UTL_TPA.emailTargetContactId);
        }
        catch(Exception e) 
        {
            System.debug('Email Failed: ' + e.getMessage());
        }
        
        //Database.rollback(sp);
        
        try
        {
            update listToBeUpdated;
        }
        catch(Exception e) 
        {
            System.debug('SAP Report Update Failed: ' + e.getMessage());
        }
        
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        
        emailToSend.setPlainTextBody(email.getPlainTextBody());
        emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(email.getHTMLBody()));
        emailToSend.setSubject(email.getSubject());
        emailToSend.setCharset('UTF-8'); 

        if(String.isNotBlank(amaSetting.get(0).To_Address_for_AMA_SAP_Report__c))
        {
            List<String> toAdd = amaSetting.get(0).To_Address_for_AMA_SAP_Report__c.split(';');
            emailToSend.setToAddresses(toAdd);
        }
        if(String.isNotBlank(amaSetting.get(0).CC_Address_for_AMA_SAP_Report__c))
        {
            List<String> ccTo = amaSetting.get(0).CC_Address_for_AMA_SAP_Report__c.split(';');
            emailToSend.setCCAddresses(ccTo);
        }
        emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        
        try
        {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) { 
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
            }
        }
        catch(Exception e) 
        {
            System.debug('SAP Report Email Failed: ' + e.getMessage());
        }
    }
   
    private string createAgreementRecordString(AMA_Agreement_Detail__c AMAagg, String scenario)
    {
        system.debug('AMAagg: ' + AMAagg);
        recordString = '';
        
        String reqNo = '';
        String reqNoforOpp = '';
        if(String.isNotBlank(AMAagg.TPA_Request__r.Name))
        {
            reqNo = AMAagg.TPA_Request__r.Name.replace('-','').replace('TPA','').replaceFirst( '^0+', '');
            reqNo = 'TPA' + reqNo;
            reqNoforOpp = AMAagg.TPA_Request__r.Name.replace('-','').replace('TPA','').replaceFirst( '^0+', '');
            reqNoforOpp = 'TP' + reqNoforOpp;
        }
        
        recordString =  '"'+reqNo+ '-' + AMAagg.Current_Year__c+'"\t'+
                        '" "\t'; 
        recordString += '="'+AMAagg.TPA_Account_SAP_Code__c +'"\t';  

        recordString +=  '"';
        if(String.isNotBlank(AMAagg.TPA_Request__r.Authorized_Signer_Name__c) && !AMAagg.TPA_Request__r.Authorized_Signer_Name__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c)){
             
            if (AMAagg.TPA_Request__r.Authorized_Signer_Name__c.contains('"') || AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c.contains('"')) {
                if (AMAagg.TPA_Request__r.Authorized_Signer_Name__c.contains('"')) {
                    recordString += AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c + ';' + AMAagg.TPA_Request__r.Authorized_Signer_Name__c.replace('"','');
                }
                if (AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c.contains('"')) {
                    recordString += AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c.replace('"','') + ';' + AMAagg.TPA_Request__r.Authorized_Signer_Name__c.replace('"','');
                }
            } else {
                recordString += AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c + ';' + AMAagg.TPA_Request__r.Authorized_Signer_Name__c;
            }
            System.debug('1');
        }else{
            if (AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c.contains('"')) {
                recordString += AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c.replace('"','');
            } else {
                recordString += AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c;
            }
            
            System.debug('2');
        }
        if(String.isNotBlank(AMAagg.Invoice_Contact__c) && !AMAagg.Invoice_Contact__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Authorized_Signer_Name__c) && !AMAagg.Invoice_Contact__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c)){
            
            if (AMAagg.Invoice_Contact__c.contains('"')) {
                recordString += ';'+ AMAagg.Invoice_Contact__c.replace('"','');
            } else {
                recordString += ';'+ AMAagg.Invoice_Contact__c;
            }
            
        }
        recordString += '"\t';
        
        recordString +=  '"';
        if(String.isNotBlank(AMAagg.TPA_Request__r.Authorized_Signer_Email__c) && AMAagg.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(AMAagg.TPA_Request__r.Vendor_Contact_e_mail__c)){
            recordString += AMAagg.TPA_Request__r.Vendor_Contact_e_mail__c; // Modified by C.P.Pandey under Issue-12141
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

                       
        if(string.isBlank(AMAagg.TPA_Request__r.Docusign_Custom_Picklist__c) || AMAagg.TPA_Request__r.Docusign_Custom_Picklist__c == 'No')
        {
            recordString += '"N/A"\t';
        } else 
        {
            recordString += '="'+AMAagg.Purchase_order_number__c+'"\t'; 
        }   
        
        // add opportunity or order Number
        recordString += '"'+reqNoforOpp+'"\t';
        
        //add header text
        
        recordString += '"'+AMAagg.TPA_Request__r.Name + ', ' + AMAagg.Current_Year__c +' AMA '+AMAagg.Contract_Type__c+' Fees working on behalf of ';
	if (AMAagg.TPA_Request__r.Client_Company_Name_Address__r.Name.contains('"')) {
            recordString += AMAagg.TPA_Request__r.Client_Company_Name_Address__r.Name.replace('"','') +'"\t';
        } 
        else{
            recordString += AMAagg.TPA_Request__r.Client_Company_Name_Address__r.Name +'"\t';
        }   
                     
        // add material No.
        if(scenario.equalsIgnoreCase(payment_portion))
        {
            recordString += '"US_AMAROYSBF2"\t';   
        } 
        else if(scenario.equalsIgnoreCase(royalty_portion))
        {
            recordString += '"US_AMASBP"\t';   
        }        
        
        // add line item text 
        recordString += '""\t';  
        

        // add billing date
        if(AMAagg.Date_Agreement_Activated__c != null)
        {
             recordString += '="'+ AMAagg.Date_Agreement_Activated__c.format('dd.MM.yyyy')+'"\t'; // modified by supriya Johari under ER-3534 // Updated By Neha Under ER-4081
        } else 
        {
            recordString += '""\t';
        }  
        
        // add delivery date
        if(AMAagg.Date_Agreement_Activated__c != null)
        {
             recordString += '="'+ AMAagg.Date_Agreement_Activated__c.format('dd.MM.yyyy')+'"\t'; // modified by supriya Johari under ER-3534 // Updated By Neha Under ER-4081
        } else 
        {
            recordString += '""\t';
        }  
        

        recordString += '"1"\t';
        

        if(AMAagg.Current_Year_Fees__c == null|| AMAagg.Current_Year_Fees__c == 0)
        {
            recordString += '"N/A"\t';    
        } else
        {
            recordString += getNetValueForScenarios(AMAagg.Current_Year_Fees__c,scenario)+'\t'; // modified by Supriya Johari under ER-3534 //Modified by Rajendra under ER-12121
        } 
        

        
        // add currency
        recordString += '"USD"\t'; 

        if(AMAagg.Billed_in_Advance__c){
            recordString += 'Y' + ' \t';
        }else{
            recordString += 'N' + ' \t';
        }

        // add ama amount to be credited or billed
        if(AMAagg.AMA_Amount_to_be_Credited_Billed__c  != null)
        {
             recordString += '="'+AMAagg.AMA_Amount_to_be_Credited_Billed__c.setScale(2)+'" \t'; // modified by Supriya Johari under Issue-10740
        } else 
        {
            recordString += '\t';
        }  

        if(AMAagg.Activated_for_SAP_Report__c == null)
        {
            if(!amaSetting.isEmpty() && amaSetting.get(0).Exclude_Test_Records_in_Report__c)
            {
                AMAagg.Activated_for_SAP_Report__c = datetime.now();
                listToBeUpdated.add(AMAagg);
            }
            else 
            {
                if(!amaSetting.isEmpty() && !amaSetting.get(0).Exclude_Test_Records_in_Report__c && String.isNotBlank(AMAagg.Client__c)  && String.isNotBlank(AMAagg.Vendor_Legal_Name__c) &&  (AMAagg.Client__c.startsWithIgnoreCase('Test_') || AMAagg.Vendor_Legal_Name__c.startsWithIgnoreCase('Test_')))
                {
                    AMAagg.Activated_for_SAP_Report__c = datetime.now();
                    listToBeUpdated.add(AMAagg);
                }
            }
            
        }

        if(AMAagg.Activated_for_SAP_Report__c != null)
        recordString += '="'+AMAagg.Activated_for_SAP_Report__c.format('MM.dd.yyyy') +'" \t'; //Modified by Rajendra under ER-12121
        else
        recordString += '="" \t';
        
        
        recordString += '= "';
        if(AMAagg.Current_Year__c != null){
            recordString += AMAagg.Current_Year__c  + '" \t';
        }else {
            recordString += 'N/A' + '" \t';
        }
           
        recordString += '="';
        if(AMAagg.Vendor_Legal_Name__c  != null)
        {
           
            if (AMAagg.Vendor_Legal_Name__c.contains('"')) {
                recordString += AMAagg.Vendor_Legal_Name__c.replace('"','') + '" \t';
            } else {
                recordString += AMAagg.Vendor_Legal_Name__c + '" \t';
            }
              
        } 
        
        
        if(AMAagg.Next_Year_Fees__c != null && AMAagg.Next_Year_Fees__c > 0){
            recordString += getNetValueForScenarios(AMAagg.Next_Year_Fees__c, scenario)  + '\t';
        }else {
            recordString += 'N/A' + ' \t';
        }
        recordString += '= "';
        if(AMAagg.Next_Year__c != null){
            recordString += AMAagg.Next_Year__c+ '\t';
        }else {
            recordString += 'N/A';
        }
        
        if(AMAagg.Current_Year_Invoice__c != null){
            
            recordString += AMAagg.Current_Year_Invoice__c+ '\t';
        }
        else{
            recordString += 'N/A'+ ' \t';
        }
        
        if(AMAagg.Next_Year_Invoice__c != null){
            
            recordString += AMAagg.Next_Year_Invoice__c+ '\t';
        }
        else{
            recordString += 'N/A'+ ' \t';
        }
        if(AMAagg.id != null){
            
            recordString += AMAagg.id;
        }
        else{
            recordString += 'N/A';
        }
        
        recordString += '\n';
        recordString  = recordString.replace('null','');
        return recordString; 
    }
    
    private decimal getNetValueForScenarios(Decimal currentFee, String scenario)
    {
        decimal feeValue = 1.00;
        if(currentFee == 21000)
        {
            if(scenario.equalsIgnoreCase(payment_portion))
            {
               feeValue = 16000.00; 
            }
            else
            {
                feeValue = 5000.00;
            }
        } else if(currentFee == 10500 )
        {
            if(scenario.equalsIgnoreCase(payment_portion))
            {
                feeValue = 8000.00; 
            }
            else
            {
                feeValue = 2500.00; 
            }
            
        } else if(currentFee == 5250)
        {
            if(scenario.equalsIgnoreCase(payment_portion))
            {
                feeValue = 4000.00;
            }
            else
            {
                feeValue = 1250.00;
            }
            
        } else
        {
            feeValue = currentFee * 1.00;
        }
        return feeValue;
    }
}
