public class EXT_CRM_Note_Detail {
    
    Note__c noteRecord;
    Id redirectId;
    public String noteRecordType{get;private set;}
    
    public EXT_CRM_Note_Detail(ApexPages.StandardController controller) {
        this.noteRecord = (Note__c)controller.getRecord();
        this.noteRecordType = ApexPages.currentPage().getParameters().get('recordType');
        this.redirectId = ApexPages.currentPage().getParameters().get('redirectId');
        if(noteRecord.Id == null) {
            if(noteRecordType == 'BNF_Note') {
                noteRecord.BNF__c = this.redirectId;
            } else if(noteRecordType == 'MIBNF_Note') {
                noteRecord.MIBNF__c = this.redirectId;
            } else if(noteRecordType == 'MIBNF_Component_Note') {
                noteRecord.MIBNF_Component__c = this.redirectId;
            }
            noteRecord.recordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByDeveloperName().get(noteRecordType).getRecordTypeId();
        } else {
            this.noteRecordType = Schema.SObjectType.Note__c.getRecordTypeInfosById().get(noteRecord.recordtypeid).getDeveloperName(); 
            if(noteRecordType == 'BNF_Note') {
                this.redirectId = noteRecord.BNF__c; 
            } else if(noteRecordType == 'MIBNF_Note') {
                this.redirectId = noteRecord.MIBNF__c;
            } else if(noteRecordType == 'MIBNF_Component_Note') {
                this.redirectId = noteRecord.MIBNF_Component__c;
            }
        }
    }
    public PageReference Save() {
        upsert this.noteRecord;
        return new PageReference('/' +  this.redirectId);
    }
    public PageReference Cancel() {
        return new PageReference('/' +  this.redirectId);
    }
}