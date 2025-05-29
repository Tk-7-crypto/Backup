/**
 * This class is used to load sample data in Account, Contact and Opportunity.
 * Also Used to aborted the apex batch.
 * Modified the custome setting.
 */
public class LoadCRMSampleData {
    static List<Account> accountList;
    static List<Contact> contactList;
    static List<Opportunity> opportunityList = new List<Opportunity>();
    static String stage = '1. Identifying Opportunity';
    static String accountName = 'Test Account ';
    static String accountCountry = 'IN';
    static String accountCustomerSegment = 'CONTRACT RESEARCH';
    static String accountSubIndustry = 'RESEARCH AND DEVELOPMENT SERVICES';
    static String contactName = 'Test Contact ';
    static String opportunityName = 'Test Opportunity ';
    static String opportunityLeadSource = 'Account Planning';
    static String opportunityLineOfBusiness = 'Commercial Solutions';
    
   /**
    *  This method is used to create sample data. 
    */
    public static void  createSampleData(Integer noOfRecord){
        
         try{
           modifyCustomSettings();
        }catch(Exception e){
            System.debug('Error of Custome setting' + e.getMessage());
        }
        
          try{
           abortedApexBatch();
        }catch(Exception e){
           System.debug('Error of Apex batch setting' + e.getMessage());     
        }
        
        try{
             createAccount(noOfRecord); 
        }catch(Exception e){
           System.debug('Error of Account setting' + e.getMessage());
        }
        
        try{
        createContact(noOfRecord);
        }catch(Exception e){
           System.debug('Error of Contact setting' + e.getMessage());
        }
        
        try{
            createOpportunity(noOfRecord);
        }catch(Exception e){
           System.debug('Error of Opportuntiy setting' + e.getMessage());
        }
        
        try{
            createDrugProductMasterData(noOfRecord);
        }catch(Exception e){
           System.debug('Error of DrugProduct setting' + e.getMessage());
        }
        
        try{
            createAvacareSetup();
        }catch(Exception e){
           System.debug('Error of Avacare setting' + e.getMessage());
        }
        
        try{
            createRevenueAnalyst();
        }catch(Exception e){
           System.debug('Error of RevenueAnalyst' + e.getMessage());
        }
    }
    
    /**
     * This Method is used to modified the custom setting.
     */ 
    public static void modifyCustomSettings(){
        //Change custom setting of MuleDoft Integration Control.
        Mulesoft_Integration_Control__c mulesoftField = Mulesoft_Integration_Control__c.getOrgDefaults();
        mulesoftField.Enable_OLI_Sync_Validation__c = false;
        mulesoftField.Enable_Opportunity_Sync_Validation__c = false;
        mulesoftField.Suppress_Outbound_Messages__c = true;
        
        upsert mulesoftField;
    }
    
    /**
     * This method is used to terminate the apex batch.
     */ 
    public static void abortedApexBatch(){
        List<AsyncApexJob> batchList = [SELECT Id, Status FROM AsyncApexJob];
        for(AsyncApexJob apexJob : batchList){
            if(apexJob.Status != 'Aborted' ){ 
                System.abortJob(apexJob.Id);
            }
        }
    }
    
    /**
     *This method to used to create account.
     */ 
    public static Void createAccount(Integer noOfRecord){
        accountList = new List<Account>();
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Unvalidated_Account').getRecordTypeId();
        for(Integer count = 1; count <= noOfRecord; count++ ){
            Account acc = new Account();
            acc.Name = accountName + count;
            acc.AccountCountry__c = accountCountry;
            acc.CustomerSegment__c = accountCustomerSegment;
            acc.Sub_Industry__c = accountSubIndustry;
            acc.RecordTypeId = accountRecordTypeId;
            accountList.add(acc);
        }
        
        insert accountList;
    }
    
    /**
     *This method to used to create contact.
     */ 
    public static void createContact(Integer noOfRecord){
        contactList = new List<Contact>();
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
        for(Integer count = 1; count <= noOfRecord; count++ ){
            Contact con = new Contact();
            con.FirstName = contactName;
            con.LastName = contactName + count;
            con.RecordTypeId = contactRecordTypeId;
            con.AccountId = accountList[count-1].Id;
            contactList.add(con);
        }
        
        insert contactList;
    }
    
    /**
     *This method to used to create opportunity.
     */
    public static void createOpportunity(Integer noOfRecord){
        for(Integer count = 1; count <= noOfRecord; count++ ){
            Opportunity opp = new Opportunity();
            opp.Name = opportunityName + count;
            opp.accountId = accountList[count-1].Id;
            opp.stageName = stage;
            opp.CloseDate = System.today().addYears(1);
            opp.Probability = 10;
            opp.LeadSource = opportunityLeadSource;
            opp.Line_of_Business__c = opportunityLineOfBusiness;
            opportunityList.add(opp);
            List<User> userID = [Select Id from User Where Name like 'Continuous Integration%'];
            Opp.OwnerId = UserId[0].Id;
        }
        
        insert opportunityList;
    }
    
    public static void createDrugProductMasterData(Integer noOfRecord){
        List<Drug_product__c> dps = new List<Drug_product__c>();
        for(Integer count = 1; count <= noOfRecord; count++ ){
            Drug_product__c dp = new Drug_product__c();
            dp.International_Drug_Name__c = 'TestR	'+ count;
            dp.Local_Drug_Name__c = 'TestR	'+ count;
            dp.Molecule_Name__c = 'TestR	'+ count;
            dp.Status__c=  'Active';
            dps.add(dp);
        }
        dps.add(new Drug_Product__c(International_Drug_Name__c = 'ASSET AGNOSTIC (OTHERS)', Local_Drug_Name__c = 'Local Name', Molecule_Name__c='Molecule', Status__c = 'Active'));
        insert dps;
    }
    
    public static void createAvacareSetup(){
        Account avacareAcc = new Account();
        avacareAcc.Name = 'Avacare';
        avacareAcc.AccountCountry__c = 'US';
        avacareAcc.CustomerSegment__c = 'Contract Research';
        avacareAcc.Sub_Industry__c = 'Research and Development Services';
        avacareAcc.Headquarter__c = 'Global HQ';
        insert avacareAcc;
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(ParentId = avacareAcc.Id, AccountCountry__c = 'IN', CustomerSegment__c = accountCustomerSegment, Sub_Industry__c = accountSubIndustry, Type2__c = 'Clinical Site', Name = 'Avacare Site'));
        accList.add(new Account(ParentId = avacareAcc.Id, AccountCountry__c = 'IN', CustomerSegment__c = accountCustomerSegment, Sub_Industry__c = accountSubIndustry, Type2__c = 'Investigator', Name = 'Avacare Investigator'));
        accList.add(new Account(ParentId = avacareAcc.Id, AccountCountry__c = 'IN', CustomerSegment__c = accountCustomerSegment, Sub_Industry__c = accountSubIndustry, Type2__c = 'CRO', Name = 'Avacare CRO'));
        insert accList;

    }
    
    public static void createRevenueAnalyst(){
        Revenue_Analyst__c ra = new Revenue_Analyst__c(User__c = UserInfo.getUserId(), Is_SAP_Revenue_Analyst__c = true, Name='GFSS RA DE');
        insert ra;
    }
}