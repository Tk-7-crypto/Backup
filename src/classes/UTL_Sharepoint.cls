/**
 * Utility Class to perform actions on Sharepoint Server
 * 1. Sharepoint Authentication
 * 2. Create Folder, Delete Folder
 * 3. View, Create or Delete File
 */
public class UTL_Sharepoint{
    private static String tanentId;
    private static String resource;
    private static String accessTokenUrl;
    @testVisible
    private static String accessTokenVal;
    @testVisible
    private static String formDigestValue;
    private static String authenticateHeader;
    private static String siteUrl;
    private static String listName;

    static{
        accessTokenUrl = 'https://accounts.accesscontrol.windows.net/{tanentId}/tokens/OAuth/2';
        authenticateHeader = '/_vti_bin/client.svc/';
    }

    /**
     * setInitials To set the initials for sharepoint
     * @param  config Object of Sharepoint_Config__c custom setting
     */
    @testVisible
    private static void setInitials(Sharepoint_Config__c config){
        siteUrl = (config.Is_Https__c?'https':'http')+'://' + config.Site_Url__c;
        listName = config.List_Name__c.replace(' ', '%20');
        setPreRequisites(config);
        accessTokenVal = getAccessToken(config);
        formDigestValue = getFormDigest(config);
    }

    /**
     * setPreRequisites To Set the tanentId and resource to access the Sharepoint Site
     * @param  config Object of Sharepoint_Config__c custom setting
     * @exception UTL_Sharepoint_Exception If no tanentId and resource found
     */
    private static void setPreRequisites(Sharepoint_Config__c config) {
        String token;
        String authenticateHeaderUrl = siteUrl +  authenticateHeader;
        token = getWWWAuthenticateHeader(authenticateHeaderUrl);
        if(String.isNotBlank(token)){
            String headerData = token.split(' ')[1];
            List<String> lstString = new List<String>();
            Matcher pm = Pattern.compile('".*?"').matcher(headerData);
            while(pm.find()){
                lstString.add(pm.group().replace('"',''));
            }
            if(lstString.size() > 0){
                tanentId = lstString[0];
                resource = lstString[1];
            }
        }
        if(String.isBlank(tanentId) || String.isBlank(resource)){
            throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_No_tanent_Id_and_Resource_found_for_Sharepoint_Site});
        }
    }
    
    /**
     * getWWWAuthenticateHeader to get the WWW-Authenticate value
     * @param  endpointUrl Url for Authentication
     * @return String Value for WWW-Authenticate
     * @exception throws UTL_Sharepoint_Exception when CalloutException occur
     */
    private static String getWWWAuthenticateHeader(String endpointUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndPoint(endpointUrl);
        req.setmethod('GET');
        req.setHeader('Authorization','Bearer');
        req.setTimeout(120000);
        HttpResponse res ;            
        try {
            res = new Http().send(req);
            return res.getHeader('WWW-Authenticate');
        }catch(Exception e) {
            throw new UTL_Sharepoint_Exception(new List<String>{e.getMessage()});
        }
    }
    
    /**
     * urlEncode To encode the Url values
     * @param  vals Map of Values to encode
     * @return Return the encoded value
     */
    private static String urlEncode(Map<String, String> vals) {
        String result = '';
        for(String thisKey : vals.keySet()) {
            result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(vals.get(thisKey), 'UTF-8') + '&';
        }
        return result.removeEnd('&');    
    }
    
    /**
     * getAccessToken To get the AccessToken using sharepoint rest api
     * @param  config object of Sharepoint_Config__c custom setting
     * @return String value of access_token
     * @exception throws UTL_Sharepoint_Exception when  accessToken is blank or CalloutException occur
     */
    private static String getAccessToken(Sharepoint_Config__c config){
        String accessTokenSite = config.Site_Url__c.split('/', 2)[0];
        accessTokenUrl = accessTokenUrl.replace('{tanentId}', tanentId);
        HttpResponse res = null;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accessTokenUrl);
        req.setMethod('POST');
        req.setHeader('Authorization','Bearer');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        Map<String,String> requestBody = new Map<String, String>();
        requestBody.put('grant_type','client_credentials');
        requestBody.put('client_id',config.Client_Id__c + '@' + tanentId);
        requestBody.put('client_secret',config.Client_Secret__c);
        requestBody.put('resource',resource + '/' + accessTokenSite + '@' + tanentId);
        req.setBody(urlEncode(requestBody));
        try{    
            res = new Http().send(req);
        }
        catch(Exception e){
            throw new UTL_Sharepoint_Exception(new List<String>{e.getMessage()});
        }
        if(res != null){
            AccessToken objAccessToken = (AccessToken)JSON.deserialize(res.getBody(), AccessToken.class);
            return objAccessToken.access_token;
        }
        throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_No_Access_Token_Found});
    }
    
    /**
     * getFormDigest To Fetch the FormDigest Value which will be need with Files and Folder Operations
     * @param  config Object of Sharepoint_Config__c custom setting
     * @return String value of FormDigest
     */
    private static String getFormDigest(Sharepoint_Config__c config){
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteUrl + '/_api/contextinfo');
        req.setHeader('Accept', 'application/json; odata=verbose');
        req.setHeader('Authorization','Bearer ' + accessTokenVal);
        req.setHeader('Content-Length','0');
        req.setMethod('POST');
        try{
            res = new Http().send(req);
        }catch(CalloutException ce){
            throw ce;
        }
        String resBody = res.getBody();
        Map<String, Object> mapResBody = (Map<String, Object>) JSON.deserializeUntyped(resBody);
        mapResBody = (Map<String, Object>)mapResBody.get('d');
        mapResBody = (Map<String, Object>)mapResBody.get('GetContextWebInformation');        
        return String.valueOf(mapResBody.get('FormDigestValue'));
    }

    /**
     * To Create Folder on Sharepoint Documents folder
     * @param  Name of Folder (Salesforce Id of Record)
     * @param  Custom Setting Sharepoint_Config Object
     * @return ServerRelativeUrl where in sharepoint documents the folder has been created
     */
    public static String createFolder(String folderName, Sharepoint_Config__c config) {
        if(config == null)
            throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_Invalid_Argument_for_Sharepoint_Config});

        setInitials(config);
        String reqBody = '{\'__metadata\': {\'type\':\'SP.Folder\'},\'ServerRelativeUrl\':\'' + listName + '/' + folderName + '\'}';
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();
        req.setEndpoint(siteUrl + '/_api/web/folders');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessTokenVal);
        req.setHeader('Content-Type', 'application/json;odata=verbose');
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('X-RequestDigest', formDigestValue);
        req.setHeader('Content-Length', String.valueOf(reqBody.length()));
        req.setBody(reqBody);
        try {
            res = new Http().send(req);
        }
        catch(Exception e) {
            throw new UTL_Sharepoint_Exception(new List<String>{e.getMessage()});
        }
        if(res.getStatusCode() == 201) {
            Map<String, Object> parsedResBody = (Map<String, Object>) JSON.deserializeUntyped(EncodingUtil.urlDecode(res.getBody(),'UTF-8'));
            parsedResBody = (Map<String, Object>) parsedResBody.get('d');
            return String.valueOf(parsedResBody.get('ServerRelativeUrl'));
        }
        return null;
    }

    /**
     * To Delete the File from Sharepoint
     * @param  fileUrl ServerRelative Url for Sharepoint File
     * @param  Custom Setting: Sharepoint_Config Object
     */ 
    public static HttpResponse deleteFolder(String  folderName, Sharepoint_Config__c config){
        if(config == null)
            throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_Invalid_Argument_for_Sharepoint_Config});
        setInitials(config);
        List<String> site = config.Site_Url__c.split('/', 2);
        String folderUrl = '';
        if(site.size() > 1){
            folderUrl = site[1]+'/'+listName;
        }else{
            folderUrl = listName;
        }
        Map<String, String> objectDetail = getParentObjectApiName(folderName);
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();
        req.setEndpoint(siteUrl + '/_api/web/GetFolderByServerRelativeUrl(\''+listName+'/'+objectDetail.get('objName')+'/' + folderName + '\')');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessTokenVal);
        req.setHeader('X-RequestDigest',formDigestValue);
        req.setHeader('IF-MATCH','*');
        req.setHeader('X-HTTP-Method','DELETE');
        req.setHeader('Content-Length','0');
        try{
            res = new Http().send(req);
        }catch(Exception e){
            throw new UTL_Sharepoint_Exception(new List<String>{e.getMessage()});
        }
        return res;
    }

    /**
     * To Create File on Sharepoint Documents Folder
     * @param  List of FileInstance which need to be created on Sharepoint
     * @param  Custom Setting: Sharepoint_Config Object
     * @return ServerRelativeUrl: where in sharepoint documents the folder has been created
     */
    public static FileInstance createFile(FileInstance objFileInstance, Sharepoint_Config__c config) {
        if(config == null)
            throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_Invalid_Argument_for_Sharepoint_Config});
        setInitials(config);
        Map<String, String> objectDetail = getParentObjectApiName(objFileInstance.parentId);
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();
        String path = listName +'/' + objectDetail.get('objName') + '/' + objFileInstance.parentId;
        if(String.isNotBlank(objFileInstance.folderName)) {
            path = listName + '/' + objectDetail.get('objName') + '/' + objFileInstance.parentId + '/' + objFileInstance.folderName;
        }
        req.setEndpoint(siteUrl + '/_api/web/GetFolderByServerRelativeUrl(\'' + path + '\')/Files/add(url=\'' + EncodingUtil.UrlEncode(objFileInstance.fileName, 'UTF-8') + '\',overwrite=true)');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessTokenVal);
        req.setHeader('Content-Type', 'application/json;odata=verbose');
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('X-RequestDigest', formDigestValue);
        req.setHeader('Content-Length', String.valueOf(objFileInstance.fileLength));
        req.setBodyAsBlob(objFileInstance.fileBody);
        try {
            res = new Http().send(req);
        }
        catch(Exception e) {
            throw e;
        }
        if(res.getStatusCode() == 200) {
            Map<String, Object> parsedResBody = (Map<String, Object>) JSON.deserializeUntyped(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'));
            parsedResBody = (Map<String, Object>) parsedResBody.get('d');
            objFileInstance.fileUrl = String.valueOf(parsedResBody.get('ServerRelativeUrl'));
            return objFileInstance;
        }
        else{
            throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_Error_In_Creating_File});
        }
    }

    /**
     * To Read the File from Sharepoint
     * @param  fileUrl ServerRelative Url for Sharepoint File
     * @param  Custom Setting: Sharepoint_Config Object
     * @param folderName will have the name of folder where file exists if user is saving in a folder otherwise it will be blank
     */ 
    public static HttpResponse readFile(Sharepoint_File__c objSPFile, Sharepoint_Config__c config, String folderName) {
        if(config == null)
            throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_Invalid_Argument_for_Sharepoint_Config});
        setInitials(config);
        List<String> site = config.Site_Url__c.split('/', 2);
        String folderUrl = '';
        if(site.size() > 1){
            folderUrl = site[1] + '/' + listName;
        }else{
            folderUrl = listName;
        }
         
        Map<String, String> objectDetail = getParentObjectApiName(objSPFile.Parent_Id__c);
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();
        String fileContainer = objSPFile.Parent_Id__c;
        if(String.isNotBlank(folderName)) {
            fileContainer = objSPFile.Parent_Id__c + '/' + folderName;
        }
        
        req.setEndpoint(siteUrl + '/_api/web/GetFileByServerRelativeUrl(\'/' + folderUrl + '/' + objectDetail.get('objName') + '/' 
            + fileContainer + '/' + EncodingUtil.UrlEncode(objSPFile.File_Name__c, 'UTF-8') + '\')/$value');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessTokenVal);
        try{
            res = new Http().send(req); 
        }
        catch(Exception e){
            throw new UTL_Sharepoint_Exception(new List<String>{e.getMessage()});
        }
        return res;
    }

    /**
     * To Delete the File from Sharepoint
     * @param parentId is the agreement id.
     * @param fileName is the name of sharepoint file
     * @param config is the sharepoint custom setting
     * @param folderName is the name of folder from where files are being deleted from sharepoint.
     */ 
    public static HttpResponse deleteFile(String  parentId, String fileName, 
        Sharepoint_Config__c config, String folderName) {
        if(config == null)
            throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_Invalid_Argument_for_Sharepoint_Config});
        
        setInitials(config);
        List<String> site = config.Site_Url__c.split('/', 2);
        String folderUrl = '';
        if(site.size() > 1) {
            folderUrl = site[1] + '/' + listName;
        } else {
            folderUrl = listName;
        }
        String fileContainer = parentId;
        if(String.isNotBlank(folderName)) {
            fileContainer = parentId + '/' + folderName.replace(' ', '%20');
        }
        Map<String, String> objectDetail = getParentObjectApiName(parentId);
        HttpRequest req = new HttpRequest();  
        HttpResponse res = new HttpResponse();
        req.setEndpoint(siteUrl + '/_api/web/GetFileByServerRelativeUrl(\'/' + folderUrl + '/' 
            + objectDetail.get('objName') + '/' + fileContainer + '/' + EncodingUtil.UrlEncode(fileName,'UTF-8') + '\')');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessTokenVal);
        req.setHeader('X-RequestDigest',formDigestValue);
        req.setHeader('IF-MATCH','*');
        req.setHeader('X-HTTP-Method','DELETE');
        req.setHeader('Content-Length','0');
        try{
            res = new Http().send(req);
        }catch(Exception e){
            throw new UTL_Sharepoint_Exception(new List<String>{e.getMessage()});
        }
        return res;
    }

    /**
     * To fetch the Parent of Sharepoint_File
     * @param recordId Parent Record Id
     * @return sObject
     */
    public static List<SObject> getParentById(Id recordId){
        String objectName  = recordId.getSObjectType().getDescribe().getName();
        String query = String.format('SELECT {0} FROM {1} WHERE {2}',new List<String>{'Name', objectName, 'ID = \'' + recordId + '\''});
        try{
            return Database.query(query);
        }catch(Exception e){
            throw new UTL_Sharepoint_Exception(new List<String>{e.getMessage()});
        }
    }

    /**
     * To fetch the Api Name of Parent Object
     * @param recordId Parent Record Id
     * @return Map<String, String>
     */
    public static Map<String, String> getParentObjectApiName(Id recordId){
        Map<String, String> mapParentObjectDetail = new Map<String, String>();
        mapParentObjectDetail.put('objName',recordId.getSObjectType().getDescribe().getName());
        mapParentObjectDetail.put('objLabel',recordId.getSObjectType().getDescribe().getLabel());
        return mapParentObjectDetail;
    }
    
    /**
     * To Delete the Related Files When Parent Gets Delete
     * @param List<Id> lstParentId List of Parent Id
     */
    @future(callout=true)
    public static void deleteRelatedFilesOnParentDeletion(Set<Id> setParentId){
        Sharepoint_Config__c config = UTL_Sharepoint.getSharepointConfig();
        SLT_SharepointFile sltSharepointFile = new SLT_SharepointFile();
        List<Sharepoint_File__c> lstSharepointFile = sltSharepointFile.getSharepointFileByParentId(setParentId, 0);
        setParentId.clear();
        for(Sharepoint_File__c objSharepointFile : lstSharepointFile){
            if(!setParentId.contains(objSharepointFile.Parent_Id__c)){
                setParentId.add(objSharepointFile.Parent_Id__c);
            }
        }
        if(!Test.isRunningTest()){
            for(Id folderName : setParentId){
                deleteFolder(folderName, config);
            }
        }
        if(lstSharepointFile.size() > 0){
            deleteFileRecord(lstSharepointFile);
        }
    }

    public static Boolean deleteRelatedFile(List<Sharepoint_File__c> lstSharepointFile, String folderName) {
        Sharepoint_Config__c config = UTL_Sharepoint.getSharepointConfig();
        if(!Test.isRunningTest()) {
            for(Sharepoint_File__c objSharepointFile : lstSharepointFile) {
                deleteFile(objSharepointFile.Parent_Id__c, objSharepointFile.File_Name__c, config, folderName);
            }
        }
        return deleteFileRecord(lstSharepointFile);
    }

    private static Boolean deleteFileRecord(List<Sharepoint_File__c> lstSharepointFile){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Sharepoint_File__c.SObjectType
            }
        );
        try {
            uow.registerDeleted(lstSharepointFile);
            uow.commitWork();
        }catch(Exception e) {
            List<String> lstErrorMsg = new List<String>();   
            if(e.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < e.getNumDml(); i++) {
                    lstErrorMsg.add(e.getDmlMessage(i));
                }
            }
            else {
                lstErrorMsg.add(e.getMessage() + ' ' + e.getStackTraceString());
            }

            throw new UTL_Sharepoint_Exception(lstErrorMsg);
        }
        return true;
    }
    
    /**
     * To fetch the default Sharepoint Configuration from Sharepoint Config Setting
     * @return Record of Custom Setting: Sharepoint_Config
     */
    public static Sharepoint_Config__c getSharepointConfig(){
        return getSharepointConfig('CLM');
    }

    /**
     * To fetch the module wise Sharepoint Configuration from Sharepoint Config Setting
     * @param  moduleName Name of Module for Which we want to fetch the setting
     * @return Record of Custom Setting: Sharepoint_Config
     * @exception SPException if No Setting found in Custom Setting: Sharepoint_Config
     */
    public static Sharepoint_Config__c getSharepointConfig(String moduleName){
        List<Sharepoint_Config__c> lstConfig = new List<Sharepoint_Config__c>();
        lstConfig = [SELECT
                     Id,Client_Id__c,Client_Secret__c,Site_Url__c,Is_Https__c,List_Name__c
                     FROM Sharepoint_Config__c 
                     WHERE Module__c =: moduleName];
        if(lstConfig.size() > 0){
            return lstConfig[0];
        }
        throw new UTL_Sharepoint_Exception(new List<String>{Label.CLM_CL0004_No_Setting_found_with_Module_Name + ' : ' + moduleName});
    }
    /**
     * Exception Class for Sharepoint
     */
    public class UTL_Sharepoint_Exception extends Exception {
        List<String> lstError = new List<String>();

        public UTL_Sharepoint_Exception(List<String> lstError){
            this.lstError = lstError;
        }
    }

    /**
     * Wrapper for getting Access Token
     */
    public class AccessToken{
        public String token_type;
        public String expires_in;
        public String not_before;
        public String expires_on;
        public String resource;
        public String access_token;
    }

    public class FileInstance{
        public String fileName;
        public Blob fileBody;
        public Integer fileLength;
        public String parentId;
        public String fileUrl;
        public String folderName;
    }
}