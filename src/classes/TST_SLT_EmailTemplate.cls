@isTest
public class TST_SLT_EmailTemplate {
    
    @isTest
    static void testSelectByIdShouldReturnEmailTemplate(){

        EmailTemplate ownerTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];

        Test.startTest();
            List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectById(new Set<Id>{ownerTemplate.Id});
        Test.stopTest();

        System.assertEquals(1, emailTemplateList.size(), 'Should Return Email Template');
    }

    @isTest
    static void testSelectEmailTemplateByDeveloperNameShouldReturnEmailTemplate(){

        Test.startTest();
            List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(
                'CPQ_Proposal_Another_User_Request_To_Unlock_Budget', new Set<String>{CON_CPQ.Id});
        Test.stopTest();

        System.assertEquals(1, emailTemplateList.size(), 'Should Return Email Template by Developer Name');
    }
    
    @isTest
    static void testSelectEmailDTemplateByName(){

        Test.startTest();
            List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectEmailDTemplateByName(
                'ET DATA EN Case Creation', new Set<String>{CON_CPQ.Id});
        Test.stopTest();

        System.assertEquals(1, emailTemplateList.size(), 'Should Return Email Template by Name');
    }
	
    @isTest
    static void testSelectEmailTemplatesByDeveloperNames(){

        Test.startTest();
            List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectEmailTemplatesByDeveloperNames(
                new Set<String>{'CPQ_Proposal_Another_User_Request_To_Unlock_Budget'});
        Test.stopTest();

        System.assertEquals(1, emailTemplateList.size(), 'Should Return Email Templates by DeveloperName');
    }
    
    @isTest
    static void testSelectEmailTemplatesByCondition(){
        Test.startTest();
        	List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectEmailTemplatesByCondition(
            	new Set<String>{'CPQ_Proposal_Another_User_Request_To_Unlock_Budget'}, new Set<String>{CON_CPQ.Id}, 'developerName =: developerNames' );
        Test.stopTest();
        
        System.assertEquals(1, emailTemplateList.size(), 'Should Return Email Templates by DeveloperNames');
    }

    @isTest
    static void testSelectEmailTemplatesByDeveloperNameAndFields(){
        Test.startTest();
        	List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectEmailTemplatesByDeveloperNameAndFields(
            	new Set<String>{'CPQ_Proposal_Another_User_Request_To_Unlock_Budget'}, new Set<String>{CON_CPQ.Id});
        Test.stopTest();
        
        System.assertEquals(1, emailTemplateList.size(), 'Should Return Email Templates by DeveloperNames');
    }
}