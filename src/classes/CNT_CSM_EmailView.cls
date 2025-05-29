public class CNT_CSM_EmailView {
    
    @AuraEnabled
    public static EmailMessage getData(id recordIDD){
        List<EmailMessage> listOfEmailMessage = [SELECT Id, Incoming, Status FROM EmailMessage  WHERE Id = :recordIDD];
        if(listOfEmailMessage != null && listOfEmailMessage.size() > 0){
            if(listOfEmailMessage[0].Incoming==true && listOfEmailMessage[0].status=='0'){
                listOfEmailMessage[0].status='1';
                update listOfEmailMessage[0];
            }
            listOfEmailMessage = [SELECT Id, ParentId, Status, MessageDate, LastModifiedBy.Name, CreatedBy.Name, Parent.CaseNumber, LastModifiedById, CreatedById, FromAddress, ToAddress, CcAddress,Subject, HtmlBody,TextBody,FromName,BccAddress,LastModifiedDate, CreatedDate,Incoming, PII_Data_Identified__c, Parent.RecordTypeName__c FROM EmailMessage  WHERE Id = :recordIDD];
            return listOfEmailMessage[0];
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static List<EmailMessageRelation> getEmailMessageRelations(id recordIDD){
        List<EmailMessageRelation> listOfMessage = [SELECT Id, RelationAddress, EmailMessage.Subject, RelationType, RelationObjectType, RelationId, EmailMessage.ToAddress,Relation.Name FROM EmailMessageRelation WHERE EmailMessageId = :recordIDD AND RelationObjectType != null];
        return listOfMessage;
    }
    
    @AuraEnabled
    public static List<Sobject> getAttachments(id recordIDD){
        List<SObject> sobjList = new list<Sobject>();
        List<Attachment> listOfAttachment = [SELECT Id, ParentId, Body, Name, ContentType ,LastModifiedDate FROM Attachment WHERE ParentId =:recordIDD];
        for(Attachment att : listOfAttachment){
            sobjList.add(att);
        }
        if(sobjList.size()<=0){
            List<ContentDocumentLink> listOfDocumentLink =[SELECT Id,  ContentDocument.Title, ContentDocument.LastModifiedDate,ContentDocument.FileExtension, ContentDocument.FileType,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId  =:recordIDD];
            for(ContentDocumentLink doc :listOfDocumentLink ){
                sobjList.add(doc);
            }
        }
        return sobjList;
    }

    @AuraEnabled
    public static void updatePIIDataIdentified(Id recordId, Boolean piiDataIdentified) {
        EmailMessage emailMsg = [SELECT Id, PII_Data_Identified__c FROM EmailMessage WHERE Id = :recordId LIMIT 1];
        emailMsg.PII_Data_Identified__c = piiDataIdentified;
        update emailMsg;
    }
    
}
