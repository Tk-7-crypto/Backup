import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import pse__Proj_OBJECT from '@salesforce/schema/pse__Proj__c';
//Ceva Service Line
import serviceLineScope_FIELD from '@salesforce/schema/pse__Proj__c.Service_Line_Scope__c';
// Signal Management Service Line
import ctDatabaseLocation from '@salesforce/schema/pse__Proj__c.CT_Database_Location__c';
import setting from '@salesforce/schema/pse__Proj__c.Setting__c';
import safetyDatabaseLocation from '@salesforce/schema/pse__Proj__c.Safety_Database_Location__c';
import smtActionLog from '@salesforce/schema/pse__Proj__c.SMT_Action_Log__c';
import scope from '@salesforce/schema/pse__Proj__c.Scope__c';
import provideReason from '@salesforce/schema/pse__Proj__c.Provide_Reason__c';
import provideReasonPSSFNotInScope from '@salesforce/schema/pse__Proj__c.Provide_Reason_PSSF_not_in_Scope__c';
import provideReasonSMTCharterNotInScope from '@salesforce/schema/pse__Proj__c.Provide_Reason_SMT_Charter_not_in_Scope__c';

import serviceLineName_FIELD from '@salesforce/schema/pse__Proj__c.Service_Line__r.Name';

const fields = [serviceLineName_FIELD];
export default class Lwc_psa_scopeforserviceline extends LightningElement {
    
    @api recordId ;
    @api objectname;
    objectname = pse__Proj_OBJECT;
    serviceLineScopefield = [serviceLineScope_FIELD];
    signalManagementSectionField = [ctDatabaseLocation,setting,safetyDatabaseLocation,smtActionLog,scope,provideReason,provideReasonPSSFNotInScope,provideReasonSMTCharterNotInScope];
    
    @wire(getRecord, { recordId: '$recordId', fields })
    project;

    // check if service line scope section to be displayed or not.
    get isDisplayScopeSection() {
        let result;
        if (getFieldValue(this.project.data, serviceLineName_FIELD) ==  'CEVA') {
            result = true;
        } else {
            result = false;
        }
        return result;
    }

    // check if signal management section to be displayed or not.
    get isDisplaySignalManagementSection() {
        let result;
        if (getFieldValue(this.project.data, serviceLineName_FIELD) ==  'Signal Management') {
            result = true;
        } else {
            result = false;
        }
        return result;
    }
} 
