import { LightningElement, api,wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord,createRecord } from 'lightning/uiRecordApi';
import fetchUserRecord from '@salesforce/apex/CNT_CRM_ContactToUser.fetchRecords';
import insertUserRecord from '@salesforce/apex/CNT_CRM_ContactToUser.deserializeUsersJSON';
import fetchUserAdditionalMapping from '@salesforce/apex/CNT_CRM_ContactToUser.fetchUserAdditionalMapping';
import fetchDeliveryCountryValues from '@salesforce/apex/CNT_CRM_ContactToUser.fetchDeliveryCountryValues';
import fetchSObjectsRecords from '@salesforce/apex/CNT_CRM_ContactToUser.fetchObjectsRecords';
import fetchCurrentUsersAccess from '@salesforce/apex/CNT_CRM_ContactToUser.fetchCurrentUsersAccess';
import User_OBJECT from '@salesforce/schema/User';
import FirstName_FIELD from '@salesforce/schema/User.FirstName';
import LastName_FIELD from '@salesforce/schema/User.LastName';
import Email_FIELD from '@salesforce/schema/User.Email';
import UserName_FIELD from '@salesforce/schema/User.Username';
import alias_FIELD from '@salesforce/schema/User.Alias';
import NickName_FIELD from '@salesforce/schema/User.CommunityNickname';
import profile_FIELD from '@salesforce/schema/User.ProfileId';
import Role_FIELD from '@salesforce/schema/User.UserRoleId';
import UserCountry_FIELD from '@salesforce/schema/User.User_Country__c';
import LocaleSidKey_FIELD from '@salesforce/schema/User.LocaleSidKey';
import TimeZoneSidKey_FIELD from '@salesforce/schema/User.TimeZoneSidKey';
import LanguageLocaleKey_FIELD from '@salesforce/schema/User.LanguageLocaleKey';
import EmailEncodingKey_FIELD from '@salesforce/schema/User.EmailEncodingKey';
import EmployeeNumber_FIELD from '@salesforce/schema/User.EmployeeNumber';
import MarketingUser_FIELD from '@salesforce/schema/User.UserPermissionsMarketingUser';
import WDEmplStatus_FIELD from '@salesforce/schema/User.WD_EMPL_STATUS__c';
import WDPerOrg_FIELD from '@salesforce/schema/User.WD_PER_ORG__c';
import WDQDeptId_FIELD from '@salesforce/schema/User.WD_Q_Department_ID__c';
import WDQDeptDescription_FIELD from '@salesforce/schema/User.WD_Q_Department_Description__c';
import WDHireDate_FIELD from '@salesforce/schema/User.WD_Hire_Date__c';
import WDLocationCode_FIELD from '@salesforce/schema/User.WD_Location_code__c';
import WDGrade_FIELD from '@salesforce/schema/User.WD_Grade__c';
import LicenseExpiryDate_FIELD from '@salesforce/schema/User.License_Expiry_Date__c';
import Phone_FIELD from '@salesforce/schema/User.Phone';
import ChangeRequestNumber_FIELD from '@salesforce/schema/User.Change_Request_Ticket_Number__c';
import ChangeRequestDesc_FIELD from '@salesforce/schema/User.Change_Request_Description__c';
import RelatedIQVIAInternalContact_FIELD from '@salesforce/schema/User.Related_IQVIA_Internal_Contact__c';
//import MarketingUser_FIELD from '@salesforce/schema/User.License_Expiry_Date__c';
import federationIdentifier_FIELD from '@salesforce/schema/User.FederationIdentifier';
const FIELDSMAPPING = ['Contact.Id','Contact.FirstName', 'Contact.LastName','Contact.Email', 'Contact.Name','Contact.EmployeeNumber__c','Contact.Location__c','Contact.Country__c','Contact.Job_Grade__c','Contact.Salesforce_User__c','Contact.pse__Employment_Status__c','Contact.pse__Last_Date__c','Contact.pse__External_Resource__c','Contact.SN_Ticket__c','Contact.SN_Ticket_Description__c','Contact.FederationIdentifier__c','Contact.WD_Q_Department_ID__c','Contact.WD_Q_Department_Description__c','Contact.pse__Start_Date__c','Contact.Phone'];
const FieldsToCheck = ['FirstName', 'LastName','Email', 'Name','EmployeeNumber__c','Location__c','Country__c','Job_Grade__c','pse__Employment_Status__c','pse__Last_Date__c','pse__External_Resource__c'];
export default class Lxc_crm_ContactToUser extends LightningElement {
    @api recordId ='';
    @api firstName = '';
    @api lastName = '';
    @api alias = '';
    @api email = '';
    @api userName = '';
    @api userEmail = '';
    @api nickName = '';
    @api snTicket = '';
    @api snTicketDescription = '';
    @api employeeNumber = '';
    @api marketingUser = false;
    @api snTiwdEmplStatuscket = '';
    @api wdPerOrg = '';
    @api exisitingUserRec;
    @api currentContact;
    @api isContactFound = false;
    wdPerOrgVal = '';
    @api isUserAlreadyCreated = false;
    showSaveBtn = false;
    federationIdentifier = '';
    userLink = '';
    erroStr = '';
    showModal;
    timezoneKeyVal = '';
    localeKeyVal = '';
    showCloseBtn = false;
    languageKeyVal = '';
    emailEncodingKeyVal = '';
    isduplicateUserNameFound = false;
    showSpinner = true;
    saveBtnTitle = '';
    isLicenseNotAvailable = false;
    isBtnDisbaled = false;
    licenseTblData = [];
    loadLocalePicklist = false;
    showProfileBlock = false;
    @api organizationInfo;
    duplicateEmplyeenumberFound = false;
    currentCountryVal = '';
    currentSelectedLicense = '';
    deliveryCountryMapping = {};
    licenseTblColumn = [{ label: 'License', fieldName: 'Name'},{ label: 'Remaining License', fieldName: 'remainingLicense'}];
    licenseFieldsSet = ['Name','TotalLicenses', 'UsedLicenses'];
    organizationFieldsSet = ['DefaultLocaleSidKey', 'LanguageLocaleKey','TimeZoneSidKey'];
    isUserHasManageUserAccess = false;
    isuserManageMethodFinished = false;
    constructor(){
        super();
        this.fetchCurrentUsersAccessFn();
    }
    @api fetchSObjectsRecords(objName, fieldList,condition, limit){
        this.showSpinner = true;
        fetchSObjectsRecords({ objectName: objName, fieldList: fieldList, condition : condition, recordsLimit : limit })
        .then(result => {
            if(objName == 'UserLicense'){
                var tblData = [];
                for(var i = 0;i<result.length;i++){
                    var remainingLiceseCount = parseInt(result[i].TotalLicenses) - parseInt(result[i].UsedLicenses);
                    var obj = {};
                    obj.remainingLicense = remainingLiceseCount.toString();
                    obj.Name = result[i].Name;
                    tblData.push(obj);
                }
                this.licenseTblData = tblData;
                this.showProfileBlock = true;
                this.showSpinner = false;
            }else if(objName == 'Organization'){
                if(result.length){
                    this.organizationInfo = result[0];
                }
            }
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            this.showSpinner = false;
        });
    }
    @api fetchObjectRecords(objName, fieldList,condition, limit){
        this.showSpinner = true;
        fetchSObjectsRecords({ objectName: objName, fieldList: fieldList, condition : condition, recordsLimit : limit })
        .then(result => {
            if(result.length > 0){
                if(fieldList.includes('EmployeeNumber')){
                    this.isBtnDisbaled = true;
                    this.exisitingUserRec = result[0];  
                    this.isUserAlreadyCreated = false;
                    this.duplicateEmplyeenumberFound = true;
                    this.showCloseBtn = true;
                    this.userLink = window.location.origin+"/"+ this.exisitingUserRec.Id;
                }else{
                    
                }        
            }else{
                this.isBtnDisbaled = false;
            }
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            this.showSpinner = false;
        });
    }
    fetchDeliveryCountryValues(){
        fetchDeliveryCountryValues()
        .then(result => {
            this.deliveryCountryMapping = result;
            this.currentCountryVal = this.deliveryCountryMapping[this.currentContact.Country__c.value];
            console.log(result);
        })
        .catch(error => {
            console.log(error);
        });
    }
    fetchUserDefaultMapping(countryList){
        fetchUserAdditionalMapping({ contactCountryList: countryList})
        .then(result => {
            console.log(result);
            if(countryList != null && countryList.length > 0){
                if(result != null && result.timezone){
                    if(result.timezone != null && result.timezone[countryList[0]]){
                        this.timezoneKeyVal = result.timezone[countryList[0]];
                    } 
                }
                if(result.locale){
                    if(result.locale != null && result.locale[countryList[0]]){
                        if(result.locale[countryList[0]].LocaleSidKey__c != null){
                            this.localeKeyVal = result.locale[countryList[0]].LocaleSidKey__c;
                        }
                        if(result.locale[countryList[0]].LanguageLocaleKey__c != null){
                            this.languageKeyVal = result.locale[countryList[0]].LanguageLocaleKey__c;
                        }
                        if(result.locale[countryList[0]].EmailEncodingKey__c != null){
                            this.emailEncodingKeyVal = result.locale[countryList[0]].EmailEncodingKey__c;
                        }
                    }
                }
                this.loadLocalePicklist = true;
            }else{
                this.loadLocalePicklist = true;
            }
            //if(result.length){
              //  this.organizationInfo = result[0];
            //}
        })
        .catch(error => {
            console.log(error);
        });
    }
   @wire(getRecord, { recordId: '$recordId', fields: FIELDSMAPPING })
    wiredMethod({ error, data }) {
        console.log(error);
        if (data) { 
            this.erroStr = '';
            this.showSpinner = true;
            if(data.fields.Salesforce_User__c.value != undefined && data.fields.Salesforce_User__c.value != null){
                this.erroStr = 'Salesforce User field should be blank, please contact to your administrator';
                this.isBtnDisbaled = true;
                this.duplicateEmplyeenumberFound = false;
                this.isUserAlreadyCreated = true;
                this.showCloseBtn = true;
                this.userLink = window.location.origin+"/"+ data.fields.Salesforce_User__c.value;
            }else if(data.fields.EmployeeNumber__c.value != undefined && data.fields.EmployeeNumber__c.value != null){
                this.fetchObjectRecords('User',['EmployeeNumber'], 'EmployeeNumber = \'' + data.fields.EmployeeNumber__c.value + '\' ','1');
            }
            this.fetchSObjectsRecords('UserLicense', this.licenseFieldsSet," Name = 'Salesforce Platform' OR Name = 'Chatter Free' OR Name = 'Salesforce'", '3');
            var countryName = data.fields.Country__c.value;
            if(countryName == null){
                this.fetchUserDefaultMapping([]);
            }else{
                this.fetchUserDefaultMapping([data.fields.Country__c.value]);
            }
            this.isContactFound = true;
            var isallaccesse = false;
            var dataResponse = JSON.parse(JSON.stringify(data.fields));
            var ind = 0;
            for(var key in dataResponse){
                if(dataResponse[key]['value'] == null){
                    dataResponse[key]['value'] = '';       // replacing null with blank value
                }
                if(ind == FieldsToCheck.length-1){
                    isallaccesse = true;        // sometimes this loop takes time and move to other thread so using this check we are doing further process
                }
                ind++;
            }
            if(dataResponse.pse__External_Resource__c.value != null){
                if(dataResponse.pse__External_Resource__c.value){
                    this.wdPerOrgVal = 'CWR';
                }else{
                    this.wdPerOrgVal = 'EMP';
                }
            }
            if(isallaccesse){
                this.currentContact = dataResponse;
                this.userName = this.currentContact.Email.value;
                this.userEmail = this.currentContact.Email.value;
                if(this.currentContact.EmployeeNumber__c.value.length > 8){
                    this.alias = (this.currentContact.EmployeeNumber__c.value).substring(0,8);
                }else{
                this.alias = this.currentContact.EmployeeNumber__c.value;
                }
                this.nickName = this.currentContact.EmployeeNumber__c.value;
                this.snTicket = this.currentContact.SN_Ticket__c.value;
                this.snTicketDescription = this.currentContact.SN_Ticket_Description__c.value;
                this.federationIdentifier = this.currentContact.FederationIdentifier__c.value;
                this.fetchDeliveryCountryValues();
                this.showModal = true;
            }
        } else if (error) { 
            //console.log(error);
            this.showSpinner = false;
         }
         
    }
    fetchCurrentUsersAccessFn(){
        fetchCurrentUsersAccess()
        .then(result => {
            this.isUserHasManageUserAccess = result;
            this.isuserManageMethodFinished = true;
            if(!this.isUserHasManageUserAccess){
                this.showCloseBtn = true;
            }
        })
        .catch(error => {
            console.log(error);
            this.isuserManageMethodFinished = true;
        });
    }
    saveUser(){
        this.showSpinner = true;
        const fields = {};
        var profileSection = this.template.querySelector('c-lwc_crm_profile-section');
        var picklistObj = this.template.querySelectorAll('c-lwc_crm_fetch-picklist');
        for(var i= 0;i<picklistObj.length;i++){
            var currentObj = picklistObj[i];
            if(currentObj.fieldName == 'LocaleSidKey'){
                fields[LocaleSidKey_FIELD.fieldApiName] = currentObj.selectedpicklist;
            }else  if(currentObj.fieldName == 'TimeZoneSidKey'){
                fields[TimeZoneSidKey_FIELD.fieldApiName] = currentObj.selectedpicklist;
            }else  if(currentObj.fieldName == 'LanguageLocaleKey'){
                fields[LanguageLocaleKey_FIELD.fieldApiName] = currentObj.selectedpicklist;
            }else  if(currentObj.fieldName == 'EmailEncodingKey'){
                fields[EmailEncodingKey_FIELD.fieldApiName] = currentObj.selectedpicklist;
            }
        }
        fields[profile_FIELD.fieldApiName] = profileSection.userProfileVal;
        if(profileSection.inputRoleId != null){
            fields[Role_FIELD.fieldApiName] = profileSection.inputRoleId;
        }
        fields[federationIdentifier_FIELD.fieldApiName] = this.federationIdentifier;
        fields[RelatedIQVIAInternalContact_FIELD.fieldApiName] = this.currentContact.Id.value;
        fields[FirstName_FIELD.fieldApiName] = this.currentContact.FirstName.value;
        fields[LastName_FIELD.fieldApiName] = this.currentContact.LastName.value;
        fields[Email_FIELD.fieldApiName] = this.userEmail;
        fields[UserCountry_FIELD.fieldApiName] = this.deliveryCountryMapping[this.currentContact.Country__c.value];
        fields[EmployeeNumber_FIELD.fieldApiName] = this.currentContact.EmployeeNumber__c.value;
        fields[UserName_FIELD.fieldApiName] = this.userName;
        fields[alias_FIELD.fieldApiName] = this.alias;
        fields[NickName_FIELD.fieldApiName] = this.nickName;
        fields[ChangeRequestNumber_FIELD.fieldApiName] = this.snTicket;
        fields[ChangeRequestDesc_FIELD.fieldApiName] = this.snTicketDescription; 
        if(this.currentContact.pse__External_Resource__c.value){
            fields[WDPerOrg_FIELD.fieldApiName] = 'CWR';
        }else{
            fields[WDPerOrg_FIELD.fieldApiName] = 'EMP';
        }
        fields[WDEmplStatus_FIELD.fieldApiName] = this.currentContact.pse__Employment_Status__c.value;
        if (this.currentContact.pse__Start_Date__c.value == null || this.currentContact.pse__Start_Date__c.value == "") {
            fields[WDHireDate_FIELD.fieldApiName] = null;
        } else {
            fields[WDHireDate_FIELD.fieldApiName] = this.currentContact.pse__Start_Date__c.value;
        }
        fields[WDLocationCode_FIELD.fieldApiName] = this.currentContact.Location__c.value;
        fields[WDQDeptId_FIELD.fieldApiName] = this.currentContact.WD_Q_Department_ID__c.value;
        fields[WDQDeptDescription_FIELD.fieldApiName] = this.currentContact.WD_Q_Department_Description__c.value;
        
        fields[Phone_FIELD.fieldApiName] = this.currentContact.Phone.value;
        fields[WDGrade_FIELD.fieldApiName] = this.currentContact.Job_Grade__c.value;
        if(this.currentContact.pse__Last_Date__c.value == null || this.currentContact.pse__Last_Date__c.value == ""){
            fields[LicenseExpiryDate_FIELD.fieldApiName] = null;
        }else{
            fields[LicenseExpiryDate_FIELD.fieldApiName] = this.currentContact.pse__Last_Date__c.value;
        }
        fields[MarketingUser_FIELD.fieldApiName] = this.marketingUser;
        fields[RelatedIQVIAInternalContact_FIELD.fieldApiName] = this.currentContact.Id.value;
        // validate all fields
        var isErrorFound = false;
        var requiredFields = [
            {"value":"LastName","label":"LastName"},
            {"value":"ProfileId","label":"Profile"},
            {"value":"Alias","label":"Alias"},
            {"value":"UserRoleId","label":"Role"},
            {"value":"Email","label":"Email"},
            {"value":"Username","label":"Username"},
            {"value":"User_Country__c","label":"User Country"},
            {"value":"CommunityNickname","label":"Nick Name"},
            {"value":"EmployeeNumber","label":"EmployeeNumber"},
            {"value":"LocaleSidKey","label":"Locale"},
            {"value":"TimeZoneSidKey","label":"Time Zone"},
            {"value":"LanguageLocaleKey","label":"Language"},
            {"value":"EmailEncodingKey","label":"Email Encoding"}
        ];
        var isErrorFound = false;
        for(var ind=0; ind<requiredFields.length;ind++){
            var currentRequiredObj = requiredFields[ind];
            var isBypassValidation = false;
            if(this.currentSelectedLicense == 'Chatter Free' && currentRequiredObj['value'] == 'UserRoleId' ){
                isBypassValidation = true;
            }
            if(!isBypassValidation && (fields[currentRequiredObj['value']] == null || fields[currentRequiredObj['value']] == '')){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title:  'Error',
                        message: currentRequiredObj['label'] + ' is required.',
                        variant: 'error',
                    }),
                );
                isErrorFound = true;
                this.showSpinner = false;     
                return;
            }
        }
        if(fields[LicenseExpiryDate_FIELD.fieldApiName] != '' && fields[LicenseExpiryDate_FIELD.fieldApiName] != null){
            this.dispatchEvent(
                new ShowToastEvent({ 
                    title:  'Error',
                    message: 'License Expiry Date should be blank, please contact your administrator',
                    variant: 'error',
                }),
            );
            isErrorFound = true;
            this.showSpinner = false;
            return;
        }
        if(fields[ChangeRequestNumber_FIELD.fieldApiName] == '' && fields[ChangeRequestDesc_FIELD.fieldApiName] == ''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title:  'Error',
                    message: 'There should be value in field SN Ticket or SN Ticket Description',
                    variant: 'error',
                }),
            );
            isErrorFound = true;
            this.showSpinner = false;
            return;
        }
        if(!isErrorFound){
            this.saveUserRequest(User_OBJECT.objectApiName, fields);
        }
    }
    saveUserRequest(userApi,fields){
        this.showSpinner = true;
        if(this.isduplicateUserNameFound){
            var currentUserName = fields[UserName_FIELD.fieldApiName];
            var initialKey = currentUserName.substring(0, currentUserName.indexOf('@'));
            var lastKey =  currentUserName.substring(currentUserName.indexOf('@'),currentUserName.length);
            fields[UserName_FIELD.fieldApiName] = initialKey+fields[EmployeeNumber_FIELD.fieldApiName]+lastKey;
        }
        var recordInput = { apiName: userApi, fields };
        var isFieldErrorFound = false;
        insertUserRecord({userStr : JSON.stringify([fields])})
        .then(result => {
            //console.log(result);
            if(result.usersList != undefined){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'User created',
                        variant: 'success',
                    }),
                );
                window.location = window.location.origin+"/"+ result.usersList;
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result.error,
                        variant: 'error',
                    }),
                );
            }
            this.showSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
        });
        /*createRecord(recordInput)
        .then(userRec => {
            console.log(userRec);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'User created',
                    variant: 'success',
                }),
            );
            window.location = window.location.origin+"/"+ userRec.id;
        })
        .catch(error => {
            var errorMessage = '';
            if(error.status == 400 && error.body != undefined && error.body.output != undefined && error.body.output.fieldErrors != undefined){
                if(error.body.output.fieldErrors != undefined){
                    var crrUserObj = error.body.output.fieldErrors;
                    for(var key in crrUserObj){
                        for(var i =0;i<crrUserObj[key].length;i++){
                            if(crrUserObj[key][i].errorCode == 'DUPLICATE_USERNAME'){
                                this.isduplicateUserNameFound = true;
                                isFieldErrorFound = true;
                                errorMessage = crrUserObj[key][i].message;
                                this.saveUserRequest(userApi,fields);
                                break;
                            }else if(crrUserObj[key][i].errorCode != undefined && crrUserObj[key][i].message != undefined){
                                isFieldErrorFound = true;
                                errorMessage = crrUserObj[key][i].message;
                                break;
                            }
                        }
                    }
                    
                }
            }
            console.log('---below error is occuring------');
            console.log(error);
            if(!isFieldErrorFound){
                if(error.body.output.errors[0] != undefined && error.body.output.errors[0].message != undefined){
                    errorMessage = error.body.output.errors[0].message;
                }else{
                    errorMessage = error.body.message;
                }
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: errorMessage,
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
        });
        */
    }
    handleInput(event){
        if(event.target.name == 'snTicket'){
            this.snTicket = event.target.value;
        }else if(event.target.name == 'snTicketDescription'){
            this.snTicketDescription = event.target.value;
        }else if(event.target.name == 'alias'){
            this.alias = event.target.value;
        }else if(event.target.name == 'marketingUser'){
            this.marketingUser = event.target.checked;
        }else if(event.target.name == 'userName'){
            this.userName = event.target.value;
        }else if(event.target.name == 'nickName'){
            this.nickName = event.target.value;
        }else if(event.target.name == 'email'){
            this.userEmail = (event.target.value).trim();
        }else if(event.target.name == 'federationIdentifier'){
            this.federationIdentifier = (event.target.value).trim();
        }
        this.template.querySelector("c-lwc_crm_profile-section").fetchObjectRecords();
    }

    validateFields(){
       // var newUser = 
    }
    @api handleRemainingLicense(event){

    }
    @api handleSaveBtn(event){
        this.currentSelectedLicense = event.detail.licenseName;
        this.isBtnDisbaled = event.detail.disablebtn;
        if(this.isBtnDisbaled && event.detail.message != ''){
            this.saveBtnTitle = event.detail.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: event.detail.message,
                    variant: 'error',
                }),
            );
        }else{
            this.saveBtnTitle = '';
        }
    }
    hideModal(){
        this.showModal = false;
    }
    @api closeModal(){
        this.dispatchEvent(
            new CustomEvent("closeModalHandler",({detail:{hide : true}}))
        );
    }
}