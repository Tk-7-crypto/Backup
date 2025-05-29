public with sharing class CNT_PEP_SendToDocusign {
    private final Contract contract; 
    
    public static String envelopeId {get;set;} 
   
    
    private static String accountId; 
    private static String userId;
    private static String password;
    private static String integratorsKey;
    private static String domainName;
    private static String emailSubject;
    private static String emailBlurb;     
    @testVisible private static String testJSONData;
       
    @testvisible static List<Contract> testContract;
    @testvisible private static List<Contract> getContractById(String contractId) {
        List<Contract> con;
        if(test.isRunningTest()) {
            con = testContract;
        } else {
            con = [Select Id,Account.Id,Account.Name,Name,DocuSign_Envelope_Id__c, 
            Date_executed_signed_contract_received__c,BillingAddress,StartDate,Agency_Program__c From Contract Where Id=:contractId Limit 1];
        }
        
        return con;
    }
    
    @testvisible private static List<Contract> getContractByAccountId(List<Contract> mainCon) {
        List<Contract> con;
        if(test.isRunningTest()) {
            con = testContract;
        } else {
            con = [Select Date_executed_signed_contract_received__c,StartDate From Contract where Account.Id =:mainCon[0].Account.Id and PRM_Contract_type__c='Master Agency Agreement' AND Status='Active' LIMIT 1];
        }
        
        return con;
    }
    
    @testVisible private static void updateContract(List<Contract> mainCon) {
        if(!test.isRunningTest()) {
            update mainCon;
        }
    }
    @testVisible private static Boolean envelopeCreationSuccess;
    //Added by Hammad Siddiqui
    public static String SendNow_WithRest(Boolean signSOWonline,String contractId, String templateId)
    {
        String dateExecuted='';
        
                
        List<Contract> mainCon  = getContractById(contractId);
        List<Agency_Program_Financials__c> apfPrice=new List<Agency_Program_Financials__c>();
        List<Agency_Program_Financials__c> apfAddress=new List<Agency_Program_Financials__c>();
        
        if(mainCon.size() > 0){
            Id userInfos=UserInfo.getUserId();
            List<User> usersList =   new SLT_User().selectAccountIdByUser(userInfos);
            Set<String> fieldSet=new Set<String>{'AccountCountry__c'};
            List<Account> acc=new SLT_Account().getAccountCountry(fieldSet, usersList[0].AccountId);
            Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
            Id agencyProgramFinancialsAddress = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Address').getRecordTypeId();
            if(acc.size()>0)
            {
                String relatedAgencyId=mainCon[0].Agency_Program__c;
                String country=acc[0].AccountCountry__c;
                apfPrice=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetails(agencyProgramFinancialsPrice, relatedAgencyId, country);
                
                if(apfPrice.size()<=0)
                {
                    apfPrice=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetailsDefault(agencyProgramFinancialsPrice, relatedAgencyId);
                }
                
                apfAddress= new SLT_Agency_Program_Financials().getAgencyProgramFinancialsAddress(agencyProgramFinancialsAddress,country);
                
                if(apfAddress.size()<=0)
                {
                    apfAddress=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsAddressDefault(agencyProgramFinancialsAddress);
                }
            }
            List<Contract> conDate=getContractByAccountId(mainCon);
            
            if(conDate.size() > 0){
                DateTime dt=conDate[0].StartDate;
                
                if(dt != null){
                    dateExecuted= dt.formatGMT('dd MMM YYYY');
                }
            }
        }
        
        PEP_DocuSign_credentials__c docuSignCredentials = PEP_DocuSign_credentials__c.getInstance();
        accountId = docuSignCredentials.AccountId__c;
        userId = docuSignCredentials.UserId__c;
        password = docuSignCredentials.Password__c;
        integratorsKey = docuSignCredentials.IntegratorsKey__c;
        domainName = docuSignCredentials.Domain_Name__c;
        emailSubject = docuSignCredentials.Email_Subject__c + ' ' + mainCon[0].Name;
        emailBlurb = docuSignCredentials.Email_Content__c;
        
        system.debug('Entered in the SendNow_WithRest');
        String docuSign_BaseEndPoint = docuSignCredentials.DocusignBaseEndpoint__c; //'https://demo.docusign.net/restapi/v2/accounts/'; //Need to be changed for the Production org
        String authorizationHeader = '<DocuSignCredentials><Username>'+userId+'</Username><Password>'+password+'</Password><IntegratorKey>'
            +integratorsKey
            +'</IntegratorKey></DocuSignCredentials>';
        
        
        //Create Envelope at DocuSign End
        String recepientUser_Name = UserInfo.getName(); //This user will be added as a recepient in the request body Hammad Siddiqui
        String recepientUser_EmailId = UserInfo.getUserEmail(); //hammad.siddiqui@metacube.com'
        String embeddedSigner_URL; //return URL
      
        String envelopeCreation_Endpoint = docuSign_BaseEndPoint + accountId + '/envelopes';
        
        String envelopeBody='';
        if(apfPrice.size()>0 && apfAddress.size()>0){
            if(signSOWonline){
                envelopeBody  = '{"accountId":"'+accountId+'", "emailSubject": "'+emailSubject+'", "emailBlurb": "'+emailBlurb+'", "templateId": "'+templateId+'", "envelopeIdStamping":"false","templateRoles": [ { "email": "'+recepientUser_EmailId+'","clientUserId":"1001", "name": "'+recepientUser_Name+'", "roleName": "Generic Signer","recipientId":"1","tabs": { "textTabs": [{ "tabLabel": "IQVIALegalAddress", "value": "'+apfAddress[0].IQVIA_Invoicing_Address__c+'" },{ "tabLabel": "IQVIAEntityName1", "value": "'+apfAddress[0].IQVIA_Invoicing_Entity_Name__c+'" },{ "tabLabel": "IQVIAEntityName2", "value": "'+apfAddress[0].IQVIA_Invoicing_Entity_Name__c+'" },{ "tabLabel": "SecondLabel", "value": "" },{ "tabLabel": "MAADate", "value": "'+dateExecuted+'" },{ "tabLabel": "AgencyName", "value": "'+mainCon[0].Account.Name+'"},{ "tabLabel": "AgencyAddress", "value": ""},  {"tabLabel": "City", "value": ""},{"tabLabel": "State", "value": ""},{"tabLabel": "Country", "value": ""},{"tabLabel": "PostalMail","value": "'+apfAddress[0].Postal_Mail__c+'"},{"tabLabel": "IQVIAInvoicingEntityName","value": "'+apfAddress[0].IQVIA_Invoicing_Entity_Name__c+'"},{"tabLabel": "OvernightMail","value": "'+apfAddress[0].Overnight_Mail__c+'"},{"tabLabel": "ElectronicPayment","value": "'+apfAddress[0].Electronic_Payment__c+'"},{"tabLabel": "ACHPayment","value": "'+apfAddress[0].ACH_Payment__c+'"},{"tabLabel": "Fedwire","value": "'+apfAddress[0].Fedwire__c+'"},{"tabLabel": "SwiftBICCode","value": "'+apfAddress[0].SWIFT_BIC_Code__c+'"},{"tabLabel": "Currency","value": "'+apfPrice[0].CurrencyIsoCode+'"},{"tabLabel": "Price","value": "'+apfPrice[0].Price__c+'"},{"tabLabel":"IQVIATIN","value": "'+apfAddress[0].IQVIA_TIN__c+'"}] } } ], "status": "sent" }';   
            }
            else
            { 
                envelopeBody  = '{"accountId":"'+accountId+'", "emailSubject": "'+emailSubject+'", "emailBlurb": "'+emailBlurb+'", "templateId": "'+templateId+'", "envelopeIdStamping":"false","templateRoles": [ { "email": "'+recepientUser_EmailId+'", "name": "'+recepientUser_Name+'", "roleName": "Generic Signer","tabs": { "textTabs": [ { "tabLabel": "IQVIALegalAddress", "value": "'+apfAddress[0].IQVIA_Invoicing_Address__c+'" },{ "tabLabel": "IQVIAEntityName1", "value": "'+apfAddress[0].IQVIA_Invoicing_Entity_Name__c+'" },{ "tabLabel": "IQVIAEntityName2", "value": "'+apfAddress[0].IQVIA_Invoicing_Entity_Name__c+'" },{ "tabLabel": "SecondLabel", "value": "" },{ "tabLabel": "MAADate", "value": "'+dateExecuted+'" },{ "tabLabel": "AgencyName", "value": "'+mainCon[0].Account.Name+'"},{ "tabLabel": "AgencyAddress", "value": ""},  {"tabLabel": "City", "value": ""},{"tabLabel": "State", "value": ""},{"tabLabel": "Country", "value": ""},{"tabLabel": "ZipCode","value": ""},{"tabLabel": "PostalMail","value": "'+apfAddress[0].Postal_Mail__c+'"},{"tabLabel": "IQVIAInvoicingEntityName","value": "'+apfAddress[0].IQVIA_Invoicing_Entity_Name__c+'"},{"tabLabel": "OvernightMail","value": "'+apfAddress[0].Overnight_Mail__c+'"},{"tabLabel": "ElectronicPayment","value": "'+apfAddress[0].Electronic_Payment__c+'"},{"tabLabel": "ACHPayment","value": "'+apfAddress[0].ACH_Payment__c+'"},{"tabLabel": "Fedwire","value": "'+apfAddress[0].Fedwire__c+'"},{"tabLabel": "SwiftBICCode","value": "'+apfAddress[0].SWIFT_BIC_Code__c+'"},{"tabLabel": "Currency","value": "'+apfPrice[0].CurrencyIsoCode+'"},{"tabLabel": "Price","value": "'+apfPrice[0].Price__c+'"},{"tabLabel":"IQVIATIN","value": "'+apfAddress[0].IQVIA_TIN__c+'"}] } } ], "status": "sent" }'; 
            }
        }      
        system.debug('envelopeBody============='+envelopeBody);
        
        HttpRequest createEnvelope_Rquest = new HttpRequest();
        createEnvelope_Rquest.setEndpoint(envelopeCreation_Endpoint);
        createEnvelope_Rquest.setMethod('POST');
        createEnvelope_Rquest.setHeader('X-DocuSign-Authentication', authorizationHeader); 
        createEnvelope_Rquest.setHeader('Accept','application/json');
        createEnvelope_Rquest.setHeader('Content-Length','162100'); 
        createEnvelope_Rquest.setHeader('Content-Type','application/json');
        createEnvelope_Rquest.setHeader('Content-Disposition','form-data');
        createEnvelope_Rquest.setBody(envelopeBody); 
      
        Http httpRequestClient = new Http();
        
        HTTPResponse envelopeCreation_Response;
        try
        {
            
            envelopeCreation_Response = httpRequestClient.send(createEnvelope_Rquest); 
            
            
            if( envelopeCreation_Response.getStatusCode() == 200 ||envelopeCreation_Response.getStatusCode() == 201)
            {
                
                String uriRe, envelope_id;
                String signer_ReturnURL = domainName + '/partner/s/contract/'+ contractId; //Need to create a custom label for the domain name;
                uriRe = jsonParser(envelopeCreation_Response.getBody(), 'uri');
                envelope_id = jsonParser(envelopeCreation_Response.getBody(), 'envelopeId');
               
                mainCon[0].DocuSign_Envelope_Id__c = envelope_id.touppercase();

                //Request for The Embedded Signer URL
                HttpRequest signerReq = new HttpRequest();
                String signerEndPoint = docuSign_BaseEndPoint + accountId + uriRe + '/views/recipient';
                JSONGenerator signerReq_Body = JSON.createGenerator(true);
                signerReq_Body.writeStartObject();
                signerReq_Body.writeStringField('userName', recepientUser_Name);
                signerReq_Body.writeStringField('email', recepientUser_EmailId);
                signerReq_Body.writeStringField('clientUserId', '1001');
                signerReq_Body.writeStringField('returnUrl',signer_ReturnURL); 
                signerReq_Body.writeStringField('authenticationMethod','email');
                signerReq_Body.writeStringField('recipientId','1');
                signerReq_Body.writeEndObject();
               // system.debug('signerEndPoint->' + signerEndPoint);
                signerReq.setHeader('X-DocuSign-Authentication', authorizationHeader); 
                signerReq.setHeader('Accept','application/json');
                
                signerReq.setHeader('Content-Type','application/json');
                signerReq.setHeader('Content-Disposition','form-data');
                signerReq.setMethod('POST');
                signerReq.setEndpoint(signerEndPoint);                
              
                String signerRequest_Body;
                if(signSOWonline==true){
                    signerRequest_Body='{"userName": "'+recepientUser_Name+'","clientUserId": "1001","email": "'+recepientUser_EmailId+'","recipientId": "1","authenticationMethod": "email","returnUrl": "'+ signer_ReturnURL +'"}';
                }
                else {
                    signerRequest_Body='{"userName": "'+recepientUser_Name+'","email": "'+recepientUser_EmailId+'","authenticationMethod": "email","returnUrl": "'+ signer_ReturnURL +'"}';
                }
                signerReq.setBody(signerRequest_Body);
                HTTPResponse signerRequest_Response = new HTTPResponse();
              
                signerRequest_Response = httpRequestClient.send(signerReq);
                envelopeCreationSuccess=True;
              
                if(signerRequest_Response.getStatusCode() == 200 || signerRequest_Response.getStatusCode() == 201)
                {
                    embeddedSigner_URL = jsonParser(signerRequest_Response.getBody(), 'url'); // The Embedded Signer URL that can be opened in the iFrame or in a new Window
                  
                   updateContract(mainCon);
 
                    
                }   
            }
            
            
        }
        catch(Exception e){
            system.debug('Exception Occurred:' + e.getMessage());
        }
        return embeddedSigner_URL;
    }
    //Parsing the JsonResponse : Added by Hammad SIddiqui
    private static String jsonParser(String jsonBody, String wantedParam)
    {
        JSONParser parser = JSON.createParser(jsonBody);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
                if (fieldName == wantedParam) {
                    return parser.getText();
                }
            }
        }
        return '';
    }
    
}