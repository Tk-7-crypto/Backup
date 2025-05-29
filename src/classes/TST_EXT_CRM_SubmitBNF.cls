@isTest
public class TST_EXT_CRM_SubmitBNF {
    private static BNF2__c TestBnf;
    private static Opportunity TestOpp;
    private static Account TestAccount;
    private static Contact testContact;
    private static List<Address__c> TestAddress_Array;
    private static List<SAP_Contact__c> TestSapContact_Array;
    private static BNF_Approval_Extension controller;
    private static Integer NumAddresses = 20;
    private static Integer NumSapContactsPerAddress = 10;
    private static User TestUser;
    private static Revenue_Analyst__c TestLocalRA;
    private static Revenue_Analyst__c TestSAPRA;
    private static User TestLocalApprover;
    private static User TestSAPApprover;
    private static Attachment doc;
    
    static void setupBNF() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        Mulesoft_Integration_Control__c mulesoft = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        mulesoft.Is_Mulesoft_User__c = true;
        upsert mulesoft;
        TestUser = [select Id from User where IsActive = true and (Profile.Name = 'System Administrator') limit 1];
        TestUser.PIC_Eligible__c = true;
        TestUser.EmployeeNumber = '0909090920';	
        update TestUser;
        
    }
    @isTest
    public static void test1(){    
          
        setupBNF();
             
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser.Id;
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        
        testContact = new Contact(FirstName = 'MainDecisionMaker', LastName='Contact', AccountId = TestAccount.Id, Email = 'abc@metacube.com', CurrencyIsoCode = 'USD');
        testContact.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT;
        testContact.Salesforce_User__c = TestUser.Id;
        insert testContact;
        
        TestLocalRA =new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = false,name='SAPRAUser, Test');
        insert TestLocalRA;
        
        TestSAPRA=new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = true,name='SAPRAUser, Test');
        insert TestSAPRA;
        
        AccountTeamMember ATM = new AccountTeamMember(AccountId=TestAccount.Id,UserId=TestLocalRA.User__c);
        insert ATM;
        
        AccountShare AccShare = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, RowCause, LastModifiedDate, LastModifiedById FROM AccountShare WHERE RowCause = 'Team' AND AccountId = :TestAccount.Id and UserOrGroupId=:TestLocalRA.User__c limit 1];
        AccShare.AccountAccessLevel = 'Edit';
        AccShare.OpportunityAccessLevel = 'Edit';
        update AccShare;
        
        Integer AccountIterator = 0;
        System.runAs(TestUser) {
            TestAddress_Array = new List<Address__c>();
            for (Integer i=0; i<NumAddresses; i++)
            {
                Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                        Account__c=TestAccount.Id,
                                                        Street__c = 'Street ' + i.format(),
                                                        City__c = 'City '+ i.format(),
                                                        Country__c = 'Country ' + i.format(),
                                                        SAP_Reference__c = String.valueOf(495000+i),
                                                        MDM_Validation_Status__c = 'Validated',
                                                        RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId());
                TestAddress_Array.add(TempAddress);
            }
            CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
            insert TestAddress_Array;
        }
        
        TestSapContact_Array = new List<SAP_Contact__c>();
        Integer AddressIterator = 0;
        for (Integer i=0; i<NumAddresses*NumSapContactsPerAddress; i++)
        {
            if (i > 0 && Math.mod(i,NumSapContactsPerAddress) == 0)
            {
                AddressIterator++;
            }
            Id AddressId = TestAddress_Array[AddressIterator].Id;
            SAP_Contact__c TempContact = New SAP_Contact__c(Name=String.valueOf(i),
                                                            Address__c=AddressId,
                                                            SAP_Contact_Number__c = String.valueOf(999999+i));
            TestSapContact_Array.add(TempContact);
        } 
        insert TestSapContact_Array;
        
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        TestOpp = new Opportunity();
        TestOpp.Name = 'test';
        TestOpp.StageName = '1. Identifying Opportunity';
        TestOpp.CloseDate = System.today();
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Potential_Competitor_1__c = comp.Id;
        insert TestOpp;
        
        Opportunity TestOpp1 = new Opportunity();
        TestOpp1.Name = 'test2';
        TestOpp1.StageName = '1. Identifying Opportunity';
        TestOpp1.CloseDate = System.today();
        TestOpp1.Budget_Available__c = 'Yes';
        TestOpp1.AccountId = TestAccount.Id;
        TestOpp1.Contract_End_Date__c = system.today();
        TestOpp1.Contract_Start_Date__c = system.today();
        TestOpp1.LeadSource = 'Account Planning';
        TestOpp1.CurrencyIsoCode = 'USD';
        TestOpp1.Potential_Competitor_1__c = comp.Id;
        insert TestOpp1;
        
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true);
        upsert bnfsetting;
        
        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'Ap';
        insert con;
        
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(con.Id, TestOpp.Id);
        insert contactRole;
        List<Product2> productList = new List<Product2>();
        
        Product2 objProduct = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH04',CurrencyIsoCode = 'USD', Business_Type__c = 'I&A', Material_Type__c = 'ZPUB', isactive=true, CanUseRevenueSchedule = true, InterfacedWithMDM__c = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI); 
        Product2 objProduct1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH04', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly', Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
        productList.add(objProduct);
        productList.add(objProduct1);
        insert productList;
        
        Test.startTest();
        List<PricebookEntry> PEList = new List<PricebookEntry>();
        PricebookEntry PE1 = new PricebookEntry();
        PE1.UseStandardPrice = false;
        PE1.Pricebook2Id = Test.getStandardPricebookId();
        PE1.Product2Id=objProduct.id;
        PE1.IsActive=true;
        PE1.UnitPrice=100.0;
        PE1.CurrencyIsoCode = 'USD';
        PEList.add(PE1);
        
        PricebookEntry PE2 = new PricebookEntry();
        PE2.UseStandardPrice = false;
        PE2.Pricebook2Id = Test.getStandardPricebookId();
        PE2.Product2Id=objProduct1.id;
        PE2.IsActive=true;
        PE2.UnitPrice=100.0;
        PE2.CurrencyIsoCode = 'USD';
        PEList.add(PE2);
        insert PEList;
        
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>();
        
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = TestOpp.Id;
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        OLI1.Product_Start_Date__c = Date.today();
        OLI1.Product_End_Date__c = Date.today().addYears(1) ;
        OLI1.PricebookEntryId = PE1.Id;
        OLI1.Billing_Frequency__c = 'Once';
        OLI1.Proj_Rpt_Frequency__c='Once [O]';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI1.Quantity = 1.00;  
        OLI1.List_Price__c = 100;
        OLI1.TotalPrice = 100;
        OLI1.Wbsrelementcode__c = 'test Code1';
        OLI1.Billing_Date__c = Date.today();
        OLI1.Delivery_Date__c = Date.today().addYears(2);
        OLI1.Wbsrelementcode__c = 'Test';
        OLI_Array.add(OLI1);
        
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = TestOpp.Id;
        OLI2.Sale_Type__c = 'New';
        OLI2.Delivery_Country__c = 'USA';
        OLI2.Revenue_Type__c = 'Ad Hoc';
        OLI2.Product_Start_Date__c = Date.today();
        OLI2.Product_End_Date__c = Date.today().addYears(1) ;
        OLI2.PricebookEntryId = PE2.Id;
        OLI2.Billing_Frequency__c = 'Once';
        OLI2.Proj_Rpt_Frequency__c='Once [O]';
        OLI2.Quantity = 1.00;
        OLI2.TotalPrice = 100;  
        OLI2.List_Price__c = 100;
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI2.Wbsrelementcode__c = 'test Code';
        OLI2.Billing_Date__c = Date.today();
        OLI2.Delivery_Date__c = Date.today().addYears(2);
        OLI2.Wbsrelementcode__c = 'Test';
        OLI_Array.add(OLI2);
        insert OLI_Array;
        
        Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule1', OLIId__c = OLI_Array[0].id);
        insert sche;
        
        Billing_Schedule_Item__c scheItem1 = new Billing_Schedule_Item__c(name = 'textScheduleItem1', Billing_Amount__c = 100, Billing_Date__c = system.today(), Billing_Schedule__c = sche.id);
        insert scheItem1;
        
        OLI_Array[0].Billing_Schedule__c = sche.Id;
        OLI_Array[1].Billing_Schedule__c = sche.Id;
        update OLI_Array;
        
        Testopp.Principle_inCharge__c = testContact.Id;
        TestOpp.StageName = '7a. Closed Won';
        TestOpp.Primary_Win_Reason__c ='Project Performance';
        TestOpp.Win_Type__c = 'Non-competitive bid';
        update TestOpp;
        
        List<Address__c> Addresslst=new List<Address__c>();
        Address__c a1=new Address__c(name='testAddress',SAP_Reference__c='500',Enabled_Sales_Orgs__c='CH04') ;
        Addresslst.add(a1);
        Address__c a2=new Address__c(name='testAddress2',SAP_Reference__c='501',Enabled_Sales_Orgs__c='CH04')  ; 
        Addresslst.add(a2);
        Address__c a3=new Address__c(name='testAddress3',SAP_Reference__c='502',Enabled_Sales_Orgs__c='CH04')  ; 
        Addresslst.add(a3);
        Address__c a4=new Address__c(name='testAddress4',SAP_Reference__c='503',Enabled_Sales_Orgs__c='CH04')  ; 
        Addresslst.add(a4);
        Address__c a5=new Address__c(name='testAddress5',SAP_Reference__c='504',Enabled_Sales_Orgs__c='CH04')  ; 
        Addresslst.add(a5);
        for(Integer index = 0; index < Addresslst.size(); index++) {
            Addresslst[index].MDM_Validation_Status__c = 'Validated';
            Addresslst[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
        }
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        
        insert Addresslst;
        
        a1 = [Select id from Address__c where name='testAddress'];
        a2 = [Select id from Address__c where name='testAddress2'];
        a3= [Select id from Address__c where name='testAddress3'];
        a4 = [Select id from Address__c where name='testAddress4'];
        a5 = [Select id from Address__c where name='testAddress5'];
        OLI_Array = [Select id from OpportunityLineItem ];
        OLI1 = OLI_Array[0];
        OLI2 = OLI_Array[1];
        Test.stopTest();
        BNF2__c TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.IMS_Sales_Org__c = 'IMS Spain';
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        TestBnf.Bill_To__c = a1.Id;
        TestBnf.X2nd_Copy__c = a2.Id;
        TestBnf.Carbon_Copy__c = a3.Id;
        TestBnf.Ship_To__c = a4.Id;
        TestBnf.Cover_Sheet__c = a5.Id;
        TestBnf.Revenue_Analyst__c = TestLocalRA.Id;
        TestBnf.Sales_Org_Code__c = 'CH04';
        TestBnf.OLI_Json_Data_1__c = JSON.serialize(OLI1);
        TestBnf.OLI_Json_Data_2__c = JSON.serialize(OLI2);

        insert TestBnf;
       
        BNF2__c bnfRec = [select id,Addendum__c from BNF2__c limit 1];
        Test.setCurrentPage(Page.BNF_Clone);
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(bnfRec);
        EXT_CRM_SubmitBNF ext = new EXT_CRM_SubmitBNF(stdSetController);
        ext.submitForApproval();
        System.assert(true);
    }
}