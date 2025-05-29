global class CNT_TPA_SelectTemplate {
    public string templateType;
    public string templateKeyword;
    public string recId;
    
    public string usecase {get; set;}
    public TPA_Request__c objTpaRequest {get; set;}
    public boolean hasError {get; set;}
    public boolean isLegalEntityPresent {get; set;}
    public boolean isDocumentGenerated {get; set;}
    public string outputFormat {get; set;}
    public List<Apttus__APTS_Template__c> templates {get; set;}
    public string selectedTemplateId {get; set;}
    public List<TPA_Additional_Term__c> lstTpaAdditionalTerm {get; set;}

    public CNT_TPA_SelectTemplate() {
        isLegalEntityPresent = true;
    }
    
    public string jsonlstTpaAdditionalTerm {
        get {
            if(lstTpaAdditionalTerm != null) {
                jsonlstTpaAdditionalTerm = JSON.serialize(lstTpaAdditionalTerm);
            }
            return jsonlstTpaAdditionalTerm;
        }
        set;
    }

    public boolean hasTemplates {
        get {
            if(hasTemplates == null) {
                hasTemplates = false;
            }
            return hasTemplates;
        } 
        set;
    }
    public List<String> getDocFormatList {
        get {
            if(getDocFormatList == null) {
                getDocFormatList = new List<String>();
		if(templateKeyword != 'TPA Agreement')
                	getDocFormatList.add('DOC');                
                getDocFormatList.add('DOCX');                
                getDocFormatList.add('PDF');
            }
            return getDocFormatList;
        }
        set;
    }
    
    public void initLightning() {
        templateType = ApexPages.currentPage().getParameters().get('templateType');
        templateKeyword = ApexPages.currentPage().getParameters().get('templateKeyword');
        recId = ApexPages.currentPage().getParameters().get('id');
        if(templateType.length() > 0) {
            usecase = UTL_TPA.capitalizeWords(templateKeyword) + ' Documents';
            templates = [Select Id, Name, Apttus__Guidance__c, Apttus__Category__c, Apttus__Subcategory__c FROM Apttus__APTS_Template__c WHERE Apttus__Type__c =: templateType AND Apttus__Keywords__c =: templateKeyword AND Apttus__IsActive__c = TRUE ORDER BY Name];
            if(templates!= null && templates.size() > 0) {
                hasTemplates = true;
            }
        }
        
        if(String.isNotBlank(recId)) {
            objTpaRequest = [Select Id, Name, (select id from IMS_Legal_Entities__r),
                            (Select id, Data_Asset__c,IMSLegalEntity__c From Data_Assets__r) 
                             From TPA_Request__c where Id =: recId];
            isLegalEntityPresent = checkifLegalEntityPresent(objTpaRequest);
        }
        lstTpaAdditionalTerm = [Select Id, Name From TPA_Additional_Term__c where TPA_Request__c =: recId];
    }

    public boolean checkifLegalEntityPresent( TPA_Request__c reqObj){

        Boolean discrOfLegalEntityPresent = false;
        Map<Id,List<TPA_Secondary_Data_Asset__c>> mapAssetIdWithSecAssetList = new Map<Id,List<TPA_Secondary_Data_Asset__c>>();
        List<TPA_Data_Asset__c> lstPAssetWithSecAssets = [select id,name,IMSLegalEntity__c,Request__c, (select id,Secondary_Asset_Name__c,IMS_Legal_Entity__c,IMS_Secondary_Data_Asset__r.IMS_Legal_Entity__c from TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c where Request__c =: reqObj.id];

        for(TPA_Data_Asset__c tpaDataAssetSO : lstPAssetWithSecAssets){
            mapAssetIdWithSecAssetList.put(tpaDataAssetSO.id,tpaDataAssetSO.TPA_Secondary_Data_Assets__r);
        }
        if(objTpaRequest.IMS_Legal_Entities__r == null || objTpaRequest.IMS_Legal_Entities__r.size() == 0){
          return false;
        }
        else{
            for(TPA_Data_Asset__c tpaDataAssetSO : reqObj.Data_Assets__r){
                if(mapAssetIdWithSecAssetList.get(tpaDataAssetSO.id) != null && mapAssetIdWithSecAssetList.get(tpaDataAssetSO.id).size() > 0){
                    
                    for(TPA_Secondary_Data_Asset__c tpaSecDataAssetSO : mapAssetIdWithSecAssetList.get(tpaDataAssetSO.id)){
                        if(tpaSecDataAssetSO.IMS_Legal_Entity__c == null ){
                             return false;
                        }
                    }
                }
                else if(tpaDataAssetSO.IMSLegalEntity__c == null ){
                    return false;
                }


            }

        }
         return true;
    }
    
    @remoteAction
    global static string generateDocument(string request) {
        if(request != null && request.length() > 0) {
            try{
                requestDetails reqDetailObj = (requestDetails)JSON.deserialize(request, requestDetails.class);
                string adminUser = UTL_TPA.userNameContract;
                string adminUserPwd = UTL_TPA.passwordContract;
                string sessionId = UTL_TPA_Class_LoginAPI.login(adminUser, adminUserPwd);
                string serverUrl = UTL_TPA_Class_LoginAPI.serverUrl;
                boolean isDisplayWatermark = false;
                boolean isHelpfulHintsAddendumRequired = false;
                if(UTL_TPA.tpaSetting.Is_Template_Watermark_Automated__c) {
                    isDisplayWatermark = UTL_TPA.isSandboxOrg;
                }
                string docId = Apttus.MergeWebService.generateCustomDoc(reqDetailObj.templateId, reqDetailObj.requestId, 'TPA_Request__c', 'Full access', reqDetailObj.docFormat, isDisplayWatermark, sessionId, serverUrl);
                if(reqDetailObj.templateKeyword == 'TPA Agreement'){
                    isHelpfulHintsAddendumRequired = true;
                    system.debug('isHelpfulHintsAddendumRequired1'+isHelpfulHintsAddendumRequired);
                }
                SRV_TPA_TPARequest.updateActivityHistory(reqDetailObj.requestId,'Generated '+reqDetailObj.templateKeyword,true);
                
                return 'Document has got created successfully.';
            } catch(Exception ex) {
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_SelectTemplate.generateDocument:::Document generation Failed', '');
                return ex.getMessage();
            }
        }
        return 'Request detail is not correct::' + request;
    }
    
    public class requestDetails {
        public String templateId {get; set;}
        public String requestId {get; set;}
        public String docFormat {get; set;}
        public String templateKeyword {get; set;}
        
    }
}
