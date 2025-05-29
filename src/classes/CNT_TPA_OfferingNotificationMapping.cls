public with sharing class CNT_TPA_OfferingNotificationMapping {
    public TPA_Offering_Notification_Mapping__c TPAOffNotificationMappingtoUpdate { get; private set; }
    public String editCloneUseOffLabels {get;set;}
    public String addendumAndOffNotificationValues {get;set;}
    public String idToUpdate {get;set;}
    public String idToClone {get;set;}
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    Public String NameOfOffMaping;
    public List<SelectOption> paginationSizeOptions{get;set;}
    public String query = 'SELECT Id,Name,IsActive__c,Country__c,Offering_Country_Name__c, IMS_Primary_Data_Asset__r.Asset_Name__c,Primary_Data_Asset_Name__c, IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c,Secondary_Data_Asset_Name__c,IMS_TPA_Purpose__r.Primary_Purpose_Name__c,Purpose_Name__c,Offering_Notifications__r.Page_Name__c,TLLA_Additional_Terms__r.Page_Name__c,Process_Execution_Mode__c,LastModifiedBy.name,lastmodifieddate, Vendor_Accounts_Name__c,OneKey_Countries__c,Is_Applicable_for_All_OneKey_Countries__c FROM TPA_Offering_Notification_Mapping__c WHERE ((LastModifiedDate  >= LAST_N_MONTHS:3 AND IsActive__c = false) OR IsActive__c = true) '; 
    public String errorText {get; set;}
    public Boolean isError {get; set;}
    public list<TPA_Offering_Notification_Mapping__c> lstofAllTPAOffNotificationMapping;
    public List<List<TPA_Offering_Notification_Mapping__c>> lstofTPAOffNotificationMappingToExport{get;set;}
    public string lookUp{get;set;}
    public String AccountIdPassToHdn {get;set;}
    public String AccountIdMap {get;set;}
    public Map<ID,String> MapOfAccIdWithName {get;set;}
    public List<String> oneKeyCountries {get;set;}
    public String selectedOneKeyCountries {get;set;}
    public String serializedMapOfAccIdWithName {
        get{
            if(serializedMapOfAccIdWithName == null){
                serializedMapOfAccIdWithName = '';
            }
            return serializedMapOfAccIdWithName ;
        }
        set;
    }

    public Static Map<String,String> MapOffNotiIdRcrdWithAddendumRcrdId {get; set;}
    public Static Map<String,String> MapOffNotiAndAddendumIdwithPageName {get; set;}
    public static Map <String,String> getMapOffNotiIdRcrdWithAddendumRcrdId()  {
        if(MapOffNotiIdRcrdWithAddendumRcrdId == null){
            MapOffNotiIdRcrdWithAddendumRcrdId = new Map <String,String>();
            MapOffNotiAndAddendumIdwithPageName = new Map <String,String>();
            Map <String, List<TPA_Text_Editor__C>> mapPageNameWithTextEditorRcrds = new Map <String, List<TPA_Text_Editor__C>>();
            for(TPA_Text_Editor__C obj : [select id,Page_Name__c, Page_Title__c, Page_Type__c 
                from TPA_Text_Editor__C where Page_Type__c in ('TPA Offering Addendum', 'TPA Offering Notifications')]){
                    if(!mapPageNameWithTextEditorRcrds.containsKey(obj.Page_Name__c)) {
                        mapPageNameWithTextEditorRcrds.put(obj.Page_Name__c, new list<TPA_Text_Editor__C>{obj});
                    } else {
                        mapPageNameWithTextEditorRcrds.get(obj.Page_Name__c).add(obj);
                    }
                    if(!MapOffNotiAndAddendumIdwithPageName.containsKey(obj.id)){
                        MapOffNotiAndAddendumIdwithPageName.put(obj.id, obj.Page_Name__c);
                    }
            }
            if(mapPageNameWithTextEditorRcrds != null && mapPageNameWithTextEditorRcrds.size() > 0){
                TPA_Text_Editor__C obj1; TPA_Text_Editor__C obj2;
                for(String pageName : mapPageNameWithTextEditorRcrds.keySet()){
                    if(mapPageNameWithTextEditorRcrds.get(pageName).size() == 2){
                        obj1 = mapPageNameWithTextEditorRcrds.get(pageName)[0];
                        obj2 = mapPageNameWithTextEditorRcrds.get(pageName)[1];
                        if(obj1.Page_Type__c == 'TPA Offering Notifications'){
                            MapOffNotiIdRcrdWithAddendumRcrdId.put(obj1.id, obj2.id);
                        }
                        else if(obj2.Page_Type__c == 'TPA Offering Notifications'){
                            MapOffNotiIdRcrdWithAddendumRcrdId.put(obj2.id, obj1.id);
                        }
                    }
                }
            }
        }
        return MapOffNotiIdRcrdWithAddendumRcrdId;
    }

    public void PopulateAddendumValue(){
        getMapOffNotiIdRcrdWithAddendumRcrdId();
        String OffNotiPageName = MapOffNotiAndAddendumIdwithPageName.get(TPAOffNotificationMappingtoUpdate.Offering_Notifications__c);
        String AddendumPageName = '';
        if(TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c != null){
            AddendumPageName = MapOffNotiAndAddendumIdwithPageName.get(TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c);
        }

        if(TPAOffNotificationMappingtoUpdate == null || TPAOffNotificationMappingtoUpdate.Offering_Notifications__c == null
        || MapOffNotiIdRcrdWithAddendumRcrdId == null || !MapOffNotiIdRcrdWithAddendumRcrdId.containsKey(TPAOffNotificationMappingtoUpdate.Offering_Notifications__c)){
            addendumAndOffNotificationValues = AddendumPageName + ':::' + OffNotiPageName;
            return;
        }
        else {
            TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c= MapOffNotiIdRcrdWithAddendumRcrdId.get(TPAOffNotificationMappingtoUpdate.Offering_Notifications__c);
        }
        addendumAndOffNotificationValues = MapOffNotiAndAddendumIdwithPageName.get(TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c) +':::'+ OffNotiPageName;
    }

    public void setAddendumPageName(){
        getMapOffNotiIdRcrdWithAddendumRcrdId();
        if(TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c != null){
            if(TPAOffNotificationMappingtoUpdate.Offering_Notifications__c != null){
                addendumAndOffNotificationValues = MapOffNotiAndAddendumIdwithPageName.get(TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c) +':::'+ MapOffNotiAndAddendumIdwithPageName.get(TPAOffNotificationMappingtoUpdate.Offering_Notifications__c);
            }
            else{
                addendumAndOffNotificationValues = MapOffNotiAndAddendumIdwithPageName.get(TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c) +':::';
            }
        }
    }

    public Static Map<String,String> MapOffNotiRulewithCountryVendorId {get; set;}
    public static Map <String,String> getMapOffNotiRulewithCountryVendorId()  {
                MapOffNotiRulewithCountryVendorId = new Map <String,String>();
                String key = ''; String oneKeyCountries = ''; String newKey = '';
                String priOffId = '';  String secOffId =  ''; String vendorAccId = ''; String useId = ''; String country = '';
                String OffNotTerms = ''; String AddendumTerms = ''; 
                for(TPA_Offering_Notification_Mapping__c mapObj : [Select id, name, IMS_Primary_Data_Asset__c, IMS_Secondary_Data_Asset__c, 
                        IMS_Secondary_Data_Asset__r.id, IMS_TPA_Purpose__c,IMS_TPA_Purpose__r.id, Process_Execution_Mode__c, Offering_Notifications__c, Offering_Notifications__r.id, 
                        TLLA_Additional_Terms__c, TLLA_Additional_Terms__r.id, OneKey_Countries__c, Country__c,
                        Is_Applicable_for_All_OneKey_Countries__c,IMS_Primary_Data_Asset__r.Asset_Name__c, 
                        (select id, Vendor_Account_Address__c, Vendor_Account_Address__r.id from 
                        TPA_Off_Notification_Account_Mapping__r)
                        from TPA_Offering_Notification_Mapping__c where IsActive__c = True]){
                            key = ''; priOffId = ''; secOffId =  ''; vendorAccId = ''; useId = ''; oneKeyCountries = ''; newKey = '' ;
                            OffNotTerms = ''; AddendumTerms = '';
                            if(mapObj.IMS_Primary_Data_Asset__c != null) {
                                priOffId = mapObj.IMS_Primary_Data_Asset__r.id + '' ;
                            }
                            if(mapObj.IMS_Secondary_Data_Asset__c != null) {
                                secOffId = mapObj.IMS_Secondary_Data_Asset__r.id + '';
                            }
                            if(mapObj.IMS_TPA_Purpose__c != null) {
                                useId = mapObj.IMS_TPA_Purpose__r.id + '';
                            }
                            if(mapObj.Offering_Notifications__c != null) {
                                OffNotTerms = mapObj.Offering_Notifications__r.id + '';
                            }
                            if(mapObj.TLLA_Additional_Terms__c != null) {
                                AddendumTerms = mapObj.TLLA_Additional_Terms__r.id + '';
                            }
                            if(mapObj.TPA_Off_Notification_Account_Mapping__r.size() > 0 ) {
                                for(TPA_Off_Notification_Account_Mapping__c accMapObj : mapObj.TPA_Off_Notification_Account_Mapping__r){
                                    vendorAccId += accMapObj.Vendor_Account_Address__r.id + ';';   
                                }
                                if(vendorAccId.substring(vendorAccId.length()-1,vendorAccId.length()).equals(';')){
                                    vendorAccId = vendorAccId.substring(0,vendorAccId.length()-1);
                                }
                            }
                            else{
                                vendorAccId = 'ALL';
                            }
                            if(mapObj.Is_Applicable_for_All_OneKey_Countries__c){
                                oneKeyCountries = 'ALL'; 
                            }
                            else if(mapObj.IMS_Primary_Data_Asset__c != null && mapObj.IMS_Primary_Data_Asset__r.Asset_Name__c.startsWith('OneKey Data - ')){
                                oneKeyCountries = mapObj.OneKey_Countries__c + ';' + mapObj.Country__c;
                            }
                            else{
                                oneKeyCountries = mapObj.Country__c;
                            }
                            key = priOffId + ';' + secOffId + ';' + useId + ';' + OffNotTerms + ';' + AddendumTerms + ';' + mapObj.Process_Execution_Mode__c;
                            if(MapOffNotiRulewithCountryVendorId.containsKey(key)) {
                                List<String> countryAndVendorVal = MapOffNotiRulewithCountryVendorId.get(key).split('~');
                                if(countryAndVendorVal[0] == 'ALL' || vendorAccId == 'ALL'){
                                    newKey = 'ALL';
                                }
                                else{
                                    newKey = countryAndVendorVal[0] + ';' + vendorAccId;
                                }
                                System.debug('newKey After Vendor:: ' + newKey ); 
                                newKey += '~';
                                if(countryAndVendorVal[1] == 'ALL' || oneKeyCountries == 'ALL'){
                                    newKey += 'ALL';
                                }
                                else{
                                    newKey += countryAndVendorVal[1] + ';' + oneKeyCountries;
                                }
                                newKey += '~';
                                if(countryAndVendorVal[2] != null || countryAndVendorVal[2] != ''){
                                    newKey +=  countryAndVendorVal[2] + ';' + mapObj.id + ':' + mapObj.name;
                                }
                                else{
                                    newKey += mapObj.id;
                                }
                                

                                MapOffNotiRulewithCountryVendorId.put(key, newKey);
                            }
                            else{
                                MapOffNotiRulewithCountryVendorId.put(key, vendorAccId + '~' + oneKeyCountries + '~' + mapObj.id + ':' + mapObj.name);
                            }
                            
                        } 

            for(String str : MapOffNotiRulewithCountryVendorId.keySet()){
                system.debug('Key' + str + 'str-->' + MapOffNotiRulewithCountryVendorId.get(str));
            }
            return MapOffNotiRulewithCountryVendorId;
        
    }

    transient public boolean bool{get;set;}
    transient public List<List<AccountWrapper>> lstAccountWrapper{get;set;}
    public set<id> setOfAccId{get;set;}
    public String searchByName{get;set;}
    public String idToViewAccount {get;set;}
    public String OfferingNotificationObjIdToViewAccount {get;set;}
    LIST<String> selectedAccountIDs;
    List<TPA_Offering_Notification_Mapping__c> OfferingNotificationMapTempList ;
    List<TPA_Off_Notification_Account_Mapping__c> OfferingNotificationAccMapTempList ;

    public String selectedAccountId{get;
                                    set{
                                        selectedAccountId = value;
                                    }
                                   }
    public set<id> setOfselectedAccountId{get;set;}

    public class AccountWrapper {
        public Address__c acc{get;set;}
        public boolean check{get;set;}
        public String billingAddress{get;set;}
        public String accId{get;set;}
        public AccountWrapper(Address__c a, boolean boo)
        { acc = a; check = boo; }
        public AccountWrapper(Address__c a, boolean boo, String address)
        { acc = a; check = boo; billingAddress = address;}
        public AccountWrapper(Address__c a, boolean boo, String address, String id)
        { acc = a; check = boo; billingAddress = address; accId = id; }
    }

    public void add(){
        bool = true;
    }

    public void showSelectedAccounts() {
        ID selectedVendorAccountID = Id.valueOf(Apexpages.currentPage().getParameters().get('selectedVendorAccountID'));
        if(setOfselectedAccountId != null && setOfselectedAccountId.size() > 0 && setOfselectedAccountId.contains(selectedVendorAccountID)){
            setOfselectedAccountId.remove(selectedVendorAccountID);
        }
        else{
            setOfselectedAccountId.add(selectedVendorAccountID);
        }
        system.debug('setOfselectedAccountId'+setOfselectedAccountId);
    }

    public void onSearch(){
        selectedAccountIDs = ( List<String> )JSON.deserialize( Apexpages.currentPage().getParameters().get('selectedVendorAccountIDs'), List<string>.class ) ;
        lstAccountWrapper = new list<List<AccountWrapper>>();
        String byName = '\'%'+String.escapeSingleQuotes(searchByName) + '%\'';
        String billingAddress = '';
        try{
            String query ='SELECT Name,Street__c, City__c, State__c, PostalCode__c, Country__c FROM Address__c WHERE Is_TPA_Account__c = true ';
            if(searchByName !=null && searchByName != ''){
                query +=  'AND name Like '+byName ;
            }
            list<Address__c> filteredAccountList = Database.query(query);
            List<AccountWrapper> tempAccList = new List<AccountWrapper>();
            for(Address__c accountObj:filteredAccountList){
                if(accountObj.Street__c != ''){
                    billingAddress = accountObj.Street__c + ',';
                }
                billingAddress += '<br/>';
                if(accountObj.City__c != ''){
                    billingAddress += accountObj.City__c + ',';
                }
                if(accountObj.State__c != ''){
                    billingAddress += accountObj.State__c + ',';
                }
                if(accountObj.PostalCode__c != ''){
                    billingAddress += accountObj.PostalCode__c + ',';
                }
                billingAddress += '<br/>';
                if(accountObj.Country__c != ''){
                    billingAddress += accountObj.Country__c;
                }
                if(accountObj.Name != null && accountObj.Name != ''){
                    if(selectedAccountIDs != null && selectedAccountIDs.size() >0 && (new Set<String>(selectedAccountIDs)).contains(accountObj.id+'')){
                        tempAccList.add(new AccountWrapper(accountObj, true, billingAddress, accountObj.id));
                    }
                    else{
                        tempAccList.add(new AccountWrapper(accountObj, false, billingAddress, accountObj.id));
                    }

                }
                system.debug('tempAccList'+tempAccList);

                if(tempAccList.size() == 1000){//limit of vf repeat components
                    lstAccountWrapper.add(tempAccList);
                    tempAccList = new List<AccountWrapper>();
                }
            }
            lstAccountWrapper.add(tempAccList);
        }catch(Exception ex){
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Illegal Search parameter!'));
        }
    }


    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'desc'; } return sortDir;  }
        set;
    }
    public String sortField {
        get  { if (sortField == null) {sortField = 'CreatedDate'; } return sortField;  }
        set;
    }



    public CNT_TPA_OfferingNotificationMapping(){
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        isError = false;
        if(TPAOffNotificationMappingtoUpdate == NULL)
        {
            TPAOffNotificationMappingtoUpdate = new TPA_Offering_Notification_Mapping__c();
        }
        MapOfAccIdWithName = new Map <ID, String>();
        bool = false; setOfAccId = new Set<Id>();
        lstAccountWrapper = new list<list<AccountWrapper>>();
        lookUp = '';
        AccountIdPassToHdn = '';
        searchByName ='';
        AccountIdMap = '';
        if(ApexPages.CurrentPage().getParameters().get('AccountIdList') != null && ApexPages.CurrentPage().getParameters().get('AccountIdList') != '')
            AccountIdPassToHdn = String.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('AccountIdList'));
        if(setOfselectedAccountId == NULL){
            setOfselectedAccountId = new Set<Id>();
        }
        selectedAccountIDs = new LIST<String>();

        if(ApexPages.CurrentPage().getParameters().get('OfferingNotificationObjId') != null && ApexPages.CurrentPage().getParameters().get('OfferingNotificationObjId') != '')
            OfferingNotificationObjIdToViewAccount = String.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('OfferingNotificationObjId'));

        String billingAddress = '';

        String Query = 'select id,Street__c, City__c, State__c, PostalCode__c, Country__c, name from Address__c where Is_TPA_Account__c = true ';

        Set<id> selectedAccountId = new Set<id>();
        Set<String> fieldSetTemp = new Set<String>{'TPA_Offering_Notification_Mapping_Rule__c', 'TPA_Offering_Notification_Mapping_Rule__r.id', 'Vendor_Account_Address__r.id'};
        //String filterCondition = 'TPA_Offering_Notification_Mapping_Rule__r.id = \'' + OfferingNotificationObjIdToViewAccount + '\' ';
        if(OfferingNotificationObjIdToViewAccount != null && OfferingNotificationObjIdToViewAccount != ''){
          OfferingNotificationAccMapTempList = SLT_TPAOffNotificationAccountMapping.instance.selectByFilter(fieldSetTemp, 'TPA_Offering_Notification_Mapping_Rule__r.id = \'' + OfferingNotificationObjIdToViewAccount + '\' ');
          for(TPA_Off_Notification_Account_Mapping__c obj: OfferingNotificationAccMapTempList)
                selectedAccountId.add(obj.Vendor_Account_Address__r.id);
            Query += ' AND id IN : selectedAccountId ';
        }
        List<Address__c> lstAccount = Database.query(Query);
        list<AccountWrapper> tempAccountLst = new list<AccountWrapper>();
        list<AccountWrapper> checkedAccountLst = new list<AccountWrapper>();
        for(Address__c accObj:lstAccount){
            if(accObj.Street__c != ''){
                billingAddress = accObj.Street__c + ',';
            }
            billingAddress += '<br/>';
            if(accObj.City__c != ''){
                billingAddress += accObj.City__c + ',';
            }
            if(accObj.State__c != ''){
                billingAddress += accObj.State__c + ',';
            }
            if(accObj.PostalCode__c != ''){
                billingAddress += accObj.PostalCode__c + ',';
            }
            billingAddress += '<br/>';
            if(accObj.Country__c != ''){
                billingAddress += accObj.Country__c;
            }

            if(AccountIdPassToHdn.contains(accObj.id+'') || selectedAccountId.contains(accObj.id)){
                checkedAccountLst.add(new AccountWrapper(accObj, true, billingAddress, accObj.id));
                lookUp += accObj.name + ', ';
            }
            else {
                tempAccountLst.add(new AccountWrapper(accObj, false, billingAddress, accObj.id));

            }
            if(tempAccountLst.size() == 1000){//limit of vf repeat components
                lstAccountWrapper.add(tempAccountLst);
                tempAccountLst = new List<AccountWrapper>();
            }

        }
        lstAccountWrapper.add(tempAccountLst);
        if(checkedAccountLst != null && checkedAccountLst.size()>0){
            lstAccountWrapper.add(0,checkedAccountLst);
        }

        system.debug('idToViewAccount'+idToViewAccount);

        oneKeyCountries = new List<String>();
        String key = '';
        for(IMS_Data_Asset__c masterOffObj : [select id,BU__c,Geo_Level__c,Asset_Name__c, (select id, Display_Order__c, 
                                              Secondary_Asset_Name__c, Geo_Level__c
                                              from IMS_Secondary_Data_Assets__r where Is_Active__c = True 
                                              order by Display_Order__c, Secondary_Asset_Name__c)
                                              from IMS_Data_Asset__c where BU__c != null and Is_Active__c = True 
                                              order by Other_for_Sorting_Display__c, Asset_Name__c]){
                if(masterOffObj.Asset_Name__c != null && masterOffObj.Asset_Name__c.startsWith('OneKey Data - ') ){ 
                    if(oneKeyCountries != null && oneKeyCountries.size() > 0 && !oneKeyCountries.contains(masterOffObj.BU__c)){
                        oneKeyCountries.add(masterOffObj.BU__c);
                    }
                    else if(oneKeyCountries != null && oneKeyCountries.size() == 0){
                        oneKeyCountries.add(masterOffObj.BU__c);
                    }
        }

    }

    }

    public String getNameOfOffMapping(){
        TPA_Offering_Notification_Mapping__c co = [select Id,name from TPA_Offering_Notification_Mapping__c order by CreatedDate desc limit 1];
        String name = co.Name;
        return name;
    }

    public void saveNotificationMapping() {
        isError = false;
        errorText = '';
        system.debug('TPAOffNotificationMappingtoUpdate: '+TPAOffNotificationMappingtoUpdate);
        system.debug('lstofAllTPAOffNotificationMapping: '+lstofAllTPAOffNotificationMapping);

        if(TPAOffNotificationMappingtoUpdate == NULL)
        {
            system.debug('TPAOffNotificationMappingtoUpdate: '+TPAOffNotificationMappingtoUpdate);
            TPAOffNotificationMappingtoUpdate = new TPA_Offering_Notification_Mapping__c();
        }

        if(TPAOffNotificationMappingtoUpdate.IMS_Primary_Data_Asset__c == NULL && TPAOffNotificationMappingtoUpdate.IMS_TPA_Purpose__c == NULL && (AccountIdMap == null || AccountIdMap == '') ){ 
            errorText = errorText += '<li>Please Select at Least one in Primary Offering, Use and Vendor Account </li>';
            isError = true;
        }
        if(TPAOffNotificationMappingtoUpdate.Offering_Notifications__c == NULL && TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c == NULL)
        {
            errorText = errorText += '<li>Please Select at Least one in Offering Notifications and Addendum Terms </li>';
            isError = true;
        }
        if(TPAOffNotificationMappingtoUpdate.Offering_Notifications__c != NULL && (TPAOffNotificationMappingtoUpdate.Process_Execution_Mode__c == NULL || TPAOffNotificationMappingtoUpdate.Process_Execution_Mode__c == ''))
        {
            errorText = errorText += '<li>Please Select Process Execution Mode </li>';
            isError = true;
        }
        if(selectedOneKeyCountries != null){
            TPAOffNotificationMappingtoUpdate.OneKey_Countries__c = selectedOneKeyCountries;
        }

        String priOffId = '';  String secOffId =  ''; String vendorAccId = ''; String useId = ''; String country = '';
        String OffNotTerms = ''; String AddendumTerms = '';
        if(TPAOffNotificationMappingtoUpdate.IMS_Primary_Data_Asset__c != null) {
            priOffId = TPAOffNotificationMappingtoUpdate.IMS_Primary_Data_Asset__c + '' ;
        }
        if(TPAOffNotificationMappingtoUpdate.IMS_Secondary_Data_Asset__c != null) {
            secOffId = TPAOffNotificationMappingtoUpdate.IMS_Secondary_Data_Asset__c + '';
        }
        if(TPAOffNotificationMappingtoUpdate.IMS_TPA_Purpose__c != null) {
            useId = TPAOffNotificationMappingtoUpdate.IMS_TPA_Purpose__c + '';
        }
        if(TPAOffNotificationMappingtoUpdate.Offering_Notifications__c != null) {
            OffNotTerms = TPAOffNotificationMappingtoUpdate.Offering_Notifications__c + '';
        }
        if(TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c != null) {
            AddendumTerms = TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__c + '';
        }
        String keyOfNewRule = priOffId + ';' + secOffId + ';' + useId + ';' + OffNotTerms + ';' + AddendumTerms + ';' + TPAOffNotificationMappingtoUpdate.Process_Execution_Mode__c;
        
        System.debug('keyOfNewRule' + keyOfNewRule);

        String OffCountries = '';

        if(TPAOffNotificationMappingtoUpdate.IMS_Primary_Data_Asset__r != null && TPAOffNotificationMappingtoUpdate.IMS_Primary_Data_Asset__r.Asset_Name__c.startsWith('OneKey Data - ')){
            if(TPAOffNotificationMappingtoUpdate.Is_Applicable_for_All_OneKey_Countries__c){
                OffCountries = 'ALL'; 
            }
            else{
                OffCountries = TPAOffNotificationMappingtoUpdate.OneKey_Countries__c + ';' + TPAOffNotificationMappingtoUpdate.Country__c;
            }
        }
        else{
            OffCountries = TPAOffNotificationMappingtoUpdate.Country__c;
        }
        
        getMapOffNotiRulewithCountryVendorId();
        if(!isError && MapOffNotiRulewithCountryVendorId != null && MapOffNotiRulewithCountryVendorId.containsKey(keyOfNewRule)){
            List<String> countryAndVendorVal = MapOffNotiRulewithCountryVendorId.get(keyOfNewRule).split('~');
            Boolean sameVendorPresent = true;
            Boolean sameCountryPresent = true;
            if(AccountIdMap != null && AccountIdMap != '' && countryAndVendorVal[0] != null && countryAndVendorVal[0] != ''){
                
                List<String> accountIdSet = AccountIdMap.split(',');
                for(String VendorId : accountIdSet){
                    if(!countryAndVendorVal[0].contains(VendorId.trim())){
                        sameVendorPresent = false;
                        Break;
                    }
                }
            }
            
            if(countryAndVendorVal[1] != null && countryAndVendorVal[1] != 'ALL' ){
                for(String OffCountry : OffCountries.split(';') ){
                    if(!countryAndVendorVal[1].contains(OffCountry.trim())){
                        sameCountryPresent = false;
                        Break;
                    }
                }
            }
            if(sameCountryPresent && sameVendorPresent){
                errorText = errorText += '<li>Duplicate value on record Name: ';
                if(countryAndVendorVal[2] != null && countryAndVendorVal[2] != ''){
                    for(String ruleID : countryAndVendorVal[2].split(';') ){
                        List<String> ruleIdWithName = ruleID.split(':');
                        errorText += '<a href=' + TPA_Settings__c.getOrgDefaults().Base_Url_Public__c+'/'+ ruleIdWithName[0] + '>' 
                        + ruleIdWithName[1] + '</a>';
                        break;
                    }
                }
                errorText += '</li>';
                isError = true;
            }
        }
            

        if(isError == true)
        {
            errorText = '<ul>' + errorText + '</ul>';
            system.debug('errorText: '+errorText);
        }
        else{
            system.debug('errorText'+errorText);
            upsert TPAOffNotificationMappingtoUpdate;

            
            List<TPA_Off_Notification_Account_Mapping__c> TPAOffNotificationAccountMappinglst = new list<TPA_Off_Notification_Account_Mapping__c>();
            List<TPA_Off_Notification_Account_Mapping__c> TPAOffNotificationAccountMappinglsttoDelete = new list<TPA_Off_Notification_Account_Mapping__c>();
            
            TPAOffNotificationAccountMappinglsttoDelete = SLT_TPAOffNotificationAccountMapping.instance.selectByFilterOnly('TPA_Offering_Notification_Mapping_Rule__r.id = \'' + TPAOffNotificationMappingtoUpdate.id + '\' ');
            
            if(TPAOffNotificationAccountMappinglsttoDelete!= null && TPAOffNotificationAccountMappinglsttoDelete.size() > 0)
                delete TPAOffNotificationAccountMappinglsttoDelete;
            if(AccountIdMap != null && AccountIdMap != ''){
                List<String> accountIdSet = AccountIdMap.split(',');
                for(String accid : accountIdSet){
                    if(accid !=null && accid.trim() != ''){
                        TPAOffNotificationAccountMappinglst.add(new TPA_Off_Notification_Account_Mapping__c (TPA_Offering_Notification_Mapping_Rule__c = TPAOffNotificationMappingtoUpdate.id, Vendor_Account_Address__c = Id.valueOf(accid.trim())));
                    }
                }
            }

            if(TPAOffNotificationAccountMappinglst != null && TPAOffNotificationAccountMappinglst.size()> 0)
                upsert TPAOffNotificationAccountMappinglst;

            String address = '';

            Set<String> fieldSetTemp = new Set<String>{'Vendor_Account_Address__r.Name', 'Vendor_Account_Address__r.Id', 'Billing_Address__c'};
            OfferingNotificationAccMapTempList = SLT_TPAOffNotificationAccountMapping.instance.selectFieldsSetById(fieldSetTemp, (new Map<Id,TPA_Off_Notification_Account_Mapping__c>(TPAOffNotificationAccountMappinglst)).keySet());
            for(TPA_Off_Notification_Account_Mapping__c obj : OfferingNotificationAccMapTempList)
                address += obj.Vendor_Account_Address__r.Name + '; ';

            TPAOffNotificationMappingtoUpdate.Vendor_Accounts_Name__c = address;
            upsert TPAOffNotificationMappingtoUpdate;

            query = 'SELECT Id,Name,IsActive__c,Country__c,Offering_Country_Name__c ,IMS_Primary_Data_Asset__r.Asset_Name__c, Primary_Data_Asset_Name__c, IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c,Secondary_Data_Asset_Name__c,IMS_TPA_Purpose__r.Primary_Purpose_Name__c,Purpose_Name__c,Offering_Notifications__r.Page_Name__c,TLLA_Additional_Terms__r.Page_Name__c,Process_Execution_Mode__c,LastModifiedBy.name,Vendor_Accounts_Name__c,lastmodifieddate,OneKey_Countries__c,Is_Applicable_for_All_OneKey_Countries__c FROM TPA_Offering_Notification_Mapping__c WHERE ((LastModifiedDate  >= LAST_N_MONTHS:3 AND IsActive__c = false) OR IsActive__c = true) ';
            
            refresh();
            idToUpdate = NULL;
            idToClone = NULL;
            TPAOffNotificationMappingtoUpdate = new TPA_Offering_Notification_Mapping__c();
            editCloneUseOffLabels = '';
            AccountIdMap = ''; 
            lookUp = '';       
            MapOfAccIdWithName = new Map <ID, String>(); 
            serializedMapOfAccIdWithName = '';
        }
    }

    public void ShowDataToEdit() {
        serializedMapOfAccIdWithName = '';
        Set<String> fieldSet = new Set<String>{'Id', 'Name', 'IsActive__c', 'Country__c', 'Offering_Country_Name__c', 'Purpose_Name__c', 'IMS_Primary_Data_Asset__r.Asset_Name__c', 'Primary_Data_Asset_Name__c', 'Secondary_Data_Asset_Name__c', 'IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c', 'IMS_TPA_Purpose__r.Primary_Purpose_Name__c', 'Offering_Notifications__r.Page_Name__c', 'TLLA_Additional_Terms__r.Page_Name__c', 'Process_Execution_Mode__c', 'Vendor_Accounts_Name__c', 'OneKey_Countries__c', 'Is_Applicable_for_All_OneKey_Countries__c'};
        OfferingNotificationMapTempList = new SLT_TPAOfferingNotificationMapping().getTPAOfferingNotificationMappingDataById(idToUpdate, fieldSet);
        if(OfferingNotificationMapTempList != null && OfferingNotificationMapTempList.size() >0 ){
            TPAOffNotificationMappingtoUpdate = OfferingNotificationMapTempList[0];
        }
        editCloneUseOffLabels = TPAOffNotificationMappingtoUpdate.Purpose_Name__c + ':::' + TPAOffNotificationMappingtoUpdate.Primary_Data_Asset_Name__c + ':::' + TPAOffNotificationMappingtoUpdate.Secondary_Data_Asset_Name__c;
        addendumAndOffNotificationValues = TPAOffNotificationMappingtoUpdate.Offering_Notifications__r.Page_Name__c + ':::' + TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__r.Page_Name__c;
        AccountIdMap = '';
        lookUp = '';
        Set<String> fieldSetTemp = new Set<String>{'TPA_Offering_Notification_Mapping_Rule__c', 'Vendor_Account_Address__r.id', 'TPA_Offering_Notification_Mapping_Rule__r.id', 'Vendor_Account_Address__c', 'Vendor_Account_Address__r.name', 'Vendor_Account_Address__r.id'};
        //String filterCondition = 'TPA_Offering_Notification_Mapping_Rule__r.id = \'' + idToUpdate + '\' ';

        OfferingNotificationAccMapTempList = SLT_TPAOffNotificationAccountMapping.instance.selectByFilter(fieldSetTemp, 'TPA_Offering_Notification_Mapping_Rule__r.id = \'' + idToUpdate + '\' ');
        for(TPA_Off_Notification_Account_Mapping__c TPAOffNotificationAcctMappingObj : OfferingNotificationAccMapTempList){
            AccountIdMap += TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.id +',';
            lookUp += TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.name + ', ';
            MapOfAccIdWithName.put(TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.id, TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.name);
            serializedMapOfAccIdWithName = JSON.serialize(MapOfAccIdWithName);
        }
        
    }

    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query +' order by ' + 'IsActive__c desc' ));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }
        set;
    }

    public void refresh(){
        Integer pageNumber = setCon.getPageNumber();
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query+' order by ' + 'IsActive__c desc'  + ', '+ sortField + ' ' + sortDir));
        setCon.setPageSize(size);
        setCon.setPageNumber(pageNumber);
    }

    public PageReference refreshPageSize() {
        setCon.setPageSize(size);
        return null;
    }

    public List<TPA_Offering_Notification_Mapping__c> getTPAOffNotificationMappings()
    {
        lstofAllTPAOffNotificationMapping = setCon.getRecords();
        return lstofAllTPAOffNotificationMapping;
    }
    public void CreteClonedCopy(){
        idToUpdate = NULL;
        serializedMapOfAccIdWithName = '';
        TPAOffNotificationMappingtoUpdate = new TPA_Offering_Notification_Mapping__c();
        Set<String> fieldSet = new Set<String>{'Id','OneKey_Countries__c', 'Is_Applicable_for_All_OneKey_Countries__c', 'Name', 'IsActive__c', 'Country__c', 'Offering_Country_Name__c', 'Purpose_Name__c', 'IMS_Primary_Data_Asset__r.Asset_Name__c', 'Primary_Data_Asset_Name__c', 'Secondary_Data_Asset_Name__c', 'IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c', 'IMS_TPA_Purpose__r.Primary_Purpose_Name__c', 'Offering_Notifications__r.Page_Name__c', 'TLLA_Additional_Terms__r.Page_Name__c', 'Process_Execution_Mode__c', 'Vendor_Accounts_Name__c'};
            OfferingNotificationMapTempList = new SLT_TPAOfferingNotificationMapping().getTPAOfferingNotificationMappingDataById(idToClone, fieldSet);
        if(OfferingNotificationMapTempList != null && OfferingNotificationMapTempList.size() >0 ){
            TPAOffNotificationMappingtoUpdate = OfferingNotificationMapTempList[0];
        }

        TPAOffNotificationMappingtoUpdate = TPAOffNotificationMappingtoUpdate.clone(false);
        editCloneUseOffLabels = TPAOffNotificationMappingtoUpdate.Purpose_Name__c + ':::' + TPAOffNotificationMappingtoUpdate.Primary_Data_Asset_Name__c + ':::' + TPAOffNotificationMappingtoUpdate.Secondary_Data_Asset_Name__c;
        addendumAndOffNotificationValues = TPAOffNotificationMappingtoUpdate.Offering_Notifications__r.Page_Name__c + ':::' + TPAOffNotificationMappingtoUpdate.TLLA_Additional_Terms__r.Page_Name__c;
        AccountIdMap = '';
        lookUp = '';
        Set<String> fieldSetTemp = new Set<String>{'TPA_Offering_Notification_Mapping_Rule__c', 'Vendor_Account_Address__r.id', 'TPA_Offering_Notification_Mapping_Rule__r.id', 'Vendor_Account_Address__c', 'Vendor_Account_Address__r.name', 'Vendor_Account_Address__r.id'};
        //String filterCondition = 'TPA_Offering_Notification_Mapping_Rule__r.id = \'' + idToUpdate + '\' ';

        OfferingNotificationAccMapTempList = SLT_TPAOffNotificationAccountMapping.instance.selectByFilter(fieldSetTemp, 'TPA_Offering_Notification_Mapping_Rule__r.id = \'' + idToClone + '\' ');
        for(TPA_Off_Notification_Account_Mapping__c TPAOffNotificationAcctMappingObj : OfferingNotificationAccMapTempList){
            AccountIdMap += TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.id +',';
            lookUp += TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.name + ', ';
            MapOfAccIdWithName.put(TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.id, TPAOffNotificationAcctMappingObj.Vendor_Account_Address__r.name);
            serializedMapOfAccIdWithName = JSON.serialize(MapOfAccIdWithName);
        }
    }

    public void runSearch(){
        String VendorAccountName = Apexpages.currentPage().getParameters().get('VendorAccountName');
        String uses = Apexpages.currentPage().getParameters().get('uses');
        String primaryOfferingName = Apexpages.currentPage().getParameters().get('primaryOfferingName');
        String secondryOfferingName = Apexpages.currentPage().getParameters().get('secondryOfferingName');
        String countryName = Apexpages.currentPage().getParameters().get('countryName');
        
        query = 'SELECT Id,Name,IsActive__c,Country__c,Offering_Country_Name__c ,Primary_Data_Asset_Name__c ,IMS_Primary_Data_Asset__r.Asset_Name__c,IMS_Secondary_Data_Asset__r.Secondary_Asset_Name__c,Secondary_Data_Asset_Name__c,IMS_TPA_Purpose__r.Primary_Purpose_Name__c,Purpose_Name__c,Offering_Notifications__r.Page_Name__c,TLLA_Additional_Terms__r.Page_Name__c,Process_Execution_Mode__c,LastModifiedBy.name,Vendor_Accounts_Name__c,lastmodifieddate,OneKey_Countries__c,Is_Applicable_for_All_OneKey_Countries__c FROM TPA_Offering_Notification_Mapping__c WHERE ';
        if (!VendorAccountName.equals(''))
            query += ' Id IN (SELECT TPA_Offering_Notification_Mapping_Rule__c from TPA_Off_Notification_Account_Mapping__c WHERE Vendor_Account_Address__r.Name LIKE \'%'+String.escapeSingleQuotes(VendorAccountName)+'%\' ) AND ';
        if (!uses.equals(''))
            query += 'Purpose_Name__c LIKE \'%'+String.escapeSingleQuotes(uses)+'%\' AND ';
        if (!primaryOfferingName.equals(''))
            query += 'IMS_Primary_Data_Asset__r.Asset_Name__c LIKE \'%'+String.escapeSingleQuotes(primaryOfferingName)+'%\' AND ';
        if (!secondryOfferingName.equals(''))
            query += 'Secondary_Data_Asset_Name__c LIKE \'%'+String.escapeSingleQuotes(secondryOfferingName)+'%\' AND ';
        if(!countryName.equals('')){
            query += 'Country__c LIKE \'%'+String.escapeSingleQuotes(countryName)+'%\' AND ';
        }

        query += '((LastModifiedDate  >= LAST_N_MONTHS:3 AND IsActive__c = false) OR IsActive__c = true) AND ';    

        
        if(query.substring(Query.length()-4,Query.length()).equals('AND '))
            query = Query.substring(0,Query.length()-4);
        if(query.substring(Query.length()-6,Query.length()).equals('WHERE '))
            query = Query.substring(0,Query.length()-6);


        system.debug(query);
        refresh();
    }
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        refresh();
    }
    public Pagereference exportAll(){
        lstofTPAOffNotificationMappingToExport = new List<List<TPA_Offering_Notification_Mapping__c>>();

        List<TPA_Offering_Notification_Mapping__c> tempList = new List<TPA_Offering_Notification_Mapping__c>();

        Set<String> fieldSet = new Set<String>{'Name', 'Account_Address__c', 'Purpose_Name__c', 'Country__c', 'Primary_Data_Asset_Name__c','Secondary_Data_Asset_Name__c', 'Offering_Notifications__r.Page_Name__c', 'TLLA_Additional_Terms__r.Page_Name__c', 'Process_Execution_Mode__c', 'LastModifiedBy.name', 'lastmodifieddate' , 'IsActive__c', 'Vendor_Accounts_Name__c'};
        Set<String> fieldSetTemp = new Set<String>{'Billing_Address__c', 'Vendor_Account_Address__r.id'};
         OfferingNotificationMapTempList = SLT_TPAOfferingNotificationMapping.instance.selectWithLineItems(fieldSet, fieldSetTemp);

        for(TPA_Offering_Notification_Mapping__c a : OfferingNotificationMapTempList){
            a.Account_Address__c = '';
            for(TPA_Off_Notification_Account_Mapping__c accMapObj : a.TPA_Off_Notification_Account_Mapping__r){
                if(accMapObj.Billing_Address__c != null && accMapObj.Billing_Address__c != '')
                     a.Account_Address__c +=  accMapObj.Billing_Address__c +  '; ';
            }
            if(a.Account_Address__c.length() >0 && a.Account_Address__c.substring(a.Account_Address__c.length()-2,a.Account_Address__c.length()).equals('; '))
                a.Account_Address__c = a.Account_Address__c.substring(0,a.Account_Address__c.length()-2);
            if(a.Vendor_Accounts_Name__c == null || a.Vendor_Accounts_Name__c.length() == 0)
                a.Vendor_Accounts_Name__c = 'ALL';
            tempList.add(a);

            if(tempList.size() == 1000){//limit of vf repeat components
                lstofTPAOffNotificationMappingToExport.add(tempList);
                tempList = new List<TPA_Offering_Notification_Mapping__c>();
            }
        }
        lstofTPAOffNotificationMappingToExport.add(tempList);
        return Page.VFP_TPA_OffNotifMappingExportALL;

    }
    public void resetOffId() {
        idToUpdate = null;
        TPAOffNotificationMappingtoUpdate = new TPA_Offering_Notification_Mapping__c();
        isError = false;
        errorText = '';
        editCloneUseOffLabels = '';
        lookUp = '';    
        AccountIdMap = '';    
    }

}