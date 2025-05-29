public class SRV_TPA_DocusignEnvelope {

    private String tpaRequestId;
    public TPA_Request__c tpaRequest;
    public boolean manualReview = true;
    public String vendorLanguage = 'English';
    private String vendorLanguageFieldName = '';
    public Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap;
    private EnvelopeDetail envDet;
    public static string documentId = '';
    private static Boolean isDoubleSignerExist = false; 
    private static Boolean isAdditionalSignerExist = false; 
    
    public string RES = '1,7,7,1,99,1';
    public String CRL = ''; //Recipient List
    public String CEM = ''; //Email Message 
    public String CES = ''; //Email Subject
    public String CCRM = ''; //Email Message
    public String CCTM = ''; //Email Subject
    public String OCO = ''; //Send Auto/manual  
   
    
    public SRV_TPA_DocusignEnvelope(String id) {
        this.tpaRequestId = id;
        this.tpaRequest = [Select Id,
                           Name,
                           Service_Provider_Name__c,
                           ServiceProviderContact__c,
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
                           ServiceProviderContact__r.email,
                           ServiceProviderContact__r.FirstName,
                           ServiceProviderContact__r.LastName,
                           ServiceProviderContact__r.Name,
                           Service_Provider_Address__c, 
                           Service_Provider_Address__r.Name,
                           Data_Access_End_Date__c,
                           Data_Access_Start_Date__c,
                           TP_Processor_Email__c,
                           TP_Processor_Name__c,
                           TPA_Authorised_Signer__c,
                           Authorized_Signer_Email__c,
                           Authorized_Signer_Name__c
                           ,(select id,
                           Is_Offshore_Access_Amendment_to_FL_Req__c,
                           Is_Foreign_License_Required__c,
                           Is_AMA_License_Required__c,
                           AMA_Foreign_Storage_Contract_Type__c,
                           Vendor_req_Storage_Permission_from_NonUS__c,
                           ExUS_Entity_Authorized_Signer_Name__c,
                            Ex_US_Entity_Authorized_Signer_Title__c,
                            Ex_US_Entity_Authorized_Signer_Email__c 
                            from AMA_Agreement_Details__r),
                            (SELECT Id, 
                            Name,
                            Additional_Signer_Name__c,
                            Additional_Signer_Email__c 
                            FROM TPA_Agreement_Additional_Fields__r)
                           from TPA_Request__c 
                           where id =: this.tpaRequestId];
        
        manualReview = this.tpaRequest.Requires_Manual_Review__c;                 
        vendorLanguage = this.tpaRequest.Vendor_Language__c != null ? this.tpaRequest.Vendor_Language__c : 'English';
        vendorLanguageFieldName = UTL_TPA_Multilingual.supportedLanguageFieldMap.get(vendorLanguage);
        multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{vendorLanguageFieldName});         
        
        Date startDateVal = this.tpaRequest.Data_Access_Start_Date__c ;
        Date endDateVal = this.tpaRequest.Data_Access_End_Date__c;
        Integer numberDays = startDateVal.daysBetween(endDateVal);
        numberDays += 1;
        RES = '1,7,7,1,'+ numberDays +',1';
    }
    
    @future(callout=true)
    public static void createAndSendEnvelopeForAgreement(String tpaRequestId, string documentIds) {
        string status = '';
        documentId = documentIds;
        try {
            SRV_TPA_DocusignEnvelope srvDocusignEnveObj = new SRV_TPA_DocusignEnvelope(tpaRequestId);
            //if(!srvDocusignEnveObj.manualReview) {
                EnvelopeDetail envDet =  srvDocusignEnveObj.setParametersForDocusignCreateEnvelopePage();
                CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
                status  = SRV_TPA_DocusignEnvelope.createAndSendEnvelope(envDet, srvDocusignEnveObj.vendorLanguage);    
            //}
            SRV_TPA_TPARequest.updateActivityHistory(tpaRequestId, 'Sent For Signature', true);
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, 
            FALSE, 
            UTL_LogFactory.GUID, 
            'Exception: Failed to Create and send Envelope  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
            'TPA', 
            'Exception', 
            'ERROR', 
            'Line#' + ex.getLineNumber()+':::StackTrace'+ ex.getStackTraceString() + ':::SRV_TPA_DocusignEnvelope:::createAndSendEnvelopeForAgreement' +':::'+status, 
            (tpaRequestId != null) ? tpaRequestId : null));
        }      
    }
    
    //set Parameters For DocusignCreateEnvelope
    public EnvelopeDetail setParametersForDocusignCreateEnvelopePage() {                  
        this.setCustomEmailSubject();
        this.setCustomEmailMessage();
        this.setRecipientList();              
        this.setEnvelopeParametersForEnvelope();                
        return envDet;
    }
    
    private void setCustomEmailSubject() {
        string serviceProvider = '';              
        string client= '';
        string tpaRequestName = '';
        
        if (tpaRequest.Service_Provider_Name__c != null) {
            if(tpaRequest.Service_Provider_Name__c.length() > 15) {
                serviceProvider = tpaRequest.Service_Provider_Name__c.substring(0,14); 
            }
            else {
                serviceProvider = tpaRequest.Service_Provider_Name__c;
            }
        } 
        
        if (tpaRequest.Client_Address__r != null && tpaRequest.Client_Address__r.Name != null ) {
            if(tpaRequest.Client_Address__r.Name.length() > 10) {
                client = tpaRequest.Client_Address__r.Name.substring(0,10); 
            }
            else {
                client = tpaRequest.Client_Address__r.Name;
            }                
        } 
        
        if (tpaRequest.Name != null) {                                   
            tpaRequestName = tpaRequest.Name;
        } 
        
        if(multilanguageUtilityMap != null) {
            String sub = (String)multilanguageUtilityMap.get(vendorLanguageFieldName + '~TPA_Request__c~Record~IQVIA TPA Program: TPA_Number, Signature Request for Client_Name')[0].get(vendorLanguageFieldName);
            CES = sub.replace('TPA_Number', tpaRequestName).replace('Client_Name', client);
        }
        else {
            CES = label.TPA_IQVIA_Keyword+' TPA Program: ' + tpaRequestName + ', Signature Request for ' + client + ' TLLA';
        }
    }
    
    private void setCustomEmailMessage() {
        string client= '';
        String vendor = '';
        
        if(tpaRequest.Client_Address__r != null && tpaRequest.Client_Address__r.Name != null) {
            client = tpaRequest.Client_Address__r.Name;                
        } 
        
        if (tpaRequest.Service_Provider_Address__c != null && tpaRequest.Service_Provider_Address__r.Name != null) {
            vendor = tpaRequest.Service_Provider_Address__r.Name;
        }
        
        String message = '';
        
        if(multilanguageUtilityMap != null) {
            message = (String)multilanguageUtilityMap.get(vendorLanguageFieldName + '~TPA_Request__c~Record~Ducusign Dynamic Message')[0].get(vendorLanguageFieldName);
            message = message.replace('Vendor_Name', vendor);
        }
        else {
            message = 'By signing the Contract Document(s), you represent and warrant that you are duly authorized by '
                + vendor
                + ' and '
                + 'have legal capacity to execute and deliver the Contract Document(s). '
                + 'You represent and warrant to '
                + Label.TPA_IQVIA_Keyword
                + ' that the execution and delivery of the Contract Document(s) '
                + 'and the performance of '
                + vendor
                + '\'s obligations here under have been duly authorized and that the Contract Document(s) are valid and '
                + 'legal agreements binding on the '
                + vendor
                + ' and enforceable in accordance with its terms.';
            
            message =  message 
                + '\r\n'
                + 'To view the documents, recipients, and other information, please click "View" below';
            
            message =  message 
                + '\r\n'
                + ' As an authorized signing authority for '
                + vendor
                + ', it is your responsibility to read and validate the terms, '
                + 'conditions and any applicable fees within the attached agreements prior to signing.';
        }
        CEM = message;
    }
    
    public void setRecipientList() {
        if(!manualReview) {
            OCO = 'Send';
        }
        
        //Custom Contact Role Map
        CCRM ='A~Signer 1;B~Signer 2;C~Signer 3;D~Carbon Copy;E~Carbon Copy1;F~Carbon Copy2;G~Carbon Copy3;H~Carbon Copy4;I~Carbon Copy5;J~Carbon Copy6;K~Carbon Copy7;';  
        
        //Custom Contact Type Map
        CCTM ='A~Signer;B~Signer;C~Signer;D~Carbon Copy;E~Carbon Copy;F~Carbon Copy;G~Carbon Copy;H~Carbon Copy;I~Carbon Copy;J~Carbon Copy;K~Carbon Copy;';  
        
        string serviceProviderName ='';
        string serviceProviderEmail ='';
        string note = 'IMS Note';

        AMA_Agreement_Detail__c aMAObj;
        TPA_Agreement_Additional_Field__c agrAdditionalObj;
        if(tpaRequest.AMA_Agreement_Details__r != null && tpaRequest.AMA_Agreement_Details__r.size() > 0 ) {
            amaObj = tpaRequest.AMA_Agreement_Details__r[0];
        }
        if(tpaRequest.TPA_Agreement_Additional_Fields__r != null && tpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0 ) {
            agrAdditionalObj = tpaRequest.TPA_Agreement_Additional_Fields__r[0];
        }

        if(tpaRequest.TPA_Authorised_Signer__c == 'Yes') {
            serviceProviderName = (tpaRequest.Vendor_First_Name__c + ' ' + tpaRequest.Vendor_Contact_Last_Name__c).trim(); 
            
            if(tpaRequest.Vendor_Contact_e_mail__c != null) {
                serviceProviderEmail = tpaRequest.Vendor_Contact_e_mail__c;      
            }
        }
        else {
            if (tpaRequest.Authorized_Signer_Name__c!= null) {
                serviceProviderName = tpaRequest.Authorized_Signer_Name__c; 
            } 
            if (tpaRequest.Authorized_Signer_Email__c != null) {
                serviceProviderEmail = tpaRequest.Authorized_Signer_Email__c;                 
            }            
        }
        string regex = '[,;~\\\\/]';
        serviceProviderName = serviceProviderName.replaceAll(regex,'');

        CRL = 'Email~'+serviceProviderEmail +';FirstName~'+''+';LastName~'+serviceProviderName +';Role~A;RoutingOrder~1;';  
        if(amaObj != null && amaObj.Is_Foreign_License_Required__c && amaObj.AMA_Foreign_Storage_Contract_Type__c != null ){
            string exUsAuthSignerName = amaObj.ExUS_Entity_Authorized_Signer_Name__c;
            exUsAuthSignerName = exUsAuthSignerName.replaceAll(regex,'');
            CRL = CRL + ',Email~'+amaObj.Ex_US_Entity_Authorized_Signer_Email__c +';FirstName~'+''+';LastName~'+exUsAuthSignerName +';Role~B;RoutingOrder~1;' ;
            isDoubleSignerExist = true; 
        }

        if(agrAdditionalObj != null && agrAdditionalObj.Additional_Signer_Name__c != null && agrAdditionalObj.Additional_Signer_Email__c != null ){
            string additionalSignerName = agrAdditionalObj.Additional_Signer_Name__c;
            additionalSignerName = additionalSignerName.replaceAll(regex,'');
            String role = isDoubleSignerExist == false ? 'Role~B' : 'Role~C';
            CRL = CRL + ',Email~'+agrAdditionalObj.Additional_Signer_Email__c +';FirstName~'+''+';LastName~'+additionalSignerName +';'+ role +';RoutingOrder~1;' ;
            isAdditionalSignerExist = true; 
        }


        system.debug('isDoubleSignerExist' + isDoubleSignerExist);

        system.debug('CRL:'+ CRL);
        CRL = CRL + setCarbonCopyList();          
    }
    
    private string setCarbonCopyList() {
        String vendorName;
        String processorName = 'Identified User';
        String carbonCopy = '';
        String name = '';
        Integer iCount = 0;
        List<String> roleList = new List<String> {'D','E','F','G','H','I','J','K'}; 
        string regex = '[,;~\\\\/]';

            List<TPA_Contact__c> tpaContactsList = SRV_TPA_TPARequest.getContactsForRequest(this.tpaRequest.Id);
        if(tpaContactsList!= null && tpaContactsList.size() > 0) {
            for(TPA_Contact__c tpaContact : tpaContactsList) {
                if(tpaContact.Type__c == 'Additional Vendor Contact') {                    
                    tpaContact.Name = tpaContact.Name.replaceAll(regex,'');
                    carbonCopy = carbonCopy  + ',Email~'+tpaContact.Email__c+';FirstName~'+''+';LastName~'+tpaContact.Name+';Role~'+roleList[iCount]+';RoutingOrder~1;' ;
                    iCount++;
                }
            }
        }
        
        carbonCopy =  carbonCopy  
            + ',Email~' 
            + UTL_TPA.sharedEmailAddress 
            + ';FirstName~Shared;LastName~Mail Box;Role~'
            + roleList[iCount]
            + ';RoutingOrder~1;';
        iCount++;
        
        if( tpaRequest.TPA_Authorised_Signer__c == 'No' 
           && tpaRequest.Vendor_Contact_e_mail__c != tpaRequest.Authorized_Signer_Email__c) {
               vendorName = (tpaRequest.Vendor_First_Name__c + ' ' + tpaRequest.Vendor_Contact_Last_Name__c).trim();
               vendorName = vendorName.replaceAll(regex,'');
               carbonCopy = carbonCopy  + ',Email~'+tpaRequest.Vendor_Contact_e_mail__c+';FirstName~'+''+';LastName~'+vendorName+';Role~'+roleList[iCount]+';RoutingOrder~1;' ;
               iCount++;
           }
        
        if(tpaRequest.TP_Processor_Name__c != null && tpaRequest.TP_Processor_Name__c != '') {
            processorName = tpaRequest.TP_Processor_Name__c;
        }
        if( tpaRequest.TP_Processor_Email__c != null 
           && tpaRequest.TP_Processor_Email__c != '' 
           && tpaRequest.TP_Processor_Email__c != tpaRequest.Vendor_Contact_e_mail__c 
           && tpaRequest.TP_Processor_Email__c != tpaRequest.Authorized_Signer_Email__c) {
            processorName = processorName.replaceAll(regex,'');   
            carbonCopy = carbonCopy  + ',Email~'+tpaRequest.TP_Processor_Email__c+';FirstName~'+''+';LastName~'+processorName+';Role~'+roleList[iCount]+';RoutingOrder~1;' ;  
               iCount++;
           }
        
        /*String DocuSignCCMailList = UTL_TPA.docusignCCEmailList;
        
        String userName = '';
        String usermailId = ''; 
        
        if(DocuSignCCMailList !=NULL && DocuSignCCMailList.trim() != '') {
            List<String> address = DocuSignCCMailList.split(',', 0);
            for(String userInfo : address) {
                List<String> CCuserDetail = userInfo.split(':');
                if(CCuserDetail != null && CCuserDetail.size() >= 2 ) {
                    usermailId = CCuserDetail[0];
                    userName = CCuserDetail[1];
                    if( usermailId != '' 
                       && userName != '' 
                       && carbonCopy.indexOf(usermailId) == -1 
                       && iCount <= roleList.size()) {
                        userName = userName.replaceAll(regex,''); 
                           carbonCopy = carbonCopy  + ',Email~'+usermailId+';FirstName~'+''+';LastName~'+userName+';Role~'+roleList[iCount]+';RoutingOrder~1;' ;  
                       }
                }                
            }
        }*/
        
        return carbonCopy;        
    }
    
    private void setEnvelopeParametersForEnvelope() {               
        envDet = new EnvelopeDetail();
        envDet.CRL = CRL; //Recipient List
        envDet.CEM = CEM ; //Email Message
        envDet.CES = CES ; //Email Subject
        envDet.CCRM = CCRM; //Recipient Role
        envDet.CCTM = CCTM; //Recipient Type
        envDet.OCO = OCO; //Send Auto/manual 
        envDet.RES = RES; //Reminder and expiration settings
        envDet.SourceId = this.tpaRequestId;
        system.debug('envDet.SourceId: ' + envDet.SourceId);
    }
    
    public static String createAndSendEnvelope(EnvelopeDetail envDet, String vendorLanguage) {
        String contentTypeWithBody = '';
        Integer contentLength = 0;
        String accKey = UTL_TPA.docusignAccountId;
        String contractName = 'test.pdf';
        String contentType = '';
        String bcontent = '';
        String ctrId = '';
        String passString = '';
        String cheader = '';
        String envelop = ''; 
        String envEOF = '\r\n'+'--myBoundary--';
        String sourceId = envDet.SourceId;
        system.debug('sourceId: ' + sourceId);
        
        
        AMA_Agreement_Detail__c amaAgreement;
        List<AMA_Agreement_Detail__c> amaAgreementsList = [Select id, 
                                                           AMA_Manual_Review__c, 
                                                           Is_AMA_License_Required__c,
                                                           Is_Offshore_Access_Amendment_Required__c
                                                           From AMA_Agreement_Detail__c 
                                                           Where TPA_Request__c = :sourceId];
        if(amaAgreementsList.size() > 0) {
            amaAgreement = amaAgreementsList[0];
            System.debug('**amaAgreement**'+amaAgreement);
        }
        
        //Get Attachment from TPA Request        
        List<Attachment> attList = new List<Attachment>();
        List<Attachment> att = new List<Attachment>();
            
        String SERVICE_BUREAU_II = 'Service Bureau II'; 
        String CONTRACT_SALESFORCE = 'Contract Sales Force'; 
        Boolean isOffNotAttached = false;
        Boolean isTLLAAttached = false;
        Boolean isAddendumAttached = false;
        Boolean isHelpfulHintAttached = false;
        Boolean isAMAAttached = false; 
        Boolean isTechLicAttached = false;
        Boolean isTechAmendAttached = false;
        Boolean isSB2orCsfAttached = false; 
        Boolean isAMAAttachment = false; 
        Attachment tllaDoc;
        Attachment helpfulHintDoc;
            
        if(documentId != null && documentId.length() > 0) {
            List<String> lstDocumentId = documentId.split(':');
            attList = [select id, Name, body from attachment 
                                        where Id in : lstDocumentId 
                                        order by createddate desc];
            for(Attachment attRec: attList) {
                if(!isTLLAAttached && attRec.Name.indexOf('TLLA') != -1 && attRec.Name.indexOf('IQVIA Third Party Tech') == -1) {
                    tllaDoc = attRec;
                    isTLLAAttached = true;
                }
                else if(!isHelpfulHintAttached && attRec.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1) {
                    helpfulHintDoc = attRec;
                    isHelpfulHintAttached = true;
                }
                else {
                    att.Add(attRec);
                }
            }
            //system.debug('0000:::'+att.size());
            if(isHelpfulHintAttached) {
                if(att.size() == 0) {
                    att.Add(helpfulHintDoc);
                }
                else {
                    att.Add(0, helpfulHintDoc);
                }
            }
            if(isTLLAAttached) {
                if(att.size() == 0) {
                    att.Add(tllaDoc);
                }
                else {
                    att.Add(0, tllaDoc);
                }
            }            
            //system.debug('0011:::'+att.size());
            //att = attList;
        }
        else {
            attList = [select id, Name, body 
                                        from attachment 
                                        where parentId =: sourceId 
                                        and (name like '%TLLA%' 
                                             or name like '%Offerings Notification%'
                                             or name like '%Addendum Notification%' 
                                             or name like '%TPA Helpful Hints Addendum%'
                                             or name like '%AMA_%') 
                                        order by createddate desc];
            
            for(Attachment a : attList) {
                isAMAAttachment = a.Name.indexOf('AMA_') == 0 && a.Name.indexOf('TPA-') != -1; 
                System.debug('##isAMAAttachment##'+isAMAAttachment);
                if(isOffNotAttached && a.Name.indexOf('Offerings Notification Vendor') != -1) {
                    continue;
                }
                if(isTLLAAttached && a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('IQVIA Third Party Tech') == -1) {
                    continue;
                }
                if(isTechLicAttached && a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('IQVIA Third Party Tech License Agreement') != -1) {
                    continue;
                }
                if(isTechAmendAttached && a.Name.indexOf('TLLA') != -1  && a.Name.indexOf('IQVIA Third Party Tech Amendment') != -1) {
                    continue;
                }
                if(isHelpfulHintAttached && a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1) {
                    continue;
                }
                if(isAddendumAttached && a.Name.indexOf('Addendum Notification') != -1 && a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) == -1) {
                    continue;
                }
                if( isAMAAttached 
                   && isAMAAttachment  
                   && amaAgreement!= null 
                   && !amaAgreement.AMA_Manual_Review__c 
                   && (amaAgreement.Is_AMA_License_Required__c || amaAgreement.Is_Offshore_Access_Amendment_Required__c)) {
                       continue;
                   }
                if(a.Name.indexOf('Offerings Notification Vendor') != -1) {
                    isOffNotAttached = true;
                    att.add(a);
                }
                if(a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('IQVIA Third Party Tech') == -1 && a.Name.indexOf('.pdf') != -1) {
                    isTLLAAttached = true;
                    tllaDoc = a;
                    //att.add(a);
                }
                if(a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('IQVIA Third Party Tech License Agreement') != -1 && a.Name.indexOf('.pdf') != -1){
                    isTechLicAttached = true;
                    att.add(a);
                } 
                if(a.Name.indexOf('TLLA') != -1 && a.Name.indexOf('IQVIA Third Party Tech Amendment') != -1 && a.Name.indexOf('.pdf') != -1){
                    isTechAmendAttached = true;
                    att.add(a);
                } 
                if(a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1) {
                    isHelpfulHintAttached = true;
                    helpfulHintDoc = a;
                    //att.add(a);
                }  
                if(a.Name.indexOf('Addendum Notification') != -1) {
                    isAddendumAttached = true;
                    att.add(a);
                }     
                if( isAMAAttachment  
                   && amaAgreement!= null 
                   && !amaAgreement.AMA_Manual_Review__c && (amaAgreement.Is_AMA_License_Required__c || amaAgreement.Is_Offshore_Access_Amendment_Required__c)) {
                       System.debug('**isAMAAttached**'+isTLLAAttached);
                       isAMAAttached = true;
                       if(a.name.indexOf(SERVICE_BUREAU_II) != -1 || a.name.indexOf(CONTRACT_SALESFORCE) != -1) {
                           isSB2orCsfAttached = true;
                       }
                       att.add(a);
                   }
            }
            if(isHelpfulHintAttached){
                if(att.size() == 0) {
                    att.Add(helpfulHintDoc);
                }
                else {
                    att.Add(0, helpfulHintDoc);
                }
            }
            if(isTLLAAttached){
                if(att.size() == 0) {
                    att.Add(tllaDoc);
                }
                else {
                    att.Add(0, tllaDoc);
                }
            }
        }
        
        passString = authHeader();
        cheader = '\r\n--myBoundary'+'\r\n'+' Content-Type: application/json'+ '\r\n'+' Content-Disposition: form-data'+ '\r\n'+'\r\n';
        
        envelop = setParametersForEnvelope(ctrId, envDet, att, isSB2orCsfAttached, vendorLanguage);  
        System.debug('request body => '+envelop);
        envEOF = '\r\n'+'--myBoundary--';
        CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
        
        String accessToken = UTL_Docusign.getJWTAccessToken('TPA');
        CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
        System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);
        EnvResponse envstat;
        String sendEnvelopeResponse = '';
        if (!String.isEmpty(accessToken) || Test.isRunningTest()) {
            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = UTL_TPA.webServiceUrl + accKey + '/envelopes';
            request.setEndPoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Accept', 'application/json');
            //request.setHeader('X-DocuSign-Authentication', passString);
            request.setHeader('grant_type', 'Bearer');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('content-type', 'multipart/form-data;boundary=myBoundary');  
            request.setBody(cheader+''+envelop+'\r\n');
            
            for(Integer count=0; count<att.size();count++) {            
                //Blob b = att.get(count).body; 
                
                //bcontent = EncodingUtil.base64Encode(b);
                CNT_TPA_RequestSubmissionForm.getLimitsMessage(); 
                contentType = '\r\n--myBoundary'+'\r\n'+'Content-Type:application/octet-stream'+ '\r\n'+'Content-Transfer-Encoding: base64'+'\r\n'+'Content-Disposition:attachment; '+'filename=\"contract.pdf\";'+'documentid='+(count+1)+'\r\n\r\n\r\n';
                request.setBody(request.getBody() + contentType +'\r\n'+EncodingUtil.base64Encode(att.get(count).body) + + '\r\n');
                //contentTypeWithBody = contentTypeWithBody + contentType +'\r\n'+EncodingUtil.base64Encode(att.get(count).body);
                //contentLength = contentLength+contentTypeWithBody.length();
                att.get(count).body = null;
                // if(count < attsize - 1) {
                //     //contentTypeWithBody = contentTypeWithBody + '\r\n';
                //     request.setBody(request.getBody() + '\r\n');
                // }
            }      
            //request.setHeader('content-length', String.valueOf(contentLength));
            request.setBody(request.getBody() +envEOF);
            //Body
            //request.setBody(cheader+''+envelop+'\r\n'+contentTypeWithBody+'\r\n'+envEOF);
            System.debug('Request Body = '+cheader+''+envelop+'\r\n'+contentTypeWithBody+'\r\n'+envEOF);
            request.setTimeout(120000);
            HttpResponse response1 = httpProtocol.send(request);
            System.debug('response1 =>'+response1.getBody());
            JSONParser parse = JSON.createParser(response1.getBody());
            envstat = (EnvResponse)parse.readValueAs(EnvResponse.class);
            sendEnvelopeResponse = sendEnvelope(envstat.envelopeId);
            System.debug('De-Serialized class is envstats => '+envstat);
            
            //TODO
            if(envstat.status != 'created' || (sendEnvelopeResponse != null && sendEnvelopeResponse.contains('errorCode'))) {
                UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                    FALSE, 
                                                    UTL_LogFactory.GUID, 
                                                    'Exception: Response' + sendEnvelopeResponse+':: Creation Response'+response1.getBody(), 
                                                    'TPA', 
                                                    'Exception', 
                                                    'ERROR', 
                                                    ':::SRV_TPA_DocusignEnvelope:::createAndSendEnvelope', 
                                                    (sourceId != null) ? sourceId : null);
            }
        }
        String retVal = 'created || sent';
        if(envstat.status != 'created'){
            retVal = 'not created || not sent';
        }
        else if(sendEnvelopeResponse != null && sendEnvelopeResponse.contains('errorCode')){
            retVal = 'created || not sent';
        }
        
        return retVal;
    }

    @future(callout=true)
    public static void mergeAddHocDocsWithTLLA(Id requestId,String GUID){
        if(GUID != NULL && GUID != '') {
            UTL_LogFactory.GUID = GUID;
        }
        string adminUser = UTL_TPA.userNameContract;
        string adminUserPwd = UTL_TPA.passwordContract;
        string sessionId = UTL_TPA_Class_LoginAPI.login(adminUser,adminUserPwd);
        string serverUrl = '';
        List<TPA_Request__c> tpaReq = [Select id,Name,(Select Id,Name,Description From Attachments where Name like '%TLLA%' or Name like 'MergedAdHoc%' order by CreatedDate DESC ) From TPA_Request__c where id =: requestId];
        try{
            if(tpaReq[0].Attachments != null && tpaReq[0].Attachments.size()>0){
                serverUrl = UTL_TPA_Class_LoginAPI.serverUrl;
                List<Id> attchIds = new Id[2];
                String tllaName = '';
                Boolean tllaFound = false,adHocDocFound = false;
                for(Attachment attch:tpaReq[0].Attachments){
                    if(!tllaFound && (attch.Name != null && attch.Name.indexOf('TLLA') > -1) && (attch.Description == null || (attch.Description != '' && attch.Description.indexOf('Merged') < 0))){
                        attchIds[0] = attch.Id;
                        //tllaId = attch.Id;
                        tllaName = attch.Name;
                        tllaFound = true;
                    }
                    if(!adHocDocFound && (attch.Name != null && attch.Name.indexOf('MergedAdHocDocs') > -1)){
                        attchIds[1] = attch.Id;
                        //addHocId = attch.Id;
                        adHocDocFound = true;
                    }
                    if(adHocDocFound && tllaFound){
                        break;
                    }
                }
                //attchIds.add(tllaId);
                //attchIds.add(addHocId);
                
                //if(addHocPageDocIds.size() > 0)
                    //attchIds.addAll(addHocPageDocIds);
                    
                Apttus.CustomClass.ActionParams apiParameters = new Apttus.CustomClass.ActionParams();
                
                apiParameters.ParentId = requestId;
                apiParameters.DocIds = attchIds;
                apiParameters.DocFileName = 'Merged'+tllaName;
                apiParameters.PreserveRedlines = false;
                apiParameters.ProtectOutputDoc = false;
                apiParameters.SessionId = sessionId;
                apiParameters.SessionUrl = serverUrl;
                
                apiParameters.addAutoHeaderFooter = false;
                apiParameters.AddFooter = false;
                
                if(!Test.isRunningTest()){
                	String docId = Apttus.MergeWebService.mergeDocsToPDF2(apiParameters);
                }
                //system.debug('get'+docId);
            }
            
        }
        catch(Exception exp){
            system.debug('exp details'+exp.getMessage());
        }
    }

    @future(callout=true)
    public static void mergeAddHocDocs(Id requestId,List<Id> addHocPageDocIds,String reqName,String GUID){
        if(GUID != NULL && GUID != '') {
            UTL_LogFactory.GUID = GUID;
        }
        string adminUser = UTL_TPA.userNameContract;
        string adminUserPwd = UTL_TPA.passwordContract;
        string sessionId = UTL_TPA_Class_LoginAPI.login(adminUser,adminUserPwd);
        string serverUrl = '';
        //List<TPA_Request__c> tpaReq = [Select id,Name From TPA_Request__c where id =: requestId];
        try{
            if(addHocPageDocIds != null && addHocPageDocIds.size()>0){
                serverUrl = UTL_TPA_Class_LoginAPI.serverUrl;
                List<Id> attchIds = new List<Id>();
                
                if(addHocPageDocIds.size() > 0)
                    attchIds.addAll(addHocPageDocIds);
                    
                Apttus.CustomClass.ActionParams apiParameters = new Apttus.CustomClass.ActionParams();
                
                apiParameters.ParentId = requestId;
                apiParameters.DocIds = attchIds;
                apiParameters.DocFileName = 'MergedAdHocDocs.pdf';
                apiParameters.PreserveRedlines = false;
                apiParameters.ProtectOutputDoc = false;
                apiParameters.SessionId = sessionId;
                apiParameters.SessionUrl = serverUrl;
                
                apiParameters.addAutoHeaderFooter = false;
                apiParameters.AddFooter = true;
                apiParameters.FooterAlignment = 'Center';
                apiParameters.FooterFont = 'Arial';
                apiParameters.FooterFontSize = 7;
                apiParameters.FooterMode = 'Overwrite';
                apiParameters.FooterText = 'Form Rev. December 2023                   '+reqName+'                   '+System.Label.ExhibitPageFooter;
                //param.RetainInputHeaderFooter = true;
                
                if(!Test.isRunningTest()){
                	String docId = Apttus.MergeWebService.mergeDocsToPDF2(apiParameters);
                }
                //system.debug('get'+docId);
            }
            
        }
        catch(Exception exp){
            system.debug('exp details'+exp.getMessage());
        }
    }

    public static String setParametersForEnvelope(String ctrId, EnvelopeDetail envDet, List<Attachment> att, Boolean isSB2orCsfAttached, String vendorLanguage)  {          
        string recipients = '';
        string currentRecipient = '';        
        
        recipients = envDet.CRL;
        List<string> recipientList = recipients.split('\\,');
        integer recipientLength = recipientList.size();
        system.debug(recipients);
        system.debug(recipientList);
        List<String> signTagList = new List<String> {'\\s1\\','\\s2\\','\\s3\\'}; 
        List<String> titleTagList = new List<String> {'\\t1\\','\\t2\\','\\t3\\'}; 
        List<String> nameTagList = new List<String> {'\\n1\\','\\n2\\','\\n3\\'}; 
        List<String> initialTagList = new List<String> {'\\i1\\','\\i2\\','\\i3\\'}; 
        List<String> dateTagList = new List<String> {'\\d1\\','\\d2\\','\\d3\\'}; 
        JSONGenerator gen = JSON.createGenerator(true);
        //Start JSON Content
        gen.writeStartObject();
        gen.writeStringField('status', 'created');
        gen.writeStringField('emailBlurb', envDet.CEM );
        gen.writeStringField('emailSubject', envDet.CES);
        gen.writeStringField('AutoNavigation','true');
        gen.writeStringField('EnvelopeIdStamping','true');
        gen.writeStringField('AuthoritativeCopy','false');
        
        if(UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Docusign Branding' + vendorLanguage) != null) {
            gen.writeStringField('brandId', UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Docusign Branding' + vendorLanguage).Translated_Template_Id__c);
        }
        
        //document
        gen.writeFieldName('documents');
        gen.writeStartArray();
        
        for(Integer count = 0; count < att.Size(); count++) {
            gen.writeStartObject();
            gen.writeStringField('documentId', String.valueOf(count+1));
            if(att[count].Name.indexOf('Third Party Tech License Agreement') != -1){
                att[count].Name = att[count].Name.replace('Third Party','TP');
            }
            gen.writeStringField('name', att[count].Name);
            gen.writeEndObject();
        }
        
        gen.writeEndArray();
        //end of doc
        
        //start notifications 
        gen.writeFieldName('notifications');       
        gen.writeStartObject();
        gen.writeStringField('useAccountDefaults', 'true');
        //start reminders   
        gen.writeFieldName('reminders');           
        gen.writeStartObject();
        gen.writeObjectField('reminderEnabled', 'true');     
        gen.writeEndObject();      
        //end reminders
        
        gen.writeEndObject();
        //end notifications          
        
        //start recipients
        gen.writeFieldName('recipients');       
        gen.writeStartObject();
        
        //start carbon copies    
        gen.writeFieldName('carbonCopies');
        gen.writeStartArray(); 
        
        List<string> recipientParameters ;  
        Recipient recipientObj;
        
        if( recipientLength > 1) {
            system.debug(currentRecipient);
            integer jCount = 1 ;
            if(isDoubleSignerExist && isAdditionalSignerExist)
                jCount = 3;
            else if(isDoubleSignerExist || isAdditionalSignerExist)   
                jCount = 2; 
            for(;jCount < recipientLength;jCount++) {
                currentRecipient = recipientList[jCount];
                system.debug(currentRecipient);
                recipientObj = new Recipient(currentRecipient,jCount+1)  ;  
                
                gen.writeStartObject();
                gen.writeObjectField('email', recipientObj.email);
                gen.writeObjectField('name', recipientObj.name);
                gen.writeObjectField('recipientId', recipientObj.recipientId);  
                gen.writeObjectField('routingOrder', recipientObj.routingOrder);            
                gen.writeEndObject();  
            }       
        }
        gen.writeEndArray();
        
        //start signers
        gen.writeFieldName('signers');
        gen.writeStartArray();
        
        system.debug(recipientList [0]);

        if( recipientLength > 1) {
            integer iCount = 0 ;
            integer jCount = 1 ;
            if(isDoubleSignerExist && isAdditionalSignerExist)
                jCount = 3;
            else if(isDoubleSignerExist || isAdditionalSignerExist)   
                jCount = 2; 
            for(;iCount < jCount;iCount++) {
                system.debug(recipientList [1]);
                currentRecipient = recipientList [iCount];
                recipientObj = new Recipient(currentRecipient,iCount+1)   ;     
                gen.writeStartObject();
                gen.writeObjectField('email', recipientObj.email);
                gen.writeObjectField('name', recipientObj.name);
                gen.writeObjectField('recipientId', recipientObj.recipientId);  
                gen.writeObjectField('routingOrder', recipientObj.routingOrder);

                gen.writeFieldName('tabs');
                gen.writeStartObject();
                //start sign here
                gen.writeFieldName('signHereTabs');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeObjectField('anchorString', signTagList[iCount]);   
                gen.writeObjectField('anchorXOffset', '0'); 
                gen.writeObjectField('anchorYOffset', '0'); 
                gen.writeObjectField('anchorIgnoreIfNotPresent', 'true');
                gen.writeObjectField('anchorUnits', 'inches');
                gen.writeEndObject();   
                gen.writeEndArray(); 
                
                gen.writeFieldName('titleTabs');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeObjectField('anchorString', titleTagList[iCount]);   
                gen.writeEndObject();   
                gen.writeEndArray(); 
                gen.writeFieldName('fullNameTabs');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeObjectField('anchorString', nameTagList[iCount]);   
                gen.writeEndObject();   
                gen.writeEndArray(); 
                
                gen.writeFieldName('initialHereTabs');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeObjectField('anchorString', initialTagList[iCount]);   
                gen.writeObjectField('anchorIgnoreIfNotPresent', true);
                gen.writeEndObject();   
                gen.writeEndArray();            
                
                gen.writeFieldName('dateSignedTabs');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeObjectField('anchorString', dateTagList[iCount]);   
                gen.writeEndObject();   
                gen.writeEndArray(); 
                
                gen.writeEndObject();
            //end tab
                gen.writeEndObject(); 
               // iCount = iCount + 1;
            }       
        }
        
        gen.writeEndArray();
        //end signers
        
        gen.writeEndObject();
        //end recipient
        
        gen.writeEndObject();
        //end JSON Content
        
        System.debug('JSON String => '+gen.getAsString());
        return gen.getAsString();
    }
    
    public static String sendEnvelope(string envId) {
        String sendEnvelopeResponse = '';
        try {
            String accessToken = UTL_Docusign.getJWTAccessToken('TPA');
            System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);
            if (!String.isEmpty(accessToken) || Test.isRunningTest()) {
                JSONGenerator gen;
                Http httpProtocol = new Http();
                HttpRequest request2 = new HttpRequest();
                String body = '';
                String passString = authHeader();  
                String accKey = UTL_TPA.docusignAccountId;
                String endpoint = UTL_TPA.webServiceUrl + accKey + '/envelopes/' + envid; 
                
                request2.setEndPoint(endpoint);        
                request2.setMethod('PUT');
                request2.setHeader('Accept', 'application/json');
                //request2.setHeader('X-DocuSign-Authentication', passString);
                request2.setHeader('grant_type', 'Bearer');
                request2.setHeader('Authorization', 'Bearer ' + accessToken);
                gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('status', 'sent');
                gen.writeEndObject();
                body = gen.getAsString();
                
                request2.setBody(body);
                HttpResponse response2 = httpProtocol.send(request2);
                sendEnvelopeResponse = response2.getBody();
                System.debug('response2 =>'+response2.getBody());
            }
        }
        catch(Exception ex) {       
            System.debug(ex.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, 
            FALSE, 
            UTL_LogFactory.GUID, 
            'Exception: Failed to Send Envelope  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
            'TPA', 
            'Exception', 
            'ERROR', 
            'Line#' + ex.getLineNumber() + ':::SRV_TPA_DocusignEnvelope:::sendEnvelope::StackTrace :'+ex.getStackTraceString(), 
            ''));
        }
        return sendEnvelopeResponse;
    }  
    
    @future(callout=true)
    public static void voidEnvelope(Set<Id> stAgreementCancelled, String voidReason) {
        system.debug('#### in Void envelope method');
        String requestId = '';
        String sendEnvelopeResponse = '';
        String tempVoidReason = voidReason;
        try {
            List<String> lstStatusVoided = new List<String>();
            List<dsfs__DocuSign_Status__c> statusList = [select id,
                                                         TPA_Request__c,
                                                         TPA_Request__r.Vendor_Language__c,
                                                         dsfs__DocuSign_Envelope_ID__c
                                                         from dsfs__DocuSign_Status__c
                                                         where dsfs__Envelope_Status__c in ('Sent','Delivered') 
                                                         and TPA_Request__c in: stAgreementCancelled];
            for(dsfs__DocuSign_Status__c objStatus: statusList ) {
                requestId = objStatus.TPA_Request__c;
                if(voidReason == '') {
                    system.debug('objStatus.TPA_Request__r.Vendor_Language__c = ' + objStatus.TPA_Request__r.Vendor_Language__c);
                    Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{objStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c'});
                    voidReason = multilanguageUtilityMap == null ? 'Envelope is Corrected' : (String)multilanguageUtilityMap.get(objStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~VoidReason')[0].get(objStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c');
                }
                else if(tempVoidReason == 'DDNVoidReason' ){
                    system.debug('objStatus.TPA_Request__r.Vendor_Language__c = ' + objStatus.TPA_Request__r.Vendor_Language__c);
                    Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{'English_Translation__c','Japanese_Translation__c'});
                    voidReason = multilanguageUtilityMap == null ? 'Account Placed on Hold due to Failure to Acknowledge DDN' : (String)multilanguageUtilityMap.get(objStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c~TPA_Request__c~Record~On_Hold')[0].get(objStatus.TPA_Request__r.Vendor_Language__c + '_Translation__c');    
                }
                String accessToken = UTL_Docusign.getJWTAccessToken('TPA');
                System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);
                
                if (!String.isEmpty(accessToken) || Test.isRunningTest()) {
                    JSONGenerator gen;
                    Http httpProtocol = new Http();
                    HttpRequest request2 = new HttpRequest();
                    String  body = '';
                    String passString = '<DocuSignCredentials>'+'<Username>'+ UTL_TPA.userId  +'</Username>'+  '<Password>'+ UTL_TPA.password  +'</Password>'+ '<IntegratorKey>'+ UTL_TPA.integratorsKey +'</IntegratorKey>'+'</DocuSignCredentials>';
                    String accKey = UTL_TPA.docusignAccountId;
                    String endpoint = UTL_TPA.webServiceUrl+accKey+'/envelopes/'+objStatus.dsfs__DocuSign_Envelope_ID__c;
                    
                    request2.setEndPoint(endpoint);
                    request2.setMethod('PUT');
                    request2.setHeader('Accept', 'application/json');
                    //request2.setHeader('X-DocuSign-Authentication', passString);
                    request2.setHeader('grant_type', 'Bearer');
                    request2.setHeader('Authorization', 'Bearer ' + accessToken);
                    gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('status', 'voided');
                    gen.writeStringField('voidedReason', voidReason);
                    system.debug('Void Reason = ' + voidReason);
                    
                    gen.writeEndObject();
                    body = gen.getAsString();
                    
                    request2.setBody(body);
                    HttpResponse response2 = httpProtocol.send(request2);
                    sendEnvelopeResponse = response2.getBody();
                }
            }
        } catch(Exception ex) {
            System.debug('####voidEnvelope an error occured: '+ex.getMessage()+', Line: '+ex.getLineNumber()+', Cause: '+ex.getCause());
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: Failed to void Envelope  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                ':::SRV_TPA_DocusignEnvelope:::voidEnvelope:::Response->'+ sendEnvelopeResponse, 
                                                (requestId != null) ? requestId : null);
        }
    }
    
    @future(callout=true)
    public static void voidEnvelope(String envId, String voidReason) {
        try {
            String accessToken = UTL_Docusign.getJWTAccessToken('TPA');
            System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);
            if (!String.isEmpty(accessToken) || Test.isRunningTest()) {
                JSONGenerator gen;
                Http httpProtocol = new Http();
                HttpRequest request2 = new HttpRequest();
                String  body = '';
                String passString = authHeader();  
                String accKey = UTL_TPA.docusignAccountId;
                String endpoint = UTL_TPA.webServiceUrl+accKey+'/envelopes/'+envid; 
                
                request2.setEndPoint(endpoint);        
                request2.setMethod('PUT');
                request2.setHeader('Accept', 'application/json');
                //request2.setHeader('X-DocuSign-Authentication', passString);
                request2.setHeader('grant_type', 'Bearer');
                request2.setHeader('Authorization', 'Bearer ' + accessToken);
                gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('status', 'voided');
                gen.writeStringField('voidedReason', voidReason);
                gen.writeEndObject();
                body = gen.getAsString();
                
                request2.setBody(body);
                HttpResponse response2 = httpProtocol.send(request2);
            }
        } catch(Exception ex) {       
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, 
            FALSE, 
            UTL_LogFactory.GUID, 
            'Exception: Failed to void Envelope  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
            'TPA', 
            'Exception', 
            'ERROR', 
            'Line#' + ex.getLineNumber() + ':::SRV_TPA_DocusignEnvelope:::voidEnvelope', 
            ''));
            
        }
    }
    
    public static void voidEnvelopeCallout(String requestId , String vendorLanguage){
        try{
            Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap = UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{vendorLanguage + '_Translation__c'});
            String voidReason = multilanguageUtilityMap == null ? 'Envelope is Corrected' : (String)multilanguageUtilityMap.get(vendorLanguage + '_Translation__c~TPA_Request__c~Record~VoidReason')[0].get(vendorLanguage + '_Translation__c');
            string envid ='';
            List<dsfs__DocuSign_Status__c> statusList = [select id,TPA_Request__c,dsfs__DocuSign_Envelope_ID__c  
                                                         from dsfs__DocuSign_Status__c
                                                         where  dsfs__Envelope_Status__c in ('Sent','Delivered') and TPA_Request__c =: requestId limit 1];
            
            //Void Envelope for cancel and expired
            for(dsfs__DocuSign_Status__c objStatus: statusList ){     
                envid = objStatus.dsfs__DocuSign_Envelope_ID__c;
            }

            //Get the access token
            String accessToken = UTL_Docusign.getJWTAccessToken('TPA');
            System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);

            //Call CLM API if a non-empty access token is returned
            if (!String.isEmpty(accessToken) || Test.isRunningTest()) {
                JSONGenerator gen;
                Http httpProtocol = new Http();
                HttpRequest request2 = new HttpRequest();
                String  body = '';
                String passString = authHeader();  
                String accKey = getAccountKey();
                String endpoint = getDocusignURL()+accKey+'/envelopes/'+envid;       
                
                request2.setEndPoint(endpoint);        
                request2.setMethod('PUT');
                request2.setHeader('Accept', 'application/json');
                //request2.setHeader('X-DocuSign-Authentication', passString);
                //set Authentication Header
                request2.setHeader('grant_type', 'Bearer');
                request2.setHeader('Authorization', 'Bearer ' + accessToken);
                gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('status', 'voided');
                gen.writeStringField('voidedReason', voidReason);
                gen.writeEndObject();
                body = gen.getAsString();
                request2.setBody(body);
                HttpResponse response2 = httpProtocol.send(request2);
                System.Debug(LoggingLevel.INFO, '***response.getBody() ' + response2.getBody());
                System.debug(LoggingLevel.INFO, '***response.getStatus() ' + response2.getStatus());
            }
        }catch(Exception ex){       
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, 
            FALSE, 
            UTL_LogFactory.GUID, 
            'Exception: Failed to void Envelope Callout ::Type' +ex.getTypeName()+'::'+'Message: '+ex.getMessage()+':: Cause: '+ex.getCause() , 
            'TPA', 
            'Exception', 
            'ERROR', 
            'Line#' + ex.getLineNumber() + ':::SRV_TPA_DocusignEnvelope:::voidEnvelopeCallout', 
            (requestId != null) ? requestId : null));
        }
        
    }
    
    //Envelope Data Class
    public class EnvResponse {
        String envelopeId;
        String status;
        String statusDateTime;
        String uri;
        String message;
    }
    
    public class Recipient {
        String email;
        String name;
        String recipientId;
        String routingOrder;
        
        public Recipient(String recipient, integer count) {
            setRecipientParameters(recipient,count);
        }
        
        private void setRecipientParameters(String recipient, integer count) {
            string parameter = '';
            String lastName ='';
            String firstName = '';
            List<string> recipientParam = new List<string>();
            List<string> parameterList = new List<string>();
            
            system.debug(recipient);
            recipientParam = recipient.split('\\;');
            for(integer iCount = 0; iCount < recipientParam.size(); iCount++) {
                parameter = recipientParam[iCount];
                system.debug(parameter);
                parameterList = parameter.split('\\~');
                system.debug(parameterList);
                if(parameter.contains('Email')) {
                    email = parameterList[1];
                }
                if(parameter.contains('LastName')) {
                    lastName = parameterList[1];
                    name = lastName;
                }
                if(parameter.contains('Role')) {
                    recipientId = string.valueof(count);
                }
                if(parameter.contains('RoutingOrder')) {
                    routingOrder = '1';
                }
            }
        }
    }
    
    //Get URL Paramter from UTL_TPA
    public static String getDocusignURL(){
        String url = UTL_TPA.webServiceUrl;
        return url;
    }
    
    //Get Account Key Paramter from UTL_TPA
    public static String getAccountKey(){
        String accKey = UTL_TPA.docusignAccountId;
        return accKey ; 
    }
    
    //Get Authenticaion Header to authenticate request for docusign by using Docusign Rest API
    public static String authHeader(){
        //Get Paramter from UTL_TPA and construct auth header
        return '<DocuSignCredentials>'+'<Username>'+ UTL_TPA.userId  +'</Username>'+  '<Password>'+ UTL_TPA.password  +'</Password>'+ '<IntegratorKey>'+ UTL_TPA.integratorsKey +'</IntegratorKey>'+'</DocuSignCredentials>';
    }
    
    @future(callout=true)
    public static void generateDocForSign(String requestId, string GUID) {
        if(GUID != NULL && GUID != '') {
            UTL_LogFactory.GUID = GUID;
        }
        string adminUser = UTL_TPA.userNameContract;
        string adminUserPwd = UTL_TPA.passwordContract;
        string sessionId = UTL_TPA_Class_LoginAPI.login(adminUser,adminUserPwd);
        string serverUrl = '';
        
        //fetch the request record
        List<TPA_Request__c> requests = [SELECT Id,
                                         Client_Request_Submission__c, 
                                         Vendor_Language__c,
                                         TLLA_Language_Chosen__c,
                                         Requires_Manual_Review__c,
                                         Pending_Acknowledgements__c, 
                                         OwnerId, 
                                         Owner.email, 
                                         Name, 
                                         Owner.Name
                                         FROM TPA_Request__c 
                                         WHERE id=:requestId LIMIT 1];
        TPA_Request__c request = requests[0];
        String templateName = '';
        String oldTemplateName = '';
        
        String vendorLanguage = request.TLLA_Language_Chosen__c != null ? request.TLLA_Language_Chosen__c : (request.Vendor_Language__c != null ? request.Vendor_Language__c : 'English');
        TPA_Multilingual_Template_Setting__c templatObj = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TLLA' + vendorLanguage);
        templateName = templatObj.Translated_Template_Name__c; 
        TPA_Multilingual_Template_Setting__c templatObjold = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TLLA Before April' + vendorLanguage);
        oldTemplateName = templatObjold.Translated_Template_Name__c; 
        System.debug('Selected template :: ' + templateName);
        //fetch the SOW template
        List<Apttus__APTS_Template__c> templates = [SELECT Id,Name FROM Apttus__APTS_Template__c WHERE Name =: templateName and Apttus__IsActive__c = TRUE LIMIT 1];
        List<Apttus__APTS_Template__c> oldTemplates = [SELECT Id,Name FROM Apttus__APTS_Template__c WHERE Name =: oldTemplateName and Apttus__IsActive__c = TRUE LIMIT 1];//Added by Govind under Issue 8548
        
        try
        {
            if(!Test.isRunningTest()){  
                serverUrl = UTL_TPA_Class_LoginAPI.serverUrl;                      
                //generate document
                Id docId;
                DateTime clientSubmittedDateTime = request.Client_Request_Submission__c;     
                Date clientPartSubmissionDate = date.newinstance(clientSubmittedDateTime.year(), clientSubmittedDateTime.month(), clientSubmittedDateTime.day());
                boolean isDisplayWatermark = false;
                if(UTL_TPA.tpaSetting.Is_Template_Watermark_Automated__c) {
                    isDisplayWatermark = UTL_TPA.isSandboxOrg;
                }
                if(clientPartSubmissionDate > TPA_Settings__c.getInstance().New_TLLA_Launch_Date__c && templates.size() > 0 && templates[0] != null){    
                    docId = Apttus.MergeWebService.generateCustomDoc( templates[0].Id,request.id, 'TPA_Request__c', 'Full access', 'PDF', isDisplayWatermark,sessionId,serverUrl); 
                }else if(oldTemplates.size() > 0 && oldTemplates[0] != null){
                    docId = Apttus.MergeWebService.generateCustomDoc( oldTemplates[0].Id,request.id, 'TPA_Request__c', 'Full access', 'PDF', isDisplayWatermark,sessionId,serverUrl); 
                }
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: in generating Document  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                'Line#' + ex.getLineNumber() + ':::Stack Trace:' + ex.getStackTraceString() + ':::SRV_TPA_DocusignEnvelope:::generateDocForSign', 
                                                (request.id != null) ? request.id : null);
            
        }
    }
    
    @future(callout=true)
    public static void generateAmaDocForSign(String requestId, String GUID){  
        If(GUID != NULL && GUID != '') {
            UTL_LogFactory.GUID = GUID;
        }
        string  adminUser = UTL_TPA.userNameContract;
        string  adminUserPwd = UTL_TPA.passwordContract;
        string sessionId = UTL_TPA_Class_LoginAPI.login(adminUser,adminUserPwd);
        string serverUrl = '';
        String templateId = '';
        Id docId;
        
        //fetch the agreement record
        List<TPA_Request__c> requests = [SELECT Id, (Select id, Current_Year__c, Contract_Type__c, Is_AMA_License_Required__c, Is_Offshore_Access_Amendment_Required__c, AMA_Manual_Review__c, Template__c 
                                                     from AMA_Agreement_Details__r limit 1)  
                                         FROM TPA_Request__c 
                                         WHERE id=:requestId LIMIT 1];
        if(requests.size() > 0 && requests[0].AMA_Agreement_Details__r.size() > 0 && ((requests[0].AMA_Agreement_Details__r[0].Contract_Type__c != null  && UTL_TPA.templateContractTypes.contains(requests[0].AMA_Agreement_Details__r[0].Contract_Type__c)
           && requests[0].AMA_Agreement_Details__r[0].Is_AMA_License_Required__c && !requests[0].AMA_Agreement_Details__r[0].AMA_Manual_Review__c) || requests[0].AMA_Agreement_Details__r[0].Is_Offshore_Access_Amendment_Required__c)){
               
               TPA_Request__c request = requests[0];
               //Send AMA Agreement
               try{
                   if(!Test.isRunningTest()){  
                       serverUrl = UTL_TPA_Class_LoginAPI.serverUrl;  
                       //generate document   
                       System.debug('**Before Generating**adminUser**'+adminUser+'=2=adminUserPwd:'+adminUserPwd+'=3=sessionId:'+sessionId+'=4=serverUrl:'+serverUrl);                
                       //Adding Five Seconds delay starts
                       Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
                       Integer delayInMilliseconds = 10000; // Five-second delay
                       while (System.now().getTime() - startingTime < delayInMilliseconds){
                           // Do nothing until desired delay has passed
                       }
                       //Adding Five Seconds delay ends
                       boolean isDisplayWatermark = false;
                       if(UTL_TPA.tpaSetting.Is_Template_Watermark_Automated__c) {
                           isDisplayWatermark = UTL_TPA.isSandboxOrg;
                       }
                       templateId = SRV_TPA_AMAAgreementDetail.generateAmaAgreement(request);
                       if(templateId != null && templateId != ''){
                           docId = Apttus.MergeWebService.generateCustomDoc( templateId, request.id, 'TPA_Request__c', 'Full access', 'PDF', isDisplayWatermark,sessionId,serverUrl);
                       }
                       System.debug('**Successfully generated AMA Template**docId**'+docId);
                   }
               }
               catch(Exception e){
                   system.debug('***Exception while generating AMA Agreement***'+e.getMessage());
                   UTL_LogFactory.generateAndCommitLog( TRUE, 
                                                        FALSE, 
                                                        UTL_LogFactory.GUID, 
                                                        'Exception: in generating AMA Doc  :: Type' +e.getTypeName()+':: Message'+ e.getMessage()+':: Cause'+ e.getCause(), 
                                                        'TPA', 
                                                        'Exception', 
                                                        'ERROR', 
                                                        ':::SRV_TPA_DocusignEnvelope:::generateAmaDocForSign::Line#'+e.getLineNumber()+'::Stack' + e.getStackTraceString(), 
                                                        (requestId != null) ? requestId : null);
                }
           }
    }
    
    public static void updateAgreement(string requestId,Date newDateSigned,String evpId,Id statusId)
    {
        System.debug('Method Upadate Agreement Called');
        try{     
            splitSignedDocument(requestId,evpId,statusId,newDateSigned, UTL_LogFactory.GUID);
        }
        catch( Exception ex){
            UTL_LogFactory.generateAndCommitLog(TRUE, 
            FALSE, 
            UTL_LogFactory.GUID, 
            'Exception: in updateAgreement  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
            'TPA', 
            'Exception', 
            'ERROR', 
            'Line#' + ex.getLineNumber() + ':::Stack Trace:' + ex.getStackTraceString() + ':::SRV_TPA_DocusignEnvelope:::updateAgreement', 
            (requestId != null) ? requestId : null);
        }
    }
    
    public static void sendReminderForEnvelope(string requestId){
        try{
            Integer daysToSendReminder = 1;
            Date dateVal = system.today().addDays(daysToSendReminder);
            Date todayDate = system.today();
            
            List<dsfs__DocuSign_Recipient_Status__c> statusList = [SELECT  Id ,dsfs__DocuSign_Recipient_Email__c,dsfs__DocuSign_Recipient_Id__c,
                                                                   dsfs__Recipient_Status__c, dsfs__Parent_Status_Record__r.TPA_Request__c,
                                                                   dsfs__Envelope_Id__c,Name,createddate FROM dsfs__DocuSign_Recipient_Status__c
                                                                   where  dsfs__Recipient_Status__c in ('Sent','Delivered') 
                                                                   and dsfs__Parent_Status_Record__r.TPA_Request__c =: requestId  limit 1];
            
            for(dsfs__DocuSign_Recipient_Status__c objRecipient : statusList ){   
                if(objRecipient.createddate < todayDate ){
                    Integer dateDifferenceInDays = todayDate.daysBetween(objRecipient.createddate.date());                    
                    Integer modInDays = math.mod(dateDifferenceInDays,UTL_TPA.daysToSendReminder);
                    if(modInDays == 0) {
                        resendEnvelope(objRecipient);
                    }               
                }
                break;
            }
        }catch(Exception ex){
            UTL_LogFactory.generateAndCommitLog(TRUE, 
            FALSE, 
            UTL_LogFactory.GUID, 
            'Exception: in sendReminderForEnvelope  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
            'TPA', 
            'Exception', 
            'ERROR', 
            'Line#' + ex.getLineNumber() + ':::Stack:' + ex.getStackTraceString() + ':::SRV_TPA_DocusignEnvelope:::sendReminderForEnvelope', 
            (requestId != null) ? requestId : null);
        }
    }
    
    public static void resendEnvelope(dsfs__DocuSign_Recipient_Status__c objRecipient){
        try{
            string envId = objRecipient.dsfs__Envelope_Id__c;
            String accessToken = UTL_Docusign.getJWTAccessToken('TPA');
            System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);
            if (!String.isEmpty(accessToken) || Test.isRunningTest()) {
                JSONGenerator gen;
                Http httpProtocol = new Http();
                HttpRequest request2 = new HttpRequest();
                String  body = '';
                String passString = authHeader();  
                String accKey = getAccountKey();
                String endpoint = getDocusignURL()+accKey+'/envelopes/'+envid+'/recipients?resend_envelope=true';     
                
                request2.setEndPoint(endpoint);        
                request2.setMethod('PUT');
                request2.setHeader('Accept', 'application/json');
                //request2.setHeader('X-DocuSign-Authentication', passString);
                request2.setHeader('grant_type', 'Bearer');
                request2.setHeader('Authorization', 'Bearer ' + accessToken);
                
                gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('signers');
                gen.writeStartArray();               
                gen.writeStartObject();
                gen.writeObjectField('email',objRecipient.dsfs__DocuSign_Recipient_Email__c);
                gen.writeObjectField('name', objRecipient.Name);
                gen.writeObjectField('recipientId', '1');  
                gen.writeEndObject();
                gen.writeEndArray();
                gen.writeEndObject();
                
                body = gen.getAsString();
                
                request2.setBody(body);
                HttpResponse response2 = httpProtocol.send(request2);
            }
        }catch(Exception ex){       
            UTL_LogFactory.generateAndCommitLog(TRUE, 
            FALSE, 
            UTL_LogFactory.GUID, 
            'Exception: in resendEnvelope  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
            'TPA', 
            'Exception', 
            'ERROR', 
            'Line#' + ex.getLineNumber() + ':::Stack:' + ex.getStackTraceString() + ':::SRV_TPA_DocusignEnvelope:::resendEnvelope', 
            (objRecipient.dsfs__Parent_Status_Record__r.TPA_Request__c != null && !Test.isRunningTest()) ? objRecipient.dsfs__Parent_Status_Record__r.TPA_Request__c : null);
        }
    }
    
    @future(callout=true)
    public static void splitSignedDocument(String requestId,String envId,Id statusId,Date newDateSigned, String GUID) {
        List<TPA_Request__c> listAgg = [select Id,Is_Contract_Generated__c,Requires_Manual_Review__c,Is_Restricted_Data_Asset__c,After_in_Effect_Changes__c
                                                   from TPA_Request__c where id =: requestId LIMIT 1 ];                          
        If(GUID != NULL && GUID != '') {
            UTL_LogFactory.GUID = GUID;
        }
        
        try {
            //String envid = 'EA148BC2-03B9-475C-A6E1-A129F7859C2C';
            List<Attachment> lstAttachmentInsert = new List<Attachment>();
            String accessToken = UTL_Docusign.getJWTAccessToken('TPA');
            System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);
            if (!String.isEmpty(accessToken) || Test.isRunningTest()) {
                Http httpProtocol = new Http();
                HttpRequest request2 = new HttpRequest();
                String passString = authHeader();  
                String accKey = getAccountKey();
                String endpoint = getDocusignURL()+getAccountKey()+'/envelopes/'+envId+'/documents'; 
                request2.setEndPoint(endpoint);        
                request2.setMethod('GET');
                request2.setHeader('Accept', 'application/json');
                //request2.setHeader('X-DocuSign-Authentication', passString);
                request2.setHeader('grant_type', 'Bearer');
                request2.setHeader('Authorization', 'Bearer ' + accessToken);
                HttpResponse response2;
                if(!Test.isRunningTest()){
                    response2 = httpProtocol.send(request2);
                }else{
                    response2 = new HttpResponse();
                    response2.setBody('{"envelopeId": "37A2A639-E9EF-4FD3-A390-3E6621897CD9","envelopeDocuments": [{"documentId": "1","name": "Test_1.pdf","type": "content","uri": "/envelopes/37A2A639-E9EF-4FD3-A390-3E6621897CD9/documents/1","order": "1","pages": "1"}]}');
                }
                WRP_TPA_DocumentParser obj  = (WRP_TPA_DocumentParser)JSON.deserialize(response2.getBody(), WRP_TPA_DocumentParser.class);
                
                for(WRP_TPA_DocumentProperties ob :  obj.envelopeDocuments){
                    if(ob.documentId == 'certificate'){
                        continue;
                    }
                    String endpoint2 = endpoint+'/'+ob.documentId;
                    HttpRequest request3 = new HttpRequest();
                    request3.setEndPoint(endpoint2);        
                    request3.setMethod('GET');
                    request3.setHeader('Accept', 'application/json');
                    //request3.setHeader('X-DocuSign-Authentication', passString);
                    request3.setHeader('grant_type', 'Bearer');
                    request3.setHeader('Authorization', 'Bearer ' + accessToken);
                    HttpResponse response3;
                    if(!Test.isRunningTest()){
                        response3 = httpProtocol.send(request3);
                    }else{
                        response3 = new HttpResponse();
                        response3.setBody('Test');
                    }
                    Attachment att = new Attachment();
                    att.name = ob.name;
                    att.body = response3.getBodyAsBlob();
                    att.ParentId = statusId;
                    lstAttachmentInsert.add(att);
                }
            }
            insert lstAttachmentInsert;
            if(listAgg.size() > 0 ){
                TPA_Request__c  cpcAgreement = listAgg[0];
                system.debug('before updateStatusToInEffect');

                if(!cpcAgreement.After_in_Effect_Changes__c ){
                    updateStatusToInEffect(requestId,newDateSigned);
                }
                else{
                    cpcAgreement.Additional_Envelope_completion_Date__c = DateTime.now();
                    UTL_TPA.modifyRequestForcefully = true;
                    update cpcAgreement;
                    UTL_TPA.modifyRequestForcefully = false;
                }
            }
        }catch(Exception ex){    
            UTL_LogFactory.generateAndCommitLog( TRUE, 
                                                        FALSE, 
                                                        UTL_LogFactory.GUID, 
                                                        'Exception: in generating AMA Doc  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
                                                        'TPA', 
                                                        'Exception', 
                                                        'ERROR', 
                                                        ':::SRV_TPA_DocusignEnvelope:::Splitted Document from Docusign::Line# '+ ex.getLineNumber() + ':::Stack :' + ex.getStackTraceString(), 
                                                        (requestId != null) ? requestId : null);
        }
    }
    
    public static void updateStatusToInEffect(String requestId,Date newDateSigned)
    {
        boolean isWetSign = false;
        List<TPA_Request__c> listAgg;
        System.debug('Method updateStatusToInEffect Called');
        try{
            listAgg = [select id,Is_Contract_Generated__c,Requires_Manual_Review__c,Is_Restricted_Data_Asset__c from TPA_Request__c where id =: requestId LIMIT 1 ];
            if(listAgg.size() > 0 ){
                TPA_Request__c  cpcAgreement = listAgg[0];
                List<Attachment> lstAttachments = new List<Attachment>();
                lstAttachments = [select id,name,LastModifiedDate from Attachment where ParentId =: cpcAgreement.Id];
                if(lstAttachments.size() > 0){
                    for(Integer count = 0; count < lstAttachments.size(); count++){
                        System.debug('################Last Modified'+lstAttachments.get(count).LastModifiedDate.date());
                        System.debug('################Date Signed'+newDateSigned);
                        if(lstAttachments.get(count).LastModifiedDate.date() == newDateSigned){
                            if(lstAttachments.get(count).name.indexOf('Signed on Paper') != -1){
                                isWetSign = true;
                            }
                        }
                    }
                }
                if(!isWetSign){
                    List<Attachment> lstAttachment = new List<Attachment>();
                    lstAttachment = [select Id, Name,Body from Attachment where ParentId =: requestId and (Name like 'AMA_%TPA%.pdf_Completed')];
                    if(lstAttachment.size() > 0){
                        TGRH_TPARequest tpa = new TGRH_TPARequest();
                        tpa.sendMailToDblForExecutedAmaAgreement(requestId);                        
                    }
                    cpcAgreement.Request_Status__c = 'In Effect';
                    cpcAgreement.Is_Mail_Feature_Required__c = true;
                    cpcAgreement.Helpful_Hints_Acknowledged__c = true;
                    update cpcAgreement;
                }else{
                    cpcAgreement.Request_Status__c = 'Signature Under Validation';
                    SRV_TPA_TPARequest.updateActivityHistory(cpcAgreement.Id, 'Signature Under Validation', true);
                    cpcAgreement.Is_Mail_Feature_Required__c = true;
                    cpcAgreement.Helpful_Hints_Acknowledged__c = true;
                    update cpcAgreement;
                }
                TPA_Request__c tpaRequest = SRV_TPA_TPARequest.getRequestInfo(listAgg[0].Id);
            }
        }catch( Exception ex){
            //todo
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Exception';
            //TPAQueryHelper.setLogObject(requestId , 'Exception:Failed to Change the Status',ex.getMessage()+'*'+ex.getLineNumber(),listAgg[0].Id);
            //TPAQueryHelper.logRef().generateLog();
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                                               FALSE, 
                                                                               UTL_LogFactory.GUID, 
                                                                               'Exception: Failed to Change the Status to In Effect  :: Type' +ex.getTypeName()+':: Message'+ ex.getMessage()+':: Cause'+ ex.getCause(), 
                                                                               'TPA', 
                                                                               'Exception', 
                                                                               'ERROR', 
                                                                               'Line#' + ex.getLineNumber() + ':::SRV_TPA_DocusignEnvelope:::updateStatusToInEffect::Stack :'+ex.getStackTraceString(), 
                                                                               (listAgg[0].Id != null) ? listAgg[0].Id : null));
        }
    }
    
    /**
     * Added by Vikram Singh under CR-12375
     * Method to GET Envelope Status at DocuSign end.
     * returns status (at Docusign end) for all the envelopes in a given date range.
     */
    public static String getEnvelopeStatus(String envId) {
        String envStatus = '';
        String accessToken = UTL_Docusign.getJWTAccessToken('TPA');
        System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);
        if (!String.isEmpty(accessToken) || Test.isRunningTest() ) {
            Http httpProtocol = new Http();
            HttpRequest request1 = new HttpRequest();
            EnvResponse envRes;
            
            if(!Test.isRunningTest()) {     
                String passString = authHeader();
                String accKey = getAccountKey();
                String endpoint = getDocusignURL() + accKey + '/envelopes/' + envId;
                request1.setEndPoint(endpoint);
                request1.setMethod('GET');
                request1.setHeader('Accept', 'application/json');
                //request1.setHeader('X-DocuSign-Authentication', passString);
                request1.setHeader('grant_type', 'Bearer');
                request1.setHeader('Authorization', 'Bearer ' + accessToken);
                HttpResponse response1 = httpProtocol.send(request1);
                system.debug('####SRV_TPA_DocusignEnvelope.getEnvelopeStatus response: '+response1.getBody());    
                JSONParser parse = JSON.createParser(response1.getBody());
                EnvResponse envResp = (EnvResponse) parse.readValueAs(EnvResponse.class);
                if(response1.getStatusCode() == 200) {
                    envStatus = envResp.status;
                } else {   
                    envStatus = envResp.message;
                }
                system.debug('####SRV_TPA_DocusignEnvelope.getEnvelopeStatus status: '+envStatus);
            }
        }
        return envStatus;    
    }
}
