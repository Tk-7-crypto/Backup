import { LightningElement,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import SLA_IRT_REVIEWED_BY from '@salesforce/schema/Case.SLA_IRT_Reviewed_By__c';
import SLA_FCR_REVIEWED_BY from '@salesforce/schema/Case.SLA_FCR_Reviewed_By__c';
import CSAT_REVIEWED_BY from '@salesforce/schema/Case.CSAT_Reviewed_by__c';
import RECORD_TYPE_NAME_FIELD from '@salesforce/schema/Case.RecordTypeName__c';


export default class Lwc_csm_quality_check_highlights extends LightningElement {
    @api recordId

    //case fields
    sla_IRT_ReviewedBy
    sla_FCR_ReviewedBy
    csat_ReviewedBy
    recordTypeName

    isIRTCompleted = false
    isFCRCompleted = false
    isCSATCompleted = false
    showComponent = false

    @wire(getRecord,{recordId:'$recordId',fields:[SLA_IRT_REVIEWED_BY,SLA_FCR_REVIEWED_BY,CSAT_REVIEWED_BY,RECORD_TYPE_NAME_FIELD]})
    wiredCase({error,data}){
    if(data){
        
        this.recordTypeName = data.fields.RecordTypeName__c.value;
        this.sla_IRT_ReviewedBy = data.fields.SLA_IRT_Reviewed_By__c.value
        this.sla_FCR_ReviewedBy = data.fields.SLA_FCR_Reviewed_By__c.value
        this.csat_ReviewedBy = data.fields.CSAT_Reviewed_by__c.value

        if(this.sla_IRT_ReviewedBy != null && this.sla_IRT_ReviewedBy != ''){
            this.isIRTCompleted = true
        }
        if(this.sla_FCR_ReviewedBy != null && this.sla_FCR_ReviewedBy != '' ){
            this.isFCRCompleted = true
        }
        if(this.csat_ReviewedBy != null && this.csat_ReviewedBy !=''){
            this.isCSATCompleted = true
        }
        if(this.recordTypeName == 'TechnologyCase' || this.recordTypeName == 'RandDCase' || this.recordTypeName == 'ActivityPlan' ||  this.recordTypeName == 'VirtualTrialsCase' ){
            this.showComponent = true
        }
    }else if  (error) {
            console.error('Error fetching contactId: ', error);
        }
    }

    get classIRT() { 
        return this.isIRTCompleted ? 'green-light' : '';
      }

    get classFCR() { 
        return this.isFCRCompleted ? 'green-light' : '';
    }

    get classCSAT() { 
        return this.isCSATCompleted ? 'green-light' : '';
    }
}