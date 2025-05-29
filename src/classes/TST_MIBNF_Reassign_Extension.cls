@istest
private class TST_MIBNF_Reassign_Extension {
    
    public static ApexPages.StandardController sc;
    public static MIBNF2__c MIBNF;
    public static MIBNF_Component__c MIBNF_Comp;
    public static MI_BNF_LineItem__c MIBNFLineItem;
    public static Opportunity opp;
    public static OpportunityLineItem OLI1;
    public static User TestUser1;
    public static Account TestAccount;
    public static List<Address__c> TestAddress_Array; 
    static BNF_Settings__c bnfsetting;
    
    @Testsetup
    static void testDataSetup() {
        UTL_ExecutionControl.stopTriggerExecution = true;
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Profile p1 = [select id from profile where (Name = 'SYSTEM ADMINISTRATOR') limit 1]; 
        User TestUser2  = new User(alias = 'jpusr', email='japnalocal@metacube.com', 
                                   emailencodingkey='UTF-8',firstname='User',lastname='Testing', languagelocalekey='en_US', 
                                   localesidkey='en_US', profileid = p1.Id, EmployeeNumber='678987',
                                   timezonesidkey='America/Los_Angeles', username='japnalocal1@metacube.com', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description'
                                  );
        System.runAs(TestUser2) {
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Revenue_Analyst__c');
            insert q1;
            GroupMember gp = new GroupMember(UserorGroupId=UserInfo.getUserId(),GroupId=g1.Id);
            insert gp;
        }
        bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=false,Enable_Customer_Validation__c=false,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=false);
        upsert bnfsetting;
        
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        
        insert new Profit_Centre__c(name='xz' ,ProfitCenterCode__c='USD');
        Contact MainDecisionMakerContact1 = new Contact(FirstName = 'MainDecisionMaker', LastName='Contact', AccountId = TestAccount.Id, Email = 'abc@metacube.com', CurrencyIsoCode = 'USD');
        MainDecisionMakerContact1.pse__Is_Resource__c=true;
        MainDecisionMakerContact1.pse__Is_Resource_Active__c=true;
        insert MainDecisionMakerContact1;
        
        // Create Opportunity
        Revenue_Analyst__c TestRA=UTL_TestData.createRevenueAnalyst();
        insert TestRA;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        opp =new Opportunity(Name='Quick opp',StageName='1. Identifying Opportunity',Amount=2000,CloseDate=System.today(),
                             Contract_Term__c='Single-Period',Contract_Type__c='Individual',CurrencyIsoCode = 'USD');
        opp.LeadSource = 'Account Planning';
        opp.Budget_Available__c = 'Yes';
        opp.Contract_Start_Date__c=system.today();
        opp.Contract_End_Date__c=system.today();
        opp.Opportunity_Number__c = '123';
        opp.Potential_Competitor_1__c = comp.Id;	
        insert opp;
        
        OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = opp.Id;
        Product2 Product1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH08', Business_Type__c = 'I&A', Material_Type__c = 'ZSET', Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
        Product1.Pillar__c = 'Technology Solutions; Information Offering';
        insert product1;
        List<PricebookEntry> pbeList = [Select id from PricebookEntry where IsActive = true and CurrencyIsoCode ='USD' and Pricebook2Id = :Test.getStandardPricebookId()  Limit 1];
        PricebookEntry pbe;
        if(pbeList.size() == 0) {
            pbe = new PricebookEntry();
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            pbe.Product2Id=Product1.id;
            pbe.IsActive=true;
            pbe.UnitPrice=100.0;
            pbe.CurrencyIsoCode = 'USD';
            insert pbe;
        }
        else {
            pbe = pbeList[0];
        }
        OLI1.PricebookEntryId = Pbe.Id;
        OLI1.Quantity = 1.00;
        OLI1.TotalPrice=10000;
        OLI1.List_Price__c = 100;
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        insert OLI1;
        
        Opportunity opp1 =new Opportunity(id=opp.Id);
        opp1.StageName='7a. Closed Won';
        opp1.Primary_Win_Reason__c ='Project Performance';
        opp1.Win_Type__c = 'Non-competitive bid';
        update opp1;
        
        TestAddress_Array = UTL_TestData.createAddresses(TestAccount);
        insert TestAddress_Array;
        
        MIBNF=new MIBNF2__c();
        MIBNF.Client__c=opp.AccountId;
        MIBNF.Opportunity__c=opp.Id;
        MIBNF.Sales_Org_Code__c='CH08';
        MIBNF.Billing_Currency__c='USD';
        MIBNF.IMS_Sales_Org__c='Acceletra';
        MIBNF.Fair_Value_Type__c='Stand Alone';
        MIBNF.Invoice_Default_Day__c='15';
        MIBNF.Contract_Start_Date__c=system.today();
        MIBNF.Contract_End_Date__c=system.today();
        MIBNF.Contract_Type__c='Individual';
        MIBNF.Contract_Term__c='Single-Period';
        MIBNF.Payment_Terms__c='0000-Default Payment Terms of Customer Master Data';
        MIBNF.Revenue_Analyst__c=TestRA.id;
        insert MIBNF;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        
        MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=MIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No';
        MIBNF_Comp.Bill_To__c=TestAddress_Array[0].Id;
        MIBNF_Comp.Ship_To__c=TestAddress_Array[0].id;
        insert MIBNF_Comp;
        
        MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
        MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
        MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
        MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
        insert MI_BNFLineItem;
    }
    
    @isTest 
    static void reassignRAMIBNFCompNULL () {
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF  = [Select id, Comments__c from MIBNF_Component__c Limit 1];
        MIBNF2__c TestMIBNF1  = [Select id, Revenue_Analyst__c from MIBNF2__c Limit 1];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(TestMIBNF.Id);
        Approval.ProcessResult result = Approval.process(req1);
        
        TestMIBNF1.Revenue_Analyst__c = null;
        PageReference pageRef = Page.MIBNF_Reassign;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id' , TestMIBNF.Id);
        MIBNF_Reassign_Extension mibnfReassign = new MIBNF_Reassign_Extension(new ApexPages.StandardController (new MIBNF_Component__c()));
        mibnfReassign.mibnfComp = TestMIBNF;
        PageReference pr = mibnfReassign.reassignRA();
        Test.stopTest();
    }
    
    @isTest 
    static void reassignRAMIBNFCompChanged() {
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF  = [Select id, Comp_Revenue_Analyst__c,SAP_Master_Contract__c, Comments__c, MIBNF__c from MIBNF_Component__c Limit 1];
        Group g = [select id from group where name= 'group name' Limit 1];
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(OwnerId = g.Id, Name='TstAnalyst1',Revenue_Analyst_Email__c='test1@metacube.com' ,User__c=UserInfo.getUserId(), User_2__c=UserInfo.getUserId() );
        insert TestLocalRA;
        TestLocalRA = [Select id , owner.type from Revenue_Analyst__c where id =:TestLocalRA.id];
        
        mibnf = [Select id, Revenue_Analyst__c from MIBNF2__c where id =:TestMIBNF.MIBNF__c ];
        mibnf.Revenue_Analyst__c = TestLocalRA.id;
        upsert mibnf;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(TestMIBNF.Id);
        Approval.ProcessResult result = Approval.process(req1);
        PageReference pageRef = Page.MIBNF_Reassign;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id' , TestMIBNF.Id);
        MIBNF_Reassign_Extension mibnfReassign = new MIBNF_Reassign_Extension(new ApexPages.StandardController (new MIBNF_Component__c()));
        mibnfReassign.mibnfComp.Reassigned_Comp_Revenue_Analyst__c = TestLocalRA.id;
        mibnfReassign.ApproverComments = 'Test';
        Test.stopTest();
        PageReference pr = mibnfReassign.reassignRA();
    }
    @isTest
    static void testReassignRequest(){
        Test.startTest();
        MIBNF_Component__c TestMIBNF  = [Select id, Comp_Revenue_Analyst__c,SAP_Master_Contract__c, Comments__c, MIBNF__c from MIBNF_Component__c Limit 1];
        Group g = [select id from group where name= 'group name' Limit 1];
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(OwnerId = g.Id, Name='TstAnalyst1',Revenue_Analyst_Email__c='test1@metacube.com' ,User__c=UserInfo.getUserId(), User_2__c=UserInfo.getUserId() );
        insert TestLocalRA;
        TestLocalRA = [Select id , owner.type from Revenue_Analyst__c where id =:TestLocalRA.id];
        
        mibnf = [Select id, Revenue_Analyst__c from MIBNF2__c where id =:TestMIBNF.MIBNF__c ];
        mibnf.Revenue_Analyst__c = TestLocalRA.id;
        upsert mibnf;
        PageReference pageRef = Page.MIBNF_Reassign;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id' , TestMIBNF.Id);
        MIBNF_Reassign_Extension mibnfReassign = new MIBNF_Reassign_Extension(new ApexPages.StandardController (new MIBNF_Component__c()));
        mibnfReassign.mibnfComp.Reassigned_Comp_Revenue_Analyst__c = TestLocalRA.id;
        mibnfReassign.ApproverComments = 'Test';
        Test.stopTest();
        PageReference pr = mibnfReassign.Reassign_Request();
    }
}