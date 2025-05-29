/**
 *   @author    : Sweta Sharma
 *   This class serves as a Service for docuisgn Signing process. (created under ER-3556 on 27/04/2017)
 */
public class SRV_CDA_DocusignStatus {

    //Public variables
    public static CDA_Settings__c settings = CDA_Settings__c.getOrgDefaults();

    //Added by Vikram Singh under CR-11764 Start
    public static Boolean isRequestorAdmin {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.REQUESTOR_ADMIN || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }
    //Added by Vikram Singh under CR-11764 End

    //Public methods
    /**
     *  Method to create and Send the Enevelope.
     *  @param cdaRequest for which we need to initiate the docusign sign process.
     */
    @future(callout = true)
    public static void createAndSendEnvelope(Id cdaRequestId) {
        try {
            CDA_Request__c cdaRequest = new CDA_Request__c();
            List < dsfs__DocuSign_Status__c > dsStatusList = new List < dsfs__DocuSign_Status__c >([select id from dsfs__DocuSign_Status__c where CDA_Request__c = :cdaRequestId]) ;
            String query = 'SELECT id, Requestor_Carbon_Copies__c, CDA_Language__c, Audit_Type__c, CDA_TYPE__C, CDA_Format__c, CDA_Source__c, Competitor_Flag__c, '+
                        'Is_Protocol_Number_Known__c, Is_Protocol_Title_Known__c, Recipient_Authorized_Signer_Email_Addres__c, Recipient_Authorized_Signer_First_Name__c, '+
                        'Recipient_Authorized_Signer_Last_Name__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Point_of_Contact_First_Name__c, '+
                        'Recipient_Point_of_Contact_Last_Name__c, Recipient_Account__r.NAME, QI_Legal_Entity_Name__r.name, CreatedBy.name, CDA_Id__c, '+
                        'Recipient_Account_Name_Formula__c, Owner.LastName, Owner.FirstName, Owner.Email , Customer_Consent_to_Disclose__c, Originating_Requestor_Flag__c, '+
                        'Originating_Requestor_First_Name__c, Originating_Requestor_Last_Name__c, Originating_Requestor_IQVIA_Email__c, Requestor_Admin_Email_Flag__c, '+
                        'Originating_Requestor_Full_Name__c, On_Behalf_of_User_Full_Name__c '+
                        'FROM CDA_Request__c '+
                        'WHERE id =\''+cdaRequestId+'\'';
            cdaRequest = Database.query(query);

            String contentTypeWithBody = '';
            Integer contentLength = 0;
            String accKey = getAccountKey();
            String contentType = '';
            String bcontent = '';
            String passString = '';
            String cheader = '';
            String envelop = '';
            String envEOF = '\r\n' + '--myBoundary--';
            String sourceId = cdaRequest.id;
            List < Attachment > att = [select id, Name, body from attachment where parentId =: sourceId ORDER BY CreatedDate DESC];
            EnvelopeDetail envDet = new EnvelopeDetail();
            if (cdaRequest.Recipient_Authorized_Signer_Email_Addres__c == null || cdaRequest.Recipient_Authorized_Signer_Email_Addres__c == '' || cdaRequest.Recipient_Authorized_Signer_Email_Addres__c == cdaRequest.Recipient_Point_of_Contact_Email_Address__c) {
                envDet.CRL = 'Email~' + cdaRequest.Recipient_Point_of_Contact_Email_Address__c + ';FirstName~' + cdaRequest.Recipient_Point_of_Contact_First_Name__c.replaceAll('[^a-zA-Z0-9\\s+]', '') + ';LastName~' + cdaRequest.Recipient_Point_of_Contact_Last_Name__c.replaceAll('[^a-zA-Z0-9\\s+]', '') + ';Role~A;RoutingOrder~1;'; //Recipient List
            } else {
                envDet.CRL = 'Email~' + cdaRequest.Recipient_Authorized_Signer_Email_Addres__c + ';FirstName~' + cdaRequest.Recipient_Authorized_Signer_First_Name__c.replaceAll('[^a-zA-Z0-9\\s+]', '') + ';LastName~' + cdaRequest.Recipient_Authorized_Signer_Last_Name__c.replaceAll('[^a-zA-Z0-9\\s+]', '') + ';Role~A;RoutingOrder~1;'; //Recipient List
                envDet.CRL = envDet.CRL + ',Email~' + cdaRequest.Recipient_Point_of_Contact_Email_Address__c + ';FirstName~' + cdaRequest.Recipient_Point_of_Contact_First_Name__c.replaceAll('[^a-zA-Z0-9\\s+]', '') + ';LastName~' + cdaRequest.Recipient_Point_of_Contact_Last_Name__c.replaceAll('[^a-zA-Z0-9\\s+]', '') + ';Role~B;RoutingOrder~2;'; //Recipient List
            }
            string carbonCopy = '';
            if (Label.CDA_Docusign_Carbon_Copy != null) {
                string parameter = '';
                String lastName = '';
                String firstName = '';
                List < string > recipientParam = new List < string > ();
                List < string > parameterList = new List < string > ();
                recipientParam = Label.CDA_Docusign_Carbon_Copy.split('\\,');
                for (String str: recipientParam) {
                    parameterList = str.split('\\;');
                    parameter = parameterList.get(0);
                    // Updated by Babita Dadarwal under Issue-11322 and Issue-11188 Start
                    if (!parameter.split('\\~').isEmpty()
                    && parameter.split('\\~').get(0) == 'Email'
                    && !((parameter.split('\\~').get(1)).equalsIgnoreCase(cdaRequest.Recipient_Authorized_Signer_Email_Addres__c))
                    && !((parameter.split('\\~').get(1)).equalsIgnoreCase(cdaRequest.Recipient_Point_of_Contact_Email_Address__c))) {
                    // Updated by Babita Dadarwal under Issue-11322 and Issue-11188 End
                        carbonCopy = carbonCopy + ',' + str;
                        continue;
                    }
                }
                // Added by Vikram Singh under CR-11764 Start
                if(isRequestorAdmin && cdaRequest.Originating_Requestor_Flag__c == UTL_CDAUtility.YES) {
                    // Originating Requestor will be copied in every email
                    if(!((cdaRequest.Originating_Requestor_IQVIA_Email__c).equalsIgnoreCase(cdaRequest.Recipient_Authorized_Signer_Email_Addres__c))
                    && !((cdaRequest.Originating_Requestor_IQVIA_Email__c).equalsIgnoreCase(cdaRequest.Recipient_Point_of_Contact_Email_Address__c))
                    && !carbonCopy.containsignorecase(cdaRequest.Originating_Requestor_IQVIA_Email__c)) {
                        carbonCopy = carbonCopy + ',Email~' + cdaRequest.Originating_Requestor_IQVIA_Email__c + ';FirstName~' + cdaRequest.Originating_Requestor_First_Name__c.replaceAll('[^a-zA-Z0-9\\s+]', '')  + ';LastName~' + cdaRequest.Originating_Requestor_Last_Name__c.replaceAll('[^a-zA-Z0-9\\s+]', '')  + ';Role~I;RoutingOrder~2;';
                    }

                    // CC Requestor Admin(Data Entry Requestor) if Requestor_Admin_Email_Flag__c flag is set to true
                    if (cdaRequest.Requestor_Admin_Email_Flag__c == UTL_CDAUtility.YES
                    && !((cdaRequest.Owner.Email).equalsIgnoreCase(cdaRequest.Recipient_Authorized_Signer_Email_Addres__c))
                    && !((cdaRequest.Owner.Email).equalsIgnoreCase(cdaRequest.Recipient_Point_of_Contact_Email_Address__c))
                    && !carbonCopy.containsignorecase(cdaRequest.Owner.Email)) {
                        carbonCopy = carbonCopy + ',Email~' + cdaRequest.Owner.Email + ';FirstName~' + cdaRequest.Owner.FirstName.replaceAll('[^a-zA-Z0-9\\s+]', '')  + ';LastName~' + cdaRequest.Owner.LastName.replaceAll('[^a-zA-Z0-9\\s+]', '')  + ';Role~I;RoutingOrder~2;';
                    }
                }
                // Added by Vikram Singh under CR-11764 End
                // Updated by Babita Dadarwal under Issue-11322 and Issue-11188 Start
                else if(cdaRequest.Requestor_Carbon_Copies__c  //Updated by Vikram Singh under CR-11764
                && !((cdaRequest.Owner.Email).equalsIgnoreCase(cdaRequest.Recipient_Authorized_Signer_Email_Addres__c))
                && !((cdaRequest.Owner.Email).equalsIgnoreCase(cdaRequest.Recipient_Point_of_Contact_Email_Address__c))
                && !carbonCopy.containsignorecase(cdaRequest.Owner.Email)) {
                // Updated by Babita Dadarwal under Issue-11322 and Issue-11188 End
                    carbonCopy = carbonCopy + ',Email~' + cdaRequest.Owner.Email + ';FirstName~' + cdaRequest.Owner.FirstName.replaceAll('[^a-zA-Z0-9\\s+]', '')  + ';LastName~' + cdaRequest.Owner.LastName.replaceAll('[^a-zA-Z0-9\\s+]', '')  + ';Role~I;RoutingOrder~2;';
                }
            }
            if (carbonCopy != null && carbonCopy != '') {
                envDet.CRL = envDet.CRL + carbonCopy;
            }
            if(dsStatusList != null && dsStatusList.size() > 0) {
                envDet.CEM = 'Updated Confidential Disclosure Agreement between ' + cdaRequest.Recipient_Account_Name_Formula__c + ' and ' + cdaRequest.QI_Legal_Entity_Name__r.name; //Email Message // Updated under by Babita Dadarwal under CR-11387
            }
            else {
                envDet.CEM = 'Confidential Disclosure Agreement between ' + cdaRequest.Recipient_Account_Name_Formula__c + ' and ' + cdaRequest.QI_Legal_Entity_Name__r.name; //Email Message
            }
            envDet.CES = cdaRequest.get('CDA_Id__c') + '- IQVIA Confidentiality Agreement - ' + cdaRequest.Recipient_Account_Name_Formula__c; //Email Subject //Updated By Babita Dadarwal Under Issue-12086
            envDet.CCRM = 'A~Signer 1;B~Carbon Copy;C~Carbon Copy1;D~Carbon Copy2;E~Carbon Copy3;F~Carbon Copy4;G~Carbon Copy5;H~Carbon Copy6;I~Carbon Copy7;'; //Recipient Role
            envDet.CCTM = 'A~Signer;B~Carbon Copy;C~Carbon Copy;D~Carbon Copy;E~Carbon Copy;F~Carbon Copy;G~Carbon Copy;H~Carbon Copy;I~Carbon Copy;'; //Recipient Type
            envDet.OCO = 'Send'; //Send Auto/manual
            if (cdaRequest.CDA_Type__c == UTL_CDAUtility.CUSTOMER) {
                envDet.RES = '1,5,5,1,60,1'; //Reminder and expiration settings
            } else {
                envDet.RES = '1,3,3,1,60,1'; //Reminder and expiration settings
            }
            envDet.SourceId = sourceId;
            passString = authHeader();
            cheader = '\r\n--myBoundary' + '\r\n' + ' Content-Type: application/json' + '\r\n' + ' Content-Disposition: form-data' + '\r\n' + '\r\n';

            envEOF = '\r\n' + '--myBoundary--';
            String generatedDocument = '';
            String customerConsentToDisclose = '';
            String auditorScopeAgenda = '';
            Map <String, String> attachmentdocIdNameMap = new Map <String, String>();
            for (Integer count = 0; count < att.size(); count++) {
                if (generatedDocument == '' && (att.get(count).name.contains(UTL_CDAUtility.EXTERNAL_DOCUMENT) || att.get(count).name.contains(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD))) { //Updated by Ajinkya Pande under Item #114
                    Blob b = att.get(count).body;
                    bcontent = EncodingUtil.base64Encode(b);
                    contentLength = contentLength + bcontent.length();
                    contentType = '\r\n--myBoundary' + '\r\n' + 'Content-Type:application/octet-stream' + '\r\n' + 'Content-Transfer-Encoding: base64' + '\r\n' + 'Content-Disposition:attachment; ' + 'filename=\"contract.pdf\";' + 'documentid=' + 1 + '\r\n\r\n\r\n';
                    generatedDocument = contentType + '\r\n' + bcontent;
                    attachmentdocIdNameMap.put('1',att.get(count).name);
                }
                if (auditorScopeAgenda  == '' && cdaRequest.CDA_Type__c == UTL_CDAUtility.AUDITOR && att.get(count).name.contains(UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE)) {
                    Blob b = att.get(count).body;
                    bcontent = EncodingUtil.base64Encode(b);
                    contentLength = contentLength + bcontent.length();
                    contentType = '\r\n--myBoundary' + '\r\n' + 'Content-Type:application/octet-stream' + '\r\n' + 'Content-Transfer-Encoding: base64' + '\r\n' + 'Content-Disposition:attachment; ' + 'filename=\"contract.pdf\";' + 'documentid=' + 3 + '\r\n\r\n\r\n';
                    auditorScopeAgenda = contentType + '\r\n' + bcontent;
                    attachmentdocIdNameMap.put('3',att.get(count).name);
                }
                if (customerConsentToDisclose == '' && cdaRequest.CDA_Type__c == UTL_CDAUtility.AUDITOR  && cdaRequest.Customer_Consent_to_Disclose__c == UTL_CDAUtility.YES  && att.get(count).name.contains(UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE)) {
                    Blob b = att.get(count).body;
                    bcontent = EncodingUtil.base64Encode(b);
                    contentLength = contentLength + bcontent.length();
                    contentType = '\r\n--myBoundary' + '\r\n' + 'Content-Type:application/octet-stream' + '\r\n' + 'Content-Transfer-Encoding: base64' + '\r\n' + 'Content-Disposition:attachment; ' + 'filename=\"contract.pdf\";' + 'documentid=' + 2 + '\r\n\r\n\r\n';
                    customerConsentToDisclose = contentType + '\r\n' + bcontent;
                    attachmentdocIdNameMap.put('2',att.get(count).name);
                }

            }
            if(cdaRequest.CDA_Type__c == UTL_CDAUtility.AUDITOR) {
                if(customerConsentToDisclose != '') {
                    contentTypeWithBody = generatedDocument + '\r\n' + customerConsentToDisclose + '\r\n' + auditorScopeAgenda;
                }
                else {
                    contentTypeWithBody = generatedDocument + '\r\n' + auditorScopeAgenda;
                }
            }
            else {
                contentTypeWithBody = generatedDocument ;
            }
            // envelop = setParametersForEnvelope(envDet , attachmentdocIdNameMap , cdaRequest.CDA_language__c , cdaRequest);   //Commented by Vikram Singh under Issue-11209
            envelop = setParametersForEnvelope(envDet , attachmentdocIdNameMap , 'English' , cdaRequest);   //Added by Vikram Singh under Issue-11209
            String accessToken = UTL_Docusign.getJWTAccessToken('CDA');
            if(!String.isEmpty(accessToken) || Test.isRunningTest()){
            	Http httpProtocol = new Http();
            	HttpRequest request = new HttpRequest();
            	String endpoint = getDocusignURL() + accKey + '/envelopes';
            	request.setEndPoint(endpoint);
            	request.setMethod('POST');
            	request.setHeader('Accept', 'application/json');
            	//request.setHeader('X-DocuSign-Authentication', passString);
            	request.setHeader('grant_type', 'Bearer');
                request.setHeader('Authorization', 'Bearer ' + accessToken);
            	request.setHeader('content-type', 'multipart/form-data;boundary=myBoundary');
            	request.setHeader('content-length', String.valueOf(contentLength));
            	//Body
            	request.setBody(cheader + '' + envelop + '\r\n' + contentTypeWithBody + '\r\n' + envEOF);
            	request.setTimeout(120000); // Added by C.P.Pandey under Issue-11579
            	UTL_EnvResponse envstat;
            	HttpResponse response1 = httpProtocol.send(request);
            	JSONParser parse = JSON.createParser(response1.getBody());
            	envstat = (UTL_EnvResponse) parse.readValueAs(UTL_EnvResponse.class);
            	sendEnvelope(envstat.envelopeId);
            }
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject('', 'Exception Occurred in SRV_CDA_DocusignStatus : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
        }

    }

    //Private methods

    /**
     *    Method to set the authentication Header
     */
    private static String authHeader() {
        return '<DocuSignCredentials>' + '<Username>' + settings.Docusign_Username__c + '</Username>' + '<Password>' + settings.Docusign_Password__c + '</Password>' + '<IntegratorKey>' + settings.Integration_Key__c + '</IntegratorKey>' + '</DocuSignCredentials>';
    }

    /**
     *   Method to set the Docusign URL.
     */
    public static String getDocusignURL() {
        String url = settings.Docusign_URL__c;
        return url;
    }

    /**
     *   Method to set the Parameter in Enevelope to be send for signature by Docusign.
     *   @param envDet Docusign Envelope Instance.
     *   @param list of all attachments of Request.
     *   @param language of generated Document used to select branding template.
     */
    private static String setParametersForEnvelope(EnvelopeDetail envDet, Map < String , string > attachmentdocIdNameMap , String language, CDA_Request__c cdaRequest) {

        string recipients = '';
        string currentRecipient = '';
        recipients = envDet.CRL;

        List < string > recipientList = recipients.split('\\,');
        integer recipientLength = recipientList.size();
        JSONGenerator gen = JSON.createGenerator(true);

        //Start JSON Content
        gen.writeStartObject();
        gen.writeStringField('status', 'created');
        gen.writeStringField('emailBlurb', envDet.CEM);
        gen.writeStringField('emailSubject', envDet.CES);
        gen.writeStringField('AutoNavigation', 'true');
        gen.writeStringField('EnvelopeIdStamping', 'true');
        gen.writeStringField('AuthoritativeCopy', 'false');

        if (UTL_CDAUtility.multiLingualTemplateSettingsMap.containsKey('Docusign Branding' + language)) {
            gen.writeStringField('brandId', UTL_CDAUtility.multiLingualTemplateSettingsMap.get('Docusign Branding' + language).Template_Id__c);
        }

        //document
        gen.writeFieldName('documents');
        gen.writeStartArray();
        List < String > keyList = new List < String >();
        Set < String > keySet = new Set < String >();
        keySet = attachmentdocIdNameMap.keySet();
        keyList.addAll( keySet );
        keyList.sort();
        for ( String docId : keyList ) {
                gen.writeStartObject();
                gen.writeStringField('documentId',docId);
                gen.writeStringField('name',attachmentdocIdNameMap.get(docId));
                gen.writeEndObject();
        }

        gen.writeEndArray();
        //end of doc

        //start notifications
        gen.writeFieldName('notification');
        gen.writeStartObject();
        gen.writeStringField('useAccountDefaults', 'false');

        //start reminders
        gen.writeFieldName('reminders');
        gen.writeStartObject();
        gen.writeObjectField('reminderEnabled', 'true');
        if (cdaRequest.CDA_Type__c == UTL_CDAUtility.CUSTOMER) {
            gen.writeObjectField('reminderDelay', '5');
            gen.writeObjectField('reminderFrequency', '5');
        } else {
            gen.writeObjectField('reminderDelay', '3');
            gen.writeObjectField('reminderFrequency', '3');
        }
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
        UTL_Recipient recipientObj;

        if (recipientLength > 1) {
            for (integer jCount = 1; jCount < recipientLength; jCount++) {
                currentRecipient = recipientList[jCount];
                recipientObj = new UTL_Recipient(currentRecipient, jCount + 1);
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

        currentRecipient = recipientList[0];
        recipientObj = new UTL_Recipient(currentRecipient, 1);
        gen.writeStartObject();
        gen.writeObjectField('email', recipientObj.email);
        gen.writeObjectField('name', recipientObj.name);
        gen.writeObjectField('recipientId', recipientObj.recipientId);
        gen.writeObjectField('routingOrder', recipientObj.routingOrder);

        //start tab
        gen.writeFieldName('tabs');
        gen.writeStartObject();
        //start sign here
        gen.writeFieldName('signHereTabs');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('anchorString', '\\s1\\');
        gen.writeObjectField('anchorXOffset', '0');
        gen.writeObjectField('anchorYOffset', '0');
        gen.writeObjectField('anchorIgnoreIfNotPresent', 'true');
        gen.writeObjectField('anchorUnits', 'inches');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeFieldName('titleTabs');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('anchorString', '\\t1\\');
        gen.writeObjectField('anchorIgnoreIfNotPresent', 'true');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeFieldName('fullNameTabs');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('anchorString', '\\n1\\');
        gen.writeObjectField('anchorIgnoreIfNotPresent', 'true');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeFieldName('initialHereTabs');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('anchorString', '\\i1\\');
        gen.writeObjectField('anchorIgnoreIfNotPresent', 'true');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeFieldName('dateSignedTabs');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('anchorString', '\\d1\\');
        gen.writeObjectField('anchorIgnoreIfNotPresent', 'true');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        //end tab
        gen.writeEndObject();
        gen.writeEndArray();
        //end signers
        gen.writeEndObject();
        //end recipient
        gen.writeEndObject();
        //end JSON Content
        return gen.getAsString();
    }

    /**
     *   Method to set Docusign Account Id.
     */
    private static String getAccountKey() {
        String accKey = settings.Docusign_Account_Id__c;
        return accKey;
    }

    /**
     * Method to send the Envelope by REST API.
     * @param envelope id to send by rest API.
     */
    private static void sendEnvelope(string envId) {

        JSONGenerator gen;
        String accessToken = UTL_Docusign.getJWTAccessToken('CDA');
        if(!String.isEmpty(accessToken) || Test.isRunningTest()){
        	Http httpProtocol = new Http();
        	HttpRequest request2 = new HttpRequest();
        	String body = '';
        	String accKey = getAccountKey();
        	String endpoint = getDocusignURL() + accKey + '/envelopes/' + envid;

        	request2.setEndPoint(endpoint);
        	request2.setMethod('PUT');
        	request2.setHeader('Accept', 'application/json');
        	request2.setHeader('grant_type', 'Bearer');
            request2.setHeader('Authorization', 'Bearer ' + accessToken);
        	gen = JSON.createGenerator(true);
        	gen.writeStartObject();
        	gen.writeStringField('status', 'sent');
        	gen.writeEndObject();
        	body = gen.getAsString();

        	request2.setBody(body);
        	request2.setTimeout(120000); // Added by C.P.Pandey under Issue-11579
        	HttpResponse response2 = httpProtocol.send(request2);
        }
    }

    /**
     * Method to void Envelope .
     * @Param envId Envelope Id to which we need to void.
     * voidReason void Reson for any envelope.
     */
    public static void voidEnvelope(String envId, String voidReason) {

        JSONGenerator gen;
        String accessToken = UTL_Docusign.getJWTAccessToken('CDA');
        if(!String.isEmpty(accessToken)|| Test.isRunningTest()){
        	Http httpProtocol = new Http();
        	HttpRequest request2 = new HttpRequest();
        	String body = '';
        	String accKey = getAccountKey();
        	String endpoint = getDocusignURL() + accKey + '/envelopes/' + envid;
        	request2.setEndPoint(endpoint);
        	request2.setMethod('PUT');
        	request2.setHeader('Accept', 'application/json');
        	request2.setHeader('grant_type', 'Bearer');
            request2.setHeader('Authorization', 'Bearer ' + accessToken);
        	gen = JSON.createGenerator(true);
        	gen.writeStartObject();
        	gen.writeStringField('status', 'voided');
        	gen.writeStringField('voidedReason', voidReason);
        	gen.writeEndObject();
        	body = gen.getAsString();
        	request2.setBody(body);
        	request2.setTimeout(120000); // Added by C.P.Pandey under Issue-11579
        	HttpResponse response2 = httpProtocol.send(request2);
        }
    }

    /**
     * Before INSERT
     * This method is called for VOID THE PREVIOUS ENVELOPE.
     * @param CDAId set from CDA Request.
     */
    public static void setVoidToDocusignEnvelope(Set < String > cdaIdSet) {
        List < dsfs__DocuSign_Status__c > listDocusignToBeVoid = new List < dsfs__DocuSign_Status__c > ();
        List<String> cdaIdsList = new List<String>();
        for(String id: cdaIdSet){
            cdaIdsList.add(id);
        }

        String dsQry = 'SELECT CDA_Request__c, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c '+
                    'FROM dsfs__DocuSign_Status__c '+
                    'WHERE dsfs__Envelope_Status__c != \'Completed\' '+
                    'AND dsfs__Envelope_Status__c != \'Voided\' '+
                    'AND dsfs__Envelope_Status__c != \'Declined\' '+
                    'AND dsfs__Envelope_Status__c != \'Expired\' '+
                    'AND CDA_Request__r.CDA_Id__c IN (\''+String.join(cdaIdsList, '\',\'')+'\')';

        listDocusignToBeVoid = Database.query(dsQry);

        Set < Id > docusignSatusIdToVoid = new Set < Id > ();

        for (dsfs__DocuSign_Status__c objDSStatus: listDocusignToBeVoid) {
            docusignSatusIdToVoid.add(objDSStatus.id);
        }

        if (docusignSatusIdToVoid != null && docusignSatusIdToVoid.size() > 0) {
            BCH_CDA_VoidEnvelope batchObj = new BCH_CDA_VoidEnvelope();
            batchObj.setStatusIds(docusignSatusIdToVoid);
            Database.executeBatch(batchObj, 1);
        }
    }

    /**
     * Function to check the split document FOR WET SIGN , update attachment name for wet sign case and cda Request update as well.
     * @param cdaRequestId CDA Request Id .
     * @param envId Envelope id of docusign status for CDA REQUEST.
     */
    @future(callout = true)
    public static void splitSignedDocument(String cdaRequestId, String envId) {
        try {
            CDA_Request__c cdaRequest = new CDA_Request__c();
            List < Attachment > attachmentToDeleteList = new List < Attachment > ();
            Attachment attachmentToInsert;
            cdaRequest = [Select id, Status_Completion_Date__c, Date_executed_signed_contract_received__c, Customer_Signed_Date__c, Status__c, Name, CDA_Language__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Negotiator_Assigned__c, Owner.Email, Requestor_Carbon_Copies__c, (select id, name from Attachments order by createddate desc), Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Requestor_Admin_Email_Flag__c from CDA_Request__c where id =: cdaRequestId];    //Updated by Vikram Singh under Issue-11834
            Map < id, CDA_Request__c > cdaRequests = new Map < id, CDA_Request__c > ();
            cdaRequests.put(cdaRequest.id, cdaRequest);
            String accessToken = UTL_Docusign.getJWTAccessToken('CDA');
            if(!String.isEmpty(accessToken) || Test.isRunningTest()){
            	Http httpProtocol = new Http();
            	HttpRequest request2 = new HttpRequest();
            	String endpoint = getDocusignURL() + getAccountKey() + '/envelopes/' + envId + '/documents';
            	request2.setEndPoint(endpoint);
            	request2.setMethod('GET');
            	request2.setHeader('Accept', 'application/json');
            	request2.setHeader('grant_type', 'Bearer');
                request2.setHeader('Authorization', 'Bearer ' + accessToken);
            	HttpResponse response2;
                if(!Test.isRunningTest()){
            	    response2 = httpProtocol.send(request2);
                }else{
                    response2 = new HttpResponse();
                    response2.setBody('{"envelopeId": "37A2A639-E9EF-4FD3-A390-3E6621897CD9","envelopeDocuments": [{"documentId": "1","name": "Test_1.pdf","type": "content","uri": "/envelopes/37A2A639-E9EF-4FD3-A390-3E6621897CD9/documents/1","order": "1","pages": "1"}]}');
                }
            	UTL_DocumentParser obj = (UTL_DocumentParser) JSON.deserialize(response2.getBody(), UTL_DocumentParser.class);
            	Boolean isWetSignDocPresent = false;
            	for (UTL_DocumentProperties doc: obj.envelopeDocuments) {
                	if (doc.name.contains(UTL_CDAUtility.SIGNED_ON_PAPER)) {
                    	isWetSignDocPresent = true;
                    	String endpoint2 = endpoint+'/'+doc.documentId;
                    	HttpRequest request3 = new HttpRequest();
                    	request3.setEndPoint(endpoint2);
                    	request3.setMethod('GET');
                    	request3.setHeader('Accept', 'application/json');
                    	request3.setHeader('grant_type', 'Bearer');
                		request3.setHeader('Authorization', 'Bearer ' + accessToken);
                    	HttpResponse response3 = httpProtocol.send(request3);
                    	attachmentToInsert = new Attachment ();
                    	attachmentToInsert.name = doc.name;
                    	attachmentToInsert.body = response3.getBodyAsBlob();
                    	attachmentToInsert.ParentId = cdaRequestId;
                    	break;
                	}
            	}
            	if (isWetSignDocPresent) {
                	cdaRequest.Status__c = UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE;    //Updated by Vikram Singh under Item #254
                	cdaRequest.Negotiator_Assigned_List__c = UTL_CDAUtility.NEGO_NOT_ASSIGN;
                	for (Attachment att: cdaRequest.Attachments) {
                    	if (att.name.contains('Completed')) {
                        	attachmentToInsert.name = UTL_CDAUtility.SIGNED_ON_PAPER+'-'+att.name;
                        	attachmentToDeleteList.add(att);
                        	break;
                    	}
                	}
                	List < String > ccAddress = new List < String > ();
                	ccAddress.add(UTL_CDAUtility.NegoMailBox);
                	SRV_CDA_CDARequest.sendCdaNotification(cdaRequests, UTL_CDAUtility.NEGO_ASSIGNED, ccAddress, UTL_CDAUtility.EMAIL_RESPONSE_RECEIVED);
            	} else {
                	cdaRequest.Status__c = UTL_CDAUtility.STATUS_CONTRACTEXECUTED;
                	cdaRequest.Status_Completion_Date__c = System.now();
                	cdaRequest.Date_executed_signed_contract_received__c = System.now();
                	cdaRequest.Customer_Signed_Date__c = System.now();
                	string devEmails = UTL_CDAUtility.devEmails;
                	List < string > ccAddress = devEmails.split(';');
                	SRV_CDA_CDARequest.sendCdaNotification(cdaRequests, UTL_CDAUtility.RECIPIENT, ccAddress, UTL_CDAUtility.EMAIL_RECIPIENT_EXC8_CONFIRM);
                	SRV_CDA_CDARequest.sendCdaNotification(cdaRequests, UTL_CDAUtility.REQUESTOR, ccAddress, UTL_CDAUtility.EMAIL_REQ_EXCU8_AGGR_RECVD);
            	}
            	if (attachmentToDeleteList != null && attachmentToDeleteList.size() > 0) {
                	delete attachmentToDeleteList;
            	}
            	if (attachmentToInsert != null) {
                	insert attachmentToInsert;
            	}
            	if (cdaRequest != null) {
                	update cdaRequest;
            	}
            }
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequestId, 'Exception Occurred in splitSignedDocument : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
        }
    }

    /**
     * Inner Class to hold info of all recipient.
     */
    private class UTL_Recipient {
        String email;
        String name;
        String recipientId;
        String routingOrder;

        public UTL_Recipient(String recipient, integer count) {
            setRecipientParameters(recipient, count);

        }
        private void setRecipientParameters(String recipient, integer count) {
            string parameter = '';
            String lastName = '';
            String firstName = '';
            List < string > recipientParam = new List < string > ();
            List < string > parameterList = new List < string > ();
            recipientParam = recipient.split('\\;');
            for (integer iCount = 0; iCount < recipientParam.size(); iCount++) {
                parameter = recipientParam[iCount];
                parameterList = parameter.split('\\~');
                if (parameter.contains('Email')) {
                    email = parameterList[1];
                }
                if (parameter.contains('FirstName')) {
                    firstName = parameterList[1];
                }
                if (parameter.contains('LastName')) {
                    lastName = parameterList[1];
                    name = firstName + ' ' + lastName;
                }
                if (parameter.contains('Role')) {
                    recipientId = string.valueof(count);
                }
                if (parameter.contains('RoutingOrder')) {
                    routingOrder = '1';
                }
            }
        }
    }

    /**
     * Inner Class UTL_EnvResponse Data Class
     */
    private class UTL_EnvResponse {
        String envelopeId;
        String status;
        String statusDateTime;
        String uri;
    }

    /**
     *  Inner Class UTL_DocumentParser Data Class for documents of envelope.
     */
    public class UTL_DocumentParser {
        public String envelopeId;
        public List < UTL_DocumentProperties > envelopeDocuments;
    }

    /**
     *  Inner Class UTL_DocumentProperties Data Class for properties of documents .
     */
    public class UTL_DocumentProperties {
        public String documentId;
        public String name;
        public String type;
        public String uri;
        public String order;
        public String pages;
        public String signerMustAcknowledge;
        public String display;
        public String includeInDownload;
    }
}
