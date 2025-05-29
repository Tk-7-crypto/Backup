public class Account_MDM_Extension {

	private Account Account;
	private ApexPages.StandardController StandardController;
//	public String ARC_MDM_Link {get;private set;}
	public Contact ProxyContact {get;private set;}
	private Map<String,String> EntryUrlParams;
	public Boolean SubmittedForApproval {get; private set;}
	public Boolean CurrentUserIsApprover {get; private set;}
	public Integer NumApprovalHistorySteps {get; private set;}
	
	public Account_MDM_Extension(ApexPages.StandardController controller)
	{
		this.StandardController = controller;
		this.Account = (Account)StandardController.getRecord();
//		this.ARC_MDM_Link = 'http://arc.imshealth.com/xxx';
		this.ProxyContact = new Contact(AccountId = this.Account.Id);
		this.EntryUrlParams = new Map<String,String>(ApexPages.currentPage().getParameters());
		this.SubmittedForApproval = false;
		this.CurrentUserIsApprover = false;
		this.NumApprovalHistorySteps = 0;
		ProcessInstanceWorkitem[] WorkItem_Array = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  
    								where ProcessInstance.Status like 'Pending' and 
    								ProcessInstance.TargetObjectId = :this.Account.Id];
		if (WorkItem_Array.size() > 0)
		{
			this.SubmittedForApproval = true;
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Account "' + this.Account.Name + '" has already been submitted for approval. Please see below for current approval status.');
			ApexPages.addMessage(myMsg);
		}
		if (Apexpages.currentPage().getParameters().get('error') == 'AccountValidation')
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Account "' + this.Account.Name + '" has not been validated in SAP.');
			ApexPages.addMessage(myMsg);
		}		
	}
	
/*	public pageReference ARC_MDM_Request()
	{
		pageReference MDM_Page = new pageReference(this.ARC_MDM_Link);
		MDM_Page.setRedirect(true);
		return MDM_Page; 
	}*/
	
	public pageReference CreateManualBnf()
    {
    	 //Quick Opp
    	//Update by Himanshu Parashar : 22 sep 2011
    	// Checking for quick opportunity
        String quickOppRecordtypeID;
        String OppRecordType;
        String UserCountry;
        Boolean isQuickOpp;
        for(RecordType recordtypeId : [SELECT Id FROM RecordType where Name Like 'Quick Opportunity' limit 1])
        {
        	quickOppRecordtypeID = recordtypeId.Id;
      
        }
        // Getting Opportunity Record Type
        for(Opportunity opp : [SELECT RecordTypeId FROM Opportunity where id=:ApexPages.currentPage().getParameters().get('OpportunityId') limit 1])
        {
        	OppRecordType = opp.RecordTypeId;
      
        }
        // Getting User Country details
        for(User U : [select User_Country__c from User where Id = :UserInfo.getUserId()])
        {
        	UserCountry=U.User_Country__c;
        }
         
        // Check for Quick Opportunity 
        if(quickOppRecordtypeID!=null && quickOppRecordtypeID!='' && OppRecordType!=null && quickOppRecordtypeID==OppRecordType)
        {
             isQuickOpp=true;  // True if quick opportunity
        }
        else
             isQuickOpp =false;
             
        //Setting default values in case of quick opportunity
        String InvoiceDefaultDay='Default Material Master Data';
	    String FairValue='Stand Alone';
	    String InvoiceHeaderText='Rechnungstext:Lieferdatum:';
	    
	    //Quick Opp
	    		//Update by Himanshu Parashar : 22 sep 2011
	            //Setting default values in case of quick opportunity
	    
        Map<String, String> fieldApiToIdmap = UTL_Sobject.getCustomFieldByIds('BNF2');
        if(isQuickOpp)
        {
            
           	 this.EntryUrlParams.put(fieldApiToIdMap.get('Fair_Value_Type__c'), FairValue);
        	 this.EntryUrlParams.put(fieldApiToIdMap.get('Invoice_Default_Day__c'), InvoiceDefaultDay);
        
        	if(UserCountry!=null && UserCountry=='Germany')
        		this.EntryUrlParams.put(fieldApiToIdMap.get('Invoice_Header_Text__c'), InvoiceHeaderText);
       }
        //******************************************************************
        String bnfPrefix = BNF2__c.SobjectType.getDescribe().getKeyPrefix();
        String NewBnfUrl = '/' + bnfPrefix + '/e?'; 
        this.EntryUrlParams.remove('id');
        this.EntryUrlParams.remove('error');
        this.EntryUrlParams.remove('SalesOrg');              	
        for (String Param:this.EntryUrlParams.keySet())
        {
            NewBnfUrl += '&' + Param + '=' + this.EntryUrlParams.get(Param);
        }
        pageReference NewBnf = new pageReference(NewBnfUrl);
        NewBnf.setRedirect(true);      
        return NewBnf;
    }  	
    
    public void GetApprovalSteps()
    {
        this.Account = [Select A.Id,A.Name, (Select Id, Status From ProcessInstances order by Id desc), 
						(Select ActorId, Comments, CreatedById, CreatedDate, Id, 
						IsPending, OriginalActorId, RemindersSent, StepStatus,ProcessInstanceId From ProcessSteps order by Id desc) 
						from Account A where Id = :this.Account.Id];
		this.NumApprovalHistorySteps = 	this.Account.ProcessInstances.size();					
    }
    
    public List<ApprovalProcessDisplay> getCustomApprovalProcessHistory()
    {
    	system.debug('calling getCustomApprovalProcessHistory()');    	
    	this.GetApprovalSteps();
    	User CurrentUser = [select Id,Profile.Name from User where Id = :UserInfo.getUserId()];
    	List<ApprovalProcessDisplay> ApprovalProcessDisplay_Array = new List<ApprovalProcessDisplay>();    	

    	Map<Id,ProcessInstance> ProcessInstance_Map = new Map<Id,ProcessInstance>();
    	ProcessInstanceWorkitem[] WorkItem_Array = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  
    								where ProcessInstance.Status like 'Pending' and 
    								ProcessInstance.TargetObjectId = :this.Account.Id];
    	if (WorkItem_Array.size() > 0)
    	{
	    	if (WorkItem_Array[0].ActorId == CurrentUser.Id || Pattern.matches('System Administrator[\\s|[A-z]|[0-9]]*',CurrentUser.Profile.Name))
	    	{
	    		CurrentUserIsApprover = true;
	    	}
    	}
    	for (ProcessInstance P:this.Account.ProcessInstances)
    	{
    		ProcessInstance_Map.put(P.Id,P);
    	}
    	for (ProcessInstanceHistory P:this.Account.ProcessSteps)
    	{
    		ApprovalProcessDisplay TempDisplay = new ApprovalProcessDisplay();
    		//  Use ProxyRa.OwnerId to display ActorId
    		TempDisplay.ProxyRa.OwnerId = P.ActorId;
    		//  Use ProxyRa.User__c to display OriginalActorId
    		TempDisplay.ProxyRa.User__c = P.OriginalActorId;
    		//  Use ProxyTask.ReminderDateTime to display created date
    		TempDisplay.ProxyTask.ReminderDateTime = P.CreatedDate;
    		if (P.StepStatus == 'Approved'  || P.StepStatus == 'Rejected' || P.StepStatus == 'Pending')
    		{
    			TempDisplay.Status = P.StepStatus;
    		}
    		TempDisplay.Comments = P.Comments;
    		if (P.StepStatus != 'Pending')
    		{
    			TempDisplay.Action = 'Approval Request ' + P.StepStatus.replace('Started','Submitted');// + '| ' + P.ProcessInstanceId;
    		}
    		else 
    		{
    			if (CurrentUserIsApprover)
    			{
	    			TempDisplay.ApproveLinkRendered = true;
	    			TempDisplay.ApproveLink = '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + WorkItem_Array[0].Id;
	    			TempDisplay.ReassignLink = '/' + WorkItem_Array[0].Id + '/e?et=REASSIGN&retURL=%2F' + this.Account.Id;
    			}
    			else
    			{
    				TempDisplay.Action = 'Approval Pending';
    			}
    		}
    		if (P.StepStatus == 'Approved')
    		{
    			TempDisplay.ImgRendered = true;
    			TempDisplay.ImgSrc = '/img/icon/approve12.gif';
    		}
    		if (ProcessInstance_Map.get(P.ProcessInstanceId).Status == 'Pending' && P.StepStatus == 'Pending')
    		{
    			TempDisplay.ImgRendered = true;
    			TempDisplay.ImgSrc = '/img/icon/pending12.gif';
    		}
    		if (P.StepStatus == 'Rejected')
    		{
    			TempDisplay.ImgRendered = true;
    			TempDisplay.ImgSrc = '/img/icon/reject12.gif';
    		}
    		ApprovalProcessDisplay_Array.add(TempDisplay);
    	}
    	return ApprovalProcessDisplay_Array;
    }
    
    public pageReference SubmitAccountForApprovalPage()
    {
    	pageReference retUrl = Page.AccountApprovalSubmit;
    	retUrl.getParameters().put('id',this.Account.Id);
    	retUrl.setRedirect(true);
    	return retUrl;
    }
    
    public pageReference SubmitForMdmApproval()
    {
    	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setObjectId(this.Account.Id);
		// Submit the approval request
		try
		{
			this.StandardController.save();
			Approval.ProcessResult result = Approval.process(req1);
		}
		catch (Exception E)
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,E.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
		}		
		pageReference retUrl = new pageReference('/'+this.Account.Id);
		retUrl.setRedirect(true);
		return retUrl;
    }
    
    public static void UpdateRepresentativeBaseCode(Set <Id> Account_Id_Set)
	{		
		List <Address__c> Address_Array = new List <Address__c>([select Id,Account__c,SAP_Reference__c,Marked_For_Deletion__c from Address__c where Account__c in :Account_Id_Set and Account__c != null]);
		Map <String,Id> Current_Sap_Code_Map = new Map <String,Id>();
		Map <Id,String> Valid_Sap_Code_Map = new Map <Id,String>();
		for (Address__c A:Address_Array)
		{
			if (!A.Marked_For_Deletion__c)
			{
				Current_Sap_Code_Map.put(A.Sap_Reference__c,(Id)A.Account__c);
				Valid_Sap_Code_Map.put((Id)A.Account__c,A.Sap_Reference__c);
			}
		}
		Map <Id,Account> Account_Map = new Map <Id,Account>([select Id,SAP_Code__c from Account where Id in :Account_Id_Set and Status__c = :MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED')]);
		List <Account> Account_Update_Array = new List <Account>();
		for (Account A:Account_Map.values())
		{
			if (Valid_Sap_Code_Map.get(A.Id) != null && (Current_Sap_Code_Map.get(A.SAP_Code__c) == null || Current_Sap_Code_Map.get(A.SAP_Code__c) != A.Id))
			{
				A.SAP_Code__c = Valid_Sap_Code_Map.get(A.Id); 
				Account_Update_Array.add(A);				
			}
		}	
		update Account_Update_Array;
	}
	
    public static void UpdateAddresses(Set <Id> Account_Id_Set)
	{		
		Map <Id,Account> Account_Map = new Map<Id,Account>([select Id,Status__c from Account where Id in :Account_Id_Set and Status__c != :MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED')]);
		Map <String,Id> Current_Sap_Code_Map = new Map <String,Id>();
		Map <Id,String> Valid_Sap_Code_Map = new Map <Id,String>();
		List <Address__c> Address_Array = new List <Address__c>([select Id,Marked_For_Deletion__c from Address__c where Account__c in :Account_Map.keySet()]);
		List <Address__c> AddressUpdate_Array = new List <Address__c>();
		for (Address__c A:Address_Array)
		{
			if (A.Marked_For_Deletion__c != true)
			{
				A.Marked_For_Deletion__c = true;
				AddressUpdate_Array.add(A);
			}
		}
		update AddressUpdate_Array;
	}
	
	
	public pageReference ApprovalProcessRedirect()
	{
		User CurrentUser = [select Id,Profile.Name from User where Id = :UserInfo.getUserId()];
		ProcessInstanceWorkitem[] WorkItem_Array = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  
    								where ProcessInstance.Status like 'Pending' and 
    								ProcessInstance.TargetObjectId = :this.Account.Id];
    	String RetUrl;
    	if (WorkItem_Array.size() > 0 &&
    		(WorkItem_Array[0].ActorId == CurrentUser.Id || Pattern.matches('System Administrator[\\s|[A-z]|[0-9]]*',CurrentUser.Profile.Name)))
    	{
			if (Apexpages.currentPage().getParameters().get('ApproveReject') != null)
			{
	    			retUrl = '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + WorkItem_Array[0].Id;
			}
			else if (Apexpages.currentPage().getParameters().get('Reassign') != null)
			{
	    			retUrl = '/' + WorkItem_Array[0].Id + '/e?et=REASSIGN&retURL=%2F' + this.Account.Id;
			}
    	}
    	else
    	{
    		retUrl = '/' + this.Account.Id;
    	}
    	pageReference ApprovalRedirect = new pageReference(retUrl);
    	ApprovalRedirect.setRedirect(true);
    	return ApprovalRedirect;
	}
	
	public class ApprovalProcessDisplay
	{
		public Revenue_Analyst__c ProxyRA {get; private set;}
		public Opportunity ProxyOpp {get; private set;}
		public Task ProxyTask {get; private set;}
		public String Action {get; private set;}
		public String Status {get; private set;}
		public String Comments {get; private set;}
		public String ImgSrc {get; private set;}
		public Boolean ImgRendered {get; private set;}
		public String ApproveLink {get; private set;}
		public String ReassignLink {get; private set;}
		public Boolean ApproveLinkRendered {get; private set;}
				
		public ApprovalProcessDisplay()
		{
			this.ProxyRA = new Revenue_Analyst__c();
			this.ProxyOpp = new Opportunity();
			this.ProxyTask = new Task();
			this.ImgRendered = false;
			this.ImgSrc = '';
			this.Status = '';
			this.Action = '';
			this.Comments = '';
			this.ApproveLinkRendered = false;
			this.ApproveLink = '';
			this.ReassignLink = '';
		}
	}
}