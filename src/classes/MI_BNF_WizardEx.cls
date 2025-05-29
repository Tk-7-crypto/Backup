// This Class is used to create multi invoice bnf for an opportunity using wizard
// Create by : Himanshu Parashar
// Date : 16 sep 2011

public class MI_BNF_WizardEx {

        // These three member variables maintain the state of the wizard.
        // When users enter data into the wizard, their input is stored
        // in these variables.
                
        public MIBNF2__c MIBNF;
    	@testVisible
        private MIBNF_Component__c MIBNF_Comp;
        private MI_BNF_LineItem__c MIBNF_LineItem;
        private Static Set<String> excludedProducts;
        public List<OpportunityLineItem> oppAvailableProductsList{get; private set;}
        public Boolean ProductAdded{get;private set;}
        public String SuccessMsg{get;private set;}
        public String SelectProductList{get;set;}
        public Boolean ShowPrevious{get;private set;}
        public Opportunity opp {get;private set;}
        public Boolean ErrorFlag{get;private set;}
        public Boolean BNFEdit{get;private set;}
        public Boolean BNFRevised{get;private set;}
        public Boolean Renewal{get;private set;}
        private String UserProfileName;
        private String MIBNFCompID;
        public String MIBNFID;
        public String InvoiceStatusText{get;private set;}
        private Map<id,OpportunityLineItem> oppAvailableProductsMap;
        public Boolean UserIsSysAdmin {get;private set;} 
        public Boolean RenderRevisedBnfFields {get;private set;}
        public Boolean hasError{get;private set;}
        //  Flag to indicate whether MIBNF_Component has just been inserted
        //  Used to ignore billing schedule validations and allow user to setup billing schedules
        //  for all line items together instead of having to enter for each individually
        private Boolean NewBnf;
        private Boolean hasAccessBNFAll;
        private Boolean IsRevisedBNFWithDoc = false;
        public Boolean isMIBNFPrebillingSalesOrgCode {get; set;}
        static {
            BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
            excludedProducts = new Set<String>();
            if(bnfSetting.Excluded_Products__c != null) {
                excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
            }
         }
    
        
        //Class Constructor
         public MI_BNF_WizardEx() 
         { 
               // To be used when user will come through MIBNF view page 
                ProductAdded=false;
                ShowPrevious=true;
                BNFEdit=false;
                Renewal=false;
                ErrorFlag = false;
                RenderRevisedBnfFields = false;
                NewBnf = false;
                isMIBNFPrebillingSalesOrgCode = false;
                this.hasAccessBNFAll = false;
               List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
               if(permSetAssList.size() > 0) {
                 hasAccessBNFAll = true; 
               }
                //getting user info
                User userRec = [select Id,Name,User_Country__c,Profile.Name from User where id = :UserInfo.getUserId()];
                        this.UserProfileName = userRec.Profile.Name;
                this.UserIsSysAdmin = userRec.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR'); 
                
                // Check for Existing Normal BNF
                if(ApexPages.currentPage().getParameters().get('oppid')!=null)
                {
                    List<BNF2__c> ExistingBnf_Array = [select Id,Addendum__c from BNF2__c where Opportunity__c = :ApexPages.currentPage().getParameters().get('oppid')];
                    Boolean AllLineItemsCancelled = true;
                    for (OpportunityLineItem OLI:[select Id,Sale_Type__c,Cancel__c from OpportunityLineItem where OpportunityId = :ApexPages.currentPage().getParameters().get('oppid') and Product_Material_Type__c NOT IN :excludedProducts])
                    {
                        if (OLI.Sale_Type__c == 'Repeat')
                        {
                            Renewal = true;
                        }
                        if (!OLI.Cancel__c)
                        {
                            AllLineItemsCancelled = false;
                        }
                    }
                    if (ExistingBnf_Array.size() > 0 && !AllLineItemsCancelled)
                    {
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.error, 'A BNF already exists for this opportunity. Multi invoice BNF\'s cannot be created unless a revised BNF has been submitted to cancel all products.');
                        ApexPages.addMessage(errMsg); 
                        ErrorFlag=true;                      
                    }
                    else if (ApexPages.currentPage().getParameters().get('mibnfid')==null)
                    {
                        List<MIBNF2__c> MIBNF_Array = [select Id from MIBNF2__c where Opportunity__c = :ApexPages.currentPage().getParameters().get('oppid') limit 1];
                        if (MIBNF_Array.size() > 0)
                        {                        
                            ApexPages.Message errMsg2 = new ApexPages.Message(ApexPages.Severity.error, 'A Multi Invoice BNF already exists for this opportunity. Only one Multi Invoice BNF can be created per opportunity.');
                            ApexPages.addMessage(errMsg2); 
                            ErrorFlag=true;
                        }
                    }
 
                }
                
                
                
                if(ApexPages.currentPage().getParameters().get('revised')==null)
                {
                    this.BNFRevised=false;
                }
                else
                {
                    this.BNFRevised=true;
                    RenderRevisedBnfFields = true;
                }
                
                InvoiceStatusText='Step 2 of 2';
                // Opportunity Details
             if(ApexPages.currentPage().getParameters().get('oppid')!=null) 
                 opp=[Select name,Opportunity_Number__c,Therapy_Area__c,Parent_Opportunity__c,Contract_Start_Date__c,Contract_End_Date__c,AccountId,Contract_Type__c,currencyisocode,Contract_Term__c,SAP_Master_Contract__c,Account.MDM_Validation_Status__c, Multi_Country_Billing__c from Opportunity where ID=:ApexPages.currentPage().getParameters().get('oppid') limit 1];
             
             if(ApexPages.currentPage().getParameters().get('oppid')!=null && opp.account.MDM_Validation_Status__c != 'Validated')
             {
                 ApexPages.Message errMsg2 = new ApexPages.Message(ApexPages.Severity.error, 'MIBNF\'s cannot be created for accounts which have not been SAP validated');
                 ApexPages.addMessage(errMsg2); 
                 ErrorFlag=true;
             }
             
             
             if(ApexPages.currentPage().getParameters().get('mibnfid')!=null && ApexPages.currentPage().getParameters().get('id')==null )
             {
                 ShowPrevious=false;
                 InvoiceStatusText='Create New BNF';
                 MIBNFID=ApexPages.currentPage().getParameters().get('mibnfid');
                 getLineItemProduct();
                 // Get MIBNF details if MIBNF id is passed when new invoice is created from MIBNF view Page.
                 MIBNF=[Select Name,Additional_Billing_Date_Information__c,Payment_Terms__c,Contract_Term__c,Comments__c,Opportunity__c,Invoice_Default_Day__c,Sales_Org_Code__c, Revenue_Analyst__c 
                        from MIBNF2__c where id=:MIBNFID limit 1];
             }
             
             if(ApexPages.currentPage().getParameters().get('id')!=null)
             {  
                 // Edit BNF
                 ShowPrevious=false;
                 BNFEdit=true;
                 
                 
                 
                 // updated By Ritesh Gupta - Issue 09951 -
                 MIBNF_Comp=[Select Name,urgent_handling__c, MIBNF__c,MIBNF__r.Opportunity__c,  Id, Contract_Value__c,LastModifiedById,CreatedById,No_Pricing_Date_Update__c,  
                             Comments__c, Bill_To__c, BNF_Status__c,BNFName__c,Manual_Handling_in_SAP__c,Billing_Frequency__c,Revised_BNF_Date__c, 
                             X2nd_Copy__c,Payment_Terms__c,Additional_Delivery_Date_Information__c,Addendum__c,Revised_BNF_Reason__c,Carbon_Copy_SAP_Contact__c,
                             X2nd_Copy_SAP_Base_Code__c,X2nd_Copy_SAP_Contact__c,Bill_To_SAP_Contact__c,Delivery_Date__c,Client_PO_Number__c,
                             Additional_Billing_Date_Information__c,Ship_To_SAP_Contact__c,Ship_To__c,Cover_Sheet_SAP_Contact__c,Bill_To_SAP_Base_Code__c,Revised_BNF_Comment__c,
                             Ship_To_SAP_Base_Code__c,Invoice_Header_Text__c,Billing_Currency__c,Carbon_Copy_SAP_Base_Code__c,SAP_Contract__c, 
                             cover_Sheet__c,Cover_Sheet_SAP_Base_Code__c,Carbon_Copy__c,Invoice_Default_Day__c,CurrencyIsocode,
                             Is_this_a_retainer_downpayment__c,Subscription_Type__c,Retainer_Data_Value__c,Specification__c,Description__c,Print_Shop__c,
                             Travel_Amount__c,Accomodation_Amount__c,Sub_Contractor_Amount__c,Is_PO_Required__c,Pass_thru_schedules__c,Retainer_Opportunity_Number__c,Hono__c,Orignal_BNF__c,SAP_Master_Contract__c,MIBNF__r.Sales_Org_Code__c,BNF_Description__c,Local_Printing__c,Project_Name__c,Sold_To__c,Sold_To__r.SAP_Reference__c
                             from MIBNF_Component__c where id=:ApexPages.currentPage().getParameters().get('id') limit 1];
                 
                 MIBNFID=MIBNF_Comp.MIBNF__c;
                 
                 MIBNF=new MIBNF2__c();
                 
                 MIBNF.Sales_Org_Code__c=MIBNF_Comp.MIBNF__r.Sales_Org_Code__c;
                 //Check for User allowed to edit
                 boolean AllowedToEdit = false;                       
                 ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :MIBNF_Comp.Id];        
                 if (P_array.size()!= 0)
                 {
                     for (ProcessInstanceWorkitem P2:P_array)
                     {
                         if (P2.ActorId == userRec.Id)
                         {
                             AllowedToEdit = true;
                         }
                     }
                 }                       
                 
                 //Updated By Himanshu Parashar
                 // Date : 25 May 2012
                 // Revised should be visible if editing revised BNF
                 if(BNFRevised==true)
                 {
                     if(ApexPages.currentPage().getParameters().get('IsRevisedBNFWithDoc') == 'true'){
                         InvoiceStatusText='Create Revised BNF with Documents';
                         IsRevisedBNFWithDoc = true;
                         
                     }else{
                         InvoiceStatusText='Create Revised BNF';
                     }
                     //InvoiceStatusText='Create Revised BNF';
                     MIBNF_Comp.Revised_BNF_Reason__c='';
                     MIBNF_Comp.Revised_BNF_Date__c=null;
                 }else
                     InvoiceStatusText='Edit BNF ' + MIBNF_Comp.Name;
                 if (BNFRevised)
                 {
                     MIBNF_Comp.Orignal_BNF__c = MIBNF_Comp.Id;
                 }
                 if (MIBNF_Comp.Addendum__c)
                 {
                     RenderRevisedBnfFields = true;
                 }
                 if (MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED') && BNFRevised)
                 {
                     this.ErrorFlag = true;
                     ApexPages.Message errMsg3 = new ApexPages.Message(ApexPages.Severity.Error, 'A revised BNF cannot be created until the original BNF has a status of "' + MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED')+'"');
                     ApexPages.addMessage(errMsg3); 
                 }
                 else if (!BNFRevised && MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') && 
                          MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('REJECTED') && 
                          MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('LO_REJECTED') && 
                          MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('RA_REJECTED') &&
                          MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') && 
                          MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED') && 
                          MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('NEW') && !this.UserIsSysAdmin && !this.hasAccessBNFAll &&!AllowedToEdit)
                 {
                     this.ErrorFlag = true;
                     ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'BNF cannot be edited when submitted or approved');
                     ApexPages.addMessage(errMsg); 
                 }
                 
             }
             
             //Update by Balkrishan Gohil : 06 Jan 2025 For (ESPSFDCQI-17263)
             //Throwing Error while MiBNF Creation on EMEA Opportunity and Related Primary IQVIA Quote is Not on Accepted Stage AND OLI not Synced with QLI
             //This Validation will Work after April 2025 Release (ESPSFDCQI-17520)
             
             String apexPageName ;
             String VFPageName ;
             if(!Test.isRunningTest()){
                 apexPageName = ApexPages.currentPage().getUrl().substringAfter('apex/');
                 VFPageName = apexPageName.substring(0,16);
             }else{
                 VFPageName = 'MI_BNF_wiz_step1';
             }
             
             if(VFPageName == 'MI_BNF_wiz_step1'){
                 Id oppId = ApexPages.currentPage().getParameters().get('oppid');
                 Map<Id,String> oppIdToErrorMsgMap = new Map<Id,String>();
                 oppIdToErrorMsgMap = CPQ_QuoteUtilityWO.validateQuoteSyncWithOpportunities(new Set<Id>{oppId});
                 String errorMsg = oppIdToErrorMsgMap.get(oppId);
                 Boolean isSuperuser = [Select Exclude_IQVIA_Quote_Sync__c from Opportunity where id = :oppId limit 1].Exclude_IQVIA_Quote_Sync__c;
                 if(errorMsg != 'Success' && errorMsg != 'Error:NonEMEAEligibleOpportunity' && BNFRevised == False && UTL_GLOBAL.getCurrentReleaseVersion() >= CON_GLOBAL.RELEASE_APR_2025 && !isSuperuser){
                     ApexPages.Message errMsg4 = new ApexPages.Message(ApexPages.Severity.error, 'Please make sure this opportunity has a Primary and Accepted IQVIA Quote record and ensure Quote Line Item and Opportunity Product are in sync before creating BNF.');
                     ApexPages.addMessage(errMsg4); 
                     ErrorFlag=true;
                 }  
             }
             
         }
    
    //Constructor is used to call from MIBNF_ComponentCheckBNFSubmit Trigger to return if there is any available products
    public MI_BNF_WizardEx (ID BNFID,ID MIBNFID,ID OPPID) 
    {       
        MIBNF_Comp=new MIBNF_Component__c(id=BNFID);
        isMIBNFPrebillingSalesOrgCode = false;
        this.MIBNFID=MIBNFID;
        opp=new Opportunity(id=OPPID);
        getLineItemProduct();
    }
    
    // The next three methods return one of each of the three member
    // variables. If this is the first time the method is called,
    // it creates an empty record for the variable.
    public MIBNF2__c getMIBNF() {
        if(MIBNF == null){
            MIBNF = new MIBNF2__c();
            // Setup default value from Opportunity.
            MIBNF.Opportunity__c=opp.id;
            MIBNF.Client__c=opp.AccountId;
            MIBNF.Original_Prior_Opportunity__c=opp.Parent_Opportunity__c;
            MIBNF.Contract_End_Date__c=opp.Contract_End_Date__c;
            MIBNF.Contract_Start_Date__c=opp.Contract_Start_Date__c;
            MIBNF.Contract_Type__c=opp.Contract_Type__c;
            MIBNF.Billing_Currency__c =opp.currencyisocode ;
            MIBNF.CurrencyIsoCode = opp.currencyisocode ;
            MIBNF.Max_Invoice_Count__c=00;
            MIBNF.Invoice_Default_Day__c='DefaultMaterialMasterData';
            MIBNF.Contract_Term__c=opp.Contract_Term__c;
            MIBNF.Therapy_Area__c=opp.Therapy_Area__c;
            MIBNF.Renewal__c=Renewal;    
            MIBNF.SAP_Master_Contract__c = opp.SAP_Master_Contract__c;
            //Added By Rakesh : 10 April 2015 : Issue-6662 : START
            Map<Id, Opportunity> oppMapWithAgreements = new map<id, Opportunity>();
            Contract_Management_Setting__c contractSetting = Contract_Management_Setting__c.getInstance();
            string OppId = opp.id;
            if(!string.isBlank(OppId) && ConstantClass.allowSalesOrgUpdateOnBNF_FromSCM && contractSetting != null && contractSetting.Allow_SalesOrg_Update_In_BNF_From_SCM__c)
            {
                oppMapWithAgreements = new map<id, Opportunity>([SELECT Id, (SELECT Id,IMS_Legal_Entity__c FROM Proxy_SCM_Agreements__r where Record_Type_Name__c = 'SOW' and is_Amendment_Record__c = false ) FROM Opportunity where id = : oppId]);
                if(oppMapWithAgreements.size() > 0 )
                {
                    map<string, string> salesCodetoSalesOrgNameInBNFMap = ConstantClass.getSalesOrgNameinBNFSystem1('Purchase BNF');
                    string IMSSalesOrgCode = '';
                    string legalEntity = '';
                    
                    //Get legal entity of agreement based on opportunity
                    legalEntity =  ConstantClass.checkAgreementLegalEntityForOpportunity(oppId, oppMapWithAgreements);             
                    //get sales org code based on legal entity
                    IMSSalesOrgCode = ConstantClass.getSalesOrgCodeforAgreementLegalEntity(legalEntity);
                    
                    //set Sales org name and code on BNF   
                    if( salesCodetoSalesOrgNameInBNFMap != null && !string.isblank(IMSSalesOrgCode) && salesCodetoSalesOrgNameInBNFMap.containsKey(IMSSalesOrgCode))
                    {
                        MIBNF.IMS_Sales_Org__c  = salesCodetoSalesOrgNameInBNFMap.get(IMSSalesOrgCode);
                    }
                }
            }
            /*
            //END : Issue-6662
            if(opp.IQVIA_Ltd_GB80_Engagement__c){
                MIBNF.IMS_Sales_Org__c = '[GB80] IQVIA Ltd';
                MIBNF.Sales_Org_Code__c = 'GB80';
            }
            */
            //ESPSFDCQI-6899
            if(opp.Multi_Country_Billing__c == 'IQVIA Ltd GB80 engagement'){
                MIBNF.IMS_Sales_Org__c = '[GB80] IQVIA Ltd';
                MIBNF.Sales_Org_Code__c = 'GB80';
            }
             if(opp.Multi_Country_Billing__c == 'IQVIA Operations France – FR12'){
                MIBNF.IMS_Sales_Org__c = '[FR12] IQVIA Operations France SAS';
                MIBNF.Sales_Org_Code__c = 'FR12';
            }
        }       
        return MIBNF;
    }
        public MIBNF_Component__c getMIBNF_Comp() {
                if(MIBNF_Comp == null && ApexPages.currentPage().getParameters().get('id')==null)
                {
                         MIBNF_Comp = new MIBNF_Component__c();
                         //setup default values from Opportunity
                         MIBNF_Comp.Additional_Billing_Date_Information__c=MIBNF.Additional_Billing_Date_Information__c;
                         MIBNF_Comp.Payment_Terms__c=MIBNF.Payment_Terms__c;
                         MIBNF_Comp.Comments__c=MIBNF.Comments__c;
                         MIBNF_Comp.Invoice_Default_Day__c=MIBNF.Invoice_Default_Day__c;
                         MIBNF_Comp.Print_Shop__c='No';
                         MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
                         MIBNF_Comp.Retainer_Data_Value__c=0.0;
                         MIBNF_Comp.Project_Name__c=opp.name;
                         MIBNF_Comp.Billing_Currency__c =MIBNF.currencyisocode ;
                         MIBNF_Comp.CurrencyIsoCode = opp.CurrencyIsoCode;                        
                }
                
                return MIBNF_Comp;
        }
        
        public MI_BNF_LineItem__c getMIBNF_LineItem() {
                if(MIBNF_LineItem == null) 
                {    
                    MIBNF_LineItem = new MI_BNF_LineItem__c();
                    
                }
                return MIBNF_LineItem;
        }
                
        // The next two methods control navigation through
        // the wizard. Each returns a PageReference for one of the two pages
        // in the wizard. Note that the redirect attribute does not need to
        // be set on the PageReference because the URL does not need to change
        // when users move from page to page.
        public PageReference step1() {
                        return Page.MI_BNF_wiz_step1;
        }
        
        public PageReference step2() {
                    if(MIBNF.Contract_Start_Date__c>MIBNF.Contract_End_Date__c)
                    {
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.error, 'Contract End Date cannot be before Contract Start Date');
                        ApexPages.addMessage(errMsg); 
                        ErrorFlag=true; 
                                   
                    }
                    else if(MIBNF.IMS_Sales_Org__c == '[DK05] IQVIA Partners A/S' || MIBNF.IMS_Sales_Org__c =='[DK86] Tarius')
                    {
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.error, 'DK05 and DK86 can select only when Revised BNF = TRUE');
                        ApexPages.addMessage(errMsg); 
                        ErrorFlag=true; 
                                   
                    }
                    else
                    {   
                        getLineItemProduct();
                        return Page.MI_BNF_wiz_step2;
                    }
           return null;         
        }
       
                
        // This method performs the final save for all three objects, and
        // then navigates the user to the detail page for the new
        // MIBNF.
        public PageReference save() {

            if(MIBNF_Comp != null && RenderRevisedBnfFields){
                MIBNF_Comp.Addendum__c = true;
            }
            hasError = false;
                 //Check for validatation.
                 if(this.UserProfileName.toUpperCase().contains('MDM') && !UserIsSysAdmin && !this.hasAccessBNFAll && (MIBNF_Comp.Invoice_Header_Text__c=='' || MIBNF_Comp.Invoice_Header_Text__c==null)
                    && (MIBNF.Sales_Org_Code__c=='FR51'|| MIBNF.Sales_Org_Code__c=='FR13' || MIBNF.Sales_Org_Code__c=='DE50'))
                 {
                     ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.error, 'Invoice header text required');
                     ApexPages.addMessage(errMsg); 
                     hasError = true;
                 }
                 if(MIBNF_Comp.Pass_thru_schedules__c == null && (MIBNF_Comp.Travel_Amount__c != null || MIBNF_Comp.Accomodation_Amount__c != null || MIBNF_Comp.Sub_Contractor_Amount__c != null || MIBNF_Comp.Hono__c != null)) {
                    ApexPages.Message errMsgSCH = new ApexPages.Message(ApexPages.Severity.error, 'Please fill in Pass thru schedule field');
                    ApexPages.addMessage(errMsgSCH);
                    hasError = true;
                 }
                 if(MIBNF_Comp.Retainer_Opportunity_Number__c == null && MIBNF_Comp.Retainer_Data_Value__c  != null  && MIBNF_Comp.Retainer_Data_Value__c  < 0) {
                    ApexPages.Message errMsgRetain = new ApexPages.Message(ApexPages.Severity.error, 'Retainer Opportunity Number is required when Retainer/Down Payment Data Value has negative amount.');
                    ApexPages.addMessage(errMsgRetain);
                    hasError = true;
                 }

                 if(hasError) {
                    return null;
                 }
                                      
                 if(AddBnf())
                 {
                     // Finally, send the user on BNF Address selector if it is created using wizard or it is newly created BNF
                    List<AggregateResult> groupedResults = [SELECT count(id) FROM MIBNF_Component__c where MIBNF__c=:MIBNFID];
        
                                    Integer BNFCount=0;
                                    for (AggregateResult ar : groupedResults)
                                    {
                                    BNFCount=Integer.valueOf(ar.get('expr0'));
                            }
                    
                    PageReference opptyPage;
                    if(!BNFEdit && (ApexPages.currentPage().getParameters().get('wz')=='1' || BNFCount==1))
                    { 
                        opptyPage = new PageReference('/apex/MIBNF_Address_Selector?id=' + MIBNF_Comp.Id + '&wz=1&mibnfid=' + MIBNFID);
                        NewBnf = true;
                        opptyPage.getParameters().put('billing_sched','true');
                    }
                    else
                    {
                            opptyPage = new PageReference('/apex/MI_BNF_View?id=' + MIBNFID);
                            if(BNFEdit!=null && BNFEdit && MIBNF_Comp.Id!=null && ApexPages.currentPage().getParameters().get('editbnf')!=null)
                                 opptyPage.setAnchor('lnk' + MIBNF_Comp.Id);
                     }
                    opptyPage.setRedirect(true);
                    return opptyPage;
                 }
                 else
                 {
                     ErrorFlag = false;
                     ProductAdded=false;
                     return null;
                 }
        }
                
       /* public PageReference saveandNew() {
            // Add BNF and Invoice
            if(AddBnf())
                return Page.MI_BNF_wiz_step2;
            else
                return null;
                
        }*/
                
        
        public PageReference cancel() {
                PageReference opptyPage;
                
                if(ApexPages.currentPage().getParameters().get('retURL')!=null)
                {
                        opptyPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
                }
                else if(MIBNFID!=null)
                {
                        opptyPage = new PageReference('/apex/MI_BNF_View?id=' + MIBNFID);
                        if(BNFEdit!=null && BNFEdit && MIBNF_Comp.Id!=null && ApexPages.currentPage().getParameters().get('editbnf')!=null)
                             opptyPage.setAnchor('lnk' + MIBNF_Comp.Id);
                }
                else
                {
                        opptyPage = new PageReference('/' + opp.Id);
                }
                
                
                opptyPage.setRedirect(true);
                return opptyPage;
        }
                                
        public List<OpportunityLineItem> getLineItemProduct()
        {
          Set<String> prebillingSalesOrgSet = new Set<String>{'MX02', 'GT01', 'CO01', 'CO71'};
          // Item List which is addes previously in various invoices.
          List<MIBNF_Component__c> MIBNF_CompList= [SELECT Id, MIBNF__r.Sales_Org_Code__c FROM MIBNF_Component__c where miBNF__c=:MIBNFID];
          if(MIBNF_CompList != null && MIBNF_CompList.size() > 0) {
              if(prebillingSalesOrgSet.Contains(MIBNF_CompList[0].MIBNF__r.Sales_Org_Code__c)) {
                  isMIBNFPrebillingSalesOrgCode = true;
              }
          }
          set<String> oli_id_set = new set<String>(); 
          for(MI_BNF_LineItem__c MI_BNF_LineItemList : [select Opportunity_Line_Itemid__c from MI_BNF_LineItem__c where MIBNF_Component__c in : MIBNF_CompList])
          {
                oli_id_set.add(MI_BNF_LineItemList.Opportunity_Line_Itemid__c);
          } 

          //show Available Products list from opportunity
          //Added By : Himanshu Parashar : 11 April 2013 :: therapy_area__c(Issue-1990)
          oppAvailableProductsMap =  new Map<id,OpportunityLineItem>([Select o.Sale_Type__c, o.Quantity, o.Product_Invoice_Text__c, 
                                               o.Id,o.PricebookEntry.Name,o.PricebookEntry.Product2.Material_Type__c,o.Delivery_Media__c ,o.Billing_Frequency__c,
                                               o.TotalPrice,o.Product_Start_Date__c,o.Product_End_Date__c,o.Proj_Rpt_Frequency__c,o.Discount_Reason__c,Prebilling__c,PO_line_item_number__c,
                                               o.Discount_Amount_Formula__c,o.PricebookEntry.ProductCode,o.therapy_area__c,Project_Start_Date__c,Project_End_Date__c
                                               From OpportunityLineItem o where opportunityid=:opp.Id and id not in : oli_id_set and Product_Material_Type__c NOT IN :excludedProducts order by o.PricebookEntry.Name]);
            
          for (OpportunityLineItem oli:oppAvailableProductsMap.values())
          {
            if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP' && oli.Project_Start_Date__c != null && oli.Project_End_Date__c != null) 
            {
                oli.Product_Start_Date__c = oli.Project_Start_Date__c;
                oli.Product_End_Date__c = oli.Project_End_Date__c;            
            } 
          }
           oppAvailableProductsList= oppAvailableProductsMap.values();
           return oppAvailableProductsList;
        }
                
                
       // Add Invoice lineItem         
    @testVisible
       private void AddInvoiceLineItem(MIBNF_Component__c Comp)
       {
          List<MI_BNF_LineItem__c> MI_BNF_LineItemList = new List<MI_BNF_LineItem__c>(); 
          MI_BNF_LineItem__c MI_BNFLineItem;
          integer ProductCount=0;   
              
          for(String s : SelectProductList.split(','))
          {
            ProductCount++; 
            MI_BNFLineItem=new MI_BNF_LineItem__c();
            MI_BNFLineItem.MIBNF_Component__c=Comp.Id;
            MI_BNFLineItem.Opportunity_Line_Itemid__c=s;
            MI_BNFLineItem.Total_Price__c= oppAvailableProductsMap.get(s).TotalPrice;
            MI_BNFLineItem.CurrencyIsoCode=comp.CurrencyIsoCode;
            
            MI_BNF_LineItemList.add(MI_BNFLineItem);
          }
          SelectProductList=null;
          insert MI_BNF_LineItemList;
          ProductAdded=true;
          SuccessMsg= ProductCount + ' Products added to Invoice '+ Comp.name;
          
          
        
       }
       
       private Boolean AddBnf()
       {
         // Check for New MIBNF if it is new craete MIBNF otherwise create child BNF
           if(MIBNFID==null)
           {
               // Create the MIBNF. Before inserting, MIBNF_Comp
               MIBNF.Opportunity__c=opp.id;
              /* if(MIBNF.Sales_Org_Code__c != 'GB80' && opp.IQVIA_Ltd_GB80_Engagement__c && BNF_Settings__c.getInstance().Enable_IQVIA_BNF_Validation__c){
                   String message = 'If IQVIA Ltd GB80 Engagement flag is selected then user must only be able to select GB80 sales org';
                   ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
                   ApexPages.addMessage(errMsg);
                   return false;
               }*/
               //ESPSFDCQI-6899
               if(MIBNF.Sales_Org_Code__c != 'GB80' && opp.Multi_Country_Billing__c == 'IQVIA Ltd GB80 engagement' && BNF_Settings__c.getInstance().Enable_IQVIA_BNF_Validation__c){
                   String message = 'If IQVIA Ltd GB80 Engagement flag is selected then user must only be able to select GB80 sales org';
                   ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
                   ApexPages.addMessage(errMsg);
                   return false;
               }
               
               if(MIBNF.Sales_Org_Code__c != 'FR12' && opp.Multi_Country_Billing__c == 'IQVIA Operations France – FR12' && BNF_Settings__c.getInstance().Enable_IQVIA_BNF_Validation__c){
                   String message = 'If IQVIA Operations France – FR12 flag is selected then user must only be able to select FR12 sales org';
                   ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
                   ApexPages.addMessage(errMsg);
                   return false;
               }
                   insert MIBNF;
                   MIBNFID=MIBNF.Id;
           }
            
            try
            {
                if(BNFRevised==true)
                {
                        
                  MIBNF_Component__c MIBNF_Comp_Revised=new MIBNF_Component__c(); 
                  MIBNF_Comp_Revised.MIBNF__c=MIBNF_Comp.MIBNF__c;
                  MIBNF_Comp_Revised.BNF_Status__c='New';
                  MIBNF_Comp_Revised.Manual_Handling_in_SAP__c=MIBNF_Comp.Manual_Handling_in_SAP__c;
                  MIBNF_Comp_Revised.Billing_Frequency__c=MIBNF_Comp.Billing_Frequency__c;
                  MIBNF_Comp_Revised.Revised_BNF_Date__c=MIBNF_Comp.Revised_BNF_Date__c;
                  MIBNF_Comp_Revised.Payment_Terms__c=MIBNF_Comp.Payment_Terms__c;
                  MIBNF_Comp_Revised.Additional_Delivery_Date_Information__c=MIBNF_Comp.Additional_Delivery_Date_Information__c;
                  MIBNF_Comp_Revised.Addendum__c=true;
                  MIBNF_Comp_Revised.Revised_BNF_Reason__c=MIBNF_Comp.Revised_BNF_Reason__c;
                  MIBNF_Comp_Revised.Delivery_Date__c= MIBNF_Comp.Delivery_Date__c;
                  MIBNF_Comp_Revised.Client_PO_Number__c=MIBNF_Comp.Client_PO_Number__c;
                  MIBNF_Comp_Revised.Revised_BNF_Comment__c=MIBNF_Comp.Revised_BNF_Comment__c;
                  MIBNF_Comp_Revised.Invoice_Header_Text__c=MIBNF_Comp.Invoice_Header_Text__c;
                  MIBNF_Comp_Revised.Billing_Currency__c=MIBNF_Comp.Billing_Currency__c;
                  MIBNF_Comp_Revised.SAP_Contract__c=MIBNF_Comp.SAP_Contract__c ;
                  MIBNF_Comp_Revised.Additional_Billing_Date_Information__c=MIBNF_Comp.Additional_Billing_Date_Information__c;
                  MIBNF_Comp_Revised.Invoice_Default_Day__c=MIBNF_Comp.Invoice_Default_Day__c;
                  MIBNF_Comp_Revised.Is_this_a_retainer_downpayment__c=MIBNF_Comp.Is_this_a_retainer_downpayment__c;
                  MIBNF_Comp_Revised.Subscription_Type__c=MIBNF_Comp.Subscription_Type__c;
                  MIBNF_Comp_Revised.Retainer_Data_Value__c=MIBNF_Comp.Retainer_Data_Value__c;
                  MIBNF_Comp_Revised.Specification__c=MIBNF_Comp.Specification__c;
                  MIBNF_Comp_Revised.Description__c=MIBNF_Comp.Description__c;
                  MIBNF_Comp_Revised.Print_Shop__c=mibnf_comp.Print_Shop__c;
                  MIBNF_Comp_Revised.Travel_Amount__c =MIBNF_Comp.Travel_Amount__c;
                  MIBNF_Comp_Revised.Accomodation_Amount__c=MIBNF_Comp.Accomodation_Amount__c;
                  MIBNF_Comp_Revised.Sub_Contractor_Amount__c=MIBNF_Comp.Sub_Contractor_Amount__c;
                  MIBNF_Comp_Revised.Hono__c=MIBNF_Comp.Hono__c;
                  MIBNF_Comp_Revised.Pass_thru_schedules__c=MIBNF_Comp.Pass_thru_schedules__c;
                  MIBNF_Comp_Revised.Orignal_BNF__c=MIBNF_Comp.id;
                  MIBNF_Comp_Revised.X2nd_Copy__c = MIBNF_Comp.X2nd_Copy__c;
                  MIBNF_Comp_Revised.X2nd_Copy_SAP_Contact__c = MIBNF_Comp.X2nd_Copy_SAP_Contact__c;
                  MIBNF_Comp_Revised.Ship_To__c = MIBNF_Comp.Ship_To__c;
                  MIBNF_Comp_Revised.Ship_To_SAP_Contact__c = MIBNF_Comp.Ship_To_SAP_Contact__c;
                  MIBNF_Comp_Revised.Cover_Sheet__c = MIBNF_Comp.Cover_Sheet__c;
                  MIBNF_Comp_Revised.Cover_Sheet_SAP_Contact__c = MIBNF_Comp.Cover_Sheet_SAP_Contact__c;
                  MIBNF_Comp_Revised.Carbon_Copy__c = MIBNF_Comp.Carbon_Copy__c;
                  MIBNF_Comp_Revised.Bill_To__c = MIBNF_Comp.Bill_To__c;
                  MIBNF_Comp_Revised.Bill_To_SAP_Contact__c  = MIBNF_Comp.Bill_To_SAP_Contact__c ;
                  MIBNF_Comp_Revised.SAP_Master_Contract__c = MIBNF_Comp.SAP_Master_Contract__c;
                  MIBNF_Comp_Revised.Carbon_Copy_SAP_Contact__c=MIBNF_Comp.Carbon_Copy_SAP_Contact__c;
                  MIBNF_Comp_Revised.CurrencyIsoCode=MIBNF_Comp.CurrencyIsoCode;
                  MIBNF_Comp_Revised.BNF_Description__c = MIBNF_Comp.BNF_Description__c;

                  MIBNF_Comp_Revised.Sold_To__c = MIBNF_Comp.Sold_To__c;
                  MIBNF_Comp_Revised.Sold_To_SAP_Base_Code__c = MIBNF_Comp.Sold_To__r.SAP_Reference__c;
                 // Added By Ritesh Gupta - Issue 09951 - 
                  MIBNF_Comp_Revised.Project_Name__c = MIBNF_Comp.Project_Name__c;
                  // Added On 31 Jan 2017   Issue-10295           
                  MIBNF_Comp_Revised.Comments__c = MIBNF_Comp.Comments__c;          
                  insert MIBNF_Comp_Revised;
                  
                  List<MI_BNF_LineItem__c> RevisedCompList=new List<MI_BNF_LineItem__c>();
                  // Clone MIBNF Component from Orignal Component
                  for(MI_BNF_LineItem__c lineItem: [Select Total_Price__c, Opportunity_Line_Itemid__c,MIBNF_Component__c,CurrencyIsoCode From MI_BNF_LineItem__c where MIBNF_Component__c=:MIBNF_Comp.Id])
                  {
                        MI_BNF_LineItem__c MIBNF_LineItem_Revised=new MI_BNF_LineItem__c(); 
                        MIBNF_LineItem_Revised.Opportunity_Line_Itemid__c=lineItem.Opportunity_Line_Itemid__c;
                        MIBNF_LineItem_Revised.MIBNF_Component__c=MIBNF_Comp_Revised.Id;
                        MIBNF_LineItem_Revised.Total_Price__c=lineItem.Total_Price__c;
                        MIBNF_LineItem_Revised.CurrencyIsoCode=lineItem.CurrencyIsoCode;                        
                        RevisedCompList.add(MIBNF_LineItem_Revised);
                  }
                  
                  insert RevisedCompList;
                    
                    if(IsRevisedBNFWithDoc){
                        System.debug('IsRevisedBNFWithDoc, with Attachment. ++++++++++++++++++++++++');
                        List<Attachment> attachmentList = [Select Id, ContentType, Body, Name, ParentId From Attachment where ParentId =: MIBNF_Comp.id];
                        List<Attachment> attachmentList2 = new List<Attachment>();
                        
                        for(Attachment atc : attachmentList){
                            Attachment attTemp = new Attachment(Name =atc.Name, Body =atc.Body, ParentId = MIBNF_Comp_Revised.Id, ContentType =atc.ContentType);
                            attachmentList2.add(attTemp);            
                        }
                        if(attachmentList2.size() > 0)
                            insert attachmentList2;
                    }
					                   
                    
                }
                else
                {
                    if(ApexPages.currentPage().getParameters().get('id')!=null)
                        update MIBNF_Comp;
                    else
                    {
                         getMIBNF_Comp();
                        MIBNF_Comp.MIBNF__c=MIBNFID;
                        insert MIBNF_Comp;
                    
                        //Get Invoice Name to display on page
                        MIBNF_Component__c lstMIBNF_Comp=[select name from MIBNF_Component__c where id=:MIBNF_Comp.Id];
                        
                        if(SelectProductList!=null && SelectProductList!='')
                              AddInvoiceLineItem(lstMIBNF_Comp);
                        else
                        {
                            ProductAdded=true;
                            SuccessMsg= lstMIBNF_Comp.name + ' BNF has been created';
                        }
                       // MIBNF_Comp=null;
                        ShowPrevious=false;
                        getLineItemProduct();
                    }
                   
                }   
                        
                       
                return true;
                 
            }
            catch(Exception e)
            {
               //show a message on page
                 ErrorFlag = true;
                 ProductAdded=false;
                 ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Error while Adding BNF ' + e.getStackTraceString());
                 ApexPages.addMessage(errMsg); 
                 return false;
            }
       }
       @RemoteAction
       public static Revenue_Analyst__c updateRevenueAnalyst(String selectedSalesOrg) {
           List<Revenue_Analyst__c> revenueAnalyst2 = [SELECT Id, Name from Revenue_Analyst__c where Name = 'GFSS RA DE'];
           if(revenueAnalyst2.size() > 0 && (selectedSalesOrg == '[DE50] IQVIA Commercial GmbH & Co. OHG' || selectedSalesOrg == '[DE82] Kairos GmbH')){
               return revenueAnalyst2[0];
           }else{
               return null;
           }
       }
}