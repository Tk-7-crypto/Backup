public class CNT_TPA_AccountCompAttachmentReport {
    
    public CNT_TPA_AccountCompAttachmentReport(){
    }

    @remoteAction
    public static returnDataWrapper searchData(){
	
        list<watchListWrapper> watchListWrapperList = new list<watchListWrapper>();
        returnDataWrapper retDataWrapObj = new returnDataWrapper();
        List<id> linkedentityID = new List<id>();
        Map<id,List<ContentDocumentLink>> accCompIdWithAttName = new Map<Id,List<ContentDocumentLink>>();

        List<ContentDocumentLink> listAttachment = [SELECT ContentDocumentId,ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.Title, ContentDocument.Description , ContentDocument.CreatedBy.name FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Account_Compliance__c) and ContentDocument.Description = 'TPA Certificate'];
        for(ContentDocumentLink attObj: listAttachment) {
            List<ContentDocumentLink> lstAttach = new List<ContentDocumentLink>();
            if(accCompIdWithAttName.containsKey(attObj.LinkedEntityId)) {
                lstAttach = accCompIdWithAttName.get(attObj.LinkedEntityId);
            }
            linkedentityID.add(attObj.LinkedEntityId);
            lstAttach.add(attObj);
            accCompIdWithAttName.put(attObj.LinkedEntityId, lstAttach);

        }

        for(Account_Compliance__c accObj : [select id, Account__r.Name, Name,CreatedBy.name,LastModifiedBy.name,CreatedDate from Account_Compliance__c where id in: linkedentityID]) {
            List<ContentDocumentLink> lstAttach = accCompIdWithAttName.get(accObj.Id);
            for(ContentDocumentLink attLink : lstAttach){
                watchListWrapperList.add( new watchListWrapper(accObj.id, accObj.Account__r.Name, accObj.Name, attLink.ContentDocument.Title, attLink.ContentDocument.CreatedBy.name, attLink.ContentDocument.CreatedDate.date()));
            }
        }
   
        if(watchListWrapperList == null || watchListWrapperList.size() == 0) {
            retDataWrapObj.resultData = null;
            return retDataWrapObj;
        }
        retDataWrapObj.resultData = watchListWrapperList;
		system.debug(retDataWrapObj.resultData[0]);
        
        return retDataWrapObj;
    }

    
    public class watchListWrapper
    {
        public string id {get; set;}
        public string AccName {get; set;}
        public String accCompName {get; set;}
        public String attName {get; set;}
        public string CreteatedUser {get; set;}
        public Date CreatedDate {get; set;}
        
        public watchListWrapper(string id,string AccName, String accCompName, String attName, string CreteatedUser, Date CreatedDate)
        {
            this.id = id;
            this.AccName = AccName;
            this.accCompName = accCompName;
            this.attName = attName;
            this.CreteatedUser = CreteatedUser;
            this.CreatedDate = CreatedDate;
        }
    }

    public class returnDataWrapper{
        public list<watchListWrapper> resultData;
        public Integer noOfTPAReqProcessed;
        public String lastReqId;
    }
}