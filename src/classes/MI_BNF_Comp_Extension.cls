/*
* Class is Used to show attached product for every child BNF in Multi Invoice BNF
* Create By : Himanshu Parashar
* Date: 15 sep 2011 
* Component : MIBNF_CompProductList
*/
public with sharing class MI_BNF_Comp_Extension {
    //  -------------------------------------------------------------------------------
    //  Member variables
    public List<OpportunityLineItem> OliList {get;private set;}
    public String MIBNF_CompId;
    public String MIBNF_Status {get;set;}
    public Boolean IsMIBNFSubmitted {get;private set;}
    public Boolean Revised_Status {get;set;}
    public String SelectedInvoice;
    public Boolean isDeleted {get;set;}
    public BOolean isRevised {get;private set;}
    public Boolean wbsCodeCheck {get; private set;}
    public MIBNF_Component__c MIBNF_Comp;
    public List<OpportunityLineItem> OLIItemList {get;set;}    
    public List<MI_BNF_LineItem__c> MIBNFLineItemList {get;set;}
    private Boolean isController;
    //Ghanshyam
    public List<OLIWrapper> oliWrapperLst;
    private Set<String> excludedProducts;
    public String MIBNF_SalesOrgCode {get;set;}
    public Boolean isMIBNFPrebillingSalesCode {get; set;}
    //  -------------------------------------------------------------------------------
    //  Constructor function
    //  -------------------------------------------------------------------------------   
    public MI_BNF_Comp_Extension() {   
        isDeleted = false;
        IsMIBNFSubmitted = true;
        isMIBNFPrebillingSalesCode = false;
        isRevised = false;
        isController = false;
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
    }
    
    public MI_BNF_Comp_Extension (ApexPages.StandardController controller) {
        isDeleted = false;
        Revised_Status = false;
        isMIBNFPrebillingSalesCode = false;
        IsMIBNFSubmitted = true;
        isRevised = false;
        MIBNF_Comp = (MIBNF_Component__c)controller.getRecord();
        MIBNF_CompId = MIBNF_Comp.id;
        MIBNF_Component__c  objMIBNF = [Select Id, Name, MIBNF__r.Sales_Org_code__c From MIBNF_Component__c where Id =: MIBNF_CompId limit 1];
        Set<String> prebillingSalesOrgSet = new Set<String>{'MX02', 'GT01', 'CO01', 'CO71'};
        if(prebillingSalesOrgSet.Contains(objMIBNF.MIBNF__r.Sales_Org_code__c)) {
            isMIBNFPrebillingSalesCode = true;
        } 
        isController = true;
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        loadData();
    }
    
    public void loadData(){
        // if BNF Submitted then remove the Drop Link from product
        // Updated by Ritesh Gupta - Issue-06365  ** Added (LO Rejected, RA Rejected, SAP Rejected)
        // if(MIBNF_Status=='New' || MIBNF_Status=='Rejected')
        if(MIBNF_Status == MDM_Defines.BnfStatus_Map.get('NEW') || 
           MIBNF_Status == MDM_Defines.BnfStatus_Map.get('REJECTED') || 
           MIBNF_Status == MDM_Defines.BnfStatus_Map.get('LO_REJECTED') || 
           MIBNF_Status == MDM_Defines.BnfStatus_Map.get('RA_REJECTED') || 
           MIBNF_Status == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED')) {
               IsMIBNFSubmitted = false;
           }
        if(Revised_Status == true) {
            isRevised = true;
        }
        
        OliList = new List<OpportunityLineItem>();
        
        Set<Id> LineItemID = new Set<Id>();
        if(MIBNFLineItemList != null) {
            for(MI_BNF_LineItem__c MIBNFLineItem : MIBNFLineItemList) {
                if(MIBNFLineItem.MIBNF_Component__c == MIBNF_CompId) {
                    LineItemID.add(MIBNFLineItem.Opportunity_Line_Itemid__c);
                }
            }
            
            for(OpportunityLineItem OLI : OLIItemList)  {
                if(Lineitemid.contains(OLI.id)) {
                    OliList.add(OLI);
                }
            }
            for(Integer i = 0 ; i < OliList.size() ; i++) {
                if(!String.isEmpty(OliList[i].WBS_R_Element__c)) {
                    wbsCodeCheck = true;
                }
            }
        }
        
        if(isController) {
            List<MI_BNF_LineItem__c> lstJo = new List<MI_BNF_LineItem__c>([Select Id, Opportunity_Line_Itemid__c, MIBNF_Component__c, CurrencyIsoCode From MI_BNF_LineItem__c where MIBNF_Component__c = :MIBNF_CompId]);
            // Get LineItem from MIBNF LineItem    
            Set<Id> JoOppLineItemidSet = new Set<Id>();
            for(MI_BNF_LineItem__c master : lstJo) {
                JoOppLineItemidSet.add(master.Opportunity_Line_Itemid__c);
            }
            
            // Show Product Details from OpportunityLineItem
            // Update by: Sneha Rathi Date: 21 Dec, 2012 -- Added Theraphy Area to query - ER: 0303
            OliList = new List<OpportunityLineItem>([Select Id, PricebookEntry.Name, Book_No__c, CurrencyIsoCode, TotalPrice, Delivery_Media__c,
                                                     PricebookEntry.ProductCode, Billing_Frequency__c,Proj_Rpt_Frequency__c, Discount_Percentage_Formula__c,
                                                     Product_Start_Date__c,Product_End_Date__c,Sales_Text__c, Product_Invoice_Text__c,Nbr_of_Users__c, 	Delivery_Country__c,
                                                     Discount_Reason__c,PO_line_item_number__c, Invoice_Date__c, Revised_Price__c,Cancel_Text__c, MIBNF_Cancel__c, Therapy_Area__c,
                                                     Surcharge_Text__c,Position_Number__c, Project_Start_Date__c, WBS_R_Element__c,
                                                     Project_End_Date__c, PricebookEntry.Product2.Material_Type__c,Other_Ship_To_Address__r.Name, Prebilling__c
                                                     From OpportunityLineItem where id IN :JoOppLineItemidSet  and Product_Material_Type__c NOT IN :excludedProducts
                                                     order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc]);	 		
            for(OpportunityLineItem oli : OliList) {
                //  Override data period start/end with project start/end for ZREP line items where projects exist
                if(oli.PricebookEntry.Product2.Material_Type__c == 'ZREP' && oli.Project_Start_Date__c != null && oli.Project_End_Date__c != null) {
                    //  Except if it's a revised BNF we need to use the data period start from the line item as these may have been adjusted for ZREP materials
                    if (MIBNF_Comp.Addendum__c == false){
                        oli.Product_Start_Date__c = oli.Project_Start_Date__c;
                    }
                    oli.Product_End_Date__c = oli.Project_End_Date__c;            
                }
            }
            for(Integer i = 0 ; i < OliList.size() ; i++) {
                if(!String.isEmpty(OliList[i].WBS_R_Element__c)) {
                    wbsCodeCheck = true;
                }
            }
        } 
        // Ghanshyam
        sortOLIList();
    }
    
    // Ghanshyam
    private void sortOLIList(){
        oliWrapperLst = new List<OLIWrapper>();
        for(OpportunityLineItem oli : OliList){
            oliWrapperLst.add(new OLIWrapper(oli));
        }
        oliWrapperLst.sort();
        OliList.clear();
        for(OLIWrapper objWrapper : oliWrapperLst){
            OliList.add(objWrapper.oli);
        }
    }
    
    // Ghanshyam
    public Class OLIWrapper implements Comparable{
        public OpportunityLineItem oli {get; set;}
        public OLIWrapper(OpportunityLineItem oli){
            this.oli = oli;
        }
        
        public Integer compareTo(Object objToCompare) { 			
            if ((oli.PricebookEntry.ProductCode + oli.Product_Start_Date__c) > (((OLIWrapper)objToCompare).oli.PricebookEntry.ProductCode + ((OLIWrapper)objToCompare).oli.Product_Start_Date__c)) { 			
                return 1; 
            } 
            if ((oli.PricebookEntry.ProductCode + oli.Product_Start_Date__c) < (((OLIWrapper)objToCompare).oli.PricebookEntry.ProductCode + ((OLIWrapper)objToCompare).oli.Product_Start_Date__c)) { 
                return -1; 
            } 
            return 0;
        }	
        
    }
    
    public PageReference deleteproduct() {
        List<MI_BNF_LineItem__c> lstDeletedItem = new List<MI_BNF_LineItem__c>([select id,MIBNF_Component__c from MI_BNF_LineItem__c where Opportunity_Line_Itemid__c = :SelectedInvoice and MIBNF_Component__c = :MIBNF_CompId limit 1]);
        isDeleted = false;
        try {
            if(lstDeletedItem.size() > 0) {
                delete lstDeletedItem;  
                loadData();
                isDeleted = true;
            } 
        } 
        catch (Exception ex) {
            //show a message on page
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Error while deleting Product');
            ApexPages.addMessage(errMsg);  
        }
        return null;
    }   
    
    //setter for SelectedInvoice 
    public void setSelectedInvoice(String s) {
        SelectedInvoice = s;
    }
    
    //getter for SelectedInvoice 
    public string getSelectedInvoice() {
        return SelectedInvoice ;
    }
    
    //setter for MIBNF_CompId
    public void setMIBNF_CompId(String s) {
        MIBNF_CompId = s;
        loadData();
    }
    
    //getter for MIBNF_CompId
    public string getMIBNF_CompId() {
        return this.MIBNF_CompId;
    }
    
    public Boolean getRenderPrebilling() {
        Set<String> prebillingSalesOrgSet = new Set<String>{'MX02', 'GT01', 'CO01', 'CO71'};
        if(prebillingSalesOrgSet.Contains(MIBNF_SalesOrgCode)) {
            return true;
        } 
        return false ;
    }
}