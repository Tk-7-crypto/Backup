import { LightningElement, wire, api } from 'lwc';
import fetchRecords from '@salesforce/apex/CNT_CRM_ContactToUser.fetchRecords';
export default class Lwc_crm_profileSection extends LightningElement {
    @api objectName = 'UserLicense';
    @api fieldName = 'Name';
    @api userLicenseData = [];
    @api profilesData = [];
    @api userLicenseVal ='';
    @api userProfileVal ='';
    @api recordsLimit = '200';    // pass query limit as a string
    @api recCondition = '';
    @api error;  
    @api selectedRole;
    @api inputRole = '';
    @api inputRoleId = '';
    @api rolesList = [];
    licenseNameParam = '';
    @api isNoResultFound = false;
    @api licenseDetails = [];
    @api disabledSaveBtn = false;
    @api message = '';
    @api disbledInputBox = false;
    @api isRoleRequiredInputBox = false;
    @api isRoleSet = false;
    licenseToShow = ['Salesforce Platform','Chatter Free','Salesforce'];
    @api divToHideClass = 'slds-dropdown slds-dropdown_length-5 slds-hide';
    connectedCallback(){
        //console.log('--licenseDetails------'+JSON.stringify(this.licenseDetails));
        if(this.objectName == 'UserLicense'){
            //this.recCondition = 'Status true '
        }else{
            this.recCondition = '';
        }
        this.fetchObjectRecords(this.objectName, this.fieldName, this.recCondition, this.recordsLimit);
    
    }
    @api fetchObjectRecords(objName, fieldName,condition, limit){
        fetchRecords({ objectName: objName, fieldName: fieldName, condition : condition, recordsLimit : limit })
        .then(result => {
            if(objName == 'UserLicense'){
                var licenses = [];
                for(var i =0;i<result.length;i++){
                    if(this.licenseToShow.includes(result[i].label)){
                        licenses.push(result[i]);
                    }
                }
                this.userLicenseData = licenses;
            }else if(objName == 'Profile'){
                this.profilesData = result;
            }else if(objName == 'UserRole'){
                this.isNoResultFound = false;
                this.rolesList = result;
                this.handleRolesList();
            }
        })
        .catch(error => {
            this.error = error;
        });
    }
    handleChange(event){
        console.log(event.target.name);
        if(event.target.name == 'UserLicense'){
            this.userLicenseVal = event.target.value;
            this.userProfileVal = '';
            var isLicenseCountValid = false;
            for(var i=0;i<this.userLicenseData.length;i++){
                for(var j=0;j<this.licenseDetails.length;j++){
                    if(this.userLicenseData[i].value == this.userLicenseVal && this.userLicenseData[i].label == this.licenseDetails[j].Name){
                        this.licenseNameParam = this.userLicenseData[i].label;
                        if(parseInt(this.licenseDetails[j].remainingLicense) > 0 ){
                            isLicenseCountValid = true;
                            this.disabledSaveBtn = false;
                            this.message = '';
                        }else{
                            this.disabledSaveBtn = true; 
                            this.userProfileVal = '';    
                            this.profilesData = []; 
                            this.message = 'You do not have remaining licenses for '+this.userLicenseData[i].label +' license type';                          
                        }
                    }
                }
            }
            if(this.licenseNameParam == 'Chatter Free'){
                this.disbledInputBox = true;
                this.isRoleRequiredInputBox = false;
                this.inputRole = '';
                this.inputRoleId = '';
            }else{
                this.isRoleRequiredInputBox = true;
                this.disbledInputBox = false;
            }
            this.dispatchEvent(
                new CustomEvent("handlesavebtn",({detail:{disablebtn : this.disabledSaveBtn, message:this.message, licenseName:this.licenseNameParam}}))
            );
            if(isLicenseCountValid){
                this.fetchObjectRecords('Profile','Name', 'UserLicenseId = \'' + this.userLicenseVal + '\' ', this.recordsLimit);
            }
        }else if(event.target.name == 'UserProfile'){
            this.userProfileVal = event.target.value;
        }else if(event.target.name == 'UserRole'){
            this.inputRole = '';
            this.inputRoleId = '';
            this.inputRole = event.target.value;
            this.fetchObjectRecords('UserRole','Name', ' PortalType = \'None\'  AND  Name like  \'%' + this.inputRole + '%\' ', '10');
            this.divToHideClass = 'slds-dropdown slds-dropdown_length-5';
        }
    }
    @api fetchProfileByUserLicense(){

    }
    @api fetchRoles(event){
        var currentVal = event.target.value;

    }
    @api handleRolesList(){
        if(this.rolesList.length > 0){
            this.isNoResultFound = false;
        }else{
            this.isNoResultFound = true;
        }
    }
    hideDropDownList(){
        this.divToHideClass = 'slds-dropdown slds-dropdown_length-5 slds-hide';
    }
    setRoleValue(event){
        event.preventDefault();
        this.isRoleSet = true;
        this.inputRole = event.currentTarget.dataset.rolelabel;
        this.inputRoleId = event.currentTarget.dataset.role;
        this.hideDropDownList();
    }
}