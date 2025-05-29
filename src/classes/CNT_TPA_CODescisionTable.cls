global class CNT_TPA_CODescisionTable {
    public String language {get;set;}
    public String tpaRequestID {get;set;}
    public string CSId {get; set;}
    public static string viewMode {get;set;}
    public string TPCountryId {get; set;}
    public string TPUSId {get; set;}
    public string MGMTId {get; set;}
    public string LGLId {get;set;}
    public string MailType{get;set;}
    public static string tpaCommunityUrl {
        get {
            if(tpaCommunityUrl == null && UTL_TPA.tpaSetting != null && !String.isEmpty(UTL_TPA.tpaSetting.TPA_Client_Community_Url__c)) {
                tpaCommunityUrl = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c;
            }
            return tpaCommunityUrl;
        }
        set;
    }
    public static User currentLoggedInUser {
        get {
            if(currentLoggedInUser == null) {
                return UTL_TPA.getCurrentUserDetails();
            }
            else {
                return currentLoggedInUser;
            }
        }
        set;
    }
    
    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = currentLoggedInUser.Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }
    public PageReference requestValidateOnLoad(){
        if(currentLoggedInUser.Profile.Name == 'tpa Profile') {
            return null;
        }
        tpaRequestID = ApexPages.currentPage().getParameters().get('id');
        CSId = ApexPages.currentPage().getParameters().get('CSId');
        viewMode = ApexPages.currentPage().getParameters().get('viewMode');
        TPCountryId = ApexPages.currentPage().getParameters().get('TPCountryId');
        TPUSId = ApexPages.currentPage().getParameters().get('TPUSId');
        MGMTId = ApexPages.currentPage().getParameters().get('MGMTId');
        LGLId = ApexPages.currentPage().getParameters().get('LGLId');
        MailType = ApexPages.currentPage().getParameters().get('MType');
        if(tpaRequestID != null && !String.isBlank(tpaRequestID))
            language = UTL_TPA_Multilingual.getLanguageForExistingRequests(tpaRequestId, 'v');
        
        return null;
    }
    
    @RemoteAction
    global static List<TPA_Commercial_Review__c> getRelatedComList( String lastRecId, id tpaRequestId, String viewMode, String MailType ){
        if(tpaRequestId != null && !String.IsBlank(tpaRequestId))
        {            
            List<TPA_Commercial_Review__c> totalComReasonsList = new List<TPA_Commercial_Review__c>();

            String actionNeededBy = UTL_TPA.commercialReviewViewMode.get(viewMode);
            String query = ' select id, Commercial_Owner_Name__c,Comment_For_Under_Validation__c, Date_of_Action_Response__c,' +
                'Additional_Text_For_Potential_Denial__c, Additional_Questions_For_TP_Processor__c, Associated_Offering_s_Use_Category_s__c,' +
                'Associated_Offering_to_Review__c,Associated_Use_to_Review__c, Associated_Offering_Category__c, Manual_Review_Reason__c,Action__c '+
                'from TPA_Commercial_Review__c where TPA_Request__c = \'' + tpaRequestId  + '\'';
            if( lastRecId != null && MailType == 'rr'){  // for "Review Required Mail"
                query += ' and Id > \'' + lastRecId + '\'';
            }else if( lastRecId != null && MailType == 'fyr'){ // for "For Your Record Mail"
                query += ' and Id < \'' + lastRecId + '\'';
            }
            if( actionNeededBy != null){
                if(viewMode == 'SCSubmit'){
                    query += ' and (Action_Needed_By__c Like \'%Vendor - Use Secondary Review by%\' OR '+
                        ' Action_Needed_By__c Like \'%Offering Requires Secondary Commercial Review%\' OR ' +
                         ' Action_Needed_By__c Like\'%Vendor - Use - Offering Secondary Review by%\')';
                }
                else if(viewMode == 'MGMT'){
                    query += ' and (Status__c like \'%Approved%\' or Status__c like \'%Complete%\')';
                }else{
                    query += ' and Action_Needed_By__c = \'' + actionNeededBy + '\'';
                }
            }
            if(MailType == 'fyr'){
                query += ' and Action__c <> null';
                query += ' order by Id DESC Limit 2000';
            }else {
                query += ' order by Id ASC Limit 2000';
            }
            
            totalComReasonsList = Database.query(query);
            if(totalComReasonsList.size() > 0) {
                return totalComReasonsList;
            }
            return null;                        
        }
        return null;
    }
}