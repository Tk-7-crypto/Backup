public class CNT_CSM_AppLauncher {
    @AuraEnabled(cacheable=true)
    public static List<CSM_QI_App_Launcher__c> getAppLauncherForCurrentUser(){
        List<CSM_QI_App_Launcher__c> appLauncher = new List<CSM_QI_App_Launcher__c>();
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Account.AccountCountry__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].Contact.Account != null) {
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\''+pillar.replace(';','\',\'')+'\'';
                String country = users[0].Contact.Account.AccountCountry__c;
                if(country != null){
                    appLauncher = Database.query('select Id, Name, Url__c, Country__c, Pillar__c from CSM_QI_App_Launcher__c where Pillar__c includes ('+pillar+') and Country__c =: country order by Name ASC');
                }
                
            }
        }
        return appLauncher;
    }
}
