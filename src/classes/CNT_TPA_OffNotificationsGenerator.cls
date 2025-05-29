global without sharing class CNT_TPA_OffNotificationsGenerator {
    public string Id {get; set;} 
    public string reqVendorAccountId{get; set;} 
    public string vendorCountry{get; set;} 
    public List<TPA_Text_Editor__C> dynamicOfferingsNotificationList {get; set;}
    public Map<ID, TPA_Text_Editor__C> mapOfIdWithTextEditorObj{get; set;}
    public set<string> countryCodeSet;
    public string translationLanguageField {get; set;}
    public string clientVendorNote {get; set;}
    public List<TPA_Text_Editor__C> offeringsNotificationList {get; set;}
    public string title {get; set;}
    public string openmode {get; set;}
    public string requestName {get; set;}
    public static TPA_Request__c tpaRequestToEdit {get; set;}
    
    public static Map<String, String> supportedLangCodeMap {
        get {
            if(supportedLangCodeMap == null) {
                supportedLangCodeMap = new Map<String, String>();
                system.debug('In TPA_OfferingNotificationsController : SuppLangCodeFieldNameLocalName' + UTL_TPA_Multilingual.SuppLangCodeFieldNameLocalName);
                if(UTL_TPA_Multilingual.SuppLangCodeFieldNameLocalName != null)
                    for(string mlGloSettObj :UTL_TPA_Multilingual.SuppLangCodeFieldNameLocalName.split(';'))
                    {
                        supportedLangCodeMap.put(mlGloSettObj.split('=')[1].split('~')[1], mlGloSettObj.split('=')[0]);
                    }
            }
            return supportedLangCodeMap;
        }
        private set{supportedLangCodeMap = value;}
    }
    public string vendorLanguage { get; set; }
    
    public CNT_TPA_OffNotificationsGenerator()
    {
        Id = ApexPages.currentPage().getParameters().get('id');
        System.debug('ApexPages.currentPage().getParameters().get(id)-----------------------> ' + ApexPages.currentPage().getParameters().get('id'));
        reqVendorAccountId = ApexPages.currentPage().getParameters().get('reqVendorAccountId');
        vendorCountry = ApexPages.currentPage().getParameters().get('reqVendorCountary');
        translationLanguageField = ApexPages.currentPage().getParameters().get('language_Field');
        openmode = ApexPages.currentPage().getParameters().get('mode');
        vendorLanguage = supportedLangCodeMap.get(translationLanguageField);
        mapOfIdWithTextEditorObj = new Map<ID, TPA_Text_Editor__C>([Select Content__c,Page_Name__c,English_Translation__c FROM TPA_Text_Editor__c ]);
        System.debug('reqVendorCountary-----------------------> ' + ApexPages.currentPage().getParameters().get('reqVendorCountary'));
        countryCodeSet = CNT_TPA_RequestSubmissionForm.createStateCountryNameSet(vendorCountry, 'C');
        loadData();
        Set<String> stUSCodes = new Set<String>{'US','U.S.','USA','United States Of America','U.S','U.S.A','United States','U.S.A.'};
        loadDataForDynamicOfferingNotification();
    }
    
    public void loadData()
    {        
        title = 'Offering Notifications';
        if(Id != null && Id.trim().length() > 0)
        {
            List<TPA_Text_Editor__C> txtOffNotifications = [SELECT Id, 
                                                                   Name, 
                                                                   Content__c, 
                                                                   Page_Name__c, 
                                                                   Page_Title__c, 
                                                                   Page_Type__c,
                                                                   English_Translation__c, 
                                                                   Japanese_Translation__c
                                                            FROM TPA_Text_Editor__c 
                                                            WHERE Page_Type__c = 'Tpa Offering Notifications'];
            offeringsNotificationList = new List<TPA_Text_Editor__C>();
            
            // Set of unique master data assets ids that require offering notification.
            set<String> masterDataAssetIDsSet = new set<String>();
            
            for(TPA_Data_Asset__c dataAssetObj :[SELECT Id, Name, Data_Asset__c, Request__r.Name From TPA_Data_Asset__c Where Request__c =: Id and Data_Asset__r.Is_Notification_Required__c = true])
            {
                masterDataAssetIDsSet.add(dataAssetObj.Data_Asset__c);
                requestName = dataAssetObj.Request__r.Name;
            }
            for(TPA_Text_Editor__C txtEditorObj: txtOffNotifications)
            {
                String content = (String)txtEditorObj.get(translationLanguageField) == null ? txtEditorObj.Content__c : (String)txtEditorObj.get(translationLanguageField);
                System.debug('Contect After :: ' + txtEditorObj.Page_Name__c + '    ' + (String)txtEditorObj.get(translationLanguageField));
                
                if(txtEditorObj.Page_Name__c == 'Client/Vendor Notification')
                    clientVendorNote = content;
                else if(txtEditorObj.Page_Title__c != null)
                {
                    for(String dataAssetId : masterDataAssetIDsSet)
                    {
                        if(txtEditorObj.Page_Title__c != null && dataAssetId != null && dataAssetId.indexOf(txtEditorObj.Page_Title__c) != -1)
                        {
                            txtEditorObj.Content__c = content;
                            System.debug('Contect 222:: ' + txtEditorObj.Content__c );
                            offeringsNotificationList.Add(txtEditorObj);
                        }
                    }
                }
            }
        }
    }
    
    public void loadDataForDynamicOfferingNotification(){
        dynamicOfferingsNotificationList = new List<TPA_Text_Editor__C>();
        Set<Id>  listOfPriAssestForWhichNotificationNotAddedUsingSec = new Set<Id>();
        Set<Id>  listOfPriAssestForWhichNotificationAddedUsingSec = new Set<Id>();
        Set<Id>  useForWhichNotificationAddedAlready= new Set<Id>();
        String useID = '';   String countryName = '';  String priOffID = ''; String secOffID = ''; String vendorAccID = '';
        vendorAccID = reqVendorAccountId + '';
        String GBVendorId = null;
        Set<Id> masterPurposeIds = new Set<Id>();
        List<TPA_Request__c> reqList = [select id,Service_Provider_Address__c,Service_Provider_Address__r.Parent_Vendor_Name__c from TPA_Request__c where id =: Id] ;

        if(reqList != null && reqList.size() > 0){
            if(reqList[0].Service_Provider_Address__c != null && reqList[0].Service_Provider_Address__r.Parent_Vendor_Name__c != null){
                GBVendorId = reqList[0].Service_Provider_Address__r.Parent_Vendor_Name__c + '';
                UTL_TPA.GlobalBrandingVendorId = GBVendorId;
            }
        }
        system.debug('GBVendorId: ' +GBVendorId);
        Set <TPA_Offering_Notification_Mapping__c> lstOffNotMapObj ;

        List<TPA_Text_Editor__C> txtOffNotifications = [SELECT Id, Name, Content__c, Page_Name__c, Page_Title__c, Page_Type__c FROM TPA_Text_Editor__c WHERE Page_Type__c = 'Tpa Offering Notifications Mapping'];
        
        List <TPA_Purpose__c> TPAPurposetList = [SELECT Id, Name, Purpose__c,Purpose__r.Primary_Purpose_Name__c, BU__c,
                                                 Request__r.Name From TPA_Purpose__c Where Request__c =: Id];
        
        if(SRV_TPA_TPARequest.allPurposeIds == null || SRV_TPA_TPARequest.allPurposeIds.size() == 0){
            for(TPA_Purpose__c purposeObj :TPAPurposetList){
                masterPurposeIds.add(purposeObj.Purpose__r.Id);
            }
            SRV_TPA_TPARequest.allPurposeIds = masterPurposeIds;
        }                                         

        if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap == null || SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.size() == 0){
            SRV_TPA_TPARequest.getdynamicOffNotificationMappingMaps(reqVendorAccountId);
        }
        
        List <TPA_Secondary_Data_Asset__c> secDataAssestList = [Select name,IMS_Secondary_Data_Asset__c,IMS_Secondary_Data_Asset__r.id,  //secondary data asset
                                                                TPA_Data_Asset__r.Data_Asset__c , //primary data assest
                                                                TPA_Data_Asset__r.Data_Asset__r.BU__c, //off country
                                                                TPA_Data_Asset__r.Purpose__r.Purpose__c, //primary purpose
                                                                TPA_Data_Asset__r.Purpose__r.Purpose__r.Primary_Purpose_Name__c
                                                                from TPA_Secondary_Data_Asset__c where TPA_Request_Secondary_Assets__c =: Id];
        
        for(TPA_Secondary_Data_Asset__c secdataAssetObj :secDataAssestList){
            useID = secdataAssetObj.TPA_Data_Asset__r.Purpose__r.Purpose__r.id + '';
            priOffID = secdataAssetObj.TPA_Data_Asset__r.Data_Asset__r.id + '';
            secOffID = secdataAssetObj.IMS_Secondary_Data_Asset__r.id + '';
            countryName = secdataAssetObj.TPA_Data_Asset__r.Data_Asset__r.BU__c;
            lstOffNotMapObj = new Set <TPA_Offering_Notification_Mapping__c>();

            if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':' + secOffID) ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':' + secOffID));
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':' + secOffID) ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':' + secOffID));
            }
            if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + '::' + priOffID + ':' + secOffID)){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + '::' + priOffID + ':' + secOffID)) ;
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + '::' + priOffID + ':' + secOffID)){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + '::' + priOffID + ':' + secOffID)) ;
            }
            if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + '::' + useID +':' + priOffID + ':' + secOffID)){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + '::' + useID +':' + priOffID + ':' + secOffID))  ;
            }
            if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':::' + priOffID + ':' + secOffID)){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':::' + priOffID + ':' + secOffID)) ;
            }
            if(lstOffNotMapObj != null && lstOffNotMapObj.size () > 0){
                for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj){
                  checkWhetherThisNotificationisAdded(OffMapObj.Offering_Notifications__r.id,OffMapObj.OfferingName__c);
                }
            }
            
        }
        
        Set<Id>  listOfPriAssestForWhichNotificationAdded = new Set<Id>();
        listOfPriAssestForWhichNotificationAddedUsingSec.removeAll(listOfPriAssestForWhichNotificationNotAddedUsingSec);
        listOfPriAssestForWhichNotificationAdded = listOfPriAssestForWhichNotificationAddedUsingSec;
        
        
        List <TPA_Data_Asset__c> TPADataAssetList = [SELECT Id, Name, Data_Asset__c,Data_Asset__r.BU__c,
                                                     Purpose__c,Purpose__r.Purpose__c,Purpose__r.Purpose__r.Primary_Purpose_Name__c,
                                                     Request__r.Name From TPA_Data_Asset__c Where Request__c =: Id];
        
        for(TPA_Data_Asset__c dataAssetObj :TPADataAssetList){
            useID = dataAssetObj.Purpose__r.Purpose__r.id + '';
            priOffID = dataAssetObj.Data_Asset__r.id + '';
            secOffID = '';
            countryName = dataAssetObj.Data_Asset__r.BU__c;
            lstOffNotMapObj = new Set <TPA_Offering_Notification_Mapping__c>();
            if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + ':' + useID +':' + priOffID + ':'))  ;
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + ':' + useID +':' + priOffID + ':'))  ;
            }
            if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + '::' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + '::' + priOffID + ':'))  ;
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + '::' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + '::' + priOffID + ':'))  ;
            }
            if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + '::' + useID +':' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + '::' + useID +':' + priOffID + ':'))  ;
            }
            if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':::' + priOffID + ':') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':::' + priOffID + ':'))  ;
            }
            if(lstOffNotMapObj != null && lstOffNotMapObj.size () > 0){
                for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj){
                  checkWhetherThisNotificationisAdded(OffMapObj.Offering_Notifications__r.id,OffMapObj.OfferingName__c);
                }
            }
            
        }
       
        
        priOffID = '';
        secOffID = '';
        for(TPA_Purpose__c purposeObj :TPAPurposetList){
            useID = purposeObj.Purpose__r.id + '';
            countryName = purposeObj.BU__c;
            lstOffNotMapObj = new Set <TPA_Offering_Notification_Mapping__c>();
            system.debug('purposeObj.Purpose__c:'+purposeObj.Purpose__c);
            if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + GBVendorId + ':' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + GBVendorId + ':' + useID +'::')) ;
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + ':' + vendorAccID + ':' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + ':' + vendorAccID + ':' + useID +'::')) ;
            }
            if(GBVendorId != null && SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey('ALL' + ':' + GBVendorId + ':' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get('ALL' + ':' + GBVendorId + ':' + useID +'::'))  ;
            }
            else if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey('ALL' + ':' + vendorAccID + ':' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get('ALL' + ':' + vendorAccID + ':' + useID +'::'))  ;
            }
            if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(countryName + '::' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(countryName + '::' + useID +'::'))  ;
            }
            if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey('ALL' + '::' + useID +'::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get('ALL' + '::' + useID +'::'))  ;
            }
            if(lstOffNotMapObj != null && lstOffNotMapObj.size () > 0){
              for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj){
                checkWhetherThisNotificationisAdded(OffMapObj.Offering_Notifications__r.id,'');
              }

            }
        }
        priOffID = '';
        secOffID = '';
        useID ='';
        lstOffNotMapObj = new Set <TPA_Offering_Notification_Mapping__c>();
        for(String VendorCountry:countryCodeSet){
            if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey(VendorCountry + ':' + vendorAccID + ':::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get(VendorCountry + ':' + vendorAccID + ':::'));
                for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj){
                  checkWhetherThisNotificationisAdded(OffMapObj.Offering_Notifications__r.Id,'');
                }

            }
        }
        if(lstOffNotMapObj == null || lstOffNotMapObj.size () == 0){
            if(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.containsKey('ALL' + ':' + vendorAccID + ':::') ){
                lstOffNotMapObj.addAll(SRV_TPA_TPARequest.tpaOffNotRulesForOffNotiMap.get('ALL' + ':' + vendorAccID + ':::'));
                for(TPA_Offering_Notification_Mapping__c OffMapObj:lstOffNotMapObj){
                    checkWhetherThisNotificationisAdded(OffMapObj.Offering_Notifications__r.Id,'');
                }
                
            }
        }
    }
    
    public void checkWhetherThisNotificationisAdded(Id id, String OfferingName){
        Boolean notificationAlredyAdded = false;
        TPA_Text_Editor__c obj = mapOfIdWithTextEditorObj.get(id);
       
        system.debug(mapOfIdWithTextEditorObj);
        system.debug('obj'+obj);
        if(obj.Content__c != NULL && obj.Content__c != '' && !obj.Content__c.contains('<Strong><u>Offerings</u>')){
            obj.English_Translation__c = obj.Content__c;
        }
        if(obj.Page_Name__c.contains('<Strong><u>Offerings</u>')){
            obj.Page_Name__c += ', <Strong>' + OfferingName + '</Strong>';
        }else{
            obj.Page_Name__c = '<Strong><u>Offerings</u>:- '+OfferingName + '</Strong>';
        }    
        String offNotificationContent = obj.English_Translation__c ;
        obj.Content__c = obj.Page_Name__c + obj.English_Translation__c ;
      
        offNotificationContent = offNotificationContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', '');
        if(dynamicOfferingsNotificationList != Null && dynamicOfferingsNotificationList.size() >0 )
        {
            for(TPA_Text_Editor__C textEditorObj :dynamicOfferingsNotificationList)
            {
                String textEditorContent = textEditorObj.English_Translation__c ;
                textEditorContent = textEditorContent.toLowerCase().trim().replaceAll('<[/a-zAZ0-9 ]*>','').replaceAll('[^a-zA-Z0-9]', '');
                
                if(textEditorContent == offNotificationContent)
                {
                    notificationAlredyAdded = true;
                    break;
                }
            }
        }
        else
        {
            dynamicOfferingsNotificationList.add(obj);
            return;
        }
        if(!notificationAlredyAdded)
        {
            dynamicOfferingsNotificationList.add(obj); 
        }
    }
}