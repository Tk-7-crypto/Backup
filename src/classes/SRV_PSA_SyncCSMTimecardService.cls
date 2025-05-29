@RestResource(urlmapping='/synCSMTimecardUpdate/*')
global without sharing class SRV_PSA_SyncCSMTimecardService {
    @HttpPost
    global static void updateTimecardSyncProcessStatus(){
        String httpBody = RestContext.request.requestBody.toString();
        system.debug('Hi Rest Api');
        
        RestResponse restResult = RestContext.response;
        List<TimeSheet__c> timesheetList = (List<TimeSheet__c>) JSON.deserialize(httpBody, List<TimeSheet__c>.class);
        system.debug('timesheetcall'+timesheetList);
        string response='';
        try{
            response= SRV_PSA_SyncCSMTimecard.setInprocessStatus(timesheetList);
            system.debug('response:-'+response);
            //restResult.responseBody =Blob.valueOf(response);
            restResult.responseBody = Blob.valueOf(JSON.serialize(response));
            restResult.statusCode = 200;  
        }
        catch(Exception ex){
            //SRV_PSA_SyncCSMTimecard.processFailedRecords(timesheetList, 'Failed-' + ex.getStackTraceString() + ' ' + ex.getMessage());
            response= 'Failed-' + ex.getStackTraceString() + ' ' + ex.getMessage();
            
            restResult.responseBody = Blob.valueOf(JSON.serialize(response));
            restResult.responseBody =Blob.valueOf(response);
            restResult.statusCode = 500;
        }
        system.debug('restResult:'+Blob.valueOf(response));
        
    }
}