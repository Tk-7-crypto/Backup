import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountReportNotes from '@salesforce/apex/CNT_PSA_accountReportNotesSidebar.getAccountReportNotes';
import { getRecord } from 'lightning/uiRecordApi';

//App Constants
const AGGREGATE_REPORT_FIELDS = [
    'Aggregate_Report__c.Account__c',
    'Aggregate_Report__c.Account__r.Name'
];
const LABELS = {
    Notes__c: 'Notes',
    Spreadsheet_Link__c: 'Spreadsheet Link'
};

export default class Lwc_psa_accountReportNotesSidebar extends LightningElement {
    @api recordId;
    accountId;
    accountName;
    accountReportNotes = [];
    labels = LABELS;

    get templateTitle(){
        if(typeof this.accountId == 'undefined'){
            return 'No Account';
        }
        else if(typeof this.accountName == 'undefined'){
            return 'Loading Notes...';
        }
        return 'Notes for '+this.accountName;
    }

    @wire(getRecord, { recordId: '$recordId', fields: AGGREGATE_REPORT_FIELDS})
    wiredAggregateReport(wireResult){
        let {error, data} = wireResult;
        if (typeof error != 'undefined') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Aggregate Report info.',
                    message: error.message,
                    variant: 'error'
                })
            );
        } else if (typeof data != 'undefined') {
            if(data.fields.Account__c.value != null){
                this.accountId = data.fields.Account__c.value;
                this.accountName = data.fields.Account__r.value.fields.Name.value;
            }
            
        }
    };

    @wire(getAccountReportNotes, {accountId: '$accountId'})
    wiredAccountReportNotes(wireResult){
        let {error, data} = wireResult;
        if (typeof error != 'undefined') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Account Report Notes',
                    message: error.message,
                    variant: 'error'
                })
            );
        } 
        else if (typeof data != 'undefined' && typeof this.accountName != 'undefined') {
            let newReportNotes = [];
            for(let noteId in data){
                if(data.hasOwnProperty(noteId)){
                    let noteCopy = {...data[noteId]};
                    let noteDate = new Date(noteCopy.CreatedDate);
                    noteCopy.title = this.truncate(noteCopy.Notes__c, 25,true)+' - '+noteDate.toLocaleDateString()+' '+noteDate.toLocaleTimeString();
                    newReportNotes.push(noteCopy);
                }
            }
            this.accountReportNotes = newReportNotes;
        }
    }

    truncate(source, n, useWordBoundary ){
        if (source.length <= n) { return source; }
        var subString = source.substr(0, n-1);
        return (useWordBoundary 
           ? subString.substr(0, subString.lastIndexOf(' ')) 
           : subString) + "…";
    }
}