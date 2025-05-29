Global with sharing class AccountTerritoryUpdate
{
    // ========================================
    // loginToPartnerSoapforceCom
    // ========================================
    // NOTE: this function is called prior to using atUpdate to login to SFDC and establish the session
    // if the session is already established, this function aborts to save the callout
    public static partnerSoapSforceCom.Soap atPartnerSoap;
    public static partnerSoapSforceCom.LoginResult atPartnerSoapLoginResult;
    public static partnerSoapSforceCom.SessionHeader_element atPartnerSoapSessionHeader;
    public static partnerSoapSforceCom.Soap atUpdate;
    public static boolean isCalloutTrue = false;

    private static Boolean loginToPartnerSoapforceCom(){
        system.debug('AccountTerritoryUpdate.loginToPartnerSoapforceCom: Function starting atUpdate ');
        if(atUpdate == null){
            try{
                // get webservice credentials
                String username = '';
                String password = '';  

                Organization_Default__c securityConfig = Organization_Default__c.getOrgDefaults();
                System.debug('securityConfig' + securityConfig);
                if(securityConfig != null) {
                    username = securityConfig.UserName__c != null ? securityConfig.UserName__c : '';
                    password = securityConfig.Password__c != null ? UTL_CRM.decryptPassword(securityConfig.Password__c) : '';
                }


                // login to SFDC webservice
                atPartnerSoap = new partnerSoapSforceCom.Soap();
                atPartnerSoapLoginResult = atPartnerSoap.login(username, password);

                partnerSoapSforceCom.AssignmentRuleHeader_element AssignmentRuleHeader1 = new partnerSoapSforceCom.AssignmentRuleHeader_element();
                AssignmentRuleHeader1.useDefaultRule = true;
                atPartnerSoap.AssignmentRuleHeader = AssignmentRuleHeader1;      
                // setup session element
                atPartnerSoapSessionHeader = new partnerSoapSforceCom.SessionHeader_element();
                atPartnerSoapSessionHeader.sessionId = atPartnerSoapLoginResult.sessionId;
                atUpdate = new partnerSoapSforceCom.soap();
                atUpdate.sessionHeader = atPartnerSoapSessionHeader;
                atUpdate.AssignmentRuleHeader = AssignmentRuleHeader1;
            } catch(Exception ex) {
                system.debug('Callout failed: ' +  + ex.getMessage());
                return false;
            }
        }

        // session established okay
        system.debug('AccountTerritoryUpdate.loginToPartnerSoapforceCom: Function ending');
        return true;
    }
    
    
    @future(callout = true)
    public static void updateAccountTerritory(set<Id> accountIdSet) {
        isCalloutTrue = true;
        // convert set of is to strin of id separated with , to be passed in soql
        string newSetStr = '';
        for(String accountId : accountIdSet) {
            newSetStr += '\'' + accountId + '\',';
        }
        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0, newSetStr.lastIndexOf(',')) + ')' : newSetStr ;
        
        // callout to webservice to update account territory
        Boolean calloutSuccessful;
        //try {
            if(atUpdate == null) {
                // login to web service if not already login
                loginToPartnerSoapforceCom();
            }
            
            partnerSoapSforceCom.QueryResult qResult = atUpdate.queryAll('SELECT id FROM Account where Id IN ' + newSetStr);
            sobjectPartnerSoapSforceCom.sObject_x[] sObject1 = qResult.records;
            system.debug(qResult.size);
            Global_Variables.isterritoryupdate = true;
            system.debug('we have set the value of isterritoryupdate' + Global_Variables.isterritoryupdate);
            partnerSoapSforceCom.SaveResult[] sr = atUpdate.update_x(sObject1);
            system.debug('we have set the value of isterritoryupdate after update checking' + Global_Variables.isterritoryupdate);
            // calloutSuccessful = sr.success;
            // return calloutSuccessful;
        //}
        //catch(Exception ex) {
            //system.debug('Callout failed: ' +  + ex.getMessage());
            // return calloutSuccessful;
        //}
    }
}