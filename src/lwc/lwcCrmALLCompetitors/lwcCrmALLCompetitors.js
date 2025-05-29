import { LightningElement, api, wire } from 'lwc';
import getAccountCompetitors from '@salesforce/apex/CNT_CRM_AllAccountCompetitors.getAccountCompetitors';

const COLUMNS = [
    {
        label: 'Account Competitor Name', fieldName: 'recordURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    {
        label: 'Account', fieldName: 'accountUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'accountName' }, target: '_blank' }
    },
    { label: 'Competitor Category', fieldName: 'Competitor_Category__c', type: 'text', sortable: true },
    {
        label: 'Competitor Name', fieldName: 'CompetitorURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'CompetitorName' }, target: '_blank' }
    },
    { label: 'Sub Offerings', fieldName: 'Sub_Offerings__c', type: 'text', sortable: true },
    { label: 'Pillars', fieldName: 'Pillars__c', type: 'text', sortable: true },
    { label: 'Contract Start Date', fieldName: 'Contract_Start_Date__c', type: 'Date', sortable: true },
    { label: 'Contract End Date', fieldName: 'Contract_End_Date__c', type: 'Date', sortable: true },
    { label: 'Active', fieldName: 'Active__c', type: 'boolean', sortable: true }
];

export default class LwcCrmAllAccountCompetitors extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    competitors = [];
    error = false;
    errorMsg = 'Unexpected error !!!';

    @wire(getAccountCompetitors, { recordId: '$recordId' })
    wireCompetitors({ data, error }) {
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
            this.competitors = tempData;
            if (this.competitors && this.competitors.length > 0) {
                this.competitors.forEach(function (competitor) {
                    try {
                        competitor['recordURL'] = '/' + competitor.Id;
                        competitor['accountName'] = competitor.hasOwnProperty('Account__r') == true ? competitor.Account__r.Name : '';
                        competitor['accountUrl'] = competitor.hasOwnProperty('Account__r') == true ? '/' + competitor.Account__c : '';
                        competitor['CompetitorName'] = competitor.hasOwnProperty('Competitor__r') == true ? competitor.Competitor__r.Name : '';
                        competitor['CompetitorURL'] = competitor.hasOwnProperty('Competitor__r') == true ? '/' + competitor.Competitor__c : '';
                    } catch (e) {
                        console.log('wireComp : ', JSON.stringify(e));
                    }
                });
            }
        } else if (error) {
            this.handleError(error);
        }
    }

    handleError(error) {
        var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
        this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
        this.error = true;
        this.competitors = [];
        console.log('hE', +JSON.stringify(error));
    }
}