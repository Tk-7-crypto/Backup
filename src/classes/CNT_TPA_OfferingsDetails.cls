public class CNT_TPA_OfferingsDetails {
    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = currentLoggedInUser.Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }
    public static User currentLoggedInUser {
        get {
            if(currentLoggedInUser == null) {
                currentLoggedInUser = UTL_TPA.getCurrentUserDetails();
            }
            return currentLoggedInUser;
        }
        set;
    }
    
    public static string tpaCommunityUrl {
        get {
            if(tpaCommunityUrl == null && UTL_TPA.tpaSetting != null && !String.isEmpty(UTL_TPA.tpaSetting.TPA_Client_Community_Url__c)) {
                tpaCommunityUrl = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c;
            }
            return tpaCommunityUrl;
        }
        set;
    }
    
    
    @remoteAction
    public static TPA_Request__c fetchTPARecords(String reqId){
        TPA_Request__c tpaRequest = new TPA_Request__c(); 
        tpaRequest = [select id, Countries_of_offerings__c, Parent_Request__c, Parent_Request__r.Is_Renewed__c, Parent_Request__r.Renewed_As__c, List_Of_Uses__c, Category_of_Offerings__c,
                      (select id, Additional_Offerings_in_Renewal__c, Excluded_Offerings_In_Renewal__c, Included_Category_s_In_Renewal__c, Excluded_Category_s_In_Renewal__c, Excluded_Uses_In_Renewal__c, Included_Uses_In_Renewal__c
                       from TPA_Agreement_Additional_Fields__r) from TPA_Request__c where id = :reqId]; 
        return tpaRequest;
    }
    
}