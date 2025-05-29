public without sharing class ApprovalItems {
    public transient List<ItemWrapper> ItemWrapperList {get; set;}
    //private static Map<String, Schema.SObjectType> gd;
    private static Map<String, String> gd;
    private transient Set<Id> memberOfQueue = new Set<Id>();
    public boolean isShowHeader {get;set;}
    public boolean isShowsidebar {get;set;}
    public boolean checkboxAllValue {get;set;}
    public Integer itemPageSize {get;set;}
    public Integer itemTotalRecord {get;set;}
    public Integer itemTotalPages {get;set;}
    public Integer itemPageNumber{get;set;}
    public List<ItemWrapper> itemListOfToShow {get; set;}
    public Integer itemPageSizeMultiplier{get;set;} 
    // Added by Pramod
    private String bnfObjectPrefix {get; set;}
    private String mibnfObjectPrefix {get; set;}
    public Map<Id,Boolean> approvalItems {get; set;}
    public List<Id> bnfList {get; set;}
    public List<Id> miBnfList {get; set;}
    public Boolean displayInfoRelatedToProposal {get; set;}
    
    public ApprovalItems(ApexPages.StandardController ex) { 
        if(ApexPages.currentPage().getParameters().get('isShowHeader') == 'true') {
            isShowHeader = true;
            isShowsidebar = true;        
        } else {
            isShowHeader = false;
            isShowsidebar = false;
        }
        
        setItemWrapperValues();
        itemPageNumber = 1;
        if(isShowsidebar)
            itemPageSize = 100;
        else
            itemPageSize = 50;    
        itemPageSizeMultiplier = 1; 
        itemTotalRecord = ItemWrapperList.size();
        itemTotalPages = itemTotalRecord / itemPageSize;
        if(Math.mod(itemTotalRecord,itemPageSize) != 0 ){
            itemTotalPages++;
        }
        reCalculateItemWrapperList();
        //Added by Pramod
        this.bnfObjectPrefix  = BNF2__c.sObjectType.getDescribe().getKeyPrefix();
        this.mibnfObjectPrefix  = MIBNF_Component__c.sObjectType.getDescribe().getKeyPrefix();
    }
    
    // Dilip for Case -00280089 03-Feb-2017 start
    private void setItemWrapperValues(){
        displayInfoRelatedToProposal = false;
        bnfList = new List<Id>();
        miBnfList = new List<Id>();
        approvalItems = new Map<Id,Boolean>();
        memberOfQueue = new Set<Id>();
        memberOfQueue.add(UserInfo.getUserId());
        for(GroupMember g : [Select Group.Id From GroupMember where UserOrGroupId = :UserInfo.getUserId() and Group.Type = 'Queue']) {
            memberOfQueue.add(g.Group.Id);
        }
        Set<String> targetObjectType = new Set<String>{'BNF2__c','MIBNF_Component__c','Opportunity','Apttus_Proposal__Proposal__c'};
        List<ProcessInstanceWorkitem> pendingItems = new List<ProcessInstanceWorkitem>();
        if(isShowsidebar){
            pendingItems = [SELECT ActorId, Actor.Name, Actor.Email, CreatedDate, CreatedBy.Name,CreatedById,
                            ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name,ProcessInstance.TargetObject.Type
                            FROM ProcessInstanceWorkitem WHERE ActorId in :memberOfQueue AND ProcessInstance.Status = 'Pending' order by CreatedDate DESC];
        } else{
            pendingItems = [SELECT ActorId, Actor.Name, Actor.Email, CreatedDate, CreatedBy.Name,CreatedById,
                            ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name,ProcessInstance.TargetObject.Type
                            FROM ProcessInstanceWorkitem WHERE ActorId in :memberOfQueue AND ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type IN : targetObjectType order by CreatedDate DESC limit 50];
        }
        //gd = Schema.getGlobalDescribe();
        gd = new Map<String,String>();
        gd.put('MIBNF_Component__c','BNF');
        gd.put('BNF2__c','Purchase/BNF');
        gd.put('Apttus_Proposal__Proposal__c','Quote/Proposal');
        ItemWrapperList = new List<ItemWrapper> ();
        
        for(ProcessInstanceWorkitem wi : pendingItems) {
            ItemWrapper i = new ItemWrapper(wi);
            if(i.tName == 'BNF')   
                miBnfList.add(i.i.ProcessInstance.TargetObjectId);
            if(i.tName == 'Purchase/BNF')   
                bnfList.add(i.i.ProcessInstance.TargetObjectId);
            if(i.tName == 'Quote/Proposal')   
                displayInfoRelatedToProposal = true;
            ItemWrapperList.add(i);
        }
        
        Map<Id,BNF2__c> bnftmpList = new Map<Id,BNF2__c> ([SELECT Id, Revenue_Analyst__r.Owner.type, Opportunity__c, Opportunity__r.Name, Opportunity__r.Opportunity_Number__c FROM BNF2__c Where Id In :bnfList]);
        for(BNF2__c bnf : bnftmpList.values()) {
            approvalItems.put(bnf.Id, bnf.Revenue_Analyst__r.Owner.type == 'Queue');
        }
        
        Map<Id,MIBNF_Component__c> mibnftmpList =new Map<Id,MIBNF_Component__c> ([SELECT Id, Comp_Revenue_Analyst__r.Owner.type, Opportunity__c, Opportunity__r.Name, Opportunity__r.Opportunity_Number__c FROM MIBNF_Component__c Where Id In :miBnfList]);
        for(MIBNF_Component__c mibnf : mibnftmpList.values()) {
            approvalItems.put(mibnf.Id, mibnf.Comp_Revenue_Analyst__r.Owner.type == 'Queue');
        }
        
        for(ItemWrapper wi : ItemWrapperList) {
            if(wi.tName == 'BNF'){
                if(mibnftmpList.containsKey(wi.i.ProcessInstance.TargetObjectId)){
                    wi.opportunityId = mibnftmpList.get(wi.i.ProcessInstance.TargetObjectId).Opportunity__c;
                    wi.opportunityName = mibnftmpList.get(wi.i.ProcessInstance.TargetObjectId).Opportunity__r.Name;
                    wi.OpportunityNumber = mibnftmpList.get(wi.i.ProcessInstance.TargetObjectId).Opportunity__r.Opportunity_Number__c;
                }
            }
            if(wi.tName == 'Purchase/BNF'){
                if(bnftmpList.containsKey(wi.i.ProcessInstance.TargetObjectId)){
                    wi.opportunityId = bnftmpList.get(wi.i.ProcessInstance.TargetObjectId).Opportunity__c;
                    wi.opportunityName = bnftmpList.get(wi.i.ProcessInstance.TargetObjectId).Opportunity__r.Name;
                    wi.opportunityNumber = bnftmpList.get(wi.i.ProcessInstance.TargetObjectId).Opportunity__r.Opportunity_Number__c;
                }
            }
        }
        
    }
    
    public PageReference ReassignPage(){
        boolean isIteamSelected = false;
        Boolean IsBNF = false;
        Boolean IsNotBNF = false;
        PageReference pageRef ;
        String targerObjectIds = '';
        //Added Issue-10525   30-03-2017 
        Integer numberOfSelectedItems = 0;
        //Ended Issue-10525   30-03-2017
        
        //Added on 19-04-2017 
        List<Id> idList = new List<Id>();
        //Ended Issue-10525   30-03-2017
        for(ItemWrapper wi : itemListOfToShow) {
            if(wi.isSelected)
            {
                isIteamSelected = true;            
                if(String.valueof(wi.i.ProcessInstance.TargetObjectId).startsWith(bnfObjectPrefix) 
                        || String.valueof(wi.i.ProcessInstance.TargetObjectId).startsWith(mibnfObjectPrefix)) {
                    targerObjectIds += String.valueOf(wi.i.ProcessInstance.TargetObjectId) + ','; 
                    IsBNF = true;
                    numberOfSelectedItems++;
                    idList.add(String.valueOf(wi.i.ProcessInstance.TargetObjectId));
                } else {
                    IsNotBNF = true;
                }                
            }   
        }
        
        if(IsBNF && IsNotBNF) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You can\'t select bnf with other ids in same list'));   
            return null;            
        } else if(IsBNF) {
            if(numberOfSelectedItems > 5) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You can\'t select more than 5 bnf or mibnf from the list'));
                return null;    
            }
            for(Id objId : idList) {
                if(approvalItems.containsKey(objId) && approvalItems.get(objId) == true) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'BNF’s assigned to GFSS RA’s cannot be reassigned, they must be rejected and resubmitted'));
                    return null; 
                }
            }
            // show bnf screen and update Issue-10525
            targerObjectIds = targerObjectIds.removeEnd(',');
            pageRef = new PageReference('/apex/BNF_Reassign');
            pageRef.getParameters().put('ids', targerObjectIds);
            pageRef.setRedirect(false);
            return pageRef;
        } else if(IsNotBNF) {
            // goto '/apex/ReassignApprovalItems'
            pageRef = new PageReference('/apex/ReassignApprovalItems');
            pageRef.setRedirect(false);
            return pageRef;
        }
        if(!isIteamSelected)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please select at least one row.')); 
            return null;
        } 
        return null; 
    }
    
    public PageReference ApproveRejectPage(){
        boolean isIteamSelected = false;
        for(ItemWrapper wi : itemListOfToShow) {
            if(wi.isSelected)
            {
                isIteamSelected = true;            
            }       
        }
        if(isIteamSelected)
        { 
            PageReference pageRef = new PageReference('/apex/ApproveRejectApprovalItems');
            pageRef.setRedirect(false);
            return pageRef;
        }
        else
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please select at least one row.'));
            return null;
        }  
    }
    
    //Dilip comments for ER-3150 17-Nov-2016 end
    // Dilip for Case -00280089 31-Jan-2017 start
    public PageReference getSelected() {     
        for(ItemWrapper item :itemListOfToShow)
        {
            item.isSelected = checkboxAllValue;                   
        }       
        return null;
    }
    
    // method to reintialize the list which is shown on page
    private void reCalculateItemWrapperList(){
        itemListOfToShow = new List<ItemWrapper>();
        Integer iterator = (itemPageSize * (itemPageNumber - 1));
        while (iterator < itemPageSize * itemPageNumber){
            if(iterator < itemTotalRecord){
                ItemListOfToShow.add(ItemWrapperList.get(iterator));
                iterator++;
            }else{
                break;
            }
        }
    }
    
    //TimeCard Pagination 
    public Boolean ItemhasNext {  
        get {  
            if(itemPageNumber >= itemTotalPages || itemTotalPages == 0){
                return false;
            }
            return true;
        }  
        set;  
    }  
    
    //Boolean to check if there are more records before the present displaying records  
    public Boolean ItemhasPrevious {  
        get {  
            if(itemPageNumber <= 1 || itemTotalPages == 0){
                return false;
            }
            return true;
        }  
        set;  
    }  
    
    //Returns the previous page of records  
    public PageReference Itemprevious() {  
        itemPageNumber--;
        setItemWrapperValues();
        reCalculateItemWrapperList();
        return null;  
    }  
    
    //Returns the next page of records  
    public PageReference itemNext() {
        itemPageNumber++;
        setItemWrapperValues();   
        reCalculateItemWrapperList();
        //Added by Priyamvada
        itemPageSizeMultiplier++;
        return null;
    }  
    
    //Returns the first page of records  
    public PageReference itemfirstPage() {  
        itemPageNumber = 1; 
        setItemWrapperValues(); 
        reCalculateItemWrapperList();
        return null;
    }  
    
    //Returns the last page of records  
    public PageReference itemlastPage() {  
        itemPageNumber = itemTotalPages;
        setItemWrapperValues();  
        reCalculateItemWrapperList();
        return null;  
    }    
    
    public class ItemWrapper {
        public ProcessInstanceWorkitem i {get; set;}
        public boolean isSelected {get; set;}
        public String tName {get; private set;}
        public string opportunityId{get;set;}
        public string opportunityName{get;set;}
        public string opportunityNumber{get;set;}
        public ItemWrapper (ProcessInstanceWorkitem i1){
            i = i1;
            //tName = gd.get(i.ProcessInstance.TargetObject.Type).getDescribe().getLabel();
            tName = gd.containsKey(i.ProcessInstance.TargetObject.Type) ?  gd.get(i.ProcessInstance.TargetObject.Type) : i.ProcessInstance.TargetObject.Type;
        }
    }
    
}