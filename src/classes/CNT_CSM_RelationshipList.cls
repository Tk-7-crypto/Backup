public class CNT_CSM_RelationshipList {
    
    @AuraEnabled
    public static List<AccountContactRelation> getActiveRelationsForCSH(Id userId, string contactType) {
        List<User> acc = [select id,AccountId,Name  from user where id =:userId limit 1 ];
        Id accId = acc[0].AccountId;
        List<AccountContactRelation> activeRelations = [SELECT Contact.Email, Contact.Name, Contact.Phone, CurrencyIsoCode, Focus__c, Function__c, Geographic_Responsibility__c, Id,Responsibility__c, User_Country__c FROM AccountContactRelation WHERE Account.Id = :accId AND IsActive = true and Contact_Type__c = :contactType ORDER BY CreatedDate];
        return activeRelations;
    }
    
    @AuraEnabled
    public static List<Contact> getContactDetails(Id userId) { 
        List<User> acc = [select id,ContactId,Name  from user where id =:userId limit 1 ];
        Id conId = acc[0].ContactId;
        List<Contact> contactRecord = [select id,Name, Title, Email, Account.Name,MobilePhone, Phone, Address_1__c, toLabel(PreferredLanguage__c) from contact where id =:conId];
        return contactRecord;
    }
    @AuraEnabled
    public static void saveAttachment(String fileName, String base64Data, String contentType) { 
        
        // Edit permission on parent object (Contact) is required to add attachments
        Document  document = new Document();
        document.AuthorId = UserInfo.getUserId();
        document.FolderId = UserInfo.getUserId(); // put it in running user's folder
        document.type = contentType;
        document.IsPublic = true;
        document.body = EncodingUtil.base64Decode(base64Data);
        document.Name =fileName;
        insert document;
    }
    
    @AuraEnabled
    public static List<User> getUserDetail(Id userId) {
        List<User> usePhoto = [select id,FullPhotoUrl  from user where id =:userId limit 1 ];
        return usePhoto;
    }
    public static void sleep(Long milliSeconds)
    {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }
    
    @AuraEnabled
    public static void setPhotoURL(Id userId,string fileName) {
        List<Document>  document1 = new List<Document>();
        sleep(6000);
        document1 =[select id,name,body from document where name =:fileName and folderId =:userId];
        try {
            // Set photo
            if(document1 != null && !document1.isEmpty()){
                ConnectApi.UserProfiles.setPhoto(null, userId, new ConnectApi.BinaryInput(document1[0].body, 'image/jpg', fileName));
            }
        }
        catch (DMLException e){
            
        }
    }
    
    @AuraEnabled
    public static void deletePhoto(Id userId,string fileName) {
        List<Document>  document1 = new List<Document>();
        sleep(6000);
        document1 =[select id,name,body from document where name =:fileName and folderId =:userId];
        try {
            
            delete document1;
        }
        catch (DMLException e){
            
        }
        
    }
    
    
}
