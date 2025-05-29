@isTest
private class TST_EXT_CRM_Recall_Approval_Request {
    private static BNF2__c TestBnf;
    private static Opportunity TestOpp;
    private static Account TestAccount;
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
    private static List<OpportunityLineItem> olijson1List = new List<OpportunityLineItem>();
    private static List<OpportunityLineItem> olijson2List = new List<OpportunityLineItem>();
    
    static void setupOpp() 
    {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        //TestUser = [select Id from User where IsActive = true and (not Profile.Name like '%administrator%') and (not Profile.Name like '%operations%') and (not Profile.Name like '%Chatter%') limit 1];
        TestUser = [select Id from User where IsActive = true and (Profile.Name = 'System Administrator') limit 1];
        //system.debug('TestUser.Profile.Name' + TestUser.Profile.Name);
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser.Id;
        TestAccount.AccountCountry__c = 'AF';
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        
        //TestLocalRA = [select Id,Name,User__c from Revenue_Analyst__c where User__r.IsActive = true and Is_SAP_Revenue_Analyst__c = false limit 1];
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
        
        TestOpp = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Potential_Competitor_1__c = comp.Id;
        insert TestOpp;
        
        BNF_Settings__c bnfsetting= BNF_Settings__c.getInstance();
        if(bnfsetting== null)
        {
            bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true);
            insert bnfsetting;
        }
        Contact con = new Contact();
        con.FirstName = 'testFirstName';
        con.LastName = 'Ap';
        insert con;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(con.Id, TestOpp.Id);
        insert contactRole;
        
        //  Add a line item to the opportunity
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>();
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = TestOpp.Id;
        
        Product2 objProduct = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH08',CurrencyIsoCode = 'USD', Business_Type__c = 'I&A', Material_Type__c = 'ZPUB', isactive=true, CanUseRevenueSchedule = true, InterfacedWithMDM__c = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI); 
        insert objProduct;
        
        PricebookEntry PE1 = new PricebookEntry();
        PE1.UseStandardPrice = false;
        PE1.Pricebook2Id = Test.getStandardPricebookId();
        PE1.Product2Id=objProduct.id;
        PE1.IsActive=true;
        PE1.UnitPrice=100.0;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;
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
        OLI1.UnitPrice = 10000;  
        OLI1.List_Price__c = 100;
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI1.Billing_Date__c = Date.today();
        OLI1.Delivery_Date__c = Date.today().addYears(2);
        OLI_Array.add(OLI1);
        //insert OLI1;
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = TestOpp.Id;
        PricebookEntry PE2 = [select Id, CurrencyIsoCode,Product2Id from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        Product2 p2=[Select Enabled_Sales_Orgs__c from Product2 where Id=:PE2.Product2Id limit 1 ][0];
        p2.Enabled_Sales_Orgs__c='CH04';
        upsert p2;
        OLI2.OpportunityId = TestOpp.Id;
        OLI2.Sale_Type__c = 'New';
        OLI2.Delivery_Country__c = 'USA';
        OLI2.Revenue_Type__c = 'Ad Hoc';
        OLI2.Product_Start_Date__c = Date.today();
        OLI2.Product_End_Date__c = Date.today().addYears(1) ;
        OLI2.PricebookEntryId = PE2.Id;
        OLI2.Billing_Frequency__c = 'Once';
        OLI2.Proj_Rpt_Frequency__c='Once [O]';
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI2.Quantity = 1.00;
        OLI2.UnitPrice = 10000;  
        OLI2.List_Price__c = 100;   
        OLI2.Delivery_Country__c = 'USA';
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI2.Billing_Date__c = Date.today();
        OLI2.Delivery_Date__c = Date.today().addYears(2);
        OLI_Array.add(OLI2);
        insert OLI_Array;
        olijson1List.add(OLI1);
        olijson2List.add(OLI2);
        TestOpp.StageName = '7a. Closed Won';
        TestOpp.Primary_Win_Reason__c ='Project Performance';
        TestOpp.Win_Type__c = 'Non-competitive bid';
        UTL_ExecutionControl.stopTriggerExecution = true;
        update TestOpp;
        UTL_ExecutionControl.stopTriggerExecution = false;
    }  
    
    static void setupBNF(String ApproverID,Boolean isSAPBNF)
    {
        
        List<Address__c> Addresslst=new List<Address__c>();
        Address__c a1=new Address__c(name='testAddress',SAP_Reference__c='500',Enabled_Sales_Orgs__c='CH03') ;
        Addresslst.add(a1);
        Address__c a2=new Address__c(name='testAddress2',SAP_Reference__c='501',Enabled_Sales_Orgs__c='CH03')  ; 
        Addresslst.add(a2);
        Address__c a3=new Address__c(name='testAddress3',SAP_Reference__c='502',Enabled_Sales_Orgs__c='CH03')  ; 
        Addresslst.add(a3);
        Address__c a4=new Address__c(name='testAddress4',SAP_Reference__c='503',Enabled_Sales_Orgs__c='CH03')  ; 
        Addresslst.add(a4);
        Address__c a5=new Address__c(name='testAddress5',SAP_Reference__c='504',Enabled_Sales_Orgs__c='CH03')  ; 
        Addresslst.add(a5);
        for(Integer index = 0; index < Addresslst.size(); index++) {
            Addresslst[index].MDM_Validation_Status__c = 'Validated';
            Addresslst[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
        }
        insert Addresslst;
        
        TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.IMS_Sales_Org__c = 'IMS Spain';
        if(isSAPBNF)
            TestBnf.RecordTypeId =MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        TestBnf.Bill_To__c=a1.Id;
        TestBnf.X2nd_Copy__c=a2.Id;
        TestBnf.Carbon_Copy__c=a3.Id;
        TestBnf.Ship_To__c=a4.Id;
        TestBnf.Cover_Sheet__c=a5.Id;
        TestBnf.Revenue_Analyst__c = ApproverID;
        TestBnf.Sales_Org_Code__c='CH04';
        TestBnf.OLI_Json_Data_1__c = JSON.serialize(olijson1List);
        TestBnf.OLI_Json_Data_2__c = JSON.serialize(olijson2List);
        insert TestBnf;
        
        Blob pdfContent = Blob.valueOf('xxxxxxxxxxxxxx');
        String FileName = 'abcdlc.pdf';       
        FileName = FileName.replace('/', '_');
        FileName = FileName.replace('\\', '_'); 
        doc = new Attachment(
            ParentId = TestBnf.Id,
            Body = pdfContent,
            Name = FileName,
            ContentType = 'application/pdf');     
        insert doc;
    }
    
    
    testmethod static void testRecall_Request(){ 
        setupOpp();        
        setupBNF(TestLocalRA.Id,false);
        
        Database.executeBatch(new BCH_CRM_BNFSync(), 10);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        
        Test.startTest();
        system.runAs(TestUser)
        {
            BNF_Test_Data.create_User_LocaleSetting();
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestBnf.Id);
            result = Approval.process(req1);
        }
        Test.setCurrentPage(Page.VFP_CRM_Recall_Approval_Request);
        ApexPages.currentPage().getParameters().put('id',TestBnf.id);
        EXT_CRM_Recall_Approval_Request approve = new EXT_CRM_Recall_Approval_Request();
        approve.recall_Request();
        approve.Cancel();
        Test.stopTest();
    }
}