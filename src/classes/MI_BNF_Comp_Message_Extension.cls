public class MI_BNF_Comp_Message_Extension {

     //  -------------------------------------------------------------------------------
    //  Member variables
        public string MIBNF_CompId{get;set;}
        public User CurrentUser;
        public MIBNF_Component__c MIBNF_Comp;
        public List<String> errorlst{get;set;}
        public List<OpportunityLineItem> OLIItemList{get;set;}    
        public List<MI_BNF_LineItem__c> MIBNFLineItemList{get;set;}
        public Map<id,MIBNF_Component__c> MIBNFCompMap{get;set;}
     
        public String ProcessInstanceWorkitemMap{get;set;}
        public AddressWrapper objAddressWrapper{get;set;}
        private static Boolean hasAccessBNFAll;
        static {
            hasAccessBNFAll = false;
            List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
            if(permSetAssList.size() > 0) {
                hasAccessBNFAll = true; 
            }
        }
        
        
        //public MIBNF_Component__c MIBNF_Comppass{get;set;}
        //  -------------------------------------------------------------------------------
        //  Constructor function
        //  -------------------------------------------------------------------------------   
        public MI_BNF_Comp_Message_Extension () 
        {
          
        }
    
    //setter for current user
     public void setCurrentUser(User s)
    {
      
        CurrentUser= s;
        
        ShowInfoMessages();
    }
    //getter for current user
    public User getCurrentUser()
    {
      return this.CurrentUser;
    }
    
     //setter for MIBNF_Comp
     public void setMIBNF_Comp(MIBNF_Component__c s)
    {
        this.MIBNF_Comp = s;
        
    }
    //getter for MIBNF_Comp
    public MIBNF_Component__c getMIBNF_Comp()
    {
     
      return this.MIBNF_Comp;
    }
    
  
    
    
    //Added Date : 13 Feb 2013
    public void ShowInfoMessages()
    {

             errorlst=new List<String>();
            //Added by Himanshu parashar : 12 dec 2012 : When BNF Status is Accepted, Info Message only display to assigned user
            BNF_Settings__c bnfSetting =BNF_Settings__c.getInstance();
         
            //ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.MIBNF_Comp.Id];        
            if(ProcessInstanceWorkitemMap==null)
            	ProcessInstanceWorkitemMap='';
            List<String> P_array= ProcessInstanceWorkitemMap.split(':');
        
            List<Address__c> Address_List = new List<Address__c>();

                //Updated by Himanshu Parashar Date : 7 Feb 2013 : BNF_Settings__c Check
            if(bnfSetting.Enable_Customer_Validation__c==true && objAddressWrapper!=null && objAddressWrapper.map_Filled_Addresses!=null)
            {
                for (String AddressType:objAddressWrapper.map_Filled_Addresses.keySet())
                {
                    Address__c A=objAddressWrapper.map_Filled_Addresses.get(AddressType);
                    Set<String> setAddressSalesOrgs = new Set<String>();
                    if(A.Enabled_Sales_Orgs__c!=null)
                    {
                        List<String> AddressSalesOrgs= A.Enabled_Sales_Orgs__c.split(':'); 
                        setAddressSalesOrgs.addAll(AddressSalesOrgs);
                    }
                    if (A.Enabled_Sales_Orgs__c==null || (setAddressSalesOrgs.size()>0 && setAddressSalesOrgs.contains(this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c) == false))
                    {
                        errorlst.add(AddressType + ': ' + A.Name + ' (SAP Code: '+ A.SAP_Reference__c + ') is not enabled for ' + this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c);
                    }
                }
            }
          
   
        if(bnfSetting.Enable_Material_Validation__c==true)
            {
             //Get LineItem from MIBNF LineItem    
             set<Id> JoOppLineItemidSet = new set<Id>();
            //  system.debug('******************coming inside****1.0*******');
             
             //Get all the lineitem belongs to current MIBNF Component
             for (MI_BNF_LineItem__c master :MIBNFLineItemList)
             {
                if(master.MIBNF_Component__c==this.MIBNF_Comp.id)
                {
                    JoOppLineItemidSet.add(master.Opportunity_Line_Itemid__c); 
                }
              
             }
             
                //Added by Himanshu Parashar : 11 dec 2012 : BNF_Status__c Accepted
                for (OpportunityLineItem OLI :OLIItemList)
                {
                   
                    if(JoOppLineItemidSet.contains(OLI.id))
                    {
                        Set<String> setProductSalesOrgs = new Set<String>();
                        if(OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c!=null)
                        {
                            List<String> ProductSalesOrgs= OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c.split(':'); 
                            setProductSalesOrgs.addAll(ProductSalesOrgs);
                       
                        }
                        //Updated by Himanshu Parashar Date : 7 Feb 2013 : BNF_Settings__c Check
                         if(OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c==null || (setProductSalesOrgs.size()>0 && OLI.PricebookEntry.Product2.Material_Type__c == 'ZPUB' && (!setProductSalesOrgs.contains(this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c))))
                         {
                            errorlst.add('Product '+OLI.PricebookEntry.Product2.ProductCode+' is not enabled for sales org '+ this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c+ '. Please contact your local Finance representative to resolve this before submitting the BNF.');
                          }
                            
                    }
                    
                    
                     
                }
            }
      MIBNF_Comp=null;  
    }
    
    
 
}