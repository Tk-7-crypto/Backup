global class CNT_TPA_AddendumNotification {
    public static string Id {get; set;}
    public static string reqVendorAccountId{get; set;}
  //  public static List<wrapperClassAssetPurposeWithAddendumTerms> WrapperClassList {get; set;}
    public static Map<Id,List<wrapperClassAssetPurposeWithAddendumTerms>> mapIdWithWrapperClassList{get; set;}
    public static Map<ID, TPA_Text_Editor__C> mapOfIdWithTextEditorObj;

    public string clientVendorNote {get; set;}
    public String clientNote{get; set;}
    public String addendumNote{get; set;}
    public string requestName {get; set;}
    public string title {get; set;}
    public static string openmode {get; set;} 
    public string aggNo {get; set;}
    public string aggStartDate {get; set;}
    public static TPA_Request__c tpaRequest {get; set;}
    public static String vendorCountry {get; set;}
    public TPA_Request__c agreement {get; set;} 
    
    
    public static Map<ID, IMS_Master_Legal_Entity__c> mapOfIdWithlegalEntityObj;
    
    public static Map<Id,wrapperClassOfLegalEntity> mapIdWithObjofwrapperClassOfLegalEntity{get; set;}

    public String clientCompanyName{get; set;}
    public string clientAddress {get; set;}
    public string clientContactName {get; set;}
    public string clientContactEmail {get; set;}
    public string clientRepresentativeName {get; set;}
    public string clientRepresentativeEmail {get; set;}
     
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

    public static boolean AddendumAdditionalTermsRequiredOrNot(TPA_Request__c reqObj) {
        Id = reqObj.Id;
        reqVendorAccountId = reqObj.Service_Provider_Address__r.id;
        tpaRequest = reqObj;
        reqObj = null; //Setting null after use to save heap size
        loadDataForDynamicOfferingNotification();
        if(mapIdWithWrapperClassList != null && mapIdWithWrapperClassList.size() > 0 ) {
            return true;
        }
        return false;
    }

    public static void loadDataForDynamicOfferingNotification() {
        system.debug('Inside loadDataForDynamicOfferingNotification');
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
        //String Use = '';
        //String countryOfOffering = '';
        
        mapIdWithWrapperClassList= new Map<Id,List<wrapperClassAssetPurposeWithAddendumTerms>>();
        
        mapOfIdWithTextEditorObj = new Map<ID, TPA_Text_Editor__C>([Select Content__c, Page_Name__c, English_Translation__c FROM TPA_Text_Editor__c WHERE Page_Type__c = 'TPA Offering Addendum']);

        String GBVendorId = null;
        if(tpaRequest.Service_Provider_Address__c != null && tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c != null){
            GBVendorId = tpaRequest.Service_Provider_Address__r.Parent_Vendor_Name__c + '';
            UTL_TPA.GlobalBrandingVendorId = GBVendorId;
        }
        system.debug('in addendum UTL_TPA.GlobalBrandingVendorId: ' + UTL_TPA.GlobalBrandingVendorId);
        
        //List<TPA_Purpose__c> TPAPurposetList = SRV_TPA_TPARequest.getPurposeAndDescriptionList(Id);
        List<TPA_Purpose__c> TPAPurposetList = SRV_TPA_TPARequest.getPurposesList(Id);
        //CNT_TPA_RequestSubmissionForm.getLimitsMessage();

        //Set<Id> masterPurposeIds = new Set<Id>();
        // Set<Id> transactionalPurposeIds = new Set<Id>();
        if(SRV_TPA_TPARequest.allPurposeIds == null || SRV_TPA_TPARequest.allPurposeIds.size() == 0) {
            for(TPA_Purpose__c purposeObj :TPAPurposetList){
                SRV_TPA_TPARequest.allPurposeIds.add(purposeObj.Purpose__r.Id);
                SRV_TPA_TPARequest.transactionalPurposeIds.add(purposeObj.Id);
            }
           // SRV_TPA_TPARequest.allPurposeIds = masterPurposeIds;
        }                                         
        
        if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap == null || SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.size() == 0) {
            SRV_TPA_TPARequest.getdynamicOffNotificationMappingMaps(reqVendorAccountId);
        }
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();

        //List<TPA_Data_Asset__c> tpaDataAssets = SRV_TPA_TPARequest.tpaDataAssetListCopy(transactionalPurposeIds); 
        //List<TPA_Data_Asset__c> tpaDataAssets = [select Purpose__r.Purpose__r.id, Data_Asset__r.id, Data_Asset__r.BU__c, IMSLegalEntity__c, IMSLegalEntity__r.IMS_Master_Legal_Entity__r.id, (select id, IMS_Secondary_Data_Asset__r.id from TPA_Secondary_Data_Assets__r) From TPA_Data_Asset__c t where Purpose__c IN : SRV_TPA_TPARequest.transactionalPurposeIds order by Primary_Asset_Geo_Level__c]; 
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();
       
        String useID = '';   
        String countryName = '';  
        String priOffID = ''; 
        String secOffID = ''; 
        String vendorAccID = '';        
        
        List<TPA_Offering_Notification_Mapping__c> lstOffNotMapObj;
        List<Id> lstTextEditorObjId;

        Id legalEntityId = null;
        //for(TPA_Data_Asset__c dataAssetObj : [select Purpose__r.Purpose__r.id, Data_Asset__r.id, Data_Asset__r.BU__c, IMSLegalEntity__c, IMSLegalEntity__r.IMS_Master_Legal_Entity__r.id, (select id, IMS_Secondary_Data_Asset__r.id from TPA_Secondary_Data_Assets__r) From TPA_Data_Asset__c t where Purpose__c IN : SRV_TPA_TPARequest.transactionalPurposeIds order by Primary_Asset_Geo_Level__c]) {
        for(TPA_Data_Asset__c dataAssetObj : SRV_TPA_TPARequest.tpaDataAssetForDynamicNotiList(SRV_TPA_TPARequest.transactionalPurposeIds)) {
            useID = dataAssetObj.Purpose__r.Purpose__r.id + '';
            priOffID = dataAssetObj.Data_Asset__r.id + '';
            secOffID = '';
            countryName = dataAssetObj.Data_Asset__r.BU__c;
            vendorAccID = reqVendorAccountId + '';
            legalEntityId = null;
            lstOffNotMapObj = new list <TPA_Offering_Notification_Mapping__c>();
            lstTextEditorObjId = new list <Id> ();

            if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':'));
            }
            else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':'));
            }
            if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + GBVendorId + '::' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + GBVendorId + '::' + priOffID + ':'));
            }
            else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + vendorAccID + '::' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + vendorAccID + '::' + priOffID + ':'));
            }
            if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + '::' + useID +':' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + '::' + useID +':' + priOffID + ':'));
            }
            if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':::' + priOffID + ':') ) {
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':::' + priOffID + ':'));
            }
            for(TPA_Secondary_Data_Asset__c secdataAssetObj : dataAssetObj.TPA_Secondary_Data_Assets__r){
                secOffID = secdataAssetObj.IMS_Secondary_Data_Asset__r.id + '';
                if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':' + secOffID)) {
                    lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':' + secOffID));
                }
                else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':' + secOffID) ) {
                    lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':' + secOffID));
                }
                else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + GBVendorId + '::' + priOffID + ':' + secOffID)) {
                    lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + GBVendorId + '::' + priOffID + ':' + secOffID));
                }
                else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + vendorAccID + '::' + priOffID + ':' + secOffID)) {
                    lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + vendorAccID + '::' + priOffID + ':' + secOffID));
                }
                else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + '::' + useID +':' + priOffID + ':' + secOffID)) {
                    lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + '::' + useID +':' + priOffID + ':' + secOffID));
                }
                else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':::' + priOffID + ':' + secOffID)) {
                    lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':::' + priOffID + ':' + secOffID));
                }
            }
            if(lstOffNotMapObj != null && lstOffNotMapObj.size () > 0) {
                if(dataAssetObj.IMSLegalEntity__c == null && dataAssetObj.TPA_Secondary_Data_Assets__r != null && dataAssetObj.TPA_Secondary_Data_Assets__r.size() > 0){
                    legalEntityId = dataAssetObj.TPA_Secondary_Data_Assets__r[0].IMS_Legal_Entity__r.IMS_Master_Legal_Entity__r.id;
                    system.debug('1legalEntityId:'+legalEntityId);
                }
                else {
                    legalEntityId = dataAssetObj.IMSLegalEntity__r.IMS_Master_Legal_Entity__r.id;
                    system.debug('2legalEntityId:'+legalEntityId);
                }
                
                for(TPA_Offering_Notification_Mapping__c OffMapObj: lstOffNotMapObj){
                    lstTextEditorObjId.add(OffMapObj.TLLA_Additional_Terms__r.id);
                }
                
                checkWhetherThisNotificationisAdded(lstTextEditorObjId, lstOffNotMapObj.get(0).Purpose_Name__c,lstOffNotMapObj.get(0).IMS_Primary_Data_Asset__r.Asset_Name__c,'',lstOffNotMapObj.get(0).Offering_Country_Name__c,legalEntityId);
            }            
        }
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();       

        Boolean UseVendorLevelNotificationExist = false;
        Boolean UseLevelNotificationExist = false;
        
        for(TPA_Purpose__c purposeObj : TPAPurposetList) {
            UseVendorLevelNotificationExist = false;
            UseLevelNotificationExist = false;
            useID = purposeObj.Purpose__r.id + '';
            priOffID = '';
            secOffID = '';
            countryName = purposeObj.BU__c;
            lstOffNotMapObj = new list <TPA_Offering_Notification_Mapping__c>();
            lstTextEditorObjId = new list <Id> ();

            if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + GBVendorId + ':' + useID +'::'));
            }
            else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + ':' + vendorAccID + ':' + useID +'::'));
            }
            if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey('ALL' + ':' + GBVendorId + ':' + useID +'::') ){
                lstOffNotMapObj.addAll( SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get('ALL' + ':' + GBVendorId + ':' + useID +'::'));
            }
            else if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey('ALL' + ':' + vendorAccID + ':' + useID +'::') ){
                lstOffNotMapObj.addAll( SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get('ALL' + ':' + vendorAccID + ':' + useID +'::'));
            }
            if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey(countryName + '::' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get(countryName + '::' + useID +'::'));
            }
            if(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.containsKey('ALL' + '::' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.dynamicOffNotificationMappingWithCountryMap.get('ALL' + '::' + useID +'::'));
            }

            if(lstOffNotMapObj != null && lstOffNotMapObj.size () > 0) {
                for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj) {
                    lstTextEditorObjId.add(OffMapObj.TLLA_Additional_Terms__r.id);
                }
                checkWhetherThisNotificationisAdded(lstTextEditorObjId, lstOffNotMapObj.get(0).Purpose_Name__c,'ALL','ALL','ALL',purposeObj.IMS_Legal_Entity__r.IMS_Master_Legal_Entity__r.id);
            }
        }

        //List <IMS_Legal_Entity__c> LegalEntityList = [SELECT Id, Name,Name_for_ESign__c ,IMS_Master_Legal_Entity__c,IMS_Master_Legal_Entity__r.id From IMS_Legal_Entity__c Where TPA_Request__c =: Id]; 

        Boolean isVendorMatched = false; 
        for(IMS_Legal_Entity__c obj: [SELECT Id, Name,Name_for_ESign__c ,IMS_Master_Legal_Entity__c,IMS_Master_Legal_Entity__r.id From IMS_Legal_Entity__c Where TPA_Request__c =: Id]) {
            for(TPA_Offering_Notification_Mapping__c OffNotificationMappingObj : SRV_TPA_TPARequest.offNotMappingLst) {
                isVendorMatched = false; 
               // system.debug(SRV_TPA_TPARequest.gettpaOfferingNotificationAcctMappingMap(reqVendorAccountId));

                if(SRV_TPA_TPARequest.gettpaOfferingNotificationAcctMappingMap(reqVendorAccountId).get(OffNotificationMappingObj.id) != null && SRV_TPA_TPARequest.gettpaOfferingNotificationAcctMappingMap(reqVendorAccountId).get(OffNotificationMappingObj.id).contains(reqVendorAccountId)){
                    isVendorMatched = true;
                }
               // system.debug('isVendorMatched:'+isVendorMatched);

                if(OffNotificationMappingObj.IMS_Primary_Data_Asset__c == null && OffNotificationMappingObj.IMS_TPA_Purpose__c == null && OffNotificationMappingObj.TLLA_Additional_Terms__c != null && isVendorMatched && (OffNotificationMappingObj.Country__c == null || OffNotificationMappingObj.Country__c == 'ALL' ||(OffNotificationMappingObj.Country__c != null && vendorCountry != null && vendorCountry == OffNotificationMappingObj.Country__c))){
                    checkWhetherThisNotificationisAdded(new List <id> {OffNotificationMappingObj.TLLA_Additional_Terms__r.Id}, 'ALL','ALL','ALL','ALL',obj.IMS_Master_Legal_Entity__r.id);
                    break;
                }
            }
        }

        mapOfIdWithlegalEntityObj = new Map<ID, IMS_Master_Legal_Entity__c>([Select Name,Name_for_ESign__c,Legal_Entity_Title__c FROM IMS_Master_Legal_Entity__c ]);

        IMS_Master_Legal_Entity__c legalEntityObj;
        string url;
        String name = '';
        mapIdWithObjofwrapperClassOfLegalEntity= new Map<Id,wrapperClassOfLegalEntity>();
        ID legalEntityDocid = null;

        for(Id IdofLegalEntity : mapIdWithWrapperClassList.keySet()) {
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
        
            mapIdWithObjofwrapperClassOfLegalEntity.put(IdofLegalEntity,new wrapperClassOfLegalEntity(legalEntityObj.name,url,legalEntityObj.Legal_Entity_Title__c,legalEntityObj.Name_for_ESign__c));
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
        public wrapperClassOfLegalEntity(String legalEntityName,String legalentityurl, String legalEntityTitle,String EsignName){
            name = legalEntityName;
            url = legalentityurl;
            title = legalEntityTitle;
            NameOfESign = EsignName;

        }
        public string url {get;set;}
        public string name {get;set;}
        public string title {get;set;}
        public string NameOfESign {get;set;}
    }

    

    public string vendorLanguage { get; set; }

    public CNT_TPA_AddendumNotification(){
        system.debug('inside CNT_TPA_AddendumNotification constructor');
        Id = ApexPages.currentPage().getParameters().get('id');
        reqVendorAccountId = ApexPages.currentPage().getParameters().get('reqVendorAccountId');
        openmode = ApexPages.currentPage().getParameters().get('mode');
        aggNo = ApexPages.currentPage().getParameters().get('aggNo');
        aggStartDate = ApexPages.currentPage().getParameters().get('aggStartDate');

        tpaRequest = [Select name,Client_Address__c,Client_Address__r.Name, Client_Address__r.Region_Territory__c, Client_Address__r.Country__c,
                                     ClientContact__r.firstName,ClientContact__r.lastname,ClientContact__r.Email ,
                                     Service_Provider_Address__r.Name,Today_Date_TLLA__c,Vendor_Billing_Mailing_Country__c,
                                     Data_Access_Start_Date__c,Service_Provider_Address__r.Parent_Vendor_Name__c,Service_Provider_Address__c,
                                     Today_s_Date__c, Client_TPA_Representative_Name__c, Client_TPA_Representative_Email__c 
                                     FROM TPA_Request__c where id = :Id];
        docTitle = 'TPA Addendum Document' ;  
        vendorCountry =  tpaRequest.Vendor_Billing_Mailing_Country__c;
        Date dataAccessstartDate = tpaRequest.Data_Access_Start_Date__c;
        clientCompanyName = '  ' + tpaRequest.Client_Address__r.Name;
        if(tpaRequest.Client_Address__r.Region_Territory__c != null && tpaRequest.Client_Address__r.Region_Territory__c != '' ){
            clientAddress = '  ' + tpaRequest.Client_Address__r.Region_Territory__c;
        }
        if(tpaRequest.Client_TPA_Representative_Name__c == null && tpaRequest.Client_TPA_Representative_Email__c == null){
            clientContactName = '  ' + tpaRequest.ClientContact__r.firstName + ' ' + tpaRequest.ClientContact__r.lastname;
            clientContactEmail = '  ' + tpaRequest.ClientContact__r.Email;
        }
        else {
            clientRepresentativeName = '  ' + tpaRequest.Client_TPA_Representative_Name__c;
            clientRepresentativeEmail = '  ' + tpaRequest.Client_TPA_Representative_Email__c;
        }
        

        title = 'Third Party Management Attribute Addendum'+'<br>' + 'To TPA Limited License Agreement No.' + aggNo + '<br>' + 'Effective Date:' + DateTime.newInstance(dataAccessstartDate.year(),dataAccessstartDate.month(),dataAccessstartDate.day()).format('MM/dd/YY') ;
        clientVendorNote = 'This Third Party Management Attribute Addendum ("Addendum") is entered into by and between:';
        clientNote = 'The '+Label.TPA_IQVIA_Keyword+' Technology listed below will be used by Vendor solely for the benefit of the following Client:';
        addendumNote = 'This Addendum is effective as of the Effective Date written above.  It is expressly incorporated into the TPA Limited License Agreement (“TPA Agreement”) referenced above. Notwithstanding any other terms of the TPA Agreement, Vendor is not authorized to access or use the '+Label.TPA_IQVIA_Keyword+' Data attributes described below, nor has Client been authorized to share such '+Label.TPA_IQVIA_Keyword+' Data attributes with Vendor. Vendor will promptly notify '+Label.TPA_IQVIA_Keyword+' of receipt of such '+Label.TPA_IQVIA_Keyword+' Data attributes and cooperate with '+Label.TPA_IQVIA_Keyword+' and the Client to terminate such access and delete or destroy such '+Label.TPA_IQVIA_Keyword+' Data attributes. ';
        LoadStyles();
        loadDataForDynamicOfferingNotification();
    }

    
    public static void checkWhetherThisNotificationisAdded(List<Id> lsttxtEditorObjId, String use, String primaryOffering,String secondryOffering,String countryOfOffering, Id legalEntityId) {
        if(secondryOffering == null || secondryOffering == ''){ 
            secondryOffering = 'ALL';                           
        }                                                       
        Boolean notificationAlredyAdded = false;
        TPA_Text_Editor__c obj = null;
        String offNotificationContent = '';

        for(Id txtEditorObjId :lsttxtEditorObjId) {
          obj = mapOfIdWithTextEditorObj.get(txtEditorObjId);
          offNotificationContent += obj.Content__c + '<br>';
        }

        if(mapIdWithWrapperClassList.containsKey(legalEntityId)) {
            List<wrapperClassAssetPurposeWithAddendumTerms> WrapperClassList1 = mapIdWithWrapperClassList.get(legalEntityId);
            WrapperClassList1.add(new wrapperClassAssetPurposeWithAddendumTerms(offNotificationContent,use,primaryOffering,secondryOffering,countryOfOffering));
            mapIdWithWrapperClassList.put(legalEntityId, WrapperClassList1);
        } else {
            mapIdWithWrapperClassList.put(legalEntityId, new List<wrapperClassAssetPurposeWithAddendumTerms> { new wrapperClassAssetPurposeWithAddendumTerms(offNotificationContent,use,primaryOffering,secondryOffering,countryOfOffering) });
        }  
        system.debug('mapIdWithWrapperClassList:'+mapIdWithWrapperClassList);
    }

    public class wrapperClassAssetPurposeWithAddendumTerms {
        public string cotent {get;set;}
        public string use {get;set;}
        public string priOffering {get;set;}
        public string secOffering {get;set;}
        public String offeringCountry{get;set;}

        public wrapperClassAssetPurposeWithAddendumTerms(String AddendumContent, String useName, String priOfferingName, String secOfferingName, String offeringOfCountry) {
            cotent = AddendumContent;
            use = useName;
            priOffering = priOfferingName;
            secOffering = secOfferingName;
            offeringCountry = offeringOfCountry;
        }        
    }    
}
