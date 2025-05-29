public class CNT_CPQ_LaunchGBOCRMCompliance {
    
    @AuraEnabled
    public static String fetchUserSessionId(){
         String sessionId = '';
         PageReference reportPage = Page.VFP_CPQ_GetVFSessionId;
         String vfContent;
         if(!Test.isRunningTest()){
             vfContent = reportPage.getContent().toString();
             Integer startPage = vfContent.indexOf(CON_CPQ.START_OF_SESSION_ID) + CON_CPQ.START_OF_SESSION_ID.length(),
                 endPage = vfContent.indexOf(CON_CPQ.END_OF_SESSION_ID);
             sessionId = vfContent.substring(startPage, endPage);
         }
         else {
             sessionId = 'testSessionId';
         }
         return sessionId;
     }
    
    @AuraEnabled 
    public static String[] getAppName() {
        String[] appName = new String[]{};
        List<User> userDetailList = new SLT_User().selectUserByName(UserInfo.getName());
        if(userDetailList[0].GBO_CRM_Compliance_Category__c.contains(CON_CPQ.CONTRACTS_USER_CATEGORY)) {
            appName.add(CON_CPQ.CONTRACTS_APP_NAME);
        }
        if(userDetailList[0].GBO_CRM_Compliance_Category__c.contains(CON_CPQ.BIDHISTORY_USER_CATEGORY)) {
            appName.add(CON_CPQ.BIDHISTORY_APP_NAME);
        }
        if(userDetailList[0].GBO_CRM_Compliance_Category__c.contains(CON_CPQ.MASTER_SERVICE_AGREEMENTS_UPDATES)){
            appName.add(CON_CPQ.MASTER_SERVICE_AGREEMENTS_UPDATES);
        }
        return appName;
    } 
    
    @AuraEnabled
    public static String getBaseURL(){
        String baseURL = URL.getOrgDomainUrl().toExternalForm();
        return (baseURL);
    }
    
    @AuraEnabled
    public static String getNewAppId(String appName){
        Apttus_XApps__Application__c app = [Select Id, Apttus_XApps__UniqueId__c FROM Apttus_XApps__Application__c 
                                               WHERE Name=:appName LIMIT 1]; 
        return app.Apttus_XApps__UniqueId__c;
        
    }
}