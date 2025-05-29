public with sharing class MI_BNF_ADD_Product {
        
        public List<MIBNF_Component__c> MIBNF_CompList{get;private set;}
        public String selectedInvoice{get;set;}
        private Id MIBNF_Id;
        
        //Constructor
        public MI_BNF_ADD_Product() 
        {    
             // Showing Child Invoices for MIBNF
             MIBNF_CompList=new List<MIBNF_Component__c>([Select Name, MIBNF__c, Id, Contract_Value__c, 
                                                         MIBNF__r.Contract_Start_Date__c, MIBNF__r.Contract_End_Date__c, 
                                                         Comments__c, Bill_To__c, BNF_Status__c, 
                                                         Ship_To__c, 
                                                         Ship_To_SAP_Base_Code__c,BNF_Description__c From MIBNF_Component__c where (BNF_Status__c='New' or BNF_Status__c='Rejected' or BNF_Status__c='LO Rejected' or BNF_Status__c='RA Rejected') and MIBNF__c=:ApexPages.currentPage().getParameters().get('minfid') order by createddate]);
            if (MIBNF_CompList.size() > 0)
            {
                this.MIBNF_Id = MIBNF_CompList[0].MIBNF__c;
            }
        }
        
        
        public PageReference save()
        {
             MI_BNF_LineItem__c MI_BNFLineItem;
             List<MI_BNF_LineItem__c> MI_BNF_LineItem_List= new List<MI_BNF_LineItem__c>();
             set<id> oliids=new set<id>();
            
             // Add OpportunityLineItemIds to get total price
             for(String s: ApexPages.currentPage().getParameters().get('prdids').Split(','))
             {
                  oliids.add(s);
             }
             Id MIBNF_Id;
             // Add product which is going to be added to Invoice from Url Parameters
             for(OpportunityLineItem oli : [select TotalPrice,CurrencyIsoCode from OpportunityLineItem where id in : oliids])
             {
                  MI_BNFLineItem=new MI_BNF_LineItem__c();
                  MI_BNFLineItem.MIBNF_Component__c=selectedInvoice;
                  MI_BNFLineItem.Opportunity_Line_Itemid__c=oli.Id;
                  MI_BNFLineItem.Total_Price__c=oli.TotalPrice;
                  MI_BNFLineItem.CurrencyIsoCode=oli.CurrencyIsoCode;
                  MI_BNF_LineItem_List.add(MI_BNFLineItem);                  
             }
                  
             //inserting LineItems
             upsert MI_BNF_LineItem_List;
             /*pageReference EditProductsPage = Page.MI_BNFOpptyList;
             EditProductsPage.getParameters().put('compid',selectedInvoice);
             EditProductsPage.getParameters().put('mibnf',this.MIBNF_Id);
             //?compid=a3aQ00000008fpJIAQ&oppid=006Q0000008sDcqIAE&mibnf=a3bQ00000008bwVIAQ&core.apexpages.devmode.url=1
             EditProductsPage.setRedirect(true);*/
             return null;
        
         }  
        
        
        public PageReference cancel()
        {    
             return null;
        }

}