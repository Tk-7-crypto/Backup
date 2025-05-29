public without sharing class TGRH_TPAAMAAgreement {

    // Private Variables
    private boolean m_isExecuting = false;
    private String requires_offshore = 'Vendor requires offshore'; 

    // Properties
    public boolean IsTriggerContext {
        get{ return m_isExecuting;}
    }

    // Construction
    public TGRH_TPAAMAAgreement(boolean isExecuting) {
        m_IsExecuting = isExecuting;
    }

    

    public void onBeforeUpdate(List<AMA_Agreement_Detail__c> OldAMAagreementDetails, List<AMA_Agreement_Detail__c> updatedAMAagreementDetails, Map<Id, AMA_Agreement_Detail__c> oldMap, Map<Id, AMA_Agreement_Detail__c> updatedMap) {

        for(AMA_Agreement_Detail__c obj:updatedAMAagreementDetails)
        {
            if(obj.Contract_Type__c != null && obj.Contract_Type__c == 'Existing Agreement' && (obj.Is_AMA_License_Required__c == null || obj.Is_AMA_License_Required__c == false) && (obj.Ex_Contract_Type__c == null || obj.Ex_Contract_Type__c == '')){
                obj.addError('AMA Existing Contract Type Found cannot be blank');
            }
            if(updatedMap.get(obj.id).AMA_Amount_to_be_Credited_Billed__c !=  oldMap.get(obj.id).AMA_Amount_to_be_Credited_Billed__c)
            {
               obj.AMA_Amount_Modified_On__c = Datetime.now();
               obj.AMA_Amount_Modified_By__c = UserInfo.getUserId();
            }

            if(updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c !=  oldMap.get(obj.id).AMA_Manual_Trigger_Reasons__c  && oldMap.get(obj.id).AMA_Manual_Trigger_Reasons__c != null && oldMap.get(obj.id).AMA_Manual_Trigger_Reasons__c.containsIgnoreCase(requires_offshore)  && (updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c== null || !updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c.containsIgnoreCase(requires_offshore)) ) {
                if(String.isNotBlank(obj.Status_of_Offshore_Questionnaire__c)) {
                   obj.Status_of_Offshore_Process__c = '';
                }
            }
            
            	
             if((updatedMap.get(obj.id).Current_Year_Fees__c != null && SRV_TPA_AMAAgreementDetail.oldCurrentYearFee != null && (updatedMap.get(obj.id).Current_Year_Fees__c !=  SRV_TPA_AMAAgreementDetail.oldCurrentYearFee)) || (updatedMap.get(obj.id).Next_Year_Fees__c != null && SRV_TPA_AMAAgreementDetail.oldNextYearFee != null && (updatedMap.get(obj.id).Next_Year_Fees__c !=  SRV_TPA_AMAAgreementDetail.oldNextYearFee)) || (updatedMap.get(obj.id).Contract_Type__c != null && SRV_TPA_AMAAgreementDetail.oldContractType != null  && (updatedMap.get(obj.id).Contract_Type__c !=  SRV_TPA_AMAAgreementDetail.oldContractType))   ) { 
                 obj.Vendor_AMA_Fee_Response__c = null;
             }

            if(updatedMap.get(obj.id).AMA_Manual_Review__c &&
                updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c != oldMap.get(obj.id).AMA_Manual_Trigger_Reasons__c
                    && updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c != null && updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c.containsIgnoreCase(requires_offshore)) {
                        if(!SRV_TPA_AMAAgreementDetail.isvalidVendorAccessCountry || !SRV_TPA_AMAAgreementDetail.isvalidVendorStorageCountry  || !SRV_TPA_AMAAgreementDetail.isPreAppTech ){
                            obj.Status_of_Offshore_Process__c = UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS;
                            obj.Last_AMA_offshore_reminder_mail_sent__c = Date.today();
            }}
            
            Boolean isvalidOffshoreCountry = true;
            Boolean isOnlyUS = false;
            if(obj.Vendor_employee_access_data_in_country__c != null){
              if(obj.Vendor_employee_access_data_in_country__c.equalsIgnoreCase('united states')){
                isOnlyUS = true;
              }
              if(!isOnlyUS){ 
                for(String country: obj.Vendor_employee_access_data_in_country__c.split(',')){
                      if(!UTL_TPA.offshoreCountries.contains(country.trim().toLowerCase())){
                          isvalidOffshoreCountry = false;
                          break;
                      }
                  }
              } 

            }
            //if(!isvalidOffshoreCountry){
            //    obj.Status_of_Offshore_Process__c = UTL_TPA.VENDOR_SELECTED_NON_APPROVED_AMA_LOCATION;
            //}
            
            if(String.isNotBlank(updatedMap.get(obj.id).AMA_Services_Provided__c)) {
                 obj.AMA_Project_Uses_Value__c = updatedMap.get(obj.id).AMA_Services_Provided__c.replace(';', ', ');
            }
             
        }

    }

     
    public void onAfterUpdate(List<AMA_Agreement_Detail__c> OldAMAagreementDetails, List<AMA_Agreement_Detail__c> updatedAMAagreementDetails, Map<Id, AMA_Agreement_Detail__c> oldMap, Map<Id, AMA_Agreement_Detail__c> updatedMap) {

        Boolean infoUpdated = false;
        Map<Id,List<String>> subjectTaskMap = new Map<Id,List<String>>();
        Map<id,AMA_Agreement_Detail__c> amaAgrIdWithRcrd = new Map<ID, AMA_Agreement_Detail__c>([select id, Client__c, Vendor_Legal_Name__c, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__c, TPA_Request__r.TP_Processor_Email__c from AMA_Agreement_Detail__c where id in: updatedMap.keySet()]);
        
        for(AMA_Agreement_Detail__c obj:updatedAMAagreementDetails)
        {
            List<String> taskSubjects = new List<String>();
            if(updatedMap.get(obj.id).Ex_Client__c !=  oldMap.get(obj.id).Ex_Client__c)
            {
               infoUpdated = true;
               String subject = 'Client Changed from ' + oldMap.get(obj.id).Ex_Client__c + ' to ' +  updatedMap.get(obj.id).Ex_Client__c;
               taskSubjects.add(subject);
            }
            if(updatedMap.get(obj.id).Ex_DBL__c !=  oldMap.get(obj.id).Ex_DBL__c)
            {
               infoUpdated = true;
               String subject = 'DBL Changed from ' + oldMap.get(obj.id).Ex_DBL__c + ' to ' +  updatedMap.get(obj.id).Ex_DBL__c;
               taskSubjects.add(subject);
            }
            if(updatedMap.get(obj.id).Ex_Client_Services_On_Behalf_Of__c !=  oldMap.get(obj.id).Ex_Client_Services_On_Behalf_Of__c)
            {
               infoUpdated = true;
               String subject = 'Client services on behalf of Changed from ' + oldMap.get(obj.id).Ex_Client_Services_On_Behalf_Of__c + ' to ' +  updatedMap.get(obj.id).Ex_Client_Services_On_Behalf_Of__c;
               taskSubjects.add(subject);
            }
            if(updatedMap.get(obj.id).Ex_Contract_Type__c !=  oldMap.get(obj.id).Ex_Contract_Type__c)
            {
               infoUpdated = true;
               String subject ='Contract Type Changed from ' + oldMap.get(obj.id).Ex_Contract_Type__c + ' to ' +  updatedMap.get(obj.id).Ex_Contract_Type__c;
               taskSubjects.add(subject);
            }

             
            if(updatedMap.get(obj.id).Ex_Contract_End_Date__c !=  oldMap.get(obj.id).Ex_Contract_End_Date__c)
            {
               infoUpdated = true;
               String subject = 'Contract End Date Changed from ' + oldMap.get(obj.id).Ex_Contract_End_Date__c + ' to ' +  updatedMap.get(obj.id).Ex_Contract_End_Date__c;
               taskSubjects.add(subject);
            }
             
            if(updatedMap.get(obj.id).Ex_Contract_List_Type__c !=  oldMap.get(obj.id).Ex_Contract_List_Type__c)
            {
               infoUpdated = true;
               String subject = 'Contract List Type Changed from ' + oldMap.get(obj.id).Ex_Contract_List_Type__c + ' to ' +  updatedMap.get(obj.id).Ex_Contract_List_Type__c;
               taskSubjects.add(subject);
            }

             
            if(updatedMap.get(obj.id).Ex_Max_Fee_Reached__c !=  oldMap.get(obj.id).Ex_Max_Fee_Reached__c)
            {
               infoUpdated = true;
               String subject = 'Max Fee reached Changed from ' + oldMap.get(obj.id).Ex_Max_Fee_Reached__c + ' to ' +  updatedMap.get(obj.id).Ex_Max_Fee_Reached__c;
               taskSubjects.add(subject);
            }
             
            if(updatedMap.get(obj.id).Ex_Offshore_Approval__c !=  oldMap.get(obj.id).Ex_Offshore_Approval__c)
            {
               infoUpdated = true;
               String subject = 'Offshore approval Changed from ' + oldMap.get(obj.id).Ex_Offshore_Approval__c + ' to ' +  updatedMap.get(obj.id).Ex_Offshore_Approval__c;
               taskSubjects.add(subject);
            }
            // for Offshore Location
            if(updatedMap.get(obj.id).Ex_Offshore_Location__c !=  oldMap.get(obj.id).Ex_Offshore_Location__c)
            {
               infoUpdated = true;
               String subject = 'Offshore Location Changed from ' + oldMap.get(obj.id).Ex_Offshore_Location__c + ' to ' +  updatedMap.get(obj.id).Ex_Offshore_Location__c;
               taskSubjects.add(subject);
            }

            // for Special Terms/Conditions
            if(updatedMap.get(obj.id).Ex_Special_Terms_Conditions__c !=  oldMap.get(obj.id).Ex_Special_Terms_Conditions__c)
            {
               infoUpdated = true;
               String exSpecialTermsCondition = oldMap.get(obj.id).Ex_Special_Terms_Conditions__c;

                
               if(String.isNotBlank(exSpecialTermsCondition) && exSpecialTermsCondition.length() > 100)
               {
                   exSpecialTermsCondition = exSpecialTermsCondition.substring(0, 100) + '...';
               }
               

               String subject = 'Special Terms and Conditions Changed from ' + exSpecialTermsCondition + ' to ' +  updatedMap.get(obj.id).Ex_Special_Terms_Conditions__c;
               taskSubjects.add(subject);
            }
             
            // for Vendor Reasons for Termination
            if(updatedMap.get(obj.id).Vendor_Reasons_for_Termination__c !=  oldMap.get(obj.id).Vendor_Reasons_for_Termination__c)
            {
               infoUpdated = true;
               String subject = 'Vendor Reasons for Termination Changed from ' + oldMap.get(obj.id).Vendor_Reasons_for_Termination__c + ' to ' +  updatedMap.get(obj.id).Vendor_Reasons_for_Termination__c;
               taskSubjects.add(subject);
            }

            // for Status of Cancelation Request
            if(updatedMap.get(obj.id).Status_of_Cancelation_Request__c !=  oldMap.get(obj.id).Status_of_Cancelation_Request__c)
            {
               infoUpdated = true;
               String subject = 'Status of Cancelation Request Changed from ' + oldMap.get(obj.id).Status_of_Cancelation_Request__c + ' to ' +  updatedMap.get(obj.id).Status_of_Cancelation_Request__c;
               taskSubjects.add(subject);
            }

             
            // for Billing sap report
            if(updatedMap.get(obj.id).Activated_for_SAP_Report__c !=  oldMap.get(obj.id).Activated_for_SAP_Report__c)
            {
               infoUpdated = true;
               String subject = 'Activated for SAP Report Changed from ' + oldMap.get(obj.id).Activated_for_SAP_Report__c + ' to ' +  updatedMap.get(obj.id).Activated_for_SAP_Report__c;
               taskSubjects.add(subject);
            }
             
            Boolean isvalidOffshoreCountry = true;
            Boolean isOnlyUS = false; 
            if(obj.Vendor_employee_access_data_in_country__c != null){
                if(obj.Vendor_employee_access_data_in_country__c.equalsIgnoreCase('united states')){
                isOnlyUS = true;
              }
              if(!isOnlyUS){ 
                for(String country: obj.Vendor_employee_access_data_in_country__c.split(',')){
                      if(!UTL_TPA.offshoreCountries.contains(country.trim().toLowerCase())){
                          isvalidOffshoreCountry = false;
                          break;
                      }
                  }
              } 
            }
             
            if(updatedMap.get(obj.id).AMA_Manual_Review__c &&
                updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c != oldMap.get(obj.id).AMA_Manual_Trigger_Reasons__c
                    && updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c != null && updatedMap.get(obj.id).AMA_Manual_Trigger_Reasons__c.containsIgnoreCase(requires_offshore) && !isOnlyUS) {//Updated by Rajendra under ER-12122 //Updated by Rajendra under ER-12253
                        if(!SRV_TPA_AMAAgreementDetail.isvalidVendorAccessCountry || !SRV_TPA_AMAAgreementDetail.isvalidVendorStorageCountry  || !SRV_TPA_AMAAgreementDetail.isPreAppTech ){
                            sendOffshoreNotificationToDBL(amaAgrIdWithRcrd.get(obj.id));
            }}
             
            if(!taskSubjects.isEmpty())
                subjectTaskMap.put(Obj.id,taskSubjects);

            if(!SRV_TPA_AMAAgreementDetail.isLetterShopUseExist && (!SRV_TPA_AMAAgreementDetail.isPreAppTech && !SRV_TPA_AMAAgreementDetail.isAccessCountriesMatched) && updatedMap.get(obj.id).Technology_s_selected_for_remote_access__c != null && updatedMap.get(obj.id).Technology_s_selected_for_remote_access__c.indexOf('Other') != -1){
                SRV_TPA_AMAAgreementDetail.sendEmailToVendor(amaAgrIdWithRcrd.get(obj.id));
            }

        }


        if(infoUpdated)
        {
            updateActivityHistoryForAMAAgreementDetail(subjectTaskMap);
        }

    }
     
    public void updateActivityHistoryForAMAAgreementDetail(Map<Id,List<String>> AMAAgreementTaskSubjectMap)
    {
            Task task;
            List<Task> tasksToInsert = new List<Task>();
            for( Id agrId : AMAAgreementTaskSubjectMap.keyset()){

                for(String subject : AMAAgreementTaskSubjectMap.get(agrId))
                {
                    task = new Task();
                    task.WhatId = agrId;
                    task.ActivityDate = system.today();
                    task.Status = 'Completed'; 
                    if(subject.length() > 245)
                    {
                        subject = subject.substring(0, 245)+'...';
                    }
                     
                    task.Subject = subject;
                    task.CallObject = subject;
                    tasksToInsert.add(task);

                }

            }
            if(tasksToInsert.size() > 0 ){
                insert tasksToInsert;
            }

    }
     
    public static void sendOffshoreNotificationToDBL(AMA_Agreement_Detail__c amaAgrObj) {
        List <TPA_Request__c> lstReq = [select id, Pending_Acknowledgements__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where id =: amaAgrObj.TPA_Request__r.id];
        if(lstReq[0].Pending_Acknowledgements__c == null || lstReq[0].Pending_Acknowledgements__c == ''){
            lstReq[0].Pending_Acknowledgements__c =  'AMA Offshore Acknowledgement' ;
        }
        else if(lstReq[0].Pending_Acknowledgements__c.indexOf('AMA Offshore Acknowledgement') == -1){
            lstReq[0].Pending_Acknowledgements__c = lstReq[0].Pending_Acknowledgements__c + ';AMA Offshore Acknowledgement' ;
        }
          
        //Date todayDate;
        //todayDate = Date.today(); 

        List<TPA_AMA_Settings__c> amaSetting =  TPA_AMA_Settings__c.getall().values();              
        String templateId = amaSetting.get(0).Offshore_Link_For_DBL_Template_ID__c;
        
        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();

		
		if(String.isNotBlank(amaAgrObj.Client__c) &&
        String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
        (!amaAgrObj.Client__c.startsWithIgnoreCase('Test') && !amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))){
            toAddress.add(UTL_TPA.dblContractContactEmail);
        }
        
        if(amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c != Null && amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c != '') {
            ccTo = amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c.split(';');
        }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
        
                    
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, lstReq[0]);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                
            }
        } catch(Exception e) {
            System.debug('Offshore Notification sent to DBL failed: ' + e.getMessage());
        } 
    }
     
}
