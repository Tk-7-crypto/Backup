public class Master_BNF_Extension {

    //  -------------------------------------------------------------------------------
    //  Member variables
    //  -------------------------------------------------------------------------------
    //  Master_BNF__c record displayed on VF page
    private Master_BNF__c MasterBnf;
    //  Standard controller for Master_BNF__c object 
    private ApexPages.StandardController StandardController;
    //  List of all Master_BNF_Component__c records which link to the Master_BNF__c record 
    private List<Master_BNF_Component__c> BNF_Component_Array;
    //  Map of OpportunityLineItem Id's used to retrieve all line items included in Master_BNF__c
    private Map<Id,Id> OLI_Id_Map;
    //  Array of all OpportunityLineItem records included in Master_BNF__c
    private List<OpportunityLineItem> OLI_Array;
    private Map<Id,Id> Opportunity_Id_Map;
    private Map<Id,Opportunity> Opportunity_Map;
    private List<OpportunityContainer> OpportunityContainer_Array;
 //   private Id AccountId;
   // private List<OpportunityContainer> AddOppsOpportunityContainer_Array;
    private Boolean EditOppsRendered;
    private Boolean OppListRendered;
    private Boolean EditHeaderRendered;
    private Boolean AddMoreOppsRendered;
    private Boolean NewBnfWizardStep1Rendered;
    private Boolean NewBnfWizardStep2Rendered;
    private Boolean NewBnfWizardStep3Rendered;
    private Boolean NewBnfWizardStep4Rendered;
    private Boolean NewBnfWizardStep2BRendered;
    
   /*public OpportunityContactRole BillToContactRole {get;set;}
    private OpportunityContactRole SoldToContactRole {get;set;}*/
    //  Member variables used in the New Master BNF Wizard
    //  List of proxy OpportunityContactRole records to allow lookup to opportunity
    //private List<OpportunityContactRole> OCR_Array;
    public Opportunity DummyOpp {get;set;}
    public OpportunityContactRole ProxyOcr {get;set;}
    public List<OpportunityContactRole> OCR_Array {get;set;}
    public List<OpportunityContainer> AccountOpportunity_Array;
    public String BnfType {get;set;}
    private static String BnfTypeContract = 'Single Contract';
    private static String BnfTypeInvoice = 'Combined Invoice';  
    public Boolean InitiatingError {get;set;}
    private BNF2__c InitiatingBnf;
    //BEGIN DEBUG
    public String Debug {get;set;}
    public Boolean DebugPanelRendered {get;set;}
    //END DEBUG

    private ApexPages.StandardSetController setCon;
    private ApexPages.StandardSetController OpportunitySetController;
    
    public ApexPages.StandardSetController getsetCon() 
    {       
        if (this.OpportunityContainer_Array.size() == 0)
        {
            return null;
        } 
        if(setCon == null) 
        {
            /*Map<Id,Id> AccountId_Map = new Map<Id,Id>();
            for (Opportunity O:this.Opportunity_Map.values())
            {
                AccountId_Map.put(O.AccountId,O.AccountId);
            } */
            this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, AccountId,Account.Name,MailingStreet,MailingCountry from Contact where AccountId = :this.OpportunityContainer_Array[0].Opportunity.AccountId order by Account.Name, Name]));
            //setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account.Name,MailingStreet,MailingCountry from Contact where Name like '%Sam%' order by Account.Name, Name]));
            this.setCon.setPageSize(10);
        }
        return setCon;
    }
    
    public String getChooseRender() 
    {
        if (ApexPages.currentPage().getParameters().get('pdf') != null)
        {
            return 'pdf';
        }
        else
        {
            return null;
        }
    }
    
    public Boolean getRenderForPdf()
    {
        if (ApexPages.currentPage().getParameters().get('pdf') != null)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    public BNF2__c getInitiatingBnf()
    {
        return this.InitiatingBnf;
    }
    
    public String getChooseContentType()
    {
        if (ApexPages.currentPage().getParameters().get('pdf') != null)
        {
            return 'application/pdf';//' + this.MasterBNF.Name + '.pdf';
        }
        else
        {
            return null;
        }
    }

    public pageReference GeneratePdf()
    {
        pageReference pdf = new pageReference('/apex/MasterBNFView2?id='+this.MasterBnf.Id+'&pdf=1');//Page.masterbnfview2;
        //pdf.getParameters().put('pdf','1');
        //pdf.getParameters().put('id',this.MasterBNF.Id);
        //pdf.setRedirect(true);
        return pdf;
    }
    
    public List<Contact> getBillingContacts() 
    {
        if (this.getsetCon() == null)
        {
            return null;
        }
        return (List<Contact>) this.getsetCon().getRecords();
        //return [select Id, Name, Account.Name,MailingStreet,MailingCountry from Contact limit 20];
    }
    
    /*public ApexPages.StandardSetController getOpportunitySetController() 
    {       
        //this.Debug += 'calling getOpportunitySetController() ';
        if (this.OpportunityContainer_Array.size() == 0)
        {
        //  this.Debug += ' getOpportunitySetController() returning null ';
            return null;
        } 
        if(this.OpportunitySetController == null) 
        {
            this.OpportunitySetController = new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, StageName, Amount, Opportunity_Number__c,CloseDate from Opportunity where StageName in ('7a. Closed Won','In-Hand') and AccountId = :this.MasterBNF.Client__c order by CreatedDate desc]));
            //setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account.Name,MailingStreet,MailingCountry from Contact where Name like '%Sam%' order by Account.Name, Name]));
            this.OpportunitySetController.setPageSize(10);          
        }
        return this.OpportunitySetController;
    }*/
    
    public List<OpportunityContainer> getAccountOpportunities() 
    {
        List<OpportunityLineItem> OLI_Dummy = new List<OpportunityLineItem>();
        this.AccountOpportunity_Array.clear();
        for (Opportunity O:[select Id, Name, StageName, Amount, Opportunity_Number__c,CloseDate,Actual_Close_Date__c from Opportunity where StageName like '7a. Closed Won' and AccountId = :this.MasterBNF.Client__c order by CreatedDate desc])      
        {           
            OpportunityContainer OC = new OpportunityContainer(O,OLI_Dummy);
            if (ApexPages.currentPage().getParameters().get('OpportunityId') == O.Id)
            {
                OC.selected = true; 
                this.Debug += ' Param Selected Opp: '+O.Id;
            }
            this.AccountOpportunity_Array.Add(OC);
        } 
        for (OpportunityContainer OC:this.OpportunityContainer_Array)
        {
            for (OpportunityContainer OC2:this.AccountOpportunity_Array)
            {
                if (OC2.Selected == true)
                {
                    OC.Selected = true;
                    this.Debug += ' Previously Selected Opp: '+OC.Opportunity.Id;
                }
            }
        }
        return this.AccountOpportunity_Array;
    }
    
    /*public List<Opportunity> getAccountOpportunities() 
    {
        if (this.getOpportunitySetController() == null)
        {
            return null;
        }
        return (List<Opportunity>) this.getOpportunitySetController().getRecords();
    }*/
    
    //  BEGIN DEBUG
    private Integer Test;
    //  END DEBUG
    /*
    public void setOpportunityContactRole(OpportunityContactRole OCR)
    {
        this.BillToContact = OCR;
    }
    
    public OpportunityContactRole getOpportunityContactRole()
    {
        return this.BillToContact;
    }
     */  
    //  -------------------------------------------------------------------------------
    //  Constructor function
    //  -------------------------------------------------------------------------------   
    public Master_BNF_Extension (ApexPages.StandardController controller) 
    {       
        this.InitiatingBnf = new BNF2__c();
        this.InitiatingError = false;
        this.DebugPanelRendered = false;
        if ((String)ApexPages.currentPage().getParameters().get('bnftype') == 'invoice')
        {
            this.BnfType = BnfTypeInvoice;
            this.InitiatingBnf = [select Id, Bnf_Status__c, Opportunity__c, Name,Zip_Postal_Code__c, X2nd_Zip_Postal_Code__c, 
                                    X2nd_State_Province__c, X2nd_Email__c, X2nd_Country__c, X2nd_Copy_Contact__c, 
                                    X2nd_Copy_Company__c, X2nd_City__c, X2nd_Address__c, Ship_To_Contact_Local__c, 
                                    Ship_To_Company__c, Ship_To_Company_Local__c, Cover_Sheet_Zip_Postal_Code__c, 
                                    Cover_Sheet_State_Province__c, Cover_Sheet_Country__c, Cover_Sheet_Contact__c, 
                                    Cover_Sheet_Company__c, Cover_Sheet_City__c, Cover_Sheet_Address__c, Country__c, 
                                    Contact__c, Client__c, Carbon_Copy_Zip_Postal_Code__c, Carbon_Copy_State_Province__c, 
                                    Carbon_Copy_Country__c, Carbon_Copy_Contact__c, Carbon_Copy_Company__c, Carbon_Copy_City__c, 
                                    Carbon_Copy_Address__c, Bill_To_Zip_Postal_Code__c, Bill_To_State_Province__c, 
                                    Bill_To_Country__c, Bill_To_Contact_Local__c, Bill_To_Company__c, Bill_To_Company__r.NameLocal, Bill_To_Company_Local__c, 
                                    Bill_To_City__c, Bill_To_Address__c,Address__c,City__c,State_Province__c from BNF2__c where Id = :(String)ApexPages.currentPage().getParameters().get('BnfId') limit 1];         
        }
        //  Default to "Combined Contract" record type
        else
        {
            this.BnfType = BnfTypeContract;
        }
        this.StandardController = controller;
        this.OpportunityContainer_Array = new List<OpportunityContainer>();
        this.AccountOpportunity_Array = new List<OpportunityContainer>();
        //this.AddOppsOpportunityContainer_Array = new List<OpportunityContainer>();
        this.Opportunity_Id_Map = new Map<Id,Id>();
        this.Opportunity_Map = new Map<Id,Opportunity>();
        this.OLI_Id_Map = new Map<Id,Id>();
        if ((String)ApexPages.currentPage().getParameters().get('action') == 'edit')
        {
            //this.EditOppsRendered = true;
            this.ShowEditOpps();
        }
        else
        {   
            //this.EditOppsRendered = false;
            this.HideEditOpps();
        }
        this.OppListRendered = !this.EditOppsRendered;
        this.AddMoreOppsRendered = false;
        this.MasterBNF = (Master_BNF__c)controller.getRecord();
        this.Test = 1;  
        this.OCR_Array = new List<OpportunityContactRole>();    
        this.ProxyOcr = new OpportunityContactRole();
        this.NewBnfWizardStep1Rendered = true;
        this.NewBnfWizardStep2Rendered = false;
        this.NewBnfWizardStep2BRendered = false;
        this.NewBnfWizardStep3Rendered = false;
        this.NewBnfWizardStep4Rendered = false;
        this.EditOppsRendered = false;
        this.AddMoreOppsRendered = false;
        this.OppListRendered = true;
        if (this.MasterBNF.Id == null && InitiatingBnf.Id == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No BNF found from which ' + BnfTypeInvoice + ' Master BNF can be initiated');
            ApexPages.addMessage(myMsg);
            this.InitiatingError = true;    
            this.NewBnfWizardStep1Rendered = false;     
        }
        /*else if (this.MasterBNF.Id == null && InitiatingBnf.BNF_Status__c != 'Accepted')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'BNF ' + InitiatingBnf.Name + ' has status of "' + InitiatingBnf.BNF_Status__c +'".  BNF must have status of "Accepted" to be included in ' + BnfTypeInvoice + ' Master BNF.');
            ApexPages.addMessage(myMsg);
            this.InitiatingError = true;
            this.NewBnfWizardStep1Rendered = false;         
        }*/
        else if ((String)ApexPages.currentPage().getParameters().get('OpportunityId') != null)
        {
            this.ProxyOcr.OpportunityId = (String)ApexPages.currentPage().getParameters().get('OpportunityId');
            this.AddOpportunityRow();
            //this.getOpportunitySetController();
        }
    }
    
    public Integer getTest()
    {
        return this.Test;
    }
    
    public Boolean getEditOppsRendered()
    {
        return this.EditOppsRendered;
    }
    
    public Boolean getEditHeaderRendered()
    {
        return this.EditHeaderRendered;
    }
    
    public Boolean getAddMoreOppsRendered()
    {
        return this.AddMoreOppsRendered; 
    }
    
    public Boolean getOppListRendered()
    {
        return this.OppListRendered;
    }
    
    public Boolean getNewBnfWizardStep1Rendered()
    {
        return this.NewBnfWizardStep1Rendered;
    }
        
    public Boolean getNewBnfWizardStep2Rendered()
    {
        return this.NewBnfWizardStep2Rendered;
    }
    
    public Boolean getNewBnfWizardStep2BRendered()
    {
        return this.NewBnfWizardStep2BRendered;
    }
        
    public Boolean getNewBnfWizardStep3Rendered()
    {
        return this.NewBnfWizardStep3Rendered;
    }       
    
    public Boolean getNewBnfWizardStep4Rendered()
    {
        return this.NewBnfWizardStep4Rendered;
    }
    //  -------------------------------------------------------------------------------
    //  Init_View() function to retreive all related records for displaying Master BNF
    //  -------------------------------------------------------------------------------     
    public void Init_View()
    {
        this.Debug += ' Init_View() ';
        //  For existing Master BNF
        if (this.MasterBNF.Id != null)
        {
            //  Get all Master_BNF_Component__c records which link to this Master_BNF__c
            this.BNF_Component_Array = new List<Master_BNF_Component__c>([select Id,OpportunityLineItemId__c from Master_BNF_Component__c where Master_BNF__c = :this.MasterBNF.Id]); 
            //  Create a map of all line item id's in the BNF_Component_Array 
            for (Master_BNF_Component__c MBNF:this.BNF_Component_Array)
            {
                this.OLI_Id_Map.put(MBNF.OpportunityLineItemId__c,MBNF.OpportunityLineItemId__c);
            }       
            for (OpportunityLineItem OLI:[select Id,OpportunityId from OpportunityLineItem where Id in :this.OLI_Id_Map.keySet()])
            {
                this.Opportunity_Id_Map.put(OLI.OpportunityId,null);
                this.Debug += ' Adding to Opp Map: ' + OLI.OpportunityId;
            }           
            if (this.MasterBnf.RecordType.Name == BnfTypeInvoice)
            {
                this.BnfType = BnfTypeInvoice;
            }
            //  Default to "Combined Contract" record type
            else
            {
                this.BnfType = BnfTypeContract;
            }   
            //  BEGIN DEBUG
            //this.BnfType =        this.MasterBnf.RecordType.Name;     
            //  END DEBUG                   
        }
        //  For BNF being created through Wizard
        else
        {   
            this.BNF_Component_Array = new List<Master_BNF_Component__c>();
            this.Debug += ' OpportunityContainer_Array.size(): '+ OpportunityContainer_Array.size();
            for (OpportunityContainer OC:this.OpportunityContainer_Array)
            {
                for (OpportunityLineItem OLI:OC.getOLI_Array())
                {
                    Master_BNF_Component__c BNF_Component = new Master_BNF_Component__c(Master_BNF__c=MasterBNF.Id);
                    BNF_Component.OpportunityLineItemId__c = OLI.Id;
                    this.BNF_Component_Array.add(BNF_Component);
                    this.Debug += ' Adding BNF component for oli: ' + OLI.Id;
                }
                this.Opportunity_Id_Map.put(OC.Opportunity.Id,null);
                this.Debug += ' Adding to Opp Map: ' + OC.Opportunity.Id;
            }
            //  Create a map of all line item id's in the BNF_Component_Array 
            for (OpportunityLineItem OLI:[select Id,OpportunityId from OpportunityLineItem where OpportunityId in :this.Opportunity_Id_Map.keySet()])
            {
                this.OLI_Id_Map.put(OLI.Id,OLI.Id);
                this.Debug += ' Adding to OLI ID Map: ' + OLI.OpportunityId;
            }
        }
        this.Debug += ' this.BNF_Component_Array.size(): ' + this.BNF_Component_Array.size();   
        //  Retrieve all line items included in the Master_BNF__c
        //Update by: Sneha Date: 21 Dec, 2012 -- Therapy_Area__c added to query - ER - 0303
        this.OLI_Array = new List<OpportunityLineItem>([select Id, Delivery_Country__c,Delivery_Media__c,Product_Start_Date__c,Product_End_Date__c,PricebookEntry.Product2.Name,
                                                        PricebookEntry.Product2.ProductCode,TotalPrice,
                                                        OpportunityId,Opportunity.Opportunity_Number__c,Cancel__c,
                                                        Product_Invoice_Text__c,Proj_Rpt_Frequency__c, Revenue_Type__c, 
                                                        Sale_Type__c, Billing_Date__c, Invoice_Lag_to_Data_Period__c, Revised_Price__c, Therapy_Area__c,
                                                        Nbr_of_Users__c,Discount_Reason__c,Discount_Percentage_Formula__c, 
                                                        Discount_Amount_Formula__c,ListPrice,Billing_Frequency__c
                                                        from OpportunityLineItem where OpportunityId in :this.Opportunity_Id_Map.keySet() 
                                                        order by OpportunityId desc, Id desc]);
        this.Debug += ' this.OLI_Array.size(): ' + this.OLI_Array.size();       
        for (Opportunity O:[select Id, Name,Opportunity_Number__c,Account.Name,Account.Id, Account.SAP_Reference__c, Amount, Contract_Start_Date__c, 
                            Contract_End_Date__c, StageName,Therapy_Area__c,CurrencyIsoCode,Contract_Type__c,Contract_Term__c,
                            Delivery_Date__c,SAP_Contract__c,SAP_Master_Contract__c from Opportunity where Id in :this.Opportunity_Id_Map.keySet()])
        {
            this.Opportunity_Map.put(O.Id,O); 
        }
        this.OpportunityContainer_Array.clear();
        for (Opportunity O:Opportunity_Map.Values())
        {
            OpportunityContainer TempOppContainer = new OpportunityContainer(O,this.OLI_Array);
            this.OpportunityContainer_Array.add(TempOppContainer);  
            this.Debug += ' Adding to OC container: ' + O.Id;
        }       
        this.OCR_Array = [select Id, ContactId, OpportunityId, Role, Opportunity.Account.Name from OpportunityContactRole where OpportunityId in :this.Opportunity_Map.keySet() order by OpportunityId];
        if (this.MasterBNF.Client__c == null)
        {
            this.MasterBNF.Client__c = this.OpportunityContainer_Array[0].Opportunity.AccountId;
        }
    }
    
    //  -------------------------------------------------------------------------------
    //  getOLI_Array() function to return all line items included in Master_BNF__c
    //  -------------------------------------------------------------------------------   
    //public List<OpportunityLineItem> getOLI_Array()
    //{
    //  return this.OLI_Array;
    //}
   /* 
    //  -------------------------------------------------------------------------------
    //  getMasterBNF() function to return Master_BNF__c record being displayed
    //  -------------------------------------------------------------------------------
    public Master_BNF__c getMasterBNF()
    {
        return this.MasterBNF;
    }*/
    
    public List<OpportunityContainer> getOpportunityContainer_Array()
    {
        return this.OpportunityContainer_Array;
    }
    
   /* public List<OpportunityContainer> getAddOppsOpportunityContainer_Array()
    {
        return this.AddOppsOpportunityContainer_Array;
    }*/
    
    public pageReference SaveHeader()
    {
        if (this.MasterBnf.IMS_Sales_Org__c == null)
        {
            //DisplayMessage('Please choose a valid Sales Org','ERROR');
            this.MasterBnf.IMS_Sales_Org__c.addError('Please choose a valid IMS Sales/Billing Org');
            return null;
        }
        if (this.MasterBnf.Sales_Org_Code__c == null)
        {
            //DisplayMessage('Please choose a valid Sales Org','ERROR');
            this.MasterBnf.IMS_Sales_Org__c.addError('Please choose a valid IMS Billing Org Code');
            return null;
        }
        this.NewBnfWizardStep3Rendered = false;
        if (this.MasterBNF.Revenue_Analyst__c != null)
        {
            Revenue_Analyst__c RA = [select Id, User__c from Revenue_Analyst__c where Id = :this.MasterBNF.Revenue_Analyst__c limit 1];
            this.MasterBNF.Revenue_Analyst_User__c = RA.User__c;
        }
        //  If BNF has not yet been saved (step 3 of wizard), then insert a new record
        //  for the header and for MBNF components
        if (this.MasterBNF.Id == null)
        {
            this.CreateMasterBnf();
            pageReference viewBnf = Page.MasterBNFView2;
            viewBnf.getParameters().put('id',(String)this.MasterBNF.Id);
            viewBnf.setRedirect(true);
            return viewBnf;     
        }
        //  Else do a standard save
        else
        {
            this.StandardController.save();
        }
        
        
        //update Test;      
        //update this.MasterBNF;
        //this.Init_View();
        //  BEGIN DEBUG
        //this.MasterBNF.Debug__c = 'Override!';        
        this.Test++;
        //  END DEBUG
        //return null;
        this.HideEditHeader();
        this.AddMoreOppsRendered = false;
        return null;
    }
     
   /* public void Save()
    {}*/ 
    
    public void SaveOppList()
    {
        //  BEGIN DEBUG
        this.Test++;        
        //ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.INFO,'Saving..');
        //ApexPages.addMessage(myMsg2);
        //  END DEBUG
        if (this.OpportunityContainer_Array.size() < 2)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Master BNF must include a minimum of 2 opportunities. Please add opportunities and then click Save button.');
            ApexPages.addMessage(myMsg);
            return;
        }
        //this.EditOppsRendered = !this.EditOppsRendered;
        try
        {
            List<Master_BNF_Component__c> DeleteBnfComponent_Array = new List<Master_BNF_Component__c>();
            Set<Id> UpdateOpp_Id_Set = new Set<Id>();
            Map<String,String> LineItemId_Map = new Map<String,String>();
            for (OpportunityLineItem OLI:this.OLI_Array)
            {
                Boolean LineItemRemoved = true;
                for (OpportunityContainer OC:this.OpportunityContainer_Array)
                {
                    if (OC.Opportunity.Id == OLI.OpportunityId)
                    {
                        LineItemRemoved = false;
                    }
                }
                if (LineItemRemoved == true)
                {
                    LineItemId_Map.put(OLI.Id,OLI.Id);
                    UpdateOpp_Id_Set.add(OLI.OpportunityId);
                    //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'DelOpp: '+OLI.OpportunityId+'Del OLI: '+OLI.Id);
                    //ApexPages.addMessage(myMsg);
                }
            }           
            for (Master_BNF_Component__c C:this.BNF_Component_Array)
            {
                //ApexPages.Message myMsg6 = new ApexPages.Message(ApexPages.Severity.INFO,'C.OpportunityLineItemId__c: '+C.OpportunityLineItemId__c);
                //ApexPages.addMessage(myMsg6);
                if (LineItemId_Map.containsKey(C.OpportunityLineItemId__c) == true)
                {
                    DeleteBnfComponent_Array.add(C);                    
                    //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Added DelOLI: '+C.OpportunityLineItemId__c);
                    //ApexPages.addMessage(myMsg);
                }
            }
            delete DeleteBnfComponent_Array;
            update this.OLI_Array;
            List<BNF2__c> UpdateBNF_Array = new List<BNF2__c>([select Id from BNF2__c where Opportunity__c in :UpdateOpp_Id_Set]);
            for (BNF2__c BNF:UpdateBNF_Array)
            {
                BNF.Master_BNF__c = null;
            }
            update UpdateBNF_Array;
            this.ShowOppList();
            this.HideEditOpps();
            //this.Init_View();
            //return;
        }
        catch (Exception E)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,E.getMessage());
            ApexPages.addMessage(myMsg);
        }       
    }
    
    public void DisplayMessage(String Msg,String Severity)
    {
        ApexPages.Message myMsg;
        if (Severity == 'INFO')     
        {
            myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Msg);
        }
        else if (Severity == 'ERROR')
        {
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Msg);
        }   
        else
        {
            myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,Msg);
        }
        ApexPages.addMessage(myMsg);
    }
        
    
    public Id ContactId {get; set;}
    
    public void DoNothing()
    {
        this.Debug += ' Doing nothing ';
    }
    
    public void ShowEditOpps()
    {
        this.EditOppsRendered = true;
        this.OppListRendered = false;
        this.AddMoreOppsRendered = false;
    }
    
    public void HideEditOpps()
    {
        this.EditOppsRendered = false;
        this.OppListRendered = true;
    }
    
    public void CancelEditOpps()
    {
        this.HideEditOpps();
        //  Reset to include all line items (i.e. undo changes if user has removed some opps)
        this.Init_View();
    }
    
    public void ShowEditHeader()
    {
        //  BEGIN DEBUG
        this.Test++;        
        //  END DEBUG
        this.EditHeaderRendered = true;
        this.AddMoreOppsRendered = false;
    }
    
    public void HideEditHeader()
    {
        //  BEGIN DEBUG
        this.Test++;        
        //  END DEBUG
        this.EditHeaderRendered = false;
    }
    
    public void HideOppList()
    {
        this.OppListRendered = false;
    }
    
    public void ShowOppList()
    {
        this.OppListRendered = true;
    }
    
    public void ToggleEditOpps()
    {
        //  BEGIN DEBUG
        this.Test++;        
        //  END DEBUG
        this.EditOppsRendered = !this.EditOppsRendered;
    }
    
    public String getContactLookupQueryModifier()
    {
        Map <Id,Opportunity> OppMap = new Map<Id,Opportunity>();
        for (OpportunityContainer OC:OpportunityContainer_Array)
        {
            OppMap.put(OC.Opportunity.Id,OC.Opportunity);
        }
        string queryModifier = 'and AccountId in (';
        Integer i = 0;
        for (Opportunity O:OppMap.values())
        {
            queryModifier += '\'' + O.AccountId + '\'';
            if (i++ < OppMap.size()-1)
            {
                queryModifier += ',';
            }
        }
        queryModifier += ')';
        return queryModifier;
    }
    
   /* public List<OpportunityContactRole> getOCR_Array()
    {
        return this.OCR_Array;
    }*/
        
    public void ValidateOpportunityRow()
    {       
        Opportunity O = [select Id, Name,Account.Name, AccountId,Account.SAP_Reference__c,CloseDate, Amount, Opportunity_Number__c,CurrencyIsoCode,StageName,Actual_Close_Date__c,Contract_Start_Date__c,Contract_End_Date__c from Opportunity where Id = :this.ProxyOcr.OpportunityId];
        //  Validation checks for Combined Contract Master BNF
        if (O.StageName != '7a. Closed Won' && this.BnfType == BnfTypeContract)
        {
            /*ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Opportunity '+ O.Opportunity_Number__c + ' cannot be included in this Master BNF because it is at stage "' + O.StageName + '". Opportunities must be at stage "7a. Closed Won" or "In-Hand" before they can be included in a Master BNF.');
            ApexPages.addMessage(myMsg);
            return false;*/
            //GeneralException E = new GeneralException();
            //E.setMessage('Opportunity '+ O.Opportunity_Number__c + ' cannot be included in this Master BNF because it is at stage "' + O.StageName + '". Opportunities must be at stage "7a. Closed Won" to be included in a ' + this.BnfType + ' Master BNF.');
            //throw E;
        }
        //  Validation checks for Combined Invoice Master BNF
        if (O.StageName != '7a. Closed Won' && O.StageName != 'In-Hand' && this.BnfType == BnfTypeInvoice)
        {
            /*ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Opportunity '+ O.Opportunity_Number__c + ' cannot be included in this Master BNF because it is at stage "' + O.StageName + '". Opportunities must be at stage "7a. Closed Won" or "In-Hand" before they can be included in a Master BNF.');
            ApexPages.addMessage(myMsg);
            return false;*/
            //GeneralException E = new GeneralException();
            //E.setMessage('Opportunity '+ O.Opportunity_Number__c + ' cannot be included in this Master BNF because it is at stage "' + O.StageName + '". Opportunities must be at stage "7a. Closed Won" or "In-Hand" to be included in a ' + this.BnfType + ' Master BNF.');
            //throw E;
        }
        for (OpportunityContainer OC:this.OpportunityContainer_Array)
        {
            if (O.Id == OC.Opportunity.Id)
            {
        //      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Opportunity '+ O.Opportunity_Number__c + ' has already been included in this Master BNF. You cannot include the same opportunity more than once.');
        //      ApexPages.addMessage(myMsg);
                //GeneralException E = new GeneralException();
                //E.setMessage('Opportunity '+ O.Opportunity_Number__c + ' has already been included in this Master BNF. You cannot include the same opportunity more than once.');
                //throw E;
            }
            if (this.MasterBNF.Client__c != null && O.AccountId != this.MasterBNF.Client__c)
            {
                //GeneralException E = new GeneralException();
                //E.setMessage('Opportunity '+ O.Opportunity_Number__c + ' belongs to a different account than other opportunities included in this Master BNF.  Opportunities must all belong to the same account.');
                //throw E;
            }
        }
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>([select Id, OpportunityId from OpportunityLineItem where OpportunityId=:O.Id]);
        OpportunityContainer OC = new OpportunityContainer(O,OLI_Array);
        //OC.AddedOpp = true;
        this.OpportunityContainer_Array.add(OC);
        this.Opportunity_Map.put(O.Id,O); 
        //  Set Client__c to the AccountId of the first opportunity added to this Master BNF
        if (this.MasterBNF.Client__c == null)
        {
            this.MasterBNF.Client__c = O.AccountId;
        }
    }   
    
    public void AddOpportunityRow()
    {
        try
        {
            this.ValidateOpportunityRow();
        }
        catch(Exception E)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,E.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void DeleteOpportunityRow()
    {           
        Integer i = 0;      
        for (OpportunityContainer OC:this.OpportunityContainer_Array)
        {
            if (OC.Opportunity.Id == (String)ApexPages.currentPage().getParameters().get('DelOppId'))
            {
                this.OpportunityContainer_Array.remove(i);
                return;
            }
            i++;
        }
        this.Opportunity_Map.remove((String)ApexPages.currentPage().getParameters().get('DelOppId'));
    }
    
    public void CreateMasterBnf()
    {
        //this.MasterBnf = new Master_BNF__c();
        RecordType R;
        if (this.BnfType == BnfTypeContract)
        {
            R = [select Id from RecordType where SObjectType = 'Master_BNF__c' and Name like :BnfTypeContract];
        }
        else
        {
            R = [select Id from RecordType where SObjectType = 'Master_BNF__c' and Name like :BnfTypeInvoice];
        }
        this.MasterBnf.RecordTypeId = R.Id;
        this.MasterBnf.Bnf_Status__c = 'New';
        insert this.MasterBnf; 
        List <Master_BNF_Component__c> BNF_Component_Array = new List <Master_BNF_Component__c>();
        Set<Id> OpportunityId_Set = new Set<Id>();
        for (OpportunityContainer OC:this.OpportunityContainer_Array)
        {
            OpportunityId_Set.add(OC.Opportunity.Id);
            for (OpportunityLineItem OLI:OC.getOLI_Array())
            {
                Master_BNF_Component__c BNF_Component = new Master_BNF_Component__c(Master_BNF__c=MasterBNF.Id);
                BNF_Component.OpportunityLineItemId__c = OLI.Id;
                BNF_Component_Array.add(BNF_Component);
            }
        }
        insert BNF_Component_Array; 
        List<BNF2__c> BNF_Array = [select Id, Master_BNF__c from BNF2__c where Opportunity__c in :OpportunityId_Set];
        for (BNF2__c BNF:BNF_Array)
        {
            BNF.Master_BNF__c = this.MasterBnf.Id;
        }
        update BNF_Array;
            
    }
    
    public pageReference Next2()
    {
        this.OpportunityContainer_Array.clear();
        Integer OppCount = 0;
        for (OpportunityContainer OC:this.AccountOpportunity_Array)
        {
            if (OC.Selected == true)
            {
                OppCount++;
                this.OpportunityContainer_Array.add(OC);
                this.Debug += ' NOW SELECTING OPP ' + OC.Opportunity.Id;
            }
        }
        if (OppCount < 2)
        {
            this.Debug += ' Clearing array';
            this.OpportunityContainer_Array.clear();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'A minimum of 2 opportunities must be selected before creating a Master BNF.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else
        {
            this.NewBnfWizardStep1Rendered = false;         
            this.NewBnfWizardStep2Rendered = true;
            return null;
        }
    }
    
    public pageReference Next3()
    {
        try
        {
            //this.CreateMasterBnf();
            this.Init_View();
            this.ShowEditHeader();
            this.HideOppList();
            this.NewBnfWizardStep2Rendered = false;
            this.NewBnfWizardStep3Rendered = true;
            //  Pre-default BNF header values from opportunity
            User CurrentUser = [Select Id,Sales_Org__c,Sales_Org_Code__c From User where Id = :UserInfo.getUserId()];
            this.MasterBNF.Therapy_Area__c = this.OpportunityContainer_Array[0].Opportunity.Therapy_Area__c;
            //this.MasterBNF.Sales_Org_Code__c = CurrentUser.Sales_Org_Code__c;
            this.MasterBNF.IMS_Sales_Org__c = CurrentUser.Sales_Org__c;
            this.MasterBNF.Billing_Currency__c = this.OpportunityContainer_Array[0].Opportunity.CurrencyIsoCode;
            this.MasterBNF.Project_Name__c = this.OpportunityContainer_Array[0].Opportunity.Name;
            this.MasterBNF.Contract_Start_Date__c = this.OpportunityContainer_Array[0].Opportunity.Contract_Start_Date__c;
            this.MasterBNF.Contract_End_Date__c = this.OpportunityContainer_Array[0].Opportunity.Contract_End_Date__c;
            this.MasterBNF.Contract_Type__c = this.OpportunityContainer_Array[0].Opportunity.Contract_Type__c;
            this.MasterBNF.Contract_Term__c = this.OpportunityContainer_Array[0].Opportunity.Contract_Term__c;
            this.MasterBNF.Delivery_Date__c = this.OpportunityContainer_Array[0].Opportunity.Delivery_Date__c;
            this.MasterBNF.SAP_PC_Code__c = this.OpportunityContainer_Array[0].Opportunity.Account.SAP_Reference__c;
            //  Setup default values
            this.MasterBNF.Is_this_a_retainer_downpayment__c = 'No';
            this.MasterBNF.Retainer_Data_Value__c = 0;
            this.MasterBNF.Print_Shop__c = 'No';
            this.MasterBNF.Payment_Terms__c = '0000-Dafault Payment Terms of Customer Master Data';
            pageReference NextPage = Page.MasterBnfView2;
            NextPage.getParameters().put('action','edit');
            NextPage.setRedirect(false);
            //  BEGIN DEBUG
            //this.Debug = 'xxx';
            this.Debug += 'Sales Org = ' + this.MasterBNF.IMS_Sales_Org__c;
            //  END DEBUG
            return NextPage;
        }
        catch(Exception E)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,E.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    public void Back2()
    {
        this.NewBnfWizardStep1Rendered = true;
        this.NewBnfWizardStep2Rendered = false;
        this.NewBnfWizardStep2BRendered = false;
        this.Debug = 'Calling Back 2 ';
    }
    
    public pageReference Back3()
    {
        this.NewBnfWizardStep3Rendered = false;
        this.NewBnfWizardStep2Rendered = true;
        pageReference retURL = Page.MasterBNFNewWizard;
        retURL.setRedirect(false);
        return retURL;
    }
    
    public pageReference InvoiceNext2()
    {
        if (this.OpportunityContainer_Array.size() < 2)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'A minimum of 2 opportunities must be selected before creating a Master BNF.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else
        {
            this.Init_View();
            this.ShowEditHeader();
            this.HideOppList();
            this.NewBnfWizardStep1Rendered = false;
            // ------ Default Bill To, Ship To etc. to be the same as the BNF from which this Master BNF was initiated
            //  Bill To
            this.MasterBnf.Bill_To_Account__c = this.InitiatingBnf.Bill_To_Company__c;
            this.MasterBnf.Bill_To__c = this.InitiatingBnf.Contact__c;
            this.MasterBnf.Bill_To_Address__c = this.InitiatingBnf.Bill_To_Address__c;
            this.MasterBnf.Bill_To_City__c = this.InitiatingBnf.Bill_To_City__c;
            this.MasterBnf.Bill_To_Country__c = this.InitiatingBnf.Bill_To_Country__c;
            this.MasterBnf.Bill_To_State_Province__c = this.InitiatingBnf.Bill_To_State_Province__c;
            this.MasterBnf.Bill_To_Zip_Postal_Code__c = this.InitiatingBnf.Bill_To_Zip_Postal_Code__c;
            //  Ship To
            this.MasterBnf.Ship_To_Account__c = this.InitiatingBnf.Ship_To_Company__c;
            this.MasterBnf.Ship_To__c = this.InitiatingBnf.Contact__c;
            this.MasterBnf.Ship_To_Address__c = this.InitiatingBnf.Address__c;
            this.MasterBnf.Ship_To_City__c = this.InitiatingBnf.City__c;
            this.MasterBnf.Ship_To_Country__c = this.InitiatingBnf.Country__c;
            this.MasterBnf.Ship_To_State_Province__c = this.InitiatingBnf.State_Province__c;
            this.MasterBnf.Ship_To_Zip_Postal_Code__c = this.InitiatingBnf.Zip_Postal_Code__c;
            //  2nd Copy
            this.MasterBnf.Second_Copy_Account__c = this.InitiatingBnf.X2nd_Copy_Company__c;
            this.MasterBnf.Second_Copy__c = this.InitiatingBnf.X2nd_Copy_Contact__c;
            this.MasterBnf.Second_Copy_Address__c = this.InitiatingBnf.X2nd_Address__c;
            this.MasterBnf.Second_Copy_City__c = this.InitiatingBnf.X2nd_City__c;
            this.MasterBnf.Second_Copy_Country__c = this.InitiatingBnf.X2nd_Country__c;
            this.MasterBnf.Second_Copy_State_Province__c = this.InitiatingBnf.X2nd_State_Province__c;
            this.MasterBnf.Second_Copy_Zip_Postal_Code__c = this.InitiatingBnf.X2nd_Zip_Postal_Code__c;
            //  Carbon Copy
            this.MasterBnf.Carbon_Copy_Account__c = this.InitiatingBnf.Carbon_Copy_Company__c;
            this.MasterBnf.Carbon_Copy__c = this.InitiatingBnf.Carbon_Copy_Contact__c;
            this.MasterBnf.Carbon_Copy_Address__c = this.InitiatingBnf.Carbon_Copy_Address__c;
            this.MasterBnf.Carbon_Copy_City__c = this.InitiatingBnf.Carbon_Copy_City__c;
            this.MasterBnf.Carbon_Copy_Country__c = this.InitiatingBnf.Carbon_Copy_Country__c;
            this.MasterBnf.Carbon_Copy_State_Province__c = this.InitiatingBnf.Carbon_Copy_State_Province__c;
            this.MasterBnf.Carbon_Copy_Zip_Postal_Code__c = this.InitiatingBnf.Carbon_Copy_Zip_Postal_Code__c;
            //  Cover Sheet
            this.MasterBnf.Cover_Sheet_Account__c = this.InitiatingBnf.Cover_Sheet_Company__c;
            this.MasterBnf.Cover_Sheet__c = this.InitiatingBnf.Cover_Sheet_Contact__c;
            this.MasterBnf.Cover_Sheet_Address__c = this.InitiatingBnf.Cover_Sheet_Address__c;
            this.MasterBnf.Cover_Sheet_City__c = this.InitiatingBnf.Cover_Sheet_City__c;
            this.MasterBnf.Cover_Sheet_Country__c = this.InitiatingBnf.Cover_Sheet_Country__c;
            this.MasterBnf.Cover_Sheet_State_Province__c = this.InitiatingBnf.Cover_Sheet_State_Province__c;
            this.MasterBnf.Cover_Sheet_Zip_Postal_Code__c = this.InitiatingBnf.Cover_Sheet_Zip_Postal_Code__c;  
            //  Default Sales Org to sales org of user
            User CurrentUser = [Select Id,Sales_Org__c,Sales_Org_Code__c From User where Id = :UserInfo.getUserId()];
            //this.MasterBNF.Sales_Org_Code__c = CurrentUser.Sales_Org_Code__c;
            this.MasterBNF.IMS_Sales_Org__c = CurrentUser.Sales_Org__c;
            this.MasterBNF.SAP_PC_Code__c = this.OpportunityContainer_Array[0].Opportunity.Account.SAP_Reference__c;    
            this.NewBnfWizardStep2BRendered = true;
            return null;
        }
    }
    
    public pageReference InvoiceNext3()
    {
        pageReference NextPage = Page.MasterBNFView2;
        NextPage.getParameters().put('action','edit');
        this.NewBnfWizardStep2BRendered = false;
        this.NewBnfWizardStep3Rendered = true;
        NextPage.setRedirect(false);
        //  BEGIN DEBUG
        this.Debug = 'xxx';
        //  END DEBUG
        return NextPage;        
    }
    
    public pageReference InvoiceBack3()
    {
        this.NewBnfWizardStep3Rendered = false;
        this.NewBnfWizardStep1Rendered = true;
        pageReference retURL = Page.MasterBNFNewWizardCombinedInvoice;
        retURL.setRedirect(false);
        return retURL;
    }
    
    public Boolean getRenderedForInvoice()
    {
        if (this.BnfType == BnfTypeInvoice)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    public void ShowAddMoreOpps()
    {
        this.AddMoreOppsRendered = true;
        //this.HideOppList();
    }
    
    public void HideAddMoreOpps()
    {
        this.AddMoreOppsRendered = false;
        //this.ShowOppList();
    }
    
    public void SaveAddedOpp()
    {
        try
        {   
            this.ValidateOpportunityRow();
            List <Master_BNF_Component__c> BNF_Component_Array = new List <Master_BNF_Component__c>();
            for (OpportunityLineItem OLI:[select Id, OpportunityId from OpportunityLineItem where OpportunityId = :this.ProxyOcr.OpportunityId])
            {
                Master_BNF_Component__c BNF_Component = new Master_BNF_Component__c(Master_BNF__c=this.MasterBNF.Id);
                BNF_Component.OpportunityLineItemId__c = OLI.Id;
                BNF_Component_Array.add(BNF_Component);
            }
            insert BNF_Component_Array;
            List<BNF2__c> BNF_Array = [select Id, Master_BNF__c from BNF2__c where Opportunity__c = :this.ProxyOcr.OpportunityId];
            for (BNF2__c BNF:BNF_Array)
            {
                BNF.Master_BNF__c = this.MasterBnf.Id;
            }
            update BNF_Array;
            this.Init_View();
        }
        catch(Exception E)
        {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,E.getMessage());
                ApexPages.addMessage(myMsg);
        }       
    }
        
    public pageReference CancelWizard()
    {
        pageReference retURL;
        if ((String)ApexPages.currentPage().getParameters().get('BnfId') != null)
        {
             retURL = new pageReference('/'+(String)ApexPages.currentPage().getParameters().get('BnfId'));  
        }
        else if ((String)ApexPages.currentPage().getParameters().get('OpportunityId') != null)
        {
            retURL = new pageReference('/'+(String)ApexPages.currentPage().getParameters().get('OpportunityId'));
        }
        retURL.setRedirect(true);
        return retURL;
    }   
    
    public Boolean getBnfLocked()
    {
        if (this.MasterBnf.Bnf_Status__c != 'New' && this.MasterBnf.Bnf_Status__c != 'Rejected')
        {
            return true;
        }
        else 
        {
            return false;
        }
    }
    
    public String getStatusImage()
    {
        if (this.MasterBnf.Bnf_Status__c == 'Submitted')
        {
            return '/img/samples/light_yellow.gif';
        }
        else if (this.MasterBnf.Bnf_Status__c == 'Rejected')
        {
            return '/img/samples/light_red.gif';
        }
        else if (this.MasterBnf.Bnf_Status__c == 'New')
        {
            return '/s.gif';
        }
        else
        {
            return '/img/samples/light_green.gif';
        }
    }
        
    public List<SelectOption> getSalesOrgs()
    {
        List<SelectOption> optionList = new List<SelectOption>();
        Boolean UserSalesOrgFound = false;
        for (Controlling_Field_Option__c f : [select Controlling_Field_Value__c from Controlling_Field_Option__c where Controlling_Field_Name__c = 'IMS_Sales_Org__c' and object_name__c = 'Master_BNF__c'])
        {
            optionList.add(new SelectOption(f.Controlling_Field_Value__c,f.Controlling_Field_Value__c));
            if (this.MasterBnf.IMS_Sales_Org__c == f.Controlling_Field_Value__c)
            {
                UserSalesOrgFound = true;
            }
        }
        if (!UserSalesOrgFound)
        {
            optionList.add(0,new SelectOption('','-- None --')); 
            this.MasterBnf.IMS_Sales_Org__c = '';   
        }
        
        //  BEGIN DEBUG
            //this.Debug = 'xxx';
            this.Debug += ' Getting Sales Orgs';
        //  END DEBUG
        return optionList;
    } 
    
    public List<SelectOption> getSalesOrgCodes()
    {
        List<SelectOption> optionList = new List<SelectOption>();
        for (Dependent_Field_Option__c f : [select dependent_Field_Value__c from Dependent_Field_Option__c where Controlling_Field_Option__r.Name = :this.MasterBnf.IMS_Sales_Org__c and Controlling_Field_Option__r.object_name__c = 'Master_BNF__c'])
        {
            optionList.add(new SelectOption(f.dependent_Field_Value__c,f.dependent_Field_Value__c));
        }
        if (optionList.size() == 0)
        {
            optionList.add(new SelectOption('','-- None --')); 
        }
        else if (optionList.size() > 1)
        {
            optionList.add(0,new SelectOption('','-- None --'));    
        }
        return optionList;
    } 
     
    public void Debug1()
    {
        String Message = 'Bill To: ' + (String)this.MasterBnf.Bill_To__c;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Message);
        ApexPages.addMessage(myMsg);        
        Message = 'Carbon Copy: ' + (String)this.MasterBnf.Carbon_Copy__c;
        myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Message);
        ApexPages.addMessage(myMsg);
        Message = 'Second Copy: ' + (String)this.MasterBnf.Second_Copy__c;
        myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Message);
        ApexPages.addMessage(myMsg);
        Message = 'Cover Sheet: ' + (String)this.MasterBnf.Cover_Sheet__c;
        myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Message);
        ApexPages.addMessage(myMsg);
    } 
        
    public class OpportunityContainer
    {
        private Opportunity Opportunity;
        private List<OpportunityLineItem> OLI_Array;
        public OpportunityContactRole OCR {get;set;}
        public Boolean Selected {get;set;}
        
        public OpportunityContainer(Opportunity Opp,List<OpportunityLineItem> OLI_Array)
        {
            this.OLI_Array = new List<OpportunityLineItem>();
            this.Opportunity = Opp;
            this.OCR = new OpportunityContactRole(OpportunityId=Opp.Id);
            this.Selected = false;
        //  this.AddedOpp = false;
            for (OpportunityLineItem OLI:OLI_Array)
            {
                if (OLI.OpportunityId == this.Opportunity.Id)
                {
                    this.OLI_Array.add(OLI);
                }
            }
        }
        
        public Opportunity getOpportunity()
        {
            return this.Opportunity;
        }
        
        public List<OpportunityLineItem> getOLI_Array()
        {
            return this.OLI_Array;
        }   
        
        
            
    }
    
    /*public class ContactContainer
    {
        public Contact Contact {get;set;}
        //public Account Account {get;set;}
        public OpportunityContactRole OCR {get;set;}
        public String Address {get;set;}
        public String City {get;set;}
        public String Country {get;set;}
        public String State_Province {get;set;}
        public String Zip_Postal_Code {get;set;}
        //public String Contact_Name_Local {get;set;}
        //public String Account_Name_Local {get;set;}
        
        public ContactContainer(Id ContactId, Id AccountId)
        {
            this.Contact = new Contact(Id = ContactId, AccountId = AccountId);
            this.OCR = new OpportunityContactRole(ContactId=Contact.Id);
            this.Address = C.MailingStreet;
            this.City = C.MailingCity;
            this.Country = C.MailingCountry;
            this.State_Province = C.MailingState;
            this.Zip_Postal_Code = C.MailingPostalCode;
            this.Contact_Name_Local = C.FirstNameLocal + ' ' + C.LastNameLocal;
            this.Account_Name_Local = C.Account.NameLocal;
        }

    }*/
 
}