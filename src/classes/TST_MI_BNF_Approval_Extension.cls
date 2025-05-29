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
private class TST_MI_BNF_Approval_Extension {
   
    private static Opportunity TestOpp;
    private static Account TestAccount;
    private static List<Address__c> TestAddress_Array;
    private static List<SAP_Contact__c> TestSapContact_Array;
    private static List<Revenue_Analyst__c> TestRA_List;
    private static List<MIBNF_Component__c> TestMIBNF_Comp_List;
    private static MI_BNF_Approval_Extension controller;
    private static Integer NumAddresses = 3;
    private static Integer NumSapContactsPerAddress = 2;
    private static User TestUser;
    private static User TestLocalApprover;
    private static User TestSAPApprover;
    private static Attachment doc;
    private static MIBNF2__c MIBNF;
    private static Contact MainDecisionMakerContact1;
    private static OpportunityLineItem OLI1; 
    private static OpportunityLineItem OLI2;
    private static List<OpportunityLineItem> olijson1List = new List<OpportunityLineItem>();
    private static List<OpportunityLineItem> olijson2List = new List<OpportunityLineItem>();
    

  static testMethod void t1() 
    {
      
       
        system.runAs(TestUser)
        {
            setupOppAndBnf();
            test.starttest();
           System.debug('1.Number of Queries used in this apex code so far:***1.6******* ' + Limits.getQueries());
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
                       
        }
        
        TestLocalApprover = [select Id from User where Id = :TestRA_List[0].User__c];
              System.debug('1.Number of Queries used in this apex code so far:***1.7******* ' + Limits.getQueries());
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
            
             ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp_List[0]);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.SelectedRejectionReason= null;
            controller.SelectedMissingApproval = null;

            // Reject with error
            controller.SelectedRejectionReason= 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            pageReference pg=controller.Reject();
           // System.assertNotEquals(pg, null);
           // MIBNF_Component__c BNFStatus=[Select BNF_Status__c from MIBNF_Component__c where id=:TestMIBNF_Comp_List[0].id];
           // system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_REJECTED'),BNFStatus.BNF_Status__c);
            System.debug('1.Number of Queries used in this apex code so far:***1.8******* ' + Limits.getQueries());
            test.stoptest();
            System.debug('1.Number of Queries used in this apex code so far:***1.9******* ' + Limits.getQueries());
        }
      

        
    }
   
    static testMethod void t2() 
    {
      
       
        system.runAs(TestUser)
        {   
            setupOppAndBnf();
            test.starttest();
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
                           
        }
        
        TestLocalApprover = [select Id from User where Id = :TestRA_List[0].User__c];
      
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
             
             ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp_List[0]);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.SelectedMissingApproval = null;
            controller.SelectedRejectionReason= null;

            controller.ApproverComments = 'Rejected for testing';
            // Reject with error
            controller.SelectedRejectionReason= 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            pageReference pg=controller.Approve();
            
            ApexPages.Message msg = ApexPages.getMessages()[0];
            System.assertEquals('Please select a SAP Revenue Analyst to whom the BNF will be assigned', msg.getDetail());
            test.stoptest();
        }
      

        
    }
 
    static testMethod void t3() 
    {
       
       
        system.runAs(TestUser)
        {
            setupOppAndBnf();
            test.starttest();
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
                           
        }
        
        TestLocalApprover = [select Id from User where Id = :TestRA_List[0].User__c];
      
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
             
             ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp_List[0]);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.SelectedRejectionReason= null;
            controller.SelectedMissingApproval = null;
            controller.ApproverComments = 'Rejected for testing';
            // Reject with error
            controller.SelectedRejectionReason= 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Comp_Revenue_Analyst__c = TestRA_List[3].Id;
            pageReference pg=controller.Approve();
            
            //MIBNF_Component__c BNFStatus=[Select BNF_Status__c from MIBNF_Component__c where id=:TestMIBNF_Comp_List[0].id];
            //system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'),BNFStatus.BNF_Status__c);
            test.stoptest();
        }
      

        
    }


    static testMethod void t4() 
    {
        system.runAs(TestUser)
        {   
            setupOppAndBnf();
            test.starttest();
            System.debug('1.Number of Queries used in this apex code so far:***1.4******* ' + Limits.getQueries());
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
                           
        }
        
        TestLocalApprover = [select Id from User where Id = :TestRA_List[0].User__c];
        System.debug('1.Number of Queries used in this apex code so far:***1.5******* ' + Limits.getQueries());
        
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
             
             ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp_List[0]);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.SelectedRejectionReason= null;
            controller.SelectedMissingApproval = null;
            controller.ApproverComments = 'Rejected for testing';
            // Reject with error
            //controller.SelectedRejectionReason= 'Multiple Error';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Comp_Revenue_Analyst__c = TestRA_List[3].Id;
            pageReference pg=controller.Reject();
            
          
            //MIBNF_Component__c BNFStatus=[Select BNF_Status__c from MIBNF_Component__c where id=:TestMIBNF_Comp_List[0].id];
            //system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'),BNFStatus.BNF_Status__c);
            test.stoptest();
        }
      

        
    }
    
    static testMethod void t5() 
    {
        system.runAs(TestUser)
        {   
            setupOppAndBnf();
            test.starttest();
            
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());                          
        }
        
        TestLocalApprover = [select Id from User where Id = :TestRA_List[0].User__c];     
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
             
             ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp_List[0]);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.SelectedRejectionReason= null;
            controller.SelectedMissingApproval = null;

            controller.ApproverComments = 'Rejected for testing';
            // Reject with error
            controller.SelectedRejectionReason= 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Comp_Revenue_Analyst__c = TestRA_List[3].Id;
            controller.BNF.First_RA__c = TestRA_List[3].Id;
            pageReference pg=controller.Approve();
            //MIBNF_Component__c BNFStatus=[Select BNF_Status__c from MIBNF_Component__c where id=:TestMIBNF_Comp_List[0].id];
            //system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'),BNFStatus.BNF_Status__c);
            test.stoptest();
        }        
    }
    
    static testMethod void t6() 
    {
        system.runAs(TestUser)
        {   
            setupOppAndBnf();
            test.starttest();
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());                          
        }
        
        TestLocalApprover = [select Id from User where Id = :TestRA_List[0].User__c];     
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
             
             ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp_List[0]);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.SelectedMissingApproval = null;
            controller.SelectedRejectionReason= null;
            controller.RejectionReason = 'Any';
            controller.IsRejected = true;

            controller.ApproverComments = 'Rejected for testing';
            // Reject with error
            controller.SelectedRejectionReason= 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Comp_Revenue_Analyst__c = TestRA_List[3].Id;
            controller.BNF.First_RA__c = TestRA_List[3].Id;           
            pageReference pg=controller.Approve();
            
            Revenue_Analyst__c TestLocalRATemp = [select id, Is_SAP_Revenue_Analyst__c from Revenue_Analyst__c where id = :controller.BNF.Comp_Revenue_Analyst__c limit 1];
            TestLocalRATemp.Is_SAP_Revenue_Analyst__c = true;
            update TestLocalRATemp;
                
            MIBNF_Component__c TestBnfTemp = [Select id, Manual_Handling_in_SAP__c from MIBNF_Component__c where id = :controller.BNF.Id];            
            TestBnfTemp.Manual_Handling_in_SAP__c = true;
            update TestBnfTemp;
            
            test.stoptest();
            stc = new ApexPages.StandardController(TestBnfTemp);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            //MIBNF_Component__c BNFStatus=[Select BNF_Status__c from MIBNF_Component__c where id=:TestMIBNF_Comp_List[0].id];
            //system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'),BNFStatus.BNF_Status__c);
        }        
    }
    


    static void setupOppAndBnf() 
    {
         SetupMIBNF();
        
        List<Address__c> addList=new List<Address__c>();
        Address__c a1=new Address__c(name='testAddress',SAP_Reference__c='5000',Enabled_Sales_Orgs__c='CH04') ;
        Address__c a2=new Address__c(name='testAddress1',SAP_Reference__c='5001',Enabled_Sales_Orgs__c='CH04');
        addList.add(a1);
        addList.add(a2);
        for(Integer index = 0; index < addList.size(); index++) {
            addList[index].MDM_Validation_Status__c = 'Validated';
            addList[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
        }
        insert addList;
        //  Add a line item to the opportunity
        TestMIBNF_Comp_List=new List<MIBNF_Component__c>();
        
        for(integer counter=0;counter<=2;counter++)
        {
            MIBNF_Component__c TestBnf=new MIBNF_Component__c();
            TestBnf.MIBNF__c=MIbnf.Id;
            TestBnf.BNF_Status__c='New';
            TestBnf.Is_this_a_retainer_downpayment__c='No';
            TestBnf.Print_Shop__c='No';
            TestBnf.Bill_To__c=addList[0].Id;
            TestBnf.Ship_To__c=addList[0].Id;
            TestBnf.Carbon_Copy__c=addList[1].Id;
            TestBnf.Manual_Handling_in_SAP__c = true;
            TestBNF.OLI_Json_Data_1__c = JSON.serialize(olijson1List);
            TestBNF.OLI_Json_Data_2__c = JSON.serialize(olijson2List);
            TestMIBNF_Comp_List.add(TestBnf);
        }
        System.debug('1.Number of Queries used in this apex code so far:***1.2******* ' + Limits.getQueries());
        insert TestMIBNF_Comp_List;
        Database.executeBatch(new BCH_CRM_MIBNFSync(), 10);
        System.debug('1.Number of Queries used in this apex code so far:***1.3******* ' + Limits.getQueries());
        ApexPages.CurrentPage().getParameters().put('minfid' ,TestMIBNF_Comp_List[0].id );
        ApexPages.CurrentPage().getParameters().put('prdids' , OLI1.Id + ',' + OLI2.Id);
        MI_BNF_ADD_Product prdcontroller = new MI_BNF_ADD_Product();
        prdcontroller.selectedInvoice=TestMIBNF_Comp_List[0].Id;
        UTL_ExecutionControl.stopTriggerExecution = true;
        prdcontroller.save();
        UTL_ExecutionControl.stopTriggerExecution = false;

        System.debug('1.Number of Queries used in this apex code so far:***1.5******* ' + Limits.getQueries());
    }  
    
    //Setup MIBNF
    static void SetupMIBNF()
    {
        MIBNF=new MIBNF2__c();
        MIBNF.Client__c=Testopp.AccountId;
        MIBNF.Opportunity__c=Testopp.Id;
        MIBNF.Sales_Org_Code__c='CH03';
        MIBNF.Billing_Currency__c='USD';
        MIBNF.IMS_Sales_Org__c='Acceletra';
        MIBNF.Fair_Value_Type__c='Stand Alone';
        MIBNF.Invoice_Default_Day__c='15';
        MIBNF.Contract_Start_Date__c=system.today();
        MIBNF.Contract_End_Date__c=system.today();
        MIBNF.Contract_Type__c='Individual';
        MIBNF.Contract_Term__c='Single-Period';
        MIBNF.Payment_Terms__c='0000-Default Payment Terms of Customer Master Data';
        MIBNF.Revenue_Analyst__c=TestRA_List[0].Id;
        MIBNF.Renewal__c = true;
        MIBNF.SAP_Master_Contract__c = null;
        insert MIBNF;
        System.debug('1.Number of Queries used in this apex code so far:****1.1****** ' + Limits.getQueries());
    }
    
    static
    {
        UTL_ExecutionControl.stopTriggerExecution = true;
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        TestUser = [select Id from User where IsActive = true and (Profile.Name like '%system administrator%') limit 1];
   		
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser.Id;
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
           
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 2);
        userList.addall(UTL_TestData.createUser('Sales User', 1));
        insert userList;
        
        Contact cnt = UTL_TestData.createContact(TestAccount.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = userList[0].Id;
        insert cnt;
        
        //MainDecisionMakerContact1=[Select Account.Status__c, Account.Id, AccountId From Contact where Account.Status__c='SAP VALIDATED' limit 1];
        //TestAccount=[select id,name from Account where id=:MainDecisionMakerContact1.Account.id];
        
        TestRA_List=new List<Revenue_Analyst__c>();
        Revenue_Analyst__c TestLocalRA =new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = false,name='SAPRAUser1, Test1');
        Revenue_Analyst__c TestLocalRA1 =new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = true,RA_Sales_Orgs__c='CH03',name='SAPRAUser1, Test1');
        Revenue_Analyst__c TestSAPTRUERA=new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = true,name='SAPRAUser2, Test2');
        Revenue_Analyst__c TestSAPRA=new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = true,RA_Sales_Orgs__c='CH04',name='SAPRAUser3, Test3');
        
        TestRA_List.add(TestLocalRA);
        TestRA_List.add(TestLocalRA1);
         TestRA_List.add(TestSAPTRUERA);
        TestRA_List.add(TestSAPRA);
        insert TestRA_List;
     
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        TestOpp =new Opportunity(Name='Quick opp',StageName='1. Identifying Opportunity',Amount=2000,CloseDate=System.today(),
        Contract_Term__c='Single-Period',Contract_Type__c='Individual',CurrencyIsoCode = 'USD');
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        TestOpp.Contract_Start_Date__c=system.today();
        TestOpp.Contract_End_Date__c=system.today();
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Compelling_Event__c = 'No';
        //TestOpp.Main_Decision_Maker__c=MainDecisionMakerContact1.Id;
        //TestOpp.Budget_Holder__c=MainDecisionMakerContact1.Id;
      //  TestOpp.Principal_In_Charge__c=PIC.Id;
        TestOpp.Potential_Competitor_1__c = comp.Id;
        
        insert TestOpp;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, TestOpp.Id);
            insert contactRole;
        
        BNF_Settings__c bnfsetting= BNF_Settings__c.getInstance();
        if(bnfsetting== null)
        {
           bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true);
           insert bnfsetting;
        }
        
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>();
        OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = TestOpp.Id;
        
        Product2 objProduct = new Product2(Name='test4', ProductCode='4', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZPUB',CanUseRevenueSchedule= true, IsActive = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
        objProduct.Pillar__c = 'Technology Solutions; Information Offering';
        insert objProduct;
        
        PricebookEntry PE1 = new PricebookEntry();
        PE1.UseStandardPrice = false;
        PE1.Pricebook2Id = Test.getStandardPricebookId();
        PE1.Product2Id=objProduct.id;
        PE1.IsActive=true;
        PE1.UnitPrice=100.0;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;
        //PricebookEntry PE1 = [select Id, CurrencyIsoCode,Product2Id from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        //Product2 p1=[Select Enabled_Sales_Orgs__c from Product2 where  Id =:PE1.Product2Id limit 1][0];
        //p1.Enabled_Sales_Orgs__c='CH03';
        //upsert p1;
        
        OLI1.PricebookEntryId = PE1.Id;
        OLI1.Quantity = 1.00;
        OLI1.UnitPrice = 10000;
        OLI1.List_Price__c=1000;
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        
        OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = TestOpp.Id;
        OLI2.PricebookEntryId = PE1.Id;
        OLI2.Quantity = 1.00;
        OLI2.UnitPrice = 10000;
        OLI2.List_Price__c=1000;
        OLI2.Sale_Type__c = 'New';
        OLI2.Delivery_Country__c = 'USA';
        OLI2.Revenue_Type__c = 'Ad Hoc';
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI_Array.add(OLI2);
        OLI_Array.add(OLI1);
        //insert OLI1;
        insert OLI_Array;
        olijson1List.add(OLI1);
        olijson2List.add(OLI2);
        Opportunity opp1 =new Opportunity(id=TestOpp.Id);
        opp1.StageName='7a. Closed Won';
        //opp1.Win_Loss_Reason__c='Win - Competitive Situation';
        //opp1.Win_Additional_Details__c = 'Additional details';
        //opp1.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        opp1.Primary_Win_Reason__c ='Project Performance';
        opp1.Win_Type__c = 'Non-competitive bid';
        opp1.Potential_Regions__c = 'Asia Pacific';
        opp1.QI_Invited_to_Present__c = 'No';
        opp1.FPI_Date__c = system.today();
        opp1.Population_Age_Group__c = 'Not Applicable';
        update opp1;
        System.debug('1.Number of Queries used in this apex code so far:***1.0******* ' + Limits.getQueries());
        UTL_ExecutionControl.stopTriggerExecution = false;
    }
    
    static testMethod void t7() {
          
        system.runAs(TestUser)
        {    
            test.starttest();
            setupOppAndBnf();
           System.debug('1.Number of Queries used in this apex code so far:***1.6******* ' + Limits.getQueries());
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
               ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp_List[0]);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            controller.ApproverComments = null;
            controller.Reject();
            
       
        
        } 
        
    }
    
    static testMethod void t8() 
    {
        system.runAs(TestUser)
        {   
            setupOppAndBnf();
            test.starttest();
            System.debug('1.Number of Queries used in this apex code so far:***1.4******* ' + Limits.getQueries());
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
                           
        }
        
            MIBNF_Component__c TestBnfTemp = [Select id, Manual_Handling_in_SAP__c, Comp_Revenue_Analyst__c from MIBNF_Component__C limit 1];
			TestBnfTemp.Manual_Handling_in_SAP__c = false;  
            upsert TestBnfTemp;
            Revenue_Analyst__c TestLocalRATemp = [select id, Is_SAP_Revenue_Analyst__c from Revenue_Analyst__c  where id = :TestBnfTemp.Comp_Revenue_Analyst__c];
            TestLocalRATemp.Is_SAP_Revenue_Analyst__c = true;
            upsert TestLocalRATemp;
        	ApexPages.StandardController stc = new ApexPages.StandardController(TestBnfTemp);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
    }
    
    static testMethod void t9() 
    {
        system.runAs(TestUser)
        {
            setupOppAndBnf();
            test.starttest();
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());                          
        }
        
        TestLocalApprover = [select Id from User where Id = :TestRA_List[0].User__c];     
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
             
             ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp_List[0]);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.SelectedRejectionReason= null;
            controller.SelectedMissingApproval = null;

            controller.ApproverComments = 'Rejected for testing';
            // Reject with error
            controller.SelectedRejectionReason= 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Comp_Revenue_Analyst__c = TestRA_List[1].Id;
            controller.BNF.First_RA__c = TestRA_List[1].Id;
            pageReference pg=controller.Approve();
            //MIBNF_Component__c BNFStatus=[Select BNF_Status__c from MIBNF_Component__c where id=:TestMIBNF_Comp_List[0].id];
            //system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'),BNFStatus.BNF_Status__c);
            test.stoptest();
        }        
    }
    
    static testMethod void t10() 
    {
        system.runAs(TestUser)
        {
            setupOppAndBnf();
            test.starttest();
            System.debug('1.Number of Queries used in this apex code so far:***1.4******* ' + Limits.getQueries());
            pageReference BnfApprovalPage = Page.MI_BNF_Comp_Submit_Approval;
            BnfApprovalPage.getParameters().put('id',TestMIBNF_Comp_List[0].Id);
       
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest req1;
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestMIBNF_Comp_List[0].Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
                           
        }
        
            MIBNF_Component__c TestBnfTemp = [Select id, Manual_Handling_in_SAP__c, Comp_Revenue_Analyst__c from MIBNF_Component__C limit 1];
			TestBnfTemp.Manual_Handling_in_SAP__c = false;  
            upsert TestBnfTemp;
            Revenue_Analyst__c TestLocalRATemp = [select id, Is_SAP_Revenue_Analyst__c from Revenue_Analyst__c  where id = :TestBnfTemp.Comp_Revenue_Analyst__c];
            TestLocalRATemp.Is_SAP_Revenue_Analyst__c = false;
            upsert TestLocalRATemp;
        	ApexPages.StandardController stc = new ApexPages.StandardController(TestBnfTemp);
            //  Create an instance of the controller extension       
            controller = new MI_BNF_Approval_Extension(stc);
            controller.Init();
    }
    
    static testMethod void t11(){
        Test.startTest();
        setupOppAndBnf();
        MIBNF_Component__c mibnfComp = [Select Id from MIBNF_Component__c Limit 1];
        MIBNF2__c mibnf = [Select Id from MIBNF2__c Limit 1];
        
        MI_BNF_Approval_Extension.AttachPdf(mibnfComp.Id, mibnf.Id, 'bnfName', 'test', System.today());
        Test.stopTest();
    }
    
}