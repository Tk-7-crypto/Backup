public without sharing class CNT_TPA_DynamicAttachments {
    public string ObjRecId {get; set;}
    public string attDetRecId {get; set;}
    public transient Workflow_Email_Record__c recSendEmail;
    public transient TPA_Agreement_Additional_Field__c tpaReqAdditionalDetail;
    public string clientVendorName {get; set;}
    public string baseOrgUrl {
        get {
            return UTL_TPA.TPA_SITEURL;
        }
    }
    public List<Attachment> attach;
    
    public string getWorkflowRecordDetail() {
        system.debug('recId00:::'+ObjRecId);
        string emailContent = '';
        if(ObjRecId == null) {
            return emailContent;
        }
        if(recSendEmail == null) {
            recSendEmail = [SELECT Id, Email_Action__c, content_1__c, content_2__c, content_3__c, content_4__c From Workflow_Email_Record__c Where id=:ObjRecId LIMIT 1];
            system.debug('wFDebug:::'+recSendEmail.Email_Action__c + '::::' + recSendEmail.content_1__c);
            string content = '<div style="width:100%;background-color:#cccccc;"><center>';
            emailContent = recSendEmail.content_1__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
            if(recSendEmail.content_2__c != null && recSendEmail.content_2__c != '') {
                emailContent += recSendEmail.content_2__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
            }
            if(recSendEmail.content_3__c != null && recSendEmail.content_3__c != '') {
                emailContent += recSendEmail.content_3__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
            }
            if(recSendEmail.content_4__c != null && recSendEmail.content_4__c != '') {
                emailContent += recSendEmail.content_4__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
            }
        }        
        return emailContent;
    }
    
    public TPA_Agreement_Additional_Field__c getTpaReqAdditionalDetail() {
        system.debug('tpaRecId00:::'+attDetRecId);
        if(attDetRecId == null) {
            return null;
        }
        if(tpaReqAdditionalDetail == null) {
            list<TPA_Agreement_Additional_Field__c> tempList = [SELECT Id, 
                                                                       Name, 
                                                                       TPA_Compliance_Hold_Acknowledged__c,
                                                                       Date_of_TPA_Compliance_Response_to_Hold__c,
                                                                       TPA_Compliance_Response_to_Hold__c,
                                                                       TPA_Compliance_Hold_Action_Taken__c, 
                                                                       Related_TPA_Request__c, 
                                                                       Related_TPA_Request__r.Name,
                                                                       Related_TPA_Request__r.Client_Address__c,
                                                                       Related_TPA_Request__r.Client_Address__r.Name,
                                                                       Related_TPA_Request__r.Request_Status__c,
                                                                       Related_TPA_Request__r.Service_Provider_Address__c,
                                                                       Related_TPA_Request__r.Service_Provider_Address__r.Name,
                                                                       Related_TPA_Request__r.Client_Project_Name__c,
                                                                       Related_TPA_Request__r.Data_Access_Start_Date__c,
                                                                       Related_TPA_Request__r.Data_Access_End_Date__c,
                                                                       Related_TPA_Request__r.isClientOnComplianceHold__c,
                                                                       Related_TPA_Request__r.isVendorOnComplianceHold__c
                                                                FROM TPA_Agreement_Additional_Field__c
                                                                WHERE Related_TPA_Request__c =: attDetRecId];
            if(tempList.size() > 0) {
                clientVendorName = '';
                Map<String,Account_Compliance__c> accCompRecords = UTL_TPA.getTPAClientVendorComplianceDetails(tempList[0].Related_TPA_Request__r.Client_Address__c, tempList[0].Related_TPA_Request__r.Service_Provider_Address__c); 
                if(accCompRecords != null) {
                    Account_Compliance__c accClientComp = accCompRecords.get('CC-'+tempList[0].Related_TPA_Request__r.Client_Address__c);
                    Account_Compliance__c accVendorComp = accCompRecords.get('VC-'+tempList[0].Related_TPA_Request__r.Service_Provider_Address__c);
                    if(accClientComp != null && accClientComp.Client_TPA_Compliance_Hold__c){
                        clientVendorName = tempList[0].Related_TPA_Request__r.Client_Address__r.Name;
                    }
                    else if(accVendorComp != null && accVendorComp.Vendor_TPA_Compliance_Hold__c){
                        clientVendorName = tempList[0].Related_TPA_Request__r.Service_Provider_Address__r.Name;
                    }
                }
                tpaReqAdditionalDetail = tempList[0];
            }
        }
        
        return tpaReqAdditionalDetail;
    }
}