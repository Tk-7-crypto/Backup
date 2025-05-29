import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import CUSTOM_P_NAME_FIELD from '@salesforce/customPermission/Custom_COE';
import ADVANCE_P_NAME_FIELD from '@salesforce/customPermission/Advanced_Administrator';
import SLA_FCR_REVIEWED_FIELD from '@salesforce/schema/Case.SLA_FCR_Reviewed__c';
import SLA_FCR_REVIEWED_BY_FIELD from '@salesforce/schema/Case.SLA_FCR_Reviewed_By__c';
import SLA_FCR_REVIEW_ESCALATION_FIELD from '@salesforce/schema/Case.FCR_Review_Escalation__c';
import SLA_IRT_REVIEWED_FIELD from '@salesforce/schema/Case.SLA_IRT_Reviewed__c';
import SLA_IRT_REVIEWED_BY_FIELD from '@salesforce/schema/Case.SLA_IRT_Reviewed_By__c';
import saveSLAReviewer from '@salesforce/apex/CNT_CSM_CaseCSATDetails.saveSLAReviewer';
import CASE_OBJECT from '@salesforce/schema/Case';
import FCR_REVIEW_ESCALATION_FIELD from '@salesforce/schema/Case.FCR_Review_Escalation__c';
import COMMENT from '@salesforce/schema/Case.FCR_Escalation_Comment__c';
import RecordTypeName from '@salesforce/schema/Case.RecordTypeName__c';

export default class Lwc_csm_case_sla_review extends LightningElement {
    isEdit = false;
    showSpinner = true;
    @api recordId;
    @track error;
    currentUser;
    @track caseRecord;
	@track caseRecordType;
    caseRecordInDatabase;
    @track fcrReviewEscalationPicklist;
    @track elementStyleClass;
    showFcrReviewedBy = false;
	@track reqComment = false;
    @track disComment = true;
    recordTypes = ['VirtualTrialsCase','ActivityPlan','RandDCase'];
    
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseMetadata;

    @wire(getPicklistValues, { 
        recordTypeId: '$caseMetadata.data.defaultRecordTypeId', 
        fieldApiName: FCR_REVIEW_ESCALATION_FIELD 
    }) wiredFcrReviewEscalation({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
           this.showToast();
        } else if (data) {
            this.fcrReviewEscalationPicklist = [];
            for(var i = 0; i < data.values.length; i++) {
                var fcrReviewEscalation = {label: data.values[i].label, value: data.values[i].value, variant: 'neutral', key: i};
                this.fcrReviewEscalationPicklist.push(fcrReviewEscalation);
            }
            this.setComponentProperties();
        }
    }


    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SLA_FCR_REVIEWED_FIELD, SLA_FCR_REVIEWED_BY_FIELD, SLA_FCR_REVIEW_ESCALATION_FIELD, SLA_IRT_REVIEWED_FIELD, SLA_IRT_REVIEWED_BY_FIELD, COMMENT, RecordTypeName]
    }) wiredCase({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
           this.showToast();
        } else if (data) {
            var caseRecord = {Id: '', SLA_FCR_Reviewed__c: false, SLA_FCR_Reviewed_By__c: '', SLA_IRT_Reviewed__c: false, SLA_IRT_Reviewed_By__c: '', FCR_Review_Escalation__c: '', Comment__c:'', RecordTypeName__c:''};
            caseRecord.Id = this.recordId;
            caseRecord.SLA_FCR_Reviewed__c = data.fields.SLA_FCR_Reviewed__c.value;
            caseRecord.SLA_FCR_Reviewed_By__c = data.fields.SLA_FCR_Reviewed_By__c.value;
            caseRecord.FCR_Review_Escalation__c = data.fields.FCR_Review_Escalation__c.value;
            caseRecord.SLA_IRT_Reviewed__c = data.fields.SLA_IRT_Reviewed__c.value;
            caseRecord.SLA_IRT_Reviewed_By__c = data.fields.SLA_IRT_Reviewed_By__c.value;
            caseRecord.FCR_Escalation_Comment__c = data.fields.FCR_Escalation_Comment__c.value;
            caseRecord.RecordTypeName__c = data.fields.RecordTypeName__c.value;            
            this.caseRecordType = data.fields.RecordTypeName__c.value;  
            this.caseRecordInDatabase = {Id: this.recordId, SLA_FCR_Reviewed__c: data.fields.SLA_FCR_Reviewed__c.value, 
                SLA_FCR_Reviewed_By__c: data.fields.SLA_FCR_Reviewed_By__c.value, SLA_IRT_Reviewed__c: data.fields.SLA_IRT_Reviewed__c.value, 
                SLA_IRT_Reviewed_By__c: data.fields.SLA_IRT_Reviewed_By__c.value, FCR_Review_Escalation__c: data.fields.FCR_Review_Escalation__c.value,
                FCR_Escalation_Comment__c: data.fields.FCR_Escalation_Comment__c.value};
            this.caseRecord = caseRecord;
            this.setComponentProperties();
        }
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, PROFILE_NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
           this.showToast();
        } else if (data) {
            var currentUser = {userName: '', userProfile: ''};
            currentUser.userName = data.fields.Name.value;
            currentUser.userProfile = data.fields.Profile.value.fields.Name.value;
            this.currentUser = currentUser;
            this.setComponentProperties();
        }
    }

    setComponentProperties() {
        this.elementStyleClass = {irtReviewClass: 'label-hidden disable_button', fcrEscalationClass: 'disable_button'};
        if(this.caseRecord && this.currentUser && this.fcrReviewEscalationPicklist && this.caseRecord) {
            for(var i = 0; i < this.fcrReviewEscalationPicklist.length; i++) {
                this.fcrReviewEscalationPicklist[i].variant = (this.fcrReviewEscalationPicklist[i].value == this.caseRecord.FCR_Review_Escalation__c) ? 'brand' : 'neutral';
            }
            this.showEditButtonForProfile = (this.currentUser.userProfile.includes('Administrator') || 
            this.currentUser.userProfile.includes('IQVIA Salesforce Platform Support') ||
            CUSTOM_P_NAME_FIELD || ADVANCE_P_NAME_FIELD) ? true : false;
            this.showEditButton = (ADVANCE_P_NAME_FIELD || this.currentUser.userProfile.includes('Administrator') || 
            this.currentUser.userProfile.includes('IQVIA Salesforce Platform Support'))|| ((!this.caseRecord.SLA_FCR_Reviewed__c && (this.caseRecord.FCR_Review_Escalation__c == '' || this.caseRecord.FCR_Review_Escalation__c == null || 
            this.caseRecord.FCR_Review_Escalation__c == undefined)) || !this.caseRecord.SLA_IRT_Reviewed__c) ? true : false;
			this.reqComment = (this.recordTypes.includes(this.caseRecordType)) ? true : false;
            this.showSpinner = false;
        }
    }

    editReviewer() {
        if(this.currentUser.userProfile.includes('Administrator') || this.currentUser.userProfile.includes('IQVIA Salesforce Platform Support') || ADVANCE_P_NAME_FIELD ) {
            this.elementStyleClass = {irtReviewClass: 'label-hidden enable_button', fcrEscalationClass: 'enable_button'};
        } else {
            this.elementStyleClass.fcrEscalationClass = (!this.caseRecord.SLA_FCR_Reviewed__c && (this.caseRecord.FCR_Review_Escalation__c == '' || this.caseRecord.FCR_Review_Escalation__c == null || 
            this.caseRecord.FCR_Review_Escalation__c == undefined)) ? 'enable_button' : 'disable_button';
            this.elementStyleClass.irtReviewClass = this.caseRecord.SLA_IRT_Reviewed__c ? 'label-hidden disable_button' : 'label-hidden enable_button';
        }
        this.isEdit = true;
        this.disComment = false;
        this.reqComment = (this.recordTypes.includes(this.caseRecordType)) ? true : false;
    }

    saveReviewer() {
        if(this.recordTypes.includes(this.caseRecordType) && this.caseRecord.FCR_Escalation_Comment__c == undefined && this.caseRecord.FCR_Review_Escalation__c != undefined && this.caseRecord.FCR_Review_Escalation__c == 'Non-Essential Escalation'){

            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'FRC Escalation Comment is Mandatory for '+this.caseRecord.FCR_Review_Escalation__c,
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        this.showSpinner = true;
        var caseRecord = this.caseRecord;
        saveSLAReviewer({caseRecord : caseRecord})
            .then(result => {
                this.caseRecord = result;
                var toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'SLA Reviewer Updated',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                this.showSpinner = false;
                this.setComponentProperties();
            })
            .catch(error => {
                this.error = error;
                this.showToast();
                this.showSpinner = false;
        });
        this.isEdit = false;
        this.elementStyleClass = {irtReviewClass: 'label-hidden disable_button', fcrEscalationClass: 'disable_button'};
        this.reqComment = (this.recordTypes.includes(this.caseRecordType)) ? true : false;
        this.disComment = true;
        
    }

    onCheckboxChange(event) {
        var checkBoxName = event.target.name;
        if(checkBoxName === 'caseIRTReviewed') {
            this.caseRecord.SLA_IRT_Reviewed__c = event.target.checked;
        }
    } 

    cancelEdit() {
        this.isEdit = false;
        this.elementStyleClass = {irtReviewClass: 'label-hidden disable_button', fcrEscalationClass: 'disable_button'};
        this.caseRecord.SLA_IRT_Reviewed__c = this.caseRecordInDatabase.SLA_IRT_Reviewed__c;
        this.caseRecord.FCR_Review_Escalation__c = this.caseRecordInDatabase.FCR_Review_Escalation__c;
        this.caseRecord.SLA_IRT_Reviewed_By__c = this.caseRecordInDatabase.SLA_IRT_Reviewed_By__c;
        this.caseRecord.SLA_FCR_Reviewed_By__c = this.caseRecordInDatabase.SLA_FCR_Reviewed_By__c;
		this.caseRecord.FCR_Escalation_Comment__c = this.caseRecordInDatabase.FCR_Escalation_Comment__c;
        for(var i = 0; i < this.fcrReviewEscalationPicklist.length; i++) {
            this.fcrReviewEscalationPicklist[i].variant = (this.fcrReviewEscalationPicklist[i].value == this.caseRecord.FCR_Review_Escalation__c) ? 'brand' : 'neutral';
        }
        this.disComment = true;
    }

    showToast() {
        var error = this.error;
        if(error != undefined && error != null && error != '' && error.body != undefined && error.body != null && error.body != '') {
            var errorMessage = error.body.message;
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }  
    
    setEscaltionType(event) {
        var currentIndex = event.currentTarget.dataset.index;
        this.fcrReviewEscalationPicklist[currentIndex].variant = 'brand';
        for(var i = 0; i < this.fcrReviewEscalationPicklist.length; i++) {
            this.fcrReviewEscalationPicklist[i].variant = (i == currentIndex) ? 'brand' : 'neutral';
        }
        this.caseRecord.FCR_Review_Escalation__c = event.currentTarget.dataset.value;
        this.caseRecord.SLA_FCR_Reviewed_By__c = '';
        this.reqComment = (this.recordTypes.includes(this.caseRecordType)) ? true : false;
    }

    setInputValues(event) {
        var areaName = event.target.name;
        if(areaName === 'commentSLA') {
            this.caseRecord.FCR_Escalation_Comment__c = event.target.value;
        }
    }
}
