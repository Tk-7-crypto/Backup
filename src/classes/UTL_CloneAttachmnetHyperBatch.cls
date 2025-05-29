public class UTL_CloneAttachmnetHyperBatch implements HyperBatch {

    public HyperBatchObjects.HyperBatchStart start() {
        return new HyperBatchObjects.HyperBatchStart('Attachment_PlaceHolder__c', 'SELECT IQVIA_Parentid__c, Status__c FROM Attachment_PlaceHolder__c where Status__c = \'Pending\' ');       
    }    
    
    public Object execute(List<sObject> scope) {
        Map<Id, Attachment_PlaceHolder__c> attPlaceHolderMap = new Map<Id, Attachment_PlaceHolder__c>();
        
        for(sobject s : scope) {
            attPlaceHolderMap.put((Id)s.get('Id'), (Attachment_PlaceHolder__c)s);
        }
        
        List<Attachment> listOfAttachment = [Select Id, Name, Body, ParentId, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById from Attachment where ParentId IN :attPlaceHolderMap.keySet()];
        List<Attachment> listOfAttachmnetToInsert = new List<Attachment>();
        Attachment cloneAttachment;
        for(Attachment attach : listOfAttachment) {
            cloneAttachment = attach.clone(false, true, true, false);
            cloneAttachment.ParentId = attPlaceHolderMap.get(attach.ParentId).IQVIA_Parentid__c;
            listOfAttachmnetToInsert.add(cloneAttachment);
        }
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        if(listOfAttachmnetToInsert.size() > 0) {
            srList = Database.insert(listOfAttachmnetToInsert, false);
        }
        
        for(Attachment_PlaceHolder__c attachRecord : attPlaceHolderMap.values()) {
            attachRecord.Status__c = 'Completed';
        }
        
        Integer count = 0;
        Map<String, Object> retObj = new Map<String, Object>();
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                attPlaceHolderMap.get(listOfAttachmnetToInsert[count].ParentId).Status__c = 'Failed';
                for(Database.Error err : sr.getErrors()) {
                    retObj.put('Record at Index '+ count + ' Failed', err.getMessage());
                }
            }
            count ++;
        }
        
        update attPlaceHolderMap.values();
        
        return retObj;        
    }
    
    public void finish(List<Object> state) {
        
        /*Integer totalCreated = 0;
        for (Object o: state) {
            Map<String, Object> objMap = (Map<String, Object>)o;
            totalCreated += (Integer)objMap.get('size');
        }
        
        String body = 'Successfully created ' + totalCreated + ' contacts.';
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'hyperbatch@gmail.com'});
        mail.setReplyTo('hyperbatch@gmail.com');
        mail.setSenderDisplayName('Hyper Batch');
        mail.setSubject('CreateContactsHyperBatch Complete');
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails); */  
        
    }   
}