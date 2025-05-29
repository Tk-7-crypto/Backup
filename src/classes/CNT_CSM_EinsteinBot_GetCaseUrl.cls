public class CNT_CSM_EinsteinBot_GetCaseUrl {

    public class CaseLoginURL{
        @InvocableVariable(required=true)
        public String caseUrl;
    }
    
    @InvocableMethod(label='GetCaseUrl')
    public static List<CaseLoginURL> getCaseLoggingUrl(){
        List<Network> communityNetworks = [SELECT Id FROM Network WHERE Name ='IQVIA Customer Service Hub'];
        List<CaseLoginURL> loginUrlList = new List<CaseLoginURL>();
        if(communityNetworks != null && communityNetworks.size() > 0){
            Network communityNetwork = communityNetworks[0];
            String loginUrl = Network.getLoginUrl(communityNetwork.Id);
            String baseUrl = loginUrl.replace('/login', '/s/contactsupport/');
            CaseLoginURL url = new CaseLoginURL();
            url.caseUrl = baseurl;
            loginUrlList.add(url);
        }
        return loginUrlList;
    }
}