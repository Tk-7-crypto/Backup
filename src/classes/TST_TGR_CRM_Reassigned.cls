@IsTest
public class TST_TGR_CRM_Reassigned {
    @testsetup
    static void datasetup() {
        
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Revenue_Analyst__c');
        insert q1;
        GroupMember gp = new GroupMember(UserorGroupId=UserInfo.getUserId(),GroupId=g1.Id);
        insert gp;
        
        
        //setup Queue
        User testUser = [Select id, name from User where isActive = true and profile.Name = 'system administrator'and Id = :UserInfo.getUserId() Limit 1];
        System.RunAs(testUser) {
            //Test.startTest();
            Account NewAccount = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
            insert NewAccount;
            Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test RA', User__c = testUser.id);
            insert ratest;
            Competitor__c comp = UTL_TestData.createCompetitor();
            insert comp;
            Opportunity NewOpportunity = new Opportunity(Name='Test Opp');
            NewOpportunity.AccountId = NewAccount.Id;
            NewOpportunity.StageName = '7a. Closed Won';
            NewOpportunity.CloseDate = System.today();
            NewOpportunity.FPI_Date__c=system.today();
            NewOpportunity.Population_Age_Group__c = 'Not Applicable';
            //NewOpportunity.Contract_Term__c='Single-Period';
            NewOpportunity.Contract_End_Date__c = system.today();
            NewOpportunity.Contract_Start_Date__c = system.today();
            NewOpportunity.CurrencyIsoCode = 'USD';
            NewOpportunity.Potential_Competitor_1__c = comp.Id;
            NewOpportunity.Potential_Regions__c = 'Global';    
            insert NewOpportunity;
            Address__c TestAddress = New Address__c(Name='Test Address',Account__c = NewAccount.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                    SAP_Reference__c = '495001',MDM_Validation_Status__c = 'Validated',RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId());
            insert TestAddress;
            
            BNF2__c TestBnf = new BNF2__c(Opportunity__c = NewOpportunity.Id);
            TestBnf.BNF_Status__c = MDM_Defines.BnfStatus_Map.get('NEW');
            TestBnf.Sales_Org_Code__c = 'ES51';
            TestBnf.IMS_Sales_Org__c = 'IMS Spain [ES51]';
            TestBnf.Ship_To__c = TestAddress.Id;
            TestBnf.Bill_To__c = TestAddress.Id;
            TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
            TestBnf.Revenue_Analyst__c = ratest.Id;
            TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
            TestBnf.Contract_End_Date__c = Date.today().addYears(2);
            insert TestBnf;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(TestBnf.Id);
            Approval.ProcessResult result = Approval.process(req1);
            
            //Test.stopTest();
        }
    }
    @isTest
    static void testReassignTrigger() {
        Test.startTest();
        Revenue_Analyst__c ratest =  [Select id,user__c from Revenue_Analyst__c Limit 1];
        BNF2__c testBNF = [Select id,Revenue_Analyst__c from BNF2__c Limit 1];
        testBNF.Revenue_Analyst__c = ratest.id;
		Update testBNF;
        
        Reassign__e reassign = new Reassign__e(
            RecordId__c = testBNF.id,
            Reassign_Approver__c = ratest.user__c,
            Comment__c = 'testUser[0].Id'
        );
        Database.SaveResult result = EventBus.publish(reassign);
        
        Test.stopTest();
        
    }  
}