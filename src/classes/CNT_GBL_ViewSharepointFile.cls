/**
 * @description Controller Class for VFP_ViewSharepointFile
 */
public class CNT_GBL_ViewSharepointFile {
    public transient  String base64Value{get;set;}
    public transient String contentType{get;set;}
    public transient String fileName{get;set;}
    public Boolean isCallCompleted{get;set;}
    private String sharepointFileId;
    private String folderName;
    public String parentName{get;set;}
    private String parentId{get;set;}

    public CNT_GBL_ViewSharepointFile() {
        sharepointFileId = ApexPages.currentPage().getParameters().get('sharepointFileId');
        parentId = ApexPages.currentPage().getParameters().get('parentId');
        folderName = ApexPages.currentPage().getParameters().get('folderName');
        if(String.isNotBlank(folderName)) {
            folderName = folderName.replace(' ', '%20');
        }
        isCallCompleted = false;
        parentName = '';
    }
    
    /**
     * @description PageAction to Fetch the record from Sharepoint and set the values of controller properties
     */
    public void loadAttachment(){
        SLT_SharepointFile sltSharepointFile = new SLT_SharepointFile();
        List<Sharepoint_File__c> lstSharepointFile = sltSharepointFile.selectById(new Set<Id>{sharepointFileId});
        List<SObject> lstSObject = UTL_Sharepoint.getParentById(parentId);
        if(lstSObject.size() == 0){
            Map<String, String> parentObjectDetail = UTL_Sharepoint.getParentObjectApiName(parentId);
            parentName = parentObjectDetail.get('objName');
        }
        else{
            Sharepoint_Config__c config = UTL_Sharepoint.getSharepointConfig();
            HttpResponse res = UTL_Sharepoint.readFile(lstSharepointFile[0], config, folderName);
            if(res.getStatusCode() == 200) {
                base64Value=EncodingUtil.base64Encode(res.getBodyAsBlob());
                fileName = lstSharepointFile[0].File_Name__c;
                String fileExtension = fileName.substring(fileName.lastIndexOf('.')+1);
                if(fileExtension.endsWith('pdf')){
                    contentType='application/pdf';
                }else if(fileExtension.contains('.doc')){
                    contentType='application/vnd.ms-word';    
                }else if(fileExtension.contains('.xls')){
                    contentType='application/vnd.ms-excel';
                }else{
                    contentType='application/octet-stream';
                }    
            }
        }
        isCallCompleted = true;
    }
}