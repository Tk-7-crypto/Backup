/****************************************************************************************
Name            : CommanUtilityTestFunction
Created Date    : Dec 04, 2012              
Usage           : This Class is created in order to provide object in order to use it in 
Test methods. 
****************************************************************************************/
public with sharing Class CommanUtilityTestFunction{
    
    public static SalesOrg__c setUpSalesOrg(){
        return new SalesOrg__c(name='testSalesOrg',CompanyCode__c = 'tst',CurrencyIsoCode = 'USD');
    }
    
    public static pse__Proj__c createEngagement(Contact con, Profit_Centre__c region, Account acc, SalesOrg__c sorg){
        pse__Proj__c projectA = new pse__Proj__c();
        projectA.name = 'Project A';
        Integer yr = Date.today().year() - 1;
        Integer mn = Date.today().month();
        Integer dy = Date.today().day();
        projectA.pse__Start_Date__c = Date.newInstance(yr,mn,dy);//System.today().addYears(-1);
        projectA.pse__End_Date__c = System.today().addYears(1); 
        projectA.pse__Project_Manager__c = con.Id;   
        projectA.pse__Stage__c = 'In Progress'; 
        //projectA.DeliveryPIC__c = con.Id;   
        //projectA.WorkingAtRisk__c = false;
        projectA.pse__Is_Active__c = true;
        projectA.pse__Region__c = region.Id;
        //projectA.FilteredRegion__c = region.Id;
        projectA.pse__Account__c = acc.Id;
        //projectA.SalesOrg__c = sorg.Id;
        //projectA.pse__Is_Billable__c = true;
        projectA.CurrencyIsoCode = 'USD';
        projectA.pse__Allow_Expenses_Without_Assignment__c = true;
        //projectA.pse__Opportunity__c = opp.id;
        //projectA.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Engagement').getRecordTypeId();
        //projectA.AlternateApprover1__c = con.id;
        //projectA.AlternateApprover2__c = con.id;
        return projectA;
    }
    
    // Helper function to create Account object and return it.
    public static Account createAccount(){
        DateTime current = System.now();
        Long timeInMili = current.getTime();
        return new Account(
            Name = 'DummyAccount'+timeInMili+'', 
            CurrencyIsoCode = 'USD',
            CustomerSegment__c = 'GOVERNMENT',
            AccountCountry__c = 'AF',
            Sub_Industry__c = 'STATE'
        );            
    }
    
    // Helper function to create Contact object and return it.
    public static Contact createContact(Account account, SalesOrg__c sOrg, User user ){
        return CommanUtilityTestFunction.createContact(account, sOrg, user, null, null);
    }
    
    // Helper function to create Contact object and return it.
    public static Contact createContact(Account account, SalesOrg__c sOrg, User user, pse__Work_Calendar__c wrkCalc, Profit_Centre__c region ){
        
        Contact contactResource = new Contact();
        contactResource.FirstName = 'testFirstName';
        contactResource.LastName = 'testcode' + Math.random();
        contactResource.AccountId = account.Id;
        //if(sOrg != null)
        //    contactResource.SalesOrg__c = sOrg.Id;
        contactResource.CurrencyIsoCode = 'USD';
        contactResource.pse__Is_Resource_Active__c = true;
        contactResource.pse__Is_Resource__c = true;
        contactResource.pse__Resource_Role__c ='Consultant';
        if(wrkCalc != null)
            contactResource.pse__Work_Calendar__c = wrkCalc.Id;
        contactResource.pse__Default_Cost_Rate__c = 25.0;
        //if(user != null)
        //    contactResource.ResourceManager__c = user.id;
        if(user != null)
            contactResource.pse__Salesforce_User__c = user.id;
        //contactResource.ContractedHours__c = 40;
        //if(region != null)
            //contactResource.pse__Region__c = region.Id;
        //insert contactResource;
        return contactResource;
    }
    
    //Helper funciton to get profile Id from existing profile
    public static Profile getProfile(String profileName){
        if(profileName.contains('PSE_Operations') || profileName.contains('PSA_Operations')) {
            return [select id from Profile where Name like 'PSE_Operations%' LIMIT 1];
        }
        else {
        return [select id from Profile where Name =: profileName LIMIT 1];
    }
    }
    
    // Helper function to create User object with Profile Id and return it.
    public static User createTestUser(Id profileId) {
        
        DateTime current = System.now();
        Long timeInMili = current.getTime();     
        Double previx = Math.random();
        String Email = 'Email'+timeInMili+'@test.com';
        String Username = 'E'+timeInMili+String.valueOf(previx) +'@test.com';
        String FirstName = 'UserF'+timeInMili +'';
        String LastName = 'UserL'+timeInMili +'';
        current = System.now();
        timeInMili = current.getTime();
        String CommunityNickname = 'Nick'+timeInMili+'';
        
        return new User(
            FirstName = FirstName,
            LastName = LastName,
            Email = Email,
            Username = Username,
            ProfileId = profileId,
            Alias = LastName.substring(0,8),
            CommunityNickname = CommunityNickname,
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            //PeopleSoft_Level__c = 6,
            IsActive=true,
            employeenumber= String.valueOf(System.currentTimeMillis())
        );
        
    }
    
    public static Product2 createProduct() {
        return new Product2 (Name = 'Test Product #1',
                             currencyisocode='EUR',
                             Description = 'Test Product #1',
                             
                             ProductCode = 'TP1',
                             
                             Family = 'Annual',
                             
                             IsActive = true);
    }
    
    public static PricebookEntry createPricebookEntry(Product2 prod) {
        PricebookEntry PE1 = new PricebookEntry();
        PE1.UseStandardPrice = false;
        PE1.Pricebook2Id='01s70000000AGCeAAO';
        PE1.Product2Id=prod.id;
        PE1.IsActive=true;
        PE1.currencyisocode='USD';
        PE1.UnitPrice=100.0;
        return PE1;
    }
    
    
    public static OpportunityLineItem createOppLineItem(Opportunity op, PricebookEntry pe) {
        //making it false so that SCM synching could not work on OLI creation
        ConstantClass.AllowAGLIUpdate=false;
        
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = op.Id;
        OLI1.PricebookEntryId = pe.Id;
        OLI1.Quantity = 1.00;
        OLI1.UnitPrice = 10000;
		OLI1.Delivery_Country__c = 'USA';
        //OLI1.Territory__c='USA';
        return OLI1;
    }
    
    public static Opportunity createOpportunity1(Account account, List<Contact> picUser, pse__Practice__c pseP){
        DateTime current = System.now();
        Long timeInMili = current.getTime();
        return new Opportunity(
            Name = 'Test Opportunity'+timeInMili+'' ,
            AccountId = account.Id,                                          
            closeDate = Date.today(),
            StageName = '3 - Understand Pre Proposal',
            Budget_Available__c= 'Yes',
            CurrencyIsoCode = 'USD',
            Main_Delivery_Country__c = 'UK',
            Contract_Start_Date__c = Date.today().addDays(-2), 
            Contract_End_Date__c = Date.today().addDays(10),      
            pse__Practice__c = pseP.Id
        );
    }
    
    public static Opportunity createOpportunity1(Account account){
        Opportunity testOpportunity = new Opportunity(Name='test1',StageName='1. Identifying Opportunity',CloseDate=System.today());
        testOpportunity.LeadSource = 'Account Planning';
        testOpportunity.CurrencyIsoCode = 'USD';
        testOpportunity.Budget_Available__c = 'Yes';
        //testOpportunity.Unique_Business_Value__c = 'Unknown';
        //testOpportunity.Compelling_Event__c = 'No';
        //testOpportunity.StageName='2. Qualifying Opportunity';
        testOpportunity.AccountId = account.Id;
        testOpportunity.Contract_Term__c='Single-Period';
        testOpportunity.Contract_End_Date__c = system.today();
        testOpportunity.Contract_Start_Date__c = system.today();
        //testOpportunity.Win_Loss_Reason__c='Win - Competitive Situation';
        testOpportunity.Contract_Type__c='Individual';
        testOpportunity.LeadSource = 'Account Planning';
        //testOpportunity.Win_Additional_Details__c = 'Additional details';
        //testOpportunity.Win_Loss_Reason_Details__c = 'Win Loss Reason Details';
        return testOpportunity;
    }
    
    public static pse__Work_Calendar__c setUpWorkCalender(){
        pse__Work_Calendar__c wrkCalc = new pse__Work_Calendar__c();
        wrkCalc.Name = 'TestCal';
        wrkCalc.pse__Monday_Hours__c = 8.0;
        wrkCalc.pse__Tuesday_Hours__c = 8.0;
        wrkCalc.pse__Wednesday_Hours__c = 8.0;
        wrkCalc.pse__Thursday_Hours__c = 8.0;
        wrkCalc.pse__Friday_Hours__c = 8.0;
        //insert wrkCalc;
        return wrkCalc;
    }
    
    public static Profit_Centre__c setUpRegion(){
        Profit_Centre__c testRegion = new Profit_Centre__c();
        testRegion.Name = 'USD';
        testRegion.CurrencyIsoCode = 'USD';
        testRegion.ProfitCenterCode__c = 'USD';
        //testRegion.ProjectsAllowed__c = true;
        return testRegion; 
    }    
}