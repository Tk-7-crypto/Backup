@isTest
private class TST_MIBNF_Component_Update_RA_User {
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
    	Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
    	Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = true;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        //OpportunityTriggerUtil.RunBeforeTrigger = false;
        //OpportunityTriggerUtil.RunAfterTrigger = false;
        Global_Variables.isupdatableOppPlan = false;
        Global_Variables.isclonningOpportunity = true;
        bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=false,Enable_Customer_Validation__c=false,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=false);
        upsert bnfsetting;
        Profile p = [select id from profile where (Name = 'SYSTEM ADMINISTRATOR') limit 1]; 
        TestUser1  = new User(alias = 'jpusr', email='japnalocal@metacube.com', 
                              emailencodingkey='UTF-8',firstname='User',lastname='Testing', languagelocalekey='en_US', 
                              localesidkey='en_US', profileid = p.Id, 
                              timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com',
                              Change_Request_Description__c = 'test', EmployeeNumber = String.valueOf(System.currentTimeMillis()),
                              Change_Request_Ticket_Number__c ='test description'
                             );
        System.runAs(TestUser1) {     
            
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser1.Id;
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        
        insert new Profit_Centre__c(name='xz', Profitcentercode__c = 'USD' );
        Contact MainDecisionMakerContact1 = new Contact(FirstName = 'MainDecisionMaker', LastName='Contact', AccountId = TestAccount.Id, Email = 'abc@metacube.com', CurrencyIsoCode = 'USD');
        MainDecisionMakerContact1.pse__Is_Resource__c=true;
        MainDecisionMakerContact1.pse__Is_Resource_Active__c=true;
        insert MainDecisionMakerContact1;
        
        /*Principal_In_Charge__c PIC=new Principal_In_Charge__c(NAME=UserInfo.getLastName()+', '+UserInfo.getFirstName(), User__c=UserInfo.getUserId());
        PIC.PseResource__c=MainDecisionMakerContact1.id;
         
         insert PIC;*/
        
         // Create Opportunity
        Revenue_Analyst__c TestRA=new Revenue_Analyst__c(name='Test RA',User__c=TestUser1.Id);
        insert TestRA;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        opp =new Opportunity(Name='Quick opp',StageName='1. Identifying Opportunity',Amount=2000,CloseDate=System.today(),
        Contract_Term__c='Single-Period',Contract_Type__c='Individual');
        opp.LeadSource = 'Account Planning';
        opp.Budget_Available__c = 'Yes';
        opp.Contract_Start_Date__c=system.today();
        opp.Contract_End_Date__c=system.today();
        opp.Potential_Competitor_1__c = comp.Id;
        //opp.Unique_Business_Value__c = 'Unknown';
        //opp.Compelling_Event__c = 'No';
        //opp.Main_Decision_Maker__c=MainDecisionMakerContact1.Id;
        //opp.Budget_Holder__c=MainDecisionMakerContact1.Id;
        //opp.Principal_In_Charge__c=PIC.Id;
        //opp.Exclude_From_Pricing_Calculator__c = true;
        insert opp;
        
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 2);
        userList.addall(UTL_TestData.createUser('Sales User', 1));
        insert userList;
		
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = userList[0].Id;
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
		
        Contact cnt = UTL_TestData.createContact(TestAccount.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = userList[0].Id;
        insert cnt;
		
		
		
		OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
            insert contactRole;
        
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
            UTL_ExecutionControl.stopTriggerExecution = true;
            insert OLI1;
            UTL_ExecutionControl.stopTriggerExecution = false;
        
        Opportunity opp1 =new Opportunity(id=opp.Id);
        opp1.StageName='7a. Closed Won';
        opp1.Primary_Win_Reason__c ='Project Performance';
        opp1.Win_Type__c = 'Non-competitive bid';
        //opp1.Win_Loss_Reason__c='Win - Competitive Situation';
        //opp1.Win_Additional_Details__c = 'Additional details';
        //opp1.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
       
        update opp1;
        
        TestAddress_Array = new List<Address__c>();
        for (Integer i=0; i<10; i++)
        {
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Account__c=TestAccount.Id,
                                                    Street__c = 'Street ' + i.format(),
                                                    City__c = 'City '+ i.format(),
                                                    Country__c = 'Country ' + i.format(),
                                                    SAP_Reference__c = String.valueOf(495000+i),
                                                    MDM_Validation_Status__c='Validated');
            TestAddress_Array.add(TempAddress);
        } 
        insert TestAddress_Array;
        
        Test.startTest();
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
         Test.stopTest();
      }  
   }
    
      @isTest 
    static void reassignRAMIBNFCompChanged() {
      
        Test.startTest();
        MIBNF_Component__c TestMIBNF  = [Select id, Comp_Revenue_Analyst__c,SAP_Master_Contract__c, Comments__c from MIBNF_Component__c Limit 1];
        TestMIBNF.Comp_Revenue_Analyst__c = null;
        TestMibnf.SAP_Master_Contract__c = null;
        
        upsert TestMIBNF;
        MIBNF2__c TestMIBNF1  = [Select id, Revenue_Analyst__c, SAP_Master_Contract__c from MIBNF2__c Limit 1];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(TestMIBNF.Id);
        Approval.ProcessResult result = Approval.process(req1);
        Profile p = [SELECT Id FROM Profile WHERE Name = 'system administrator' Limit 1];
        List<User> userlist= new List<User>();
        for (Integer k=0;k<10;k++) { 
            userlist.add(new User(Alias = 'standt', Email='standarduser@metacube.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3144'+k+'@metacube.com', isActive = true, Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description',EmployeeNumber = '0909096924' + k
                                 ));
        }
        insert userlist;
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(name='TestRA',
            User__c = userlist[0].id);                                                                 
        insert TestLocalRA;
        TestMIBNF.Comp_Revenue_Analyst__c = TestLocalRA.id;
        TestMIBNF.SAP_Master_Contract__c = '1032009760';
        upsert  TestMIBNF;  
        Test.stopTest();
    }
    
     @isTest 
    static void reassignRAMIBNFCompChangedInactiveUser() {
      
        Test.startTest();
        MIBNF_Component__c TestMIBNF  = [Select id, Comp_Revenue_Analyst__c,SAP_Master_Contract__c, Comments__c from MIBNF_Component__c Limit 1];
        
        MIBNF2__c TestMIBNF1  = [Select id, Revenue_Analyst__c, SAP_Master_Contract__c from MIBNF2__c Limit 1];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(TestMIBNF.Id);
        Approval.ProcessResult result = Approval.process(req1);
        Profile p = [SELECT Id FROM Profile WHERE Name = 'system administrator' Limit 1];
        List<User> userlist= new List<User>();
        for (Integer k=0;k<10;k++) { 
            userlist.add(new User(Alias = 'standt', Email='standarduser@metacube.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber = '0909096924' + k,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3144'+k+'@metacube.com', isActive = true, Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description'
));
        }
        userlist[0].isactive = false;
        userlist[1].isactive = false;
        userlist[2].isactive = false;
        userlist[3].isactive = false;
        userlist[4].isactive = false;
        userlist[5].isactive = false;
        userlist[6].isactive = false;
        //userlist[7].isactive = false;
       // userlist[8].isactive = false;
        insert userlist;
        
        //system.runas(userlist[8]){
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
        //}
         
        system.runas(userlist[8]){
        
            Group grp = [select id from Group where name ='group name'];
            
            for(User u : userlist){
                GroupMember gm1 = new GroupMember(GroupId= grp.id, UserOrGroupId = u.Id);
                insert gm1;
            }
            
            QueuesObject q1 = new QueueSObject(QueueID = grp.id, SobjectType = 'Revenue_Analyst__c');
            insert q1;
            Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(name='TestRA',Revenue_Analyst_Email__c ='test@test.com',
                                                                    User__c = userlist[0].id, ownerId = grp.Id);                                                                 
            insert TestLocalRA;
            TestMIBNF.Comp_Revenue_Analyst__c = TestLocalRA.id;
            upsert TestMIBNF;
        }
        Test.stopTest();
    }
}