@isTest(seeAllData=false)
public class TST_UTL_Docusign {
    @testSetup
    static void setupData() {
        
        DocuSign_Auth_Data__c docAuthData = new DocuSign_Auth_Data__c();       
        docAuthData.Name = 'TPA';
	docAuthData.User_Name__c = 'TPA Docusign Username';
        docAuthData.Base_URL__c = 'account-d.docusign.com';
        docAuthData.Client_Id__c = 'Integrator';
        docAuthData.DocuSign_Pwd__c = 'Docusign Password';
        docAuthData.DocusignUser_Id__c = 'User Id';
        docAuthData.Private_Key__c = 'Private Key';
        docAuthData.Public_Key__c = 'Public Key';
        docAuthData.Access_Token__c = ' ';
        docAuthData.Docusign_Auth_Endpoint__c = 'https://account-d.docusign.com/oauth/token';
        docAuthData.Docusign_Auth_ContentType__c = 'application/x-www-form-urlencoded';
        docAuthData.Docusign_Auth_Scope__c = 'signature spring_read spring_write';
        insert docAuthData;

        
    }
    
    public static testMethod void testgetJWTAccessToken()
    {
        Test.startTest();
            UTL_Docusign.getJWTAccessToken('TPA');
        Test.stopTest();
    }

}