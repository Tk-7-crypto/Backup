import { LightningElement,api } from 'lwc';
import  getRecords  from '@salesforce/apex/CNT_OWF_MassUpdate.getRecords';
import  updateRecords  from '@salesforce/apex/CNT_OWF_MassUpdate.updateRecords';
import getrecordtypeId from '@salesforce/apex/CNT_OWF_MassUpdate.getrecordtypeId';

export default class Lwc_owf_recordsMassUpdation extends LightningElement {
    @api columns;
    @api selectedrecords=[];
    @api currentobject;
    @api recordtypename;
    @api navigateToList;
    type;
    message;
    title;
    showToastBar = false;
    autoCloseTime = 4000;
    IsRecordsExist=false;
    fieldName;
    records;
    error;
    showSpinner=true;
    recordtypeid;

    connectedCallback(){
        this.showSpinner=true;
        this.columns=JSON.parse(JSON.stringify(this.columns));
        this.fieldName = ['Id'].concat(this.columns);
        this.selectedrecords=JSON.parse(JSON.stringify(this.selectedrecords));
        getrecordtypeId({ObjectName:this.currentobject,RecordTypeName:this.recordtypename})
        .then((result) =>{
            this.recordtypeid=result;
        })
        .catch((error)=>{
            this.error = error;
            this.showToast('error',error.body.message);
        });
        getRecords({sObjectname:this.currentobject, recordIds:(this.selectedrecords.replace(/[- \[\]]/g,'')).split(","), fieldNames:this.fieldName  })
        .then((result) => {
            if (result && result.length === 0) {
                this.showSpinner=false;
                this.showToast('error','Select at least one record and try again.');
            }
            else{
                this.title='You have selected '+ result.length +' records.';
                this.IsRecordsExist=true;
                this.records = result;
                this.error = undefined;
                this.showSpinner=false;
            }
        })
        .catch((error) => {
            this.error = error;
            this.showToast('error',error.body.message);
            this.records = undefined;
        });
    }

    handleSubmit(){
        this.showSpinner=true;
        let myInputs = this.template.querySelectorAll("lightning-input-field");
        myInputs.forEach(input => this.records.forEach(record =>
            record[input.fieldName]=input.value==null?record[input.fieldName]:input.value));
        updateRecords({sObjectType:this.records})
            .then(() => {
                this.showSpinner=false;
                this.showToast('success','Records updated');
                this.handleCancel();
            })
            .catch(error => {
                this.showSpinner=false;
                this.showToast('error',error.body.message);
            });
    }

    handleCancel(){
        this.navigateToList();
    }

    showToast(type, message) {
        this.type = type;
        this.message = message;
        this.showToastBar = true;
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }

    closeModel() {
        this.showToastBar = false;
        this.type = '';
        this.message = '';
	}

    get getIconName() {
        return 'utility:' + this.type;
    }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }

    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
}