import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getPicklistValues from '@salesforce/apex/CNT_CSM_CaseCategorization.getPicklistValues';

export default class Lwc_csm_create_categorizaton_additional_info extends LightningElement {
    @track showModal = false;
    @track fieldsToDisplay = [];
    _subtype2;
    _assetName;
    _maintenanceType;
    _caseType;

    fieldsForRule1 = [
        { label: 'Process SRA/group table maintenance', apiName: 'Process_SRA_group_table_maintenance__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'New/existing market maintenance changes', apiName: 'New_existing_market_maintenance_changes__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'IQVIA or Client issue', apiName: 'IQVIA_or_Client_issue__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'List all Gen Codes of the reports', apiName: 'List_all_Gen_Codes_of_the_reports__c', value: '', isText: true, required: true },
        { label: 'Reports Aligned or Unaligned', apiName: 'Reports_Aligned_or_Unaligned__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'DDD back data run', apiName: 'DDD_back_data_run__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Current or a back data short proc', apiName: 'Current_or_a_back_data_short_proc__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Delivered to the customer incorrectly', apiName: 'Delivered_to_the_customer_incorrectly__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Will we miss DAP?', apiName: 'Will_we_miss_DAP__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Do You Anticipate Any Penalties?', apiName: 'Do_You_Anticipate_Any_Penalties__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Potential $ amt in penalties', apiName: 'Potential_amt_in_penalties__c', value: '', isText: true, required: true },
        { label: 'When is the Client\'s Contracted DAP', apiName: 'When_is_the_Client_s_Contracted_DAP__c', value: '', isText: true, required: true },
        { label: 'Request for an Ad-Hoc', apiName: 'Request_for_an_Ad_Hoc__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Expected Delivery Date', apiName: 'Expected_Delivery_Date__c', value: '', isDate: true, required: true },
    ];

    fieldsForRule2 = [
        { label: 'Process SRA/group table maintenance', apiName: 'Process_SRA_group_table_maintenance__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'New/existing market maintenance changes', apiName: 'New_existing_market_maintenance_changes__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'IQVIA or Client issue', apiName: 'IQVIA_or_Client_issue__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'List all Gen Codes of the reports', apiName: 'List_all_Gen_Codes_of_the_reports__c', value: '', isText: true, required: true },
        { label: 'Reports Aligned or Unaligned', apiName: 'Reports_Aligned_or_Unaligned__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'DDD back data run', apiName: 'DDD_back_data_run__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Current or a back data short proc', apiName: 'Current_or_a_back_data_short_proc__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Delivered to the customer incorrectly', apiName: 'Delivered_to_the_customer_incorrectly__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Will we miss DAP?', apiName: 'Will_we_miss_DAP__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Do You Anticipate Any Penalties?', apiName: 'Do_You_Anticipate_Any_Penalties__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Potential $ amt in penalties', apiName: 'Potential_amt_in_penalties__c', value: '', isText: true, required: true },
        { label: 'When is the Client\'s Contracted DAP', apiName: 'When_is_the_Client_s_Contracted_DAP__c', value: '', isText: true, required: true },
        { label: 'Request for an Ad-Hoc', apiName: 'Request_for_an_Ad_Hoc__c', value: '', isPicklist: true, options: [], required: true },
        { label: 'Expected Delivery Date', apiName: 'Expected_Delivery_Date__c', value: '', isDate: true, required: true },
        { label: 'Description of the error', apiName: 'Description_of_the_error__c', value: '', isText: true, required: true },
        { label: 'Root Cause Reason', apiName: 'Root_Cause_Reason__c', value: '', isText: true, required: true },
        { label: 'Actions taken to avoid reoccurrence', apiName: 'Actions_taken_to_avoid_reoccurrence__c', value: '', isText: true, required: true },
        { label: 'Who discovered the error', apiName: 'Who_discovered_the_error__c', value: '', isPicklist: true, options: [], required: true }
    ]


    @api caseId

    @api
    get subtype2() {
        return this._subtype2;
    }
    set subtype2(value) {
        this._subtype2 = value;
        this.getFieldsToDisplay();
    }

    @api
    get assetName() {
        return this._assetName;
    }
    set assetName(value) {
        this._assetName = value;
        this.getFieldsToDisplay();
    }

    @api
    get maintenanceType() {
        return this._maintenanceType;
    }
    set maintenanceType(value) {
        this._maintenanceType = value;
        this.getFieldsToDisplay();
    }

    @api
    get caseType() {
        return this._caseType;
    }
    set caseType(value) {
        this._caseType = value;
        this.getFieldsToDisplay();
    }


    get caseFields() {
        const allFields = [...this.fieldsForRule1, ...this.fieldsForRule2];
        return allFields.map(field => `Case.${field.apiName}`);
    }

    @wire(getRecord, { recordId: '$caseId', fields: '$caseFields' })
    wiredCase({ error, data }) {
        if (data) {
            this.populateFieldValues(data.fields);
        } else if (error) {
            console.error('Error retrieving case data:', error);
        }
    }

    populateFieldValues(caseFields) {
        let fieldsToUpdateForRule1 = this.fieldsForRule1;
        let fieldsToUpdateForRule2 = this.fieldsForRule2;

        const allFields = [...fieldsToUpdateForRule1, ...fieldsToUpdateForRule2];
        allFields.forEach((field) => {
            if (caseFields[field.apiName]) {
                field.value = caseFields[field.apiName].value;
            }
        });
        if (JSON.stringify(this.fieldsForRule1) !== JSON.stringify(fieldsToUpdateForRule1)) {
            this.fieldsForRule1 = [...fieldsToUpdateForRule1]
        }
        if (JSON.stringify(this.fieldsForRule2) !== JSON.stringify(fieldsToUpdateForRule2)) {
            this.fieldsForRule2 = [...fieldsToUpdateForRule2]
        }
    }

    getFieldsToDisplay() {
        this.fieldsToDisplay = [];
        if (
            (
                this.subtype2 === 'Special' &&
                this.maintenanceType !== 'Rerun' &&
                this.caseType == 'Report Maintenance' &&
                ['DDD', 'DDD MD', 'XPONENT'].includes(this.assetName)
            ) ||
            (
                this.assetName === 'XPONENT' &&
                ['NRX Recovery Tier', 'Restatement Tier'].includes(this.subtype2) &&
                this.maintenanceType !== 'Rerun' &&
                this.caseType === 'Report Maintenance'
            )
        ) {
            this.fieldsToDisplay = this.fieldsForRule1;
        } else if (
            (
                this.subtype2 === 'Special' &&
                ['DDD', 'DDD MD', 'XPONENT'].includes(this.assetName) &&
                this.caseType === 'Report Maintenance' &&
                this.maintenanceType === 'Rerun'
            ) ||
            (
                this.assetName === 'XPONENT' &&
                ['NRX Recovery Tier', 'Restatement Tier'].includes(this.subtype2) &&
                this.maintenanceType === 'Rerun' &&
                this.caseType === 'Report Maintenance'
            )
        ) {
            this.fieldsToDisplay = this.fieldsForRule2;
        }

        this.showModal = this.fieldsToDisplay.length > 0;

        this.fieldsToDisplay.forEach((field) => {
            if (field.isPicklist) {
                this.loadPicklistValues('Case', field.apiName).then((options) => {
                    field.options = options;
                });
            }
        });
    }

    async loadPicklistValues(objectName, fieldName) {
        try {
            const options = await getPicklistValues({ objectName, fieldName });
            const formattedOptions = [
                /*{ label: 'Please Specify', value: '' },*/
                ...options.map(option => ({ label: option, value: option }))
            ];
            return formattedOptions;
        } catch (error) {
            console.error(`Error for ${fieldName}: `, error);
            return [];
        }
    }

    handleSubmit() {
        let missingFields = [];
        let updatedFields = [];
        this.fieldsToDisplay.forEach((field) => {
            const inputElement = this.template.querySelector(`[data-id="${field.apiName}"]`);
            if (field.required && (!inputElement || !inputElement.value)) {
                missingFields.push(field.label);
            } else {
                updatedFields.push({ ...field, value: inputElement.value });
            }
        });

        if (missingFields.length > 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing Required Fields',
                    message: `Please fill out the following fields: ${missingFields.join(', ')}`,
                    variant: 'error'
                })
            );
        } else {
            this.fieldsToDisplay = updatedFields;
            const event = new CustomEvent('submit', {
                detail: { data: JSON.stringify(this.fieldsToDisplay) }
            });
            this.dispatchEvent(event);
            this.showModal = false;
        }
    }

    handleCancel() {
        const event = new CustomEvent('cancel');
        this.dispatchEvent(event);
        this.showModal = false;
    }

}
