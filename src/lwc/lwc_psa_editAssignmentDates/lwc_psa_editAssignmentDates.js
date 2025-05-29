import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import updateAssignmentScheduleDates from '@salesforce/apex/CNT_PSA_UpdateAssignmentDate.updateAssignmentScheduleDates';


const ASSIGNMENT_DATES = [
    'pse__Assignment__c.pse__Schedule__r.pse__Start_Date__c',
    'pse__Assignment__c.pse__Schedule__r.pse__End_Date__c',
    'pse__Assignment__c.pse__Schedule__r.Id',
    'pse__Assignment__c.pse__Project__r.pse__Start_Date__c',
    'pse__Assignment__c.pse__Project__r.pse__End_Date__c'
];

export default class Lwc_psa_editAssignmentDates extends NavigationMixin (LightningElement) {
    @api assignmentId ;
    @track newStartDate = '';
    @track newEndDate = '';
    @track showPageSpinner = true;
    @track errorMsgFlag = false;
    @track errorMsg = '';
    @track projectStartDate = '';
    @track projectEndDate = '';
    @api scheduleId;


    @wire(getRecord, { recordId: '$assignmentId', fields: ASSIGNMENT_DATES })
    fillInDefaultAssignmentDates(value) {
        if(value.data){
            this.newStartDate = value.data.fields.pse__Schedule__r.value.fields.pse__Start_Date__c.value;
            this.newEndDate = value.data.fields.pse__Schedule__r.value.fields.pse__End_Date__c.value;
            this.scheduleId = value.data.fields.pse__Schedule__r.value.fields.Id.value;
            this.projectStartDate = value.data.fields.pse__Project__r.value.fields.pse__Start_Date__c.value;
            this.projectEndDate = value.data.fields.pse__Project__r.value.fields.pse__End_Date__c.value;;
            this.showPageSpinner = false;
        }
    }

    handleClick(event) {
        let buttonName = event.target.name;
        if(buttonName === 'EDIT_ASSIGNMENTS_CANCEL'){
           this.closePopup();
        } else if(buttonName === 'EDIT_ASSIGNMENTS_SAVE'){
            let startDate = this.newStartDate;
            let endDate = this.newEndDate;
            if(startDate === '' || startDate === null){
                this.errorMsgFlag = true;
                this.errorMsg = 'Please enter a valid start date.';
            } else if(endDate === '' || endDate === null) {
                this.errorMsgFlag = true;
                this.errorMsg = 'Please enter a valid end date.';
            } else if(this.newEndDate !== '' && this.newStartDate > this.newEndDate) {
                this.errorMsgFlag = true;
                this.errorMsg = 'Schedule end date cannot be before the schedule start date.';
            }else if(this.newStartDate < this.projectStartDate || this.newStartDate > this.projectEndDate){
                this.errorMsgFlag = true;
                this.errorMsg = 'Schedule start date cannot be before the project start date or after the project end date.';
            }else if(this.newEndDate > this.projectEndDate || this.newEndDate < this.projectStartDate){
                this.errorMsgFlag = true;
                this.errorMsg = 'Schedule end date cannot be after the project end date or before the project start date.';
            } else{
                this.showPageSpinner = true;
                updateAssignmentScheduleDates({scheduleId: this.scheduleId, startDate: startDate, endDate: endDate})
                .then(response => {
                    if(response === 'success'){
                        this.closePopup();
                        eval("$A.get('e.force:refreshView').fire();");
                    } else {
                        this.showPageSpinner = false;
                        this.errorMsgFlag = true;
                        this.errorMsg = response + ': ' + 'There was a problem updating the assignment\'s dates.';
                    }
                })
                .catch(error =>{
                    this.showPageSpinner = false;
                    this.errorMsgFlag = true;
                    this.errorMsg = error + ': ' + 'There was a problem updating the assignment\'s dates.';
                });
            }

        }
    }

    closePopup() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }


    newDateApplied(event){
        if(event.target.name === 'NEW_START_DATE'){
            this.newStartDate = event.detail.value;
        }
        if(event.target.name === 'NEW_END_DATE'){
            this.newEndDate = event.detail.value;
        }
    }
}