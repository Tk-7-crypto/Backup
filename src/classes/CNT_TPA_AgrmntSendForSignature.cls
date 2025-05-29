global class CNT_TPA_AgrmntSendForSignature { 
    private final ApexPages.StandardController controller;
    public TPA_Request__c tpaRequest {get; set;}
    
    private PageReference pageRef;
    private String retURL;
    private String tpaRequestId;
    private boolean updateAttachmentFlag = false;
    public List<Attachment> listAttachments {get; set;}	
    public List<RecipientWrapper> listRecipientWrapper {get; set;}
    public string usecase {get; set;}
    
    public boolean hasDocuments {
        get {
            if(hasDocuments == null) {
                hasDocuments = false;
            }
            return hasDocuments;
        } 
        set;
    }	
    	
    public boolean hasRecipients {	
        get {	
            if(hasRecipients == null) {	
                hasRecipients = false;	
            }	
            return hasRecipients;	
        } 	
        set;	
    }
                
    public static final String WARNING_MESSAGE = 'You cannot edit TPA Request record.'; 
    
    private boolean manualReview = true;
    private String vendorLanguage = 'English'; 
    private String vendorLanguageFieldName = ''; 
    public Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap;
        
   public CNT_TPA_AgrmntSendForSignature() {
        this.tpaRequestId = ApexPages.currentpage().getparameters().get('Id');
        system.debug('In CNT_TPA_AgrmntSendForSignature: tpaRequestId: ' + this.tpaRequestId);  
        //this.controller = paramController;
        this.retURL = ApexPages.currentPage().getParameters().get('retURL');
        this.tpaRequest = [Select id,
                                  Service_Provider_Name__c,
                                  Requires_Manual_Review__c,
                                  Vendor_Language__c,
                                  ClientContact__r.Email,
                                  ClientContact__r.FirstName,
                                  ClientContact__r.lastName,
                                  Vendor_Contact_e_mail__c,
                                  Vendor_Contact_Name_f__c,
                                  Vendor_First_Name__c, 
                                  Vendor_Contact_Last_Name__c,
                                  Client_Address__r.Name,
                                  Name,
                                  Service_Provider_Address__c, 
                                  Service_Provider_Address__r.Name,
                                  Data_Access_End_Date__c,
                                  Data_Access_Start_Date__c,
                                  TP_Processor_Email__c,
                                  TP_Processor_Name__c,
                                  TPA_Authorised_Signer__c,
                                  Authorized_Signer_Email__c,
                                  Authorized_Signer_Name__c,
                                  After_in_Effect_Changes__c,
                                  Request_Status__c,
                                  (select id,Is_Foreign_License_Required__c,AMA_Foreign_Storage_Contract_Type__c,Is_AMA_License_Required__c,ExUS_Entity_Authorized_Signer_Name__c,
                                  Ex_US_Entity_Authorized_Signer_Title__c,Ex_US_Entity_Authorized_Signer_Email__c from AMA_Agreement_Details__r),
                                  (select id, name, lastModifiedby.name, lastmodifieddate from Attachments order by createddate desc)
                           from TPA_Request__c 
                           where id =: this.tpaRequestId]; 
        
        if(this.tpaRequest.Attachments != null && this.tpaRequest.Attachments.size() > 0) {
            hasDocuments = true;
            listAttachments = this.tpaRequest.Attachments;
            Attachment objAttachTLLA = null;
            Attachment objAttachAMA = null;
            Attachment objAttachTechLicense = null;
            Attachment objAttachTechAmendment = null;
            Attachment objAttachAMAFL = null;
            Attachment objAttachAddendum = null;
            Attachment objAttachHelpfulHint = null;
            string mandatoryIds = ApexPages.currentpage().getparameters().get('mandatoryDocsId');
            for(integer i = 0; i < listAttachments.size(); i++) {
                if(mandatoryIds != null) {
                    for(String strArg: mandatoryIds.split(':')) {
                        if(strArg.indexOf(listAttachments[i].Id) != -1) {
                            if(objAttachTLLA == null && strArg.indexOf('TLLA') != -1) {
                                objAttachTLLA = listAttachments.remove(i);
                                i--;
                                break;
                            }
                            else if(objAttachAMA == null && strArg.indexOf('AMA') != -1 && strArg.indexOf('FL') == -1) {
                                objAttachAMA = listAttachments[i];
                                listAttachments.remove(i);
                                i--;
                                break;
                            }
                            else if(objAttachTechLicense == null && strArg.indexOf('TechLi') != -1) {
                                objAttachTechLicense = listAttachments[i];
                                listAttachments.remove(i);
                                i--;
                                break;
                            }
                            else if(objAttachTechAmendment == null && strArg.indexOf('TechAm') != -1) {
                                objAttachTechAmendment = listAttachments[i];
                                listAttachments.remove(i);
                                i--;
                                break;
                            }
                            else if(objAttachAMAFL == null && strArg.indexOf('AMAFL') != -1) {
                                objAttachAMAFL = listAttachments[i];
                                listAttachments.remove(i);
                                i--;
                                break;
                            }
                            else if(objAttachAddendum == null && strArg.indexOf('Addendum') != -1 && strArg.indexOf(UTL_TPA.helpfulHintsDocLabel) == -1) {
                                objAttachAddendum = listAttachments[i];
                                listAttachments.remove(i);
                                i--;
                                break;
                            }
                            else if(objAttachHelpfulHint == null && strArg.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1) {
                                objAttachHelpfulHint = listAttachments[i];
                                listAttachments.remove(i);
                                i--;
                                break;
                            }
                        }
                    }
                }
            }
            if(listAttachments.size() == 0){
                if(objAttachTLLA != null) {
                    listAttachments.add(objAttachTLLA);
                }
                if(objAttachHelpfulHint != null) {
                    listAttachments.add(objAttachHelpfulHint);
                }
                if(objAttachAddendum != null) {
                    listAttachments.add(objAttachAddendum);
                }
                if(objAttachAMA != null) {
                    listAttachments.add(objAttachAMA);
                }
                if(objAttachAMAFL != null) {
                    listAttachments.add(objAttachAMAFL);
                }
            }else{
                if(objAttachAMA != null) {
                    listAttachments.add(0, objAttachAMA);
                }
                if(objAttachAMAFL != null) {
                    listAttachments.add(0, objAttachAMAFL);
                }
                if(objAttachAddendum != null) {
                    listAttachments.add(0, objAttachAddendum);
                }
                if(objAttachHelpfulHint != null) {
                    listAttachments.add(0, objAttachHelpfulHint);
                }
                if(objAttachTLLA != null) {
                    listAttachments.add(0, objAttachTLLA);
                }
            }
            if(this.tpaRequest.After_in_Effect_Changes__c && this.tpaRequest.Request_Status__c == 'In Effect'){
                listAttachments = new List<Attachment>();
                if(objAttachAMA != null) {
                    listAttachments.add(objAttachAMA);
                }
                if(objAttachTechLicense != null) {
                    listAttachments.add(objAttachTechLicense);
                }
                if(objAttachTechAmendment != null) {
                    listAttachments.add(objAttachTechAmendment);
                }
            }
        }
        vendorLanguage = this.tpaRequest.Vendor_Language__c != null ? this.tpaRequest.Vendor_Language__c : 'English';
        
        vendorLanguageFieldName = UTL_TPA_Multilingual.supportedLanguageFieldMap.get(vendorLanguage);
        multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{vendorLanguageFieldName});         
        manualReview = this.tpaRequest.Requires_Manual_Review__c ;                      
        usecase = 'SEND FOR SIGNATURE';
        system.debug('In CNT_TPA_AgrmntSendForSignature: vendorLanguageFieldName: ' + vendorLanguageFieldName); 
        system.debug('In CNT_TPA_AgrmntSendForSignature: multilanguageUtilityMap: ' + multilanguageUtilityMap); 
        system.debug('In CNT_TPA_AgrmntSendForSignature: manualReview: ' + manualReview); 	
        	
        if(this.tpaRequestId != null) {	
            SRV_TPA_DocusignEnvelope objSrvDocSignEnv = new SRV_TPA_DocusignEnvelope(this.tpaRequestId);	
            objSrvDocSignEnv.setRecipientList();	
            if(objSrvDocSignEnv.CRL != '') {	
                listRecipientWrapper = new List<RecipientWrapper>();	
                List<String> lstRecepientDetails;	
                Integer carbonCopyCounter = 1;	
                RecipientWrapper objRecWrapp;	
                for(String objRecipient: objSrvDocSignEnv.CRL.split(',')) {	
                    lstRecepientDetails = objRecipient.split(';');	
                    if(lstRecepientDetails != null && lstRecepientDetails.size() == 5) {	
                        objRecWrapp = new RecipientWrapper();
                        system.debug('lstRecepientDetails::'+lstRecepientDetails);
                        if(lstRecepientDetails[2].split('~').size() == 2) {
                        	objRecWrapp.recipientName = lstRecepientDetails[2].split('~')[1];
                        }
                        if(lstRecepientDetails[0].split('~').size() == 2) {
                        	objRecWrapp.recipientEmail = lstRecepientDetails[0].split('~')[1];
                        }
                        String role = lstRecepientDetails[3].split('~')[1];	
                        if(role == 'A' || role == 'B'|| role == 'C') {	
                            objRecWrapp.recipientAction = 'Signer';	
                            objRecWrapp.recipientRole = role == 'A' ? 'Signer 1' : role == 'B' ? 'Signer 2' : 'Signer 3';	
                        }	
                        else {	
                            objRecWrapp.recipientAction = 'Carbon Copy';	
                            objRecWrapp.recipientRole = 'Carbon Copy ' + carbonCopyCounter;	
                            carbonCopyCounter++;	
                        }	
                        listRecipientWrapper.Add(objRecWrapp);	
                        hasRecipients = true;	
                    }	
                }	
            }	
        }
    }
    
    @remoteAction
    global static string submitDocusign(string requestId, string documentIds) {
        QBL_TPA_AsyncSendDoc asyncSendDocCall= new QBL_TPA_AsyncSendDoc();
        asyncSendDocCall.requestId = requestId;
        asyncSendDocCall.documentIds = documentIds;
        System.enqueueJob(asyncSendDocCall); 
        return 'DocuSign call has submitted';
    }

    public PageReference redirectToDocusignCreateEnvelopePage() {  
        this.setPageRefToDocusignCreateEnvelopePage();                           
        return this.pageRef;    
    }
    
    private void setPageRefToDocusignCreateEnvelopePage() {  
        QBL_TPA_AsyncSendDoc asyncSendDocCall= new QBL_TPA_AsyncSendDoc();
        asyncSendDocCall.requestId = tpaRequest.id;
        system.debug('tpaRequest.id: ' + tpaRequest.id);
        System.enqueueJob(asyncSendDocCall); 
        this.pageRef = new PageReference('/apex/VFP_TPA_Page_Status');
        this.pageRef.getParameters().put('type','requestSentForSign'); 
        this.pageRef.getParameters().put('retURL',retURL); 
        this.pageRef.setRedirect(true);                     
    }	
    	
    public class RecipientWrapper {
        Public String recipientName {get; set;}	
        Public String recipientEmail {get; set;}	
        Public String recipientAction {get; set;}	
        Public String recipientRole {get; set;}	
    }
}
