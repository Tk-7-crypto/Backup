public class MI_BNF_MDM_Extension {
    public MIBNF_Component__c MIBNF_Comp {get;set;}
    private ApexPages.StandardController StandardController;
    private ApexPages.StandardSetController AddressSetController;
    public Id BnfAccountId {get; private set;}
    private Id BnfOpportunityId;
    private Integer NumAddressRecordsPerPage;
    private Integer NumAddresses;
    private Boolean AddressSelectorRendered;    
    public String SalesOrg {get;set;}
    private Map<String,String> EntryUrlParams;
    public Boolean BnfLocked {get; private set;}
    private Boolean ManualBnfOverride;
    public Boolean ShowEditContractButton {get; private set;}
    public Boolean SapCodeSelectPanelRendered {get; private set;}
    public String SelectedSapCode {get;set;}
    public String AddressSearchName {get;set;}
    public String AddressSearchCity {get;set;}
    public String AddressSearchSapCode {get;set;}
    public Boolean AddressSearchRunOnce {get; private set;}
    public Integer NumAddressSearchResults {get; private set;}
    public String AddressSearchMFD {get;set;}
	public List<String> mfdValues = new List<String>();
    public Account ProxyAccount {get; set;}
    private ApexPages.StandardSetController AddressSearchSetController;
    private Boolean UserIsSysAdmin;
    private Set<String> excludedProducts;
     //Added by Himanshu Parashar Date : 7 Feb 2013
    public BNF_Settings__c bnfSetting; 
    public User U;
    private Boolean NewBnf;
  
    public boolean tempSold {get;set;}
    public boolean tempBill {get;set;}
    
    public Boolean recallbuttonview {get;set;}
    public Boolean unlockbuttonview {get;set;}
    public Boolean showlockbuttonview {get;set;}
    public Boolean showReassignbuttonview {get;set;}
    public Boolean showUploadSignedContractButton {get;set;}
    
    // updated by dheeraj kumar 20 April 2017
    public boolean isOwnerQueue {get;set;}
    //Constructor for MIBNF Component
    private boolean hasAccessBNFAll;
    public MI_BNF_MDM_Extension(ApexPages.StandardController controller)
    {
        // updated by dheeraj kumar 20 April 2017
   		this.isOwnerQueue = false;
        this.StandardController = controller;
        this.ManualBnfOverride = false;   
        this.SapCodeSelectPanelRendered = false;  
        this.AddressSearchRunOnce = false;
        this.ProxyAccount = new Account();
        this.NumAddressSearchResults = 0;
        this.AddressSearchName = '';
        this.AddressSearchCity = '';
        this.AddressSearchSapCode = '';
        this.AddressSearchMFD = '';
        this.NumAddressRecordsPerPage = 5;    
        this.tempSold = false;
        this.tempBill = false;           
        if (System.currentPageReference().getParameters().get('billing_sched')!=null)
            this.NewBnf = true;
        else
            this.NewBnf = false;
        bnfSetting =BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        this.hasAccessBNFAll = false;
        List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        if(permSetAssList.size() > 0) {
            hasAccessBNFAll = true; 
        }
        if ((Id)(controller.getRecord()).Id != null)
        {	
            // updated by dheeraj kumar 20 April 2017
            this.MIBNF_Comp = [select Id,MIBNF__r.Id,MIBNF__r.Opportunity__r.Id,MIBNF__r.Opportunity__r.Account.Id ,Bill_To_SAP_Contact__c,
                        Bill_To__c, Sold_To__c, Carbon_Copy__c,Cover_Sheet_SAP_Contact__c,Cover_Sheet__c,BNFName__c,Ship_To_SAP_Contact__c,Carbon_Copy_SAP_Contact__c,
                        Ship_To__c,X2nd_Copy_SAP_Contact__c,X2nd_Copy__c,Manual_Handling_In_Sap__c,MIBNF__r.MIBNF_Status__c,Sap_Contract__c,
                        MIBNF__r.Renewal__c,MIBNF__r.SAP_Master_Contract__c,MIBNF__r.Manual_Handling_In_Sap__c,BNF_Status__c,MIBNF__r.Revenue_Analyst__r.User__r.id,
                        MIBNF__r.Opportunity__r.Account.Name,MIBNF__r.Opportunity__r.Account.SAP_Reference__c,Name,
                        MIBNF__r.Opportunity__r.Account.Region_Territory__c,MIBNF__r.Sales_Org_code__c,MIBNF__r.Revenue_Analyst__c, Bill_To__r.PO_Required__c,Revised_BNF_Reason__c,
                        MIBNF__r.Opportunity__r.Opportunity_Number__c,MIBNF__r.Opportunity__r.Is_USBU_Opportunity__c,AR_Comments__c,Addendum__c, Comp_Revenue_Analyst__r.owner.type  from MIBNF_Component__c where Id = :(Id)(controller.getRecord()).Id];
            this.BnfAccountId = (Id)(this.MIBNF_Comp.MIBNF__r.Opportunity__r.AccountId);
            this.BnfOpportunityId = (Id)(this.MIBNF_Comp.MIBNF__r.Opportunity__r.Account.Id);
            
            //Update By Himanshu : 19 Aug 2013 : MIS issue-2636
            if(System.currentPageReference().getParameters().get('addressid')!=null && System.currentPageReference().getParameters().get('addressid')!='')
              this.MIBNF_Comp.Bill_To__c=System.currentPageReference().getParameters().get('addressid');
            if(System.currentPageReference().getParameters().get('sapaddressid')!=null && System.currentPageReference().getParameters().get('sapaddressid')!='')
              this.MIBNF_Comp.Bill_To_SAP_Contact__c=System.currentPageReference().getParameters().get('sapaddressid');
            if(System.currentPageReference().getParameters().get('lookup')!=null && System.currentPageReference().getParameters().get('lookup')=='false')
            {
              this.MIBNF_Comp.Bill_To__c=null;
              this.MIBNF_Comp.Bill_To_SAP_Contact__c=null;            
              
            }
            
            
            // updated by Dheeraj Kumar 19 April 2017
            if(this.MIBNF_Comp.Comp_Revenue_Analyst__r.Owner.Type == 'Queue') {
                this.isOwnerQueue = true;
            }
            
          setButtonVisiblity((Id)(controller.getRecord()).Id);
          setUploadSignedContractVisiblity(this.MIBNF_Comp);  
        }
           
            this.EntryUrlParams = new Map<String,String>(ApexPages.currentPage().getParameters());
             U = [select Id, Sales_Org__c,Profile.Name from User where Id = :UserInfo.getUserId()];
             if (Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',U.Profile.Name.toLowerCase()))
                UserIsSysAdmin=true;
            else
                UserIsSysAdmin=false;
            
            this.SalesOrg = U.Sales_Org__c;
            
             //  Flag used to determine whether button is shown which allows RA to edit the SAP contract numbers
            //  This button should only be shown if the person viewing the BNF is the person to whom it has been 
            //  assigned and the BNF is currently in an approval process OR if viewed by sys admin
            this.ShowEditContractButton = false;
            Id CurrentUserId = U.Id;
            if ((Id)(controller.getRecord()).Id != null)
            {
                    List<ProcessInstanceWorkitem> P = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.MIBNF_Comp.MIBNF__r.Id]);
                    if (P.size() > 0 && (this.MIBNF_Comp.MIBNF__r.Renewal__c == true ||this.MIBNF_Comp.MIBNF__r.SAP_Master_Contract__c != null ||this.MIBNF_Comp.MIBNF__r.Manual_Handling_In_Sap__c) &&
                            (CurrentUserId == P[0].ActorId  || Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',U.Profile.Name.toLowerCase())))
                    {
                            this.ShowEditContractButton = true;
                    }
                    this.ProxyAccount.Region_Territory__c = this.MIBNF_Comp.MIBNF__r.Opportunity__r.Account.Region_Territory__c;
            }
            this.BnfLocked = false;
            //  BEGIN DEBUG
            this.Debug = '';
            system.debug('User Profile: '+ Profile.Name);
        
        this.tempSold = this.MIBNF_Comp.Sold_To__c == null ? false : true ;
        this.tempBill = this.MIBNF_Comp.Bill_To__c == null ? false : true ;
        //  END DEBUG
    }
    
  
    // Block MIBNF_Page_Selector if MIBNF is sent for submit or there is no address available.
        
    public pageReference Initialise()
    {
       // commented for Issue-10275 30 Jan 2017
       /*if (MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') ||
        MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('REJECTED') ||
        MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_REJECTED') || 
        MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_REJECTED') ||
        MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED') ||
        MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_REJECTED') ||
        MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('NEW') ||
        UserIsSysAdmin == true)
        {

                Address__c[] Address_Array = [select Id from Address__c where Account__c = :this.BnfAccountId and Marked_For_Deletion__c = false AND Archived__c = false];
                this.NumAddresses = Address_Array.size();
                this.NumAddressRecordsPerPage = 5;//this.NumAddresses < 5 ? this.NumAddresses : 5;
                if ((Id)(this.StandardController.getRecord()).Id != null) 
                {
                    ProcessInstanceWorkitem[]  P = [select Id, ActorId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.MIBNF_Comp.MIBNF__r.Id];
                    if (P.size() > 0 && this.MIBNF_Comp.MIBNF__r.MIBNF_Status__c != MDM_Defines.BnfStatus_Map.get('NEW'))
                    {     
                        
                                  
                        if (P[0].ActorId != UserInfo.getUserId())
                        {
                        
                            this.AddressSelectorRendered = false;
                            this.BnfLocked = true;
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'BNF is currently submitted for approval and cannot be edited.');
                            ApexPages.addMessage(myMsg);
                           
                            return null;
                        }
                    }
                    if (this.MIBNF_Comp.MIBNF__r.MIBNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED'))
                    {
                        this.BnfLocked = true;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Contract/Order has been created in SAP and BNF cannot be edited.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
                if (this.NumAddresses > 0)
                {
                    this.AddressSelectorRendered = true;
                }
                else
                {
                    this.AddressSelectorRendered = false;        
                    //Date :: Date 3 Jan 2012 :: 
                    //Update by :: Himanshu Parashar       
                    //Using wizard now instead of Address
                    //pageReference NewAddressRequest = Page.RequestNewAddress;   
                    pageReference NewAddressRequest = Page.RequestNewAddresswizard;
                    NewAddressRequest.getParameters().put('compId',this.MIBNF_Comp.Id);
                    NewAddressRequest.getParameters().put('AccountId',this.BnfAccountId);
                    NewAddressRequest.getParameters().put('ApprovalRequest','true');
                    NewAddressRequest.getParameters().put('retURL','/'+this.MIBNF_Comp.Id);
                    NewAddressRequest.setRedirect(false);
                    return NewAddressRequest;
                }
        }
        else
        {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Address cannot be edited once the BNF has been submitted.');
             ApexPages.addMessage(myMsg);
        }
        
        return null;*/
        //updated  for Issue-10275 30 Jan 2017
        Address__c[] Address_Array = [select Id from Address__c where recordType.DeveloperName = 'MDM_Validated' and Account__c = :this.BnfAccountId and Marked_For_Deletion__c = false AND Archived__c = false];
      	this.NumAddresses = Address_Array.size();
        this.NumAddressRecordsPerPage = 5;//this.NumAddresses < 5 ? this.NumAddresses : 5;
       	if((Id)(this.StandardController.getRecord()).Id != null) {
               ProcessInstanceWorkitem[]  P = [select Id, ActorId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.MIBNF_Comp.Id];
               if(P.size() > 0 && this.MIBNF_Comp.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('NEW') && !UserIsSysAdmin && !hasAccessBNFAll) {
                    set<ID> ActorIdset=new set<ID>();
        			for (ProcessInstanceWorkitem P2 : P) {
          				ActorIdset.add(P2.ActorId);
        			}
        			if(ActorIdset.size() > 0) {
            			for(User DelegateApproverUser :[select DelegatedApproverId from User where Id in : ActorIdset]) {
                			if(DelegateApproverUser.DelegatedApproverId!=null)
                    			ActorIdset.add(DelegateApproverUser.DelegatedApproverId);
            			}
       				}     
                    if(ActorIdset!=null && !ActorIdset.contains(UserInfo.getUserId()))
                    {
                    
                        this.AddressSelectorRendered = false;
                        this.BnfLocked = true;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Address cannot be edited once the BNF has been submitted.');
                        ApexPages.addMessage(myMsg);
                       
                        return null;
                    }
                }
                if (this.MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED')) {
                	this.BnfLocked = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'BNF has been created in SAP and Address cannot be edited.');
                    ApexPages.addMessage(myMsg);
                    return null;
                 }
            }
            if (this.NumAddresses > 0)
            {
                this.AddressSelectorRendered = true;
            }
        	else {
                this.AddressSelectorRendered = false;        
                pageReference NewAddressRequest = Page.RequestNewAddresswizard;
                NewAddressRequest.getParameters().put('compId',this.MIBNF_Comp.Id);
                NewAddressRequest.getParameters().put('AccountId',this.BnfAccountId);
                NewAddressRequest.getParameters().put('ApprovalRequest','true');
                NewAddressRequest.getParameters().put('retURL','/'+this.MIBNF_Comp.Id);
                NewAddressRequest.setRedirect(false);
                return NewAddressRequest;
            }
        return null;
    }
    
     public ApexPages.StandardSetController getAddressSetController() 
    {       
        if(this.AddressSetController== null)
        {
            //  BEGIN DEBUG
            this.Debug += 'calling getAddressSetController(), AccountId: '+ this.BnfAccountId;
            Address__c[] Address_Array = [select Id, Name, Account__c, Street__c, City__c, State__c, Country__c from Address__c where recordType.DeveloperName = 'MDM_Validated' and Account__c = :this.BnfAccountId and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc];
            
            this.Debug += '  SOQL array size: ' + Address_Array.size().format();
            //  END DEBUG
            this.AddressSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,Marked_For_Deletion__c from Address__c where recordType.DeveloperName = 'MDM_Validated' and Account__c = :this.BnfAccountId and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc]));
             
            this.AddressSetController.setPageSize(this.NumAddressRecordsPerPage);   
            //  BEGIN DEBUG
            this.Debug += ' num addresses:  ' + this.AddressSetController.getResultSize().format();
            this.Debug += '  SOQL: select Id, Name, Account__c, Street__c, City__c, State__c, Country__c from Address__c where recordType.DeveloperName = \'MDM_Validated\' and  Account__c = ' +this.BnfAccountId + ' order by Name desc  ';
            //  END DEBUG
        }
        
     
        return this.AddressSetController;
    }
    
    
    
    // Save Method
    public PageReference Save()
    {   
        if (fetchValidId(this.MIBNF_Comp.Bill_To__c)== null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Bill To address');
            ApexPages.addMessage(myMsg);
            return null;
        }
       
        if (fetchValidId(this.MIBNF_Comp.Ship_To__c) == null)
        {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Ship To address');
            ApexPages.addMessage(myMsg);
            return null;
        } 
 
        this.MIBNF_Comp.Bill_To_SAP_Contact__c=fetchValidId(MIBNF_Comp.Bill_To_SAP_Contact__c + '');
        this.MIBNF_Comp.Ship_To_SAP_Contact__c = fetchValidId(MIBNF_Comp.Ship_To_SAP_Contact__c + '');
        this.MIBNF_Comp.X2nd_Copy_SAP_Contact__c = fetchValidId(MIBNF_Comp.X2nd_Copy_SAP_Contact__c + '');
        this.MIBNF_Comp.Cover_Sheet_SAP_Contact__c =fetchValidId(MIBNF_Comp.Cover_Sheet_SAP_Contact__c + '');
        this.MIBNF_Comp.Carbon_Copy_SAP_Contact__c=fetchValidId(MIBNF_Comp.Carbon_Copy_SAP_Contact__c  + '');
        
       
        try
        {
            update this.MIBNF_Comp;
        }
        catch (Exception E)
        {
            return null;
        }
        
        PageReference retURL; 
        if(ApexPages.currentPage().getParameters().get('wz')=='1')
        {
            //retURL = new PageReference('/apex/MI_BNFOpptyList' + '?wz=1&oppid=' + this.MIBNF_Comp.MIBNF__r.Opportunity__c + '&mibnf=' + this.MIBNF_Comp.MIBNF__r.Id + '&compid=' + this.MIBNF_Comp.id );
            retURL = new PageReference('/apex/MI_BNFOpptyListLockedGrid' + '?wz=1&oppid=' + this.MIBNF_Comp.MIBNF__r.Opportunity__c + '&mibnf=' + this.MIBNF_Comp.MIBNF__r.Id + '&compid=' + this.MIBNF_Comp.id);
            if (this.NewBnf)
                retURL.getParameters().put('newbnf','true');
            //  If opp is below the threshold, direct to "old" page
            if(BNF_Settings__c.getInstance().BNF_Opportunity_Threshold__c != null) 
            {
            	try {
                    if(Integer.valueOf(this.MIBNF_Comp.MIBNF__r.Opportunity__r.Opportunity_Number__c) < BNF_Settings__c.getInstance().BNF_Opportunity_Threshold__c)                
	                    retURL = new PageReference('/apex/MI_BNFOpptyListLockedGridOld' + '?wz=1&oppid=' + this.MIBNF_Comp.MIBNF__r.Opportunity__c + '&mibnf=' + this.MIBNF_Comp.MIBNF__r.Id + '&compid=' + this.MIBNF_Comp.id );
            	} catch(Exception exp) {
            	    retURL = new PageReference('/apex/MI_BNFOpptyListLockedGridOld' + '?wz=1&oppid=' + this.MIBNF_Comp.MIBNF__r.Opportunity__c + '&mibnf=' + this.MIBNF_Comp.MIBNF__r.Id + '&compid=' + this.MIBNF_Comp.id );
            	} 
            } 
        }
        else if(ApexPages.currentPage().getParameters().get('retURL')!=null)
        {
             retURL = new PageReference('/' + ApexPages.currentPage().getParameters().get('retURL'));
        }
        else
        {
            retURL = new PageReference('/apex/MI_BNF_View?id=' + this.MIBNF_Comp.MIBNF__r.Id);
            if(this.MIBNF_Comp.Id!=null && ApexPages.currentPage().getParameters().get('editbnf')!=null)
                                 retURL.setAnchor('lnk' + this.MIBNF_Comp.Id);
        }

        retURL.setRedirect(true);
        return retURL;
    }
    
    public PageReference Cancel()
    {
         PageReference retURL;
        if(ApexPages.currentPage().getParameters().get('retURL')!=null)
        {
             retURL = new PageReference('/' + ApexPages.currentPage().getParameters().get('retURL'));
        }
        else
        {
             retURL = new PageReference('/apex/MI_BNF_View?id=' + this.MIBNF_Comp.MIBNF__r.Id);
             if(ApexPages.currentPage().getParameters().get('editbnf')!=null)
                retURL.setAnchor('lnk' + MIBNF_Comp.Id);
        }
         
        retURL.setRedirect(true);
        return retURL;
    }
    
    public List<SelectOption> getmfdValues() {
        List<SelectOption> options = new List<SelectOption>();
       // options.add(new SelectOption('null','--None--'));
        options.add(new SelectOption('Excluding Marked For Deletions','Excluding Marked For Deletions'));
        options.add(new SelectOption('Including Marked For Deletions','Including Marked For Deletions'));
        return options;
    }    
    
    public List<Address__c> getAccountAddresses() 
    {
        if (this.getAddressSetController() == null)
        {
            //  BEGIN DEBUG
            this.Debug += '  getAccountAddresses returning null  ';
            //  END DEBUG
            return null;
        }
        return (List<Address__c>) this.getAddressSetController().getRecords();
    }
    
    public List<SelectOption> getAddressContacts(String AddressId)
    {
        List<SelectOption> optionList = new List<SelectOption>();
        
        if (AddressId != null && AddressId != '')
        {          
            for (SAP_Contact__c C : [select Id, Name, First_Name__c, Last_Name__c  from SAP_Contact__c where Address__c = :AddressId and Marked_For_Deletion__c = false AND Address__r.Archived__c = false and RecordType.name='MDM Validated' order by Last_Name__c asc, First_Name__c asc])
            {
                optionList.add(new SelectOption(C.Id,C.Name));
            }
            if (optionList.size() == 0)
            {
                optionList.add(new SelectOption('','NA',false));
            }
            else (optionList.add(0, new SelectOption('','No Contact Selected',false)));
        }
        return optionList;
    }
    
    public List<SelectOption> getBillToContacts()
    {
       return getAddressContacts((String)this.MIBNF_Comp.Bill_To__c);
    }
    
    public List<SelectOption> getShipToContacts()
    {
        return getAddressContacts((String)this.MIBNF_Comp.Ship_To__c);
    }
    
    public List<SelectOption> getSecondCopyContacts()
    {
        return getAddressContacts((String)this.MIBNF_Comp.X2nd_Copy__c);
    }
    
    public List<SelectOption> getCarbonCopyContacts()
    {
        return getAddressContacts((String)this.MIBNF_Comp.Carbon_Copy__c);
    }
    
    public List<SelectOption> getCoverSheetContacts()
    {
        return getAddressContacts((String)this.MIBNF_Comp.Cover_Sheet__c);
    }
    
    public void NextAddressPage()
    {
        this.getAddressSetController().next();
    }
    
    public void PrevAddressPage()
    {
        this.getAddressSetController().previous();
    }
    
    public Boolean getMoreNextAddressesAvailable()
    {
        return this.AddressSetController.getHasNext();
    }
    
    public Boolean getMorePrevAddressesAvailable()
    {
        return this.AddressSetController.getHasPrevious();
    }
    
    public Boolean getAddressSelectorRendered()
    {
        return this.AddressSelectorRendered;
    }
    
    public Address__c getAddressDetails(String AddressId) 
    {
        Address__c Address = new Address__c();
        if (AddressId != null && AddressId != '')
        {          
            Address = [select Id, Name, Account__c, Street__c, City__c, State__c,PostalCode__c, Country__c  from Address__c where id = :AddressId];
            
        }
       return Address;
    }

    public Address__c getBillToAddressDetails()
    {
        return getAddressDetails((String)this.MIBNF_Comp.Bill_To__c);
    }
    
    public Address__c getShipToAddressDetails()
    {
        return getAddressDetails((String)this.MIBNF_Comp.Ship_To__c);
    }
    
    public Address__c getSecondCopyAddressDetails()
    {
        return getAddressDetails((String)this.MIBNF_Comp.X2nd_Copy__c);
    }
    
    public Address__c getCoverSheetAddressDetails()
    {
        return getAddressDetails((String)this.MIBNF_Comp.Cover_Sheet__c);
    }
    
    public Address__c getCarbonCopyAddressDetails()
    {
        return getAddressDetails((String)this.MIBNF_Comp.Carbon_Copy__c);
    }
     
    public Address__c getSoldToAddressDetails()
    {
        return getAddressDetails((String)this.MIBNF_Comp.Sold_To__c);
    }    
        
    
    public void DoNothing()
    {
        //  BEGIN DEBUG
        //this.Debug += '  Bill_To__c: ' + this.MIBNF_Comp.Bill_To__c;
        //  END DEBUG
    }
    
    public Integer getNumAddressRecordsPerPage()
    {
        return this.NumAddressRecordsPerPage;
    }
    
    //  BEGIN DEBUG functions
    public String getBnfId()
    {
        return this.MIBNF_Comp.Id;
    }
    
    public String getBnfAccountId()
    {
        return this.BnfAccountId;
    }
    
    public String Debug {get;set;}
    //  END DEBUG functions
    
    public Id fetchValidId(String ContactId)
    {
    
        Id retId=null;
        
        try {
           retId = ContactId;
        } catch(Exception ex) {
        
           System.debug('excetpion' + ex.getMessage() );
   
          
        }
        return retId;
     
    }
    
  
    
    
    public void SearchAddressByName()
    {
        this.AddressSearchName = this.AddressSearchName.trim();         
                this.AddressSearchSetController = null;
                this.AddressSearchRunOnce = true;
                this.getAddressSearchSetController();           
        //  BEGIN DEBUG
        this.Debug += ' calling SearchAddressByName() ';
        this.Debug += '  AddressSearchName: ' + this.AddressSearchName;
        //  END DEBUG    
    }
    
    
     public ApexPages.StandardSetController getAddressSearchSetController() 
    {       
        if(this.AddressSearchSetController == null)
        {
            String SearchTerm = this.AddressSearchName;
            if (AddressSearchRunOnce == false)
            {
                SearchTerm = 'XXXXadfl;kjad;fljads;flj';
            }
            //  BEGIN DEBUG
            //this.Debug += '  calling getAddressSearchSetController() ';
            //Address__c[] Address_Array = [select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c from Address__c where Country__c = :this.ProxyAccount.Region_Territory__c and Name like :('%'+SearchTerm+'%') and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc limit 500];
            //this.Debug += ' Search SOQL array size: ' + Address_Array.size().format();
            //this.Debug += ' Search Query: ' + '[select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c from Address__c where Country__c like :("%"'+this.ProxyAccount.Region_Territory__c + '"%") and Name like :("%"'+SearchTerm+'"%") order by Name desc]';
            //  END DEBUG
            if(this.AddressSearchMFD == 'Excluding Marked For Deletions'){
                if (this.ProxyAccount.Region_Territory__c == null)
                {
                    this.AddressSearchSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,Marked_For_Deletion__c from Address__c where recordType.DeveloperName = 'MDM_Validated' and Name like :('%'+SearchTerm+'%') and City__c like :('%'+this.AddressSearchCity.trim()+'%') and SAP_Reference__c like :('%'+this.AddressSearchSapCode.trim()+'%') and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc limit 400]));
                }
                else
                {
                    this.AddressSearchSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,Marked_For_Deletion__c from Address__c where recordType.DeveloperName = 'MDM_Validated' and Country__c =:this.ProxyAccount.Region_Territory__c and Name like :('%'+SearchTerm+'%') and City__c like :('%'+this.AddressSearchCity.trim()+'%') and SAP_Reference__c like :('%'+this.AddressSearchSapCode.trim()+'%') and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc limit 400]));
                }
            }
            else
            {
                if (this.ProxyAccount.Region_Territory__c == null)
                {
                    this.AddressSearchSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,Marked_For_Deletion__c from Address__c where recordType.DeveloperName = 'MDM_Validated' and Archived__c = false and Name like :('%'+SearchTerm+'%') and City__c like :('%'+this.AddressSearchCity.trim()+'%') and SAP_Reference__c like :('%'+this.AddressSearchSapCode.trim()+'%') order by Name asc limit 400]));
                }
                else
                {
                    this.AddressSearchSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,Marked_For_Deletion__c from Address__c where recordType.DeveloperName = 'MDM_Validated' and Archived__c = false and Country__c =:this.ProxyAccount.Region_Territory__c and Name like :('%'+SearchTerm+'%') and City__c like :('%'+this.AddressSearchCity.trim()+'%') and SAP_Reference__c like :('%'+this.AddressSearchSapCode.trim()+'%') order by Name asc limit 400]));
                }                
            }
            this.AddressSearchSetController.setPageSize(this.NumAddressRecordsPerPage);   
            //  BEGIN DEBUG
            this.Debug += ' num search addresses:  ' + this.AddressSearchSetController.getResultSize().format();
            //  END DEBUG
            this.NumAddressSearchResults = this.AddressSearchSetController.getResultSize();
        }
        return this.AddressSearchSetController;
    }
    
     public List<Address__c> getSearchAddresses() 
    {
        if (this.getAddressSearchSetController() == null)
        {
            //  BEGIN DEBUG
            this.Debug += '  getSearchAddresses returning null  ';
            //  END DEBUG
            return null;
        }
        return (List<Address__c>) this.getAddressSearchSetController().getRecords();
    }
    
    public void NextAddressSearchPage()
    {
        this.getAddressSearchSetController().next();
    }
    
    public void PrevAddressSearchPage()
    {
        this.getAddressSearchSetController().previous();
    }
    
    public Boolean getMoreNextAddressSearchAvailable()
    {
        return this.AddressSearchSetController.getHasNext();
    }
    
    public Boolean getMorePrevAddressSearchAvailable()
    {
        return this.AddressSearchSetController.getHasPrevious();
    }
    
     public void ShowSapCodeSelectionPanel()
    {
         this.SapCodeSelectPanelRendered = true; 
    } 
    
    public void HideSapCodeSelectionPanel()
    {
         this.SapCodeSelectPanelRendered = false; 
    } 
    //Added Date : 13 Feb 2013
     public void ShowInfoMessages()
    {
        //Added by Himanshu parashar : 12 dec 2012 : When BNF Status is Accepted, Info Message only display to assigned user
        
            ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.MIBNF_Comp.Id];        

        
            if(bnfSetting.Enable_Customer_Validation__c==true)   
            {
                    Set<Id> AddressId_Set = new Set<Id>{this.MIBNF_Comp.Bill_To__c,this.MIBNF_Comp.Ship_To__c,this.MIBNF_Comp.Cover_Sheet__c,this.MIBNF_Comp.X2nd_Copy__c,this.MIBNF_Comp.Carbon_Copy__c};
                    Map<Id,String> Address_Map = new Map<Id,String>();
                    Address_Map.put(this.MIBNF_Comp.X2nd_Copy__c,'2nd Copy');
                    Address_Map.put(this.MIBNF_Comp.Carbon_Copy__c,'Carbon Copy');
                    Address_Map.put(this.MIBNF_Comp.Bill_To__c,'Bill To');
                    Address_Map.put(this.MIBNF_Comp.Ship_To__c,'Ship To');
                    Address_Map.put(this.MIBNF_Comp.Cover_Sheet__c,'Cover Sheet');
                    List<Address__c> Address_List = new List<Address__c>([select Id,Name,SAP_Reference__c,Enabled_Sales_Orgs__c from Address__c where Id in :AddressId_Set and Id != null]);
                    
                     //Updated by Himanshu Parashar Date : 7 Feb 2013 : BNF_Settings__c Check
                    if(bnfSetting.Enable_Customer_Validation__c==true )
                    {
                        for (Address__c A:Address_List)
                        {                           
                             Set<String> setAddressSalesOrgs = new Set<String>();
                             if(A.Enabled_Sales_Orgs__c!=null)
                             {
                                     List<String> AddressSalesOrgs= A.Enabled_Sales_Orgs__c.split(':'); 
                                     setAddressSalesOrgs.addAll(AddressSalesOrgs);
                             }                             
                            if (A.Enabled_Sales_Orgs__c==null || (setAddressSalesOrgs.size()>0 && setAddressSalesOrgs.contains(this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c) == false))
                            {
                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Address_Map.get(A.Id) + ': ' + A.Name + ' (SAP Code: '+ A.SAP_Reference__c + ') is not enabled for ' + this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c);
                                        ApexPages.addMessage(myMsg);                    
                            }
                        }
                    }                       
                }
                
            if(bnfSetting.Enable_Material_Validation__c==true)
            {
                set<Id> JoOppLineItemidSet = new set<Id>();
                
                for (MI_BNF_LineItem__c master :[Select Opportunity_Line_Itemid__c From MI_BNF_LineItem__c where MIBNF_Component__c=: this.MIBNF_Comp.id])
                {
                    JoOppLineItemidSet.add(master.Opportunity_Line_Itemid__c);
                }
             
                for (OpportunityLineItem OLI :[Select Id,PricebookEntry.Product2.Enabled_Sales_Orgs__c,TotalPrice ,PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.ProductCode
                                                      From OpportunityLineItem where id in:JoOppLineItemidSet AND Product_Material_Type__c NOT IN :excludedProducts])
                {
                    Set<String> setProductSalesOrgs = new Set<String>();
                    if(OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c!=null)
                    {
                        List<String> ProductSalesOrgs= OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c.split(':'); 
                        setProductSalesOrgs.addAll(ProductSalesOrgs);
                       
                    }
                    //Updated by Himanshu Parashar Date : 7 Feb 2013 : BNF_Settings__c Check
                    if((OLI.TotalPrice!=null && OLI.TotalPrice > 0) && (OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c==null || (setProductSalesOrgs.size()>0 && (!setProductSalesOrgs.contains(this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c)))))
                    {
                       ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.INFO,'Product '+OLI.PricebookEntry.Product2.ProductCode+' is not enabled for sales org '+ this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c + '. Please contact your local Finance representative to resolve this before submitting the BNF.');
                        ApexPages.addMessage(myMsg1);  
                     }
                }
            }
    }
    
      // Update By Himanshu : 19-Aug-2013 : Use on OLI_Address_selector page
      // used by the visualforce page to send the link to the right dom element
      public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
      }
     
      // used by the visualforce page to send the link to the right dom element for the text box
      public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
      }
      
      // used by the visualforce page to send the link to the right dom element for the text box
      public string getAddressID() {
        return System.currentPageReference().getParameters().get('addressid');
      }
      
       // used by the visualforce page to send the link to the right dom element for the text box
      public string getSAPContactName() {
        return System.currentPageReference().getParameters().get('sapaddressname');
      }
      
       // used by the visualforce page to send the link to the right dom element for the text box
      public string getAddressName() {
        return System.currentPageReference().getParameters().get('addressname');
      } 
	  
    /**
     * method used to Hide and Show Recall Approval Request and Unlock Record Button
     * @params : Id recordId
     */
      public void setButtonVisiblity(Id recordId){
          
        Boolean isLocked = Approval.isLocked(recordId);
        unlockbuttonview = false;
        showlockbuttonview = false;
        List<PermissionSetAssignment> hasPermission = [SELECT id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        List<ProcessInstanceWorkitem> approvalpending = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.Status FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recordId];
        recallbuttonview = false;
        if(approvalpending.size() > 0 && hasPermission.size() > 0){
            recallbuttonview = true;
        }
        if(approvalpending.size() > 0 && hasPermission.size() > 0 && this.MIBNF_Comp.BNF_Status__c=='Submitted'){
            showReassignbuttonview = true;
        }
        if(isLocked && hasPermission.size() > 0 && this.MIBNF_Comp.BNF_Status__c =='Submitted'){
            unlockbuttonview = true;
        }
        if(isLocked == false && approvalpending.size() > 0 && hasPermission.size() > 0 && this.MIBNF_Comp.BNF_Status__c=='Submitted'){
            showlockbuttonview = true;
        }
    }
    
    /**
     * method used to Hide and Show Upload Signed Contract Button 
     * @params : Id recordId
     */
    public void setUploadSignedContractVisiblity(MIBNF_Component__c mibnfComp){
	    showUploadSignedContractButton = false;
        Boolean isUSBUOpp = mibnfComp.MIBNF__r.Opportunity__r.Is_USBU_Opportunity__c;
        CLM_Configuration__c clmConfiguration = CLM_Configuration__c.getInstance();
        Boolean enableAgreementRepository = clmConfiguration.Enable_Agreement_Repository__c;
        if(isUSBUOpp && enableAgreementRepository && mibnfComp.Addendum__c && mibnfComp.Revised_BNF_Reason__c == 'Change Order/Amendment' && String.isBlank(mibnfComp.AR_Comments__c)){
            showUploadSignedContractButton = true;
        }
    }
}