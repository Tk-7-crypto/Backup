public class EXT_CRM_Lead_AddToCampaign {
        public Set<Id> leadIdSet = new Set<Id>();
        public CampaignMember cmp{get;set;}
        public Boolean hasRecords{get;set;}
        public Boolean isSuccess{get;set;}
        public Id campaignId{get;set;}
        public Integer selectedLeadCount{get;set;}
        public Boolean isMultipleSelected{get;set;}
        public Boolean isSingleRecordselected{get;set;}
        public Boolean isMemberExisting{get;set;}
        public Integer existingMemberCount{get;set;}
        private List<CampaignMember> campaignMember = new List<CampaignMember>();
        
        public EXT_CRM_Lead_AddToCampaign(ApexPages.StandardSetController controller) {
            cmp = new CampaignMember();
            this.hasRecords = false;
            this.isSuccess = false;
            this.isMultipleSelected = false;
            this.isSingleRecordselected = false;
            this.isMemberExisting = false;
            this.selectedLeadCount = 0;
            this.existingMemberCount = 0;
            
            List<Lead> leadList = (List<Lead>)controller.getSelected();
            selectedLeadCount = leadList.size();
            if(selectedLeadCount>0){
                if(selectedLeadCount==1){
                    this.isSingleRecordselected = true;
                }else{
                    this.isMultipleSelected = true;
                }
                for(Lead lead : leadList) {
                    leadIdSet.add(lead.Id);
                }
                this.hasRecords = true;
            }else{
                String errorMessage = 'Select at least one record and try again.';
                ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR,  errorMessage);            
                ApexPages.addMessage(error);
            }
        }
        
        public List<SelectOption> getStatusOptions() {
            List<SelectOption> statusOptions = new List<SelectOption>();
            statusOptions.add(new SelectOption('Sent','Sent'));
            statusOptions.add(new SelectOption('Responded','Responded'));
            
            return statusOptions;
        }
        
        public PageReference AddToCampaignRecords() {
            
            List<CampaignMember> existingMemberList = new List<CampaignMember>();
            Set<Id> existingMemberIdSet = new Set<Id>();           
            this.campaignId = cmp.CampaignId;
            
            existingMemberList = [SELECT Id, CampaignId, Name, LeadId, Status FROM CampaignMember where CampaignId =: campaignId];
            System.debug('existingMemberList ' + existingMemberList);
            for(CampaignMember cmpMember : existingMemberList) {
                if(cmpMember.leadId != null){
                    existingMemberIdSet.add(cmpMember.leadId);
                }
            }
            if(leadIdSet.size()>0 && existingMemberIdSet.size()>0){
                for(Id eMemId : existingMemberIdSet){
                    for(Id leadId : leadIdSet){
                        if(eMemId.equals(leadId)){
                            leadIdSet.remove(leadId);
                            existingMemberCount++;
                        }
                    }
                }
                if(existingMemberCount>0){
                    this.isMemberExisting = true;
                }
                addLeadsToCampaign(leadIdSet);
                
            }else if(leadIdSet.size()>0 ){
                addLeadsToCampaign(leadIdSet);
                return null;
            }else{
                //No records in the lead Set to add, returns to lead list view
                return new PageReference('/00Q/o');
            }
            return null;
        }
        
        public PageReference addLeadsToCampaign(Set<Id> leadIdSet){
            for(Id leadId : leadIdSet) {
                campaignMember.add(new CampaignMember(LeadId = leadId, status= cmp.status, campaignid = cmp.campaignid));
            }
            try{
                insert campaignMember;
                this.isSuccess = true;
                System.debug('Insert success');
            } catch(Exception e) {
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, e.getMessage()));
                return null;
            }
            return null;
        }
    }