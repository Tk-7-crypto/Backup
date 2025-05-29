global class CNT_TPA_Helpful_Hints_Addendum { 
    public static string Id {get; set;}
    public static Map<Id,IMS_Legal_Entity__c> mapIdWithLegalEntityList{get; set;}    

    public Boolean isDisplayWatermark {get; set;}
    public string requestName {get; set;}
    public string title {get; set;}
    public static string openmode {get; set;} 
    public string aggNo {get; set;}
    public string aggStartDate {get; set;}
    public static TPA_Request__c tpaRequest {get; set;}
    public String helpfulAddendumNote{get; set;}
    public String helpfulAddendumNote1{get; set;}
    public String helpfulAddendumNote2{get; set;}
    public String helpfulAddendumNote3{get; set;}
    public String helpfulAddendumNote4{get; set;}
    public String helpfulAddendumNote5{get; set;}
    public String helpfulAddendumNote6{get; set;}
    public String helpfulAddendumNote7{get; set;}
    public String helpfulAddendumNote8{get; set;}
    
    public static Map<ID, IMS_Master_Legal_Entity__c> mapOfIdWithlegalEntityObj;
    
    public static Map<Id,wrapperClassOfLegalEntity> mapIdWithObjofwrapperClassOfLegalEntity{get; set;}


     
    public string wordStyle {get; set;}
    public string docTitle {get; set;}
    public string contentStyle {get; set;}
    public string headerStyle {get; set;}
    public string boldEffect {get; set;}
    public string contentParagraph {get; set;}
    public string centerAlign {get; set;}
    public string underlineEffect {get; set;}
    public string italicEffect {get; set;}
    public string marginT1Left {get; set;}
    public string marginT2Left {get; set;}
    public string marginT1Bottom {get; set;}
    public string marginDocOnly1 {get; set;}
    public string margin1 {get; set;}
    public string columnStyle {get; set;}
    public string addendumText {get; set;}

    public string language{
        get{
            system.debug('++'+language);
            return language;
        }
        set;
    }
    public static void loadDataForHelpfulAddendumDocument() {
        system.debug('Inside loadDataForHelpfulAddendumDocument');
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        
        mapIdWithLegalEntityList = new Map<Id,IMS_Legal_Entity__c>();

        Id legalEntityId = null;

        for(IMS_Legal_Entity__c obj: [SELECT Id, Name,Name_for_ESign__c ,IMS_Master_Legal_Entity__c,IMS_Master_Legal_Entity__r.id From IMS_Legal_Entity__c Where TPA_Request__c =: Id]) {
            legalEntityId = obj.IMS_Master_Legal_Entity__r.id;
			mapIdWithLegalEntityList.put(obj.IMS_Master_Legal_Entity__r.id, obj);
        }

        mapOfIdWithlegalEntityObj = new Map<ID, IMS_Master_Legal_Entity__c>([Select Name,Name_for_ESign__c,Legal_Entity_Title__c FROM IMS_Master_Legal_Entity__c ]);

        IMS_Master_Legal_Entity__c legalEntityObj;
        string url;
        String name = '';
        mapIdWithObjofwrapperClassOfLegalEntity= new Map<Id,wrapperClassOfLegalEntity>();
        ID legalEntityDocid = null;

        for(Id IdofLegalEntity : mapIdWithLegalEntityList.keySet()) {
            if(mapOfIdWithlegalEntityObj != null && !mapOfIdWithlegalEntityObj.isEmpty() && mapOfIdWithlegalEntityObj.containsKey(IdofLegalEntity)) {
                legalEntityObj = mapOfIdWithlegalEntityObj.get(IdofLegalEntity);
                if(legalEntityObj != null && legalEntityObj.name != null){
                    name = legalEntityObj.name.replaceall('[^a-zA-Z0-9]','_').replaceall('[_ ]+','_').removeEnd('_');
                }
            }

            List<Document> lstdoc = [SELECT Id, FolderId, Folder.Name,SystemModstamp FROM Document WHERE DeveloperName like :name LIMIT 1]; //will review, query in for loop
            if(lstdoc != null && lstdoc.size() >0 ){
               legalEntityDocid =  lstdoc[0].id;
            }
            system.debug('legalEntityDocid:'+legalEntityDocid);
                url =  TPA_Settings__c.getOrgDefaults().Base_Url_Public__c+'/servlet/servlet.ImageServer?id=' +legalEntityDocid+'&oid='+UserInfo.getOrganizationId()+'&contentType=image/png';
        
            mapIdWithObjofwrapperClassOfLegalEntity.put(IdofLegalEntity,new wrapperClassOfLegalEntity(legalEntityObj.name,url,legalEntityObj.Legal_Entity_Title__c,legalEntityObj.Name_for_ESign__c, ''));
        }
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
    }

     public void LoadStyles(){
        if(openMode == 'word'){
            headerStyle = 'font-family: Arial Narrow;font-size:10.0pt;';
            contentStyle = 'font-family: Arial;font-size:8.0pt;';
            contentParagraph = 'font-family: Arial;font-size:8.0pt;text-align:justify;';
            marginT1Left = 'margin-left:80px;';
            marginT2Left = 'margin-left:20px;';
            marginT1Bottom = 'margin-bottom:10px;';
            marginDocOnly1 = 'margin:0.001in 0.03in 0.03in 0.0in;';
            margin1 = 'margin:0.05in;';
            columnStyle = 'border:1px solid black;text-align:center;';

        }
        else{
            headerStyle = 'font-family: Dialog;font-size:13px;';
            contentStyle = 'font-family: Dialog;font-size:11px;';
            contentParagraph = 'font-family: Dialog;font-size:11px;text-align:justify;';
            marginT1Left = 'margin-left:40px;';
            marginT2Left = 'margin-left:15px;';
            marginT1Bottom = 'margin-bottom:10px;';
            marginDocOnly1 = '';
            margin1 = 'margin:5px;';
            columnStyle = '';
        }
        boldEffect = 'font-weight:bolder;';
        centerAlign = 'text-align:center;';
        underlineEffect = 'text-decoration:underline;';
        italicEffect = 'font-style:italic;';
        wordStyle = '<style>.useDefStyle p {margin:0.0in;} .useDefStyle ol ol li p {margin:0.04in 0.0in 0.1in 0.0in;}</style>';
        addendumText = 'text-align: center; display: table; margin-left: auto; margin-right: auto;';
    }
    public String getPrintView(){
        return
        '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>125</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>' +
            '<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />' +
            '<style>' +
            'p.MsoHeader, li.MsoHeader, div.MsoHeader{margin:0in;margin-top:.0001pt;margin-left:0.8in;mso-pagination:widow-orphan;tab-stops:center 3.0in right 6.0in;}' +
            'p.MsoFooter, li.MsoFooter, div.MsoFooter{margin:0in;margin-bottom:.0001pt;margin-left:-0.45in;mso-pagination:widow-orphan;tab-stops:center 3.0in right 6.0in;}' +
            '@page main{mso-header:h1;mso-footer:f1;}' +
            'div.main{page:main;}' +
            'table#hrdftrtbl{margin:0in 0in 0in 15in;}' +
            '</style>';

    }

    

    public class wrapperClassOfLegalEntity{
        public wrapperClassOfLegalEntity(String legalEntityName,String legalentityurl, String legalEntityTitle,String EsignName, String helpfulAddendumNote){
            name = legalEntityName;
            url = legalentityurl;
            title = legalEntityTitle;
            NameOfESign = EsignName;
            helpfulAddendumNote = helpfulAddendumNote;

        }
        public string url {get;set;}
        public string name {get;set;}
        public string title {get;set;}
        public string NameOfESign {get;set;}
        public string helpfulAddendumNote {get;set;}
    }

    public string vendorLanguage { get; set; }
    public static Map<String, String> supportedLanguageMap{
        get{
            if(supportedLanguageMap == null)
            {
                supportedLanguageMap = new Map<String, String>();
                for(string langCodeMapObj :UTL_TPA_Multilingual.mlGlobalSettings.Supported_Language_Field_Map__c.split(';'))
                {
                    supportedLanguageMap.put(langCodeMapObj.split('~')[0], langCodeMapObj.split('~')[1]);
                }        
            }
            return supportedLanguageMap;
        }
        private set;
    }

    public CNT_TPA_Helpful_Hints_Addendum(){
        system.debug('inside CNT_TPA_Helpful_Hints_Addendum constructor');
        Id = ApexPages.currentPage().getParameters().get('id');
        openmode = ApexPages.currentPage().getParameters().get('mode');
        aggNo = ApexPages.currentPage().getParameters().get('aggNo');
        aggStartDate = ApexPages.currentPage().getParameters().get('aggStartDate');
        isDisplayWatermark = false;
        if(UTL_TPA.tpaSetting.Is_Template_Watermark_Automated__c) {
            isDisplayWatermark = UTL_TPA.isSandboxOrg;
        }

        tpaRequest = [Select Id, name,Client_Address__c,Client_Address__r.Name, Client_Address__r.Region_Territory__c, Client_Address__r.Country__c,
                                     ClientContact__r.firstName,ClientContact__r.lastname,ClientContact__r.Email ,
                                     Service_Provider_Address__r.Name,Today_Date_TLLA__c,Vendor_Billing_Mailing_Country__c,
                                     Data_Access_Start_Date__c,Service_Provider_Address__r.Parent_Vendor_Name__c,Service_Provider_Address__c,Vendor_Language__c,TLLA_Language_Chosen__c,
                                     Today_s_Date__c
                                     FROM TPA_Request__c where id = :Id];
        docTitle = 'TPA Helpful Hints Addendum' ;  
        vendorLanguage = tpaRequest.TLLA_Language_Chosen__c != null ? tpaRequest.TLLA_Language_Chosen__c : (tpaRequest.Vendor_Language__c != null ? tpaRequest.Vendor_Language__c : 'English');
        language = vendorLanguage == 'French' ? 'fr' : 'en_US';
        Date dataAccessstartDate = tpaRequest.Data_Access_Start_Date__c;
        LoadStyles();
        loadDataForHelpfulAddendumDocument();
        List<TPA_Text_Editor__C> listTPA = [Select Id, Content__c, Page_Name__c, Page_Title__c, Page_Type__c, English_Translation__c, Japanese_Translation__c, French_Translation__c FROM TPA_Text_Editor__c WHERE Page_Type__c = 'Helpful Hints Addendum'];
        for(TPA_Text_Editor__C textEditor: listTPA){
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum'){
                for(Id legalEntityId: mapIdWithObjofwrapperClassOfLegalEntity.keySet()){
                    helpfulAddendumNote = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
                    helpfulAddendumNote = helpfulAddendumNote.replace('Client_Request_Number',tpaRequest.Name);
                    helpfulAddendumNote = helpfulAddendumNote.replace('TLLA_Effective_Date', DateTime.newInstance(dataAccessstartDate.year(),dataAccessstartDate.month(),dataAccessstartDate.day()).format('MM/dd/YY'));
                    helpfulAddendumNote = helpfulAddendumNote.replace('IMS_Legal_Entity_Name',mapIdWithObjofwrapperClassOfLegalEntity.get(legalEntityId).Name);
                    helpfulAddendumNote = helpfulAddendumNote.replace('Vendor_Legal_Name',tpaRequest.Service_Provider_Address__r.name);
                    helpfulAddendumNote = helpfulAddendumNote.replace('<strong>','<b class="boldEffect">');
                    helpfulAddendumNote = helpfulAddendumNote.replace('</strong>','</b>');
                    mapIdWithObjofwrapperClassOfLegalEntity.get(legalEntityId).helpfulAddendumNote = helpfulAddendumNote;
                }
                
            }
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum 1'){
                helpfulAddendumNote1 = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
            }
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum 2'){
                helpfulAddendumNote2 = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
            }
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum 3'){
                helpfulAddendumNote3 = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
            }
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum 4'){
                helpfulAddendumNote4 = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
            }
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum 5'){
                helpfulAddendumNote5 = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
            }
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum 6'){
                helpfulAddendumNote6 = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
            }
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum 7'){
                helpfulAddendumNote7 = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
            }
            if(textEditor.Page_Name__c == 'TPA Helpful Hints Addendum 8'){
                helpfulAddendumNote8 = textEditor.get(supportedLanguageMap.get(vendorLanguage)) != null ? String.valueOf(textEditor.get(supportedLanguageMap.get(vendorLanguage))) : String.valueOf(textEditor.Content__c);
            }
            
        }
        
    }

    
    public static void generateHelpfulHintsAddendumDoc(Id reqId, String mode, String argGUID) { // Debug log change
        // Debug log change
        if(UTL_Validate.isValidGuid(argGUID)) {
            UTL_LogFactory.GUID = argGUID; 
        }
        TPA_Request__c objTpaRequest;
        // Debug log change
        try {
            objTpaRequest = SRV_TPA_TPARequest.getRequestInfo(reqId); // Debug log change
            system.debug('Helpful Hints Addendum Generation::::');

            PageReference pdf = Page.VFP_TPA_Helpful_Hints_Addendum;
            pdf.getParameters().put('mode', mode); 
            pdf.getParameters().put('id',reqId);
            pdf.getParameters().put('aggNo',objTpaRequest.Name);
            pdf.getParameters().put('aggStartDate',string.valueOfGmt(objTpaRequest.Data_Access_Start_Date__c));
            Blob body;
            if (Test.IsRunningTest()) {
                body = Blob.valueOf('UNIT.TEST');
            }
            else {
                body = pdf.getContentAsPDF();
            }
            Attachment attach = new Attachment();
            attach.Body = body;
            
            if(mode == 'word'){
                attach.Name = objTpaRequest.Name + '_TPA Helpful Hints Addendum.doc';
            }
            else{
                attach.Name = objTpaRequest.Name + '_TPA Helpful Hints Addendum.pdf';
            } 

            attach.IsPrivate = false;
            attach.ParentId = reqId;
            insert attach;
            string taskSubject = 'TPA Helpful Hints Addendum';
            SRV_TPA_TPARequest.updateActivityHistory(reqId,'Generated ' + taskSubject, true);
        } catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_Helpful_Hints_Addendum:::generateAddendumNotificationDoc', reqId != null ? reqId : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
             
        }
      }


    
}
