/**
 * This class contains unit tests for validating the behavior of MI_BNF_Check Trigger

 */
@isTest
private class TST_MI_BNF_Check {

    public static MIBNF2__c MIBNF;
    public static Opportunity[] oppToCreate;
    public static ID RevenueAnalystID;
    

    static testMethod void StopBNFCreateTest() {
        
        SetupoppMIBNF(false);
        
        BNF2__c[] BNFToCreate = new BNF2__c[]{};
        for(Integer x=0; x<10;x++)
        {
            BNF2__c TestBnf=new BNF2__c();
            TestBnf.Opportunity__c=oppToCreate[x].id;
            TestBnf.BNF_Status__c = MDM_Defines.BnfStatus_Map.get('NEW');
            TestBnf.Sales_Org_Code__c = 'ES51';
            TestBnf.IMS_Sales_Org__c = 'IMS Spain';
            TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
            TestBnf.Revenue_Analyst__c = RevenueAnalystID;
            BNFToCreate.add(TestBnf);
            
        }
        try
        {
             insert BNFToCreate;
        }
        catch (Exception E)
        {
             system.assert(e.getMessage().contains('A Multi Invoice BNF already exists for this opportunity. BNF cannot be created.'));
        }     
        
        
    }
    
    static testMethod void AllowBNFCreateTest() {
        
        SetupoppMIBNF(true);
        User TestUser = [select Id from User where Profile.Name like '%system administrator%' and IsActive = true limit 1];
        Revenue_Analyst__c TestRA = new Revenue_Analyst__c(name='TestRA',User__c = TestUser.Id);
        insert TestRa;
        
        BNF2__c[] BNFToCreate = new BNF2__c[]{};
        for(Integer x=0; x<10;x++)
        {
            BNF2__c TestBnf=new BNF2__c();
            TestBnf.Opportunity__c=oppToCreate[x].id;
            TestBnf.BNF_Status__c = MDM_Defines.BnfStatus_Map.get('NEW');
            TestBnf.Sales_Org_Code__c = 'ES51';
            TestBnf.IMS_Sales_Org__c = 'IMS Spain';
            TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
            TestBnf.Revenue_Analyst__c = TestRA.Id;
            BNFToCreate.add(TestBnf);
            
        }
        insert BNFToCreate;
        
    }
    
      //Setup MIBNF
    static void SetupoppMIBNF(Boolean Allow)
    {
             // Create Opportunity
            for(Revenue_Analyst__c RA: [select id from Revenue_Analyst__c limit 1])
            {
                RevenueAnalystID=RA.id;
            }
            oppToCreate = new Opportunity[]{};
            for(Integer x=0; x<10;x++)
            {
               Opportunity opp = new Opportunity();
               opp.Name='opp--' + x;
               opp.StageName='1. Identifying Opportunity';
               opp.Amount=2000;
               opp.CloseDate=System.today();
               opp.Contract_Term__c='Single-Period';
               opp.Contract_Type__c='Individual';
               opp.LeadSource = 'Account Planning';
               opp.Budget_Available__c = 'Yes';
               //opp.Unique_Business_Value__c = 'Unknown';
               //opp.Compelling_Event__c = 'No';
        
               oppToCreate.add(opp);
            }
            insert oppToCreate;
            
            if(!Allow)
            {
                //Creating Bulk MIBNF
                MIBNF2__c[] MIBNFToCreate = new MIBNF2__c[]{};
                for(Integer x=0; x<10;x++)
                {
                    MIBNF = new MIBNF2__c();
                    MIBNF.opportunity__c=oppToCreate[x].id;
                    MIBNF.Client__c=oppToCreate[x].AccountId;
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
                    
                    MIBNFToCreate.add(MIBNF);
                }
                  
                insert MIBNFToCreate;
                
                
                for(MIBNF2__c lst :[select name,Opportunity__r.name from MIBNF2__c where Opportunity__c in: oppToCreate])
                   system.debug('*************Output*' + lst.name + '*************'+ lst.opportunity__r.name );
                    
            }
            
      
 
    }
}