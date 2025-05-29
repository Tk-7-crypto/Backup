public class BNF_Approval_Extension 
{
    public String ApproverComments {public get;public set;}
    public BNF2__c BNF {public get;private set;}
    private ApexPages.StandardController StandardController;
    public String RejectionReason {public get;public set;}
    public String MissingApproval {public get;public set;} //added by rashi
    public static Boolean BnfAttachmentCheckOverride = false;
    private User CurrentUser;
    public Boolean AllowedToApprove {public get;private set;}
    public static Boolean CustomApprovalPage = false;
    public Boolean IsRejected {public get;public set;}
    public String ErrorMessage {public get;private set;}
    public String ErrorMessage2 {public get;private set;}
    public String classRejectionReason{public get;private set;}
    public String classMissingApproval{public get;private set;} //added by rashi
    public String classRevenueAnalyst {public get;private set;}
    private String lastRA;
    private Boolean hasAccessBNFAll;

    public String SelectedRejectionReason{get;set;} // added by Himanshu Parashar : 5 nov 2012
    public String SelectedMissingApproval{get;set;} // added by rashi
    
    public BNF_Approval_Extension(ApexPages.StandardController controller)
    {
        this.StandardController = controller;
        this.BNF = (BNF2__c)StandardController.getRecord();
        // updated for issue RA approal log Issue-10024
        this.BNF = [Select id, BNF_status__c,Rejection_Reasons__c,Missing_Approval__c,SAP_SD_Error_Message__c,Revenue_Analyst__c ,Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c,Revenue_Analyst__r.RA_Sales_Orgs__c,IMS_Sales_org_code__c,First_RA__c,Rejection_Reasons_Multi__c,RecordTypeId, Name, Revenue_Analyst__r.Revenue_Analyst_Email__c from BNF2__c where id = :this.BNF.id ];
        this.BNF.Rejection_Reasons__c = null;
        this.BNF.SAP_SD_Error_Message__c = null;
        this.CurrentUser = [select Id,Profile.Name from User where Id = :userInfo.getUserId()];
        system.debug('BNF Id: '+this.BNF.Id);
        this.AllowedToApprove = false;
        this.ErrorMessage = '';
        this.classRejectionReason ='';

        this.SelectedRejectionReason=''; // added by Himanshu Parashar : 5 nov 2012

        this.classMissingApproval ='';
        this.SelectedMissingApproval=''; // added by rashi
        this.classRevenueAnalyst = '';
        lastRA = this.BNF.First_RA__c ;
        //  Store ID of local office RA
        // Update By Himanshu : 27 Sep 2013 :  Issue-02612 
        if (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == false ||
        (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
        this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
        !String.valueof(this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.IMS_Sales_org_code__c)
        ))
        {
            this.BNF.First_RA__c = (Id)this.BNF.Revenue_Analyst__c;
            this.BNF.Revenue_Analyst__c = null;
        }
        hasAccessBNFAll = false;

    }
    
    public pageReference Init()
    {
        //  BEGIN DEBUG
       /* if (this.BNF.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id)
        {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'YES: ' + this.BNF.RecordTypeId);
             ApexPages.addMessage(myMsg);  
             return null;
        }
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'NO: ' + this.BNF.RecordTypeId);
             ApexPages.addMessage(myMsg);  
             return null;
        } */
        
        //  END DEBUG
        //  Check whether BNF is currently pending approval
        //  Check whether BNF is currently pending approval
        ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :this.BNF.Id];        
        
        //Get All Delegate Approvar list.
        set<ID> ActorIdset=new set<ID>();
        for (ProcessInstanceWorkitem P2:P_array)
        {
          ActorIdset.add(P2.ActorId);
        }
        
        
        if(ActorIdset.size()>0)
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
            List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
            if(permSetAssList.size() > 0) {
                hasAccessBNFAll = true; 
            }
            if (ActorIdset.contains(this.CurrentUser.Id) || Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',this.CurrentUser.Profile.Name.toLowerCase()) || hasAccessBNFAll)
            {
                AllowedToApprove = true;
            }
          
            if (!AllowedToApprove)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have sufficient permissions to approve this BNF.  Please click <a href="/'+this.BNF.Id+'">here</a> to go back to the BNF.');
                ApexPages.addMessage(myMsg);                  
            }
            return null;  
        }
    }
    
    public pageReference Approve()
    {
        try
        {
            
            if (this.BNF.Revenue_Analyst__c == null)
            {
                this.ErrorMessage2 = 'Please select a SAP Revenue Analyst to whom the BNF will be assigned';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage2);
                ApexPages.addMessage(myMsg);                
                this.classRevenueAnalyst = 'error';
                return null;
            }
            
            // Update By Himanshu : 27 Sep 2013 :  Issue-02612 
            if(this.BNF.Revenue_Analyst__c!=null && this.BNF.First_RA__c!=null)
            {
                Revenue_Analyst__c rc=[select Is_SAP_Revenue_Analyst__c,RA_Sales_Orgs__c,Available_for_Selection__c from Revenue_Analyst__c where id=:this.BNF.Revenue_Analyst__c];
                if(rc.Available_for_Selection__c == 'FALSE'){
                    this.ErrorMessage2 = 'Revenue Analyst does not have any active users. Please select a valid Revenue Analyst .';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage2);
                    ApexPages.addMessage(myMsg);                
                    this.classRevenueAnalyst = 'error';
                    return null;
                }
                if((rc.Is_SAP_Revenue_Analyst__c!=null && rc.Is_SAP_Revenue_Analyst__c==false) ||
                (rc.Is_SAP_Revenue_Analyst__c == true && rc.RA_Sales_Orgs__c!=null &&
             !(String.valueof(rc.RA_Sales_Orgs__c).contains(this.BNF.IMS_Sales_org_code__c))
            ))
                {
                  this.ErrorMessage2 = 'Please select a SAP Revenue Analyst to whom the BNF will be assigned';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,this.ErrorMessage2);
                    ApexPages.addMessage(myMsg);                
                    this.classRevenueAnalyst = 'error';
                    return null;
                }
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
            
            //Update By Himanshu : 11 Dec 2013 : BNF Metrics
            //Approving Request
           /* if((this.BNF.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) && (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == false ||
            (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
            this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
            !String.valueof(this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.IMS_Sales_org_code__c)
            )))
                    this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED');
            
            else if((this.BNF.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) && (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true ||
            (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
            this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
            String.valueof(this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.IMS_Sales_org_code__c)
            )))
                    this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED');
                else
                    this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('ACCEPTED');
            
            */
            update this.BNF;
            Approval.ProcessResult result2 = Approval.process(req);
            AttachPdf(this.BNF.Id,this.BNF.Name,userInfo.getFirstName() + '_' + userInfo.getLastName(),this.BNF.RecordTypeId,datetime.now());
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
    
    public pageReference Reject()
    {
        system.debug('Starting Reject()');
        try
        {
                

            if (this.SelectedRejectionReason == null && this.SelectedMissingApproval == null)
             //added by Himanshu Parashar : 5 nov 2012
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
            //added by Himanshu Parashar : 5 nov 2012
            this.BNF.Rejection_Reasons_Multi__c = this.SelectedRejectionReason != '' ? this.SelectedRejectionReason : this.SelectedMissingapproval;
            if(this.SelectedMissingApproval != ''){
                if(this.BNF.Rejection_Reasons_Multi__c == ''){
                    this.BNF.Rejection_Reasons_Multi__c = this.SelectedMissingApproval;
                } else{
               	 	this.BNF.Rejection_Reasons_Multi__c += ';' + this.SelectedMissingApproval;
                }
                this.BNF.Missing_Approval__c = this.SelectedMissingApproval;
            }
            this.BNF.SAP_SD_Error_Message__c = this.ApproverComments ;

          /*  if((this.BNF.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) && (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == false ||
        (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
        this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
        !String.valueof(this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.IMS_Sales_org_code__c)
        )))
                this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('LO_REJECTED');
            else if((this.BNF.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) && (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true ||
        (this.BNF.Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c == true && 
        this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c!=null && 
        String.valueof(this.BNF.Revenue_Analyst__r.RA_Sales_Orgs__c).contains(this.BNF.IMS_Sales_org_code__c)
        )))
                this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('RA_REJECTED');
            else
                this.BNF.BNF_Status__c=MDM_Defines.BnfStatus_Map.get('REJECTED');
        */    
            CustomApprovalPage = true; 
            if (this.BNF.First_RA__c != null && (this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED'))) {
                this.BNF.Revenue_Analyst__c = this.BNF.First_RA__c;
                this.BNF.First_RA__c = lastRA;
            } else if(this.BNF.First_RA__c != null && 
            	(this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') ||
            	this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED') ||
            	this.BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED')
            	) ){
                this.BNF.Last_RA_Email__c = this.BNF.Revenue_Analyst__r.Revenue_Analyst_Email__c;
                this.BNF.First_RA__c = (Id)this.BNF.Revenue_Analyst__c;
                this.BNF.Revenue_Analyst__c = lastRA;
            }
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
    Public static void AttachPdf(String BnfId,String BnfName,String ApproverName,String BnfRecordTypeId,Datetime ApprovalDate)
    {
        //pageReference pdf = (BnfRecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) ? Page.BNFPDF_MDM : Page.BNFPDF;
        pageReference pdf;
        if (BnfRecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id)
        {
        	// updated by dheerj kumar ER 3208 start
            pdf = Page.BNFChangesPDF_MDM;
            // updated by dheerj kumar ER 3208 end
        }
        else
        {
        	// updated by dheerj kumar ER 3208 start
            pdf = Page.BNFChangesPDF;
            // updated by dheerj kumar ER 3208 end
        }
        pdf.getParameters().put('id',BnfId);
        Blob pdfContent = pdf.getContent();
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


    public List<List<Selectoption>> getRejectionReasons()
    {
        List<List<SelectOption>> tempRejectionItems= new List<List<SelectOption>>();
        Integer colCount = 0;
        
        List<SelectOption>  tempRejectionList1 = new List<SelectOption>();
        List<SelectOption>  tempRejectionList2 = new List<SelectOption>();
        List<SelectOption>  tempRejectionList3 = new List<SelectOption>();
        
        // Getting Rejection reasons
        Schema.DescribeFieldResult fieldResult = BNF2__c.Rejection_Reasons__c.getDescribe();
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
        
        // Getting missing approvals 
        Schema.DescribeFieldResult fieldResult = BNF2__c.Missing_Approval__c.getDescribe();
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