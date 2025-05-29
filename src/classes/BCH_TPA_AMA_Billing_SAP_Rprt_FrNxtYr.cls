global class BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr implements Database.Batchable<sObject>, Database.Stateful {
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
    
    global BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr()
    {
        headerString = 'control #/invoice # \t project number \t Bill to Cust \t contact \t email address \t ship to Cust \t Purchase order number \t Opportunity/order number \t Header text \t material# \t line item text \t Billing date \t delivery date \t quantity \t Net Value \t currency \t Credit \t Activated Date \t Year \n'; 
        AMABillingReportString  = headerString ;
        //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_AMA_Billing_SAP_Rprt_FrNxtYr');
        if(amaSetting == null)
        {
          amaSetting = TPA_AMA_Settings__c.getAll().values();
        }
        listToBeUpdated = new List<AMA_Agreement_Detail__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        string query = 'SELECT Id, Name, TPA_Request__r.Name, Client__c, Vendor_Legal_Name__c, TPA_Account_SAP_Code__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Client_Company_Name_Address__r.Name,TPA_Request__r.Docusign_Custom_Picklist__c, TPA_Request__r.Authorized_Signer_Name__c, TPA_Request__r.Authorized_Signer_Email__c, Purchase_order_number__c, Current_Year_Fees__c, Next_Year_Fees__c, Date_Agreement_Activated__c,Contract_Type__c, AMA_Amount_to_be_Credited_Billed__c, Activated_for_SAP_Report__c, Next_Year__c  from AMA_Agreement_Detail__c where Date_Agreement_Activated__c != null and Next_Year_Fees__c != null and Next_Year_Fees__c != 0 and Contract_Type__c = \'Service Bureau II\''; 

        if(!Test.isRunningTest())
            query  += 'and TPA_Request__r.Request_Status__c = \'In Effect\'';
        query += ' and (Current_Year_Fees__c > 0 OR Next_Year_Fees__c > 0) ';
        if(!amaSetting.isEmpty() && amaSetting.get(0).Billing_SAP_Report_For_Year__c != null && amaSetting.get(0).Billing_SAP_Report_For_Year__c != '')
            query += ' and (Next_Year__c = \''+ amaSetting.get(0).Billing_SAP_Report_For_Year__c +'\')  ';
        //if(!amaSetting.isEmpty() && amaSetting.get(0).Exclude_Test_Records_in_Report__c)
        if(includeTestDataOnly){
            query += ' and (Client__c Like \'Test_'+'%\'  OR Vendor_Legal_Name__c Like \'Test_'+'%\' )';
        }
             
        query += ' order by Date_Agreement_Activated__c DESC';
        if(Test.isRunningTest())
        {
            query += ' limit 1' ;
        }
        
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    TPA_Settings__c TPASetting;
    global void execute(Database.BatchableContext bc, List<Sobject> objList)
    {
        
        // TPASetting = TPA_Settings__c.getOrgDefaults();
        // for(SObject obj : objList)
        // {
        //     AMAagg = (AMA_Agreement_Detail__c)obj;
        //     AMABillingReportString += createAgreementRecordString(AMAagg, payment_portion); // scenario is AMA Payment Portion
        //     AMABillingReportString += createAgreementRecordString(AMAagg, royalty_portion); // scenarios is AMA Royalty Portion
        // }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        // Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        // Blob csvBlob = Blob.valueof(AMABillingReportString);
        // String csvFileName = 'AMA Billing Template to match IMS Finance SAP Format.xls';
        // csvAttc.setFileName(csvFileName);
        // csvAttc.setBody(csvBlob);
        
        // amaSetting = TPA_AMA_Settings__c.getAll().values();
        // Contact contObj = [select id, Email from Contact where email != null limit 1];
            
        // Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // /*email.setTargetObjectId(contObj.Id);
        // email.setTemplateId(amaSetting.get(0).AMA_SAP_Report_Mail_Template_Id_NextYr__c);
        // Savepoint sp = Database.setSavepoint();*/
        
        // try
        // {
        //     /*if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) { 
        //         Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        //     }*/
        //     email = Messaging.renderStoredEmailTemplate(amaSetting.get(0).AMA_SAP_Report_Mail_Template_Id_NextYr__c, NULL, contObj.Id);
        // }
        // catch(Exception e) 
        // {
        //     System.debug('Email Failed: ' + e.getMessage());
        // }
        
        // //Database.rollback(sp);
        
        // try
        // {
        //     update listToBeUpdated;
        // }
        // catch(Exception e) 
        // {
        //     System.debug('SAP Report Update Failed: ' + e.getMessage());
        // }
        
        // Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        
        // emailToSend.setPlainTextBody(email.getPlainTextBody());
        // emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(email.getHTMLBody()));
        // emailToSend.setSubject(email.getSubject() + ' ' + amaSetting.get(0).Billing_SAP_Report_For_Year__c);
        // emailToSend.setCharset('UTF-8');  
        // //   emailToSend.setToAddresses(new List<String> {'neha.bansal@metacube.com'});
        // if(String.isNotBlank(amaSetting.get(0).To_Address_for_AMA_SAP_Report__c))
        // {
        //     List<String> toAdd = amaSetting.get(0).To_Address_for_AMA_SAP_Report__c.split(';');
        //     emailToSend.setToAddresses(toAdd);
        // }
        // if(String.isNotBlank(amaSetting.get(0).CC_Address_for_AMA_SAP_Report__c))
        // {
        //     List<String> ccTo = amaSetting.get(0).CC_Address_for_AMA_SAP_Report__c.split(';');
        //     emailToSend.setCCAddresses(ccTo);
        // } 
        // emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        
        // try
        // {
        //     if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) { 
        //         Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
        //     }
        // }
        // catch(Exception e) 
        // {
        //     System.debug('SAP Report Email Failed: ' + e.getMessage());
        // }
    }
   
    // private string createAgreementRecordString(AMA_Agreement_Detail__c AMAagg, String scenario)
    // {
    //     system.debug('AMAagg: ' + AMAagg);
    //     recordString = '';
        
    //     String reqNo = '';
    //     if(String.isNotBlank(AMAagg.TPA_Request__r.Name))
    //     {
    //         reqNo = AMAagg.TPA_Request__r.Name.replace('-','');
    //     }
        

    //     recordString =  '"'+reqNo+'"\t'+
    //                     '" "\t';
        
    //     recordString += '="'+AMAagg.TPA_Account_SAP_Code__c +'"\t';  
        
    //     if(AMAagg.TPA_Request__r.Authorized_Signer_Name__c != null) {
    //         recordString +=  '"'+AMAagg.TPA_Request__r.Authorized_Signer_Name__c+'"\t'; 
    //     }
    //     else {
    //         recordString +=  '"'+AMAagg.TPA_Request__r.Vendor_Contact_Name_f__c+'"\t';
    //     }
    //     if(AMAagg.TPA_Request__r.Authorized_Signer_Email__c != null) {
    //         recordString += '"'+AMAagg.TPA_Request__r.Authorized_Signer_Email__c+'"\t';
    //     }
    //     else {
    //         recordString += '"'+AMAagg.TPA_Request__r.Vendor_Contact_Email_Client__c+'"\t';
    //     }
        
    //     recordString += '="'+AMAagg.TPA_Account_SAP_Code__c +'"\t';  
                       
    //     if(string.isBlank(AMAagg.TPA_Request__r.Docusign_Custom_Picklist__c) || AMAagg.TPA_Request__r.Docusign_Custom_Picklist__c == 'No')
    //     {
    //         recordString += '"N/A"\t';
    //     } else 
    //     {
    //         recordString += '="'+AMAagg.Purchase_order_number__c+'"\t'; 
    //     }   
        
    //     recordString += '"'+reqNo+'"\t';
        
        
    //     recordString += '"'+AMAagg.TPA_Request__r.Name+' , '+ amaSetting.get(0).Billing_SAP_Report_For_Year__c + ' AMA ' +AMAagg.Contract_Type__c+' Fees working on behalf of '+AMAagg.TPA_Request__r.Client_Company_Name_Address__r.Name+'"\t'; 

    //     if(scenario.equalsIgnoreCase(payment_portion))
    //     {
    //         recordString += '"US_AMAROYSBF2"\t';   
    //     } 
    //     else if(scenario.equalsIgnoreCase(royalty_portion))
    //     {
    //         recordString += '"US_AMASBP"\t';   
    //     }        
        
    //     // add line item text 
    //     recordString += '""\t';  
        
    //     // add billing date
    //     if(AMAagg.Date_Agreement_Activated__c != null)
    //     {
    //          recordString += '="'+ AMAagg.Date_Agreement_Activated__c.format('dd/MM/yyyy')+'"\t'; 
    //     } else 
    //     {
    //         recordString += '""\t';
    //     }  
        
    //     // add delivery date
    //     if(AMAagg.Date_Agreement_Activated__c != null)
    //     {
    //          recordString += '="'+ AMAagg.Date_Agreement_Activated__c.format('dd/MM/yyyy')+'"\t'; 
    //     } else 
    //     {
    //         recordString += '""\t';
    //     }  
        
    //     // add quantity
    //     recordString += '"1"\t';
      
    //     // add next year Fee
    //     if(AMAagg.Next_Year_Fees__c == null || AMAagg.Next_Year_Fees__c == 0)
    //     {
    //         recordString += '"N/A"\t';    
    //     } else
    //     {
    //         recordString += '="'+getNetValueForScenarios(AMAagg.Next_Year_Fees__c,scenario) +'"\t';
    //     }
        
        
    //     // add currency
    //     recordString += '"USD"\t'; 
        
    //     // add ama amount to be credited or billed
    //     if(AMAagg.AMA_Amount_to_be_Credited_Billed__c  != null)
    //     {
    //          recordString += '="'+AMAagg.AMA_Amount_to_be_Credited_Billed__c.setScale(2)+'" \t'; 
    //     } else 
    //     {
    //         recordString += '\t';
    //     }  

    //     // add ama activated date when it was first added in sap report
    //     if(AMAagg.Activated_for_SAP_Report__c == null)
    //     {
    //         if(!amaSetting.isEmpty() && amaSetting.get(0).Exclude_Test_Records_in_Report__c)
    //         {
    //             AMAagg.Activated_for_SAP_Report__c = datetime.now();
    //             listToBeUpdated.add(AMAagg);
    //         }
    //         else 
    //         {
    //             if(!amaSetting.isEmpty() && !amaSetting.get(0).Exclude_Test_Records_in_Report__c && String.isNotBlank(AMAagg.Client__c)  && String.isNotBlank(AMAagg.Vendor_Legal_Name__c) &&  (AMAagg.Client__c.startsWithIgnoreCase('Test_') || AMAagg.Vendor_Legal_Name__c.startsWithIgnoreCase('Test_')))
    //             {
    //                 AMAagg.Activated_for_SAP_Report__c = datetime.now();
    //                 listToBeUpdated.add(AMAagg);
    //             }
    //         }
            
    //     }
        
    //     recordString += '="';
    //     if(AMAagg.Activated_for_SAP_Report__c != null){
    //         recordString += AMAagg.Activated_for_SAP_Report__c.format('dd/MM/yyyy') ;
    //     }
    //     recordString += '" \t';
        
    //     recordString += '="';
    //     if(!amaSetting.isEmpty() && amaSetting.get(0).Billing_SAP_Report_For_Year__c != null){
    //         recordString += amaSetting.get(0).Billing_SAP_Report_For_Year__c ;
    //     }
    //     recordString += '" \n';
        
    //     recordString  = recordString.replace('null','');
    //     return recordString; 
    // }
    
    // private decimal getNetValueForScenarios(Decimal currentFee, String scenario)
    // {
    //     decimal feeValue = 0.00;
    //     if(currentFee == 21000)
    //     {
    //         if(scenario.equalsIgnoreCase(payment_portion))
    //         {
    //            feeValue = 16000.00; 
    //         }
    //         else
    //         {
    //             feeValue = 5000.00;
    //         }
    //     } else if(currentFee == 10500 )
    //     {
    //         if(scenario.equalsIgnoreCase(payment_portion))
    //         {
    //             feeValue = 8000.00; 
    //         }
    //         else
    //         {
    //             feeValue = 2500.00; 
    //         }
            
    //     } else if(currentFee == 5250)
    //     {
    //         if(scenario.equalsIgnoreCase(payment_portion))
    //         {
    //             feeValue = 4000.00;
    //         }
    //         else
    //         {
    //             feeValue = 1250.00;
    //         }
            
    //     } else
    //     {
    //         feeValue = currentFee;
    //     }
    //     return feeValue.setScale(2);
    // }
}