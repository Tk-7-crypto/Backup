/**
 * @description Controller for LXC_GBL_FileRelatedList Lightning Component
 * @author arun.jain@metacube.com
 */
public class CNT_GBL_FileRelatedList {
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String RECORDS_PARAM = 'records';
    public static final String PARENT_OBJECT_NAME = 'parentObjectName';
    public static final String PARENT_OBJECT_LABEL = 'parentObjectLabel';
    public static final String PARENT_RECORD = 'parentRecord';
    public static final String FOLDER_NAME = 'folderName';

    /**
     * @description Method to Init Data when lightning component init method called.
     * @param  jsonData String Request JSON with parameters
     * @return JSON String of Response Map.
     * @exception throws AuraHandledException On Exception occur to Notify Ligthning Component
     */
    @AuraEnabled
    public static String initData(String jsonData) {
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        String recordId = (String)root.get(RECORD_ID_PARAM);
        Integer numberOfRecords = Integer.valueOf(root.get(NUMBER_OF_RECORDS_PARAM));
        Map<String, Object> responseMap = new Map<String, Object>();
        String parentRecordName = getParentRecordName(recordId);
        Map<String,String> mapParentDetail = UTL_Sharepoint.getParentObjectApiName(recordId);
        try {
            if(root.containsKey(FOLDER_NAME)) {
                String folderName = (String)root.get(FOLDER_NAME);
                String condition = 'File_Url__c LIKE \'%/' + recordId + '/' + folderName + '/%\'';
                if(folderName.contains(',')) {
                    List<String> folders = folderName.split(',');
                    for(Integer i = 0; i < folders.size(); i++) {
                        if(i == 0) {
                            condition = 'File_Url__c LIKE \'%/' + recordId + '/' + folders.get(i) + '/%\'';
                        } else {
                            condition += ' OR File_Url__c LIKE \'%/' + recordId + '/' + folders.get(i) + '/%\'';
                        }
                    }
                }
                responseMap.put(RECORDS_PARAM, SRV_GBL_SharepointFile.getSharepointFilesByParentIdAndFolder(
                    new Set<Id>{recordId}, numberOfRecords, condition));
            } else {
                responseMap.put(RECORDS_PARAM, SRV_GBL_SharepointFile.getSharepointFilesByParentId(
                    new Set<Id>{recordId}, numberOfRecords));
            }
            responseMap.put(PARENT_RECORD, parentRecordName);
            responseMap.put(PARENT_OBJECT_NAME, mapParentDetail.get('objName'));
            responseMap.put(PARENT_OBJECT_LABEL,mapParentDetail.get('objLabel'));
        } catch(Exception e) {
            throw new AuraHandledException(JSON.serialize(e));
        }
        return JSON.serialize(responseMap);
    }
    
    /**
     * @description Method to Delete the Sharepoint_File__c Record
     * @param  recordId Id Record Id for Sharepoint_File__c
     * @param folderName is the folder from where files will be deleted.
     * @return True if record Delete Successfully, else False
     * @exception throws AuraHandledException On Exception occur to Notify Ligthning Component
     */
    @AuraEnabled
    public static Boolean deleteRecord(Id recordId, String folderName) {
        try {
            return SRV_GBL_SharepointFile.deleteRecord(new Set<Id>{recordId}, folderName);
        } catch(Exception e) {
            throw new AuraHandledException(JSON.serialize(e));
        }
    }
    
    /**
     * @description Method to Get the Parent Record Name
     * @param  recordId Id Parent Record Id
     * @return Name Field Value of Parent Object Record
     */
    @AuraEnabled
    public static String getParentRecordName(Id recordId){
        List<SObject> lstSObject = UTL_Sharepoint.getParentById(recordId);
        if(lstSObject.size() == 0){
            return '';
        }
        return String.valueOf(lstSObject[0].get('Name'));
    }
}