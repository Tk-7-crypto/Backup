public class CNT_CSM_FlashMessage {
    @AuraEnabled
    public static string getFlashMessage(string contactId, string caseNumber, string recordTypeId){  
        string recordTypeName = getRecordTypeNameByRecordTypeId(recordTypeId); 
        if(recordTypeName =='TechnologyCase' && contactId!='' ){
             return formatMessages([SELECT  Message__c FROM Flash_Message__c WHERE ContactId__c  =: contactId AND Start_Date__c <= TODAY AND (End_Date__c = NULL OR End_Date__c >= TODAY) AND Pillar__c=:CON_CSM.S_TECHNOLOGY_SOLUTIONS]);     
        }
        else if(caseNumber != '' && recordTypeName.indexOf('R&D') != -1)
        {
            Case caseRecord = getLOSandQueueNameByCaseNumber(caseNumber);
            if(caseRecord !=null){
                List<Flash_Message__c> lst = [SELECT  Id,Message__c FROM Flash_Message__c WHERE ((los__c = null AND Queue__c =:caseRecord.CurrentQueue__C) or (los__c  =: caseRecord.LOS__c AND Queue__c = null)  OR (los__c  =: caseRecord.LOS__c AND Queue__c =:caseRecord.CurrentQueue__C)) AND Start_Date__c <= TODAY AND (End_Date__c = NULL OR End_Date__c >= TODAY) AND Pillar__c='R&D'];
                
                return formatMessages(lst);
            }
            else{
                return '';
            }
        }else{
            return '';
        }
    }
   
    @AuraEnabled
    public static string formatMessages(List<Flash_Message__c> lst){
         List<String> lstMsgs = new List<String>();    
         for(Flash_Message__c msg: lst){
            if(String.isNotBlank(msg.Message__c)){
                lstMsgs.add(msg.Message__c);
                lstMsgs.add('____________________________________________________________________________');    
            }
        }
        if(lstMsgs.size() > 1){
            lstMsgs.remove(lstMsgs.size()-1); }
        return string.join(lstMsgs,'\n'); 
    }
    
    @AuraEnabled
    public static string getRecordTypeNameByRecordTypeId(string recordTypeId){
        RecordType recordType = [Select ID,Name  from RecordType where ID =: recordTypeId];
        if(String.isNotBlank(recordType.Name)){
            return recordType.Name;
        }else{
            return 'Not Found';
        }
    }    
    
    @AuraEnabled
    public static Case getLOSandQueueNameByCaseNumber(string caseNumber){
        if(String.isNotBlank(caseNumber))
        {
            Case caseRecord = [SELECT ID, CaseNumber, LOS__C, CurrentQueue__C FROM CASE WHERE CaseNumber  =: caseNumber];
            if(caseRecord != null)
                return caseRecord;
            else
                return null;
        }else{
            return null;
        } 
    }
    
    @AuraEnabled
    public static Boolean getReasonForLateMessage(string caseId,string recordTypeId){
        Boolean returnValue = false;
        system.debug('recordTypeId :'+recordTypeId);
        string recordTypeName = getRecordTypeNameByRecordTypeId(recordTypeId); 
        system.debug('recordTypeName :'+recordTypeName);
        if(recordTypeName == 'DATA CREATE Service' ){
            Case caseRecord = [SELECT ID,Status,  Reason_for_Late_Request_Re_Run__c FROM CASE WHERE Id  =: caseId];
            returnValue =(caseRecord.Status != CON_CSM.S_CLOSED && caseRecord.Reason_for_Late_Request_Re_Run__c != null)?true:false; 
        }
        return returnValue;
    }
    
    
    @AuraEnabled
    public static Boolean getReasonForLateMessageForCreate(string recordId){
        Boolean returnValue = false;
        if(recordId != null){
            Case caseRecord = [SELECT ID,Status,  Reason_for_Late_Request_Re_Run__c,RecordTypeName__c FROM CASE WHERE Id  =: recordId];
            returnValue =(caseRecord.RecordTypeName__c == CON_CSM.S_DataCreateService_R_T && caseRecord.Status !='Clsoed' && caseRecord.Reason_for_Late_Request_Re_Run__c != null)?true:false; 
        }
        return returnValue;
    }

    @AuraEnabled
    public static Boolean checkTimeSheetMessage(string caseId,string recordTypeId){
        Boolean returnValue = false;
        String userId = UserInfo.getUserId();
        string recordTypeName = getRecordTypeNameByRecordTypeId(recordTypeId); 
        if(recordTypeName == 'DATA CREATE Service' ){
            List<TimeSheet__c> tsList = Database.query('select Id,Case__r.Status,CreatedDate  from TimeSheet__c WHERE Case__c = :caseId AND Type__c =\'Manual\' AND Status__c = \'stop\' AND CreatedById =:userId ORDER BY CreatedDate DESC LIMIT 1');
            if(tsList != null && !tsList.isEmpty()){
                for(TimeSheet__c ts : tsList){
                    if(ts.Case__r.Status != CON_CSM.S_CLOSED){
                        Long minutes = (System.now().getTime() - ts.CreatedDate.getTime()) / 60000;
                        if(minutes > 3){
                            returnValue = true;
                        }    
                    }
                    
                }
            }else{
                returnValue = true;
            }
        }
        return returnValue;
    }
    
    @AuraEnabled
    public static Boolean checkIfSNStatusCancelled(string recordTypeId,string SNStatus, string parentId){
        Boolean returnValue = false;
        system.debug('recordTypeId :'+recordTypeId);
        string recordTypeName = getRecordTypeNameByRecordTypeId(recordTypeId); 
        system.debug('recordTypeName :'+recordTypeName);
        if(recordTypeName.contains('R&D -')){
            if(SNStatus == 'Cancelled')
                returnValue = true;
            else if (parentId != null){
                List<Case> ParentCase = [SELECT ID, ServiceNow_Status__c FROM Case Where Id =:  parentId];
                if(ParentCase[0].ServiceNow_Status__c == 'Cancelled'){
                    returnValue = true;
                }
            }
        }
        return returnValue;
    }
    
    @AuraEnabled
    public static Boolean checkSNStatusForParent(string parentId){
        Boolean returnValue = false;
        List<Case> ParentCase = [SELECT ID, ServiceNow_Status__c FROM Case Where Id =:  parentId];
        if(ParentCase[0].ServiceNow_Status__c == 'Cancelled'){
            returnValue = true;
        }
        return returnValue;
    }
    
    
}
