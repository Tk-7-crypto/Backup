/*
 * This class contains all the data being used for test methods for BNF.
 */
public class BNF_Test_Data {
    static Account TestAccount;
    static Contact testContact;
    private static BNF2__c TestBnf;
    private static MIBNF2__c TestMIBNF;
    private static MIBNF_Component__c TestMIBNF_Comp;
    private static MI_BNF_LineItem__c TestMI_BNFLineItem;
    private static Opportunity TestOpp;
    private static Integer NumAddresses = 20;
    private static Integer NumSapContactsPerAddress = 10;
    private static List<Address__c> TestAddress_Array;
    private static List<SAP_Contact__c> TestSapContact_Array;
    private static BNF_Settings__c bnfsetting;
    private static List<OpportunityLineItem> OLI_Array;
    private static list<PricebookEntry> PEList;
    private static List<Product2> productList;
    private static List<OpportunityLineItem> oliList;
    private static User u;
    private static Revenue_Analyst__c TestLocalRA;
    private static List<Billing_Schedule__c> billingSchedule;
    private static List<Billing_Schedule_Item__c> billingScheduleItem;
    
    public static Profile getProfile(){
        Profile p = [select id from profile where name Like '%System Administrator%' limit 1]; 
        return p;
    }
    
    public static User createUser(){
        String uniqueUserName = String.valueof(Datetime.now()).replace(' ', '') .replace(':', '') .replace('-', '');
        u = new User(alias = 'alias', email='testBNFUser@metacube.com',
                     emailencodingkey='UTF-8', lastname='lstname',FirstName='fstname', languagelocalekey='en_US', 
                     localesidkey='en_US', profileId = getProfile().id, timezonesidkey='America/Los_Angeles', username=uniqueUserName+'BNF.username@metacube.com', Change_Request_Description__c = 'test',
                     Change_Request_Ticket_Number__c ='test description', employeenumber= String.valueOf(System.currentTimeMillis())
);
        
        insert u;
        return u;
    }
    
    public static Revenue_Analyst__c createRA(){
        TestLocalRA = new Revenue_Analyst__c(name='TestRA',User__c = u.Id);
        insert TestLocalRA;
        return TestLocalRA;
    }
    
    public static List<Product2> createProductList(){
        List<Product2> tempProductList = new List<Product2>();
        Product2 objProduct1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
        objProduct1.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        tempProductList.add(objProduct1);
        Product2 objProduct2 = new Product2(Name='test2', ProductCode='2', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZPUB',CanUseRevenueSchedule= true);
        objProduct2.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        tempProductList.add(objProduct2);
        Product2 objProduct3 = new Product2(Name='test3', ProductCode='3', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
        objProduct3.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        tempProductList.add(objProduct3);
        Product2 objProduct4 = new Product2(Name='test4', ProductCode='4', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZPUB',CanUseRevenueSchedule= true);        
        objProduct4.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        tempProductList.add(objProduct4);
        Product2 objProduct5 = new Product2(Name='test5', ProductCode='5', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true);
        objProduct5.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        tempProductList.add(objProduct5);
        insert tempProductList;
        return tempProductList;
    }
    
    public static List<PricebookEntry> cretaePriceBook() {
        List<Product2> lstPro = createProductList();
        PEList  =new list<PricebookEntry>();
        for(Integer i=0;i<5;i++)
        {
            PricebookEntry pbe = new PricebookEntry();
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            pbe.Product2Id=lstPro[i].id;
            pbe.IsActive=true;
            pbe.UnitPrice=100.0;
            pbe.CurrencyIsoCode = 'USD';
            PEList.add(pbe);
        }
        insert PEList ;
        return PEList;
    }
    
    public static List<OpportunityLineItem> createOppLineItem()
    {
        oliList = new List<OpportunityLineItem>();
        List<PricebookEntry> lstPB = cretaePriceBook();
        for(Integer i=0;i<5;i++)
        {
            OpportunityLineItem add1_oli = new OpportunityLineItem();
            add1_oli.OpportunityId = TestOpp.Id;
            add1_oli.Sale_Type__c = 'New';
            add1_oli.Revenue_Type__c = 'Ad Hoc';
            add1_oli.Product_Start_Date__c = Date.today();
            add1_oli.Product_End_Date__c = Date.today().addYears(1) ;
            add1_oli.PricebookEntryId = lstPB[i].Id;
            add1_oli.Billing_Frequency__c = 'Once';
            add1_oli.Proj_Rpt_Frequency__c='Once [O]';
            add1_oli.Therapy_Area__c= 'Hepatitis C [21]';
            add1_oli.Quantity = 1.00;
            add1_oli.UnitPrice = 10000;  
            add1_oli.List_Price__c = 100;
            add1_oli.Delivery_Country__c = 'USA';
            oliList.add(add1_oli);
        }
        UTL_ExecutionControl.stopTriggerExecution = true;
        insert oliList;
        UTL_ExecutionControl.stopTriggerExecution = false;
        List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
        for (OpportunityLineItem OLI:oliList)
          {
            //  Create 18 schedules to cover 18 months from the first month of the current year
            Integer RevFactor = 1;
            Double dRevenueAmount = RevFactor*1000.00;
            RevFactor = RevFactor + 2;
            Date strScheduleDate = Date.valueOf(String.valueOf(System.now().year())+'-01-15 00:00:00');    
            for (Integer i = 0; i < 3; i++) 
            {
              OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
              OliSched.OpportunityLineItemId = OLI.Id;
              OliSched.Type = 'Revenue';
              OliSched.Revenue = dRevenueAmount;
              OliSched.ScheduleDate = strScheduleDate;
              strScheduleDate = strScheduleDate.addMonths(1);
              InsertOLISList.add(OliSched); 
            }
          }
          insert InsertOLISList;
        
        return oliList;
    }
    
    public static Account createAccount(){
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.AccountCountry__c = 'AF';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('NEW');
        TestAccount.Website = 'https://www.test.com';
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE'; 
        insert TestAccount;
        return TestAccount;
    }
    
    public static Contact createContact(){
        testContact = new Contact(FirstName = 'MainDecisionMaker', LastName='Contact', AccountId = TestAccount.Id, Email = 'abc@metacube.com', CurrencyIsoCode = 'USD');
        insert testContact;
        return testContact;
    }
    
    public static List<Address__c> createAddress_Array(){
        Integer AccountIterator = 0;
        TestAddress_Array = new List<Address__c>();
        for (Integer i=0; i<5; i++)
        {
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Enabled_Sales_Orgs__c='IHA, IMS Health Rotkreuz [CH03]',
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
        return TestAddress_Array;
    }
    
    public static List<SAP_Contact__c>createSapContact_Array(){
        TestSapContact_Array = new List<SAP_Contact__c>();
        Integer AddressIterator = 0;
        for (Integer i=0; i<5; i++)
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
        return TestSapContact_Array;
    }
    
    public static Opportunity createOpp(){
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        TestOpp = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Compelling_Event__c = 'No';
        TestOpp.StageName='5. Finalizing Deal';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        TestOpp.Potential_Regions__c = 'Japan';
        TestOpp.QI_Invited_to_Present__c = 'No';
        TestOpp.FPI_Date__c = system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        //TestOpp.Win_Additional_Details__c = 'Additional details';
        //TestOpp.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Is_this_IQVIA_Biotech__c = 'No';
        TestOpp.Potential_Regions__c = 'Asia Pacific';
        TestOpp.QI_Invited_to_Present__c = 'No';
        TestOpp.FPI_Date__c = system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
        TestOpp.Potential_Competitor_1__c = comp.Id;											
        insert TestOpp;
        return TestOpp;
    }
    
    public static BNF_Settings__c createBNFSetting(){
        
           bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=true,BNF_Release__c = '2019');
           //bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=true);
           bnfsetting.Excluded_Products__c = 'ZQUI|TEst';
           insert bnfsetting;
           return bnfsetting;
    }
    public static Current_Release_Version__c createCurrentReleaseVersionSetting(){
        
           Current_Release_Version__c currentReleaseVersion=new Current_Release_Version__c(Current_Release__c ='2019.02' ,Name = 'a');
           insert currentReleaseVersion;
           return currentReleaseVersion;
    }
    public static List<User_Locale__c> create_User_LocaleSetting(){
           List<User_Locale__c> localeList = new List<User_Locale__c>();
           User_Locale__c User_LocaleSetting1=new User_Locale__c(name = 'Format1',Format__c='1211.22',LocaleSidKey__c='bnf',LocaleSidKey1__c = 'ft1');
           User_Locale__c User_LocaleSetting2=new User_Locale__c(name = 'Format2',Format__c='1212.22',LocaleSidKey__c='bnf1',LocaleSidKey1__c = 'ft23');
            User_Locale__c User_LocaleSetting3=new User_Locale__c(name = 'Format3',Format__c='1213.22',LocaleSidKey__c='bnf2',LocaleSidKey1__c = 'ft3');
            User_Locale__c User_LocaleSetting4=new User_Locale__c(name = 'Format4',Format__c='1214.22',LocaleSidKey__c='bnf3',LocaleSidKey1__c = 'ft4');
            User_Locale__c User_LocaleSetting5=new User_Locale__c(name = 'Format5',Format__c='1215.22',LocaleSidKey__c='bnf4',LocaleSidKey1__c = 'ft5');
            User_Locale__c User_LocaleSetting6=new User_Locale__c(name = 'Format6',Format__c='1216.22',LocaleSidKey__c='bnf5',LocaleSidKey1__c = 'ft5');
           User_Locale__c User_LocaleSetting7=new User_Locale__c(name = 'Format7',Format__c='1,234.56',LocaleSidKey__c=';en_IE_EURO;ar;zh;iw;ja;ko;tl;th;en_GH;en_BB;en_BM;en_IN;en_ID;en_NG;en_SG;iw_IL;tl_PH;ar_SA;ar_BH;ar_KW;ar_EG;ar_JO;ar_LB;ar_AE;zh_TW;zh_CN;zh_HK;en_US;en_AU;en_CA;en_GB;en_NZ;en_IE;en_ZA;en_PH;ko_KR;ja_JP;es_MX;es_GT;es_PA;es_DO;es_PE;es_SV;es_HN;',LocaleSidKey1__c = ';es_PR;th_TH;ur_PK;');
            localeList.add(User_LocaleSetting1);
            localeList.add(User_LocaleSetting2);
            localeList.add(User_LocaleSetting3);
            localeList.add(User_LocaleSetting4);
            localeList.add(User_LocaleSetting5);
            localeList.add(User_LocaleSetting6);
            localeList.add(User_LocaleSetting7);
           insert localeList;
           return localeList;
    }
    
    public static BNF2__c createBNF(){
        TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
        TestBnf.Contract_End_Date__c = Date.today().addYears(2);
        TestBnf.IMS_Sales_Org__c = 'IHA, IMS Health Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.Bill_To__c=TestAddress_Array[0].id;
        TestBnf.X2nd_Copy__c=TestAddress_Array[1].id;
        TestBnf.Carbon_Copy__c=TestAddress_Array[2].id;
        TestBnf.Ship_To__c=TestAddress_Array[3].id;
        TestBnf.Cover_Sheet__c=TestAddress_Array[4].id;
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        insert TestBnf;
        return TestBnf;
    }
    
    public static MIBNF2__c createMIBNF(){
        TestMIBNF=new MIBNF2__c();
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
        
        insert TestMIBNF;
        return TestMIBNF;
    }
    
    public static MIBNF_Component__c createMIBNF_Comp(){
        TestMIBNF_Comp=new MIBNF_Component__c();
        TestMIBNF_Comp.MIBNF__c=TestMIBNF.Id;
        TestMIBNF_Comp.BNF_Status__c='New';
        TestMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        TestMIBNF_Comp.Print_Shop__c='No';
        TestMIBNF_Comp.Bill_To__c=TestAddress_Array[0].id;
        TestMIBNF_Comp.X2nd_Copy__c=TestAddress_Array[1].id;
        TestMIBNF_Comp.Carbon_Copy__c=TestAddress_Array[2].id;
        TestMIBNF_Comp.Ship_To__c=TestAddress_Array[3].id;
        TestMIBNF_Comp.Cover_Sheet__c=TestAddress_Array[4].id;
        //TestMIBNF_Comp.Addendum__c=true;
        insert TestMIBNF_Comp;
        return TestMIBNF_Comp;
    }
    
    public static MI_BNF_LineItem__c createMI_BNF_LineItem(){
        TestMI_BNFLineItem = new MI_BNF_LineItem__c();
        TestMI_BNFLineItem.MIBNF_Component__c = TestMIBNF_Comp.id;
        TestMI_BNFLineItem.Opportunity_Line_Itemid__c = oliList[0].Id;
        TestMI_BNFLineItem.Total_Price__c = oliList[0].TotalPrice;
        insert TestMI_BNFLineItem;
        return TestMI_BNFLineItem;
    }
    
    public static List<Billing_Schedule__c> createBillingSchedule(){
        billingSchedule = new List<Billing_Schedule__c>();
        for(Integer i=0;i<5;i++){
            Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule'+i, OLIId__c = oliList[i].id);
            billingSchedule.add(sche);
        }
        insert billingSchedule;
        return billingSchedule;
    }
    
    public static List<Billing_Schedule_Item__c> createBillingScheduleItem(){
        billingScheduleItem = new List<Billing_Schedule_Item__c>();
        for(Integer i=0;i<5;i++){
            Billing_Schedule_Item__c sche1 = new Billing_Schedule_Item__c(name = 'textScheduleItem'+i, Billing_Amount__c = 2000,Billing_Date__c = system.today(),Billing_Schedule__c = billingSchedule[i].id);
            Billing_Schedule_Item__c sche2 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp'+i, Billing_Amount__c = 3000, Billing_Date__c = system.today().addYears(1),Billing_Schedule__c = billingSchedule[i].id);
            billingScheduleItem.add(sche1);
            billingScheduleItem.add(sche2);
        }
        insert billingScheduleItem;
        return billingScheduleItem;
    }
}