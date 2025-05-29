import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import getQLIs from '@salesforce/apex/CNT_CPQ_RelatedListController.getQLIs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateQLIs from '@salesforce/apex/CNT_CPQ_RelatedListController.updateQLIs';
import { refreshApex } from '@salesforce/apex';
import REVENUE_TYPE from '@salesforce/schema/Quote_Line_Item__c.Revenue_Type__c';
import COUNTRY from '@salesforce/schema/Quote_Line_Item__c.Country__c';
import SALES_TYPE from '@salesforce/schema/Quote_Line_Item__c.Sales_Type__c';
import INSTALLMENT_PERIOD from '@salesforce/schema/Quote_Line_Item__c.Installment_Period__c';
import DISCOUNT_REASON from '@salesforce/schema/Quote_Line_Item__c.Discount_Reason__c';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Quote__c.Approval_Stage__c';
import ID_FIELD from '@salesforce/schema/Quote__c.Id';
export default class LWC_CPQ_UpdateQLI extends LightningElement {
    
    @api objectApiName = 'Quote_Line_Item__c';
    recordTypeId;
    objectInfoData;
    revenueTypeOptions;
    countryOptions;
    salesTypeOptions;
    installmentPeriodOptoins;
    discountReasonOptions;
    error;
    @api recordId;
    wiredData;
    isLoading = true;
    records;
    ogData;
    totalRecords;
    pageSize = 100;
    @track pageNumber = 1;
    @track recordSize = '10';
    @track displayRecords = [];
    @track records = [];
    @track totalPages;
    @track columns;
    @track values;
    @track showSpinner;
    @track draftValues = [];
    @track ogData = [];
    @track initialRecords = [];
    @track tableData = [];
    pageNumber = 1;
    pageOffSet = 0;
    wiredData;
    searchStirng;
    updateQLI = false;
    privateChildren = {};
    @track hasData = false;
    
    hasSalesType = true;
    hasRevenueType = true; 
    hasCountry = true;
    hasStartDate = true;
    hasNumberOfInstallment = true;
    hasinstallPeriod = true;
    qliByIdMap = new Map();
    showDiscountReason = false;
    showDiscountValidation;
    idToReasonMap = new Map();
    idWithDiscountValidationMap = new Map();
    idWithHasInstallPeriodMap = new Map();
    idWithHasNumberOfInstallmentMap = new Map();
    idWithHasSalesTypeMap = new Map();
    idWithHasRevenueType = new Map();
    idWithHasCountryMap = new Map();
    idWithHasStartDateMap = new Map();
    
    columns = [{label: 'Product Name', fieldName: 'productName', type: 'string', editable: false},
    {label: 'Product Code', fieldName: 'productCode', type: 'string', editable: false},
    {label: 'List Price', fieldName: 'listPrice', type: 'currency', editable: true,
    typeAttributes: { currencyCode: 'EUR'}},
    {label: 'Discount Percent', fieldName: 'discountPercent', editable: true},
    {label: 'Discount Amount', fieldName: 'discountAmount', type: 'currency', editable: true,
    typeAttributes: { currencyCode: 'EUR'}},
    {label: 'Final Price', fieldName: 'salesPrice', type: 'currency', editable: true,
    typeAttributes: { currencyCode: 'EUR'}},
    {label: 'Installment Period', fieldName: 'installPeriod', type: 'customPicklist', editable: true,
        typeAttributes: {
            label: 'Installment Period',
            options: {fieldName: 'installmentPeriodOptions'},
            value: {fieldName: 'installPeriod'},
            isPickList: true,
            context: {fieldName: 'Id'}
        }
    },
    {label: 'Number of Installment', fieldName: 'noOfInstallment', type: 'number', editable: {fieldName: 'isNOIEditable'}, 
        cellAttributes: { alignment: 'left'}},
    {label: 'Delivery Country', fieldName: 'country', type: 'customPicklist', editable: true,
        typeAttributes: {
            label: 'Delivery Country',
            options: {fieldName: 'countryOptions'},
            value: {fieldName: 'country'},
            isPickList: true,
            context: {fieldName: 'Id'}
        }
    },
    {label: 'Revenue Type', fieldName: 'revenueType', type: 'customPicklist', editable: true,
        typeAttributes: {
            label: 'Revenue Type',
            options: {fieldName: 'revenueTypeOptions'},
            value: {fieldName: 'revenueType'},
            isPickList: true,
            context: {fieldName: 'Id'}
        }
    },
    {label: 'Sales Type', fieldName: 'salesType', type: 'customPicklist', editable: true,
        typeAttributes: {
            label: 'Sales Type',
            options: {fieldName: 'salesTypeOptions'},
            value: {fieldName: 'salesType'},
            isPickList: true,
            context: {fieldName: 'Id'}
        }
    },
    {label: 'Revenue Start', fieldName: 'startDate', type: 'date-local', editable: true}];

    connectedCallback() {

    }

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            
            this.objectInfoData = data; 
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.error = error;
            this.toast('Error', JSON.stringify(this.error), 'error');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: REVENUE_TYPE})
    wiredRevenueTypes({ error, data }) {
        if (data) {
            this.revenueTypeOptions = data.values.map(picklistValue => {
                return {
                    label: picklistValue.label,
                    value: picklistValue.value
                };
            });
        } else if (error) {
            this.error = error;
            this.toast('Error', JSON.stringify(this.error), 'error');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: SALES_TYPE})
    wiredSalesTypes({ error, data }) {
        if (data) {
            this.salesTypeOptions = data.values.map(picklistValue => {
                return {
                    label: picklistValue.label,
                    value: picklistValue.value
                };
            });
        } else if (error) {
            this.error = error;
            this.toast('Error', JSON.stringify(this.error), 'error');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: COUNTRY })
    wiredCountryTypes({ error, data }) {
        if (data) {
            this.countryOptions = data.values.map(picklistValue => {
                return {
                    label: picklistValue.label,
                    value: picklistValue.value
                };
            });
        } else if (error) {
            this.error = error;
            this.toast('Error', JSON.stringify(this.error), 'error');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: INSTALLMENT_PERIOD })
    wiredInstallmentPeriosTypes({ error, data }) {
        if (data) {
            this.installmentPeriodOptoins = data.values.map(picklistValue => {
                return {
                    label: picklistValue.label,
                    value: picklistValue.value
                };
            });
        } else if (error) {
            this.error = error;
            this.toast('Error', JSON.stringify(this.error), 'error');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: DISCOUNT_REASON })
    wiredDiscountReasonOptions({ error, data }) {
        if (data) {
            this.discountReasonOptions = data.values.map(picklistValue => {
                return {
                    label: picklistValue.label,
                    value: picklistValue.value
                };
            });
        } else if (error) {
            this.error = error;
            this.toast('Error', JSON.stringify(this.error), 'error');
        }
    }

    @wire(getQLIs, { recordId:"$recordId", discountReasonOptions:'$discountReasonOptions', countryOptions: '$countryOptions'})
    getQLIs(result) {
        this.wiredData = result;
        if (result.data) {
            if (result.data.length == 0) {
                this.hasdata = false;
                this.isLoading = false;
                return;
            }
            this.hasData = true;
            this.ogData = result.data.map(item => {
                this.qliByIdMap.set(item.Id, item);
                let revenueTypeOptions = this.revenueTypeOptions;
                let salesTypeOptions = this.salesTypeOptions;
                let countryOptions = this.countryOptions;
                let installmentPeriodOptions = this.installmentPeriodOptoins;
                return {
                    ...item,
                    revenueTypeOptions: revenueTypeOptions,
                    salesTypeOptions: salesTypeOptions,
                    countryOptions: countryOptions,
                    installmentPeriodOptions: installmentPeriodOptions,
                    discountReasonOptions: this.discountReasonOptions,
                    isNOIEditable: item.installPeriod == 'Once' && item.noOfInstallment == 1 ? false : true
                }
            })
            this.records = JSON.parse(JSON.stringify(this.ogData));
            this.columns.forEach(item => {
                if (item.fieldName == 'listPrice' || item.fieldName == 'salesPrice' || item.fieldName == 'discountAmount') {
                    item.typeAttributes.currencyCode = this.ogData[0].currencyIsoCode;
                }
            })
            var uiRecords = [];
            let size = this.records.length < Number(this.recordSize) ? this.records.length : Number(this.recordSize);
            for(var i = 0; i < size; i++) {
                uiRecords.push(JSON.parse(JSON.stringify(this.records[i])));
            }
            this.displayRecords = JSON.parse(JSON.stringify(uiRecords));
            this.totalRecords = this.records.length;
            this.totalPages = Math.ceil(this.records.length / Number(this.recordSize));
            this.isLoading = false;
            this.checkDsicountAmount(this.displayRecords);
        } else if (result.error) {
            this.toast('Error', JSON.stringify(result.error), 'error');
            this.isLoading = false;
        }
    }

    toast(title, msg, variant, mode) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: mode ? mode : 'dismissable'
        })
        this.dispatchEvent(toastEvent)
    } 

    handleCancel() {
        this.draftValues = [];
        this.records = JSON.parse(JSON.stringify(this.ogData));
        this.processRecords();
        this.checkDsicountAmount(this.displayRecords);
    }

    handleCellChange(event) {
        event.preventDefault();
        let updatedValues = [];
        let updatedValue = event.target.draftValues;
        this.displayRecords = JSON.parse(JSON.stringify(this.displayRecords));
        updatedValue.forEach(item => {
            if ((this.idToReasonMap.has(item.Id) && this.idToReasonMap.get(item.Id) != item.discountReason && item.discountReason != '') || !this.idToReasonMap.has(item.Id)) {
                this.idToReasonMap.set(item.Id, item.discountReason);
            }
            var flag = '';
            var discountReason = item.discountReason;
            this.displayRecords.forEach((detail) => {
                if (detail.Id === item.Id) {
                    flag = item;
                    if ((item.listPrice && item.listPrice != detail.listPrice) || (item.discountAmount && item.discountAmount != detail.discountAmount) || (item.discountPercent && item.discountPercent != detail.discountPercent) || (item.salesPrice && item.salesPrice != detail.salesPrice)) {
                        let listPrice = item.listPrice ? item.listPrice : detail.listPrice;
                        if (item.listPrice && item.listPrice != detail.listPrice) {
                            detail.salesPrice = detail.listPrice = item.salesPrice = item.listPrice;
                            item.discountAmount = item.discountPercent = 0;
                            detail.discountAmount = detail.discountPercent = 0;
                            item.discountReason = '';
                            flag.discountReason = '';
                            this.idToReasonMap.set(flag.Id, '');
                        } else if (item.discountAmount && item.discountAmount != detail.discountAmount) {
                            if ((item.discountAmount > 0 && detail.discountAmount < 0) || (item.discountAmount < 0 && detail.discountAmount > 0)) {
                                item.discountReason = '';
                                flag.discountReason = '';
                                this.idToReasonMap.set(flag.Id, '');
                            }
                            else {
                                item.discountReason = detail.discountReason;
                            }
                            let discountPercent = (item.discountAmount / listPrice) * 100;
                            item.discountPercent = detail.discountPercent = Math.round((discountPercent + Number.EPSILON) * 100) / 100;
                            detail.discountAmount = item.discountAmount;
                            if (listPrice <= 0) {
                                item.discountPercent = detail.discountPercent = 0;
                                detail.discountAmount = item.discountAmount = 0
                            }
                            item.salesPrice = detail.salesPrice = listPrice - item.discountAmount;
                        } else if (item.discountPercent && item.discountPercent != detail.discountPercent) {
                            if(!this.isValidDecimal(item.discountPercent)) {
                                this.toast('Error', 'Please enter a valid value.', 'error');
                            }
                            if ((item.discountPercent >= 0 && detail.discountPercent < 0) || (item.discountPercent <= 0 && detail.discountPercent > 0)) {
                                item.discountReason = '';
                                flag.discountReason = '';
                                this.idToReasonMap.set(flag.Id, '');
                            }
                            else {
                                item.discountReason = detail.discountReason;
                            }
                            item.discountAmount = detail.discountAmount = (item.discountPercent / 100) * listPrice;
                            item.salesPrice = detail.salesPrice = listPrice - detail.discountAmount;
							 if (Math.sign(item.discountPercent) != Math.sign(detail.discountPercent)) {
                                this.idToReasonMap.set(item.Id, '');
                                item.discountReason = '';
                            }												 
                            detail.discountPercent = item.discountPercent;
                        } else if (item.salesPrice && item.salesPrice != detail.salesPrice) {
                            item.discountAmount =  (listPrice - item.salesPrice);
                            if ((item.discountAmount > 0 && detail.discountAmount < 0) || (item.discountAmount < 0 && detail.discountAmount > 0)) {
                                item.discountReason = '';
                            }
                            detail.discountAmount = item.discountAmount;
                            let discountPercent = (detail.discountAmount / listPrice) * 100;
                            item.discountPercent = detail.discountPercent = Math.round((discountPercent + Number.EPSILON) * 100) / 100;
                            detail.salesPrice = item.salesPrice;
                            if (listPrice <= 0) {
                                item.discountPercent = detail.discountPercent = 0;
                                detail.discountAmount = item.discountAmount = 0
                                item.salesPrice = detail.salesPrice = listPrice - item.discountAmount;
                            }
                        }
                    } else {
                        if (item.hasOwnProperty('listPrice') && 1*item.listPrice !== 1*detail.listPrice) {
                            item.listPrice = item.salesPrice = item.discountAmount = item.discountPercent = 0;
                            detail.listPrice = detail.salesPrice = detail.discountAmount = detail.discountPercent = 0;
                        } else if ((item.hasOwnProperty('discountPercent') && 1*item.discountPercent !== 1*detail.discountPercent) || (item.hasOwnProperty('discountAmount') && 1*item.discountAmount !== 1*detail.discountAmount)) {
                            item.discountAmount = item.discountPercent = 0;
                            flag.discountReason = '';
                            this.idToReasonMap.set(flag.id, '');
                            detail.discountAmount = detail.discountPercent = 0;
                            item.salesPrice = detail.listPrice;
                        } else if (item.hasOwnProperty('salesPrice') && 1*item.salesPrice !== 1*detail.salesPrice) {
                            item.salesPrice = detail.salesPrice = 0;
                            item.discountAmount = detail.discountAmount = detail.listPrice;
                            item.discountPercent = detail.discountPercent = 100;
                        }
                    }
                    if (item.discountAmount == 0) {
                        item.discountReason = '';
                        flag.discountReason = '';
                        this.idToReasonMap.set(flag.Id, '');
                    }
                    if (item.listPrice == "") {
                        item.listPrice = item.salesPrice = item.discountPercent = item.discountAmount = 0;
                    }
                    if (item.startDate && item.startDate != detail.startDate) {
                        detail.startDate = item.startDate ? item.startDate : detail.startDate;
                    }

                    if ((item.revenueType && item.revenueType != detail.revenueType)) {
                        item.installPeriod = item.revenueType == 'Ad Hoc' && detail.installPeriod != 'Once' ? 'Once' : item.installPeriod;
                        item.installPeriod = (item.revenueType == 'Subscription' && item.installPeriod == undefined && detail.installPeriod == undefined) ? 'Monthly' : item.installPeriod;
                    }
                    if (item.installPeriod || detail.installPeriod) {
                        item.noOfInstallment = ((item.installPeriod == 'Once') || (detail.installPeriod == 'Once' && item.installPeriod == undefined)) ? '1' : item.noOfInstallment;
                        detail.isNOIEditable = item.installPeriod == 'Once' ? false : true;
                    }
                    if (item.noOfInstallment == '') {
                        delete item.noOfInstallment;
                    }
                    if (item.discountReason && item.discountReason.length > 255) {
                        item.discountReason = item.discountReason.slice(0, 255);
                    }
                    this.idWithHasSalesTypeMap.set(item.Id,!item.salesType && !detail.salesType ? false : true);
                    this.idWithHasRevenueType.set(item.Id,!item.revenueType && !detail.revenueType ? false : true);
                    this.idWithHasCountryMap.set(item.Id,!item.country && !detail.country ? false : true);
                    this.idWithHasStartDateMap.set(item.Id,item.startDate || detail.startDate ? true : false);
                    this.idWithHasNumberOfInstallmentMap .set(item.Id,(!item.noOfInstallment && !detail.noOfInstallment ? false : true));
                    this.idWithHasInstallPeriodMap.set(item.Id,!item.installPeriod && !detail.installPeriod ? false : true);
                    if (discountReason != undefined && discountReason != '' && discountReason.trim() == '') {
                        this.idWithDiscountValidationMap.set(item.Id, true);
                    }
                    else {
                        this.idWithDiscountValidationMap.set(item.Id, false)
                    }
                    if (discountReason == undefined && item.discountReason != '') {
                        item.discountReason = detail.discountReason;
                    }
                    return 0;
                }
            });
            if (flag != '') {
                if (!flag.discountReason || flag.discountReason == '') {
                    flag.discountReason = this.idToReasonMap.get(flag.Id);
                }
                updatedValues.push(flag);
            }
        })
        if (this.idWithDiscountValidationMap.size != 0) {
            const hasTrueValue = [...this.idWithDiscountValidationMap.values()].some(value => value === true);
            if (hasTrueValue) {
                this.showDiscountValidation = true;
            }
            else {
                this.showDiscountValidation = false;
            }
        }
        if (this.idWithHasInstallPeriodMap.size != 0) {
            const hasFalseValue = [...this.idWithHasInstallPeriodMap.values()].some(value => value === false);
            if (hasFalseValue) {
                this.hasinstallPeriod = false;
            }
            else {
                this.hasinstallPeriod = true;
            }
        }
        if (this.idWithHasNumberOfInstallmentMap.size != 0) {
            const hasFalseValue = [...this.idWithHasNumberOfInstallmentMap.values()].some(value => value === false);
            if (hasFalseValue) {
                this.hasNumberOfInstallment = false;
            }
            else {
                this.hasNumberOfInstallment = true;
            }
        }
        if (this.idWithHasSalesTypeMap.size != 0) {
            const hasFalseValue = [...this.idWithHasSalesTypeMap.values()].some(value => value === false);
            if (hasFalseValue) {
                this.hasSalesType = false;
            }
            else {
                this.hasSalesType = true;
            }
        }
        if (this.idWithHasRevenueType.size != 0) {
            const hasFalseValue = [...this.idWithHasRevenueType.values()].some(value => value === false);
            if (hasFalseValue) {
                this.hasRevenueType = false;
            }
            else {
                this.hasRevenueType = true;
            }
        }
        if (this.idWithHasCountryMap.size != 0) {
            const hasFalseValue = [...this.idWithHasCountryMap.values()].some(value => value === false);
            if (hasFalseValue) {
                this.hasCountry = false;
            }
            else {
                this.hasCountry = true;
            }
        }
        if (this.idWithHasStartDateMap.size != 0) {
            const hasFalseValue = [...this.idWithHasStartDateMap.values()].some(value => value === false);
            if (hasFalseValue) {
                this.hasStartDate = false;
            }
            else {
                this.hasStartDate = true;
            }
        }
        this.draftValues = [...updatedValues];
        this.checkDsicountAmount(this.displayRecords);
    }
    checkDsicountAmount(qlis) {
        let showDiscountReason = false;
        qlis.forEach(item => {
            item.isDiscountReasonEditable = false;
            if (item.discountAmount > 0 || item.discountAmount < 0) {
                showDiscountReason = true;
                item.isDiscountReasonEditable = true;
                item.isDiscount = item.discountAmount > 0 ? true : false;

                item.isSurcharge = item.discountAmount < 0 ? true : false;
            }
        });
        if (showDiscountReason && this.showDiscountReason == false) {
            this.showDiscountReason = true;
            let col = [{label: 'Discount/Surcharge Reason', fieldName: 'discountReason', type: 'customPicklist',
                            typeAttributes: {
                                label: 'Discount/Surcharge Reason',
                                options: {fieldName: 'discountReasonOptions'},
                                value: {fieldName: 'discountReason'},
                                context: {fieldName: 'Id'},
                                isPickList: {fieldName: 'isDiscount'},
                                isString: {fieldName: 'isSurcharge'}
                            }, editable: {fieldName: 'isDiscountReasonEditable'}
                        }];
            this.columns = [...this.columns,...col];
        }
        if (showDiscountReason == false && this.showDiscountReason == true) {
            this.showDiscountReason = false;
            this.columns = [...this.columns].filter(col => col.fieldName != 'discountReason');
        }
    }

    handleSave(event) {
        this.isLoading = true;
        this.draftValues = event.detail.draftValues
        let isValid = true;
        let error = '';
        let showDiscountValidation = false;
        this.draftValues.forEach(item => {
            if (item.listPrice < 0 || item.salesPrice < 0) {
                isValid = false;
                error = 'List price and Sales price should be greater than 0.';
            } else if (item.listPrice == "") {
                isValid = false;
                error = 'List price can not be null.';
            } else if (item.noOfInstallment && (item.noOfInstallment > 156 || item.noOfInstallment < 1)) {
                isValid = false;
                error = 'Please enter Number of Installments between 1 to 156.';
            }
            
            if ((item.discountReason == undefined && (this.qliByIdMap.has(item.Id) && this.qliByIdMap.get(item.Id).discountReason == undefined)) || ((item.hasOwnProperty('discountReason') && (item.discountReason == undefined || item.discountReason == '')))) {
                if (item.discountAmount || item.discountAmount == 0) {
                    if ((item.discountAmount > 0 || item.discountAmount < 0)) {
                        showDiscountValidation = true;
                    }
                } else {
                    if ((this.qliByIdMap.get(item.Id).discountAmount < 0 || this.qliByIdMap.get(item.Id).discountAmount < 0)) {
                        showDiscountValidation = true;
                    }
                }
            }

            if (item.discountAmount && item.discountAmount > 0) {
                item.isDiscount = true;
            } else if (item.discountAmount && item.discountAmount < 0) {
                item.isDiscount = false;
            } else if (this.qliByIdMap.get(item.Id).discountAmount && this.qliByIdMap.get(item.Id).discountAmount > 0) {
                item.isDiscount = true;
            } else if (this.qliByIdMap.get(item.Id).discountAmount && this.qliByIdMap.get(item.Id).discountAmount < 0) {
                item.isDiscount = false;
            }
            if (item.discountAmount == '') {
                item.discountAmount = 0;
            }
            if (item.discountPercent == '') {
                item.discountPercent = 0;
            }
        });
            
        if (!isValid){
            this.toast('Error', error, 'error');
            this.isLoading = false;
            return;
        } else if (!this.hasinstallPeriod) {
            this.toast('Error', 'Please enter the value of Installment Period.', 'error');
            this.isLoading = false;
            return;
        } else if (!this.hasNumberOfInstallment) {
            this.toast('Error', 'Please enter the value of Number of Installment.', 'error');
            this.isLoading = false;
            return;
        } else if (!this.hasCountry) {
            this.toast('Error', 'Please enter the value of Delivery Country.', 'error');
            this.isLoading = false;
            return;
        } else if (!this.hasRevenueType) {
            this.toast('Error', 'Please enter the value of Revenue Type.', 'error');
            this.isLoading = false;
            return;
        } else if (!this.hasSalesType) {
            this.toast('Error', 'Please enter the value of Sales Type.', 'error');
            this.isLoading = false;
            return;
        } else if (!this.hasStartDate) {
            this.toast('Error', 'Please enter the value of Start Date.', 'error');
            this.isLoading = false;
            return;
        } else if (showDiscountValidation|| this.showDiscountValidation) {
            this.toast('Error', 'Please enter the value of Discount/Surcharge Reason.', 'error');
            this.isLoading = false;
            return;
        }
        updateQLIs({"updatedDataJSON": JSON.stringify(this.draftValues)}).then(res => {
            if (res == 'Success') {
                this.isLoading = false;
                this.toast('Success', 'Updated Successfully.', 'success');
                this.refreshPage();
            } else {
                this.toast('Error', res, 'error');
                this.isLoading = false;
            }
        }).catch(err => {
            this.toast('Error', err, 'error');
            this.isLoading = false;
        })
    }

    showUpdateQLI() {
        window.open('/' + this.recordId, '_self');
        this.updateQLI = !this.updateQLI;
    }

    handleSearchChange(event) {
        this.pageNumber = 1;
        this.searchStirng = event.target.value;
        if (this.searchStirng.length == 0) {
            this.tableData = this.initialRecords;
        }
    }

    
    handleSearch() {
        let searchData = []
        if (this.searchStirng) {
            this.records.forEach(element => {
                if(element.productName.toLowerCase().includes(this.searchStirng.toLowerCase()) || element.productCode.toLowerCase().includes(this.searchStirng.toLowerCase())) {
                    searchData.push(element);
                }
            });
        } else {
            searchData = JSON.parse(JSON.stringify(this.ogData));
        }
        if (searchData.length > 0) {
            searchData.forEach(item => {
                this.draftValues.forEach(item2 => {
                    if (item.Id === item2.Id) {
                        if (item2.revenueType != undefined) {
                            item.revenueType = item2.revenueType;
                        }
                    }
                })
            })
            this.records = JSON.parse(JSON.stringify(searchData));
            var uiRecords = [];
            let size = searchData.length < Number(this.recordSize) ? searchData.length : Number(this.recordSize);
            for(var i = 0; i < size; i++) {
                uiRecords.push(JSON.parse(JSON.stringify(searchData[i])));
            }
            this.displayRecords = JSON.parse(JSON.stringify(uiRecords));
            this.totalRecords = searchData.length;
            this.totalPages = Math.ceil(searchData.length / Number(this.recordSize));
        } else {
            this.toast('Error', 'No Records Found.', 'error');
        }
    }

    get showBar() {
        return this.totalPages > 1; 
    }

    get getRecordSizeList() {
        let recordSizeList = [];
        recordSizeList.push({'label':'10', 'value':'10'});
        recordSizeList.push({'label':'25', 'value':'25'});
        recordSizeList.push({'label':'50', 'value':'50'});
        recordSizeList.push({'label':'100', 'value':'100'});
        return recordSizeList;
    }

    handleRecordSizeChange(event) {
        this.recordSize = event.detail.value;
        this.pageNumber = 1;
        this.totalPages = Math.ceil(this.totalRecords / Number(this.recordSize));
        this.pageOffSet = (this.pageNumber - 1 ) * this.recordSize;
        this.processRecords();
    }

    handleNavigation(event){
        let buttonName = event.target.label;
        if (buttonName == 'First') {
            this.pageNumber = 1;
        } else if(buttonName == 'Next') {
            this.pageNumber = this.pageNumber >= this.totalPages ? this.totalPages : this.pageNumber + 1;
        } else if(buttonName == 'Previous') {
            this.pageNumber = this.pageNumber > 1 ? this.pageNumber - 1 : 1;
        } else if(buttonName == 'Last') {
            this.pageNumber = this.totalPages;
        }
        this.processRecords();
    }

    handleFirst() {
        this.pageNumber = 1;
        this.pageOffSet = (this.pageNumber - 1 ) * this.recordSize;
        this.processRecords();
    }

    handleNext() {
        this.pageNumber = this.pageNumber >= this.totalPages ? this.totalPages : this.pageNumber + 1;
        this.pageOffSet = (this.pageNumber - 1 ) * this.recordSize;
        this.processRecords();
    }
    
    handlePrevious() {
        this.pageNumber = this.pageNumber > 1 ? this.pageNumber - 1 : 1;
        this.pageOffSet = (this.pageNumber - 1 ) * this.recordSize;
        this.processRecords();
    }
     
    handleLast() {
        this.pageNumber = this.totalPages;
        this.pageOffSet = (this.pageNumber - 1 ) * this.recordSize;
        this.processRecords();
    }

    get disablePreviousButtons() {
        if (this.pageNumber == 1)
            return true;
    }
 
    get disableNextButtons() {
        if (this.pageNumber == this.totalPages)
            return true;
    }
 
    get disableCombobox() {
        if (!this.records || this.records.length == 0)
            return true;
    }
 
    get recordViewMessage() {
        return 'Total Records - ' + this.totalRecords + ' | Current Page - ' + this.pageNumber + '/' + this.totalPages;
    }
 
    processRecords() {
        var uiRecords = [];
        var startLoop = ((this.pageNumber - 1) * Number(this.recordSize));
        var endLoop =  (this.pageNumber * Number(this.recordSize) >= this.totalRecords) ? this.totalRecords : this.pageNumber * Number(this.recordSize);
        for (var i = startLoop; i < endLoop; i++) {
            uiRecords.push(JSON.parse(JSON.stringify(this.records[i])));
        }
        this.displayRecords = JSON.parse(JSON.stringify(uiRecords));
    }

    refreshPage() {
        this.isLoading = true;
        this.draftValues = [];
        var temp = refreshApex(this.wiredData).then(() => {
            this.isLoading = false;
            return true;
        }).catch(err => {
            this.isLoading = false;
            return false;
        });
    }

    isValidDecimal(value) {
        const decimalRegex = /^[+-]?(\d+(\.\d*)?|\.\d+)$/;
        return decimalRegex.test(value);
    }

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            const status = data.fields.Approval_Stage__c.value;
            if (status === 'Draft') {
                this.updateStatusToInProgress();
            }
        } else if (error) {
            this.toast('Error', error, 'error');
        }
    }

    updateStatusToInProgress() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = 'In-Progress';
        const recordInput = { fields };
        updateRecord(recordInput)
            .catch((error) => {
                 this.toast('Error', error, 'error');
            });
    }
}