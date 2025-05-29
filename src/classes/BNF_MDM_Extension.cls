public without sharing class BNF_MDM_Extension {
    
    public BNF2__c BNF {get;set;}
    private ApexPages.StandardController StandardController;
    private ApexPages.StandardSetController AddressSetController;
    public Id BnfAccountId {get; private set;}
    private Id BnfOpportunityId;
    private Integer NumAddressRecordsPerPage;
    private Integer NumAddresses;
    private Boolean AddressSelectorRendered;    
    public String SalesOrg {get;set;}
    public Boolean IsLocalLanguage {get;set;}
    private Map<String,String> EntryUrlParams;
    public Boolean BnfLocked {get; private set;}
    private Boolean ManualBnfOverride;
    public Boolean ShowEditContractButton {get; private set;}
    public Boolean SapCodeSelectPanelRendered {get; private set;}
    public String SelectedSapCode {get;set;}
    public String AddressSearchSapCode {get;set;}
    public String AddressSearchMFD {get;set;}
    public List<String> mfdValues = new List<String>();
    public String AddressSearchName {get;set;}
    public String AddressSearchCity {get;set;}
    public String orgDomainURL{get;private set;}
    //public List<Address__c> SearchAddress_Array {get; private set;}
    public Boolean AddressSearchRunOnce {get; private set;}
    public Integer NumAddressSearchResults {get; private set;}
    public Account ProxyAccount {get; set;}
    private ApexPages.StandardSetController AddressSearchSetController;
    //Quick Opp
    //Update by Himanshu Parashar : 22 sep 2011
    private Boolean isQuickOpp;  
    public String UserCountry {get; private set;}
    public User U; //Update by Himanshu Parashar : 13 dec 2012
    public BNF_Settings__c bnfSetting;
    
    public Boolean showPOMandatoryMsg;
    public boolean tempSold {get;set;}
    public boolean tempBill {get;set;}
    // updated by dheeraj kumar 19 April 2017
    public boolean isOwnerQueue {get;set;}
    private Boolean hasAccessBNFAll;
    private Map<String, String> fieldApiToIdmap;
    
    public String fullURLString {get; private set;} 
    
    private Set<Id> ApproverId_Set{get;private set;} //Added by Himanshu Parashar Date : 24 May 2013
    
    private Set<String> excludedProducts;
    public boolean IsError {get;set;}
    public String errorMsgLabel {get;set;}
    public Id OppId {get;set;}
    
    public Boolean recallbuttonview {get;set;}
    public Boolean unlockbuttonview {get;set;}
    public Boolean showlockbuttonview {get;set;}
    public Boolean showReassignbuttonview {get;set;}
    public Boolean showUploadSignedContractButton {get;set;}
    
    public BNF_MDM_Extension(ApexPages.StandardController controller)
    {
        User_Permissions__c userPermission = User_Permissions__c.getInstance();
        IsLocalLanguage = userPermission.Is_Local_Language__c;
        //  this.BNF = (BNF2__c)controller.getRecord();
        system.debug('** ****');
        orgDomainURL = URL.getOrgDomainUrl().toExternalForm();
        this.fieldApiToIdmap = UTL_Sobject.getCustomFieldByIds('BNF2');
        system.debug('** utl - fieldApiToIdmap' + fieldApiToIdmap);
        this.isOwnerQueue = false;
        this.hasAccessBNFAll = false;
        List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        if(permSetAssList.size() > 0) {
            hasAccessBNFAll = true; 
        }
        this.StandardController = controller;
        this.ManualBnfOverride = false;   
        this.showPOMandatoryMsg = false;
        this.SapCodeSelectPanelRendered = false;  
        //  this.SapCodeSelectedAddress_Array = new List<Address__c>();
        this.AddressSearchRunOnce = false;
        this.ProxyAccount = new Account();
        this.NumAddressSearchResults = 0;
        this.AddressSearchSapCode = '';
        this.AddressSearchMFD = '';
        this.AddressSearchName = '';
        this.AddressSearchCity = '';
        
        tempSold = false;
        tempBill = false;
        
        bnfSetting =BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        
        if ((Id)(controller.getRecord()).Id != null)
        {
            // updated by Dheeraj Kumar 19 April 2017
            this.BNF = [select Id,Opportunity__r.Id, Opportunity__r.AccountId,Bill_To_SAP_Contact__c,Revenue_Analyst__r.User__r.Id,Carbon_Copy_SAP_Contact__c, //Carbon_Copy_SAP_Contact__c - add by Ghanshyam  - Issue-06350
                        Bill_To__c,Carbon_Copy__c,Cover_Sheet_SAP_Contact__c,Cover_Sheet__c,
                        Ship_To_SAP_Contact__c,Ship_To__c, Sold_To__c, X2nd_Copy_SAP_Contact__c,
                        X2nd_Copy__c,X2nd_Address__c,BNF_Status__c,Manual_Handling_In_Sap__c,
                        RecordTypeId,Sap_Contract__c,Sap_Master_Contract__c,
                        Opportunity__r.Account.Name,Opportunity__r.Account.SAP_Reference__c,Name,Addendum_Reasons__c,
                        Opportunity__r.Account.Region_Territory__c,Opportunity__r.Is_USBU_Opportunity__c,AR_Comments__c,Addendum__c,Renewal__c,Sales_Org_Code__c, Bill_To__r.PO_Required__c,Opportunity__r.Opportunity_Number__c, Revenue_Analyst__r.Owner.Type from BNF2__c where Id = :(Id)(controller.getRecord()).Id];
            this.BnfAccountId = (Id)(this.BNF.Opportunity__r.AccountId);
            this.BnfOpportunityId = (Id)(this.BNF.Opportunity__r.Id);
            
            
            //Added By Himanshu : 1 Aug 2013 : Issue-01265
            if(System.currentPageReference().getParameters().get('addressid')!=null && System.currentPageReference().getParameters().get('addressid')!='')
                this.BNF.Bill_To__c=System.currentPageReference().getParameters().get('addressid');
            if(System.currentPageReference().getParameters().get('sapaddressid')!=null && System.currentPageReference().getParameters().get('sapaddressid')!='')
                this.BNF.Bill_To_SAP_Contact__c=System.currentPageReference().getParameters().get('sapaddressid');
            if(System.currentPageReference().getParameters().get('lookup')!=null && System.currentPageReference().getParameters().get('lookup')=='false')
            {
                this.BNF.Bill_To__c=null;
                this.BNF.Bill_To_SAP_Contact__c=null;            
                
            }
            
            if(BNF.Bill_To__r.PO_Required__c)
                showPOMandatoryMsg = BNF.Bill_To__r.PO_Required__c;
            
            // updated by Dheeraj Kumar 19 April 2017
            if(this.BNF.Revenue_Analyst__r.Owner.Type == 'Queue') {
                this.isOwnerQueue = true;
            }
                
          setButtonVisiblity((Id)(controller.getRecord()).Id);
          setUploadSignedContractVisiblity(this.BNF);
        }
        else
        {
            this.BnfAccountId = ApexPages.currentPage().getParameters().get('AccountId');
            if (ApexPages.currentPage().getParameters().get('AccountId')!= null)
            {
                this.ProxyAccount = [select Id,Name,Region_Territory__c from Account where Id = :this.BnfAccountId];
            }
            if (ApexPages.currentPage().getParameters().get('newid') != null)
            {
                this.BNF = [select Id,Opportunity__r.Id, Opportunity__r.AccountId,Bill_To_SAP_Contact__c,Revenue_Analyst__r.User__r.Id,Carbon_Copy_SAP_Contact__c, //Carbon_Copy_SAP_Contact__c - add by Ghanshyam  - Issue-06350
                            Bill_To__c,Carbon_Copy__c,Cover_Sheet_SAP_Contact__c,Cover_Sheet__c,
                            Ship_To_SAP_Contact__c,Ship_To__c, Sold_To__c, X2nd_Copy_SAP_Contact__c,
                            X2nd_Copy__c,X2nd_Address__c,BNF_Status__c,Manual_Handling_In_Sap__c,
                            RecordTypeId,Sap_Contract__c,Sap_Master_Contract__c,
                            Opportunity__r.Account.Name, Opportunity__r.Account.SAP_Reference__c,Name,Addendum_Reasons__c,
                            Opportunity__r.Account.Region_Territory__c,Opportunity__r.Is_USBU_Opportunity__c,AR_Comments__c,Addendum__c,Renewal__c,Sales_Org_Code__c, Bill_To__r.PO_Required__c,Opportunity__r.Opportunity_Number__c from BNF2__c where Id = :ApexPages.currentPage().getParameters().get('newid')];
                this.BnfAccountId = (Id)(this.BNF.Opportunity__r.AccountId);
                this.BnfOpportunityId = (Id)(this.BNF.Opportunity__r.Id);
                
                
                //Added By Himanshu : 1 Aug 2013 : 
                if(System.currentPageReference().getParameters().get('addressid')!=null && System.currentPageReference().getParameters().get('addressid')!='')
                    this.BNF.Bill_To__c=System.currentPageReference().getParameters().get('addressid');
                if(System.currentPageReference().getParameters().get('sapaddressid')!=null && System.currentPageReference().getParameters().get('sapaddressid')!='')
                    this.BNF.Bill_To_SAP_Contact__c=System.currentPageReference().getParameters().get('sapaddressid');
                if(System.currentPageReference().getParameters().get('lookup')!=null && System.currentPageReference().getParameters().get('lookup')=='false')
                {
                    this.BNF.Bill_To__c=null;
                    this.BNF.Bill_To_SAP_Contact__c=null;           
                    
                }
                
            }
            else if (ApexPages.currentPage().getParameters().get('OpportunityId') != null)
            {
                this.BnfOpportunityId = ApexPages.currentPage().getParameters().get('OpportunityId');
            }
        }
        
        // updated by GS
        tempSold = this.BNF.Sold_To__c==null ? false : true ;
        tempBill = this.BNF.Bill_To__c==null ? false : true ;
        
        //Quick Opp
        //Update by Himanshu Parashar : 22 sep 2011
        // Checking for quick opportunity
        String quickOppRecordtypeID;
        String OppRecordType;
        for(RecordType recordtypeId : [SELECT Id FROM RecordType where Name Like 'Quick Opportunity' limit 1])
        {
            quickOppRecordtypeID = recordtypeId.Id;
            
        }
        
        for(Opportunity opp : [SELECT RecordTypeId FROM Opportunity where id=:this.BnfOpportunityId limit 1])
        {   
            OppRecordType = opp.RecordTypeId;
        }
        
        if(quickOppRecordtypeID!=null && quickOppRecordtypeID!='' && OppRecordType!=null && quickOppRecordtypeID==OppRecordType)
        {
            isQuickOpp=true;  // True if quick opportunity
        }
        else
            isQuickOpp =false;
        //***************************************************************************************************************
        //this.EntryUrl = ApexPages.currentPage().getUrl();
        this.EntryUrlParams = new Map<String,String>(ApexPages.currentPage().getParameters());
        //Quick Opp
        //Update by Himanshu Parashar : 22 sep 2011
        // User country__c parameter added
        U = [select Id, Sales_Org__c,Profile.Name,User_Country__c from User where Id = :UserInfo.getUserId()];
        //Updated By Rakesh : 9 April 2015 : Issue-6662 : START
        //this.SalesOrg = U.Sales_Org__c;
        this.SalesOrg = (ApexPages.currentPage().getParameters().get(fieldApiToIdmap.get('IMS_Sales_Org__c')) != null) ? ApexPages.currentPage().getParameters().get(fieldApiToIdmap.get('IMS_Sales_Org__c')) : U.Sales_Org__c;
        /*
        if(ApexPages.currentPage().getParameters().get('isIQVIAGB80') == 'true') {
            this.SalesOrg = '[GB80] IQVIA Ltd';
        }
        */
        if(ApexPages.currentPage().getParameters().get('multiBillingCountry') == 'IQVIA Operations France – FR12') {
            this.SalesOrg = '[FR12] IQVIA Operations France SAS';
        }
        if(ApexPages.currentPage().getParameters().get('multiBillingCountry') == 'IQVIA Ltd GB80 engagement') {
            this.SalesOrg = '[GB80] IQVIA Ltd';
        }
        //END : Issue-6662
        UserCountry=U.User_Country__c;
        //  Flag used to determine whether button is shown which allows RA to edit the SAP contract numbers
        //  This button should only be shown if the person viewing the BNF is the person to whom it has been 
        //  assigned and the BNF is currently in an approval process OR if viewed by sys admin
        this.ShowEditContractButton = false;
        Id CurrentUserId = U.Id;
        if ((Id)(controller.getRecord()).Id != null)
        {
            List<ProcessInstanceWorkitem> P = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.BNF.Id]);
            ApproverId_Set = new Set<Id>();
            if (P.size() > 0)
            {
                for (ProcessInstanceWorkitem PIW:P)
                {
                    ApproverId_Set.add(PIW.ActorId);
                }
                
                //Update By Himanshu Parahsr : 24 May 2013 : Issue-02093
                //Get Delegate approvers or all Approval process actor id
                for(User DelegateApproverUser :[select DelegatedApproverId from User where Id in : ApproverId_Set])
                {
                    if(DelegateApproverUser.DelegatedApproverId!=null)
                        ApproverId_Set.add(DelegateApproverUser.DelegatedApproverId);
                }
            }
            if (P.size() > 0 && (this.BNF.Renewal__c == true || this.BNF.SAP_Master_Contract__c != null || this.BNF.Manual_Handling_In_Sap__c) &&
                (ApproverId_Set.contains(CurrentUserId) || Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',U.Profile.Name.toLowerCase()) || hasAccessBNFAll))
            {
                this.ShowEditContractButton = true;
            }
            this.ProxyAccount.Region_Territory__c = this.BNF.Opportunity__r.Account.Region_Territory__c;
        }
        this.BnfLocked = false;
        //  BEGIN DEBUG
        this.Debug = '';
        system.debug('User Profile: '+ Profile.Name);
        //  END DEBUG 
    }
    
    public pageReference Initialise()
    {
        Address__c[] Address_Array = [select Id from Address__c where recordType.DeveloperName = 'MDM_Validated' and Account__c = :this.BnfAccountId and Marked_For_Deletion__c = false AND Archived__c = false];
        this.NumAddresses = Address_Array.size();
        this.NumAddressRecordsPerPage = 5;//this.NumAddresses < 5 ? this.NumAddresses : 5;
        if ((Id)(this.StandardController.getRecord()).Id != null) 
        {
            ProcessInstanceWorkitem[]  P = [select Id, ActorId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.BNF.Id];
            // updated for Issue-10275 30 Jan 2017
            if (P.size() > 0 && this.BNF.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('NEW') && !Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',U.Profile.Name.toLowerCase()) && !hasAccessBNFAll)
            {
                
                //Update By Himanshu Parahsr : 24 May 2013 : Issue-02093
                // updated for Issue-10275 30 Jan 2017            
                if (ApproverId_Set!=null && !ApproverId_Set.contains(UserInfo.getUserId()))
                {
                    this.AddressSelectorRendered = false;
                    this.BnfLocked = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'BNF is currently submitted for approval and cannot be edited.');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
            if (this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED'))
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
            NewAddressRequest.getParameters().put('BnfId',this.BNF.Id);
            NewAddressRequest.getParameters().put('AccountId',this.BnfAccountId);
            NewAddressRequest.getParameters().put('ApprovalRequest','true');
            NewAddressRequest.getParameters().put('retURL','/'+this.BNF.Id);
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
            Address__c[] Address_Array = [select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, International_Name__c, International_Street__c, International_City__c, International_State__c, International_PostalCode__c,International_Country__c,Marked_For_Deletion__c from Address__c where recordType.DeveloperName = 'MDM_Validated' and Account__c = :this.BnfAccountId and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc];
            this.Debug += '  SOQL array size: ' + Address_Array.size().format();
            //  END DEBUG
            this.AddressSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c, International_Name__c, International_Street__c, International_City__c, International_State__c, International_PostalCode__c,International_Country__c,Marked_For_Deletion__c  from Address__c where recordType.DeveloperName = 'MDM_Validated' and  Account__c = :this.BnfAccountId and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc]));
            this.AddressSetController.setPageSize(this.NumAddressRecordsPerPage);   
            //  BEGIN DEBUG
            this.Debug += ' num addresses:  ' + this.AddressSetController.getResultSize().format();
            this.Debug += '  SOQL: select Id, Name, Account__c, Street__c, City__c, State__c, Country__c from Address__c where recordType.DeveloperName = \'MDM_Validated\' and Account__c = ' + this.BnfAccountId + ' order by Name desc  ';
            //  END DEBUG
        }
        
        return this.AddressSetController;
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
        String OptionName = '';
        if (AddressId != null && AddressId != '')
        {          
            for (SAP_Contact__c C : [select Id, Name, First_Name__c, Last_Name__c, First_Name_Local__c, Last_Name_Local__c, SAP_Contact_Number__c, Address__r.Country__c  from SAP_Contact__c where Address__c = :AddressId and Marked_For_Deletion__c = false AND Address__r.Archived__c = false and RecordType.name='MDM Validated' order by Last_Name__c asc, First_Name__c asc])
            {
                if (UserCountry == C.Address__r.Country__c && C.Last_Name_Local__c != null)
                {
                    OptionName = C.Last_Name_Local__c + '&nbsp;&nbsp;&nbsp;' + C.First_Name_Local__c + ' - [' + C.SAP_Contact_Number__c + ']';
                }
                else 
                {
                    OptionName = C.Name;
                }
                SelectOption SO = new SelectOption(C.Id,OptionName);
                SO.setEscapeItem(false);
                optionList.add(SO);
            }
            if (optionList.size() == 0)
            {
                optionList.add(new SelectOption('','N/A',false));
            }
            else (optionList.add(0, new SelectOption('','No Contact Selected',false)));
        }
        return optionList;
    }
    
    public List<SelectOption> getBillToContacts()
    {
        return getAddressContacts((String)this.BNF.Bill_To__c);
    }
    
    public List<SelectOption> getShipToContacts()
    {
        return getAddressContacts((String)this.BNF.Ship_To__c);
    }
    
    public List<SelectOption> getSecondCopyContacts()
    {
        return getAddressContacts((String)this.BNF.X2nd_Copy__c);
    }
    
    public List<SelectOption> getCarbonCopyContacts()
    {
        return getAddressContacts((String)this.BNF.Carbon_Copy__c);
    }
    
    public List<SelectOption> getCoverSheetContacts()
    {
        return getAddressContacts((String)this.BNF.Cover_Sheet__c);
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
    
    public Address__c getAddressDetails(String AddressId) 
    {
        Address__c Address = new Address__c();
        if (AddressId != null && AddressId != '')
        {          
            Address = [select Id, Name, Account__c, Street__c, City__c, State__c,PostalCode__c, Country__c,  International_Name__c, International_Street__c, International_City__c, International_State__c, International_PostalCode__c,International_Country__c  from Address__c where id = :AddressId];
            
        }
        return Address;
    }
    
    public Address__c getBillToAddressDetails()
    {
        return getAddressDetails((String)this.BNF.Bill_To__c);
    }
    
    public Address__c getShipToAddressDetails()
    {
        return getAddressDetails((String)this.BNF.Ship_To__c);
    }
    
    public Address__c getSecondCopyAddressDetails()
    {
        return getAddressDetails((String)this.BNF.X2nd_Copy__c);
    }
    
    public Address__c getCoverSheetAddressDetails()
    {
        return getAddressDetails((String)this.BNF.Cover_Sheet__c);
    }
    
    public Address__c getCarbonCopyAddressDetails()
    {
        return getAddressDetails((String)this.BNF.Carbon_Copy__c);
    }
    
    public Address__c getSoldToAddressDetails()
    {
        return getAddressDetails((String)this.BNF.Sold_To__c);
    }    
    
    public void DoNothing()
    {
        //  BEGIN DEBUG
        //this.Debug += '  Bill_To__c: ' + this.BNF.Bill_To__c;
        //  END DEBUG
    }
    
    public Integer getNumAddressRecordsPerPage()
    {
        return this.NumAddressRecordsPerPage;
    }
    
    //  BEGIN DEBUG functions
    public String getBnfId()
    {
        return this.BNF.Id;
    }
    
    public String getBnfAccountId()
    {
        return this.BnfAccountId;
    }
    
    public String Debug {get;set;}
    //  END DEBUG functions
    
    public Id fetchValidId(String ContactId)
    {
        if (ContactId == null || ContactId == '' || ContactId == 'Default' || ContactId == 'NA' )
        {
            return null;
        }
        else
        {
            return (Id)ContactId;
        }
    }
    
    public PageReference Save()
    {   
        if (fetchValidId(this.BNF.Bill_To__c) == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Bill To address');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if (fetchValidId(this.BNF.Ship_To__c) == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Ship To address');
            ApexPages.addMessage(myMsg);
            return null;
        }
        this.BNF.Bill_To_SAP_Contact__c = fetchValidId(BNF.Bill_To_SAP_Contact__c);
        this.BNF.Ship_To_SAP_Contact__c = fetchValidId(BNF.Ship_To_SAP_Contact__c);
        this.BNF.X2nd_Copy_SAP_Contact__c = fetchValidId(BNF.X2nd_Copy_SAP_Contact__c);
        this.BNF.Cover_Sheet_SAP_Contact__c = fetchValidId(BNF.Cover_Sheet_SAP_Contact__c);
        //Carbon_Copy_SAP_Contact__c - add by Ghanshyam  - Issue-06350
        this.BNF.Carbon_Copy_SAP_Contact__c = fetchValidId(BNF.Carbon_Copy_SAP_Contact__c);
        //  BEGIN DEBUG
        //this.Debug += ' |' + this.BNF.Bill_To_SAP_Contact__c + '|  '; 
        //this.Debug += ' |' + this.BNF.X2nd_Copy_SAP_Contact__c + '|  ';
        this.Debug += '  | Opp ID: ' + this.BnfOpportunityId + '|  ';   
        //  END DEBUG
        //this.StandardController.save();
        try
        {
            update this.BNF;
        }
        catch (Exception E)
        {
            return null;
        }
        
        PageReference retURL; 
        if (ApexPages.currentPage().getParameters().get('AccountId') != null)
        {
            BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
            retURL = Page.BNFOpptyListLockedGridMDM;
            //  If opp is below the threshold, direct to "old" page
            if(bnfSetting.BNF_Opportunity_Threshold__c != null) 
            {
                try {
                    if(Integer.valueOf(this.BNF.Opportunity__r.Opportunity_Number__c) < bnfSetting.BNF_Opportunity_Threshold__c)                
                        retURL = Page.BNFOpptyListLockedGridMDMOld;
                } catch (Exception exp) {
                    retURL = Page.BNFOpptyListLockedGridMDMOld;
                } 
            } 
            retURL.getParameters().put('id',this.BnfOpportunityId);
            retURL.getParameters().put('newid',this.BNF.Id);
            //  BEGIN DEBUG
            this.Debug += '  | URL: ' + retURL.getUrl() + '|  '; 
            //  END DEBUG            
        }
        else
        {
            retURL = new PageReference('/' + this.BNF.Id);
        }   
        retURL.setRedirect(true);
        return retURL;
    }
    
    public pageReference AddressSelectorRedirect()
    {
        pageReference AddressSelector = Page.BNF_Address_Selector;
        AddressSelector.getParameters().put('id',this.BNF.Id);
        AddressSelector.setRedirect(true);
        return AddressSelector;
    }
    
    public Boolean getAddressSelectorRendered()
    {
        return this.AddressSelectorRendered;
    }
    
    public List<SelectOption> getSalesOrgs()
    {   
        //Get all the picklist values of BNF2__c.Sales_Org_Code__c
        Schema.DescribeFieldResult F = BNF2__c.IMS_Sales_Org__c.getDescribe();
        List<Schema.PicklistEntry> SalesOrgValues = F.getPicklistValues();
        List<SelectOption> SalesOrgs = new List<SelectOption>();
        for (Schema.PicklistEntry S:SalesOrgValues) 
        {
            SalesOrgs.add(new SelectOption(S.getValue(),S.getValue()));
        }  
        return SalesOrgs;
    }
    
    public List<SelectOption> getmfdValues() {
        List<SelectOption> options = new List<SelectOption>();
       // options.add(new SelectOption('null','--None--'));
        options.add(new SelectOption('Excluding Marked For Deletions','Excluding Marked For Deletions'));
        options.add(new SelectOption('Including Marked For Deletions','Including Marked For Deletions'));
        return options;
    }
    
    public PageReference CreateNewBnf()
    {
        //Quick Opp
        //Update by Himanshu Parashar : 22 sep 2011
        //Setting default values in case of quick opportunity
        String InvoiceDefaultDay='Default Material Master Data';
        String FairValue='Stand Alone';
        Boolean isIBNF = false;
        this.IsError = false;
        String InvoiceHeaderText='Rechnungstext:Lieferdatum:';
        system.debug('****** EntryUrlParams0 - ' + EntryUrlParams);
        system.debug('****** fieldApiToIdmap - ' + fieldApiToIdmap);        
        //***********************************************************
        String bnfPrefix = BNF2__c.SobjectType.getDescribe().getKeyPrefix();
        String NewBnfUrl = '/' + bnfPrefix + '/e?';         
        this.EntryUrlParams.put(fieldApiToIdmap.get('IMS_Sales_Org__c'), this.SalesOrg);
        //Quick Opp
        //Update by Himanshu Parashar : 22 sep 2011
        //Setting default values in case of quick opportunity
        if(isQuickOpp)
        {
            this.EntryUrlParams.put(fieldApiToIdmap.get('Fair_Value_Type__c'), FairValue);
            this.EntryUrlParams.put(fieldApiToIdmap.get('Invoice_Default_Day__c'), InvoiceDefaultDay);
            
            if(UserCountry=='Germany')
                this.EntryUrlParams.put(fieldApiToIdmap.get('Invoice_Header_Text__c'), InvoiceHeaderText);
        }
        Set<String> usSalesOrgsSet = new Set<String>(); 
        Enable_US_Sales_Org__c usSalesOrgs = Enable_US_Sales_Org__c.getInstance();
        System.debug(usSalesOrgs);
        if(usSalesOrgs.US_iBNF_Sales_Orgs__c != null) {
            for (String usOrgs : usSalesOrgs.US_iBNF_Sales_Orgs__c.split(','))
            {
                usSalesOrgsSet.add(usOrgs);
            }
        }
        String SalesOrgCode = (this.SalesOrg).substringBetween('[', ']');
        if ( ( MDM_Defines.EnabledSalesOrgs.contains(this.SalesOrg) || usSalesOrgsSet.contains(SalesOrgCode))  && !this.ManualBnfOverride)
        {            
            Account BNF_Account = [select Id, MDM_Validation_Status__c from Account where Id = :this.BnfAccountId];
            if (BNF_Account.MDM_Validation_Status__c != 'Validated')
            {
                pageReference SapValidation = Page.AccountValidation;
                system.debug('****** EntryUrlParams - ' + EntryUrlParams);
                for (String Param:this.EntryUrlParams.keySet())
                {
                    SapValidation.getParameters().put(Param,this.EntryUrlParams.get(Param));
                }
                SapValidation.getParameters().put('id',this.BnfAccountId);
                SapValidation.getParameters().put('error','AccountValidation');
                SapValidation.getParameters().put('retURL',ApexPages.currentPage().getParameters().get('retURL'));
                SapValidation.getParameters().put('SalesOrg',this.SalesOrg);
                SapValidation.setRedirect(true);
                return SapValidation;
            }
            isIBNF = true;           
            this.EntryUrlParams.put('RecordType', MDM_Defines.SAP_SD_Integrated_Record_Type_Id);   
            this.EntryUrlParams.put('saveURL','/apex/BNF_Address_Selector?AccountId=' + this.EntryUrlParams.get('AccountId'));
            this.EntryUrlParams.remove('saveUrl');    
        }
        //pageReference NewBnf = new pageReference(NewBnfUrl);
        String fullURL = NewBnfUrl;
        for (String Param : this.EntryUrlParams.keySet())
        {
            if(Param == fieldApiToIdmap.get('IMS_Sales_Org__c')) {
                fullURL += '&' + Param + '=' + EncodingUtil.urlEncode(this.SalesOrg,'UTF-8');  
            }
            else if(this.EntryUrlParams.get(Param) != '' && this.EntryUrlParams.get(Param) != 'undefined') {
                if(Param.contains('__c')) {
                    if(!isIBNF) {
                        fullURL += '&' + fieldApiToIdmap.get(Param) + '=' + EncodingUtil.urlEncode(this.EntryUrlParams.get(Param),'UTF-8');
                    }
                }
                else
                    fullURL += '&' + Param + '=' + EncodingUtil.urlEncode(this.EntryUrlParams.get(Param),'UTF-8');
            } 
            //NewBnf.getParameters().put(Param,EncodingUtil.urlEncode(this.EntryUrlParams.get(Param),'UTF-8'));
        }
        //NewBnf.setRedirect(true);
        if(isIBNF) {
            List<BNF2__c> iBNFList = [SELECT Id, First_RA__c  from BNF2__c where Opportunity__c = :BnfOpportunityId and Addendum__c = false];
            if(iBNFList.size() > 0) {
                fullURL = '/' + iBNFList[0].Id + '/e?clone=1&retURL=/'+ this.BnfOpportunityId +'&saveURL=/apex/BNF_Clone?OriginalBnfId=' + iBNFList[0].Id ;
                fullURL += '&' + fieldApiToIdmap.get('Revised_BNF_Date__c') + '=';
                fullURL += '&' + fieldApiToIdmap.get('Addendum__c') + '=1&nooverride=true' ;
                fullURL += '&' + fieldApiToIdmap.get('SAP_Contract__c') + '=' ;
                fullURL += '&' + fieldApiToIdmap.get('BNF_Status__c') + '=New' ;
                if(iBNFList[0].First_RA__c != null) {
                    Revenue_Analyst__c revenueAnalyst = [SELECT Id, Name from Revenue_Analyst__c where Id = :iBNFList[0].First_RA__c];
                    fullURL += '&CF' + fieldApiToIdmap.get('Revenue_Analyst__c') + '_lkid=' + revenueAnalyst.Id ;
                    fullURL += '&CF' + fieldApiToIdmap.get('Revenue_Analyst__c') + '='  + revenueAnalyst.Name;
                }
            }
            if((this.SalesOrg == '[DE50] IQVIA Commercial GmbH & Co. OHG' || this.SalesOrg == '[DE82] Kairos GmbH') && iBNFList.isEmpty()){
                List<Revenue_Analyst__c> revenueAnalyst = [SELECT Id, Name from Revenue_Analyst__c where Name = 'GFSS RA DE'];
                if(revenueAnalyst.size() > 0){
                   fullURL += '&CF' + fieldApiToIdmap.get('Revenue_Analyst__c') + '_lkid=' + revenueAnalyst[0].Id ;
                   fullURL += '&CF' + fieldApiToIdmap.get('Revenue_Analyst__c') + '='  + revenueAnalyst[0].Name; 
                }
            }
        }
        fullURLString =  fullURL;
        
        //Update by Balkrishan Gohil : 06 Jan 2025 For (ESPSFDCQI-17263)
        //Throwing Error while iBNF Creation on EMEA Opportunity and Related Primary IQVIA Quote is Not on Accepted Stage AND OLI not Synced with QLI 
        //This Validation will Work after April 2025 Release (ESPSFDCQI-17520)
        if(isIBNF){
            List<BNF2__c> iBNFList = [SELECT Id, First_RA__c  from BNF2__c where Opportunity__c = :BnfOpportunityId and Addendum__c = false];
            if(iBNFList.isEmpty()){
                iqviaQuoteValidationCheck(BnfOpportunityId);
            }  
        }
        return null;
    }  
    
    public pageReference UpdateCloneFromOriginal()
    {
        this.BNF = [select Id from BNF2__c where Id =:ApexPages.currentPage().getParameters().get('newid')];
        BNF2__c OriginalBnf = [select Id,X2nd_Copy__c, X2nd_Copy_SAP_Contact__c, Ship_To__c, Ship_To_SAP_Contact__c, Carbon_Copy_SAP_Contact__c, //Carbon_Copy_SAP_Contact__c - add by Ghanshyam  - Issue-06350
                               Cover_Sheet__c, Cover_Sheet_SAP_Contact__c, Carbon_Copy__c, Bill_To__c, Bill_To_SAP_Contact__c, SAP_Master_Contract__c,SAP_Contract__c, Sold_To__c, RecordType.Name
                               From BNF2__c where Id = :ApexPages.currentPage().getParameters().get('OriginalBnfId')];
        this.BNF.X2nd_Copy__c = OriginalBnf.X2nd_Copy__c;
        this.BNF.X2nd_Copy_SAP_Contact__c = OriginalBnf.X2nd_Copy_SAP_Contact__c;
        this.BNF.Ship_To__c = OriginalBnf.Ship_To__c;
        this.BNF.Ship_To_SAP_Contact__c = OriginalBnf.Ship_To_SAP_Contact__c;
        this.BNF.Cover_Sheet__c = OriginalBnf.Cover_Sheet__c;
        this.BNF.Cover_Sheet_SAP_Contact__c = OriginalBnf.Cover_Sheet_SAP_Contact__c;
        this.BNF.Carbon_Copy__c = OriginalBnf.Carbon_Copy__c;
        this.BNF.Bill_To__c = OriginalBnf.Bill_To__c;
        this.BNF.Bill_To_SAP_Contact__c  = OriginalBnf.Bill_To_SAP_Contact__c ;
        this.BNF.SAP_Master_Contract__c = OriginalBnf.SAP_Master_Contract__c;      
        this.BNF.SAP_Contract__c = OriginalBnf.SAP_Contract__c;
        //Carbon_Copy_SAP_Contact__c - add by Ghanshyam  - Issue-06350
        this.BNF.Carbon_Copy_SAP_Contact__c = OriginalBnf.Carbon_Copy_SAP_Contact__c;     
        this.BNF.Sold_To__c = OriginalBnf.Sold_To__c;
        
        update this.BNF;
        pageReference retURL = new pageReference('/' + this.BNF.Id);
        retURL.setRedirect(true);
        return retURL;
    }
    
    public pageReference UpdateCloneWithAttachmentFromOriginal()
    {
        this.BNF = [select Id from BNF2__c where Id =:ApexPages.currentPage().getParameters().get('newid')];
        BNF2__c OriginalBnf = [select Id,X2nd_Copy__c, X2nd_Copy_SAP_Contact__c, Ship_To__c, Ship_To_SAP_Contact__c, Carbon_Copy_SAP_Contact__c, //Carbon_Copy_SAP_Contact__c - add by Ghanshyam  - Issue-06350
                               Cover_Sheet__c, Cover_Sheet_SAP_Contact__c, Carbon_Copy__c, Bill_To__c, Bill_To_SAP_Contact__c, SAP_Master_Contract__c,SAP_Contract__c, Sold_To__c 
                               From BNF2__c where Id = :ApexPages.currentPage().getParameters().get('OriginalBnfId')];
        this.BNF.X2nd_Copy__c = OriginalBnf.X2nd_Copy__c;
        this.BNF.X2nd_Copy_SAP_Contact__c = OriginalBnf.X2nd_Copy_SAP_Contact__c;
        this.BNF.Ship_To__c = OriginalBnf.Ship_To__c;
        this.BNF.Ship_To_SAP_Contact__c = OriginalBnf.Ship_To_SAP_Contact__c;
        this.BNF.Cover_Sheet__c = OriginalBnf.Cover_Sheet__c;
        this.BNF.Cover_Sheet_SAP_Contact__c = OriginalBnf.Cover_Sheet_SAP_Contact__c;
        this.BNF.Carbon_Copy__c = OriginalBnf.Carbon_Copy__c;
        this.BNF.Bill_To__c = OriginalBnf.Bill_To__c;
        this.BNF.Bill_To_SAP_Contact__c  = OriginalBnf.Bill_To_SAP_Contact__c ;
        this.BNF.SAP_Master_Contract__c = OriginalBnf.SAP_Master_Contract__c;      
        this.BNF.SAP_Contract__c = OriginalBnf.SAP_Contract__c;
        //Carbon_Copy_SAP_Contact__c - add by Ghanshyam  - Issue-06350
        this.BNF.Carbon_Copy_SAP_Contact__c = OriginalBnf.Carbon_Copy_SAP_Contact__c;     
        this.BNF.Sold_To__c = OriginalBnf.Sold_To__c;
        
        List<Attachment> attachmentList = [Select Id, ContentType, Body, Name, ParentId From Attachment where ParentId =: OriginalBnf.id];
        List<Attachment> attachmentList2 = new List<Attachment>();        
        for(Attachment atc : attachmentList){
            Attachment attTemp = new Attachment(Name =atc.Name, Body =atc.Body, ParentId = this.BNF.Id, ContentType =atc.ContentType);
            attachmentList2.add(attTemp);            
        }
        if(attachmentList2.size() > 0)
            insert attachmentList2;        
        
        update this.BNF;
        pageReference retURL = new pageReference('/' + this.BNF.Id);
        retURL.setRedirect(true);
        return retURL;
    }
    
    public void ShowSapCodeSelectionPanel()
    {
        this.SapCodeSelectPanelRendered = true; 
    } 
    
    public void HideSapCodeSelectionPanel()
    {
        this.SapCodeSelectPanelRendered = false;
    }   
    
    /* public void SearchBySapCode()
{
this.SelectedSapCode = this.SelectedSapCode.replaceFirst('^[0]+','').trim();
this.AddressSearchRunOnce = true;
if (this.SelectedSapCode.length() > 0)
{
this.SapCodeSelectedAddress_Array = [select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,  International_Name__c, International_Street__c, International_City__c from Address__c where SAP_Reference__c like :('%'+this.SelectedSapCode) order by Name desc limit 1];
}
//  BEGIN DEBUG
this.Debug += '  SelectedSapCode: ' + this.SelectedSapCode;
//  END DEBUG
}  */
    
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
            //Address__c[] Address_Array = [select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c, International_Name__c, International_Street__c, International_City__c from Address__c where Country__c = :this.ProxyAccount.Region_Territory__c and (Name like :('%'+SearchTerm+'%') or (International_Name__c!= null and International_Name__c like :('%'+SearchTerm+'%')) ) and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc limit 500];
            //this.Debug += ' Search SOQL array size: ' + Address_Array.size().format();
            //this.Debug += ' Search Query: ' + '[select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c, International_Name__c, International_Street__c, International_City__c from Address__c where Country__c like :("%"'+this.ProxyAccount.Region_Territory__c + '"%") and Name like :("%"'+SearchTerm+'"%") order by Name desc]';
            //  END DEBUG
            system.debug('@@ GS'+this.ProxyAccount.Region_Territory__c);
            if(this.AddressSearchMFD == 'Excluding Marked For Deletions'){
                if (this.ProxyAccount.Region_Territory__c == null)
                {
                    this.AddressSearchSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,  International_Name__c, International_Street__c, International_City__c, International_State__c, International_PostalCode__c,International_Country__c,Marked_For_Deletion__c from Address__c where
                                                                                                                   recordType.DeveloperName = 'MDM_Validated' and 
                                                                                                                   (Name like :('%'+SearchTerm+'%') or (International_Name__c!= null and International_Name__c like :('%'+SearchTerm+'%'))) 
                                                                                                                   and (City__c like :('%'+this.AddressSearchCity.trim()+'%') or (International_City__c!=null and International_City__c like :('%'+this.AddressSearchCity.trim()+'%'))) and SAP_Reference__c like :('%'+this.AddressSearchSapCode.trim()+'%') and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc limit 400]));
                }
                else
                {                    
                    this.AddressSearchSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,  International_Name__c, International_Street__c, International_City__c, International_State__c, International_PostalCode__c,International_Country__c,Marked_For_Deletion__c from Address__c where
                                                                                                                   recordType.DeveloperName = 'MDM_Validated'
                                                                                                                   and Country__c =:this.ProxyAccount.Region_Territory__c and (Name like :('%'+SearchTerm+'%') or (International_Name__c!= null and International_Name__c like :('%'+SearchTerm+'%'))) 
                                                                                                                   and (City__c like :('%'+this.AddressSearchCity.trim()+'%') or (International_City__c!=null and International_City__c like :('%'+this.AddressSearchCity.trim()+'%'))) and SAP_Reference__c like :('%'+this.AddressSearchSapCode.trim()+'%') and Marked_For_Deletion__c = false AND Archived__c = false order by Name asc limit 400]));
                }
            }
            else{
                if (this.ProxyAccount.Region_Territory__c == null)
                {
                    this.AddressSearchSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,  International_Name__c, International_Street__c, International_City__c, International_State__c, International_PostalCode__c,International_Country__c,Marked_For_Deletion__c from Address__c where
                                                                                                                   recordType.DeveloperName = 'MDM_Validated' and Archived__c = false and
                                                                                                                   (Name like :('%'+SearchTerm+'%') or (International_Name__c!= null and International_Name__c like :('%'+SearchTerm+'%'))) 
                                                                                                                   and (City__c like :('%'+this.AddressSearchCity.trim()+'%') or (International_City__c!=null and International_City__c like :('%'+this.AddressSearchCity.trim()+'%'))) and SAP_Reference__c like :('%'+this.AddressSearchSapCode.trim()+'%') order by Name asc limit 400]));
                }
                else
                {                    
                    this.AddressSearchSetController= new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Name, Account__c, Street__c, City__c, State__c, Country__c, SAP_Reference__c,  International_Name__c, International_Street__c, International_City__c, International_State__c, International_PostalCode__c,International_Country__c,Marked_For_Deletion__c from Address__c where
                                                                                                                   recordType.DeveloperName = 'MDM_Validated' and Archived__c = false 
                                                                                                                   and Country__c =:this.ProxyAccount.Region_Territory__c and (Name like :('%'+SearchTerm+'%') or (International_Name__c!= null and International_Name__c like :('%'+SearchTerm+'%'))) 
                                                                                                                   and (City__c like :('%'+this.AddressSearchCity.trim()+'%') or (International_City__c!=null and International_City__c like :('%'+this.AddressSearchCity.trim()+'%'))) and SAP_Reference__c like :('%'+this.AddressSearchSapCode.trim()+'%') order by Name asc limit 400]));
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
    
    public void ShowInfoMessages()
    {
        //Added by Himanshu parashar : 12 dec 2012 : When BNF Status is Accepted, Info Message only display to assigned user
        
        ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.BNF.Id];        
        Set<Id> Approver_Set = new Set<Id>();
        if (P_array.size() > 0)
        {
            for (ProcessInstanceWorkitem PIW:P_array)
            {
                Approver_Set.add(PIW.ActorId);
            }
            
            //Update By Himanshu Parahsr : 24 May 2013 : Issue-02093
            //Get Delegate approvers or all Approval process actor id
            for(User DelegateApproverUser :[select DelegatedApproverId from User where Id in : Approver_Set])
            {
                if(DelegateApproverUser.DelegatedApproverId!=null)
                    Approver_Set.add(DelegateApproverUser.DelegatedApproverId);
            }
        }
        
        if(bnfSetting.Enable_Customer_Validation__c==true)
        {
            Set<Id> AddressId_Set = new Set<Id>{this.BNF.Bill_To__c,this.BNF.Ship_To__c,this.BNF.Cover_Sheet__c,this.BNF.X2nd_Copy__c,this.BNF.Carbon_Copy__c};
                Map<Id,String> Address_Map = new Map<Id,String>();
            Address_Map.put(this.BNF.X2nd_Copy__c,'2nd Copy');
            Address_Map.put(this.BNF.Carbon_Copy__c,'Carbon Copy');
            Address_Map.put(this.BNF.Bill_To__c,'Bill To');
            Address_Map.put(this.BNF.Ship_To__c,'Ship To');
            Address_Map.put(this.BNF.Cover_Sheet__c,'Cover Sheet');
            List<Address__c> Address_List = new List<Address__c>([select Id,Name,SAP_Reference__c,Enabled_Sales_Orgs__c from Address__c where Id in :AddressId_Set and Id != null]);
            
            for (Address__c A:Address_List)
            {
                Set<String> setAddressSalesOrgs = new Set<String>();
                if(A.Enabled_Sales_Orgs__c!=null)
                {
                    List<String> AddressSalesOrgs= A.Enabled_Sales_Orgs__c.split(':'); 
                    setAddressSalesOrgs.addAll(AddressSalesOrgs);
                }
                
                if (A.Enabled_Sales_Orgs__c==null || (setAddressSalesOrgs.size()>0 && setAddressSalesOrgs.contains(this.BNF.Sales_Org_Code__c) == false))
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,Address_Map.get(A.Id) + ': ' + A.Name + ' (SAP Code: '+ A.SAP_Reference__c + ') is not enabled for ' + this.BNF.Sales_Org_Code__c);
                    ApexPages.addMessage(myMsg);   
                }
            }                        
        }
        //Added by Himanshu Parashar : 11 dec 2012 : BNF_Status__c Accepted
        if(bnfSetting.Enable_Material_Validation__c==true)
        {
            for (OpportunityLineItem OLI : [select Id,TotalPrice ,PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.ProductCode,PricebookEntry.Product2.Enabled_Sales_Orgs__c from OpportunityLineItem where OpportunityId =:this.BNF.Opportunity__c AND Product_Material_Type__c NOT IN :excludedProducts])
            {
                
                Set<String> setProductSalesOrgs = new Set<String>();
                if(OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c!=null)
                {
                    List<String> ProductSalesOrgs= OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c.split(':'); 
                    setProductSalesOrgs.addAll(ProductSalesOrgs);
                    
                }
                
                if((OLI.TotalPrice!=null && OLI.TotalPrice > 0) && (OLI.PricebookEntry.Product2.Enabled_Sales_Orgs__c==null || (setProductSalesOrgs.size()>0 && (!setProductSalesOrgs.contains(this.BNF.Sales_Org_Code__c)))))
                {
                    ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.INFO,'Product '+OLI.PricebookEntry.Product2.ProductCode+' is not enabled for sales org '+ this.BNF.Sales_Org_Code__c + '. Please contact your local Finance representative to resolve this before submitting the BNF.');
                    ApexPages.addMessage(myMsg1);
                }
            }
        }
        
        
        
    }
    
    // Update By Himanshu : 12-June-2013 : Use on OLI_Address_selector page
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
    
    public void iqviaQuoteValidationCheck(Id bnfOppId){
        Map<id,String> oppIdToErrorMsgMap = CPQ_QuoteUtilityWO.validateQuoteSyncWithOpportunities(new Set<Id>{bnfOppId});
        String ErrorMessageForIqviaQuote = oppIdToErrorMsgMap.get(bnfOppId);
        Boolean isSuperUser = [Select Exclude_IQVIA_Quote_Sync__c from Opportunity where id =: bnfOppId Limit 1].Exclude_IQVIA_Quote_Sync__c;
        if(ErrorMessageForIqviaQuote != 'Success' && ErrorMessageForIqviaQuote != 'Error:NonEMEAEligibleOpportunity' && UTL_GLOBAL.getCurrentReleaseVersion() >= CON_GLOBAL.RELEASE_APR_2025 && !isSuperUser){
            this.errorMsgLabel = 'Please make sure this opportunity has a Primary and Accepted IQVIA Quote record and ensure Quote Line Item and Opportunity Product are in sync before creating BNF.';
            this.IsError = True;
            this.OppId = bnfOppId;
        }
    }
    
	 /**
     * method used to Hide and Show Recall Approval Request Button and Unlock Record Button
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
        if(approvalpending.size() > 0 && hasPermission.size() > 0 && this.BNF.BNF_Status__c =='Submitted'){
            showReassignbuttonview = true;
        }
        if(isLocked && hasPermission.size() > 0 && this.BNF.BNF_Status__c=='Submitted'){
            unlockbuttonview = true;
        }
        if(isLocked == false && approvalpending.size() > 0 && hasPermission.size() > 0 && this.BNF.BNF_Status__c=='Submitted'){
            showlockbuttonview = true;
        }
    }
    
    /**
     * method used to Hide and Show Upload Signed Contract Button 
     * @params : Id recordId
     */
    public void setUploadSignedContractVisiblity(BNF2__c bnf){
	    showUploadSignedContractButton = false;
        Boolean isUSBUOpp = bnf.Opportunity__r.Is_USBU_Opportunity__c;
        CLM_Configuration__c clmConfiguration = CLM_Configuration__c.getInstance();
        Boolean enableAgreementRepository = clmConfiguration.Enable_Agreement_Repository__c;
		if(isUSBUOpp && enableAgreementRepository && String.isBlank(bnf.AR_Comments__c) && bnf.Addendum__c && bnf.Addendum_Reasons__c == 'Change Order/Amendment'){
            showUploadSignedContractButton = true;
        }
    }
}