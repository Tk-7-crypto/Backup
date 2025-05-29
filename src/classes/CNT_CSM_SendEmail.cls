public without sharing class CNT_CSM_SendEmail {
    public string ObjRecId {get; set;}
        public Workflow_Email_Record__c recSendEmail;
        public List<Attachment> attach;
        
        public Workflow_Email_Record__c getSendEmail() {
            if(ObjRecId == null) {
                return null;
            }
            return [SELECT Id, Email_Action__c, content_1__c, content_2__c From Workflow_Email_Record__c Where id=:ObjRecId LIMIT 1];
        }
}
