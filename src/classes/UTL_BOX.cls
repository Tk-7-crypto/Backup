public class UTL_BOX {
    public static box.Toolkit toolkit = new box.Toolkit();
    public static List<String> lstBoxException = new List<String>();
    
    /*
    * This method is used to copy all files and folders from source to destination in box 
    * @param String sourceFolderId
    * @param String destinationFolderId
    * @param String folderName
    * @return String
    */
    public static String copyAllFoldersAndFilesFromSourceToDestination(String sourceFolderId, String destinationFolderId, String folderName) {
        Box_End_Point__c boxEndPoint = Box_End_Point__c.getOrgDefaults();
        String idFolderCreated = null;
        Parent parentObject = new Parent();
        parentObject.id = destinationFolderId;
        FolderWrapper wrapper = new FolderWrapper();
        wrapper.name = folderName;
        wrapper.parent = parentObject;
        String endpoint = boxEndPoint.End_Point_for_Folders__c +'/folders/'+sourceFolderId+'/copy/';
        System.debug('endPoint : '+ endPoint);
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
                System.debug('response : '+ response);
            }
            if(response !=null && response.getStatusCode() == 201) {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                if(result != null && !result.isEmpty() && result.containsKey('id')) {
                    idFolderCreated = (String)result.get('id');
                }
            }
            else if(response !=null && response.getStatusCode() != 201) {
                lstBoxException.add('Source Folder Id '+ sourceFolderId + ' : Copy API Error : ' + response.getStatusCode()+ ' response = '+response);                
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            lstBoxException.add('Source Folder Id '+sourceFolderId + ' : Copy API Exception : ' + UTL_GLOBAL.concatenateException(e));
        }
        return idFolderCreated;
    }
    
    /*
    * This method is used to delete entire folders and files with the help of box folderId
    * @param String folderId
    * @return Boolean
    */
    public static Boolean deleteAllFilesAndFolders(String folderId) {
        Boolean isDeleted = false;
        Box_End_Point__c boxEndPoint = Box_End_Point__c.getOrgDefaults();
        String endpoint = boxEndPoint.End_Point_for_Folders__c + '/folders/' + folderId + '?recursive=true';
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
                lstBoxException.add('Folder Id to delete '+folderId + ' : Delete API Error : ' + response.getStatusCode()+ ' response = '+response);    
                isDeleted = false;
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            lstBoxException.add('Folder Id to delete '+folderId + ' : Delete API Exception : ' + UTL_GLOBAL.concatenateException(e));
        }
        return isDeleted;
    }
    
    public class FolderWrapper {
        public String name;
        public Parent parent;
    }
    
    public class Parent {
        public String id;
    }

}