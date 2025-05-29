/**
* This class is created to authenticate the Docusign Application
*/
public class CNT_APTMS_DocuSignAccountSetting{
    public static final String SYSTEM_PROPERTIES ='System_Properties';
    public static final String SYSTEM_PROPERTIES_LABEL ='System Properties';
    public static final String STR_ENCRYPT_BLOB_VALUE ='12345678901234567890123456789012';
    public static final String STR_DEFAULT = 'Default';
    public static final String CS_SYSTEM_PROPERTIES = 'System Properties'; 
    public static final String USER_EMAIL_URL_STR = '/users?email=';
    public static final String BEARER_STR = 'bearer ';
    public static final String RESTAPI_STR = '/restapi/v2/accounts/';
    
    public CNT_APTMS_DocuSignAccountSetting(){         
    }
    
    /**
     * This method returns docusign auth data list
     * @return List<DocuSign_Auth_Data__c>
    */
    @AuraEnabled
    public static List <DocuSign_Auth_Data__c> fetchDocusignData() {
        List<DocuSign_Auth_Data__c> docuSignDataList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetails
            (new Set<String>{'Id', 'User_Name__c', 'Account_Id__c', 'Client_Id__c'}, null);
        return docuSignDataList;
    }
        
    /**
     * This method insert Docusign Auth Data
     * @params String packagedString
     * @return Boolean
    */ 
    @AuraEnabled
    public static boolean insertDocusignAuthData(String packagedString){
        Map<String, String> unpackedMap = new Map<String, String>();
        String tempKey, tempValue;
        JSONParser parsedMap = JSON.createParser(packagedString);
        while(parsedMap.nextToken() != null) {
            if(parsedMap.getCurrentToken() == JSONToken.FIELD_NAME) {
                tempKey = parsedMap.getText();
                parsedMap.nextToken();
                tempValue = parsedMap.getText();
                unpackedMap.put(tempKey, tempValue);
            }
        }
        List<DocuSign_Auth_Data__c> docuSignDataList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId
            (new Set<String>{'Id'}, unpackedMap.get('name'), 1);
        if(docuSignDataList.size() > 0){
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    DocuSign_Auth_Data__c.SObjectType
                }
            );
            uow.registerDeleted(docuSignDataList[0]);
            uow.commitWork();
        }        
        DocuSign_Auth_Data__c docuSignAuthData = new DocuSign_Auth_Data__c();
        	docuSignAuthData.User_Name__c = unpackedMap.get('userEmail');
            docuSignAuthData.Name = unpackedMap.get('name');
        	docuSignAuthData.DocusignUser_Id__c = unpackedMap.get('userName');
            docuSignAuthData.Client_Id__c = unpackedMap.get('clientId');
            docuSignAuthData.Account_Id__c = unpackedMap.get('accountId');
            docuSignAuthData.Base_URL__c = unpackedMap.get('baseURL');
        	docuSignAuthData.Private_Key__c = unpackedMap.get('privateKey');
        	docuSignAuthData.Public_Key__c = unpackedMap.get('publicKey');
            docuSignAuthData.Expire_After__c = decimal.valueOf(unpackedMap.get('expireAfter'));
            docuSignAuthData.Expire_Warn__c = decimal.valueOf(unpackedMap.get('expireWarn'));
            docuSignAuthData.Reminder_Delay__c = decimal.valueOf(unpackedMap.get('reminderDelay'));
            docuSignAuthData.Reminder_Frequency__c = decimal.valueOf(unpackedMap.get('reminderFrequency'));
        	fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    DocuSign_Auth_Data__c.SObjectType
                }
            );
            uow.registerNew(docuSignAuthData);
            uow.commitWork();
    		return true;
    }
	
    /**
     * This method validates Docusign sign Admin User
     * @params String accountId, String userEmail
    */
    @AuraEnabled
    public static ESignatureResponseWrapper getUserInfoBeforeInserting(String accountId, String userEmail){
        List<DocuSign_Auth_Data__c > docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId
            (new Set<String>{'Id', 'Base_URL__c', 'Account_Id__c', 'Name'}, accountId, null);
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0];
        List<DocuSign_Auth_Data__c> dAuthData = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId
            (new Set<String>{'User_Name__c', 'Name'}, accountId, 1);
        String sendAsUserEmail = dAuthData.get(0).User_Name__c;
        String authCode = CNT_APTMS_DocuSignESignature.getJWTAccessToken(docuSignIntegrationSettings.Name,sendAsUserEmail,true);
        HttpResponse response = CNT_APTMS_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, RESTAPI_STR+docuSignIntegrationSettings.Account_Id__c+USER_EMAIL_URL_STR+userEmail, 'GET', BEARER_STR+AuthCode, null, sendAsUserEmail);
        if(response.getStatusCode() == 401){
			authCode = CNT_APTMS_DocuSignESignature.getJWTAccessToken(docuSignIntegrationSettings.Name,sendAsUserEmail,true);
            response = CNT_APTMS_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, RESTAPI_STR+docuSignIntegrationSettings.Account_Id__c+USER_EMAIL_URL_STR+userEmail, 'GET', BEARER_STR+AuthCode, null, sendAsUserEmail);
        }
        if (response.getStatusCode() == 200) {
            return new ESignatureResponseWrapper('TRUE', CON_CLM.STATUS_SUCCESS, '');
        }
        else {
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(),
            ResponseErrorWrapper.class);
            String errorList = resError.errorCode + ' : '+resError.error + ',';
            return new ESignatureResponseWrapper('FALSE', CON_CLM.STATUS_FAILED, errorList);  
        }
    }
    
    public class ResponseErrorWrapper {        
        public String errorCode {get; set;}
        public String message {get; set;}
        public String error {get; set;}
    }
    
    public class ESignatureResponseWrapper {
        @AuraEnabled
        public String batchId {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String message {get; set;}
        
        public ESignatureResponseWrapper(String batchId, String status, String message) {
            this.batchId = batchId;
            this.status = status;
            this.message = message;
        }
    }	
    
    public class DocuSignUserWrapper {
        public List<Users> users;
        public String resultSetSize;
        public String totalSetSize;
        public String startPosition;
        public String endPosition;
    }
    
    public class Users {
        @AuraEnabled
        public String userId {get; set;}
        @AuraEnabled
        public String email {get; set;}
        public Users(users user){
            this.userId = user.userId;
            this.email = user.email;
        }
    }
}