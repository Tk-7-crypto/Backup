import { LightningElement, wire, api,track } from 'lwc';
import getPicklistValues from '@salesforce/apex/CNT_CRM_ContactToUser.getPicklistValues';
export default class Lwc_crm_fetchPicklist extends LightningElement {
    @api objectName;
    @api fieldName;
    @api recordTypeId = '';
    @api options;
    @api apiFieldName = '';
    @api fieldLabel='';
    @api selectedpicklist = '';
    @api objectInfo;
    @api isNeedToDisabled = false;
    @api defaultValue = '';
    @api isRequired = false;
    @api setDefaultValue = '';
    @wire(getPicklistValues, { objName: '$objectName', fieldName: '$fieldName' })
    PicklistValues({ error, data }) {
        if (data) {  
            // Map picklist values
            this.options = data;
            console.log(this.setDefaultValue);
            this.selectedpicklist = this.setDefaultValue;
        } else if (error) {
            // Handle error
            //console.log(JSON.stringify(error));
        }
    }
    handleChange(event) {
        this.selectedpicklist = event.detail.value;
    }

}