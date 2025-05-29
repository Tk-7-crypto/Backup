import { LightningElement, api, wire } from 'lwc';
import getMyCampaign from '@salesforce/apex/CNT_CRM_List_View.getMyCampaign';
const COLUMNS = [
    {
        label: 'Campaign Name', fieldName: 'recordURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'Name', type: 'text' }, target: '_blank' }
    },
    { label: 'Start Date', fieldName: 'StartDate', type: 'Date', sortable: true },
    { label: 'Channel', fieldName: 'Channel__c', type: 'text', sortable: true },
    { label: 'Responses in Campaign', fieldName: 'NumberOfResponses', type: 'text', sortable: true },
    { label: 'MQLs in campaign', fieldName: 'NoOfMQLs__c', type: 'text', sortable: true }
];

export default class LwcCrmMyCampaign extends LightningElement {

    columns = COLUMNS;
    error = false;
    filteredRecord = [];
    errorMsg = 'Unexpected error !!!';

    @wire(getMyCampaign, {})
    wireMethod({ data, error }) {
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data));
            if (tempData.length > 0) {
                tempData.forEach(function (record) {
                    record['recordURL'] = '/' + record.Id;
                });
                this.filteredRecord = JSON.parse(JSON.stringify(tempData));
            }

        } else if (error) {
            this.error = true;
            this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
            console.log('error : ' + JSON.stringify(error));
        }
    }
}