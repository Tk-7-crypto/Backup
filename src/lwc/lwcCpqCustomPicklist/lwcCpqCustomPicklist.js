import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { loadStyle } from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/CustomDataTable';

export default class LwcCpqCustomPicklist extends LightningElement {
    @api label;
    @api name;
    @api value;
    @api placeholder;
    @api context;
    @api variant;
    @api editable;
    @api objectApiName;
    @api fieldApiName;
    options = [];
    recordTypeId;
    showPicklist = false;
    picklistValueChanged = false;

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.objectInfoData = data; 
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$fieldApiName' })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.options = data.values.map(picklistValue => {
                return {
                    label: picklistValue.label,
                    value: picklistValue.value
                };
            });
        } else if (error) {
            this.error = error;
        }
    }

    handleChange(event) {
        event.preventDefault();
        this.picklistValueChanged = true;
        this.value = event.detail.value;
        this.showPicklist = false;
        this.dispatchCustomEvent('valuechange', this.context, this.value, this.label, this.name);
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, CustomDataTableResource),
        ]).then(() => { });
        if (!this.guid) {
            this.guid = this.template.querySelector('.picklistBlock').getAttribute('id');
            this.dispatchEvent(
                new CustomEvent('itemregister', {
                    bubbles: true,
                    composed: true,
                    detail: {
                        callbacks: {
                            reset: this.reset,
                        },
                        template: this.template,
                        guid: this.guid,
                        name: 'c-lwc-cpq-custom-picklist'
                    }
                })
            );
        }
    }

    reset = (context) => {
        if (this.context !== context) {
            this.showPicklist = false;
        }
    }

    handleClick(event) {
        event.preventDefault();
        event.stopPropagation();
        this.showPicklist = true;
        this.dispatchCustomEvent('edit', this.context, this.value, this.label, this.name);
    }
    
    handleBlur(event) {
        event.preventDefault();
        this.showPicklist = false;
        if (!this.picklistValueChanged)
            this.dispatchCustomEvent('customtblur', this.context, this.value, this.label, this.name);
    }

    dispatchCustomEvent(eventName, context, value, label, name) {
        this.dispatchEvent(new CustomEvent(eventName, {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: context, value: value, label: label, name: name }
            }
        }));
    }
}