/********************************************************************
* @ 2016 IMS Health, All Rights Reserved
*
* Public class: TPA_MultilingualController
* VF Page: TPA_Multilingual_Entry_Page
* 
* Created by: Vikram Singh Fartyal @June/17/2016
********************************************************************/
global class CNT_TPA_MultilingualController {
	/************
     Properties
    *************/
    public string id {get; set;}
    public string getRecordId() {
        return JSON.serialize(id);
    }
    public static allData dataObj {get; set;}
    public string getAllData()
    {
        return JSON.serialize(dataObj);
    }
    public String languageFieldApi {get; set;}
    public boolean isSorteable {get; set;}
    public boolean isSearchAllowed {get; set;}
    
    /************
     Constructor
    *************/
    public CNT_TPA_MultilingualController()
    {
        id = ApexPages.currentPage().getParameters().get('id');
        dataObj = new allData();
        
        // getting values for all the picklists on UI from custom settings
        dataObj.mlSettingsValues = TPA_Multilingual_Settings__c.getAll().values();
    }
    
    /***************
     Remote Methods
    ****************/
    @remoteAction
    public static List<TPA_Language_Cross_Walk__c> getTPA_MultilingualEditorData(string language)
    {
    	runQuery();
    	return dataObj.editorRecords;
    }
    
    @remoteAction
    global static allData saveRecord(string record, string clone)
    {
        TPA_Language_Cross_Walk__c obj = (TPA_Language_Cross_Walk__c)JSON.deserialize(record, TPA_Language_Cross_Walk__c.class);

        //update case
        if(obj.Id != null){
        	update obj;
       
       		// instead of physical deletetion of the record, creating a backup record with the before update value and updating field isDeleted = true 
	        TPA_Language_Cross_Walk__c clonedObj = (TPA_Language_Cross_Walk__c)JSON.deserialize(clone, TPA_Language_Cross_Walk__c.class);
	        system.debug('####clonedObj:' +clonedObj);
	        clonedObj.Original_Record_Id__c = obj.Id;
	        clonedObj.Id = null;
	        clonedObj.isDeleted__c = true;	
	        clonedObj.Deleted_By__c = UserInfo.getUserId();
	        clonedObj.Deleted_On__c = system.now();
	        insert clonedObj;
         }else{ 
         	//new record case
         	insert obj;
         }
         	
        runQuery();
        return dataObj;
    }
    
    
    /***************
     Private Method
    ****************/
    private static void runQuery(){
    	dataObj = new allData();
        dataObj.editorRecords = [SELECT Id, Name, Object_Type__c, Object_Label__c, Control_Type__c, Field_Type__c, Field_Label__c, English_Translation__c, Japanese_Translation__c, Default_Value__c, Deleted_By__c, Deleted_On__c, Rank__c FROM TPA_Language_Cross_Walk__c WHERE isDeleted__c = false];
    	system.debug('#### records: '+dataObj.editorRecords);
    }
    
    
    /**************
     Wrapper Class
    ***************/
    global class allData
    {
        public allData()
        {
            editorRecords = new List<TPA_Language_Cross_Walk__c>();
        }
        List<TPA_Language_Cross_Walk__c> editorRecords;
        List<TPA_Multilingual_Settings__c> mlSettingsValues;
    }
}