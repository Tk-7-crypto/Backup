public class MI_BNF_Approval_Extension {
    
    public String ApproverComments {public get;public set;}
    public MIBNF_Component__c BNF {public get;private set;}
    private ApexPages.StandardController StandardController;
    public String RejectionReason {public get;public set;}
    public String MissingApproval {public get;public set;} //added by rashi
    public static Boolean BnfAttachmentCheckOverride = false;
    private User CurrentUser;
    public Boolean AllowedToApprove {public get;private set;}
    public static Boolean CustomApprovalPage = false;
    public Boolean IsRejected {public get;public set;}
    public String ErrorMessage {public get;private set;}    
    public String ErrorMessage2 {public get;private set;} // added by Himanshu Parashar : 5 Sep 2013
    public String classRejectionReason{public get;private set;}
    public String classMissingApproval{public get;private set;} //added by rashi
    public String classRevenueAnalyst {public get;private set;} // added by Himanshu Parashar : 5 Sep 2013
    public Id Original_RA_Id; // added by Himanshu Parashar : 5 Sep 2013
    public Boolean AdHoc {public get;private set;}
    public Boolean SapMasterContractRendered {public get;private set;}
    public Boolean SapContractRendered {public get;private set;}
    private Boolean hasAccessBNFAll;
    
    public String SelectedRejectionReason{get;set;} // added by Himanshu Parashar : 4 April 2013
    public String SelectedMissingApproval{get;set;} // added by rashi
    private String lastRA;
 
    // Constructor function
    public MI_BNF_Approval_Extension(ApexPages.StandardController controller)
    {
        this.StandardController = controller;
        this.BNF = (MIBNF_Component__c)StandardController.getRecord();
        // added for Issue-10024 14 march 2017
        this.BNF = [Select Id,BNF_status__c,Rejection_Reasons_Multi__c,Rejection_Reasons__c,Missing_Approval__c,SAP_Master_Contract__c, MIBNF__r.SAP_Master_Contract__c, Manual_Handling_in_SAP__c, MIBNF__r.Renewal__c, First_RA__c, Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c, Comp_Revenue_Analyst__r.RA_Sales_Orgs__c, Sales_org_code__c, Comp_Revenue_Analyst__c, SAP_SD_Error_Message__c, Name, MIBNF__c, Sap_Contract__c, Comp_Revenue_Analyst__r.Revenue_Analyst_Email__c from MIBNF_Component__c where id = :this.BNF.id];
        // added by Himanshu Parashar : 4 April 2013
        //this.BNF.Rejection_Reasons__c = null;
        this.BNF.Rejection_Reasons_Multi__c = null;
       // this.BNF.SAP_SD_Error_Message__c = null;
        this.CurrentUser = [select Id,Profile.Name from User where Id = :userInfo.getUserId()];
        this.AllowedToApprove = false;
        this.ErrorMessage = '';
        this.classRejectionReason ='';
        this.SelectedRejectionReason=''; // added by Himanshu Parashar : 4 April 2013
        this.classMissingApproval ='';
        this.SelectedMissingApproval=''; // added by rashi
        this.AdHoc = false;
        hasAccessBNFAll = false;
        if (!AdHoc && (BNF.MIBNF__r.SAP_Master_Contract__c==null && (BNF.Manual_Handling_in_SAP__c || BNF.MIBNF__r.Renewal__c)))    
        {
            this.SapMasterContractRendered = true;
        }               
        else
        {
            this.SapMasterContractRendered = false;
        }
        this.SapContractRendered=this.BNF.Manual_Handling_in_SAP__c;
        this.classRevenueAnalyst = '';
        lastRA = this.BNF.First_RA__c;
        //  Store ID of local office RA 
        if (this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == false ||
        (this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
        this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
        !String.valueof(this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.Sales_org_code__c)
        ))
        
        
        {
            this.BNF.First_RA__c = (Id)this.BNF.Comp_Revenue_Analyst__c;
            List<MIBNF_Component__c> mcComp=[select id,Comp_Revenue_Analyst__c from MIBNF_Component__c 
            where MIBNF__c=: this.BNF.MIBNF__c and  id!=: this.BNF.id and BNF_Status__c
                                                 IN ('LO Accepted','RA Accepted','SAP Contract Confirmed') limit 1];
            if(mcComp.size()>0)                                     
            {
                this.BNF.Comp_Revenue_Analyst__c = mcComp[0].Comp_Revenue_Analyst__c;
            }
            else
            {
                this.BNF.Comp_Revenue_Analyst__c = null;
            }
            
            this.SapMasterContractRendered = false;
            this.SapContractRendered=false;
        }   
        
        
        
    } 
    
    public pageReference Init()
    {
        
        //  Check whether BNF is currently pending approval
        ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.BNF.Id];        
        
        //Get All Delegate Approvar list.
        set<ID> ActorIdset = new set<ID>();
        for (ProcessInstanceWorkitem P2:P_array)
        {
          ActorIdset.add(P2.ActorId);
        }      
        
        if(ActorIdset.size() > 0)
        {
            //Get Delegate approvers or all Approval process actor id
            for(User DelegateApproverUser :[select DelegatedApproverId from User where Id in : ActorIdset])
            {
                if(DelegateApproverUser.DelegatedApproverId!=null)
                    ActorIdset.add(DelegateApproverUser.DelegatedApproverId);
            }
        }        
        
        if (P_array.size() == 0)
        {
            pageReference retUrl = new pageReference('/'+this.BNF.Id);
            retUrl.setRedirect(true); 
            return retUrl;
        }
        else
        {
            //for (ProcessInstanceWorkitem P2:P_array)
            //{
            List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
                if(permSetAssList.size() > 0) {
                    hasAccessBNFAll = true;
                }
                if (ActorIdset.contains(this.CurrentUser.Id) ||  Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',this.CurrentUser.Profile.Name.toLowerCase()) || hasAccessBNFAll)
                {
                    AllowedToApprove = true;
                }
            //}
          
            
            if (!AllowedToApprove)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have sufficient permissions to approve this BNF.  Please click <a href="/'+this.BNF.Id+'">here</a> to go back to the BNF.');
                ApexPages.addMessage(myMsg);                  
            }
            String ErrorMsg;
            List<MI_BNF_LineItem__c> MIBNF_OLI_List = new List<MI_BNF_LineItem__c>([SELECT MIBNF_Component__c,Opportunity_Line_Itemid__c FROM MI_BNF_LineItem__c where MIBNF_Component__c = :this.BNF.Id]);
            Set<Id> OLI_Id_Set = new Set<Id>();
            for (MI_BNF_LineItem__c MIBNF_OLI:MIBNF_OLI_List)
            {
                OLI_Id_Set.add(MIBNF_OLI.Opportunity_Line_Itemid__c);
            }
            List<OpportunityLineItem> OLI_List = new List<OpportunityLineItem>([select Id,Billing_Frequency__c,Proj_Rpt_Frequency__c from OpportunityLineItem where Id in:OLI_Id_Set]);
            this.AdHoc = true;
            for (OpportunityLineItem OLI:OLI_List)
            {
                if (OLI.Billing_Frequency__c != 'Once' || OLI.Proj_Rpt_Frequency__c != 'Once [O]')
                {
                    this.AdHoc = false;
                }
            }
            if (this.BNF.MIBNF__r.Renewal__c && this.BNF.MIBNF__r.SAP_Master_Contract__c == null && SapMasterContractRendered)
            {
                  if (this.AdHoc)
                  {
                      ErrorMsg = 'This BNF is marked for renewal but appears to have ad hoc line items (billing frequency = once and delivery frequency = once). This should not be a valid option for renewals.';
                      ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,ErrorMsg);
                      ApexPages.addMessage(myMsg2);
                  }
                  else
                  {
                      ErrorMsg = 'This BNF is marked for renewal. Before approving you will need to enter the 10 digit SAP master contract number under which this contract should be created.';
                      ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.INFO,ErrorMsg);
                      ApexPages.addMessage(myMsg1);
                  }
            }
            if (this.BNF.Manual_Handling_in_SAP__c && SapContractRendered)
            {                  
                  if ( this.BNF.MIBNF__r.SAP_Master_Contract__c != null)
                  {
                      ErrorMsg = 'This BNF is marked for manual handling in SAP. Before approving you will need to create the contract in SAP and enter the SAP contract number below.';
                  }
                  else if (this.AdHoc == false)
                  {
                      ErrorMsg = 'This BNF is marked for manual handling in SAP. Before approving you will need to create the master and standard contract in SAP and enter the SAP contract numbers below.';              
                  }
                  else if (this.AdHoc == true)
                  {
                      ErrorMsg = 'This BNF is marked for manual handling in SAP. Before approving you will need to create the standard contract in SAP and enter the SAP contract number below.';                                
                  }
                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,ErrorMsg);
                  ApexPages.addMessage(myMsg);
            }
            return null;  
        }
    }  
    
    // Approve BNF
    public pageReference Approve()
    {
        try
        {
             if (this.BNF.Comp_Revenue_Analyst__c == null)
            {
                this.ErrorMessage2 = 'Please select a SAP Revenue Analyst to whom the BNF will be assigned';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage2);
                ApexPages.addMessage(myMsg);                
                this.classRevenueAnalyst = 'error';
                return null;
            }
            
            if(this.BNF.Comp_Revenue_Analyst__c!=null && this.BNF.First_RA__c!=null)
            {
                //Issue-10284 start
                /*List<MIBNF_Component__c> mcComp=[select id,Name,Comp_Revenue_Analyst__c,Comp_Revenue_Analyst__r.Name,Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c,Comp_Revenue_Analyst__r.RA_Sales_Orgs__c from MIBNF_Component__c
                                                 where MIBNF__c=: this.BNF.MIBNF__c and  id!=: this.BNF.id and BNF_Status__c
                                                 IN ('LO Accepted','RA Accepted','SAP Contract Confirmed') limit 1];
                                                 
                if(mcComp.size()>0 && (this.BNF.Comp_Revenue_Analyst__c !=mcComp[0].Comp_Revenue_Analyst__c))
                {
                    this.ErrorMessage2 = 'Another MIBNF ('+mcComp[0].Name+') belonging to the same MIBNF header has already been approved to SAP revenue analyst '+ mcComp[0].Comp_Revenue_Analyst__r.Name + '.  All MIBNF\'s must be approved to the same SAP revenue analyst.';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage2);
                    ApexPages.addMessage(myMsg);                
                    this.classRevenueAnalyst = 'error';
                    return null;
                }*/
                //Issue-10284 end
                
                
                Revenue_Analyst__c rc=[select Is_SAP_Revenue_Analyst__c,RA_Sales_Orgs__c,Available_for_Selection__c from Revenue_Analyst__c where id=:this.BNF.Comp_Revenue_Analyst__c];
                if(rc.Available_for_Selection__c == 'FALSE'){
                    this.ErrorMessage2 = 'Revenue Analyst does not have any active users. Please select a valid Revenue Analyst .';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage2);
                    ApexPages.addMessage(myMsg);                
                    this.classRevenueAnalyst = 'error';
                    return null;
                }
                if((rc.Is_SAP_Revenue_Analyst__c!=null && rc.Is_SAP_Revenue_Analyst__c==false) ||
                (rc.Is_SAP_Revenue_Analyst__c == true && rc.RA_Sales_Orgs__c!=null &&
                 !(String.valueof(rc.RA_Sales_Orgs__c).contains(this.BNF.Sales_org_code__c))
                ))
                {
                    this.ErrorMessage2 = 'Please select a SAP Revenue Analyst to whom the BNF will be assigned';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage2);
                    ApexPages.addMessage(myMsg);                
                    this.classRevenueAnalyst = 'error';
                    return null;
                }
            }
            
        
            if (SapMasterContractRendered && BNF.Sap_Master_Contract__c == null)
            {
                BNF.Sap_Master_Contract__c.addError('Please enter a SAP master contract number');
                return null;
            }
            if (BNF.Manual_Handling_In_Sap__c && BNF.Sap_Contract__c == null && SapContractRendered)
            {
                BNF.Sap_Contract__c.addError('Please enter a SAP standard contract number');
                return null;
            }
            CustomApprovalPage = true;
            system.debug('Approving');
            ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.BNF.Id];           
            // New code 16/8/2016
            Set<ID> userIdsSet = new Set<ID>();
            Map<ID, ID> userToDelegatedUser = new Map<ID, ID>();
            for(ProcessInstanceWorkitem item : P_array){
                userIdsSet.add(item.ActorId);
            }
            
            if(userIdsSet.size() > 0) {
                for(User usr: [select Id, DelegatedApproverId from User where id IN: userIdsSet]){
                    userToDelegatedUser.put(usr.Id, usr.DelegatedApproverId);
                }
            }            
            // END code 16/8/2016
            ProcessInstanceWorkitem P;
            //  If only one approver is involved or a sys admin is viewing, then just take the first ProcessInstanceWorkItem
            //if (P_array.size() == 1 || Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',this.CurrentUser.Profile.Name.toLowerCase()))
            if (Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',this.CurrentUser.Profile.Name.toLowerCase()) || hasAccessBNFAll)
            {      
                P = P_array[0];          
            }
            //  Else if multiple approvers are involved, find the ProcessInstanceWorkItem belonging to the current user
            else
            {              
                for (ProcessInstanceWorkitem P2:P_array)
                {
                    //if (P2.ActorId == this.CurrentUser.Id)                    
                    if ((P2.ActorId == this.CurrentUser.Id) || (userToDelegatedUser.get(P2.ActorId) != null && this.CurrentUser.Id == userToDelegatedUser.get(P2.ActorId)))
                    
                    {
                        P = P2;
                    }
                }
            }
            // If Approver not found
            if(P == null) {
                this.ErrorMessage2 = 'BNF has already been approved. Please click <a href="/'+this.BNF.Id+'">here</a> to go back to the BNF.';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage2);
                ApexPages.addMessage(myMsg);                
                this.classRevenueAnalyst = 'error';
                return null;
            }
                        
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(this.ApproverComments);
            req.setAction('Approve');
            req.setWorkitemId(P.Id);
            //Updated By Himanshu Parashar : 4 April 2013
            //this.BNF.Rejection_Reasons__c = this.RejectionReason;
            this.BNF.Rejection_Reasons_Multi__c = this.SelectedRejectionReason != '' ? this.SelectedRejectionReason : this.SelectedMissingapproval;
            this.BNF.SAP_SD_Error_Message__c = this.ApproverComments ;
           	if(this.SelectedMissingApproval != ''){
                if(this.BNF.Rejection_Reasons_Multi__c == ''){
                    this.BNF.Rejection_Reasons_Multi__c = this.SelectedMissingApproval;
                } else{
               	 	this.BNF.Rejection_Reasons_Multi__c += ';' + this.SelectedMissingApproval;
                }
                this.BNF.Missing_Approval__c = this.SelectedMissingApproval;
            } 
            //Approving Request
          /*  if((this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == false ||
            (this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
            this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
            !String.valueof(this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.IMS_Sales_org__c)
            )))
                    this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED');
            else if((this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true ||
            (this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
            this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
            String.valueof(this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.IMS_Sales_org__c)
            )))
                    this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED');
                else
                    this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('ACCEPTED');
            */
            
            
            update this.BNF;
            Approval.ProcessResult result2 = Approval.process(req);
            AttachPdf(this.BNF.Id,this.BNF.MIBNF__c,this.BNF.Name,userInfo.getFirstName() + '_' + userInfo.getLastName(),datetime.now());
            pageReference retUrl = new pageReference('/'+this.BNF.Id);
            retUrl.setRedirect(true);
            return retUrl;
        }
        catch (Exception E)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,E.getMessage());
            System.debug('error==='+myMsg);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    //Reject BNF
    public pageReference Reject()
    {
        system.debug('Starting Reject()');
        try
        {
            //Updated by Himanshu Parashar : 4 April 2013
            if (this.SelectedRejectionReason == null && this.SelectedMissingApproval == null)
            //if (this.RejectionReason == null)
            {
                this.ErrorMessage = 'Please specify either a rejection reason or missing approval';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage);
                ApexPages.addMessage(myMsg);                
                this.classRejectionReason = 'error';
                return null;
            }
            ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.BNF.Id];           
            ProcessInstanceWorkitem P;            
            //  If only one approver is involved or a sys admin is viewing, then just take the first ProcessInstanceWorkItem
            if (P_array.size() == 1 || Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',this.CurrentUser.Profile.Name.toLowerCase()) || hasAccessBNFAll)
            {      
                P = P_array[0];          
            }
            //  Else if multiple approvers are involved, find the ProcessInstanceWorkItem belonging to the current user
            else
            {              
                for (ProcessInstanceWorkitem P2:P_array)
                {
                    if (P2.ActorId == this.CurrentUser.Id)
                    {
                        P = P2;
                    }
                }
            }
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(this.ApproverComments);
            req.setAction('Reject');
            req.setWorkitemId(P.Id);
            // commented for  Issue-10024 14 march 2017
            // Setting 
             //Issue : Issue-08434
             /*if(this.BNF.First_RA__c!=null) 
                this.BNF.Comp_Revenue_Analyst__c = this.BNF.First_RA__c;*/
                
             if(this.BNF.First_RA__c != null && (this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED'))) {
                this.BNF.Comp_Revenue_Analyst__c = this.BNF.First_RA__c;
                this.BNF.First_RA__c = lastRA;
             } 
             // updated by dheeraj kumar 20 april 2017
             else if (this.BNF.First_RA__c != null && 
            		(this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') ||
            		this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED') ||
            		this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED')
            		)) {
                                 this.BNF.Last_RA_Email__c = this.BNF.Comp_Revenue_Analyst__r.Revenue_Analyst_Email__c;
        		 	this.BNF.First_RA__c = (Id)this.BNF.Comp_Revenue_Analyst__c;
           			this.BNF.Comp_Revenue_Analyst__c = lastRA;
               	} 
            //added by Himanshu Parashar : 4 April 2013
            this.BNF.Rejection_Reasons_Multi__c=this.SelectedRejectionReason != '' ? this.SelectedRejectionReason : this.SelectedMissingapproval;
           // this.BNF.Rejection_Reasons__c = this.RejectionReason;
            this.BNF.SAP_SD_Error_Message__c = this.ApproverComments ;
            
            if(this.SelectedMissingApproval != ''){
                if(this.BNF.Rejection_Reasons_Multi__c == ''){
                    this.BNF.Rejection_Reasons_Multi__c = this.SelectedMissingApproval;
                } else{
                    this.BNF.Rejection_Reasons_Multi__c += ';' + this.SelectedMissingApproval;
                }
                this.BNF.Missing_Approval__c = this.SelectedMissingApproval;
            }
           /* if(this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == false || 
            (this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c!=null &&
                 !(String.valueof(this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.Sales_org_code__c))
            )
            )
                this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('LO_REJECTED');
            else if((this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c==null) ||
            (this.BNF.Comp_Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c!=null &&
                 (String.valueof(this.BNF.Comp_Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.Sales_org_code__c))
            )
            )
                this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('RA_REJECTED');
            else
                this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('REJECTED');
            */
            
            update this.BNF;
            Approval.ProcessResult result2 = Approval.process(req);
            pageReference retUrl = new pageReference('/'+this.BNF.Id);
            retUrl.setRedirect(true);
            return retUrl;
        }
        catch (Exception E)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,E.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    } 
    
     //@future
    Public static void AttachPdf(String BnfId,String MIBnfId,String BnfName,String ApproverName,Datetime ApprovalDate)
    {
        // updated by dheeraj kumar ER 3208 start
        pageReference pdf = Page.MI_BNF_Comp_Changes_PDF;
        // updated by dheeraj kumar ER 3208 end
        pdf.getParameters().put('id',BnfId);
        pdf.getParameters().put('mibnfid',MIBnfId);
        Blob pdfContent;
        try
        {
            pdfContent = pdf.getContent();
        }
        catch(VisualforceException e)
        {
            pdfContent = Blob.valueOf('Error occured');
        }
       
        
        String FileName = 'BNF_'+BnfName+'_Accepted_by_'+ApproverName+ '_on_' + ApprovalDate.formatGmt('yyyy-MM-dd HH:mm:ss z') + '.pdf';
        
        FileName = FileName.replace('/', '_');
        FileName = FileName.replace('\\', '_'); 
        Attachment doc = new Attachment(
            ParentId = BnfId,
            Body = pdfContent,
            Name = FileName,
            ContentType = 'application/pdf');     
        BnfAttachmentCheckOverride = true;            
        insert doc;
        BnfAttachmentCheckOverride = false;
    }
    
    /**
    public List<Selectoption> getRejectionReasons()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = MIBNF_Component__c.Rejection_Reasons__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '- None -'));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        return options;         
    } **/
    
    // Added By : Himanshu Parashar
    // Date : 4 April 2013
    // Show Rejection reason as checkboxes
    public List<List<Selectoption>> getRejectionReasons()
    {
        List<List<SelectOption>> tempRejectionItems= new List<List<SelectOption>>();
        Integer colCount = 0;
        
        List<SelectOption>  tempRejectionList1 = new List<SelectOption>();
        List<SelectOption>  tempRejectionList2 = new List<SelectOption>();
        List<SelectOption>  tempRejectionList3 = new List<SelectOption>();
        
        // Getting Rejection reasons
        Schema.DescribeFieldResult fieldResult = MIBNF_Component__c.Rejection_Reasons__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Integer x = Integer.valueOf(ple.size()/3);
        
        for(Schema.PicklistEntry f : ple){
            if(colCount/x <= 0){
                tempRejectionList1.add(new SelectOption(f.getLabel(), f.getValue()));
            }
            else if(colCount/x <= 1){
                tempRejectionList2.add(new SelectOption(f.getLabel(), f.getValue()));
            }
            else{
                tempRejectionList3.add(new SelectOption(f.getLabel(), f.getValue()));
            }
            colCount = colCount + 1;
        }
        
        if(tempRejectionList1.size() > 0)   tempRejectionItems.add(tempRejectionList1);
        if(tempRejectionList2.size() > 0)   tempRejectionItems.add(tempRejectionList2);
        if(tempRejectionList3.size() > 0)   tempRejectionItems.add(tempRejectionList3);
          
        return tempRejectionItems;         
    }
    
    /** 
     * This method is used to get Missing Approval values
     * @return  List<List<Selectoption>> (Missing_Approval__c picklist values)
     */
    public List<List<Selectoption>> getMissingApprovals()
    {
        List<List<SelectOption>> tempMissingApprovals= new List<List<SelectOption>>();
        Integer colCount = 0;
        
        List<SelectOption>  tempMissingApproval1 = new List<SelectOption>();
        List<SelectOption>  tempMissingApproval2 = new List<SelectOption>();
        List<SelectOption>  tempMissingApproval3 = new List<SelectOption>();
        
        // Getting Missing Approvals
        Schema.DescribeFieldResult fieldResult = MIBNF_Component__c.Missing_Approval__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Integer x = Integer.valueOf(ple.size()/3);
        
        for(Schema.PicklistEntry f : ple){
            if(colCount/x <= 0){
                tempMissingApproval1.add(new SelectOption(f.getLabel(), f.getValue()));
            }
            else if(colCount/x <= 1){
                tempMissingApproval2.add(new SelectOption(f.getLabel(), f.getValue()));
            }
            else{
                tempMissingApproval3.add(new SelectOption(f.getLabel(), f.getValue()));
            }
            colCount = colCount + 1;
        }
        
        if(tempMissingApproval1.size() > 0)   tempMissingApprovals.add(tempMissingApproval1);
        if(tempMissingApproval2.size() > 0)   tempMissingApprovals.add(tempMissingApproval2);
        if(tempMissingApproval3.size() > 0)   tempMissingApprovals.add(tempMissingApproval3);
          
        return tempMissingApprovals;         
    }
}