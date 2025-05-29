/*
 * Version       : 1.0
 * Description   : Utility Class for Creating Records
 */
public class UTL_TestData {  
    
    /** 
     * This method used to insert Account 
     * @return  Account
     */
    public static Account createAccount() {
        return new Account(Name = 'TestAccount', BillingStreet = 'testStreet', BillingCity = 'testCity', BillingCountry = 'testCountry', BillingPostalCode = '123465',AccountCountry__c = 'AF',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
    }
    
    /**
     * This method used to insert Contact
     * @params  Id accountId
     * @return  Contact
     */
    public static Contact createContact(Id accountId) {
        return new Contact(FirstName = 'TestFirstName', LastName = 'TestContact', accountId = accountId);
    }
    
    /**
     * This method used to insert Contacts
     * @params  Id accountId
     * @params  Integer noOfContact
     * @return  Contact
     */
    public static List<Contact> createContacts(Id accountId, Integer noOfContact) {
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0; i < noOfContact; i++) {
            contactList.add(new Contact(FirstName = 'TestFirstName', LastName = 'TestContact' + i, accountId = accountId));
        }
        return contactList;
    }
    
    /**
     * This method used to insert Lead
     * @return  Lead
     */
    public static Lead createLead() {
        return new Lead(FirstName = 'TestLead', Email = 'test@gmail.com', Country = 'USA' ,LastName = 'TestLead', Status = 'New', Company = 'Metacube',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
    }
    
    /**
     * This method used to insert Contract
     * @return  Contract
     */
    public static Contract createContract(Opportunity opp, String recordTypeDevName) {
        Contract newContract = new Contract(AccountId = opp.AccountId, ContractTerm = 12, StartDate = opp.CloseDate, OwnerExpirationNotice = '30');
        newContract.recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        return newContract;
    }
    
    /**
     * This method used to insert Contract In/Out Log Record
     * @return  Contract_In_Out_Log__c
     */
    public static Contract_In_Out_Log__c createContractInOutLog(Contract ctr) {
        Contract_In_Out_Log__c newInOutLog = new Contract_In_Out_Log__c();
        newInOutLog.Contract__c = ctr.Id;
        return newInOutLog;
    }

    /**
     * This method used to insert Opportunity put Stage at your end
     * @params  Id accountId
     * @return  Opportunity
     */
    public static Opportunity createOpportunity(Id accountId) {
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        Competitor__c Competitor = createCompetitor();
        insert Competitor;
        
        Opportunity opp = new Opportunity();
        opp.Potential_Competitor_1__c = Competitor.Id;
        opp.Phase_P__c =  'Phase 1';
        opp.Name = 'TestOpportunity';
        opp.Indication_List__c = indication.Id;
        opp.accountId = accountId;
        opp.stageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp.CloseDate = System.today().addYears(1);
        opp.Probability = 10;
        opp.Budget_Available__c = 'Yes';
        opp.Contract_Start_Date__c = system.today();
        opp.Contract_End_Date__c = system.today().addYears(1);
        opp.LeadSource = 'Account Planning';
        opp.CurrencyIsoCode = 'USD';
        opp.Line_of_Business__c = 'Commercial Solutions';
        opp.Is_this_a_renewal__c = 'No';
        opp.Proposal_Sent_Date__c = system.today();
        //opp.Principle_inCharge__c = testContact.Id;
        opp.Primary_Win_Reason__c ='Project Performance';
        opp.Win_Type__c = 'Non-competitive bid';
        opp.Is_this_IQVIA_Biotech__c = 'No';
        opp.Path_Probability__c = 'Potential';
        opp.Drug_Product_Name__c = 'Health Product';
        opp.Global_project_unit__c = 'AA/Japan';
        opp.US_government_fully_or_partially_funded__c = 'No';
        opp.Pass_through_Expenses__c = 100;
        return opp;
    }

    /**
     * This method used to insert OpportunityContactRole
     * @params  Id accountId
     * @params  Id opportunityId
     * @return  OpportunityContactRole
     */
    public static OpportunityContactRole createOpportunityContactRole(Id contactId, Id opportunityId) {
        return new OpportunityContactRole(contactId = contactId, role = 'Business User', opportunityId = opportunityId);
    }
    
    /**
     * This method used to insert Product update Material_Type__c either 'ZREP' or 'ZPUB'
     * @return  Product2
     */
    public static Product2 createProduct() {
        return new Product2(Name = 'TestProduct', ProductCode = '1234', isActive = true, CanUseRevenueSchedule = true, InterfacedWithMDM__c = true, Enabled_Sales_Orgs__c = 'CH04', CurrencyIsoCode = 'USD', Delivery_Media__c = 'DVD [DV]:CD [CD]', Delivery_Frequency__c = 'Monthly:Quaterly', Business_Type__c = 'I&A',Pillar__c = 'Information Offering;Technology Solutions');
    }
    
    /**
     * This method used to insert Favorite Product
     * @return  Product2
     */
    public static Favorite_Product__c createFavoriteProduct(Product2 product) {
        return new Favorite_Product__c(Product__c = product.Id, User__c = UserInfo.getUserId());
    }

    /**
     * This method used to insert PricebookEntry
     * @return  PricebookEntry
     */
    public static PricebookEntry createPricebookEntry(Id productId) {
        return new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),CurrencyIsoCode = 'USD', Product2Id = productId, UnitPrice = 100.00, isActive = true);
    }
    
    /**
     * This method used to insert OpportunityLineItem
     * @params  Id opportunityId
     * @params  Id pricebookEntryId
     * @return  OpportunityLineItem
     */
    public static OpportunityLineItem createOpportunityLineItem(Id opportunityId, Id pricebookEntryId) {
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunityId, PricebookEntryId = pricebookEntryId, Quantity = 1, TotalPrice = 100, Delivery_Country__c = 'USA', Sale_Type__c = 'New', Revenue_Type__c = 'Ad Hoc');
        oli.Delivery_Country__c = 'India';
        oli.Product_Start_Date__c = Date.today();
        oli.Product_End_Date__c = Date.today().addYears(1);
        oli.Billing_Frequency__c = 'Once';
        oli.Proj_Rpt_Frequency__c='Once [O]';
        oli.Therapy_Area__c= 'Hepatitis C [21]';
        oli.List_Price__c = 100;
        oli.Wbsrelementcode__c = 'test Code1';
        oli.Billing_Date__c = Date.today();
        oli.Delivery_Date__c = Date.today().addYears(2);
        return oli;
    }
    
    /**
     * This method used to insert Billing_Schedule__c
     * @return  Billing_Schedule__c
     */
    public static Billing_Schedule__c createBillingSchedule(Id oliId) {
        return new Billing_Schedule__c(name = 'textSchedule1', oliId__c = oliId);
    }
    
    /**
     * This method used to insert Billing_Schedule_Item__c
     * @return  Billing_Schedule_Item__c
     */
    public static Billing_Schedule_Item__c createBillingScheduleItem(Id bilingScheduleId) {
        return new Billing_Schedule_Item__c(name = 'textScheduleItem1', Billing_Amount__c = 100, Billing_Date__c = system.today(), Billing_Schedule__c = bilingScheduleId);
    }
    
    
    /**
     * This method used to insert DefaultProductSearch
     * @return  Default_Product_Search__c
     */
    public static Default_Product_Search__c createDefaultProductSearch(Id userId) {
        return new Default_Product_Search__c(User__c = userId);
    }
    
    
    
    /**
     * This method used to insert OpportunitySplit
     * @return  OpportunitySplit
     */
    public static OpportunitySplit createOpportunitySplit(Id opportunityId, Id userId, Id splitTypeId) {
        return new OpportunitySplit(OpportunityId = opportunityId, SplitOwnerId = userId, splitTypeId = splitTypeId, SplitPercentage = 100, SplitNote = 'Test');
    }
    
    /**
     * This method used to insert OpportunityTeamMember
     * @return  OpportunityTeamMember
     */
    public static OpportunityTeamMember createOpportunityTeamMember(Id opportunityId, Id userId) {
        return new OpportunityTeamMember(OpportunityId = opportunityId, UserId = userId, TeamMemberRole = 'Account Director', OpportunityAccessLevel = 'Edit');
    }
    
    /**
     * This method used to insert User List
     * @return  List<User>
     */
    public static List<User> createUser(String profileName, Integer noOfUser) {
        List<User> userList = new List<User>();
        for(Integer index = 0; index < noOfUser; index++) {
            userList.add(new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
                LastName = 'lastName123',
                Email = 'testuser3133@iqvia.com',
                Username = 'testuser3133@imshealth.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alia3133',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Q1_Target__c = 1.0,
                Change_Request_Description__c = 'test',
                Change_Request_Ticket_Number__c ='test description',
                employeenumber= String.valueOf(System.currentTimeMillis()) + index
            ));
        }
        return userList;
    }
    
    /**
     * This method used to insert Competitor
     * @return  Competitor
     */
    public static Competitor__c createCompetitor() {
        return new Competitor__c(Name = 'TestCompetitor');
    }
    
    /**
     * This method used to insert OpportunityLineItem
     * @params  Id OpportunityLineItemId
     * @return  OpportunityLineItemSchedule
     */
    public static OpportunityLineItemSchedule createOpportunityLineItemSchedule(Id OpportunityLineItemId) {
        return new OpportunityLineItemSchedule(OpportunityLineItemId = OpportunityLineItemId, Revenue = 100, Description = 'Test', Type = 'Revenue', ScheduleDate = system.today());
    }
    
    /**
     * This method used to insert BNF2__c record
     * @params  Id opportunityId
     * @params  OpportunityLineItem oli
     * @params  List<Id> addressList
     * @params  Id revenueAnalystId
     * @return  BNF2__c
     */
    public static BNF2__c createBNFRecord(Opportunity opp, OpportunityLineItem oli, List<Address__c> addressList, Id revenueAnalystId) {
        BNF2__c TestBnf = new BNF2__c();
        TestBnf.Opportunity__c = opp.Id;
        TestBNF.Opportunity_Number__c = opp.Opportunity_Number__c;
        TestBnf.BNF_Status__c = 'New';
        TestBnf.IMS_Sales_Org__c = 'IMS Spain';
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        TestBnf.Bill_To__c = addressList[0].Id;
        TestBnf.X2nd_Copy__c = addressList[1].Id;
        TestBnf.Carbon_Copy__c = addressList[2].Id;
        TestBnf.Ship_To__c = addressList[3].Id;
        TestBnf.Cover_Sheet__c = addressList[4].Id;
        TestBnf.Revenue_Analyst__c = revenueAnalystId;
        TestBnf.Sales_Org_Code__c = 'CH04';
        TestBnf.OLI_Json_Data_1__c = JSON.serialize(oli);
        return TestBnf;
    }
    public static MIBNF2__c createMIBNF(Opportunity TestOpp,Revenue_Analyst__c TestLocalRA){
        MIBNF2__c TestMIBNF=new MIBNF2__c();
        TestMIBNF.Client__c=TestOpp.AccountId;
        TestMIBNF.Opportunity__c=TestOpp.Id;
        TestMIBNF.Sales_Org_Code__c='CH08';
        TestMIBNF.Billing_Currency__c='USD';
        TestMIBNF.IMS_Sales_Org__c='Acceletra';
        TestMIBNF.Fair_Value_Type__c='Stand Alone';
        TestMIBNF.Invoice_Default_Day__c='15';
        TestMIBNF.Contract_Start_Date__c=system.today();
        TestMIBNF.Contract_End_Date__c=system.today();
        TestMIBNF.Contract_Type__c='Individual';
        TestMIBNF.Contract_Term__c='Single-Period';
        TestMIBNF.IMS_Sales_Org__c = 'IMS Spain';
        TestMIBNF.Payment_Terms__c='0000-Default Payment Terms of Customer Master Data';
        TestMIBNF.Revenue_Analyst__c = TestLocalRA.id;
        return TestMIBNF;
    }
    public static MIBNF_Component__c createMIBNF_Comp(MIBNF2__c TestMIBNF,List<Address__c> TestAddress_Array){
        MIBNF_Component__c TestMIBNF_Comp=new MIBNF_Component__c();
        TestMIBNF_Comp.MIBNF__c=TestMIBNF.Id;
        TestMIBNF_Comp.BNF_Status__c='New';
        TestMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        TestMIBNF_Comp.Print_Shop__c='No';
        TestMIBNF_Comp.Bill_To__c=TestAddress_Array[0].id;
        TestMIBNF_Comp.X2nd_Copy__c=TestAddress_Array[1].id;
        TestMIBNF_Comp.Carbon_Copy__c=TestAddress_Array[2].id;
        TestMIBNF_Comp.Ship_To__c=TestAddress_Array[3].id;
        TestMIBNF_Comp.Cover_Sheet__c=TestAddress_Array[4].id;
        return TestMIBNF_Comp;
    }
    
    public static MI_BNF_LineItem__c createMIBNFLineItem(Id mibnfCompId, OpportunityLineItem oli){
        MI_BNF_LineItem__c TestMI_BNFLineItem = new MI_BNF_LineItem__c();
        TestMI_BNFLineItem.MIBNF_Component__c = mibnfCompId;
        TestMI_BNFLineItem.Opportunity_Line_Itemid__c = oli.Id;
        TestMI_BNFLineItem.Total_Price__c = oli.TotalPrice;
        return TestMI_BNFLineItem;
    }
    
    public static List<Billing_Schedule__c> createBillingSchedules(List<OpportunityLineItem> olis){
        List<Billing_Schedule__c> billingSchedule = new List<Billing_Schedule__c>();
        Integer i = 0;
        for(OpportunityLineItem oli: olis){
            Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule'+i, OLIId__c = oli.id);
            i++;
            billingSchedule.add(sche);
        }
        return billingSchedule;
    }
    
    public static List<Billing_Schedule_Item__c> createBillingScheduleItems(List<Billing_Schedule__c> billingSchedule){
        List<Billing_Schedule_Item__c> billingScheduleItem = new List<Billing_Schedule_Item__c>();
        Integer i = 0;
        for(Billing_Schedule__c bs: billingSchedule){
            Billing_Schedule_Item__c sche1 = new Billing_Schedule_Item__c(name = 'textScheduleItem'+i, Billing_Amount__c = 2000,Billing_Date__c = system.today(),Billing_Schedule__c = billingSchedule[i].id);
            Billing_Schedule_Item__c sche2 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp'+i, Billing_Amount__c = 3000, Billing_Date__c = system.today().addYears(1),Billing_Schedule__c = billingSchedule[i].id);
            billingScheduleItem.add(sche1);
            billingScheduleItem.add(sche2);
            i++;
        }
        return billingScheduleItem;
    }
    
    /**
     * This method used to insert Address Record
     * @params  Account TestAccount
     * @return List<Address__c>
     */
    public static List<Address__c> createAddresses(Account TestAccount){
        List<Address__c> TestAddress_Array = new List<Address__c>();
        for (Integer i = 0; i < 5; i++) {
            Address__c TempAddress = new Address__c();
            TempAddress.Name = String.valueOf(i);
            TempAddress.Enabled_Sales_Orgs__c='IHA, IMS Health Rotkreuz [CH03]';
            TempAddress.Account__c=TestAccount.Id;
            TempAddress.Street__c = 'Street ' + i.format();
            TempAddress.City__c = 'City '+ i.format();
            TempAddress.Country__c = 'Country ' + i.format();
            TempAddress.SAP_Reference__c = String.valueOf(495000+i);
            TempAddress.International_Name__c = 'Test Address Name' + i;
            TempAddress.MDM_Validation_Status__c = 'Validated';
            TestAddress_Array.add(TempAddress);
        } 
        return TestAddress_Array;
    }
    
    /**
     * This method used to insert SAP_Contact__c Records
     * @params  List<Address__c> addressList
     * @return List<SAP_Contact__c>
     */
    public static List<SAP_Contact__c> createSAPContacts(List<Address__c> addressList){
        List<SAP_Contact__c> TestSapContact_Array = new List<SAP_Contact__c>();
        for (Integer i = 0; i < 5; i++) {
            SAP_Contact__c newSAPContact = New SAP_Contact__c();
            newSAPContact.Name= 'TestSAPContact' + String.valueOf(i);
            newSAPContact.Address__c = addressList[i].Id;
            newSAPContact.SAP_Contact_Number__c = String.valueOf(999999 + i);
            TestSapContact_Array.add(newSAPContact);
        }
        return TestSapContact_Array;
    }
    
    /**
     * This method used to insert MDM_Invoicing_Transaction__c Record
     * @params  Address__c add
     * @params List<SAP_Contact__c> sapContactList
     * @return MDM_Invoicing_Transaction__c
     */
    public static MDM_Invoicing_Transaction__c createMDMInvoiceTransaction(Address__c add, List<SAP_Contact__c> sapContactList){
        MDM_Invoicing_Transaction__c mit = new MDM_Invoicing_Transaction__c();
        mit.Address__c = add.Id;
        mit.SAP_Contact_1__c = (sapContactList.size() > 0) ? sapContactList[0].Id : null;
        mit.SAP_Contact_2__c = (sapContactList.size() > 1) ? sapContactList[1].Id : null;
        mit.SAP_Contact_3__c = (sapContactList.size() > 2) ? sapContactList[2].Id : null;
        mit.Sales_org__c = 'AE01';
        mit.Type__c = '1';
        return mit;
    }
    /**
     * This method used to insert Revenue Analyst Record
     * @return Revenue_Analyst__c
     */
    public static Revenue_Analyst__c createRevenueAnalyst() {
        return new Revenue_Analyst__c(User__c = UserInfo.getUserId(), Is_SAP_Revenue_Analyst__c = true, Name='SAPRAUser, Test');
    }
    
    
    /**
     * This method used to insert Mulesoft Integration Control
     * @return  Mulesoft_Integration_Control__c
     */
    public static Mulesoft_Integration_Control__c createMulesoftIntegrationControl(Id userOrProfileOrOrgId) {
        Mulesoft_Integration_Control__c mic = Mulesoft_Integration_Control__c.getInstance(userOrProfileOrOrgId);
        mic.Enable_OLIS_JSON__c = false;
        mic.Enable_OLI_Sync_Validation__c = false;
        mic.Enable_Opportunity_Sync_Validation__c = false;
        mic.Ignore_Validation_Rules__c = false;
        mic.Is_Mulesoft_User__c = false;
        mic.Suppress_Outbound_Messages__c = false;
        return mic;
    }
    
    /**
     * This method used to insert Legacy Org Link
     * @return  Legacy_Org_Link__c
     */
    public static Legacy_Org_Link__c createLegacyOrgLink() {
        return new Legacy_Org_Link__c(SetupOwnerId = UserInfo.getOrganizationId(), Legacy_IMS_URL__c = URL.getOrgDomainUrl().toExternalForm(), Legacy_Quintiles_URL__c = URL.getOrgDomainUrl().toExternalForm());
    }
    
    /**
     * This method used to insert proxy SCM agreement record.
     * @return  Proxy_SCM_Agreement__c
     */
    public static Proxy_SCM_Agreement__c createProxySCMAgreement(Id OpportunityId) {
        return new Proxy_SCM_Agreement__c(Opportunity__c = OpportunityId, Record_Type_Name__c = 'SOW', Apttus_Status_c__c = 'Activated', LI_Record_Id__c = 'xxxxxxxx');
    }
    
    /**
     * This method used to insert proxy Project record.
     * @return  Proxy_SCM_Agreement__c
     */
    public static Proxy_Project__c createProxyProject(Id OpportunityId) {
        return new Proxy_Project__c(Opportunity__c = OpportunityId, Record_Type_Name__c = 'Project', Project_Status__c = 'Draft', LI_Record_Id__c = 'xxxxxxxx');
    }
    
    /**
     * This method used to insert user contact sync custom setting record.
     * @return User_Contact_Sync__c
     */
    public static User_Contact_Sync__c createUserContactSync() {
        User_Contact_Sync__c testUserContactSync = new User_Contact_Sync__c();
        testUserContactSync.Record_Active__c = 'IsActive,Inactive__c,User To Contact';
        testUserContactSync.Record_Email__c = 'Email,Email,User To Contact';
        testUserContactSync.Record_First_Name__c = 'FirstName,FirstName,User To Contact';
        testUserContactSync.Record_Language__c = 'LanguageLocaleKey,PreferredLanguage__c,User To Contact';
        testUserContactSync.Record_Last_Name__c = 'LastName,LastName,User To Contact';
        testUserContactSync.Record_Phone__c = 'Phone,Phone,Both';
        testUserContactSync.Record_Employee_Number__c = 'EmployeeNumber,EmployeeNumber__c,User To Contact';
        testUserContactSync.Record_Salesforce_User__c = 'Id,Salesforce_User__c,User To Contact';
        return testUserContactSync;
    }
    
    /**
     * This method used to insert Merge_Queue__c
     * @return  Merge_Queue__c
     */
    public static Merge_Queue__c createMergeQueue() {
        return new Merge_Queue__c(Name = 'TestMergeQueue', Sobjecttype__c = 'Account', Merge_status__c = 'Pending');
    }
    
    /**
    * This method used to insert Agreement
    * @return  Apttus__APTS_Agreement__c
    */
    public static Apttus__APTS_Agreement__c createAgreement() {
        return new Apttus__APTS_Agreement__c(Name='Test Agreement', Apttus__Status_Category__c = CON_CLM.REQUEST, Apttus__Status__c = CON_CLM.REQUEST);
    }
    
    /**
    * This method used to insert Bid_History__c
    * @return  Bid_History__c
    */
    public static Bid_History__c createClinicalBid() {
        return new Bid_History__c(Name='Test Clinical Bid');
    }
    
    /**
     * This method used to insert Application
     * @return  Apttus_XApps__Application__c
     */
    public static Apttus_XApps__Application__c createApplication() {
        return new Apttus_XApps__Application__c(Name='Test Application');
    }

    /**
     * This method used to insert Application
     * @return  Contract__x
     */
    public static Contract__x createContractExternal() {
        return new Contract__x(Name__c = 'Work Order', DisplayUrl = 'https://quintiles.my.salesforce.com/a0nw000000EclWKAAZ');
    }
    

    
    /**
    * This method used to insert Group
    * @return  Group
    */
    public static Group createGroup(String groupName, String groupType){
    
        Group testGroup = new Group();
        testGroup.name = groupName;
        testGroup.Type = groupType; 
        return testGroup;
    }
    
    /**
    * This method used to insert GroupMember
    * @return  GroupMember
    */
    public static GroupMember createGroupMember(Id groupId, Id userOrGroupId){

        GroupMember testGroupMember = new GroupMember();
        testGroupMember.UserOrGroupId = userOrGroupId;
        testGroupMember.GroupId = groupId;
        return testGroupMember;
    }
    
    /**
    * This method used to insert EmailTemplate
    * @return  EmailTemplate
    */
    public static EmailTemplate createEmailTemplate(String name, String developerName, String templateType){
        EmailTemplate testEmailTemplate = new EmailTemplate();
        testEmailTemplate.isActive = true;
        testEmailTemplate.Name = 'name';
        testEmailTemplate.DeveloperName = developerName;
        testEmailTemplate.TemplateType = templateType;
        return testEmailTemplate;
    }
    
    /**
    * This method used to insert Attachment
    * @return Attachment
    */
    public static Attachment createAttachment() {
        return new Attachment(Name='Test Attachment');
    }/*
    *This method is used to insert QC_Check_List_Item__c
    *return QC_Check_List_Item__c
    */
    public static QC_Check_List_Item__c createQCCheckListItem(){
        return new QC_Check_List_Item__c(Type__c = 'Budget', Question__c = 'Test', Guidelines__c = 'Test');
    }

    /*
    *This method is used to insert Proposal_QA_Self_Check_List__c
    *return Proposal_QA_Self_Check_List__c
    */
    public static Proposal_QA_Self_Check_List__c createProposalQASelfCheckList(){
        return new Proposal_QA_Self_Check_List__c(Type__c = 'Budget', Question__c = 'Test', Guidelines__c = 'Test');
    }

    /*
    *This method is used to insert Document
    *return Document
    */
    public static Document createDocument(String name, String developerName, String contentType){
        return new Document(DeveloperName = developerName, Name = name, ContentType = contentType, Body = Blob.valueOf('Some Text'));
    }

    public static Task createTask(String subject, Id whatId, String status, String priority){
        return new task(Subject = subject, WhatId = whatId, Status = status, Priority = priority);
    }
    
    public static Task createTask(Id whoId, String status, String priority, String subject, Id RecordTypeId){
        return new task(Subject = subject, WhoId = whoId, Status = status, Priority = priority, RecordTypeId = RecordTypeId);
    }

    /**
    * This method used to insert CPQ_Settings
    * @return CPQ_Settings__c
    */
    public static CPQ_Settings__c createCPQSettings() {
        CPQ_Settings__c cpqSetting  = new CPQ_Settings__c();   
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.IQVIA_Domain__c = CON_CPQ.IQVIA_ALLOWED_DOMAINS;
        cpqSetting.Bid_Grid_Mapping_Email__c = 'test@gmail.com';
        return cpqSetting;
    }
	
    /**
    * This method used to insert Client Sat Survey Record
    * @return Client_Sat_Survey__c
    */
    public static Client_Sat_Survey__c createClientSatSurveyRecord(String Name, String sendSurvey, String surveyRecipient1_Id, String opportunityId) {
        Client_Sat_Survey__c clientSatSurvey = new Client_Sat_Survey__c();
        clientSatSurvey.Send_Survey__c = sendSurvey;
        clientSatSurvey.Survey_Recipient_1__c = surveyRecipient1_Id;
        clientSatSurvey.Opportunity__c = opportunityId;
        return clientSatSurvey;
    }

    /**
    * This method used to insert Declined Survey Approver Group
    * @return DeclinedSurveyApproverGroup__c
    */    
    public static DeclinedSurveyApproverGroup__c createDeclinedSurveyApproverGroup(String offeringType, String businessUnit, 
                                                                            String mainDeliveryCountry, String userCountry, 
                                                                            String declinedSurveyApproverGroup, 
                                                                            Decimal priority){
        DeclinedSurveyApproverGroup__c declinedApproverGroup = new DeclinedSurveyApproverGroup__c();
        declinedApproverGroup.BusinessUnit__c = businessUnit;
        declinedApproverGroup.DeclinedSurveyApproverGroup__c = declinedSurveyApproverGroup;
        declinedApproverGroup.PeopleSoft_User_Country__c = userCountry;
        declinedApproverGroup.MainDeliveryCountry__c = mainDeliveryCountry;
        declinedApproverGroup.PeopleSoftProductOfferingType__c = offeringType;
        declinedApproverGroup.Priority__c = priority;    
        return declinedApproverGroup;
    }
	
    public static case createCase() {
        SLT_RecordType sltRecordType = new SLT_RecordType();
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        
        case newCase = new Case(
            Origin = 'Chat',
            Status = 'Request for Approval',
            AssignCaseToCurrentUser__c = false,
            RandD_Location__c = 'Dalian',
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OneKeyID__c = 'WFRD00890450',
			OneKey_LastName__c = 'BISMUTH',
            OneKey_FirstName__c = 'ALAIN',
            OwnerId = UserInfo.getUserId(),
            Type = 'Total Erasure',
            RecordTypeId = sltRecordType.getRecordType(CON_CSM_OneKey.S_HCP_ONE_KEY_REQUEST)[0].Id
        );
        return newCase;
    }
	
	public static PermissionSetAssignment createPermissionSetAssignmentRecord(String permissionSetAPIName, Id userId) {
        Id pId = null;
        List<PermissionSet> pList = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetAPIName];
        if(pList.size() > 0) {
            pId = pList[0].Id;
        }
        return new PermissionSetAssignment(PermissionSetId = pId, AssigneeId = userid); 
    }
    
    //Added by Surbhi Singh : 02 March 2019
    /**
     * This method used to insert Sales_Team_Hierarchy__c
     * @return  Sales_Team_Hierarchy__c
     */
    public static Sales_Team_Hierarchy__c createSalesTeamHierarchy(){
        Sales_Team_Hierarchy__c testSalesTeam = new Sales_Team_Hierarchy__c();
        testSalesTeam.Team_Name__c = 'testSalesTeam';
        return testSalesTeam;     
    }
    
    //Added by Surbhi Singh : 02 March 2019
    /**
     * This method used to insert Sales_Team_Hierarchy_ST__c
     * @return  Sales_Team_Hierarchy_ST__c
     */
    public static Sales_Team_Hierarchy_ST__c createSalesTeamHierarchyST(String userEmployeeNumber){
        Sales_Team_Hierarchy_ST__c testSalesTeamHierarchyST = new Sales_Team_Hierarchy_ST__c();
        testSalesTeamHierarchyST.ST_Code__c = userEmployeeNumber;
        testSalesTeamHierarchyST.ST_Name__c = 'testSalesTeamHierarchyST';
        testSalesTeamHierarchyST.VP__C =  [Select Id,VP_Code__c,VP_Name__c from Sales_Team_Hierarchy_VP__c where VP_Name__c = 'testSalesTeamHierarchyVP'][0].Id;
        testSalesTeamHierarchyST.Hierarchy_Id__c= '12305';
        testSalesTeamHierarchyST.Type__c = 'Sales Team';
        return testSalesTeamHierarchyST;     
    }
    
    //Added by Surbhi Singh : 02 March 2019
    /**
     * This method used to insert SalesTeamHierarchy-VP
     * @return  SalesTeamHierarchy-VP
     */
    public static Sales_Team_Hierarchy_VP__c createSalesTeamHierarchyVP(String userEmployeeNumber){
        Sales_Team_Hierarchy_VP__c testSalesTeamHierarchyVP = new Sales_Team_Hierarchy_VP__c();
        testSalesTeamHierarchyVP.VP_Name__c = 'testSalesTeamHierarchyVP';
        testSalesTeamHierarchyVP.VP_Code__c = userEmployeeNumber;
        testSalesTeamHierarchyVP.Hierarchy_Id__c= '1255';
        testSalesTeamHierarchyVP.Type__c = 'Sales Team';
        return testSalesTeamHierarchyVP;
    }
    
    //Added by Surbhi Singh : 02 March 2019
    /**
     * This method used to insert Sales_Team_Hierarchy_AE__c
     * @return  Sales_Team_Hierarchy_AE__c
     */
    public static Sales_Team_Hierarchy_AE__c createSalesTeamHierarchyAE(String userEmployeeNumber){
        Sales_Team_Hierarchy_AE__c testSalesTeamHierarchyAE = new Sales_Team_Hierarchy_AE__c();
        testSalesTeamHierarchyAE.AE_Code__c = userEmployeeNumber;
        Sales_Team_Hierarchy_ST__c testSalesTeamHierarchy = [Select id from Sales_Team_Hierarchy_ST__c where ST_Name__c = 'testSalesTeamHierarchyST'];
        testSalesTeamHierarchyAE.Sales_Team__c = testSalesTeamHierarchy.id;
        testSalesTeamHierarchyAE.Hierarchy_Id__c= '12455';
        testSalesTeamHierarchyAE.Type__c ='Sales Team';
        return testSalesTeamHierarchyAE;     
    }
    
    /**
     * This method used to insert IQVIA_Legal_Entity__c
     * @return  IQVIA_Legal_Entity__c
     */
     
    public static IQVIA_Legal_Entity__c createIQVIALegalEntity() {
        return new IQVIA_Legal_Entity__c(Name = 'Test Entity');
    }

    public static void createOneKeyConfig() {
        OneKey_Config__c oneKey = new OneKey_Config__c(OneKey_Request_1__c = '{"fields": [{"name": "individual.individualEid","values":[',
                                                       OneKey_Request_2__c = '],"method": "EXACT"}],"codBase": [{0}"]}');
        insert oneKey;
    }

    /**
     * This method used to insert Challenge_Matrix__c
     * @return  Challenge_Matrix__c
     */
    
    public static Challenge_Matrix__c createChallengeMatrix(String fees, String opportunityType, String reviewType, String action, String isThisIQB, String winProbabilityRange, String deliveryPotentialRegion) {
      return new Challenge_Matrix__c(Fees__c = fees, Opportunity_Type__c = opportunityType,
          Review_Type__c = reviewType, Action__c = action, Is_this_IQB__c = isThisIQB, Win_Probability__c = winProbabilityRange, Delivery_Region__c = deliveryPotentialRegion);
    }
    
    /**
     * This method used to insert Approver_Group__c
     * @return  Approver_Group__c
     */

    public static Approver_Group__c createApproverGroup(String name, String type) {
        return new Approver_Group__c(Name=name, Type__c=type);
    }
    
    /**
     * This method used to insert Approval_Matrix__c
     * @return  Approval_Matrix__c
     */

    public static Approval_Matrix__c createApprovalMatrix(Approver_Group__c approverGroup, String opportunityType,
        String region, String therapyArea, String X0_5M_USD, String X10_20M_USD, String X20_50M_USD, String X5_10M_USD, String X50M_USD, String sales,
        String md, String role, String globalProjectUnit, String customer) {
        
        Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(Approver_Group__c = approverGroup.Id,
            Opportunity_Type__c = opportunityType,
            Region__c = region,
            Therapy_Area__c = therapyArea,
            X0_5M_USD__c = X0_5M_USD,
            X5_10M_USD__c = X5_10M_USD,
            X10_20M_USD__c = X10_20M_USD,
            X20_50M_USD__c = X20_50M_USD,
            X50M_USD__c = X50M_USD,
            Sales__c = sales,
            Md__c = md,
            Role__c = role,
            Global_Project_Unit__c = globalProjectUnit,
            Customer__c = customer);
        return approvalMatrix;
    }
    
    public static Apttus_CMConfig__AgreementSummaryGroup__c createAgreementSummaryGroup(Apttus__APTS_Agreement__c testAgreement, Decimal extendedPrice) {
      return new Apttus_CMConfig__AgreementSummaryGroup__c(Apttus_CMConfig__AgreementId__c = testAgreement.Id,
          Apttus_CMConfig__ExtendedPrice__c = extendedPrice);
    }
    
    /**
     * This method used to insert AgreementLineItem
     * @params  Id AgreementId
     * @params  Id ProductId
     * @return  AgreementLineItem
     */
    public static Apttus__AgreementLineItem__c createAgreementLineItem(Id agreementId, Id productId) {
        return new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementId, Apttus__ProductId__c = productId, Apttus__Quantity__c = 1,
            Apttus__NetPrice__c = 100, Apttus__Description__c = 'Test');
    }


    
    public static List<Apttus__AgreementLineItem__c> createAgreementLineItems(Id agreementId) {
        List<Apttus__AgreementLineItem__c> agreementLineItemList = new List<Apttus__AgreementLineItem__c>();
        agreementLineItemList.add(new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementId, Apttus__Quantity__c = 1, Apttus__Description__c = CON_CPQ.SITE_CONTACT,
            APTTUS_CMCONFIG__CHARGETYPE__C = CON_CPQ.LABOR, APTTUS_CMCONFIG__LINESTATUS__C = CON_CPQ.SALE_TYPE_NEW, APTTUS_CMCONFIG__LINETYPE__C = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_ENROLLMENT,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 1.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Total_Hours__c = 5, Unit_Code__c = CON_CPQ.CLIN_A14 + '_' + CON_CPQ.USA));
        agreementLineItemList.add(new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementId, Apttus__Quantity__c = 1, Apttus__Description__c = CON_CPQ.REMOTE_EDC_REVIEW,
            APTTUS_CMCONFIG__CHARGETYPE__C = CON_CPQ.LABOR, APTTUS_CMCONFIG__LINESTATUS__C = CON_CPQ.SALE_TYPE_NEW, APTTUS_CMCONFIG__LINETYPE__C = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_ENROLLMENT,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Total_Hours__c = 5, Unit_Code__c = CON_CPQ.CLIN_A14 + '_' + CON_CPQ.USA));
        agreementLineItemList.add(new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementId, Apttus__Quantity__c = 1, Apttus__Description__c = CON_CPQ.SITE_CONTACT,
            APTTUS_CMCONFIG__CHARGETYPE__C = CON_CPQ.LABOR, APTTUS_CMCONFIG__LINESTATUS__C = CON_CPQ.SALE_TYPE_NEW, APTTUS_CMCONFIG__LINETYPE__C = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_TREATMENT,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 1, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Total_Hours__c = 5, Unit_Code__c = CON_CPQ.CLIN_A18 + '_' + CON_CPQ.USA));
        agreementLineItemList.add(new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementId, Apttus__Quantity__c = 1, Apttus__Description__c = CON_CPQ.REMOTE_EDC_REVIEW,
            APTTUS_CMCONFIG__CHARGETYPE__C = CON_CPQ.LABOR, APTTUS_CMCONFIG__LINESTATUS__C = CON_CPQ.SALE_TYPE_NEW, APTTUS_CMCONFIG__LINETYPE__C = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_TREATMENT,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Total_Hours__c = 5, Unit_Code__c = CON_CPQ.CLIN_A18 + '_' + CON_CPQ.USA));
        agreementLineItemList.add(new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementId, Apttus__Quantity__c = 1, Apttus__Description__c = CON_CPQ.SITE_CONTACT,
            APTTUS_CMCONFIG__CHARGETYPE__C = CON_CPQ.LABOR, APTTUS_CMCONFIG__LINESTATUS__C = CON_CPQ.SALE_TYPE_NEW, APTTUS_CMCONFIG__LINETYPE__C = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_FOLLOWUP,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Total_Hours__c = 5, Unit_Code__c = CON_CPQ.CLIN_A19 + '_' + CON_CPQ.USA));
        agreementLineItemList.add(new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementId, Apttus__Quantity__c = 1, Apttus__Description__c = CON_CPQ.REMOTE_EDC_REVIEW,
            APTTUS_CMCONFIG__CHARGETYPE__C = CON_CPQ.LABOR, APTTUS_CMCONFIG__LINESTATUS__C = CON_CPQ.SALE_TYPE_NEW, APTTUS_CMCONFIG__LINETYPE__C = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_FOLLOWUP,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Total_Hours__c = 5, Unit_Code__c = CON_CPQ.CLIN_A19 + '_' + CON_CPQ.USA));
        agreementLineItemList.add(new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementId, Apttus__Quantity__c = 1, Apttus__Description__c = CON_CPQ.SITE_CONTACT,
            APTTUS_CMCONFIG__CHARGETYPE__C = CON_CPQ.LABOR, APTTUS_CMCONFIG__LINESTATUS__C = CON_CPQ.SALE_TYPE_NEW, APTTUS_CMCONFIG__LINETYPE__C = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_CLOSEOUT,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 3.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Total_Hours__c = 5, Unit_Code__c = CON_CPQ.CLIN_A20 + '_' + CON_CPQ.USA));
        return agreementLineItemList;
    }
    


    public static Template_Data__c createTemplateData(String templateDataName) {
        Template_Data__c tempDataInstance = new Template_Data__c();
		tempDataInstance.Name = templateDataName;
        tempDataInstance.Cell_Reference__c = 'Cell_Reference__c';
        tempDataInstance.DML_Type__c = 'Both';
        tempDataInstance.Field_Name__c = 'Apttus_Proposal__Proposal_Name__c';
        tempDataInstance.Object_Name__c = 'Apttus_Proposal__Proposal__c';
        tempDataInstance.Package_Name__c = 'Package_Name__c';
        tempDataInstance.Version__c = 21;
        tempDataInstance.Migration_Id__c = 'TD-01';
        
		return tempDataInstance;
    }
    
    public static Contract createContract(Id accountId) {
        return new Contract(Name = 'TestContract', AccountId = accountId);
    }
    public static Campaign createCampaign() {
        return new Campaign(Name = 'test1',Campaign_Goal__c = 'Awareness',StartDate = Date.today(),EndDate = Date.today(),Business_Unit__c = 'Enterprise',Channel__c = 'Email',Status = 'planned');
    }
    /**
     * This method used to insert Country Sales Head
     * @params  String saleType
     * @params  String countrySales
     * @params  String customerName
     * @return  Country_Sales_Head__c
     */
    
    public static Country_Sales_Head__c createCountrySalesHeadData(String saleType,String countrySales,String approverName) {
        return new Country_Sales_Head__c(Sale_Type__c = saleType, Country_Sales__c = countrySales, Approver_Name__c = approverName);
    }
    /**
     * This method used to insert Account Directory
     * @params  String role
     * @params  Account account
     * @params  String customerName
     * @return  Account_Directory__c
     */
    public static Account_Directory__c createAccountDirectoryData(String role,Account account,String approverName) {
        return new Account_Directory__c(Role__c = role, Account__c = account.id, Approver_Name__c = approverName);
    }
    
    public static SObject_Sharing__c createSObjectSharingParentData(String objectName, String parentShareObjectName, String sharingTerritoryLabel,
                                                                    String sharingTeamLabel, String sharingType, String teamSharingLookUpField, String accountCountryApiName,
                                                                    String recordTypeApiName, String parentCustomerCodeApiName, String businessUnitApiName) {
                                                                        SObject_Sharing__c socs = new SObject_Sharing__c();
                                                                        socs.Type__c = 'Parent';
                                                                        socs.Parent_Sobject__c = objectName;
                                                                        socs.Parent_Sobject_Share__c = parentShareObjectName;
                                                                        socs.Maintenance_Job_Status__c = 'Completed';
                                                                        socs.Enable_Sharing_Calculation__c = true;
                                                                        socs.Sharing_Territory_Label__c = sharingTerritoryLabel; 
                                                                        socs.Sharing_Team_Label__c = sharingTeamLabel;
                                                                        socs.Sharing_Type__c = sharingType;
                                                                        socs.Team_Sharing_Lookup_Field__c = teamSharingLookUpField; 
                                                                        socs.Account_Country_Api_Name__c = accountCountryApiName;
                                                                        socs.Record_Type_Api_Name__c = recordTypeApiName;
                                                                        socs.Parent_Customer_Code_Api_Name__c = parentCustomerCodeApiName;
                                                                        socs.Business_Unit_Api_Name__c = businessUnitApiName;
                                                                        return socs;
                                                                    }
    
    public static SObject_Sharing__c createSObjectSharingChildData(String objectName, String parentShareObjectName, String childObjectName,
                                                                   String childShareObjectName, String lookUpName, String childSharingTerritoryLabel,
                                                                   String childSharingTeamLabel, String childSharingOwnerLabel,
                                                                   String parentSharingTeamLabel, String parentSharingTerritoryLabel,
                                                                   String teamSharingLookUpField) {
                                                                       SObject_Sharing__c socs = new SObject_Sharing__c();
                                                                       socs.Type__c = 'Child';
                                                                       socs.Parent_Sobject__c = objectName;
                                                                       socs.Parent_Sobject_Share__c = parentShareObjectName;
                                                                       socs.Maintenance_Job_Status__c = 'Completed';
                                                                       socs.Enable_Sharing_Calculation__c = true;
                                                                       socs.Sharing_Territory_Label__c = childSharingTerritoryLabel; 
                                                                       socs.Sharing_Team_Label__c = childSharingTeamLabel;
                                                                       socs.Sharing_Type__c = 'Derived';
                                                                       socs.Child_Sobject__c = childObjectName;
                                                                       socs.Child_Sobject_Share__c = childShareObjectName;
                                                                       socs.Parent_Sharing_Team_Label__c = parentSharingTeamLabel;
                                                                       socs.Parent_Sharing_Territory_Label__c = parentSharingTerritoryLabel;
                                                                       socs.Sharing_Owner_Label__c = childSharingOwnerLabel;
                                                                       socs.Lookup_Name__c = lookupName;
                                                                       socs.Team_Sharing_Lookup_Field__c = teamSharingLookUpField;                                                       
                                                                       return socs;
                                                                   }
    
    public static Territory_Sharing__c createTerritorySharingData(Id groupId, String parentObjectName) {
        Territory_Sharing__c ts = new Territory_Sharing__c();
        ts.Access_Level__c = 'Read';
        ts.Account_Country__c = 'AL';
        ts.Business_Unit__c = 'ALL';
        ts.Group_Id__c = groupId;
        ts.isActive__c = true;
        ts.Parent_Customer_Code__c = 'ALL';
        ts.Record_Type__c = 'MSA';
        ts.Parent_Sobject_Name__c = parentObjectName;
        return ts;
    }
    
    public static Team_Sharing__c createTeamSharingData(String parentObjectName, String childObjectName, String teamObjectName, String teamRoleName) {
        Team_Sharing__c ts = new Team_Sharing__c();
        ts.Access_Level__c = 'Read';
        ts.isActive__c = true;
        ts.Parent_Sobject_Name__c = parentObjectName;
        ts.Child_Sobject_Name__c = childObjectName;
        ts.Team_Object_Name__c = teamObjectName;
        ts.Team_Role_Name__c = teamRoleName;
        return ts;
    }
    
    public static Fail_Sharing_Log__c createFailRecordSharing(Id recordId, Id parentRecordId) {
        Fail_Sharing_Log__c failLog = new Fail_Sharing_Log__c();
        failLog.Fail_Record_Id__c = recordId;
        failLog.Parent_Record_Id__c = parentRecordId;
        return failLog;
    }

    /**
    * This method used to insert Quote
    * @return  Apttus_Proposal__Proposal__c
    */
    public static Apttus_Proposal__Proposal__c createQuote() {
        return new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c='Test Quote');
    }
    
    /**
    * This method used to insert Team Member
    * @return  Team_Member__c
    */
    public static Team_Member__c createTeamMember(String memberRole, String rrRole, Id userId, Id proposalId) {
        return new Team_Member__c(Member_Role__c = memberRole, Role_from_RR__c=rrRole, User__c = userId, Proposal__c = proposalId);
    }
    /**
     * This method used to insert QuoteLineItem
     * @params  Id QuoteId
     * @return  QuoteLineItem
     */
    public static Apttus_Proposal__Proposal_Line_Item__c createQuoteLineItem(Id quoteId) {
        return new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quoteId);
    }

    public static Apttus__APTS_Agreement__c setAgreementData(String recordTypeName, Id opportunityId, String pricingTool) {
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Id recordTypeId =
            SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Apttus__APTS_Agreement__c testAgreement = UTL_TestData.createAgreement();
        testAgreement.Apttus__Related_Opportunity__c = opportunityId;
        testAgreement.RecordTypeId = recordTypeId;
        testAgreement.Select_Pricing_Tool__c = pricingTool;
        testAgreement.Apttus__Workflow_Trigger_Created_From_Clone__c = true;
        testAgreement.Apttus__Contract_Start_Date__c = Date.newInstance(2027, 06, 02);
        testAgreement.O_Term_Years__c = '3';
        insert testAgreement;
        return testAgreement;
    }
    
    public static Bid_History__c setClinicalBidData(String recordTypeName, Id opportunityId, String pricingTool) {
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Id recordTypeId =
            SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Bid_History__c testClinicalBid = UTL_TestData.createClinicalBid();
        testClinicalBid.Bid_History_Related_Opportunity__c = opportunityId;
        testClinicalBid.RecordTypeId = recordTypeId;
        testClinicalBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK;
        testClinicalBid.Patient_Population__c= 'test';
        testClinicalBid.Unblinded_CVs_required__c='None';
        testClinicalBid.Is_PPT_Format_Required__c='No';
        //testClinicalBid.Mark_as_Primary__c = false;
        testClinicalBid.DTE_Study__c = CON_CPQ.YES_TITLE_CASE;
        testClinicalBid.Budget_Iteration__c = 1;
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        //testClinicalBid.Mark_as_Primary__c = true;
        testClinicalBid.Number_of_Scenarios__c = 10;
        insert testClinicalBid;
        return testClinicalBid;
    }
    
    public static Apttus_Proposal__Proposal__c setProposalData(String recordTypeName, Id opportunityId, String pricingTool, Id bidId) {
        Id recordTypeId =
            SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'test proposal');
        testProposal.Apttus_Proposal__Opportunity__c = opportunityId;
        testProposal.RecordTypeId = recordTypeId;
        testProposal.Select_Pricing_Tool__c = pricingTool;
        testProposal.Clinical_Bid__c = bidId;
        testProposal.Scenario_Number__c = 123.0;
        testProposal.DTE_Study__c = CON_CPQ.YES_TITLE_CASE;
        testProposal.Scenario_Description__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        testProposal.Budget_Iteration__c = 1;
        testProposal.Apttus_Proposal__Primary__c = true;
        testProposal.Protocol_Number__c ='test23';
        insert testProposal;
        return testProposal;
    }
    
    public static Apttus_Proposal__Proposal__c setTSProposalData(Boolean isInsert, String recordTypeName, Id opportunityId, String pricingTool) {
        Id recordTypeId =
            SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'test proposal');
        testProposal.Apttus_Proposal__Opportunity__c = opportunityId;
        testProposal.RecordTypeId = recordTypeId;
        testProposal.Select_Pricing_Tool__c = pricingTool;
        testProposal.Apttus_Proposal__Primary__c = true;
        if(isInsert) {
            insert testProposal;
        }
        return testProposal;

    }
    
    public static Apttus_Proposal__Proposal_Line_Item__c createProposalLineItem(Id proposalId, Id productId) {
        return new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Product__c = productId, Apttus_Proposal__Quantity__c = 1,
            Apttus_QPConfig__NetPrice__c = 100, Apttus_Proposal__Description__c = 'Test',BidGrid_Country__c='USA');
    }

    public static List<Country_Input__c> createQuoteCountryInputs(Id proposalId) {
        List<Country_Input__c> countryInputs = new List<Country_Input__c>();
        countryInputs.add(new Country_Input__c(Name = CON_CPQ.USA, Country__c = CON_CPQ.USA, Proposal__c = proposalId, Num_of_Active_Sites__c = 10,Enrollment_Site_Months__c = 10, Subjects_Randomized_or_Receiving_Treatme__c = 50));
        return countryInputs;
    }
    
    public static List<Timeline__c> createQuoteTimelines(Id proposalId) {
        List<Timeline__c> timelines = new List<Timeline__c>();
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 251.29, Months__c = 58, Order__c = 1, Name = CON_CPQ.DURATION_OF_ACTIVE_PROJECT, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 8, Months__c = 1.84, Order__c = 2, Name = CON_CPQ.PRE_PROJECT_ACTIVITIES, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 51.96, Months__c = 12, Order__c = 3, Name = CON_CPQ.PROJECT_START_UP, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 9, Months__c = 2.1, Order__c = 4, Name = CON_CPQ.ON_HOLD_DUE_TO_CLIENT, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 12, Months__c = 2.8, Order__c = 5, Name = CON_CPQ.RECRUITMENT_FPI_TO_LPI, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 14, Months__c = 3.2, Order__c = 6, Name = CON_CPQ.RUN_IN_SCREENING_LPI, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 16, Months__c = 3.7, Order__c = 7, Name = CON_CPQ.TREATMENT_LPI_LPO, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 20, Months__c = 4.6, Order__c = 8, Name = CON_CPQ.IN_TREATMENT_FOLLOWUP_BASED_ON_LPO, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 2, Months__c = 0.5, Order__c = 9, Name = CON_CPQ.LOCKED_DATABASE, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 4.33, Months__c = 1, Order__c = 10, Name = CON_CPQ.CLOSE_OUT, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 24, Months__c = 5.5, Order__c = 11, Name = CON_CPQ.STAT_ANALYSIS_FINAL_TLF, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 28, Months__c = 6.5, Order__c = 12, Name = CON_CPQ.FIRST_DRAFT_REPORT, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 30, Months__c = 6.9, Order__c = 13, Name = CON_CPQ.SUBSEQUENT_DRAFTS_TO_FINAL_REPORT, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 40, Months__c = 9.2, Order__c = 14, Name = CON_CPQ.POST_TREATMENT_FOLLOW_UP, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        timelines.add(new Timeline__c(Proposal__c = proposalId, Weeks__c = 1, Months__c = 0.2, Order__c = 15, Name = CON_CPQ.OTHER_POST_PROJECT_ACTIVITIES_IN, Start__c = Date.newInstance(2022, 06, 02), End__c = Date.newInstance(2027, 06, 04)));
        return timelines;
    }
    
    public static List<Apttus_Proposal__Proposal_Line_Item__c> createProposalLineItems(Id proposalId) {
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.SITE_CONTACT,
		    Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_ENROLLMENT,
		    BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 1.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
		    Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Total_Hours__c = 5, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A14 + '_' + CON_CPQ.USA, Budgeted_Units__c = 80));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.REMOTE_EDC_REVIEW,
		    Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_ENROLLMENT,
		    BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
		    Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Total_Hours__c = 5, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A14 + '_' + CON_CPQ.USA, Budgeted_Units__c = 80));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.SITE_CONTACT,
		    Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_TREATMENT,
		    BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 1, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
		    Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Total_Hours__c = 5, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A18 + '_' + CON_CPQ.USA, Budgeted_Units__c = 28));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.REMOTE_EDC_REVIEW,
		    Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_TREATMENT,
		    BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
		    Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Total_Hours__c = 5, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A18 + '_' + CON_CPQ.USA, Budgeted_Units__c = 48));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.SITE_CONTACT,
		    Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_FOLLOWUP,
		    BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
		    Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Total_Hours__c = 5, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A19 + '_' + CON_CPQ.USA));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.REMOTE_EDC_REVIEW,
		    Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_FOLLOWUP,
		    BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
		    Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Total_Hours__c = 5, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A19 + '_' + CON_CPQ.USA));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.SITE_CONTACT,
		    Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.SITE_MANAGEMENT_CLOSEOUT,
		    BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 3.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
		    Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Total_Hours__c = 5, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A20 + '_' + CON_CPQ.USA, Budgeted_Units__c = 10));
        return proposalLineItemList;
    }
	
	public static List<Apttus_Proposal__Proposal_Line_Item__c> createProposalLineItemsForClinicalVisitFrequency(Id proposalId) {
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.CALL,
            Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.REMOTE_MONITORING_VISITS,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 3.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Number_of_Units__c = 10, Total_Hours__c = 35, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A11 + '_' + CON_CPQ.USA));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.ON_SITE,
            Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.HALF_DAY_PHARMACY_VISITS,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 3.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Number_of_Units__c = 10, Total_Hours__c = 35, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A23 + '_' + CON_CPQ.USA));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.ON_SITE,
            Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.HALF_DAY_ONSITE_MONITORING_VISITS,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Number_of_Units__c = 10, Total_Hours__c = 25, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A5 + '_' + CON_CPQ.USA));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.CALL,
            Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.REMOTE_MONITORING_VISITS,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Number_of_Units__c = 10, Total_Hours__c = 25, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A11 + '_' + CON_CPQ.USA));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.ON_SITE,
            Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.HALF_DAY_PHARMACY_VISITS,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 2.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Number_of_Units__c = 10, Total_Hours__c = 25, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A23 + '_' + CON_CPQ.USA));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId, Apttus_Proposal__Quantity__c = 1, Apttus_Proposal__Description__c = CON_CPQ.ON_SITE,
            Apttus_QPConfig__ChargeType__c = CON_CPQ.LABOR, Apttus_QPConfig__LineStatus__c = CON_CPQ.SALE_TYPE_NEW, Apttus_QPConfig__LineType__c = CON_CPQ.PRODUCT_SERVICE,Unit_Name__c = CON_CPQ.HALF_DAY_ONSITE_MONITORING_VISITS,
            BIDGRID_COUNTRY__C = CON_CPQ.USA, BUDGET_DIAGNOSTIC_CODE__C = CON_CPQ.CLINICAL_MONITORING, CRM_CODE__C = CON_CPQ.CLIN, HOURS_PER_UNIT__C = 3.5, IQVIA_LINE_TYPE__C = CON_CPQ.UPT_TASK,
            Closeout_Phase__c = true, Conduct_Phase__c = true, Startup_Phase__c = true, Role__c = CON_CPQ.CRA, Number_of_Units__c = 10, Total_Hours__c = 35, Total_Budget_hours__c = 30, Unit_Code__c = CON_CPQ.CLIN_A5 + '_' + CON_CPQ.USA));
        return proposalLineItemList;
    }
    
    public static List<Clinical_Visit_Frequency_Data__c> createClinicalVisitFrequencyData(Id proposalID) {
        List<Clinical_Visit_Frequency_Data__c> clinicalVisitFrequencyData = new List<Clinical_Visit_Frequency_Data__c>();
        clinicalVisitFrequencyData.add(new Clinical_Visit_Frequency_Data__c(Visit_Frequency__c = 7.04, Country__c = CON_CPQ.USA, Proposal__c = proposalID, Visit_Type__c = 'Onsite Monitoring Visit Frequency (weeks) Calculated for QRPM'));
        return clinicalVisitFrequencyData;
    }
    
    public static List<Admin_Time_Entry_Data__c> createAdminTimeEntryData(Id proposalID) {
        List<Admin_Time_Entry_Data__c> adminTimeEntryData = new List<Admin_Time_Entry_Data__c>();
        adminTimeEntryData.add(new Admin_Time_Entry_Data__c(Admin_Time__c = 1.5, Country__c = CON_CPQ.USA, Proposal__c = proposalID, Visit_Type__c = 'RBM Admin SIV-FSI'));
        return adminTimeEntryData;
    }
    
    /**
    * This method used to insert a record for the Customer Profile custom setting
    * @return  Customer_Profile__c
    */
    public static Customer_Profile__c createCustomerProfileRecord(String fieldName, Boolean isAccField, Integer accWeight, Boolean isConField, Integer conWeight) {
        Customer_Profile__c cProfileRecord = new Customer_Profile__c();
        cProfileRecord.Name = fieldName;
        cProfileRecord.Account__c = isAccField;
        cProfileRecord.Account_Weight__c = accWeight;
        cProfileRecord.Contact__c = isConField;
        cProfileRecord.Contact_Weight__c = conWeight;
        return cProfileRecord;
    }
    /* This method used to insert a record for the Level Up custom setting
    * @return  Level_Up__c
    */
    public static Level_Up__c createLevelUpRecord(String fieldName, Boolean isAccField, Integer accLevel, Boolean isConField, Integer conLevel) {
        Level_Up__c lvlUpRecord = new Level_Up__c();
        lvlUpRecord.Name = fieldName;
        lvlUpRecord.Account__c = isAccField;
        lvlUpRecord.Account_Level__c = accLevel;
        lvlUpRecord.Contact__c = isConField;
        lvlUpRecord.Contact_Level__c = conLevel;
        return lvlUpRecord;
    }
    
    public static List<Team_Member__c> createTeamMembers(Id proposalId) {
        List<Team_Member__c> proposalMemberList = new List<Team_Member__c>();
        /*Commented under LC-10187 to remove ref. of Reviewer/Final Reviewer picklist value from Team Member object
        proposalMemberList.add(new Team_Member__c(User__c = UserInfo.getUserId(), Member_Role__c = CON_CPQ.QC_REVIEWER, Proposal__c = proposalId));
        proposalMemberList.add(new Team_Member__c(User__c = UserInfo.getUserId(), Member_Role__c = CON_CPQ.FINAL_QC_REVIEWER, Proposal__c = proposalId));*/
        proposalMemberList.add(new Team_Member__c(User__c = UserInfo.getUserId(), Member_Role__c = CON_CPQ.APPROVER, Proposal__c = proposalId, Role_from_RR__c = CON_CPQ.TSL));
        proposalMemberList.add(new Team_Member__c(User__c = UserInfo.getUserId(), Member_Role__c = CON_CPQ.FUNCTIONAL_REVIEWER, Proposal__c = proposalId, Role_from_RR__c = CON_CPQ.DSB_MW));
        return proposalMemberList;
    }
    
    public static Apttus_Config2__PriceList__c createPriceList() {
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(Name = CON_CPQ.RDS_PRICE_LIST, Apttus_Config2__Description__c = CON_CPQ.TEST_LAST_NAME, Migration_Id__c = 'CPL-10');
        insert priceList;
        return priceList;
    }
    
    public static Apttus_Config2__ProductConfiguration__c createProductConfiguration (Id proposalId, String status) {
        Apttus_Config2__ProductConfiguration__c config = new Apttus_Config2__ProductConfiguration__c();
        config.Name = CON_OCE.TEST_PRODUCT_CONFIG_NAME;
        config.Apttus_QPConfig__Proposald__c = proposalId;
        config.Apttus_Config2__Status__c = status;
        return config;
    }

    /** 
     * This method used to insert Sales_Program__c 
     * @return  Sales_Program__c
     */
    public static Sales_Program__c createSalesProgram(Id accountId) {
        return new Sales_Program__c(Name = 'Test Sales Program', Account_Name__c = accountId);
    } 
    
    /** 
     * This method used to insert Custom settings "CPQ TS Price List Selection" 
     * @return  CPQ_TS_Price_List_Selection__c
     */
    public static CPQ_TS_Price_List_Selection__c createCPQTSPriceListSelectionCustomSettings() {
        CPQ_TS_Price_List_Selection__c customSetting = new CPQ_TS_Price_List_Selection__c();
        customSetting.Name = CON_CPQ.TECH_SOLUTION_JAPAN;
        customSetting.Account_Country__c = 'JP';
        customSetting.Price_List_Name__c = CON_CPQ.TECH_SOLUTION_JAPAN;
        customSetting.Proposal_Record_Type_Name__c = CON_CPQ.TECH_SOLUTION;
        insert customSetting;
        return customSetting;
    }

    /** 
     * This method used to create Price List
     * @return  Apttus_Config2__PriceList__c
     */
    public static Apttus_Config2__PriceList__c createPriceList(String priceListName) {
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(Name = priceListName, Apttus_Config2__Active__c = true, Migration_Id__c = 'PL-11');
        insert priceList;
        return priceList;
    }
    
    /** 
     * This method used to create Price List Item
     * @return  Apttus_Config2__PriceListItem__c
     */
    public static Apttus_Config2__PriceListItem__c createPriceListItem(Id productId, Id priceListId, String migrationId) {
        Apttus_Config2__PriceListItem__c priceListItem = new Apttus_Config2__PriceListItem__c();
        priceListItem.Apttus_Config2__Active__c = true;
        priceListItem.Apttus_Config2__ChargeType__c = 'Standard Price';
        priceListItem.Apttus_Config2__Frequency__c = 'One Time';
        priceListItem.Apttus_Config2__ListPrice__c = 100.00;
        priceListItem.Apttus_Config2__PriceMethod__c = 'Per Unit';
        priceListItem.Apttus_Config2__PriceType__c = 'One Time';
        priceListItem.Apttus_Config2__PriceUom__c = 'Each';
        priceListItem.Apttus_Config2__PriceListId__c = priceListId;
        priceListItem.Apttus_Config2__ProductId__c = productId;
        priceListItem.Migration_Id__c = migrationId;
        return priceListItem;
    }
    
    /** 
     * This method used to create Content Document (File record)
     * @return  ContentDocumentLink
     */
    public static ContentDocumentLink createContentDocument(String fileName, Id parentId) {
        // Create Content Document
        ContentVersion contentVersion = new ContentVersion(
            Title = fileName,
            PathOnClient = 'test',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        contentVersion = [SELECT ContentDocumentId FROM ContentVersion Where Id =: contentVersion.Id];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink contentDocumentLink = New ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.shareType = 'V';
        insert contentDocumentLink;
        return contentDocumentLink;
    }
    
    /**
    * This method used to insert CPQ_Create_Proposal_Setting
    * @return CPQ_Proposal_Create_Settings__c
    */
    public static CPQ_Proposal_Create_Settings__c cpqProposalCreateSettings() {
        CPQ_Proposal_Create_Settings__c cpqProposalCreateSettings  = new CPQ_Proposal_Create_Settings__c();
        cpqProposalCreateSettings.Name = 'CPQ TS Proposal';
        cpqProposalCreateSettings.Available_Pricing_Tools__c = 'TS Japan';
        cpqProposalCreateSettings.Flow_Name__c = 'TSJapan';
        cpqProposalCreateSettings.Permission_Set_Name__c = 'CPQ_TS_Read_Write';
        cpqProposalCreateSettings.Price_List__c = 'Tech Solution Japan';
        cpqProposalCreateSettings.Proposal_Record_Type_Name__c = 'Tech_Solution';
        return cpqProposalCreateSettings;
    }
    public static IQVIA_Schedule_Setting__c createIqviaSchedulesetting(){
        IQVIA_Schedule_Setting__c iqviaScheduleSetting = new IQVIA_Schedule_Setting__c();
        iqviaScheduleSetting.Name='OWF Test';
        iqviaScheduleSetting.Module_Name__c ='OWF';
        iqviaScheduleSetting.Frequency__c ='YEARLY';
        iqviaScheduleSetting.Hour__c =1;
        iqviaScheduleSetting.Is_Active__c = true;
        iqviaScheduleSetting.Batch_Name__c ='BCH_OWF_Generate_Triage_Users_Report';
        iqviaScheduleSetting.Batch_Size__c =1;
        iqviaScheduleSetting.Mode__c ='PSASET';
        iqviaScheduleSetting.Year__c=2023;
        iqviaScheduleSetting.Day_of_Month__c=1;
        iqviaScheduleSetting.Year_Upto__c=2023;
        iqviaScheduleSetting.Month__c=2;
        
        return iqviaScheduleSetting;
    }
    /**
    * This method used to insert Field_History__c
    * @return List<Field_History__c> accountFieldHistoryList
    */
    
    public static List<Field_History__c> createFieldHistoryRecord(string objname,Id Objid){
       List<Field_History__c> accountFieldHistoryList = new List<Field_History__c>();
       accountFieldHistoryList.add(new Field_History__c(Tracked_Object__c = 'Account', Action_User__c = userinfo.getuserid(), Action_Date_Time__c = System.Today(), Tracked_Record_Id__c = Objid, Old_Value__c = '', New_Value__c = 'Test Account', Type__c ='Text', Tracked_Field_API__c = 'Name', Tracked_Field_Label__c = 'Account Name'));
       accountFieldHistoryList.add(new Field_History__c(Tracked_Object__c = 'Account', Action_User__c = userinfo.getuserid(), Action_Date_Time__c = System.Today(), Tracked_Record_Id__c = Objid, Old_Value__c = '', New_Value__c = 'USD 12345.00', Type__c ='Currency', Tracked_Field_API__c = 'AnnualRevenue', Tracked_Field_Label__c = 'Annual Revenue'));
       accountFieldHistoryList.add(new Field_History__c(Tracked_Object__c = 'Account', Action_User__c = userinfo.getuserid(), Action_Date_Time__c = System.Today(), Tracked_Record_Id__c = Objid, Old_Value__c = '', New_Value__c = 'Test Account', Type__c ='Long Text', Tracked_Field_API__c = 'Description', Tracked_Field_Label__c = 'Account Description'));
       accountFieldHistoryList.add(new Field_History__c(Tracked_Object__c = 'Account', Action_User__c = userinfo.getuserid(), Action_Date_Time__c = System.Today(), Tracked_Record_Id__c = Objid, Old_Value__c = '', New_Value__c = '2024-03-14 06:30:00', Type__c ='DateTime', Tracked_Field_API__c = 'Date_Time_Risk_Assessed__c', Tracked_Field_Label__c = 'Date/Time Risk Assessed'));
       accountFieldHistoryList.add(new Field_History__c(Tracked_Object__c = 'Account', Action_User__c = userinfo.getuserid(), Action_Date_Time__c = System.Today(), Tracked_Record_Id__c = Objid, Old_Value__c = '', New_Value__c = '2024-03-14 06:30:00', Type__c ='DateOnly', Tracked_Field_API__c = 'Date_Time_Risk_Assessed__c', Tracked_Field_Label__c = 'Date/Time Risk Assessed'));
       accountFieldHistoryList.add(new Field_History__c(Tracked_Object__c = 'Account', Action_User__c = userinfo.getuserid(), Action_Date_Time__c = System.Today(), Tracked_Record_Id__c = Objid, Old_Value__c = '', New_Value__c = '12.00', Type__c ='Number', Tracked_Field_API__c = 'NumberOfEmployees', Tracked_Field_Label__c = 'Employees'));
       accountFieldHistoryList.add(new Field_History__c(Tracked_Object__c = 'Account', Action_User__c = userinfo.getuserid(), Action_Date_Time__c = System.Today(), Tracked_Record_Id__c = Objid, Old_Value__c = '', New_Value__c = '20.00', Type__c ='Percent', Tracked_Field_API__c = 'NumberOfEmployees', Tracked_Field_Label__c = 'Employees'));
       accountFieldHistoryList.add(new Field_History__c(Tracked_Object__c = 'Account', Action_User__c = userinfo.getuserid(), Action_Date_Time__c = System.Today(), Tracked_Record_Id__c = Objid, Old_Value__c = '', New_Value__c = 'India', Type__c ='Picklist', Tracked_Field_API__c = 'AccountCountry__c', Tracked_Field_Label__c = 'Account Country'));
       return accountFieldHistoryList;        
    }
    
    public static Drug_Product__c createDrugProducts(){
        return (new Drug_Product__c(Molecule_Name__c='Molecule_Name', International_Drug_Name__c='International_Drug_Name__c', Local_Drug_Name__c='Local_Drug_Name', Status__c= 'Active'));
    }
    
    public static Drug_Product_Name__c createOpportunityDrugProduct(Drug_Product__c dp, Opportunity opp){
        return (new Drug_Product_Name__c(Opportunity__c=Opp.Id, Drug_Product__c = dp.Id));
    }
    
    public static CBEX_Price_Modular_Cred__c createCBEXPriceModularCred(){
        return (new CBEX_Price_Modular_Cred__c(Endpoint_Token__c='metacube.com', Endpoint_PriceModuler__c ='metacube.com', Client_Id__c = '123', Client_Secret__c = '123'));
    }
	public static Quote__c createQuote(Boolean isInsert) {
        Quote__c quote = new Quote__c();
        if (isInsert) {
            insert quote;
        }
        return quote;
    }
    public static Quote__c createIqviaQuote(Id accountId, Id opportunityId, Id bidHistoryId, String pricingTool, String gbu, Boolean isInsert) {
        Quote__c quote = new Quote__c();
        quote.Related_Bid__c = bidHistoryId;
        quote.Related_Opportunity__c = opportunityId;
        quote.Related_Account__c = accountId;
        quote.Pricing_Tools__c = pricingTool;
        quote.GBU__c = gbu;
        if (isInsert) {
            insert quote;
        }
        return quote;
    }
    public static RecordType getRecordType(String developerName, String objectApiName) {
        return [SELECT Id FROM RecordType WHERE DeveloperName = : developerName AND SobjectType = :objectApiName LIMIT 1];
    }
    public static Quote_Line_Item__c createIqviaQuoteLineItem(Id quoteId, String pricingTool, Boolean isInsert) {
        Quote_Line_Item__c qLi = new Quote_Line_Item__c();
        qLi.Quote__c = quoteId;
        qLi.Pricing_Tool__c = pricingTool;
        qLi.BasePrice__c = 100;
        qLi.Quantity__c = 10;
        qLi.Cost_Price__c = 1000;
        qLi.Discount_Amount__c = 100;
        if (isInsert) {
            insert qLi;
        }
        return qLi;
    }
    public static CollectionTool__c createCollectionTool(Id bidHistoryId, String type, Boolean isInsert) {
        CollectionTool__c collectionTool = new CollectionTool__c();
        collectionTool.Bid_History__c = bidHistoryId;
        collectionTool.LPI_Date__c = Date.today();
        collectionTool.LPO_Date__c = Date.today();
        collectionTool.FPI_Date__c = Date.today();
        collectionTool.DBL_Date__c = Date.today();
        collectionTool.Scenario_Number__c = 1;
        collectionTool.Countries__c = 'Aruba';
        collectionTool.Number_of_Sites__c = 5;
        collectionTool.Type__c = type;
        if (isInsert) {
            insert collectionTool;
        }
        return collectionTool;
    }
    public static Quote_Requisites__c createQuoteRequisites(Id quoteId, String type, Boolean isInsert) {
        Quote_Requisites__c quoteRequisite = new Quote_Requisites__c();
        quoteRequisite.Quote__c = quoteId;
        quoteRequisite.Type__c = type;
        if (type == CON_CPQ.COUNTRY_INPUT) {
            quoteRequisite.Selected_Languages__c = '1';
            quoteRequisite.Country__c = 'Mexico';
            quoteRequisite.Site_Count__c = 50;
            quoteRequisite.Document_Language__c = 13;
            quoteRequisite.Site_Count_Adjusted__c = 15;
        }
        if (type == CON_CPQ.TIMELINE) {
            quoteRequisite.End_Date__c = System.today().addYears(1);
            quoteRequisite.Start_Date__c = System.today();
            quoteRequisite.Timeline_Name__c = 'First Patient In (FPI)';
        }
        if (type == CON_CPQ.STUDY_TYPE) {
            quoteRequisite.Matrix__c = 'N/A';
            quoteRequisite.Site__c = 'Indianapolis - ADME';
            quoteRequisite.Clinical_Type__c = 'Non-Clinical';
            quoteRequisite.Number_of_Analyte_Global__c = '1';
            quoteRequisite.Species_Global__c = 'Baboon';
            quoteRequisite.Analyte_ID__c = 'dummy Molecule';
            quoteRequisite.Study_Number__c = '1';
            quoteRequisite.Study_Type__c = 'Method Feasibility';
            quoteRequisite.Specimen_Type__c = 'Non-Plasma/Serum';
            quoteRequisite.Number_of_Analyte_Global__c = '1';
        }
        if (isInsert) {
            insert quoteRequisite;
        }
        return quoteRequisite;
    }
    public static Bid_History__c createBidHistoryData(Id accountId, Id opportunityId, Id recordTypeId, Boolean isInsert) {
        Bid_History__c bidHistory = new Bid_History__c();
        bidHistory.Bid_History_Account__c = accountId;
        bidHistory.Bid_History_Related_Opportunity__c = opportunityId;
        bidHistory.RecordTypeId = recordTypeId;
        bidHistory.Bid_Number__c = 0;
        bidHistory.Study_Number__c = '01';
        if (isInsert) {
            insert bidHistory;
        }
        return bidHistory;
    }
    public static Apttus_Proposal__Proposal__c createProposalData(Id accountId, Id opportunityId, Id quoteId, Id recordTypeId, String pricingTool, String stage, Boolean isInsert) {
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Account__c = accountId;
        proposal.RecordTypeId = recordTypeId;
        proposal.IQVIA_Quote__c = quoteId;
        proposal.Apttus_Proposal__Opportunity__c = opportunityId;
        proposal.Average_Gross_Margin__c = 15;
        proposal.Select_Pricing_Tool__c = pricingTool;
        proposal.Approver_Level__c = 1; 
        proposal.Total_Amount__c = 40000; 
        proposal.CountryCode__c = CON_CPQ.INDIA; 
        proposal.Average_Gross_Margin__c = 40; 
        proposal.Apttus_Proposal__Discount_Percent__c = 0; 
        proposal.Actual_Discount_Value__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = stage; 
        proposal.Apttus_QPApprov__Approval_Status__c = CON_CPQ.NONE;
        if (isInsert) {
            insert proposal;
        }
        return proposal;
    }
    public static Opportunity createOpportunityData(Id accountId, String lineOfBusiness, String identifyBusiness, String potentialRegions, String currencyIsoCode, Boolean isInsert) {
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpportunity';
        opp.stageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp.CloseDate = System.today().addYears(1);
        opp.accountId = accountId;
        opp.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        opp.CurrencyIsoCode = currencyIsoCode;
        opp.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        opp.Potential_Regions__c = potentialRegions;
        opp.Number_of_Potential_Regions__c = 0;
        opp.Line_of_Business__c = lineOfBusiness;
        opp.Identified_Business__c = identifyBusiness;
        opp.Path_Probability__c = CON_CPQ.PATH_PROBABILITY_POTENTIAL;
        if (isInsert) {
            insert opp;
        }
        return opp;
    }
    public static Id getBidHistoryRecordtypeId(String developerName) {
        return Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }
    public static Id getProposalRecordtypeId(String developerName) {
        return Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }
    
    public static Apttus_Config2__ProductConfiguration__c buildTestConfiguration(Id proposal, Boolean isInsert) {
        Apttus_Config2__ProductConfiguration__c pc = new Apttus_Config2__ProductConfiguration__c();
        pc.Apttus_QPConfig__Proposald__c = proposal;
        if (isInsert) {
            insert pc;
        }
        return pc;
    }

    public static Apttus_QPConfig__ProposalProductAttributeValue__c createProposalProductAttribute(Id proposalLineItemId, String country, Boolean isInsert) {
        Apttus_QPConfig__ProposalProductAttributeValue__c proposalProductAttribute = new Apttus_QPConfig__ProposalProductAttributeValue__c();
        proposalProductAttribute.Apttus_QPConfig__LineItemId__c = proposalLineItemId;
        proposalProductAttribute.O_Country__c = country;
        if (isInsert) {
            insert proposalProductAttribute;
        }
        return proposalProductAttribute;
    }

    public static Apttus_Config2__ProductAttributeValue__c createProductAttribute(Id lineItemId, String country, Boolean isInsert) {
        Apttus_Config2__ProductAttributeValue__c productAttribute = new Apttus_Config2__ProductAttributeValue__c();
        productAttribute.Apttus_Config2__LineItemId__c = lineItemId;
        productAttribute.O_Country__c = country;
        if (isInsert) {
            insert productAttribute;
        }
        return productAttribute;
    }

    public static Currency_Exchange_Rates__c getCurrencyExchangeRate(boolean isInsert) {
        Currency_Exchange_Rates__c currencyRate = new Currency_Exchange_Rates__c();
        currencyRate.Conversion_rate__c = 0.9761;
        currencyRate.Iso_Code__c = CON_CPQ.CHF;
        currencyRate.Effective_Date__c = Date.newInstance(2022,9,1);
        if (isInsert) {
        	insert currencyRate;
        }
        return currencyRate;
    }

    public static CPQ_Proposal_Create_Settings__c createCPQProposalCreateSettings(String name, String permissionSetName, String availPricingTools, boolean congaSetup, String priceList, boolean isInsert) {
        CPQ_Proposal_Create_Settings__c customSettingsObjforQ2 = new CPQ_Proposal_Create_Settings__c();
        customSettingsObjforQ2.Name = name;
        customSettingsObjforQ2.Permission_Set_Name__c = permissionSetName;
        customSettingsObjforQ2.Proposal_Record_Type_Name__c = CON_CPQ.TECH_SOLUTION;
        customSettingsObjforQ2.Available_Pricing_Tools__c = availPricingTools;
        customSettingsObjforQ2.Conga_Setup__c = congaSetup;
        customSettingsObjforQ2.Price_List__c = priceList;
        if (isInsert) {
            insert customSettingsObjforQ2;
        }
        return customSettingsObjforQ2;
    }
    
    public static Template_Data__c tempDataCreation(String cellRef, String field, String obj) {
        Template_Data__c temp = new Template_Data__c();
        temp.Cell_Reference__c = cellRef;
        temp.Field_Name__c = field;
        temp.Object_Name__c = obj;
        temp.Status__c = 'Active';  
        temp.Version__c = 1;
        temp.Migration_Id__c = 'T-001';
        insert temp;
        return temp;
    }
    
    public static Site_Submission__c creatSiteSubmissionRecord(Id oppId, Id investigatorAccId, Id SiteAccId){
        Site_Submission__c ss = new Site_Submission__c();
        ss.Name = 'TestR Site Submission';
        ss.Opportunity__c = oppId;
        ss.PI__c = investigatorAccId;
        ss.Site__c = SiteAccId;
        return ss;
    }
    
    public static CBEX_Unity_Flag_Outbound__c createCBEXUnityFlag(){
        CBEX_Unity_Flag_Outbound__c cufo = new CBEX_Unity_Flag_Outbound__c();
        cufo.Client_Id__c = 'HilywOhxMie0MrNzcquEwTJSPfwa';
        cufo.Client_Secret__c = '0pyYg2WxPOxLdg6SABBCZZNmM2Ea';
        cufo.Endpoint_Token__c = 'https://dev2-fedsvc.solutions.iqvia.com:443/oauth2/token	';
        cufo.Endpoint_Unity_Flag__c ='https://iqvia-rds-crm-outbound-exp-2-0-devext.us-e1.cloudhub.io/NotificationService/Notification';
        return cufo;
    }
    
    public static Intake_Unity_Flag_Sync__c createIntakeUnityFlag(String objectId, String objectType){
        Intake_Unity_Flag_Sync__c iufs= new Intake_Unity_Flag_Sync__c();
        iufs.SObject_Id__c = objectId;
        iufs.SObject_Type__c = objectType;
        return iufs;
    }
    public static CPQ_Opp_Sync_Product_Mappings__c createCospm(String productCode, String productType, boolean olisRequired, String productName, String productSyncType, String pricingToolName, String migrationId, boolean isInsert){
        CPQ_Opp_Sync_Product_Mappings__c cospm = new CPQ_Opp_Sync_Product_Mappings__c();
        cospm.Migration_Id__c = migrationId;
        cospm.CPQ_Product_Code__c = productCode;
        cospm.CPQ_Product_Type__c = productType;
        cospm.MDM_Product_Code__c = productCode;
        cospm.OLIS_Required__c = olisRequired;
        cospm.Pricing_Tool__c = pricingToolName;
        cospm.Product_Name__c = productName;
        cospm.Product_Sync_Type__c = productSyncType;
        if (isInsert) {
            insert cospm;
        }
        return cospm;
    }
    
    public Static Renewal_Task__c createRenewalTask(Id OppId){
        Renewal_Task__c rt = new Renewal_Task__c();
        rt.CurrencyIsoCode = 'USD';
        rt.Price_Increase__c = 5;
        rt.Cloning_Action__c = CON_CRM_OpportunityRenewals.NO_CHANGE_STR ; 
        rt.Cloning_Status__c = '' ; 
        rt.ownerId = userInfo.getUserId();
        rt.Targeted_Close_Date__c = System.today();
        rt.Opportunity__c = oppId;
        return rt;
    }
}