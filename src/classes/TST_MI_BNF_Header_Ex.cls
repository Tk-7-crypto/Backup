/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class TST_MI_BNF_Header_Ex { 
    
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
    @testSetup
    static void dataSetup(){
        Profile p = [select id from profile where ( Name = 'SYSTEM ADMINISTRATOR') limit 1]; 
        TestUser1  = new User(alias = 'jpusr', email='japnalocal@metacube.com', 
                              emailencodingkey='UTF-8',firstname='User',lastname='Testing', languagelocalekey='en_US', 
                              localesidkey='en_US', profileid = p.Id, EmployeeNumber = '0909090924',
                              timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        
        insert TestUser1;
        PermissionSet pr = [select id,name from PermissionSet Where Name = 'Modify_all_privileges_on_BNF'];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = pr.id, AssigneeId = TestUser1.id);
        insert psa; 
        system.debug(psa);
    }
    static testMethod void t1() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=false,Enable_Customer_Validation__c=false,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=false);
        upsert bnfsetting;
        TestUser1 = [Select id from User where username = 'japnalocal@metacube.com'][0];
        System.runAs(TestUser1) {   
            system.debug(UserInfo.getUserId());
            SetupMIBNF();
            SetupMIBNF_Comp(MIBNF);
            system.debug([SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF']);
            MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
            MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
            MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
            MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
            insert MI_BNFLineItem;
            
            ApexPages.CurrentPage().getParameters().put('id' ,MIBNF_Comp.id);
            
            PageReference pageRef = ApexPages.currentPage();
            Test.setCurrentPageReference(pageRef);
            MI_BNF_Comp_Submit_Approval appcontroller = new MI_BNF_Comp_Submit_Approval();
            
            PageReference pg=appcontroller.SubmitRequest();
            //  System.assertEquals(pg,null);
            ApexPages.CurrentPage().getParameters().put('id' ,MIBNF.id);
            ApexPages.CurrentPage().getParameters().put('retURL' ,'/apex/MI_BNF_View?id='+MIBNF.id);
            sc = new ApexPages.StandardController(MIBNF);
            
            MI_BNF_Header_Ex controller = new MI_BNF_Header_Ex(sc);
            Test.stopTest();
            controller.cancel();
            
            pg=controller.Redirect();
            System.assertEquals(pg,null);
        }  
        
    }
    
    //Setup MIBNF
    static void SetupMIBNF()
    {
        
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser1.Id;
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        
        insert new Profit_Centre__c(name='xz' ,ProfitCenterCode__c='USD');
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
        
        opp =new Opportunity(Name='Quick opp',StageName='1. Identifying Opportunity',Amount=2000,CloseDate=System.today(),
                             Contract_Term__c='Single-Period',Contract_Type__c='Individual');
        opp.LeadSource = 'Account Planning';
        opp.Budget_Available__c = 'Yes';
        //opp.Unique_Business_Value__c = 'Unknown';
        //opp.Compelling_Event__c = 'No';
        //opp.Main_Decision_Maker__c=MainDecisionMakerContact1.Id;
        //opp.Budget_Holder__c=MainDecisionMakerContact1.Id;
        // opp.Principal_In_Charge__c=PIC.Id;
        //opp.Exclude_From_Pricing_Calculator__c = true;
        insert opp;
        AddLineItems(opp);
        
        //Opportunity opp1 =new Opportunity(id=opp.Id);
        //opp1.StageName='7a. Closed Won';
        //opp1.Win_Loss_Reason__c='Win - Competitive Situation';
        //opp1.Win_Additional_Details__c = 'Additional details';
        //opp1.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        
        //update opp1;
        
        TestAddress_Array = new List<Address__c>();
        for (Integer i=0; i<10; i++)
        {
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Account__c=TestAccount.Id,
                                                    Street__c = 'Street ' + i.format(),
                                                    City__c = 'City '+ i.format(),
                                                    Country__c = 'Country ' + i.format(),
                                                    SAP_Reference__c = String.valueOf(495000+i),
                                                    MDM_Validation_Status__c = 'Validated');
            TestAddress_Array.add(TempAddress);
        } 
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
        Test.startTest();
        
    }
    
    //setting up component for MIBNF
    static void SetupMIBNF_Comp(MIBNF2__c RefMIBNF)
    {
        MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=RefMIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No';
        MIBNF_Comp.Bill_To__c=TestAddress_Array[0].Id;
        MIBNF_Comp.Ship_To__c=TestAddress_Array[0].id;
        
        insert MIBNF_Comp;
        
        
    }
    
    // AddLineItem to Opportunity
    static void AddLineItems(Opportunity O)
    {
        //  Add a line item to the opportunity
        
        OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = O.Id;
        Product2 Product1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH08', Business_Type__c = 'I&A', Material_Type__c = 'ZSET');
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
        //PricebookEntry PE1 = [select Id, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Business_Type__c = 'I&A' limit 1][0];
        OLI1.PricebookEntryId = Pbe.Id;
        OLI1.Quantity = 1.00;
        OLI1.TotalPrice=10000;
        OLI1.List_Price__c = 100;
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        insert OLI1;
        
    }
}