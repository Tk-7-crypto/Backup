/*
 * Version       : 1.0
 * Description   : Apex Controller to assign Resource to assignment.
 */
public class CNT_OWF_CreateAssignmentFromResReq {
    
    public boolean hasAccess{get;set;}
    public CNT_OWF_CreateAssignmentFromResReq(ApexPages.StandardController controller) {
       List<PermissionSetAssignment> triageManagerPermissionList = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'OWF_Triage_Manager' and AssigneeId = :userInfo.getUserId() limit 1];
       if(triageManagerPermissionList != null && triageManagerPermissionList.size() > 0)
       {
         hasAccess  = true;  
       }
       else
       {
           hasAccess = false;
       }
    }
    /**
     * This method is used to retrieve the related resource request record to get Suggested FTE value
     * @params  String resRequestId
     * @return  String suggestedFTEValue
     */
    @AuraEnabled
    public static String getSuggestedFTEFromResRequest(String resRequestId) {
        String suggestedFteVal = '';
        Set<Id> resRequestIdsSet = new Set<Id>{resRequestId};
        Set<String> resRequestFieldSet = new Set<String>{'Id', 'Suggested_FTE__c','pse__Assignment__c'};
        Map<Id, pse__Resource_Request__c> resRequestRecordMap = new SLT_Resource_Request(false,false).selectResReqsById(resRequestIdsSet, resRequestFieldSet);
        if(!resRequestRecordMap.IsEmpty() && resRequestRecordMap.values().get(0).pse__Assignment__c != null){
            return 'Assignment already exists';
        }
        if(!resRequestRecordMap.IsEmpty() && resRequestRecordMap.values().get(0).Suggested_FTE__c != null) {
            suggestedFteVal = String.valueOf(resRequestRecordMap.values().get(0).Suggested_FTE__c);
        }
        return suggestedFteVal ;
    }
    
    /**
     * This method is used to create Schedule, Assignment and update related Resource Request record
     * @params  String resRequestId
     * @params  String resourceId
     * @return  String resultMessage
     */
    @AuraEnabled
    public static String assignResourceAndCreateAssignment(String resRequestId, String resourceId) {
        String resultMsg = createAssignment(resRequestId, resourceId);
        
        return resultMsg;
    }
    
    /**
     * This method is used to create Schedule, Assignment and update related Resource Request record
     * @params  String resRequestId
     * @params  String resourceId
     * @return  String Success/Error message
     */
    private static String createAssignment(Id resRequestId, Id resourceId) {
        Set<Id> resRequestIdsSet = new Set<Id>{resRequestId};
        Set<String> resRequestFieldSet = new Set<String>{'Id', 'pse__Project__c', 'Bid_History__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'CurrencyIsoCode','pse__Assignment__c'};
        String resultMsg = '';
        try {
            Map<Id, pse__Resource_Request__c> resRequestRecordMap = new SLT_Resource_Request(false,false).selectResReqsById(resRequestIdsSet, resRequestFieldSet);
            if(!resRequestRecordMap.IsEmpty()) {
                pse__Resource_Request__c resReqRecord = resRequestRecordMap.values().get(0);
                Id scheduleRecId = createdSchedule(resReqRecord.pse__Start_Date__c, resReqRecord.pse__End_Date__c);
                if(resReqRecord.pse__Assignment__c!=null) {
                    resultMsg ='Assignment for this RR already exists';
                } else {
                    pse__Assignment__c objAssignment= new pse__Assignment__c(); 
                    objAssignment.pse__Project__c = resReqRecord.pse__Project__c;
                    objAssignment.Bid_History__c = resReqRecord.Bid_History__c;
                    objAssignment.pse__Resource__c = resourceId;
                    objAssignment.pse__Resource_Request__c = resReqRecord.id;
                    objAssignment.pse__Is_Billable__c = false;
                    objAssignment.pse__Bill_Rate__c = 0;
                    objAssignment.pse__Schedule__c = scheduleRecId; 
                    objAssignment.pse__Status__c = 'Pending'; 
                    objAssignment.CurrencyIsoCode = resReqRecord.CurrencyIsoCode;
                    objAssignment.Trigger_Email_Notification__c = true;
                    insert objAssignment;
                
                    //Updating Resource Request record
                    resReqRecord.pse__Resource__c = resourceId;
                    resReqRecord.pse__Assignment__c = objAssignment.Id;
                    update resReqRecord;
                    resultMsg = 'success';
                }
            }   
        }catch(Exception ex) {
            resultMsg =  String.valueOf(ex.getMessage());
            Integer textSize = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, '.length();
            Integer index = resultMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            Integer minusNum = resultMsg.lastIndexOf(': []') !=-1 ? 4 : 0;
            if(index != -1) {
                resultMsg = ex.getMessage().substring(index+textSize,resultMsg.length() - minusNum);
            }
        }
        return resultMsg;
    }
    
    /**
     * This method is used to create Schedule
     * @params  Date startDate
     * @params  Date endDate
     * @return  Id scheduleId
     */
    private static Id createdSchedule(Date startDate, Date endDate) {
        pse__Schedule__c scheduleRecord = new pse__Schedule__c();
        if(endDate < Date.today() || startDate > Date.today()){
        	scheduleRecord.pse__Start_Date__c = startDate;
        }
        else{
            scheduleRecord.pse__Start_Date__c = date.today();
        }
        scheduleRecord.pse__End_Date__c = endDate;
        insert scheduleRecord;
        return scheduleRecord.Id;
    }
    
}