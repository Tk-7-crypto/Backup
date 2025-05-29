global class CNT_TPA_EditorController_Multi {
    public string content {get; set;}
    public string getHtmlContent() {
         return JSON.serialize(content);
    }
    
    //Added by C.P.Pandey under ER-1940 start
    public String languageFieldApi {get; set;}
    public string getGlobalSettings(){
        return JSON.serialize(UTL_TPA_Multilingual.mlGlobalSettings);
    }
    //Added by C.P.Pandey under ER-1940 end
    
    public string id {get; set;}
    public string getRecordId()
    {
        return JSON.serialize(id);
    }
    
    public string name {get; set;}
    public string getPageName()
    {
        return JSON.serialize(name);
    }
    
    public boolean isPageTypeFixed {get; set;}
    public string pTypeName {get; set;}
    public boolean isSorteable {get; set;}
    public boolean isSearchAllowed {get; set;} //Added by C.P.Pandey under ER-1940
    
    public string title {get; set;}
    public static allData dataObj {get; set;}
    public string getAllData()
    {
        return JSON.serialize(dataObj);
    }
    
    public string getTPA_EditorLoadData()
    {
     	Set<String> fieldSet  = new Set<String>();
    	for(string mlFieldApi :UTL_TPA_Multilingual.mlGlobalSettings.Supported_Language_Field_Map__c.split(';'))
        	fieldSet.add(mlFieldApi.split('~')[1]);
        dataObj.editorRecords = new SLT_TPATextEditor().getTPATextEditorData(fieldSet);
        if(isPageTypeFixed)
        {
            pTypeName = toProperCase(pTypeName);
            String condition = 'Page_Type__c = \'' + pTypeName + '\'';
            dataObj.editorRecords = new SLT_TPATextEditor().getTPATextEditorDataByCondition(condition, fieldSet);
        }
        dataObj.autoCompletePageTypeList = new Set<string>();
        for(TPA_Text_Editor__c txtEditorObj: dataObj.editorRecords)
        {
            dataObj.autoCompletePageTypeList.add(toProperCase(txtEditorObj.Page_Type__c));
        }
        return 'Data is Loaded';
    }
    
    public CNT_TPA_EditorController_Multi()
    {
        id = ApexPages.currentPage().getParameters().get('id');
        //Modified by C.P.Pandey under ER-1940 start
        languageFieldApi = ApexPages.currentPage().getParameters().get('contentFieldApi');
        if(languageFieldApi != null && languageFieldApi.length() > 0)
            languageFieldApi = languageFieldApi.trim().toLowerCase();
        dataObj = new allData();
        TPA_Text_Editor__c textEditorObj = new TPA_Text_Editor__c();
        if(id != null && id.trim().length() > 0)
        {
            Set<String> fieldSet  = new Set<String>();
	    	for(string mlFieldApi :UTL_TPA_Multilingual.mlGlobalSettings.Supported_Language_Field_Map__c.split(';'))
	        	fieldSet.add(mlFieldApi.split('~')[1]);
	        List<TPA_Text_Editor__c> editorRecord = new SLT_TPATextEditor().getTPATextEditorDataById(id, fieldSet);
            if(editorRecord != null && editorRecord.size() > 0)
            {
                Boolean isContentFieldExists = Schema.SObjectType.TPA_Text_Editor__c.fields.getMap().keySet().contains(languageFieldApi);
                content = (languageFieldApi != null && isContentFieldExists) ? (string)editorRecord[0].get(languageFieldApi) : editorRecord[0].Content__c;
                if(content == null || content.length() == 0)
                    content = editorRecord[0].Content__c;
                name = editorRecord[0].Page_Name__c;
                title = editorRecord[0].Page_Title__c == null ? editorRecord[0].Page_Name__c : editorRecord[0].Page_Title__c;
            }
        }
        //Modified by C.P.Pandey under ER-1940 end
    }
    
    @remoteAction
    global static allData saveRecord(string arg)
    {
        system.debug('in save');
        TPA_Text_Editor__c obj = (TPA_Text_Editor__c)JSON.deserialize(arg, TPA_Text_Editor__c.class);
        upsert obj;
        dataObj = new allData();
        Set<String> fieldSet  = new Set<String>();
    	for(string mlFieldApi :UTL_TPA_Multilingual.mlGlobalSettings.Supported_Language_Field_Map__c.split(';'))
        	fieldSet.add(mlFieldApi.split('~')[1]);
        dataObj.editorRecords = new SLT_TPATextEditor().getTPATextEditorData(fieldSet);
        dataObj.autoCompletePageTypeList = new Set<string>();
        for(TPA_Text_Editor__c txtEditorObj: dataObj.editorRecords)
        {
            dataObj.autoCompletePageTypeList.add(toProperCase(txtEditorObj.Page_Type__c));
        }
        return dataObj;
    }
    
    public static String toProperCase(String value) 
    {
        value = value.toLowerCase();
        List<String> pieces = new List<String>();
        for(String s : value.split(' '))
        {
            s = s.capitalize();
            pieces.add(s);
        }
        return String.join(pieces, ' ');
    }
    
    global class allData
    {
        public allData()
        {
            editorRecords = new List<TPA_Text_Editor__c>();
            autoCompletePageTypeList = new Set<string>();
        }
        List<TPA_Text_Editor__c> editorRecords;
        Set<string> autoCompletePageTypeList;
    }
}