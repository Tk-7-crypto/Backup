/**
 * This class is use for refresh the agreement page after Box forder is create. 
 **/
public class RefreshPageController {
    public Boolean flag{get; set;}
    public Apttus__APTS_Agreement__c record; 
    Public String recordId{get; set;}
    Private Integer pageLoadTimeInSec;
    Private Integer recordCreateTimeInSec;
    Public Boolean isShowPageMessage{get; set;}
    public RefreshPageController(ApexPages.StandardController controller){
        this.record = (Apttus__APTS_Agreement__c)controller.getRecord();
        recordId = record.Id;
        this.flag = true;
        this.record = [select id, Bid_History__c, Bid_History__r.Is_Box_Folder_Migrated__c, RecordTypeId from Apttus__APTS_Agreement__c where Id=:record.Id limit 1];
        List<Box__FRUP__c> agreementFrupRecordList = [SELECT Id FROM Box__FRUP__c where box__Record_ID__c = :this.record.Id];
        isShowPageMessage =false;
        if(CON_OWF.OWF_AGREEMENT_RECORD_TYPE_BID_HISTORY.contains(this.record.recordTypeId) && this.record.Bid_History__c != null 
           && (this.record.Bid_History__r.Is_Box_Folder_Migrated__c == true || agreementFrupRecordList == null || agreementFrupRecordList.size()==0)){
               isShowPageMessage = true;
               ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'The Box folder for this Agreement has been migrated to the Bid History record. Please access the Box Folder from the corresponding Bid History record.'));
        }
        pageLoadTimeInSec = covertTimeToSecond(System.now());
    }
    
    private Integer covertTimeToSecond(DateTime t_time){
        return (t_time.hour()*3600) + (t_time.minute()*60) + t_time.second();
    }
    public  PageReference refresh(){
       LIST<box__FRUP__c>  boxItem = [Select Id, CreatedDate from box__FRUP__c Where box__Record_ID__c = :recordId Limit 1];
        if(boxItem.size() == 1 )
            recordCreateTimeInSec = covertTimeToSecond(boxItem[0].CreatedDate);
        if(boxItem.size() == 0 ){
            return null;
        } else if(boxItem[0].CreatedDate.Date() != system.today() || recordCreateTimeInSec < (pageLoadTimeInSec) ){
            this.flag = false;
            return null;
        } else{
            PageReference pg = new PageReference('/'+this.recordId);
            pg.setRedirect(true);
            return pg;
        }
    }
}