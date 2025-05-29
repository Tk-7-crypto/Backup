/**
* Version     : 1.0
* Description : Apex Utility class for Box Migration CLM. 
*/ 
public class UTL_CLM_Box {
    public static box.Toolkit toolkit = new box.Toolkit();
    public static List<String> lstBoxException = new List<String>();

    /*
    * This method is used to get the total number of folders and files with the help of box folderId
    * @param String folderId
    * @return Integer
    */
    public static Integer getTotalFolderCount(String folderId) {
        Integer totalCount = 0;
        CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
        String endpoint = configuration.Box_End_Point__c + '/folders/' + folderId;
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setTimeout(120000);
            request.setEndpoint(endpoint);
            HttpResponse response;
            if(Test.isRunningTest()) {
                response = new Http().send(request);
            }
            else {
                response = toolkit.sendRequest(request);
            }
            if(response != null && response.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                if(result != null && !result.isEmpty() && result.containsKey('item_collection')) {
                    Map<String, Object> itemCollectionMap = (Map<String, Object>)result.get('item_collection');
                    totalCount = itemCollectionMap.containsKey('total_count') ? (Integer)itemCollectionMap.get('total_count') : 0; 
                }
            }
            else if(response !=null && response.getStatusCode() != 200) {
                lstBoxException.add(folderId + '===Count API Error===' + response.getStatusCode() + ' response = '+response);                
            }
        }
        catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            lstBoxException.add(folderId + '===Count API Exception===' + UTL_CLM.concatenateException(e));
        }
        return totalCount;
    }

    /*
    * This method is used to copy all files and folders from source to destination in box 
    * @param String sourceFolderId
    * @param String destinationFolderId
    * @param String folderName
    * @return String
    */
    public static String copyAllFoldersAndFilesFromContractToAgreement(String sourceFolderId, String destinationFolderId, String folderName) {
        CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
        String idFolderCreated = null;
        Parent parentObject = new Parent();
        parentObject.id = destinationFolderId;
        FolderWrapper wrapper = new FolderWrapper();
        wrapper.name = folderName;
        wrapper.parent = parentObject;
        String endpoint = configuration.Box_End_Point__c +'/folders/'+sourceFolderId+'/copy/';
        try {   
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setTimeout(120000);
            request.setEndpoint(endpoint);
            request.setBody(JSON.serialize(wrapper));
            HttpResponse response;
            if(Test.isRunningTest()) {
                response = new Http().send(request);
            }
            else {
                response = toolkit.sendRequest(request);
            }
            if(response !=null && response.getStatusCode() == 201) {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                if(result != null && !result.isEmpty() && result.containsKey('id')) {
                    idFolderCreated = (String)result.get('id');
                }
            }
            else if(response !=null && response.getStatusCode() != 201) {
                lstBoxException.add(sourceFolderId + '===Copy API Error===' + response.getStatusCode()+ ' response = '+response);                
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            lstBoxException.add(sourceFolderId + '===Copy API Exception===' + UTL_CLM.concatenateException(e));
        }
        return idFolderCreated;
    }
    
    public class FolderWrapper {
        public String name;
        public Parent parent;
    }
    
    public class Parent {
        public String id;
    }
 
    /*
    * This method is used to delete entire folders and files with the help of box folderId
    * @param String folderId
    * @return Boolean
    */
    public static Boolean deleteAllFilesAndFolders(String folderId) {
        Boolean isDeleted = false;
        CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
        String endpoint = configuration.Box_End_Point__c + '/folders/' + folderId + '?recursive=true';
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod('DELETE');
            request.setTimeout(120000);            
            request.setEndpoint(endpoint);
            HttpResponse response;
            if(Test.isRunningTest()) {
                response = new Http().send(request);
                isDeleted = true; 
            }
            else {
                response = toolkit.sendRequest(request);
            }
            if(response != null && response.getStatusCode() == 204) {
                isDeleted = true; 
            }
            else if(response != null && response.getStatusCode() != 204) {
                lstBoxException.add(folderId + '===Delete API Error===' + response.getStatusCode()+ ' response = '+response);    
                isDeleted = false;
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            lstBoxException.add(folderId + '===Delete API Exception===' + UTL_CLM.concatenateException(e));
        }
        return isDeleted;
    }
}