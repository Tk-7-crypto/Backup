import { LightningElement, api, track } from 'lwc';

export default class Lwc_knowledge_content extends LightningElement {
    @api recordId;
    showSpinner;
    richFields = [
        {
            name: 'Content__c',
            label: ''
        },
        {
            name: 'L1Content__c',
            label: 'L1 Content'
        },
        {
            name: 'L2L3Content__c',
            label: 'L2/L3 Content'
        },
        {
            name: 'Question__c',
            label: 'Question'
        },
        {
            name: 'Answer__c',
            label: 'Answer'
        },
        {
            name: 'L1Answer__c',
            label: 'L1 Answer'
        },
        {
            name: 'L2L3Answer__c',
            label: 'L2/L3 Answer'
        }
    ];

    @track fieldsList = this.richFields;

    handleLoad(event) {
        this.showSpinner = true;
        const record = event.detail.records;
        const fields = record[this.recordId].fields;
        this.fieldsList = this.richFields;
        setTimeout(() => {
            const tempArr = this.fieldsList;
            for (const v of tempArr) {
                let key = v.name;
                if (fields.hasOwnProperty(key) && fields[key].value != null)
                    this.addInnerHtml(`[data-id="${key}"]`, this.replaceVideoCode(fields[key].value));
                else
                    this.fieldsList = this.fieldsList.filter(e => e !== v);
            }
            this.showSpinner = false;
        }, 100);
    }

    replaceVideoCode(str) {
        return str.replaceAll(/\[\[video/g, '<video').replaceAll(/video\]\]/g, '></video>');
    }

    addInnerHtml(selector, val) {
        this.template.querySelector(selector).innerHTML = val;
    }
}