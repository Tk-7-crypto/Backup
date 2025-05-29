/**  
 * This test class is used to test UTL_PEP_SendonPointUserInfos class.
 * version : 1.0
 */
@isTest
public class TST_UTL_PEP_SendOnPointUserInfo {

    private static String email = 'onPointTestUser@test.com';

    @testSetup
    public static void setup() {
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY].id;

        Account ac = new Account(Name = 'IQVIA CONSOLIDATED ACCOUNT',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        ac.AccountCountry__c = 'IN';
        insert ac;
        
        Contact con = new Contact(FirstName = 'TestFirstName1234', LastName = 'testCon', AccountId = ac.Id, Email = email);
        con.Partner_Type__c = 'Data Partner';
        insert con;

        User user = new User(alias = 'test1234', email = email,
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = prmProfileId, country = 'United States', IsActive = true,
            ContactId = con.Id,
            timezonesidkey = 'America/Los_Angeles', username = email,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c = 'test description',
            EmployeeNumber = String.valueOf(System.currentTimeMillis())
        );
        insert new List<User>{user};

        TS_LMS_Training_Management__c trainingMgmt = new TS_LMS_Training_Management__c();
        trainingMgmt.Subscription_Start_Date__c = Date.today();
        trainingMgmt.Subscription_End_Date__c = Date.today() + 1;
        trainingMgmt.IQVIA_Key_Contact__c = con.Id;
        trainingMgmt.Account_Name__c = ac.Id;
        insert trainingMgmt;

        TS_LMS_Category__c category = new TS_LMS_Category__c();
        category.Active__c = true;
        category.Catalog__c = '123';
        category.OnPoint_Skill_Profile_Id__c = '456';
        insert category;


        TS_LMS_Catalog_Relationship__c categoryReltionship = new TS_LMS_Catalog_Relationship__c();
        categoryReltionship.Licenses__c = 100;
        categoryReltionship.Training_Management__c = trainingMgmt.id;
        categoryReltionship.Catalog__c = category.Id;
        insert categoryReltionship;
    }

    @isTest
    public static void testIsAdminApproved() {
        User partnerUser = [SELECT id FROM User WHERE email = :email];
        new UTL_PEP_SendonPointUserInfo().authorize(null, null, true, null);
    }
    
    @isTest
    public static void testCustomAttributes() {
        User partnerUser = [SELECT id FROM User WHERE email = :email];
        Map <String, String> result = new UTL_PEP_SendonPointUserInfo().customAttributes(partnerUser.Id, null, new Map < String, String > (), null);
        System.assert(result.get('training') != null); 
    }


}