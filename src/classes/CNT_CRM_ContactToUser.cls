/*
* v 47.0
* Class to manage contact to user functionality
*/
public class CNT_CRM_ContactToUser{
    public static Map<String, Id> idToUserMapToUpdateSfUser = new Map<String, Id>();
    public static final String EMAIL_REQUIRED = 'Email is required to create chatter user.';
    public static final String USER_COUNTRY_REQUIRED = 'User country is required to create chatter user.';
    public static final String USER_COUNTRY_REQUIRED_OR_INVALID_COUNTRY = 'User country you have entered is invalid.';
    public static final String EMAILENCODING_UTF_8 = 'UTF-8';
    public static final String IQVIA_USER_EXIST = 'Salesforce user is already exist on this contact';
    public static final String IQVIA_USER_EXIST_WITH_EMPLOYEE_NUMBER = 'User is already exist with this employee number';
    public static final String LICENSE_EXPIRY_DATE_ERROR = 'License expiry date should be blank to create chatter user.';
    public static final String USERNAME = 'Username';
    public static final String DUPLICATE_USERNAME = 'DUPLICATE_USERNAME';
    public static final String ERROR_WHILE_CREATE_USER = 'Error while creating user,';
    public static final String PROFILE_FREE_CHATTER = 'Chatter Free User';
    public static final String SN_TICKET_REQIRED_ERROR = 'SN ticket or SN ticket description is required';
    public static final String WD_PER_ORG_EMP = 'EMP';
    public static final String WD_PER_ORG_CWR = 'CWR';
    public CNT_CRM_ContactToUser() {
        
    }
    
    /*
    * @params 
    * Fetch cuurent user's PermissionsManageUsers access 
    */
    @AuraEnabled
    public static Boolean fetchCurrentUsersAccess(){
        Boolean isUserHasManageUserAccess = false;
        List<UserPermissionAccess> currentUserDetails = [SELECT PermissionsManageUsers, Id FROM UserPermissionAccess limit 1];
        if(currentUserDetails.size() > 0){
            isUserHasManageUserAccess = currentUserDetails[0].PermissionsManageUsers;
        }else if(Test.isRunningTest()){
            isUserHasManageUserAccess = true;
        }
        return isUserHasManageUserAccess;
    }
    /*
    * @params String objectName, String fieldName, String condition, String recordsLimit
    * Fetch record based on object name, field name and conditions, used in contact to user lwc 
    */
    @AuraEnabled
    public static List<ResponseWrapper> fetchRecords(String objectName, String fieldName, String condition, String recordsLimit){
        if(condition != ''){
            condition = ' where '+condition;
        }
        String query ='Select Id,'+fieldName+' from '+objectName+' '+condition+' order by Name ASC limit '+recordsLimit;
        List<sObject> sobjList = Database.query(query);
        List<ResponseWrapper> rwList = new List<ResponseWrapper>();
        if(sobjList.size() > 0){
            for(sObject obj : sobjList){
                rwList.add(new ResponseWrapper(obj,fieldName));
            }
        }
        return rwList;
    }
    /*
    * @params String objectName, List<String> fieldName, String condition, String recordsLimit
    * Fetch record based on object name, field name and conditions, used in contact to user lwc 
    */
    @AuraEnabled
    public static List<sObject> fetchObjectsRecords(String objectName, List<String> fieldList, String condition, String recordsLimit){
        if(condition != ''){
            condition = ' where '+condition;
        }
        String query ='Select Id,';
        Integer count = 0;
        for(String s : fieldList){
            query += s;
            if(fieldList.size() != count+1){
                query += ' ,';
            }
            count++;
        }
        query +=' from '+objectName+' '+condition+' limit '+recordsLimit;
        System.debug('--'+query);
        List<sObject> sobjList = Database.query(query);
        return sobjList;
    }
    
    /*
    * @params String objName, String fieldName
    * Fetch picklist based on object and fieldname
    */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues(String objName, String fieldName) {
        List<Map<String, String>> pickValuesList = new List<Map<String, String>>();
        Map<String, String> lableValueMap;
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            lableValueMap = new Map<String, String>();
            lableValueMap.put('label', pickListVal.getLabel());
            lableValueMap.put('value', pickListVal.getValue());
            lableValueMap.put('default', String.valueOf(pickListVal.isDefaultValue()));
            pickValuesList.add(lableValueMap);
        }    
        return pickValuesList;
    }
    
    
    /*
    * @Param List<Contact> contactList, Map<Id, Contact> oldMap
    * check for valid employee number    
    */
    public static void checkValidEmployeeNumber(List<Contact> contactList, Map<Id, Contact> oldMap){
        if(fetchCurrentUsersAccess()){
            Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
            Set<String> employeeNumbersList = new Set<String>();
            List<Contact> contactsToCreateUserList= new List<Contact>();
            List<Contact> contactsContainEmployeeNumberList = new List<Contact>();
            for(Contact con : contactList){
                if(con.Create_Chatter_user__c && (Trigger.isInsert || !oldMap.get(con.id).Create_Chatter_user__c) && con.RecordTypeId == CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT){
                    if(!String.isBlank(con.Salesforce_User__c) && !mulesoftSetting.Ignore_Validation_Rules__c){
                        con.addError(IQVIA_USER_EXIST);
                    }else if(!String.isBlank(con.EmployeeNumber__c) && (con.EmployeeNumber__c).isNumeric()){
                        employeeNumbersList.add(con.EmployeeNumber__c);
                        contactsContainEmployeeNumberList.add(con);
                    }    
                }
            }
            List<User> usersList = fetchUserByEmployeeNumber(employeeNumbersList);
            if(usersList.size() > 0){
                Map<String, User> employeeNumberToUserMap = new Map<String, User>();
                for(User crrUser : usersList){
                    employeeNumberToUserMap.put(crrUser.EmployeeNumber,crrUser);
                }
                for(Contact con : contactsContainEmployeeNumberList){
                    if(!employeeNumberToUserMap.containsKey(con.EmployeeNumber__c)){
                        contactsToCreateUserList.add(con);
                    }else if(!mulesoftSetting.Ignore_Validation_Rules__c){
                        con.addError(IQVIA_USER_EXIST_WITH_EMPLOYEE_NUMBER);
                    }
                }
            }else{
                contactsToCreateUserList.addAll(contactsContainEmployeeNumberList);
            }
            //System.debug('contactsToCreateUserList---'+contactsToCreateUserList);
            createUsersObject(contactsToCreateUserList);    
        }
    }
    public static List<User> fetchUserByEmployeeNumber(Set<String> employeeNumbersList){
        List<User> usersList = new SLT_User().selectUserByEmployeeNumber(employeeNumbersList, new Set<String>{'Id','EmployeeNumber'});
        return usersList;
    }
    /*
    * @param List<Contact> contactList
    * Create user lists to insert
    */
    public static void createUsersObject(List<Contact> contactList){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        List<String> contactCountryList = new List<String>();
        for(Contact con : contactList){
            contactCountryList.add(con.Country__c);
        }
        list<Profile> profileList = [Select Id,Name from Profile where Name  =: PROFILE_FREE_CHATTER limit 1];
        List<User> usersToCreateList = new List<User>();
        if(profileList.size() > 0){
            Map<String,String> countryToTimezoneMap = fetchTimeZoneMapping(contactCountryList);
            Map<String,User_Locale_Mapping__mdt> countryToLocaleMap = fetchLocaleMapping(contactCountryList);
            Map<String,String> countryPicklistMap = fetchDeliveryCountryValues();
            Organization currentOrg= [Select Id,DefaultLocaleSidKey, LanguageLocaleKey, TimeZoneSidKey From Organization limit 1];
            for(Contact con : contactList){
                Boolean isErrorFound = false;
                User newUser = new User();
                newUser.FirstName = con.FirstName;
                newUser.LastName = con.LastName;
                if(!String.isBlank(con.Email)){
                    newUser.Email = con.Email;
                    newUser.Username = con.Email;
                }else if(!mulesoftSetting.Ignore_Validation_Rules__c){
                    isErrorFound = true;
                    con.addError(EMAIL_REQUIRED);
                }
                if(!String.isBlank(con.Country__c) && countryPicklistMap.containsKey(con.Country__c)){
                    newUser.User_Country__c = countryPicklistMap.get(con.Country__c);   // doing ths bcoz country and usercountry both have different picklist apis name
                }else if(!mulesoftSetting.Ignore_Validation_Rules__c){
                    isErrorFound = true;
                    if(!String.isBlank(con.Country__c)){
                        con.addError(USER_COUNTRY_REQUIRED_OR_INVALID_COUNTRY);
                    }else{
                        con.addError(USER_COUNTRY_REQUIRED);
                    }
                }
                if(countryToTimezoneMap.containsKey(con.Country__c)){
                    if(countryToTimezoneMap.get(con.Country__c) != null){
                        newUser.TimeZoneSidKey = countryToTimezoneMap.get(con.Country__c);
                    }else{
                        newUser.TimeZoneSidKey = currentOrg.TimeZoneSidKey;
                    }
                }else{
                    newUser.TimeZoneSidKey = currentOrg.TimeZoneSidKey;
                }
                if(countryToLocaleMap.containsKey(con.Country__c)){
                    if(countryToLocaleMap.get(con.Country__c).EmailEncodingKey__c != null){
                        newUser.EmailEncodingKey = countryToLocaleMap.get(con.Country__c).EmailEncodingKey__c;
                    }else{
                        newUser.EmailEncodingKey = EMAILENCODING_UTF_8;
                    }
                    if(countryToLocaleMap.get(con.Country__c).LanguageLocaleKey__c != null){
                        newUser.LanguageLocaleKey = countryToLocaleMap.get(con.Country__c).LanguageLocaleKey__c;
                    }else{
                        newUser.LanguageLocaleKey = currentOrg.LanguageLocaleKey;
                    }
                    if(countryToLocaleMap.get(con.Country__c).LocaleSidKey__c != null){
                        newUser.LocaleSidKey = countryToLocaleMap.get(con.Country__c).LocaleSidKey__c;
                    }else{
                        newUser.LocaleSidKey = currentOrg.DefaultLocaleSidKey;
                    }
                }else{
                    newUser.LocaleSidKey = currentOrg.DefaultLocaleSidKey;
                    newUser.LanguageLocaleKey = currentOrg.LanguageLocaleKey;
                    newUser.EmailEncodingKey = EMAILENCODING_UTF_8;     //May need to change
                }
                if(con.EmployeeNumber__c.length() > 8){
                    newUser.Alias = con.EmployeeNumber__c.subString(0,8);
                }else{
                    newUser.Alias = con.EmployeeNumber__c;
                }
                newUser.EmployeeNumber = con.EmployeeNumber__c;
                newUser.CommunityNickname = con.EmployeeNumber__c;
                newUser.ProfileId = profileList[0].Id;
                newUser.FederationIdentifier = con.FederationIdentifier__c;
                newUser.Phone = con.Phone;
                newUser.WD_Location_code__c = con.Location_Code_text__c;
                newUser.WD_Q_Department_ID__c = con.WD_Q_Department_ID__c;
                newUser.WD_Hire_Date__c = con.pse__Start_Date__c;
                newUser.WD_Q_Department_Description__c = con.WD_Q_Department_Description__c;
                //newUser.UserRoleId = '';
                newUser.WD_EMPL_STATUS__c = con.pse__Employment_Status__c;
                if(con.pse__External_Resource__c){
                    newUser.WD_PER_ORG__c = WD_PER_ORG_CWR;
                }else{
                    newUser.WD_PER_ORG__c = WD_PER_ORG_EMP;
                }
                newUser.WD_Location_code__c = con.Location__c;
                newUser.WD_Grade__c = con.Job_Grade__c;
                if(String.isBlank(String.valueOf(con.pse__Last_Date__c))){
                    newUser.License_Expiry_Date__c = con.pse__Last_Date__c;
                }else if(!mulesoftSetting.Ignore_Validation_Rules__c){
                    isErrorFound = true;
                    con.addError(LICENSE_EXPIRY_DATE_ERROR);
                }
                if(!(String.isBlank(con.SN_Ticket__c) && String.isBlank(con.SN_Ticket_Description__c))){
                    newUser.Change_Request_Ticket_Number__c = con.SN_Ticket__c;
                    newUser.Change_Request_Description__c = con.SN_Ticket_Description__c;
                }else if(!mulesoftSetting.Ignore_Validation_Rules__c){
                    isErrorFound = true;
                    con.addError(SN_TICKET_REQIRED_ERROR);
                }
                if(!isErrorFound){
                    newUser.Related_IQVIA_Internal_Contact__c = con.Id;
                    usersToCreateList.add(newUser);    
                }
            }
        }
        if(usersToCreateList.size() > 0){
            createUsers(usersToCreateList);
        }
    }
    
    /*
    *@param List<String> contactCountryList
    *Fetch timezone mapping from metadata based on country
    */
    @AuraEnabled
    public static Map<String,String> fetchTimeZoneMapping(List<String> contactCountryList){
        Set<String> countrySet = new Set<String>();
        countrySet.addAll(contactCountryList);
        List<User_Timezone_Mapping__mdt> timeZoneMapping = new SLT_UserTimezoneKeyMapping().fetchTimezoneMapping(new Set<String>{'City__c','CountryCode__c','TimeZoneSidKey__c','DeveloperName','Id'},countrySet);
        Map<String,String> countryToTimezoneMap = new Map<String,String>();
        for(User_Timezone_Mapping__mdt tzm : timeZoneMapping){
            countryToTimezoneMap.put(tzm.CountryCode__c,tzm.TimeZoneSidKey__c);
        }
        return countryToTimezoneMap;
    }
    
    /*
    *@param List<String> contactCountryList
    *Fetch locale mapping from metadata based on country
    */
    @AuraEnabled
    public static Map<String,User_Locale_Mapping__mdt> fetchLocaleMapping(List<String> contactCountryList){
        Set<String> countrySet = new Set<String>();
        countrySet.addAll(contactCountryList);
        List<User_Locale_Mapping__mdt> timeZoneMapping = new SLT_UserLocaleMapping().fetchLocaleMapping(new Set<String>{'Country__c','CountryCode__c','CurrencyIsoCode__c','EmailEncodingKey__c','LanguageLocaleKey__c','LocaleSidKey__c'},countrySet);
        Map<String,User_Locale_Mapping__mdt> countryToLocaleMap = new Map<String,User_Locale_Mapping__mdt>();
        for(User_Locale_Mapping__mdt localeRec : timeZoneMapping){
            countryToLocaleMap.put(localeRec.CountryCode__c,localeRec);
        }
        return countryToLocaleMap;
    }
    
    /*
    *@param List<String> contactCountryList
    *Fetch tiemzone and locale mapping from metadata based on country for lwc
    */
    @AuraEnabled
    public static Map<String,Object> fetchUserAdditionalMapping(List<String> contactCountryList){
        Map<String,Object> mappingMap = new Map<String,Object>();
        mappingMap.put('timezone', (Object)fetchTimeZoneMapping(contactCountryList));
        mappingMap.put('locale', (Object)fetchLocaleMapping(contactCountryList));
        return mappingMap;
    }
    
    /*
    *@param String userStr
    *Canvert user string to user object for insert new user
    */
    @AuraEnabled
    public static Map<String,Object> deserializeUsersJSON(String userStr){
        List<User> userList = (List<User>)JSON.deserialize(userStr, List<User>.Class);
        Map<String,Object> returnMap = createUsers(userList);
        return returnMap;
    }
    
    /*@param List<User> userList
    * Create new users and error handling
    * in this method we are handling functionality for both trigger and component
    * return value will be used to show response on component, return value is not useful for trigger
    */
    public static Map<String,Object> createUsers(List<User> userList){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Map<String,User> idToUserMap = new Map<String,User>();
        for(User crrUser : userList){
            idToUserMap.put(crrUser.EmployeeNumber,crrUser);
        }
        
        Map<String, Contact> employeeNumberToContactMap = new Map<String, Contact>();
        if(Trigger.IsExecuting){
            for(Contact con : (List<Contact >)Trigger.new){
                employeeNumberToContactMap.put(con.EmployeeNumber__c,con);
            }
        }
        Map<String,Object> returnMap = new Map<String,Object>();
        List<User> failedUserList = new List<User>();
        try{
            UTL_ExecutionControl.stopUserUpdateFromUserTrigger = true;
            Database.SaveResult[] srList = Database.insert(userList, false);
            UTL_ExecutionControl.stopUserUpdateFromUserTrigger = false;
            Integer recordCount = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    returnMap.put('usersList', sr.getId());
                    //idToUserMapToUpdateSfUser.put(userList[recordCount].EmployeeNumber, sr.getId());  // creating this map to update salesforce_User__c field on contact (declared globally bcoz this method is running recursively)
                }else {     
                    for(Database.Error err : sr.getErrors()) {
                        if(err.getFields().contains(USERNAME) && String.valueOf(err.getStatusCode()) == DUPLICATE_USERNAME){
                            failedUserList.add(userList[recordCount]);
                        }else{
                            if(Trigger.IsExecuting && employeeNumberToContactMap.containsKey(userList[recordCount].EmployeeNumber) && !mulesoftSetting.Ignore_Validation_Rules__c){
                                employeeNumberToContactMap.get(userList[recordCount].EmployeeNumber).addError(ERROR_WHILE_CREATE_USER+err.getFields()+','+err.getMessage());   // if user is inserting from backend and if user insertion is failed then contact insert/update will also failed
                            }
                            returnMap.put('error', err.getFields()+'--'+err.getMessage());
                        }
                    }
                }
                recordCount++;
            }
            if(failedUserList.size() > 0){
                for(User crrUser : failedUserList){
                    String initialKey = crrUser.Username.substring(0, crrUser.Username.indexOf('@'));
                    String lastKey =  crrUser.Username.substring(crrUser.Username.indexOf('@'),crrUser.Username.length());
                    crrUser.Username = initialKey+crrUser.EmployeeNumber+lastKey;     // if username is duplicate than we are adding employee number in username
                }
                return createUsers(failedUserList);  
            }
        }catch(Exception e){
            returnMap.put('error', e);
        }
        return returnMap;    // this return type is only to show response on component, not useful while inserting recoords from backend or trigger
    }
    
    
    
    /*Fetch Delivery_Country_Mapping__c custom setting data*/
    @AuraEnabled
    public static Map<String,String> fetchDeliveryCountryValues(){
        List<Delivery_Country_Mapping__c> dcmList = Delivery_Country_Mapping__c.getall().values();
        Map<String,String> countryPicklistMap = new Map<String,String>();
        for(Delivery_Country_Mapping__c dc : dcmList){
            if(dc.ISOCODE__c != null)
                countryPicklistMap.put(dc.ISOCODE__c, dc.Name);
        }
        return countryPicklistMap;
    }
    public static Map<String,String> fetchPicklistValues(String objName, String fieldName){
        Map<String, String> lableValueMap = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe(); 
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            lableValueMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }    
        return lableValueMap;
    }
    public class ResponseWrapper{
        @AuraEnabled public String value{get;set;}
        @AuraEnabled public String label{get;set;}
        public ResponseWrapper(sObject obj, String fieldName){
            value = String.valueOf(obj.get('Id'));
            label = String.valueOf(obj.get(fieldName));
        }
    }
}