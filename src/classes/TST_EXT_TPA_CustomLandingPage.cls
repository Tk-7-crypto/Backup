@isTest
public class TST_EXT_TPA_CustomLandingPage { 
	
    private static TPA_Request__c tpaRequest1;
    private static Contact tpaContact;
    private static Address__c testAccount;
    //private static Account testClientAccount;
    private static Address__c testAddress;
    private static Address__c testClientAddress;

    @TestSetup
    static void setup() {
        testClientAddress = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test address 1', 1345);
        testAddress = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test address 2', 1212);
        //testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test account 1', 1345);
        //testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test account 2', 1212);
        testAccount = [select Id, Name,Account__c from Address__c where Id=: testAddress.Id];
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        system.debug('tpaContact: '+ tpaContact);

        Profile p = [SELECT Id FROM Profile WHERE Name = 'TPA Customer Community Plus Login User'];
        User testUser = UTL_TPA_SetupTestData.createTestUser(tpaContact, p);
        TPA_Country_Codes__c tpaCountryCode = new TPA_Country_Codes__c(name = 'USA', Country_Possible_Codes__c = 'USA', Code_Type__c = 'C');
        insert tpaCountryCode;
        
        insert new Contact_Address_Crosswalk__c(Address__c = testAccount.Id, Contact__c = tpaContact.Id);

        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequest();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();

        Date todayDate = Date.today();
        TPA_Settings__c objSetting = TPA_Settings__c.getInstance();
        objSetting.Base_Url__c = 'nourl/wer';
        objSetting.Restriction_Date_For_Maintenance__c = todayDate.addDays(12);

        /*TPA_Custom_Landing_Page_Message__c objMessage = new TPA_Custom_Landing_Page_Message__c();
        objMessage.Name = 'Test Name';
        insert objMessage;*/
    }

    public static testMethod void testConstructor() {
        User u = [select id from user where Alias = 'standt' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CSM_CSH_Community_Access'];
		insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        ApexPages.currentPage().setCookies(new System.Cookie[] { new System.Cookie('extUserActionVal', 'extAction=ExtNewReq', null, -1, false) });
        system.runAs(u){
            Test.startTest();

            ApexPages.StandardController stdController = null;
            EXT_TPA_CustomLandingPage objController = new EXT_TPA_CustomLandingPage(stdController);
            objController = new EXT_TPA_CustomLandingPage();
            objController.refreshPage();
            objController = new EXT_TPA_CustomLandingPage();
            String listId = objController.listId;
            objController.listName = 'testName';
            String listName = objController.listName;
            String msgBoard = objController.msgBoardContent;
            String vName = objController.viewName;
            EXT_TPA_CustomLandingPage.getTPARequestsByDate('0');
            Map<String, String>  mpTranslated = EXT_TPA_CustomLandingPage.supportedLanguageMap;
            String strLanguage = objController.getLanguageMap();

            String changeLanguagePage = objController.goBackToChangeLanguagePage().getUrl();
        	Boolean isChangeLanguagePageRendered = changeLanguagePage.contains('VFP_TPA_CustomLandingPage');
        	System.assertEquals(true, isChangeLanguagePageRendered);

            objController.isRestrictedUser = true;
            objController.isClientFromUS = true;
            objController.lastSelectedLanguage = 'ja';

            System.assertNotEquals(null, objController.getTranslatedMap());

            objController.setView();
            EXT_TPA_CustomLandingPage.updateLastSelectedLanguage('English');
            objController.gettpaRequests();
            objController.settableSize();
            objController.sortData();
            objController.refreshTPAPage();
            String tempArg = objController.strPortalRequests;
            tempArg = objController.strDateMap;
            EXT_TPA_CustomLandingPage.isVendorUserProp();
            Map<String, List<TPA_Language_Cross_Walk__c>> tempMapTpaLangCrosWalk = objController.multilanguageUtilityMap;
            User tempUser = EXT_TPA_CustomLandingPage.currentLoggedInUser;
            tempArg = EXT_TPA_CustomLandingPage.loggedUserProfileName;
            tempArg = objController.sortOrder;
            objController.setTPARequest = null;
            ApexPages.StandardSetController stdSetController = objController.setTPARequest;
        }
        Test.stopTest();
    }
}