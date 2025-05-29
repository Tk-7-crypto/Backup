/*
author: Supriya Johari
Date: 11 August 2016
Purpose: To upload connection diagram which can be image, pdf or Doc while submitting the questionnaire by vendor if vendor requires offshore approval.
RelatedTo: ER-2906 under CR-09237
*/

global class CNT_TPA_AMA_OffshoreUploadAttachment {    
    
    // transient static public Blob fileBody{get;set;}
    // public String fileName {get; set;}
    // public Boolean success {get; set;}
    // public String amaAgreementID{get; set;}
    // public AMA_Agreement_Detail__c amaAgreementDetailObj {
    //     get{
    //         if(amaAgreementDetailObj == null){
    //             if(!Test.isRunningTest())
    //             {
    //                 amaAgreementID = ApexPages.currentPage().getParameters().get('id');
    //             }
    //             if(amaAgreementID != null)
    //             {
    //                 List<AMA_Agreement_Detail__c> amaAgreementDetailValues = [Select id,Name, TPA_Request__r.Employee_Accessing_Data_Location__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
    //                                             TPA_Request__c, TPA_Request__r.Name, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c, Client_Company_Name__c,
    //                                             Status_of_Offshore_Questionnaire__c, Where_will_the_data_reside__c, pharmaceutical_client_accessed_overseas__c, service_provider_accessed_overseas__c, With_the_overseas_entity__c, Tell_us_about_the_project__c, Volume_of_records__c,              
    //                                             Specific_variables_requested__c, offshore_entity_interacting_with_data__c, How_will_the_data_be_accessed__c, HTTPS_VPN_Other__c, app_software_used_at_offshore__c, Data_security_procedures_used__c , Encryption__c,Can_data_be_downloaded_or_printed__c, Firewall_port_filtering_technologies__c,
    //                                             Other__c, physical_security_procedures__c, Portable_storage_devices_allowed__c, Employees_have_wireless_connectivity__c, Is_area_secure__c, Number_of_computers_used__c, Additional_technologies_used__c
    //                                             FROM AMA_Agreement_Detail__c Where id = :amaAgreementID limit 1];
    //                 if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty())
    //                     amaAgreementDetailObj = amaAgreementDetailValues.get(0);
    //             }
    //         }
    //         return amaAgreementDetailObj;
    //     }
    //     set;
    // }
    
    
    public CNT_TPA_AMA_OffshoreUploadAttachment() {
    }
   
    // public void AttachDocument()
    // {
    //     try
    //     {
    //         //delete previous connection diagram attachments
    //         List<Attachment> attachmentList = [SELECT Id, Name, Body, ContentType  FROM Attachment WHERE Parentid =:amaAgreementDetailObj.id and Name LIKE '%Connection Diagram%'];
    //         delete attachmentList;
            
    //         String ext = '';
    //         if (Test.IsRunningTest())
    //         {
    //             fileBody = Blob.valueOf('UNIT.TEST');
    //         }
    //         Attachment attach = new Attachment();
    //         attach.Body = fileBody;
    //         if(String.isNotBlank(fileName) && String.isNotBlank(fileName.substring(fileName.lastIndexOf('.') + 1)))
    //         {
    //            ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    //         }  
    //         attach.Name = 'Temp Connection Diagram'+'.'+ext;
    //         attach.IsPrivate = false;
    //         attach.ParentId = amaAgreementDetailObj.id;
    //         insert attach;
    //         success = true;
    //     }
    //     catch(Exception ex)
    //     {
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMA_OffshoreUploadAttachment:::AttachDocument', ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         system.debug(ex.getMessage());
    //     }
    // }
    
    
}