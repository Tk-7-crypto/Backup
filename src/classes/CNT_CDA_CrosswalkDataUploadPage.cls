/**
* @author    :Vikram Singh Fartyal
* This class serves as a controller to VFP_CDA_CrosswalkDataUploadPage (created under ER-3556 on 07/06/2017)
*/
global class CNT_CDA_CrosswalkDataUploadPage {
    //Properties

    public string id {get; set;}
    public string getRecordId() {
        return JSON.serialize(id);
    }
    public static allData dataObj {get; set;}
    public string getAllData() {
        return JSON.serialize(dataObj);
    }
    public boolean isSorteable {get; set;}
    public boolean isSearchAllowed {get; set;}
    public List<CDA_Multilingual_Settings__mdt> cdaMultilingualCrossWalkDataList {
        get{
            if(cdaMultilingualCrossWalkDataList == null){
                cdaMultilingualCrossWalkDataList = new List<CDA_Multilingual_Settings__mdt>([Select id, MasterLabel, Parent_Name__c, Record_Type__c, Value__c from CDA_Multilingual_Settings__mdt]);
            }
            return cdaMultilingualCrossWalkDataList;
        }
        private set{cdaMultilingualCrossWalkDataList = value;}
    }


    //Constructor

    public CNT_CDA_CrosswalkDataUploadPage()
    {
        id = ApexPages.currentPage().getParameters().get('id');
        dataObj = new allData();

        // getting values for all the picklists on UI from custom settings
        dataObj.mlSettingsValues = cdaMultilingualCrossWalkDataList;
    }


    //Public Methods

    @remoteAction
    public static List<CDA_Language_Cross_Walk__c> getCDAMultilingualCrossWalkData(string language)
    {
    	runQuery();
    	return dataObj.editorRecords;
    }

    @remoteAction
    global static allData saveRecord(string record, string clone) {
        try {
            CDA_Language_Cross_Walk__c obj = (CDA_Language_Cross_Walk__c)JSON.deserialize(record, CDA_Language_Cross_Walk__c.class);
            //update case
            if(obj.Id != null){
                update obj;

                // instead of physical deletetion of the record, creating a backup record with the before update value and updating field isDeleted = true
                CDA_Language_Cross_Walk__c clonedObj = (CDA_Language_Cross_Walk__c)JSON.deserialize(clone, CDA_Language_Cross_Walk__c.class);
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
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject('', 'Exception Occurred in CNT_CDA_CrosswalkDataUploadPage : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            return null;
        }
    }


    //Private Method

    private static void runQuery(){
      dataObj = new allData();
      dataObj.editorRecords = [SELECT Id, Name, Object_Type__c, Object_Label__c, Control_Type__c, Field_Type__c, Field_Label__c, English_Translation__c, Chinese_Translation__c, Default_Value__c, Deleted_By__c, Deleted_On__c, Rank__c FROM CDA_Language_Cross_Walk__c WHERE isDeleted__c = false];   //Updated by Vikram Singh under CR-11147
    }


    //Wrapper Class
    @TestVisible
    global class allData
    {
        public allData()
        {
            editorRecords = new List<CDA_Language_Cross_Walk__c>();
        }
        public List<CDA_Language_Cross_Walk__c> editorRecords;
        public List<CDA_Multilingual_Settings__mdt> mlSettingsValues;
    }
}