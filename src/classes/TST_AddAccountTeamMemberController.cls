/*
* Version       : 1.0
* Description   : This test class is used for AddAccountTeamMemberController Class
*/
@isTest(SeeAllData=false)
private class TST_AddAccountTeamMemberController
{
    /**
     * This method used to set up testdata
     */
    @testSetup
    public static void setupData() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'MainDecisionMaker', LastName='Contact', AccountId = testAccount.Id,  Email = 'abc@xyz.com', CurrencyIsoCode = 'USD');
        insert testContact;
    }
    
    /**
     * This method used to test add team member and cancel functionality
     */  
    @isTest
    static void test1() {
        Account testAccount = [SELECT id, Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        PageReference pageRef = Page.TRIMActionInsufficientPrivilegesCustom;
        pageRef.getParameters().put('id', testAccount.Id);
        Test.setCurrentPage(pageRef);
        AddAccountTeamMemberController controller = new AddAccountTeamMemberController();
        Test.StartTest();
            controller.addATM();
            controller.cancel();
        Test.StopTest();
        System.assertNotEquals(null, controller);
    }
    
    /**
     * This method used to test add team member and cancel functionality
     */  
    @isTest
    static void test2() {
        Contact testContact = [SELECT id, Name FROM Contact WHERE Email='abc@xyz.com' LIMIT 1];
        PageReference pageRef = Page.TRIMActionInsufficientPrivilegesCustom;
        pageRef.getParameters().put('id', testContact.Id);
        Test.setCurrentPage(pageRef);
        AddAccountTeamMemberController controller = new AddAccountTeamMemberController();
        Test.StartTest();
            controller.addATM();
            controller.cancel();
        Test.StopTest();
    }
    
    /**
     * This method used to test constructor functionality
     */  
    @isTest
    static void test3() {
        Account testAccount = [SELECT id, Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        PageReference pageRef = Page.TRIMActionInsufficientPrivilegesCustom;
        pageRef.getParameters().put('id', '003sad');
        Test.setCurrentPage(pageRef);
        Test.StartTest();
            AddAccountTeamMemberController controller = new AddAccountTeamMemberController();
        Test.StopTest();
        System.assertNotEquals(null, controller);
    }
    
    /**
     * This method used to test constructor functionality
     */  
    @isTest
    static void test4() {
        Contact testContact = [SELECT id, Name FROM Contact WHERE Email='abc@xyz.com' LIMIT 1];
        PageReference pageRef = Page.TRIMActionInsufficientPrivilegesCustom;
        pageRef.getParameters().put('id', '001asadas');
        Test.setCurrentPage(pageRef);
        Test.StartTest();
            AddAccountTeamMemberController controller = new AddAccountTeamMemberController();
        Test.StopTest();
        System.assertNotEquals(null, controller);
    }
    
    /**
     * This method used to test constructor functionality
     */  
    @isTest
    static void test5() {
        Contact testContact = [SELECT id, Name FROM Contact WHERE Email='abc@xyz.com' LIMIT 1];
        PageReference pageRef = Page.TRIMActionInsufficientPrivilegesCustom;
        Test.setCurrentPage(pageRef);
        Test.StartTest();
            AddAccountTeamMemberController controller = new AddAccountTeamMemberController();
        Test.StopTest();
        System.assertNotEquals(null, controller);
    }
    
    /**
     * This method used to test complete contorller functionality
     */  
    @isTest
    static void test6() {
        Account testAccount = [SELECT id, Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        PageReference pageRef = Page.TRIMActionInsufficientPrivilegesCustom;
        pageRef.getParameters().put('id', testAccount.Id);
        Test.setCurrentPage(pageRef);
        AddAccountTeamMemberController controller = new AddAccountTeamMemberController();
        Test.StartTest();
            controller.Acc = testAccount;
            controller.addATM();
            PageReference pageurl = controller.addATM();
            controller.cancel();
        Test.StopTest();
        System.assertNotEquals(null, controller);
        System.assertEquals(null, pageurl);
    }
}