@isTest
public class TST_CNT_OWF_BHR_NotificationService {
/**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
	{
		Account acc = UTL_OWF_TestData.createAccount();
        acc.Name = 'GLAXOSMITH';
		insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Grp__c grp1 = UTL_OWF_TestData.createGroup();
        grp1.Name = 'OWF TSL';
        insert grp1;
        Contact cont2 = UTL_OWF_TestData.createContact(acc.Id);
        cont2.pse__Is_Resource__c = true;
        cont2.pse__Is_Resource_Active__c = true;
        cont2.pse__Group__c = grp1.Id;
        cont2.sub_group__c = 'TSL-Japan';
        cont2.available_for_triage_flag__c = true;
        cont2.pse__Salesforce_User__c = UserInfo.getUserId();
        insert cont2;
        OWF_Config__c owfConfig = UTL_OWF_TestData.setupOWFConfig(grp.Id);
        owfConfig.OWF_Compatible_Group_Set_1__c = 'OWF TSL';
        owfConfig.OWF_Compatible_Group_Set_2__c = 'OWF DSB-DM';
        owfConfig.Enable_Agreement_Notification_Service__c = true;
        owfConfig.GSK_Account_Name__c = 'GLAXOSMITH';
        insert owfConfig;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        agreement.Targeted_Countries__c = 'AL;AF';
        agreement.Is_this_part_of_a_Program__c = 'Not part of a program';
        agreement.Number_of_Scenarios__c = 2;
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
    }
    
    static testmethod void testClinicalAgreement() 
	{
		test.startTest();
        try{
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            Bid_History__c agr = [Select Id,Name from Bid_History__c where Bid_History_Related_Opportunity__c =:oppty.Id];
			Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
			List<String> oppFields = new List<String>{'Id','Name','StageName'};
			CNT_OWF_BHR_NotificationService controller = new CNT_OWF_BHR_NotificationService(new ApexPages.StandardController(oppty));
			CNT_OWF_BHR_NotificationService.getBidHistoryDetailsAndValidate(agr.Id);
        }
		catch(Exception e)
        {
            system.debug('Error Occurred');
        }
        test.stopTest(); 
    }
} 
