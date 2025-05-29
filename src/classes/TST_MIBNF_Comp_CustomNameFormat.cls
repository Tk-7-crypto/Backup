/**
* MI_BNF_Comp_CustomNameFormat Trigger Test
 */
@isTest
private class TST_MIBNF_Comp_CustomNameFormat {

    public static MIBNF2__c MIBNF;
    public static MIBNF_Component__c MIBNF_Comp;
    public static Opportunity opp;
    
    
    public static MIBNF_Component__c[] MIBNF_CompToCreate;
    
    static testMethod void NameFormat1() {
        // TO DO: implement unit test
        setupMIBNF();
        test.starttest();
        MIBNF_Component__c[] MIBNFCompToCreate = new MIBNF_Component__c[]{};
            for(Integer x=0; x<10;x++)
            {
                MIBNF_Component__c lineItem = new MIBNF_Component__c();
                lineItem.MIBNF__c=MIBNF.Id;
                lineItem.BNF_Status__c='New';
                lineItem.Is_this_a_retainer_downpayment__c='No';
                lineItem.Print_Shop__c='No';
                MIBNFCompToCreate.add(lineItem);
            }
            
            insert MIBNFCompToCreate;
            for(MIBNF_Component__c lst :[select name from MIBNF_Component__c where MIBNF__c=:MIBNF.Id])
               system.debug('*************Output*' + lst.name );
                test.stoptest();
    }
   
    static testMethod void RevisedNameFormat1() {
        // TO DO: implement unit test
        setupMIBNF();
        SetupMIBNF_Comp(MIBNF);
        test.starttest();
        MIBNF_Component__c[] MIBNFCompToCreate = new MIBNF_Component__c[]{};
            for(Integer x=0; x<10;x++)
            {
                MIBNF_Component__c lineItem = new MIBNF_Component__c();
                lineItem.MIBNF__c=MIBNF.Id;
                lineItem.BNF_Status__c='New';
                lineItem.Addendum__c=true;
                lineItem.Orignal_BNF__c=MIBNF_Comp.id;
                lineItem.Revised_BNF_Date__c=system.today();
                lineItem.Is_this_a_retainer_downpayment__c='No';
                lineItem.Print_Shop__c='No';
                MIBNFCompToCreate.add(lineItem);
            }
                
            insert MIBNFCompToCreate;
             for(MIBNF_Component__c lst :[select name from MIBNF_Component__c where MIBNF__c=:MIBNF.Id])
               system.debug('*************Output*' + lst.name );
                test.stoptest();
    }
    
     static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        setupMIBNF();
        SetupMIBNF_Comp(MIBNF);
        test.starttest();
        MIBNF_Component__c MIBNF_Comp1=new MIBNF_Component__c();
        MIBNF_Comp1.MIBNF__c=MIBNF.Id;
        MIBNF_Comp1.BNF_Status__c='New';
        MIBNF_Comp1.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp1.Print_Shop__c='No';
        MIBNF_Comp1.Orignal_BNF__c=MIBNF_Comp.id;
        MIBNF_Comp1.Revised_BNF_Date__c=system.today();
        MIBNF_Comp1.Addendum__c=true;
        
        insert MIBNF_Comp1;
        
        
        MIBNF_Component__c[] MIBNFCompToCreate = new MIBNF_Component__c[]{};
            for(Integer x=0; x<10;x++)
            {
                MIBNF_Component__c lineItem = new MIBNF_Component__c();
                lineItem.MIBNF__c=MIBNF.Id;
                lineItem.BNF_Status__c='New';
                lineItem.Addendum__c=true;
                lineItem.Orignal_BNF__c=MIBNF_Comp1.id;
                lineItem.Revised_BNF_Date__c=system.today();
                lineItem.Is_this_a_retainer_downpayment__c='No';
                lineItem.Print_Shop__c='No';
                MIBNFCompToCreate.add(lineItem);
            }
           insert MIBNFCompToCreate;
        test.stoptest();              
    }
    
     //Setup MIBNF
    static void SetupMIBNF()
    {
         // Create Opportunity
        ID RevenueAnalystID;
        for(Revenue_Analyst__c RA: [select id from Revenue_Analyst__c limit 1])
        {
            RevenueAnalystID=RA.id;
        }
        
        opp =new Opportunity(Name='Quick opp',StageName='1. Identifying Opportunity',Amount=2000,CloseDate=System.today(),
        Contract_Term__c='Single-Period',Contract_Type__c='Individual');
        opp.LeadSource = 'Account Planning';
        opp.Budget_Available__c = 'Yes';
        //opp.Unique_Business_Value__c = 'Unknown';
        //opp.Compelling_Event__c = 'No';
        insert opp;
        
        
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
        MIBNF.Revenue_Analyst__c=RevenueAnalystID;
        
        insert MIBNF;
    }
    
    //setting up component for MIBNF
    static void SetupMIBNF_Comp(MIBNF2__c RefMIBNF)
    {
        MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=RefMIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No';
        
        insert MIBNF_Comp;
    }
}