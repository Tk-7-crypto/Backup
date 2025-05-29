public without sharing class UTL_TPA_Multilingual {  
    /************
    Properties
    *************/
    public static Map<String, List<TPA_Language_Cross_Walk__c>> translationMap{get; set;}

    public static List<TPA_Multilingual_Template_Setting__c> multiLingualTemplateSettings {
        get {
            if(multiLingualTemplateSettings == null) {
                multiLingualTemplateSettings = TPA_Multilingual_Template_Setting__c.getAll().values();
            }
            return multiLingualTemplateSettings;
        }
        private set{multiLingualTemplateSettings = value;}
    }

    //Map : Key: Label + Language, Value: Template setting object
    //Used to retrieve a record with given label and language
    public static map<String, TPA_Multilingual_Template_Setting__c> multiLingualTemplateSettingsMap {
        get {
            if(multiLingualTemplateSettingsMap == null) {
                multiLingualTemplateSettingsMap = new map<String, TPA_Multilingual_Template_Setting__c>();
                for(TPA_Multilingual_Template_Setting__c templateObj : TPA_Multilingual_Template_Setting__c.getAll().values()) {
                    multiLingualTemplateSettingsMap.put(templateObj.label__c + templateObj.Language__c , templateObj);
                }
            }
            return multiLingualTemplateSettingsMap;
        }
        private set{multiLingualTemplateSettingsMap = value;}
    }

    /**
     * @param: template setting label, client/vendor preferred language
     * @return: template id based on clinet/vendor preffered language
     */
    public static Id getEmailTemplateId(String tempName, String prefLang) {
        String preferredLanguage = prefLang != null ? prefLang : 'English';
        return multiLingualTemplateSettingsMap.get(tempName+preferredLanguage).Translated_Template_Id__c;
    }

    //Map : Key - Label, Value - Template setting object List
    //Used to retrieve all records(All languages) list for a particular label
    public static map<String, list<TPA_Multilingual_Template_Setting__c>> multiLingualTemplateSettingsListMap {
        get {
            if(multiLingualTemplateSettingsListMap == null) {
                multiLingualTemplateSettingsListMap = new map<String, list<TPA_Multilingual_Template_Setting__c>>();
                for(TPA_Multilingual_Template_Setting__c templateObj : TPA_Multilingual_Template_Setting__c.getAll().values()) {
                    list<TPA_Multilingual_Template_Setting__c> settlist = new list<TPA_Multilingual_Template_Setting__c>();
                    if(!multiLingualTemplateSettingsListMap.containsKey(templateObj.label__c)) {
                        multiLingualTemplateSettingsListMap.put(templateObj.label__c, new list<TPA_Multilingual_Template_Setting__c>{templateObj});
                    }
                    else {
                        settlist = multiLingualTemplateSettingsListMap.get(templateObj.label__c);
                        settlist.add(templateObj);
                        multiLingualTemplateSettingsListMap.put(templateObj.label__c, settlist);
                    }
                }
            }
            return multiLingualTemplateSettingsListMap;
        }
        private set{multiLingualTemplateSettingsListMap = value;}
    }
    
   

    public static string SuppLangCodeFieldNameLocalName {
        get {
            if(SuppLangCodeFieldNameLocalName == null) {
                SuppLangCodeFieldNameLocalName = '';
                if(multiLingualTemplateSettingsListMap != null) {
                    for(TPA_Multilingual_Template_Setting__c langEx : multiLingualTemplateSettingsListMap.get('SuppLangCode-FieldName-LocalName')) {
                        if(langEx.Translated_Template_Name__c != null)
                            SuppLangCodeFieldNameLocalName += langEx.Translated_Template_Name__c + ';';
                    }
                    if(SuppLangCodeFieldNameLocalName != '')
                        SuppLangCodeFieldNameLocalName = SuppLangCodeFieldNameLocalName.subString(0, SuppLangCodeFieldNameLocalName.length()-1);
                }
            }
            return SuppLangCodeFieldNameLocalName;
        }
        private set {
            SuppLangCodeFieldNameLocalName = value;
        }
    }
    
    public static Map<String, String> supportedLanguageCodeMap {
        get{
            if(supportedLanguageCodeMap == null){
                supportedLanguageCodeMap = new Map<String, String>();
                if(multiLingualTemplateSettings != null)
                    for(TPA_Multilingual_Template_Setting__c langFC :multiLingualTemplateSettings) {
                        if(langFC.Label__c == 'SupportedLanguageCodeFieldMap' && langFC.Translated_Template_Name__c != null)
                            supportedLanguageCodeMap.put(langFC.Language__c, langFC.Translated_Template_Name__c.split('=')[0]);
                    }
            }
            return supportedLanguageCodeMap;
        }
        private set{supportedLanguageCodeMap = value;}
    } //To-Do: change it to dynamic. merge this with below used setting i.e. Supported_Language_Field_Map__c n make it Supported_Language_Field_With_Code_Map__c

    public static Map<String, String> supportedLanguageCodeAndNameMap {
        get {
            if(supportedLanguageCodeAndNameMap == null) {
                supportedLanguageCodeAndNameMap = new Map<String, String>();
                if(multiLingualTemplateSettings != null)
                    for(TPA_Multilingual_Template_Setting__c langFC :multiLingualTemplateSettings) {
                        if(langFC.Label__c == 'SupportedLanguageCodeFieldMap' && langFC.Translated_Template_Name__c != null)
                            supportedLanguageCodeAndNameMap.put(langFC.Translated_Template_Name__c.split('~')[0].split('=')[0], langFC.Translated_Template_Name__c.split('~')[0].split('=')[1]);
                    }
            }
            return supportedLanguageCodeAndNameMap;
        }
        private set{supportedLanguageCodeAndNameMap = value;}
    }

    public static Map<String, String> supportedLanguageFieldMap {
        get {
            if(supportedLanguageFieldMap == null){
                supportedLanguageFieldMap = new Map<String, String>();
                if(SuppLangCodeFieldNameLocalName != null)
                    for(string mlGloSettObj : SuppLangCodeFieldNameLocalName.split(';')) {
                    supportedLanguageFieldMap.put(mlGloSettObj.split('~')[0].split('=')[1], mlGloSettObj.split('~')[1]);
                }
            }

            return supportedLanguageFieldMap;
        }
        private set{supportedLanguageFieldMap = value;}
    }

    public static TPA_Multilingual_Global_Settings__c mlGlobalSettings {
        get {
            if(mlGlobalSettings == null)
                mlGlobalSettings = TPA_Multilingual_Global_Settings__c.getOrgDefaults();
            return mlGlobalSettings;
        }
        private set{mlGlobalSettings = value;}
    }


    public static User CurrentUser {
        get{
            if(CurrentUser == null) {
                CurrentUser = UTL_TPA.getCurrentUserDetails();
                System.debug('In UTL_TPA_Multilingual :: CurrentUser = ' + CurrentUser);
            }
            return CurrentUser;
        }
        private set{CurrentUser = value;}
    }
    /***************
    Public Methods
    ****************/

    

    public static Map<String, List<TPA_Language_Cross_Walk__c>> langCrossWalkMap;//TODO: will review
    public static TPA_Request__c tpaReqObj;//TODO: will review
    public static void updateChildRecordsTranslation( string tpaRequestId, TPA_Request__c tpaReqObjRef) {
        Map<String, Schema.SobjectField> reqLocFieldsMap = Schema.SObjectType.TPA_Request_Localized__c.fields.getMap();
        
        string fieldsAsException = '';
        string fieldsPopulateDynam = '';
        string MultiSelectPicklistsToTranslate = '';
        string MultiSelectPicklistsCommaSeprated = '';
        if(multiLingualTemplateSettingsListMap != null) {
            for(TPA_Multilingual_Template_Setting__c langEx : multiLingualTemplateSettingsListMap.get('FieldsAsException')) {
                if(langEx.Translated_Template_Name__c != null) {
                    fieldsAsException += langEx.Translated_Template_Name__c + ';';
                }
            }

            for(TPA_Multilingual_Template_Setting__c langEx : multiLingualTemplateSettingsListMap.get('fieldsPopulateDynam')) {
                if(langEx.Translated_Template_Name__c != null) {
                    fieldsPopulateDynam += langEx.Translated_Template_Name__c + ';';
                }
            }

            for(TPA_Multilingual_Template_Setting__c langEx : multiLingualTemplateSettingsListMap.get('MultiSelect Picklist To Translate')) {
                if(langEx.Translated_Template_Name__c != null) {
                    MultiSelectPicklistsToTranslate += langEx.Translated_Template_Name__c + ';';
                }
            }

            for(TPA_Multilingual_Template_Setting__c langEx : multiLingualTemplateSettingsListMap.get('Multi Select Picklist With Comma')) {
                if(langEx.Translated_Template_Name__c != null) {
                    MultiSelectPicklistsCommaSeprated += langEx.Translated_Template_Name__c + ';';
                }
            }
        }
        
        system.debug('rHere-1:::');
        system.debug('rHere-1:::fieldsAsException ' + fieldsAsException);
        system.debug('rHere-1:::fieldsPopulateDynam ' + fieldsPopulateDynam);
        system.debug('rHere-1:::MultiSelectPicklistsToTranslate ' + MultiSelectPicklistsToTranslate);
        system.debug('rHere-1:::MultiSelectPicklistsCommaSeprated ' + MultiSelectPicklistsCommaSeprated);
        system.debug('in multilingual utility : supportedLanguageFieldMap' + supportedLanguageFieldMap);

        if(tpaReqObjRef != null && (tpaReqObjRef.Client_Language__c != null || tpaReqObjRef.Vendor_Language__c != null)) {
            tpaReqObj = tpaReqObjRef; //TODO: will review
        }
        else if(tpaReqObj == null) {
            //tpaReqObj = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId); //TODO: will review

            List<TPA_Request__c> tpaRequestList = [select id, Client_Language__c, Vendor_Language__c, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Authorized_Signer_Email__c, Authorized_Signer_First_Name__c, Authorized_Signer_Last_Name__c, Authorized_Signer_Title__c, Client_Contact_Territory__c, Client_Project_Name__c,  Data_Provided_By__c,  FrequencyOfDeliveryToSP_Other__c, FrequencyOfDeliveryToServiceProvider__c, Frequency_Of_Delivery__c, Frequency_of_Delivery_Other__c,  Legacy_Id__c, List_Of_Uses__c, Offerings_With_Category__c,  PurposeWithDataAsset__c, Region__c, Request_Status__c, Secondary_Client_Contact_Territory__c, Secondary_Location_Required__c, TPA_Purpose_Picklist_Apttus__c, Total_Deliveries__c, U_S_Prescriber_Level_Data_Outside_US__c, Vendor_Billing_Mailing_City__c, Vendor_Billing_Mailing_Country__c, Vendor_Billing_Mailing_State_Province__c, Vendor_Billing_Mailing_Street__c, Vendor_Billing_Mailing_Zip_Post_Code__c, Vendor_Company_Name__c, Vendor_Contact_Email_Client__c, Vendor_Contact_First_Name_Client__c, Vendor_Contact_Last_Name_Client__c, Vendor_Contact_Last_Name__c, Vendor_Contact_Phone__c, Vendor_Contact_Telephone_Client__c, Vendor_Contact_Title__c, Vendor_Employee_Country_AMA__c, Vendor_First_Name__c, Vendor_Phone__c, Vendor_Website__c, Vendor_e_mail__c from TPA_Request__c where id =: tpaRequestId];

            if(tpaRequestList != null && tpaRequestList.size() > 0) {
                tpaReqObj = tpaRequestList[0];
            }
        }

        Set<string> langSet = new Set<string>();
        if(tpaReqObj.Client_Language__c != null) {
            langSet.add(supportedLanguageFieldMap.get(tpaReqObj.Client_Language__c));
        }
        if(tpaReqObj.Client_Language__c != null && tpaReqObj.Vendor_Language__c != null && tpaReqObj.Client_Language__c != tpaReqObj.Vendor_Language__c) {
            langSet.add(supportedLanguageFieldMap.get(tpaReqObj.Vendor_Language__c));
        }
        if(tpaReqObj.Client_Language__c == null && tpaReqObj.Vendor_Language__c != null) {
            langSet.add(supportedLanguageFieldMap.get(tpaReqObj.Vendor_Language__c));
        }

        if(langSet.size() == 0) {
            return;
        }
        
        langCrossWalkMap = getTranslatedValueMap(langSet);//TODO: will review

        string langToBeRecordUpdated = '';
        
        List<TPA_Request_Localized__c> tpaReqLoclist = getRequestChildLocalizedRecords(tpaRequestId);

        for(TPA_Request_Localized__c tpaReqLocObj: tpaReqLoclist) {
            if(tpaReqLocObj.Record_Localized_For__c == 'client' || tpaReqLocObj.Record_Localized_For__c == 'client-vendor') {
                langToBeRecordUpdated = tpaReqObj.Client_Language__c;
            }
            else if(tpaReqLocObj.Record_Localized_For__c == 'vendor') {
                langToBeRecordUpdated = tpaReqObj.Vendor_Language__c;
            }

            for(string reqLocFieldRef: reqLocFieldsMap.keyset()) {
                if(reqLocFieldRef.indexOf('__c') == -1 || (fieldsPopulateDynam != null && fieldsPopulateDynam.containsIgnoreCase(reqLocFieldRef)) || (fieldsAsException != null && fieldsAsException.containsIgnoreCase(reqLocFieldRef))) {
                    continue;
                }

                if(String.valueOf(tpaReqObj.get(reqLocFieldRef)) == '--None--') {
                    tpaReqLocObj.put(reqLocFieldRef, getEqualTranslation((supportedLanguageFieldMap.get(langToBeRecordUpdated)+'~TPA_Request__c~Record~'+String.valueOf(tpaReqObj.get(reqLocFieldRef))), String.valueOf(tpaReqObj.get(reqLocFieldRef))));
                }
                else if(MultiSelectPicklistsToTranslate != null && MultiSelectPicklistsToTranslate.containsIgnoreCase(reqLocFieldRef)) {
                    for(string plComma: MultiSelectPicklistsToTranslate.split(';')) {
                        if(plComma.trim() == reqLocFieldRef) {
                            reqLocFieldRef = plComma.trim();
                        }
                    }

                    string mulSelPicTranslation = '';
                    
                    if(tpaReqObj.get(reqLocFieldRef) != null && (string)tpaReqObj.get(reqLocFieldRef)  != '') {
                        for(string mulSelPicValue: (String.valueOf(tpaReqObj.get(reqLocFieldRef))).split(';')) {
                            mulSelPicTranslation += getEqualTranslation((supportedLanguageFieldMap.get(langToBeRecordUpdated)+'~TPA_Request__c~Picklist~'+reqLocFieldRef), mulSelPicValue.trim()) + ';';
                        }
                    }
                    tpaReqLocObj.put(reqLocFieldRef, mulSelPicTranslation);
                }
                else if(MultiSelectPicklistsCommaSeprated != null && MultiSelectPicklistsCommaSeprated.containsIgnoreCase(reqLocFieldRef+'=')) {
                    string fieldToRefer = '';
                    for(string plComma: MultiSelectPicklistsCommaSeprated.split(';')) {
                        if(plComma.split('=')[0] == reqLocFieldRef) {
                            fieldToRefer = plComma.split('=')[1];
                        }
                    }

                    string mulSelPicTranslation = '';

                    if(tpaReqObj.get(reqLocFieldRef) != null && (string)tpaReqObj.get(reqLocFieldRef)  != '') {
                        for(string mulSelPicValue: (String.valueOf(tpaReqObj.get(reqLocFieldRef))).split(',')) {
                           mulSelPicTranslation += getEqualTranslation((supportedLanguageFieldMap.get(langToBeRecordUpdated)+'~TPA_Request__c~Picklist~'+fieldToRefer), mulSelPicValue.trim()) + ', ';
                        }
                    }
                    tpaReqLocObj.put(reqLocFieldRef, mulSelPicTranslation.removeEnd(','));
                }
                else {
                    tpaReqLocObj.put(reqLocFieldRef, getEqualTranslation((supportedLanguageFieldMap.get(langToBeRecordUpdated)+'~TPA_Request__c~Picklist~'+reqLocFieldRef), String.valueOf(tpaReqObj.get(reqLocFieldRef))));
                }
            }
        }
        
        upsert tpaReqLoclist; //TODO: insert logs
    }

    /*
    * @param: Language type we are going to provide the translation for
    * @return: Collection of TPA_Language_Cross_Walk__c type records
    */
    public static Map<String, List<TPA_Language_Cross_Walk__c>> getTranslatedValueMap(Set<String> langSet) {
        if(translationMap != null && !translationMap.isEmpty()) {
            return translationMap;
        }
        translationMap = new Map<String, List<TPA_Language_Cross_Walk__c>>();
        string soql = 'SELECT Id, Object_Type__c, Control_Type__c, Field_Type__c, Default_Value__c, Rank__c ';
        for(string lang: langSet)
            soql +=  ', ' + lang;
        soql += ' FROM TPA_Language_Cross_Walk__c WHERE IsDeleted__c = false';
        
        List<TPA_Language_Cross_Walk__c> translatedValueList = Database.query(soql);
        
        String mlKey = '';
        for(TPA_Language_Cross_Walk__c tlc : translatedValueList) {
            // We are segregating records based on the Control_Type__c and maintaing different key accordingly.
            // For 'Record' Control_Type__c, key -> Language__c + Object_Type__c + Control_Type__c + Default_Value__c
            // Other Control_Type__c, key -> Language__c + Object_Type__c + Control_Type__c + Field_Type__c
            for(string lang: langSet) {
                mlKey = '';
                if(tlc.control_type__c == 'Record') {
                    mlKey = lang +'~'+ tlc.Object_Type__c +'~'+ tlc.control_type__c +'~'+ tlc.default_value__c;
                } else {
                    mlKey = lang +'~'+ tlc.Object_Type__c +'~'+ tlc.control_type__c +'~'+ tlc.field_type__c;
                }
                if(!translationMap.containsKey(mlKey)) {
                    translationMap.put(mlKey, new List<TPA_Language_Cross_Walk__c>());
                }
                translationMap.get(mlKey).add(tlc);
            }
        }
        system.debug('####translationMap: '+translationMap);
        return translationMap;
    }

    public static string getEqualTranslation(string key, string default_value) {
        string translatedValue = '';
        for(string keyObj: langCrossWalkMap.keyset()) {
            if(keyObj.containsIgnoreCase(key)) {
                key = keyObj;
                break;
            }
        }
        if(langCrossWalkMap.get(key) == null) {
            translatedValue = default_value;
        }
        else {
            for(TPA_Language_Cross_Walk__c lanCwObj: langCrossWalkMap.get(key)) {
                if(lanCwObj.Default_Value__c == default_value) {
                    translatedValue = String.valueOf(lanCwObj.get(key.split('~')[0]));
                }
            }
        }
        return translatedValue;
    }

    public static List<TPA_Request_Localized__c> getRequestChildLocalizedRecords(string tpaRequestId) {
        List<TPA_Request_Localized__c> tpaReqLoclist = SRV_TPA_TPARequest.getLocalizedRequests(tpaRequestId);
        if(tpaReqObj == null && SRV_TPA_TPARequest.tpaRequest != null){
            tpaReqObj = SRV_TPA_TPARequest.tpaRequest;
        }
        else if(tpaReqObj == null){
            tpaReqObj = SRV_TPA_TPARequest.getRequestInfo(tpaRequestId);
        }
        system.debug('rHere1:::'+tpaReqLoclist);
        if(tpaReqLoclist == null || tpaReqLocList.size() == 0) {
            if(tpaReqLocList == null) {
                tpaReqLoclist = new List<TPA_Request_Localized__c>();
            }
            if(tpaReqObj.Client_Language__c != null && tpaReqObj.Vendor_Language__c == null) {
                tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'client', TPA_Request__c = tpaRequestId, Language__c = tpaReqObj.Client_Language__c));
                system.debug('in ML Utility : tpaReqLoclist ' + tpaReqLoclist);
            }
            else if(tpaReqObj.Vendor_Language__c != null && tpaReqObj.Client_Language__c != null && tpaReqObj.Client_Language__c != tpaReqObj.Vendor_Language__c) {
                tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'client', TPA_Request__c = tpaRequestId, Language__c = tpaReqObj.Client_Language__c));
                tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'vendor', TPA_Request__c = tpaRequestId, Language__c = tpaReqObj.Vendor_Language__c));
            }
            else if(tpaReqObj.Vendor_Language__c != null && tpaReqObj.Client_Language__c != null && tpaReqObj.Client_Language__c == tpaReqObj.Vendor_Language__c) {
                tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'client-vendor', TPA_Request__c = tpaRequestId, Language__c = tpaReqObj.Client_Language__c));
            }
            else if(tpaReqObj.Vendor_Language__c != null && tpaReqObj.Client_Language__c == null) {
                tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'vendor', TPA_Request__c = tpaRequestId, Language__c = tpaReqObj.Vendor_Language__c));
            }
        }
        else if(tpaReqLocList.size() > 0) {
            system.debug('rHere1.001:::');
            if(tpaReqObj.Client_Language__c != null && tpaReqObj.Vendor_Language__c != null && tpaReqObj.Client_Language__c != tpaReqObj.Vendor_Language__c) {
                system.debug('rHere1.011:::'+tpaReqLocList.size());
                tpaReqLocList[0].Record_Localized_For__c = 'client';
                tpaReqLocList[0].Language__c = tpaReqObj.Client_Language__c;
                if(tpaReqLocList.size() == 1)
                    tpaReqLocList.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'vendor', TPA_Request__c = tpaRequestId, Language__c = tpaReqObj.Vendor_Language__c));
            }
            else if(tpaReqObj.Vendor_Language__c != null && tpaReqObj.Client_Language__c != null && tpaReqObj.Client_Language__c == tpaReqObj.Vendor_Language__c) {
                system.debug('rHere1.012:::'+tpaReqLocList.size());
                tpaReqLocList[0].Record_Localized_For__c = 'client-vendor';
                tpaReqLocList[0].Language__c = tpaReqObj.Client_Language__c;
                if(tpaReqLocList.size() == 2 && tpaReqLocList[1] != null) {
                    delete tpaReqLocList[1];
                    tpaReqLocList.remove(1);
                }
            }
            else if(tpaReqObj.Client_Language__c != null && tpaReqObj.Vendor_Language__c == null) {
                system.debug('rHere1.013:::'+tpaReqLocList.size());
                tpaReqLocList[0].Record_Localized_For__c = 'client';
                tpaReqLocList[0].Language__c = tpaReqObj.Client_Language__c;
                if(tpaReqLocList.size() == 2 && tpaReqLocList[1] != null) {
                    delete tpaReqLocList[1];
                    tpaReqLocList.remove(1);
                }
            }
            else if(tpaReqObj.Vendor_Language__c != null && tpaReqObj.Client_Language__c == null) {
                tpaReqLocList[0].Record_Localized_For__c = 'vendor';
                tpaReqLocList[0].Language__c = tpaReqObj.Vendor_Language__c;
                if(tpaReqLocList.size() == 2 && tpaReqLocList[1] != null) {
                    delete tpaReqLocList[1];
                    tpaReqLocList.remove(1);
                }
            }
        }
        return tpaReqLoclist;
    }

    public static string firstLetterCapital(string valToTransform) {
        string convertedString = '';
        for(String x : valToTransform.split('_')) {
            if(x != '' && x != 'c')
                convertedString += x.substring(0,1).toUpperCase()+x.substring(1,x.length()) + '_';
        }
        convertedString += '_c';
        return convertedString;
    }

    /**
    * @author: Vikram Singh Fartyal
    * @description: This method is used by the constructor to get the current language of a user. This value is stored in the cookie.
    * @return: returns the language code to be used in document.
    * */
    public static String getLanguage() {
        // Updated by Vikram Singh under ER-3272
        String languageCode = 'en_US';
        if(CurrentUser.Contact != null && CurrentUser.Contact.TPA_Last_Selected_Language__c != null){
            languageCode = supportedLanguageCodeMap.get(CurrentUser.Contact.TPA_Last_Selected_Language__c);
            system.debug('####UTL_TPA_Multilingual lastSelectedLanguageCode: '+languageCode);
        }
        /*else {
            Cookie lang = ApexPages.currentPage().getCookies().get('lang');
            if(lang != null) {
                languageCode = lang.getValue();
            }
        }*/
        return languageCode;
    }

    /**
    * @author: Vikram Singh Fartyal
    * @params: requestId, requestBy
    * @description: This method is used request edit capability where on editing/cloning/renewing any existing request, request will open in its earlier saved language for both the client and vendor..
    * @return: returns the language code to be used in document.
    * */
    public static String getLanguageForExistingRequests(String requestId, String requestBy) {
        string requestLang = 'en_US';
        if(tpaReqObj == null) {
            tpaReqObj = SRV_TPA_TPARequest.getRequestInfo(requestId);
        }
        if(requestBy != null && requestBy == 'c') {
            requestLang = supportedLanguageCodeMap.get(tpaReqObj.Client_Language__c == null ? 'English' : tpaReqObj.Client_Language__c);
        } else if(requestBy != null && requestBy == 'v') {
            requestLang = supportedLanguageCodeMap.get(tpaReqObj.Vendor_Language__c == null ? 'English' : tpaReqObj.Vendor_Language__c);
        }
        system.debug('####language saved: '+requestLang);
        return requestLang;
    }


    /*
    * @description: This method is used to save use and offerings tarnslated names on their local/Transactional cpoies.
    */
    public static void saveUseOfferingTranslatedNames(string tpaRequestId, String langFieldName, Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap) {
        system.debug('Inside saveUseOfferingTranslatedNames');
        CNT_TPA_RequestSubmissionForm.getLimitsMessage();

        String offering_Category_Translation = (String)multilanguageUtilityMap.get(langFieldName + '~IMS_TPA_Purpose__c~Record~Offering Category')[0].get(langFieldName);
        String data_offering_translation = (String)multilanguageUtilityMap.get(langFieldName + '~IMS_TPA_Purpose__c~Record~Data Offerings')[0].get(langFieldName);
        String none_Translation = (String)multilanguageUtilityMap.get(langFieldName + '~TPA_Request__c~Record~--None--')[0].get(langFieldName);

        List<TPA_Language_Cross_Walk__c> geoLevelTranslationList = new List<TPA_Language_Cross_Walk__c>();
        geoLevelTranslationList = multilanguageUtilityMap.get(langFieldName + '~IMS_Data_Asset__c~Picklist~Geo_Level__c'); 
        
        Map<String, String> geoLevelTranslationMap = new Map<String, String>();
        for(TPA_Language_Cross_Walk__c crosWalkObj : geoLevelTranslationList) {
            geoLevelTranslationMap.put(crosWalkObj.Default_Value__c, (String)crosWalkObj.get(langFieldName));
        }

        //List<TPA_Purpose__c> tpaPurposeList = SRV_TPA_TPARequest.getPurposeAndDescriptionList(tpaRequestId);
        List<TPA_Purpose__c> tpaPurposeList = SRV_TPA_TPARequest.getPurposesList(tpaRequestId);
        Set<Id> purposeIds = new Set<Id>();
        Set<Id> masterPurposeIds = new Set<Id>();
        if(tpaPurposeList != null && tpaPurposeList.size() > 0 ) {
            for(TPA_Purpose__c tpaPurpose : tpaPurposeList) {
                purposeIds.add(tpaPurpose.Id);
                masterPurposeIds.add(tpaPurpose.Purpose__r.Id);
                tpaPurpose.Translated_Purpose_Name__c = (String)tpaPurpose.purpose__r.get(langFieldName);
            }
            SRV_TPA_TPARequest.allPurposeIds = masterPurposeIds;
            SRV_TPA_TPARequest.transactionalPurposeIds = purposeIds;
            
            // Map<Id,List<TPA_Data_Asset__c>> purposeIdDataAssetMap = SRV_TPA_TPARequest.getPurposeIdDataAssetMap( purposeIds);
          
            Map<Id,List<TPA_Data_Asset__c>> purposeIdDataAssetMap = new Map<Id,List<TPA_Data_Asset__c>>();
            for( TPA_Data_Asset__c dataAsset : [Select id,
                                                Asset_Name__c,
                                                Primary_Asset_Geo_Level__c,
                                                APLD_Delivery_Date__c,
                                                APLD_Study_Name__c,
                                                RWE_Delivery_Date__c,
                                                RWE_Study_Name__c,
                                                STI_Data_Report_Name__c,
                                                Nostradata_Source_of_Business_LRx__c,
                                                Longitudanal_Patient_Diagonsis__c,
                                                CH_Other_Outlet_Profits__c,
                                                CH_Hospital_Profits__c,
                                                CH_Combined_Hos_and_Ret_Profit_AU__c,
                                                Health_Plan_Claims_Data__c,
                                                LAAD_Longitudinal_Access_and_Adj_data__c,
                                                Patient_Reference_File__c,
                                                Payer_Companion_File__c,
                                                Provider_Companion_File__c,
                                                CWH_NZ_Scan_data__c,
                                                CH_Retail_Profits__c,
                                                Consumer_Profile_Delivery_Date__c,
                                                Consumer_Profile_Study_Name__c,
                                                Promotional_ROI_Delivery_Date__c,
                                                Promotional_ROI_Study_Name__c,
                                                Other_Data_Asset_Details__c,
                                                Other_Text__c,
                                                Data_Asset__r.English_Translation__c,
                                                Data_Asset__r.Japanese_Translation__c,
                                                Purpose__c,
                                                Purpose__r.Id,
                                                Asset_NametText__c,
                                                Customized_Data_Text__c,

                                                (select id,
                                                Secondary_Asset_Name__c,
                                                IMS_Secondary_Data_Asset__r.English_Translation__c,
                                                IMS_Secondary_Data_Asset__r.Japanese_Translation__c,
                                                BrandImpact_Delivery_Date__c,
                                                BrandImpact_Study_Name__c,
                                                Channel_Dynamics_Delivery_Date__c,
                                                Channel_Dynamics_Study_Name__c,
                                                Pro_Voice_Delivery_Date__c,
                                                Pro_Voice_Study_Name__c,
                                                Outliner_Label_Code__c,
                                                Outliner_Data_Period_Text__c,
                                                Nostradata_Source_of_Business_LRx__c,
                                                Combined_Hos_and_Ret_Profit_AU__c,
                                                AU_Profits__c,
                                                AU_Other_Outlet_Data_Profits__c,
                                                AU_DDD_Hospital_Profits__c,
                                                Nostradata_LRx_Volume__c,
                                                Pharmacy_Scan__c,
                                                STI_Data_Custom_Report_Name__c 
                                                from TPA_Secondary_Data_Assets__r)
                                                From TPA_Data_Asset__c t 
                                                where Purpose__c IN : purposeIds] ) {
                List<TPA_Data_Asset__c> tempList = new List<TPA_Data_Asset__c>();
                if( purposeIdDataAssetMap.containskey( dataAsset.Purpose__c) ) {
                    tempList = purposeIdDataAssetMap.get( dataAsset.Purpose__r.Id);                               
                }
                tempList.add( dataAsset );
                purposeIdDataAssetMap.put( dataAsset.Purpose__c, tempList); 
            }

            Map<String, String> priAssetFieldMap = new Map<String, String>();
            for(string priAssetField : Label.TPA_Primary_Asset_Field_Map.split(',')){
                priAssetFieldMap.put(priAssetField.split('~')[0], priAssetField.split('~')[1]);
            }
            Map<String, String> secAssetFieldMap = new Map<String, String>();
            for(string secAssetField : Label.TPA_Sec_Asset_Field_Map.split(',')) {
                secAssetFieldMap.put(secAssetField.split('~')[0], secAssetField.split('~')[1]);
            }

            for(TPA_Purpose__c tpaPurpose : tpaPurposeList) {
                // tpaPurpose.Restricted_Offerings__c = '';//will review if still applicable
                // tpaPurpose.Restricted_Offerings_Localized__c = '';//will review if still applicable

                String allOfferings = '';
                String allOfferingsLocalized = '';
                Map<String, String> geoLevelDAMap = new Map<String, String>();
                Map<String, String> geoLevelLocalDAMap = new Map<String, String>();
                
                for(TPA_Data_Asset__c tpaDataAsset : purposeIdDataAssetMap.get( tpaPurpose.Id )){
                    String geoLevel = '';
                    String geoLevelLocalized = '';
                    if(geoLevelDAMap.containskey(tpaDataAsset.Primary_Asset_Geo_Level__c)){ 
                        geoLevel = geoLevelDAMap.get(tpaDataAsset.Primary_Asset_Geo_Level__c);
                        geoLevelLocalized = geoLevelLocalDAMap.get(tpaDataAsset.Primary_Asset_Geo_Level__c);
                    }else{	
                        geoLevel = '\nCategory of Offering: '+tpaDataAsset.Primary_Asset_Geo_Level__c + '\n';
                        geoLevel += 'IQVIA Data Offering(s): \n';
                        geoLevelLocalized = '\n' + offering_Category_Translation + ': ' + geoLevelTranslationMap.get(tpaDataAsset.Primary_Asset_Geo_Level__c) + '\n';
                        geoLevelLocalized += data_offering_translation + ': \n'; 
                    }
                    if(tpaDataAsset.TPA_Secondary_Data_Assets__r.size() > 0) {
                        for(TPA_Secondary_Data_Asset__c secDataAsset : tpaDataAsset.TPA_Secondary_Data_Assets__r) {
                            String deliveryDate = '';
                            List<String> lstSplit = new List<String>();
                            String dataStudyNameAndDate = '';

                            String secAssetName = secDataAsset.Secondary_Asset_Name__c;
                            String secAssetNameLocalized = (String)secDataAsset.IMS_Secondary_Data_Asset__r.get(langFieldName) == null ? secDataAsset.Secondary_Asset_Name__c : (String)secDataAsset.IMS_Secondary_Data_Asset__r.get(langFieldName);
                                                        
                            if(Label.BrandImpact_Study_Name == secAssetName) {
                                if(secDataAsset.BrandImpact_Delivery_Date__c != null) {
                                    lstSplit = String.valueOf(secDataAsset.BrandImpact_Delivery_Date__c ).split('-');
                                }
                                if(lstSplit != null && lstSplit.size() > 1) {
                                    deliveryDate = lstSplit[1]+'/'+lstSplit[2]+'/'+lstSplit[0];
                                }
                                dataStudyNameAndDate = ' ' + secDataAsset.BrandImpact_Study_Name__c + ' - ' + deliveryDate;
                            }
                            else if(Label.Channel_Dynamics_Study_Name_and_Date == secAssetName) {
                                if(secDataAsset.Channel_Dynamics_Delivery_Date__c != null) {
                                    lstSplit = String.valueOf(secDataAsset.Channel_Dynamics_Delivery_Date__c).split('-');
                                }
                                if(lstSplit != null && lstSplit.size() > 1) {
                                    deliveryDate = lstSplit[1]+'/'+lstSplit[2]+'/'+lstSplit[0];
                                }
                                dataStudyNameAndDate = ' ' + secDataAsset.Channel_Dynamics_Study_Name__c + ' - ' + deliveryDate;
                            }
                            else if(Label.Pro_Voice_Study_Name_and_Date == secAssetName) {
                                if(secDataAsset.Pro_Voice_Delivery_Date__c != null) {
                                    lstSplit = String.valueOf(secDataAsset.Pro_Voice_Delivery_Date__c).split('-');
                                }
                                if(lstSplit != null && lstSplit.size() > 1) {
                                    deliveryDate = lstSplit[1]+'/'+lstSplit[2]+'/'+lstSplit[0];
                                }
                                dataStudyNameAndDate = ' ' + secDataAsset.Pro_Voice_Study_Name__c + ' - ' + deliveryDate;
                            }
                            else if(Label.TPA_OutlierView == secAssetName) {
                                dataStudyNameAndDate = ' ' + secDataAsset.Outliner_Label_Code__c + ' - ' + secDataAsset.Outliner_Data_Period_Text__c;
                            }
                            else if(secAssetFieldMap != null && secAssetFieldMap.size() > 0 && secAssetFieldMap.keySet().contains(secAssetName)) {
                                String fieldName = secAssetFieldMap.get(secAssetName);
                                if(secDataAsset.get(fieldName) != null) {
                                    dataStudyNameAndDate = ': ' + secDataAsset.get(fieldName);
                                }
                            }
                            else if(Label.STI_Data_Custom_Report_Name == secAssetName) {
                                dataStudyNameAndDate = secDataAsset.STI_Data_Custom_Report_Name__c;
                            }
                            if(Label.TPA_OutlierView == secAssetName) {
                                secAssetName = Label.TPA_OutlierView_Data_Asset_Name ;
                            }
                            if(Label.TPA_OutlierView == secAssetNameLocalized) {
                                secAssetNameLocalized = Label.TPA_OutlierView_Data_Asset_Name ;
                            }
                          

                            String dataStudyNameAndDateAPLD = '';
                            String dataStudyNameAndDateAPLDLocalized = '';
                            if(Label.TPA_APLD_Offering_Name == tpaDataAsset.Asset_Name__c && geoLevel.indexOf(Label.TPA_APLD_Offering_Name) == -1) {
                                String deliveryDateAPLD = '';
                                List<String> lstSplitAPLD = new List<String>();
                                String dataAssetName = tpaDataAsset.Asset_Name__c;
                                String dataAssetNameLocalized = (String)tpaDataAsset.Data_Asset__r.get(langFieldName) == null ? tpaDataAsset.Asset_Name__c : (String)tpaDataAsset.Data_Asset__r.get(langFieldName);

                                if(tpaDataAsset.APLD_Delivery_Date__c != null) {
                                    lstSplitAPLD = String.valueOf(tpaDataAsset.APLD_Delivery_Date__c).split('-');
                                }
                                if(lstSplitAPLD != null && lstSplitAPLD.size() > 1) {
                                    deliveryDateAPLD = lstSplitAPLD[1]+'/'+lstSplitAPLD[2]+'/'+lstSplitAPLD[0];
                                }

                                dataStudyNameAndDateAPLD = dataAssetName + ' ' + tpaDataAsset.APLD_Study_Name__c + ' - ' + deliveryDateAPLD + ' - ';
                                dataStudyNameAndDateAPLDLocalized = dataAssetNameLocalized + ' ' + tpaDataAsset.APLD_Study_Name__c + ' - ' + deliveryDateAPLD + ' - ';
                            }
                            
                            if(dataStudyNameAndDate != null && dataStudyNameAndDate != '') {
                                geoLevel +=  secAssetName + dataStudyNameAndDate + ', ';
                                geoLevelLocalized +=  secAssetNameLocalized + dataStudyNameAndDate + ', ';
                            }
                            else {
                                geoLevel += dataStudyNameAndDateAPLD + secAssetName + dataStudyNameAndDate + ', ';
                                geoLevelLocalized += dataStudyNameAndDateAPLDLocalized + secAssetNameLocalized + dataStudyNameAndDate + ', ';
                            }
                        }
                    }
                    else {
                        String dataAssetName = tpaDataAsset.Asset_Name__c;
                        String dataAssetNameLocalized = (String)tpaDataAsset.Data_Asset__r.get(langFieldName) == null ? tpaDataAsset.Asset_Name__c : (String)tpaDataAsset.Data_Asset__r.get(langFieldName);

                        String deliveryDate = '';
                        List<String> lstSplit = new List<String>();
                        String dataStudyNameAndDate = '';
                        
                        if(Label.TPA_RWE_Name == dataAssetName) {
                            if(tpaDataAsset.RWE_Delivery_Date__c != null) {
                                lstSplit = String.valueOf(tpaDataAsset.RWE_Delivery_Date__c).split('-');
                            }
                            if(lstSplit != null && lstSplit.size() > 1) {
                                deliveryDate = lstSplit[1]+'/'+lstSplit[2]+'/'+lstSplit[0];
                            }
                            dataStudyNameAndDate = ' ' + tpaDataAsset.RWE_Study_Name__c + ' - ' + deliveryDate;
                        }
                        else if(dataAssetName.indexOf(Label.TPA_STI_Data_Offering_Name) != -1) {
                            dataStudyNameAndDate = ' ' + tpaDataAsset.STI_Data_Report_Name__c;
                        }
                        else if(priAssetFieldMap != null && priAssetFieldMap.size() > 0 && priAssetFieldMap.keySet().contains(dataAssetName)) {
                            String fieldName = priAssetFieldMap.get(dataAssetName);
                            if(tpaDataAsset.get(fieldName) != null) {
                                dataStudyNameAndDate = ': ' + tpaDataAsset.get(fieldName);
                            }
                        }
                        else if(Label.TPA_Consumer_Profile == tpaDataAsset.Asset_Name__c) {
                            if(tpaDataAsset.Consumer_Profile_Delivery_Date__c != null) {
                                lstSplit = String.valueOf(tpaDataAsset.Consumer_Profile_Delivery_Date__c).split('-');
                            }
                            if(lstSplit != null && lstSplit.size() > 1) {
                                deliveryDate = lstSplit[1]+'/'+lstSplit[2]+'/'+lstSplit[0];
                            }
                            dataStudyNameAndDate = ' ' + tpaDataAsset.Consumer_Profile_Study_Name__c + ' - ' + deliveryDate;
                        }
                        else if(Label.TPA_ROI == tpaDataAsset.Asset_Name__c) {
                            if(tpaDataAsset.Promotional_ROI_Delivery_Date__c != null) {
                                lstSplit = String.valueOf(tpaDataAsset.Promotional_ROI_Delivery_Date__c).split('-');
                            }
                            if(lstSplit != null && lstSplit.size() > 1) {
                                deliveryDate = lstSplit[1]+'/'+lstSplit[2]+'/'+lstSplit[0];
                            }
                            dataStudyNameAndDate = ' ' + tpaDataAsset.Promotional_ROI_Study_Name__c + ' - ' + deliveryDate;
                        }
                        else if(tpaDataAsset.Asset_Name__c == 'Customized IQVIA Data - Specify name of Customized Data will be shared:') {
                            dataStudyNameAndDate = ' ' + tpaDataAsset.Customized_Data_Text__c;
                        }
                        if(tpaDataAsset.Asset_NametText__c == 'Other') {
                            if(tpaDataAsset.Other_Data_Asset_Details__c != null) {
                                geoLevel += 'Other: ' + tpaDataAsset.Other_Data_Asset_Details__c + ', ';
                                geoLevelLocalized += 'Other: ' + tpaDataAsset.Other_Data_Asset_Details__c + ', ';
                            }
                            else {
                                geoLevel += 'Other: ' + tpaDataAsset.Other_Text__c + ', ';
                                geoLevelLocalized += 'Other: ' + tpaDataAsset.Other_Text__c + ', ';
                            }
                        }
                        else {
                            geoLevel += dataAssetName + dataStudyNameAndDate + ', ';
                            geoLevelLocalized += dataAssetNameLocalized + dataStudyNameAndDate + ', ';
                        }
                        
                        
                    }
                    geoLevelLocalDAMap.put(tpaDataAsset.Primary_Asset_Geo_Level__c, geoLevelLocalized);
                    geoLevelDAMap.put(tpaDataAsset.Primary_Asset_Geo_Level__c,geoLevel);
                }
                
                if(!geoLevelDAMap.isEmpty()){
                    for(String geoLevel : geoLevelDAMap.keySet()){
                        if(allOfferings == ''){
                            allOfferings = geoLevelDAMap.get(geoLevel);
                            allOfferings = allOfferings.substring(0,allOfferings.length()-2);
                        }else{
                            allOfferings += '\n' + geoLevelDAMap.get(geoLevel);
                            allOfferings = allOfferings.substring(0,allOfferings.length()-2);
                        }
                    }
                }
                if(!geoLevelLocalDAMap.isEmpty()){
                    for(String geoLevelLocal : geoLevelLocalDAMap.keySet()){
                        if(allOfferingsLocalized == ''){
                            allOfferingsLocalized = geoLevelLocalDAMap.get(geoLevelLocal);
                            allOfferingsLocalized = allOfferingsLocalized.substring(0,allOfferingsLocalized.length()-2);
                        }else{
                            allOfferingsLocalized += '\n' + geoLevelLocalDAMap.get(geoLevelLocal);
                            allOfferingsLocalized = allOfferingsLocalized.substring(0,allOfferingsLocalized.length()-2);
                        }

                       
                    }
                }
              
                if(allOfferings != '') {
                    tpaPurpose.All_Data_Assets__c = allOfferings;
                    tpaPurpose.All_Data_Assets_Localized__c = allOfferingsLocalized;
                }
            }
            try {
                upsert tpaPurposeList;
            }
            catch(Exception ex) {
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::UTL_TPA_Multilingual.saveUseOfferingTranslatedNames:::Upsert Failed', tpaRequestId != null ? tpaRequestId : '');
                System.debug('Uses Translated Names Upsert Failed : '+ex.getMessage());
                //will review, put tpa logs here
            }
        }
    }

    //Added by Vikram Singh under ER-3186 Start
    /**
    * @param: Code_Type__c, Name we expecting Country_Possible_Codes__c for
    * @return: Collection of Country_Possible_Codes__c
    * */
    public static List<TPA_Country_Codes__c> lstCountryStatesCodes;
    public static Set<String> getCountryStateCodeSet(String CoS, String CoSName) {
        List<TPA_Country_Codes__c> lstCountryStatesCodes = new List<TPA_Country_Codes__c>();
        lstCountryStatesCodes = [select name, Country_Possible_Codes__c, Code_Type__c from TPA_Country_Codes__c];
        Set<String> countryStateCode =  new Set<String>();
        for(TPA_Country_Codes__c cc : lstCountryStatesCodes){
            if(cc.Code_Type__c == CoS && cc.Name == CoSName){
                countryStateCode.addAll(cc.Country_Possible_Codes__c.toLowerCase().split(';'));
            }
        }
        return countryStateCode;
    }
    //Added by Vikram Singh under ER-3186 End

    public static List<TPA_Country_Codes__c> lstCountryStatesCodesWithName;
    public static Set<String> getCountryStateCodeSetWithName(String CoS, String CoSName) {
        if(lstCountryStatesCodesWithName == null || lstCountryStatesCodesWithName.size() == 0) {
            lstCountryStatesCodesWithName = [select name, Country_Possible_Codes__c, Code_Type__c from TPA_Country_Codes__c];
        }
        Set<String> countryStateCode =  new Set<String>();
        List<String> countStatCodeTemp;
        for(TPA_Country_Codes__c cc : lstCountryStatesCodesWithName){
            if(cc.Country_Possible_Codes__c != null) {
                countStatCodeTemp = cc.Country_Possible_Codes__c.toLowerCase().split(';');
            }
            if(cc.Code_Type__c == CoS && (cc.Name == CoSName || (countStatCodeTemp != null && countStatCodeTemp.contains(CoSName.toLowerCase())))){
                countryStateCode.addAll(countStatCodeTemp);
            }
        }
        return countryStateCode;
    }

    public static Map<String, String> mapCountryStatesCodes {
        get {
            if(mapCountryStatesCodes == null) {
                mapCountryStatesCodes = loadCountryStateCodeMap();
            }
            return mapCountryStatesCodes;
        }
        set;
    }

    /**
    * @param: Code_Type__c, Name we expecting Country_Possible_Codes__c Map for
    * @return: Map of Country_Possible_Codes__c
    * */
    //public static Map<String, String> mapCountryStatesCodes;
    public static Map<String, String> loadCountryStateCodeMap() {
        Map<String, String> mapCountStCodes = new Map<String, String>();
        List<TPA_Country_Codes__c> lstCountStaCode = [select Name, Country_Possible_Codes__c, Code_Type__c from TPA_Country_Codes__c];
        for(TPA_Country_Codes__c recCountryCode: lstCountStaCode) {
            mapCountStCodes.put(recCountryCode.Name+'~'+recCountryCode.Code_Type__c, recCountryCode.Name);
            if(recCountryCode.Country_Possible_Codes__c != null && recCountryCode.Country_Possible_Codes__c.length() > 0) {
                for(String strCodes: recCountryCode.Country_Possible_Codes__c.split(';')) {
                    mapCountStCodes.put(strCodes+'~'+recCountryCode.Code_Type__c, recCountryCode.Name);
                }
            }
        }
        return mapCountStCodes;
    }

    //Added by Rajendra under ER-11762 -- Start
    public static boolean isValidEmailId(String emailId) {
        if(UTL_Validate.isEmptyOrNull(emailId)) {
            return false;
        }
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9!#$%&\\\'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&\\\'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$';
        //'^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(emailId);

        if (!emailMatcher.matches()) {
            res = false;
        }
        return res;
    }

    public static boolean isValidRecordId(String recordId) {
        if(UTL_Validate.isEmptyOrNull(recordId)) {
            return false;
        }
        return recordId InstanceOf Id;
    }

    public static List<String> ccList(String emailIds, List<String> ccList) {
        if(emailIds != null && emailIds != '' ) {
            if(ccList == null){
                ccList = new List<String>();
            }
            for(String email: emailIds.split(';')) {
                if(UTL_TPA_Multilingual.isValidEmailId(email)){
                    ccList.add(email);
                }
            }
        }
        return ccList;
    }
    //Added by Rajendra under ER-11762 -- End
    
    public static List<String> addAdditionalClientContactInccList(List<TPA_Contact__c> tpaContactsList, List<String> ccList){

        if(tpaContactsList != null && tpaContactsList.size() > 0 ){
            for(TPA_Contact__c tpaContact : tpaContactsList)
            {
              if(tpaContact.Type__c == 'Additional Client Contact' || tpaContact.Type__c == 'Additional Contact' )
              {
                ccList.add(tpaContact.Email__c);
              }
            }
          }

        if(ccList.size() > 0){
            return ccList;
        }
        return null;
    }
}
