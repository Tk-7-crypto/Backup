/**
 * @author:Govind Narayan Sharma
 * @purpose: 
 * 1) Providing link for the Documents(Compliance Program,Restricted Data and Terms and Conditions) in the email that is triggered for Signature Request.
**/
public without sharing class CNT_TPA_RequestDocumentPage {

    public integer partsLength;
    public string subject;
    public string fileId;
    public string documentType;
    public string requestName;
    //public string checkVariable{get;set;}

    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                User currentLoggedInUser = UTL_TPA.getCurrentUserDetails();
                currentUserProfileName = currentLoggedInUser.Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }

    public static string tpaCommunityUrl {
        get {
            if(tpaCommunityUrl == null && UTL_TPA.tpaSetting != null && !String.isEmpty(UTL_TPA.tpaSetting.TPA_Client_Community_Url__c)) {
                tpaCommunityUrl = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c;
            }
            return tpaCommunityUrl;
        }
        set;
    }
    
    public PageReference getDocument() {
        system.debug('pRef.getContent()-1');
        if(currentUserProfileName == 'tpa Profile' || currentUserProfileName == 'IQVIA TPA Portal Profile' ) {
            system.debug('In check profile:::' + currentUserProfileName);
            return null;
        }
        PageReference pagRef = null;
        subject = ApexPages.currentPage().getParameters().get('EmailTitle');
        if(fileId == null) {
            fileId = ApexPages.currentPage().getParameters().get('file');
        }
        system.debug('pRef.getContent()-2'+subject);
        if(subject != null)
        {system.debug('pRef.getContent()-3');
            List<String> docType =subject.split(':');
            if(docType.size() > 0)
            {
                documentType = docType[0].trim();//Added by Babita Dadarwal under ER-1940
            }
            List<String> parts = subject.split(',');
            List<String> lstByColon = new List<String>();
            if(parts.size() > 0)
            {
                 lstByColon = parts[0].split(':');
                partsLength = lstByColon.size()- 1;
            }
            requestName = lstByColon[partsLength].trim();//Added by Babita Dadarwal under ER-1940
            List<TPA_Request__c> lstTPARequest = new List<TPA_Request__c>();
            lstTPARequest = [select id,name, Offering_Notification_Document_Id__c from TPA_Request__c where name =:requestName];// Updated by Babita Dadarwal under ER-2106
            if(lstTPARequest.size() > 0)
            {
                //Updated by Babita Dadarwal under ER-2106 Start
                if(documentType == 'OND')



                {
                    //if(lstTPARequest[0].agreements__r.size() > 0 )
                    //{
                         //Updated by Babita Dadarwal under Issue-08140 start
                        if(lstTPARequest[0].Offering_Notification_Document_Id__c == null || lstTPARequest[0].Offering_Notification_Document_Id__c == '') {
                            return new PageReference('/VFP_TPA_Page_Status?type=noOfferingNotificationRequired');
                        }
                        else {
                            pagRef = new PageReference('/servlet/servlet.FileDownload?file='+lstTPARequest[0].Offering_Notification_Document_Id__c);
                        }
                        //Updated by Babita Dadarwal under Issue-08140 End
                   // }
                    
                }
                else {
                    List<TPA_RequestDocument__c> lstRequestDocument = new List<TPA_RequestDocument__c>();
                    lstRequestDocument = [select id,Document_Id__c from TPA_RequestDocument__c where TPA_Request_Id__c =:lstTPARequest[0].id and Document_Type__c =: documentType];
                    if(lstRequestDocument.size() > 0)
                    {
                        pagRef = new PageReference('/servlet/servlet.FileDownload?file='+lstRequestDocument[0].Document_Id__c);
                    }
               }
               //Updated by Babita Dadarwal under ER-2106 End
            }   
        }
        else if(fileId != null && fileId != '') {system.debug('pRef.getContent()-4');
            system.debug('pRef.getContent()0');
            pagRef = new PageReference('/servlet/servlet.FileDownload?file=' + fileId);
        }
        return pagRef;
    }
}