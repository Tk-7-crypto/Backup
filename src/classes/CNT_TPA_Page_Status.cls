//Created under ER-1940
public class CNT_TPA_Page_Status {
    public String language {get; set;}
    
    public CNT_TPA_Page_Status() {
        language = getLanguage();
    }
    
    //Added for site to community logic submission start
    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = UTL_TPA.getCurrentUserDetails().Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }
    //Added for site to community logic submission end
    
    private String getLanguage() {
        //Cookie lang = ApexPages.currentPage().getCookies().get('lang');
        String lang = '';
        if(ApexPages.currentPage().getParameters().get('lang') != null)
            return ApexPages.currentPage().getParameters().get('lang');
        if(ApexPages.currentPage().getParameters().get('reqNo') != null) {
            String tpaReqNo = ApexPages.currentPage().getParameters().get('reqNo');
            String reqBy = '';
            TPA_Request__c reqObj = [Select Id from TPA_request__c where Name =: tpaReqNo LIMIT 1];
            if(reqObj != null) {
                if(currentUserProfileName == UTL_TPA.tpaVendorProfile) {
                    reqBy = 'v';
                }
                else if(UTL_TPA.tpaClientPortalProfiles.contains(currentUserProfileName)) {
                    reqBy = 'c';
                }
                if(reqBy != '' && reqBy != null) {
                    lang = UTL_TPA_Multilingual.getLanguageForExistingRequests(reqObj.Id, reqBy);
                }
            }
        }
        if(lang == null || lang == '') {
            lang = 'en_US';
        }
        return lang;
    }

}