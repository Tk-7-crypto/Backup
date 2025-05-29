public class CNT_TPA_Additional_Terms {

    //Map of all the ad-hoc additional terms for a TPA request
    //Key : Id of additional term
    //Value : TPA_Additional_Term__c Object record
    public Static Map<Id, TPA_Additional_Term__c> additionalTermsMap {get; set;}
    public Static Map<Id, Id> addHocIdWithAttchsId {get; set;}
    public static boolean showExhibitPage {get{
        if(showExhibitPage == null){
            showExhibitPage = TPA_Settings__c.getOrgDefaults().Show_Exhibit_Input__c;
        }
        return showExhibitPage;
    } set;}


    public static List<TPA_Request__c> tpaRequestList =  new List<TPA_Request__c>();
    public static TPA_Request__c tparequest;
    public static List<IMS_Legal_Entity__c> legalEmtityList = new List<IMS_Legal_Entity__c>();
    public static List<TPA_Data_Asset__c> priOfferingList = new List<TPA_Data_Asset__c>();
    public static List<TPA_Secondary_Data_Asset__c> secOfferingList = new List<TPA_Secondary_Data_Asset__c>();
    
    public static Boolean isGlobalUser {
        get {
            if(isGlobalUser == null){
                List<Id> groupMemberId = UTL_TPA.getIdOfMembersOfGroup();
                if(groupMemberId != null && groupMemberId.size() != 0 && groupMemberId.contains(UserInfo.getUserId())) {
                    system.debug('user part of global group');
                    isGlobalUser = true;
                    return true;
                }
                return false;
            }
            return isGlobalUser;
        }
        set;
    }
    
    public static String currentLoggedInUser {
        get {
            if(currentLoggedInUser == null) {
                return UserInfo.getName();
            }
            else {
                return currentLoggedInUser;
            }
        }
        set;
    }
    
    public CNT_TPA_Additional_Terms() {
        string tparequestId = ApexPages.currentPage().getParameters().get('tpaRequestId');
        system.debug('isGlobalUser'+isGlobalUser);
        loadData(tparequestId, false);
    }

    public class AttachmentWrapper {
        public String name{get;set;}
        public String body{get;set;}
        public String mimeType{get;set;}
    }

    public class ReturnWrapper{
        Map<Id, TPA_Additional_Term__c > termsMap;
        Map<Id,Id> attachmentMap;
    }
    
    @RemoteAction
    public static String saveRequest(String additionalTermDetail , String attchWrapper ,String tpaRequestId,String saveType,Boolean prevExhibitAttached) {
        Type t = Type.forName('TPA_Additional_Term__c');
        TPA_Additional_Term__c additionaltermObj = (TPA_Additional_Term__c)JSON.deserialize(additionalTermDetail, t);
        AttachmentWrapper attchWrap;
        if(attchWrapper != null && attchWrapper != '')
            attchWrap = (AttachmentWrapper)JSON.deserializeStrict(attchWrapper, AttachmentWrapper.class);
        
        Attachment attch1 = new Attachment();
        if(attchWrap != null && attchWrap.name != null){
            //attchWrap = (AttachmentWrapper)JSON.deserialize(attachDetail, Type.forName('AttachmentWrapper'));
            attchWrap.name = attchWrap.name.indexOf('Exhibit') > -1 ? attchWrap.name : ('Exhibit'+attchWrap.name) ;
            attch1.Name = attchWrap.name;
            attch1.Body = EncodingUtil.base64Decode(attchWrap.body);
            attch1.ContentType = attchWrap.mimeType;
        }
        if( additionaltermObj != null) {
            List<TPA_Additional_Term__c> relatedTerm;
            if(saveType == 'Edit' && ( additionaltermObj.Category__c == 'General Ad-Hoc Term' || additionaltermObj.Category__c == 'Use Specific Ad-Hoc Terms') ){
                system.debug('additionaltermObj.Parent_Additional_Terms__c'+additionaltermObj.Parent_Additional_Terms__c);
                relatedTerm = [Select Id,Term_Name__c,Addtional_Term__c,Exhibit_Attached__c,Do_Not_Apply_if_Renewed__c,Use_Name__c From TPA_Additional_Term__c where Id !=: additionaltermObj.Id and (Id =: additionaltermObj.Parent_Additional_Terms__c or Parent_Additional_Terms__c =: additionaltermObj.Id) Limit 1];
                if(relatedTerm != null && relatedTerm.size() > 0){
                    relatedTerm[0].Term_Name__c = additionaltermObj.Term_Name__c;
                    relatedTerm[0].Addtional_Term__c = additionaltermObj.Addtional_Term__c;
                    relatedTerm[0].Exhibit_Attached__c = additionaltermObj.Exhibit_Attached__c;
                    relatedTerm[0].Do_Not_Apply_if_Renewed__c = additionaltermObj.Do_Not_Apply_if_Renewed__c;
                    relatedTerm[0].Use_Name__c = additionaltermObj.Use_Name__c;
                    relatedTerm[0].Category__c = additionaltermObj.Category__c;
                }
            }
            if(saveType == 'new'){
                additionaltermObj.Type__c = 'New';
                additionaltermObj.Ad_hoc_Term_Last_Entered_By__c = currentLoggedInUser;
                additionaltermObj.Ad_hoc_Term_Last_Updated__c = Datetime.Now();
            }
            else if(saveType == 'Edit'){
                additionaltermObj.Ad_hoc_Term_Last_Entered_By__c = currentLoggedInUser;
                additionaltermObj.Ad_hoc_Term_Last_Updated__c = Datetime.Now();
            }
            if(saveType == 'Edit' && prevExhibitAttached && (attchWrap != null && attchWrap.name != null)){
                DAOH_TPA_Additional_Term.exhibitPageUpdated = true;
            }
            DAOH_TPA_Additional_Term.insertionFromPage = true;
            if(relatedTerm != null && relatedTerm.size() > 0){
                upsert new List<TPA_Additional_Term__c>{additionaltermObj,relatedTerm[0]};
            }
            else{
                upsert additionaltermObj;
            }
            DAOH_TPA_Additional_Term.insertionFromPage = false;
            DAOH_TPA_Additional_Term.exhibitPageUpdated = false;
            relatedTerm = [Select Id From TPA_Additional_Term__c where Id !=: additionaltermObj.Id and (Id =: additionaltermObj.Parent_Additional_Terms__c or Parent_Additional_Terms__c =: additionaltermObj.Id)  Limit 1];
            List<Attachment> attchsToInsert = new List<Attachment>();
            List<Attachment> attchsToDelete = new List<Attachment>();
            if(relatedTerm != null && relatedTerm.size() > 0)
                attchsToDelete = [Select Id From Attachment where  ParentId =: additionaltermObj.Id or ParentId =: relatedTerm[0].Id];
            else 
                attchsToDelete = [Select Id From Attachment where  ParentId =: additionaltermObj.Id];
            
            if(attchsToDelete.size() > 0 && ((attchWrap != null && attchWrap.name != null) || (prevExhibitAttached && additionaltermObj != null && !additionaltermObj.Exhibit_Attached__c))){
                delete attchsToDelete;
            }

            if(attchWrap != null && attchWrap.name != null){
            	
                Attachment attch = new Attachment();
                if(relatedTerm != null && relatedTerm.size() > 0){
                	attch.Name = attchWrap.name;
                	attch.Body = EncodingUtil.base64Decode(attchWrap.body);
                	attch.ContentType = attchWrap.mimeType;
                	attch.ParentId = relatedTerm[0].Id;
                	attchsToInsert.add(attch);
				}
                attch1.ParentId = additionaltermObj.Id;
                attchsToInsert.add(attch1);
                insert attchsToInsert;
                DAOH_TPA_Additional_Term.sendEmails();
            }
            else if((DAOH_TPA_Additional_Term.reqsSendApprovalMail != null && DAOH_TPA_Additional_Term.reqsSendApprovalMail.size() > 0)
            ||(DAOH_TPA_Additional_Term.reqsSendSecApprovalMail != null && DAOH_TPA_Additional_Term.reqsSendSecApprovalMail.size() > 0)){
                DAOH_TPA_Additional_Term.sendEmails();
            }
            CNT_TPA_Additional_Terms.loadData(tpaRequestId,true);
            ReturnWrapper retVal = new ReturnWrapper();
            retVal.termsMap = additionalTermsMap;
            retVal.attachmentMap = addHocIdWithAttchsId;
            return JSON.serialize(retVal);
        }
        return null;
    }

    @RemoteAction
    public static String deleteAdditionalTerm(String additionaltermId,String parentTermId, String additionaltermName, string tpaRequestId) {
        system.debug('additionaltermId = ' + additionaltermId);
        TPA_Additional_Term__c additionaltermObj = new TPA_Additional_Term__c(Id=additionaltermId,Parent_Additional_Terms__c = parentTermId);
        if( additionaltermObj != null) {
            system.debug('additionaltermObj = ' + additionaltermObj);
            List<TPA_Additional_Term__c> relatedTerm = [Select Id From TPA_Additional_Term__c where Id !=: additionaltermObj.Id and (Id =: additionaltermObj.Parent_Additional_Terms__c or Parent_Additional_Terms__c =: additionaltermObj.Id)  Limit 1];
            DAOH_TPA_Additional_Term.insertionFromPage = true;
            if(relatedTerm != null && relatedTerm.size() > 0){
                relatedTerm.add(additionaltermObj);
                delete relatedTerm;
            }
            else{
                delete additionaltermObj;
            }
            DAOH_TPA_Additional_Term.insertionFromPage = false;
            system.debug('additionalTermsMap = ' + additionalTermsMap);
            CNT_TPA_Additional_Terms.loadData(tpaRequestId,true);
            system.debug('additionalTermsMap = ' + additionalTermsMap);
            return JSON.serialize(additionalTermsMap);
        }
        return null;
    }
    
    //Load all the ad-hoc additional terms for a TPA request
    public static void loadData(string tpaRequestId, Boolean isUpdateOrDelete) {
        additionalTermsMap = new Map<Id, TPA_Additional_Term__c>();
        tpaRequestList = [SELECT Id, Name, Request_status__c, Ad_hoc_Categories__c,
                                 (SELECT Id, Name,Term_Name__c,Use_Name__c,Country_of_Offering__c, Addtional_Term__c, Category__c,Is_All_Legal_Entities_Selected__c, Parent_Additional_Terms__c, TPA_Legal_Entity_1__c, 
                                 TPA_Legal_Entity_1__r.Legal_Entity_Name_for_TLLA__c,
                                 TPA_Request__c, Exhibit_Attached__c,
                                 TPA_Request__r.Name, 
                                 Primary_Offering_Name__c, 
                                 //Primary_Offering__r.Asset_Name__c, 
                                 Secondary_Offering_Name__c,Do_Not_Apply_if_Renewed__c,Type__c,
                                 Is_Future_Approved__c,
                                 Ad_hoc_Term_Last_Entered_By__c,
                                 Ad_hoc_Term_Last_Updated__c,
                                 LastModifiedBy.Name,
                                 LastModifiedDate
                                 //Secondary_Offering__r.Secondary_Asset_Name__c
                                 FROM TPA_Additional_Terms__r order by CreatedDate desc), 
                                 (SELECT Id, Legal_Entity_Name_for_TLLA__c FROM IMS_Legal_Entities__r), (SELECT Id, Asset_Name__c, BU__c FROM Data_Assets__r), 
                                 (SELECT Id, Secondary_Asset_Name__c FROM TPA_Tertiary_Data_Assets__r) 
                        FROM TPA_Request__c 
                        WHERE Id = :tparequestId];
        system.debug('tpaRequestList: ' + tpaRequestList);
        string strPickListValue = '';
        Boolean picklistUpdated = false;
        List<String> adHocCatList = new List<String>();
        if(tpaRequestList != null && tpaRequestList.size() > 0) {
            tparequest = tpaRequestList[0];
            for(TPA_Additional_Term__c additionalterm : tparequest.TPA_Additional_Terms__r) {
                additionalTermsMap.put(additionalterm.Id, additionalterm);
                if(adHocCatList == null || adHocCatList.size() == 0){
                    adHocCatList.add(additionalterm.Category__c) ;
                }
                else if(!adHocCatList.contains(additionalterm.Category__c)){
                    adHocCatList.add(additionalterm.Category__c) ;
                }
            }
            adHocCatList.sort();
            if(tparequest != null && isUpdateOrDelete){
                String colonSepCat = '';
                if(adHocCatList.size() >0){
                    colonSepCat = String.join(adHocCatList, ';');
                }
                if((tparequest.Ad_hoc_Categories__c == null || tparequest.Ad_hoc_Categories__c == '') || (tparequest.Ad_hoc_Categories__c != null && tparequest.Ad_hoc_Categories__c != colonSepCat)){
                    try {
                        update(new TPA_request__c(id= tparequest.id, Ad_hoc_Categories__c = colonSepCat));
                    } catch (Exception e) {
                        UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_Additional_Terms.setStatusExp:::in loadData', tparequest.id != null ? tparequest.id : ''));
                        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                    }
                }
                
            }
            
            addHocIdWithAttchsId = new Map<Id,Id>();
            for(Attachment attch : [Select Id,ParentId From Attachment where ParentId in: additionalTermsMap.keySet()]){
                addHocIdWithAttchsId.put(attch.ParentId,attch.Id);
            }
            legalEmtityList = tparequest.IMS_Legal_Entities__r;
            priOfferingList = [SELECT Id, Asset_Name__c,A_Column_Use_For_Template__c, BU__c , IMSLegalEntity__c, 
                               (SELECT Id, Secondary_Asset_Name__c, IMS_Legal_Entity__c FROM TPA_Secondary_Data_Assets__r)
                               FROM TPA_Data_Asset__c 
                               WHERE Request__c = :tparequestId];                               
        }
    }

    public string getTPARequest() {
        system.debug('tparequest : ' + tparequest );
        return JSON.serialize(tparequest);       
    }
    
    public string getJSONAdditionalTermsMap() {
        system.debug('additionalTermsMap : ' + additionalTermsMap );
        return JSON.serialize(additionalTermsMap );       
    }

    public String JSONAdditionalTermsAttachId{
        get{
            return JSON.serialize(addHocIdWithAttchsId ); 
        }
        set;
    }
    
    
    //List of all the legal entities selected for the TPA request
    public static String jsonLegalEntityList {
        get {
            if(jsonLegalEntityList == null || jsonLegalEntityList == '') { 
                system.debug('legalEmtityList = ' + legalEmtityList);
                jsonLegalEntityList = JSON.serialize(legalEmtityList);
                system.debug('jsonLegalEntityList = ' + jsonLegalEntityList);
            }
            return jsonLegalEntityList;
        }
        set;
    } 
    
    //List of all the primary offerings selected for the TPA request
    public static String jsonPriOfferingList {
        get {
            if(jsonPriOfferingList == null || jsonPriOfferingList == '') { 
                system.debug('priOfferingList = ' + priOfferingList);
                jsonPriOfferingList = JSON.serialize(priOfferingList);
                system.debug('jsonPriOfferingList = ' + jsonPriOfferingList);
            }
            return jsonPriOfferingList;
        }
        set;
    }
    //List of all the secondary offerings selected for the TPA request
    public static String jsonSecOfferingList {
        get {
            if(jsonSecOfferingList == null || jsonSecOfferingList == '') { 
                system.debug('secOfferingList = ' + secOfferingList);
                jsonSecOfferingList = JSON.serialize(secOfferingList);
                system.debug('jsonSecOfferingList = ' + jsonSecOfferingList);
            }
            return jsonSecOfferingList;
        }
        set;
    }    

    //Get list of available category options
    public string getCategory() {
        List<string> requestedData = new List<string>();
        requestedData.add('--None--');
        Schema.DescribeFieldResult fieldResult = TPA_Additional_Term__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            requestedData.add(f.getLabel());
        }
        requestedData.sort();
        return JSON.serialize(requestedData);
    } 
}
