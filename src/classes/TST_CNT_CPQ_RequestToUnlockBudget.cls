@isTest
public class TST_CNT_CPQ_RequestToUnlockBudget {

    static Group setGroupData(){
        Group testGroup = UTL_TestData.createGroup(CON_CPQ.CPQ_ADMINS_FOR_BUDGET_UNLOCKING, 'Regular');
        insert testGroup; 
        return testGroup;
    }

    static GroupMember setGroupMemberData(Id groupId){
    
        GroupMember testGroupMember = UTL_TestData.createGroupMember(groupId, UserInfo.getUserId());
        Insert testGroupMember;
        return testGroupMember;
    }
    
    static Apttus_Proposal__Proposal__c getBudgetData(Id OpportuntiyId)
    {
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, OpportuntiyId, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c testBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, OpportuntiyId, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        testBudget.Pricing_Tool_Locked__c = true;
        testBudget.Budget_Checked_Out_By__c = UserInfo.getUserId();
        update testBudget;
        return testBudget;
    }

    static Opportunity setOpportunityData(Id accountId){

        Opportunity testOpportunity= UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        insert testOpportunity;
        return testOpportunity;
    }

    static Account setAccountData(){

        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    static EmailTemplate setEmailTemplate(String developerName){
        EmailTemplate testEmailTemplate = UTL_TestData.createEmailTemplate('test template', developerName, 'custom');
        testEmailTemplate.FolderId = UserInfo.getUserId();
        testEmailTemplate.Body = 'test';
        insert testEmailTemplate;
        return testEmailTemplate;
    }
    
    static Apttus_Proposal__Proposal__c getBudget(Id budgetId){
        return [SELECT Pricing_Tool_Locked__c FROM Apttus_Proposal__Proposal__c WHERE Id =: budgetId];
    }

    @isTest
    static void testIsNotifyCurrentXAE()
    {

        Group adminGroup = setGroupData();
        GroupMember adminGroupMember = setGroupMemberData(adminGroup.Id);
        
        Test.startTest();
            Boolean isNotify = CNT_CPQ_RequestToUnlockBudget.isNotifyCurrentXAEOWner(CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        Test.stopTest();

        System.assertEquals(false, isNotify, 'Owner is not notified');
    }

    @isTest
    static void testNotifyXAEOwnerShouldSendEmailToBudgetOwner()
    {

        List<User> thisUser = new SLT_User().selectById(new Set<Id>{UserInfo.getUserId()});  
        Apttus_Proposal__Proposal__c budget;
        System.runAs(thisUser[0])  { 
            Account testAccount = setAccountData();
            Opportunity testOpportunity = setOpportunityData(testAccount.Id);
            budget = getBudgetData(testOpportunity.Id);
        }
        Group adminGroup = setGroupData();
        GroupMember adminGroupMember = setGroupMemberData(adminGroup.Id);
        EmailTemplate ownerTemplate = setEmailTemplate('CPQ_Proposal_Another_User_Request_To_Unlock_Budget');
        EmailTemplate adminTemplate = setEmailTemplate('Notify_System_Admin_About_Lock_Agreement');

        Test.startTest();
            CNT_CPQ_RequestToUnlockBudget.notifyXAEOwner(UserInfo.getUserId(), budget.Id);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'Email is Sent to budget owner');
    }
    
    @isTest
    static void testNotifyAdmin()
    {
        List<User> thisUser = new SLT_User().selectById(new Set<Id>{UserInfo.getUserId()});  
        Apttus_Proposal__Proposal__c budget;
        System.runAs(thisUser[0])  { 
            Account testAccount = setAccountData();
            Opportunity testOpportunity = setOpportunityData(testAccount.Id);
            budget = getBudgetData(testOpportunity.Id);
        }
        Group adminGroup = setGroupData();
        GroupMember adminGroupMember = setGroupMemberData(adminGroup.Id);
        EmailTemplate ownerTemplate = setEmailTemplate(CON_CPQ.CPQ_PROPOSAL_SAME_USER_REQUEST_TO_UNLOCK_BUDGET);

        Test.startTest();
            CNT_CPQ_RequestToUnlockBudget.notifyAdminUser(UserInfo.getUserId(), budget.Id);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'Email is Sent to budget owner');
    }


    @isTest
    static void testUnlockAgreementShouldUnlockAgreement()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus_Proposal__Proposal__c budget = getBudgetData(testOpportunity.Id);

        Test.startTest();
            CNT_CPQ_RequestToUnlockBudget.unlockBudget(UserInfo.getUserId(), budget.Id);
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c budgetRecord = getBudget(budget.Id);
        System.assertEquals(false,  budgetRecord.Pricing_tool_Locked__c, 'Budget is unlocked');
    }
    
}