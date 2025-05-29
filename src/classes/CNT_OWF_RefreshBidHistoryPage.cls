/**
 * This class is use for refresh the Bid History page after Box forder is create. 
 **/
public class CNT_OWF_RefreshBidHistoryPage {
    public Boolean flag{get; set;}
    public Bid_History__c record; 
    Public String recordId{get; set;}
    public String srcRecordId{get; set;}
    public Boolean redirectAgrBox{get;set;}
    Private Integer pageLoadTimeInSec;
    Private Integer recordCreateTimeInSec;
    public CNT_OWF_RefreshBidHistoryPage(ApexPages.StandardController controller){
        this.record = (Bid_History__c)controller.getRecord();
        this.record = [Select Id,Is_Box_Folder_Migrated__c,Migrated_Agreement_Id__c from Bid_History__c where Id=:record.Id limit 1];
       
	   if(this.record.Is_Box_Folder_Migrated__c)
        {
            recordId = record.Id;
            redirectAgrBox = false;
        }
        	
        else if(this.record.Migrated_Agreement_Id__c != null){
            List<Box__FRUP__c> agreementFrupRecordList = [SELECT Id FROM Box__FRUP__c where box__Record_ID__c = :this.record.Migrated_Agreement_Id__c];
            if(!this.record.Is_Box_Folder_Migrated__c && agreementFrupRecordList != null && agreementFrupRecordList.size()>0){
                srcRecordId = record.Migrated_Agreement_Id__c;
            	redirectAgrBox = true;
            }
        }
            
        this.flag = true;
        system.debug('srcRecordId→' + srcRecordId);
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