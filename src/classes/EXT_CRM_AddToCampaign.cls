public class EXT_CRM_AddToCampaign {
        public Set<Id> contactIdSet = new Set<Id>();
        public CampaignMember cmp{get;set;}
        public Boolean hasRecords{get;set;}
        public Boolean isSuccess{get;set;}
        public Id campaignId{get;set;}
        public Integer selectedContactCount{get;set;}
        public Boolean isMultipleSelected{get;set;}
        public Boolean isSingleRecordselected{get;set;}
        public Boolean isMemberExisting{get;set;}
        public Integer existingMemberCount{get;set;}
        private List<CampaignMember> campaignMember = new List<CampaignMember>();
        
        public EXT_CRM_AddToCampaign(ApexPages.StandardSetController controller) {
            cmp = new CampaignMember();
            this.hasRecords = false;
            this.isSuccess = false;
            this.isMultipleSelected = false;
            this.isSingleRecordselected = false;
            this.isMemberExisting = false;
            this.selectedContactCount = 0;
            this.existingMemberCount = 0;
            
            List<Contact> contactList = (List<Contact>)controller.getSelected();
            selectedContactCount = contactList.size();
            if(selectedContactCount>0){
                if(selectedContactCount==1){
                    this.isSingleRecordselected = true;
                }else{
                    this.isMultipleSelected = true;
                }
                for(Contact contact : contactList) {
                    contactIdSet.add(contact.Id);
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
            
            existingMemberList = [SELECT Id, CampaignId, Name, ContactId, Status FROM CampaignMember where CampaignId =: campaignId];
             System.debug('existingMemberList ' + existingMemberList);
            for(CampaignMember cmpMember : existingMemberList) {
                if(cmpMember.contactId != null){
                    existingMemberIdSet.add(cmpMember.contactId);
                }
            }
            
            if(contactIdSet.size()>0 && existingMemberIdSet.size()>0){
                for(Id eMemId : existingMemberIdSet){
                    for(Id contactId : contactIdSet){
                        if(eMemId.equals(contactId)){
                            contactIdSet.remove(contactId);
                            existingMemberCount++;
                        }
                    }
                }
                if(existingMemberCount>0){
                    this.isMemberExisting = true;
                }
                addContactsToCampaign(contactIdSet);
                
            }else if(contactIdSet.size()>0 ){
                addContactsToCampaign(contactIdSet);
                return null;
            }else{
                //No records in the contact Set to add, returns to contact list view
                return new PageReference('/003/o');
            }
            return null;
        }
        
        public PageReference addContactsToCampaign(Set<Id> contactIdSet){
            for(Id contactId : contactIdSet) {
                campaignMember.add(new CampaignMember(ContactId = contactId, status= cmp.status, campaignid = cmp.campaignid));
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