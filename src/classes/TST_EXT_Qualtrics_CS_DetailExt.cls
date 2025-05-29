@isTest
private class TST_EXT_Qualtrics_CS_DetailExt {
    private static User usr;
    private static pse__Work_Calendar__c wrkCalc;
    private static Account Acc;   
    private static Contact contactResource;
    private static Opportunity oppV;
    private static Proxy_Project__c projectA;

    @TestSetup
    static void setup() {
        List<Group> listOfGroup = new List<Group>();
        Group newGroup = new Group();
        newGroup.Name = 'Test Group';
        newGroup.type = 'Queue'; 
        listOfGroup.add(newGroup); 
        insert listOfGroup;
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        usr = createUser(UserInfo.getOrganizationId()+'1test.User@bluewolf.com',pf.Id);
        User usr1 = createUser(UserInfo.getOrganizationId()+'2test.User@bluewolf.com',pf.Id);
        User usr2 = createUser(UserInfo.getOrganizationId()+'3test.User@bluewolf.com',pf.Id);
        usr.EmployeeNumber = '0909090921';
        usr1.EmployeeNumber = '0909090922';
        usr2.EmployeeNumber = '0909090923';
        List<User> listOfUser = new List<User>{usr, usr1, usr2};
        insert listOfUser;
        GroupMember groupMember1 = new GroupMember( GroupId = newGroup.Id, UseroRGroupId =  usr.Id);
        GroupMember groupMember2 = new GroupMember( GroupId = newGroup.Id, UseroRGroupId =  usr1.Id);
        GroupMember groupMember3 = new GroupMember( GroupId = newGroup.Id, UseroRGroupId =  usr2.Id);
        List<GroupMember> listOfGroupMember = new List<GroupMember>{groupMember1, groupMember2, groupMember3};
        insert listOfGroupMember;
    }
    
    private static User createUser(String email,String ProfileId) {
        User newusr = new User();
        newusr.firstName = 'test101';
        newusr.LastName = 'test101';
        newusr.Alias = '101';
        newusr.UserName=email;
        newusr.ProfileId = ProfileId;
        newusr.Email = email;
        newusr.EmailEncodingKey ='ISO-8859-1';
        newusr.LanguageLocaleKey = 'en_US';
        newusr.TimeZoneSidKey ='America/New_York';
        newusr.LocaleSidKey = 'en_US';
        newusr.PeopleSoft_Level__c = 6;
        newusr.Change_Request_Description__c = 'test';
        newusr.Change_Request_Ticket_Number__c ='test description';
        return newusr;
    }
    
    private static void setUpWorkCalender(){
        wrkCalc = new pse__Work_Calendar__c();
        wrkCalc.Name = 'TestCal';
        wrkCalc.pse__Monday_Hours__c = 8.0;
        wrkCalc.pse__Tuesday_Hours__c = 8.0;
        wrkCalc.pse__Wednesday_Hours__c = 8.0;
        wrkCalc.pse__Thursday_Hours__c = 8.0;
        wrkCalc.pse__Friday_Hours__c = 8.0;
        insert wrkCalc;
    }
    
    private static void setUpAccount()
    {
        Acc = new Account();
        Acc.Name = 'Test';
        Acc.CurrencyIsoCode = 'USD';
        Acc.Region_Territory__c = 'Algeria';
        Acc.CustomerSegment__c = 'GOVERNMENT';
        Acc.Sub_Industry__c = 'STATE';
        insert Acc;
    }
    
    private static Contact setUpContactResource()
    {
        contactResource = new Contact();
        contactResource.FirstName = 'TestFirstName';
        contactResource.LastName = 'Test';
        contactResource.AccountId = Acc.Id;
        contactResource.CurrencyIsoCode = 'USD';
        contactResource.pse__Is_Resource_Active__c = true;
        contactResource.pse__Is_Resource__c = true;
        contactResource.pse__Resource_Role__c ='Consultant';
        contactResource.pse__Work_Calendar__c = wrkCalc.Id;
        contactResource.pse__Default_Cost_Rate__c = 25.0;
        return contactResource;
    }
    static Profile getProfileIdByName(String profileName){
        return [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
    }
    public static List<Opportunity> setupOpportunity(Account NewAccount, Integer numOpportunities){
        /*Opportunity opportunitynew = new Opportunity(Name = 'Test Opportunity', StageName = CON_CRM.CLOSED_WON_STAGE , CloseDate = Date.today(),
                                                     Line_of_Business__c = 'Biosimilars',Amount = 16000,
                                                     Actual_Close_Date__c = Date.today().addDays(-30), Conversion_Rate_To_USD__c = 1,
                                                     Survey_Recipient__c = contactResource.Id);
        */
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Parent Acc';
        insert acc1;
        Opportunity opportunitynew = UTL_TestData.createOpportunity(acc1.Id);
        opportunitynew.StageName = CON_CRM.CLOSED_WON_STAGE;
        opportunitynew.CurrencyIsoCode = 'USD';
        opportunitynew.Line_of_Business__c = 'Clinical';
        opportunitynew.Amount = 16000;
        opportunitynew.Actual_Close_Date__c = Date.today().addDays(-30);
        opportunitynew.Conversion_Rate_To_USD__c = 1;
        opportunitynew.Survey_Recipient__c = contactResource.Id;
        opportunitynew.CloseDate = Date.today();
        opportunitynew.Awarded_Date__c = Date.today();
        opportunitynew.Signed_Contract_Date__c = Date.today();
        opportunitynew.Early_Engagement_COE__c = 'Not Applicable';
        opportunitynew.Expected_Project_Start_Date__c = Date.today().addYears(1);
        opportunitynew.Expected_Project_End_Date__c = Date.today().addYears(1);
        opportunitynew.Proposal_Sent_Date__c = system.today();
        List<Opportunity> opportunityList = new List<Opportunity>{ opportunitynew};
        insert opportunityList;
        Profile profile1 = getProfileIdByName('System Administrator');
        String UserName = 'testUser1@testGroupUpdate.com'+UserInfo.getOrganizationId();
        User testUser1 = new User(ProfileId = profile1.Id, UserName = UserName,
                                  Email = 'externalUser@metacube.com', EmailenCodingKey = 'UTF-8', LocalesIdKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', TimeZonesIdKey = 'America/Los_Angeles', Alias = 'extUser',
                                  LastName = 'lastname', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '09087090918');
        insert testUser1;
        Contact contObj = new Contact(LastName = 'TestAp',RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =testUser1.Id );
        insert contObj;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Product X',ProductCode = 'Pro-X',isActive = true, Offering_Type__c ='Commercial Tech',
                                    Offering_Segment__c = 'Commercial Solutions', Material_Type__c = 'ZREP', 
                                    Pillar__c = 'Technology Solutions; Information Offering');
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,IsActive = true, CurrencyIsoCode = 'USD');
        insert pbEntry;
      
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opportunitynew.Id, pse__IsServicesProductLine__c = true,Delivery_Country__c = 'USA',
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 20000,
                                                               Segment_Flag__c = 'Commercial Solutions',
                                                               PricebookEntryId = pbEntry.Id,Therapy_Area__c = 'Hepatitis C [21]');
        insert lineItem;

        return opportunityList;
    }
    
    private static void setUpProjects() {
        projectA = new Proxy_Project__c();
        projectA.name = 'Project A';
        Integer yr = Date.today().year() - 1;
        Integer mn = Date.today().month();
        Integer dy = Date.today().day();
        projectA.Project_Start_Date__c = Date.newInstance(yr,mn,dy);
        projectA.Project_End_Date__c = System.today().addYears(1); 
        projectA.Project_Manager_Name__c = contactResource.Name;   
        projectA.Delivery_PIC_Name__c = contactResource.Name;   
        projectA.Is_Project_Billable__c = true;
        projectA.CurrencyIsoCode = 'USD';
        projectA.Opportunity__c = oppV.id;
        projectA.LI_Record_Id__c = '123';
        projectA.Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_ENGAGEMENT;
        projectA.Delivery_PIC_Offering_Segment__c = 'Consumer Health';
        projectA.Delivery_PIC_Offering_Type__c = 'Canada';
        projectA.Delivery_PIC_Product_COE__c = 'Canada';
        projectA.Delivery_PIC_Business_Unit__c = 'Canada';
        insert projectA;
        
        Proxy_Project__c projectB = new Proxy_Project__c();
        projectB.name = 'Project B';
        projectB.Project_Start_Date__c = system.today().addDays(-30);
        projectB.Project_End_Date__c = system.today().addDays(10); 
        projectB.Project_Manager_Name__c = contactResource.Name;  
        projectB.Delivery_PIC_Name__c = contactResource.Name;   
        projectB.Master_Project__c = projectA.id;
        projectB.LI_Record_Id__c = '1235';
        projectB.Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_PROJECT;
        projectB.Delivery_PIC_Offering_Segment__c = 'Consumer Health';
        projectB.Delivery_PIC_Offering_Type__c = 'Canada';
        projectB.Delivery_PIC_Product_COE__c = 'Canada';
        projectB.Delivery_PIC_Business_Unit__c = 'Canada';
        insert projectB;
    }
    
    public static void setupCustomSetting()
    {
        Contract_Management_Setting__c contractMgmt = new Contract_Management_Setting__c();
        contractMgmt.Perform_SCM_Functions_Flag__c = true;
        insert contractMgmt ;
        BNF_Settings__c bnfSetting = new BNF_Settings__c();
        bnfSetting.BNF_Release__c = '5';
        insert bnfSetting;
        Current_Release_Version__c currentReleaseVersion = new Current_Release_Version__c();
        currentReleaseVersion.Current_Release__c = '3';
        insert currentReleaseVersion;
    }
    
    static testMethod void testSaveCustomShouldSaveSurveyRecord() {
        String userName = UserInfo.getOrganizationId()+'1test.User@bluewolf.com';
        usr = [SELECT Id FROM User WHERE UserName =: userName];
        setupCustomSetting();
        setUpWorkCalender();
        setUpAccount();
        contactResource = setUpContactResource();
        contactResource.pse__Salesforce_User__c = usr.id;
        insert contactResource;
        DeclinedSurveyApproverGroup__c declinedApproverGroup = createDeclinedSurveyApproverGroup('Consumer Health','Canada',
                                                                                                 'Canada', 'Canada', 
                                                                                                 'Test Group', 1);
        DeclinedSurveyApproverGroup__c declinedSurveyApproverGroup = createDeclinedSurveyApproverGroup('', '', '', '',
                                                                                                       'Test Group', 2);
        List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList = 
            new List<DeclinedSurveyApproverGroup__c>{declinedApproverGroup, declinedSurveyApproverGroup};
        insert declinedApproverGroupList;  
        Test.startTest(); 
        System.runAs(usr)
        {   
            oppV = setupOpportunity(Acc, 1)[0];    
        }
        Test.stopTest();
        setUpProjects();
        Client_Sat_Survey__c cs = new Client_Sat_Survey__c();
        cs.opportunity__c = oppV.Id;  
        ApexPages.StandardController controller = new ApexPages.StandardController(cs);
        EXT_Qualtrics_CS_DetailExt csDetailExt = new EXT_Qualtrics_CS_DetailExt(controller);
        csDetailExt.getIsAdminUser();
        csDetailExt.SetApproverDetails();
        cs.Send_Survey__c = 'Yes';
        cs.Survey_Recipient_1__c = contactResource.Id;
        csDetailExt.saveCustom(); 
        cs.Survey_Send_Date__c = System.today() - 1;
        controller = new ApexPages.StandardController(cs);
        csDetailExt = new EXT_Qualtrics_CS_DetailExt(controller);
        csDetailExt.getIsAdminUser();
        csDetailExt.SetApproverDetails();
        
        List<Client_Sat_Survey__c> clientSatSurveyList = [SELECT Id, Name FROM Client_Sat_Survey__c];
        System.assertEquals(true, clientSatSurveyList.size() > 0, 'client Sat Survey Record Inserted');
    }
    
    static testMethod void testSaveCustomShouldThrowError() {
        String userName = UserInfo.getOrganizationId()+'1test.User@bluewolf.com';
        usr = [SELECT Id FROM User WHERE UserName =: userName];        
        setupCustomSetting();
        setUpWorkCalender();
        setUpAccount();
        contactResource = setUpContactResource();
        contactResource.pse__Salesforce_User__c = usr.id;
        insert contactResource;
        DeclinedSurveyApproverGroup__c declinedApproverGroup = createDeclinedSurveyApproverGroup('Consumer Health','Canada',
                                                                                                 'Canada', 'Canada', 
                                                                                                 'Test Group', 1);
        DeclinedSurveyApproverGroup__c declinedSurveyApproverGroup = createDeclinedSurveyApproverGroup('', '', '', '',
                                                                                                       'Test Group', 2);
        List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList = 
            new List<DeclinedSurveyApproverGroup__c>{declinedApproverGroup, declinedSurveyApproverGroup};
        insert declinedApproverGroupList;     
        Test.startTest();
        System.runAs(usr)
        {   
            oppV = setupOpportunity(Acc, 1)[0];    
        }
        Test.stopTest();
        setUpProjects();
        Client_Sat_Survey__c cs = new Client_Sat_Survey__c();
        cs.opportunity__c = oppV.Id;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(cs);
        EXT_Qualtrics_CS_DetailExt csDetailExt = new EXT_Qualtrics_CS_DetailExt(controller);
        csDetailExt.getIsAdminUser();
        csDetailExt.SetApproverDetails();
        cs.Send_Survey__c = 'Yes';
        cs.Don_t_Send_Survey_Reason__c = CON_Qualtrics.DELAYED;
        cs.Survey_Send_Date__c = Date.today().addDays(-20);
        csDetailExt.saveCustom();    
        
        System.assertEquals(true, ApexPages.hasMessages(), 'Survey Send date is in past');
        
        cs.Survey_Send_Date__c = System.today() - 1;
        controller = new ApexPages.StandardController(cs);
        csDetailExt = new EXT_Qualtrics_CS_DetailExt(controller);
        csDetailExt.getIsAdminUser();
        csDetailExt.SetApproverDetails();
    }
    
    static DeclinedSurveyApproverGroup__c createDeclinedSurveyApproverGroup(String offeringType, String businessUnit, 
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
    public static List<Opportunity> setupOpportunity1(Account NewAccount, Integer numOpportunities){
        /*Opportunity opportunitynew = new Opportunity(Name = 'Test Opportunity', StageName = CON_CRM.CLOSED_WON_STAGE , CloseDate = Date.today(),
                                                     Line_of_Business__c = 'Biosimilars',Amount = 16000,
                                                     Actual_Close_Date__c = Date.today().addDays(-30), Conversion_Rate_To_USD__c = 1,
                                                     Survey_Recipient__c = contactResource.Id);
        */
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Parent Acc';
        insert acc1;
        Opportunity opportunitynew = UTL_TestData.createOpportunity(acc1.Id);
        opportunitynew.StageName = CON_CRM.CLOSED_WON_STAGE;
        opportunitynew.CurrencyIsoCode = 'USD';
        opportunitynew.Line_of_Business__c = 'Other';
        opportunitynew.Amount = 16000;
        opportunitynew.Actual_Close_Date__c = Date.today().addDays(-30);
        opportunitynew.Conversion_Rate_To_USD__c = 1;
        opportunitynew.Survey_Recipient__c = contactResource.Id;
        opportunitynew.CloseDate = Date.today();
        opportunitynew.Awarded_Date__c = Date.today();
        opportunitynew.Signed_Contract_Date__c = Date.today();
        opportunitynew.Expected_Project_Start_Date__c = Date.today().addYears(1);
        opportunitynew.Expected_Project_End_Date__c = Date.today().addYears(1);
        opportunitynew.Proposal_Sent_Date__c = system.today();
        //insert opportunitynew;
        List<Opportunity> opportunityList = new List<Opportunity>{ opportunitynew};
        insert opportunityList;
        Profile profile1 = getProfileIdByName('System Administrator');
        String UserName = 'testUser1@testGroupUpdate.com'+UserInfo.getOrganizationId();
        User testUser1 = new User(ProfileId = profile1.Id, UserName = UserName,
                                  Email = 'externalUser@metacube.com', EmailenCodingKey = 'UTF-8', LocalesIdKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', TimeZonesIdKey = 'America/Los_Angeles', Alias = 'extUser',
                                  LastName = 'lastname', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '09087090918');
        insert testUser1;
        Contact contObj = new Contact(LastName = 'TestAp',RecordTypeId=CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID,Salesforce_User__c =testUser1.Id );
        insert contObj;
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Product X',ProductCode = 'Pro-X',isActive = true, Offering_Type__c ='Commercial Tech',
                                    Offering_Segment__c = 'Commercial Solutions', Material_Type__c = 'ZREP', 
                                    Pillar__c = 'Technology Solutions; Information Offering');
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,IsActive = true);
        insert pbEntry;
      
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opportunitynew.Id, pse__IsServicesProductLine__c = true,Delivery_Country__c = 'USA',
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 20000,
                                                               Segment_Flag__c = 'Commercial Solutions',
                                                               PricebookEntryId = pbEntry.Id,Therapy_Area__c = 'Hepatitis C [21]');
        insert lineItem;

        return opportunityList;
    }
    static testMethod void testSaveCustomShouldSaveSurveyRecord1() {
        String userName = UserInfo.getOrganizationId()+'1test.User@bluewolf.com';
        usr = [SELECT Id FROM User WHERE UserName =: userName];
        setupCustomSetting();
        setUpWorkCalender();
        setUpAccount();
        contactResource = setUpContactResource();
        contactResource.pse__Salesforce_User__c = usr.id;
        insert contactResource;
        DeclinedSurveyApproverGroup__c declinedApproverGroup = createDeclinedSurveyApproverGroup('Consumer Health','Canada',
                                                                                                 'Canada', 'Canada', 
                                                                                                 'Test Group', 1);
        DeclinedSurveyApproverGroup__c declinedSurveyApproverGroup = createDeclinedSurveyApproverGroup('', '', '', '',
                                                                                                       'Test Group', 2);
        List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList = 
            new List<DeclinedSurveyApproverGroup__c>{declinedApproverGroup, declinedSurveyApproverGroup};
        insert declinedApproverGroupList;  
        Test.startTest();   
        oppV = setupOpportunity1(Acc, 1)[0]; 
        System.debug(oppV);
        System.debug([select Id,Line_of_Business__c,Is_Survey_Eligible_for_Non_RDS__c from Opportunity ]);
        System.debug(oppV.Is_Survey_Eligible_for_Non_RDS__c);
        Test.stopTest();
        setUpProjects();
        Client_Sat_Survey__c cs = new Client_Sat_Survey__c();
        cs.opportunity__c = oppV.Id;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(cs);
        EXT_Qualtrics_CS_DetailExt csDetailExt = new EXT_Qualtrics_CS_DetailExt(controller);
        csDetailExt.getIsAdminUser();
        csDetailExt.SetApproverDetails();
        cs.Send_Survey__c = 'Yes';
        cs.Don_t_Send_Survey_Reason__c = CON_Qualtrics.DECLINED;
        cs.Survey_Send_Date__c = Date.today().addDays(-20);
        csDetailExt.saveCustom();    
        
        System.assertEquals(true, ApexPages.hasMessages(), 'Survey Send date is in past');
        
        cs.Survey_Send_Date__c = System.today() - 1;
        controller = new ApexPages.StandardController(cs);
        csDetailExt = new EXT_Qualtrics_CS_DetailExt(controller);
        csDetailExt.getIsAdminUser();
        csDetailExt.SetApproverDetails();
    }
}