import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getAssetsForAccount from '@salesforce/apex/CNT_CSM_CaseCategorization.getAssetsForAccount';
import getCategorizationOptions from '@salesforce/apex/CNT_CSM_CaseCategorization.getCategorizationOptions';
import getMediaDates from '@salesforce/apex/CNT_CSM_CaseCategorization.getMediaDates';
import getReasonLateList from '@salesforce/apex/CNT_CSM_CaseCategorization.getReasonLateList';

const CASE_FIELDS = [
    'Case.RecordTypeId', 
    'Case.AccountId',
    'Case.ProductName__c', 
    'Case.SubType1__c', 
    'Case.SubType2__c', 
    'Case.SubType3__c',
    'Case.AssetId',
    'Case.Case_Type__c',
    'Case.Other_audits_and_their_frequencies__c',
    'Case.Reason_for_Late_Request_Re_Run__c',
    'Case.CreatedDate',
    'Case.DueDate__c',
    'Case.Media_Date__c',
    'Case.Media_Date_Label__c',
    'Case.Media_Download_Date__c',
    'Case.Maintenance_Type__c'
];

export default class LwcCsmCategorizationDataCreate extends NavigationMixin (LightningElement) {
    @api recordId;
    @track isLoading = true;
    @track caseRecord;
    @track assets = [];
    @track products = [];
    @track subType1Options = [];
    @track subType2Options = [];
    @track subType3Options = [];
    @track mediaDateOptions = [];
    @track reasonForLateRequestReRunOptions = [];
    @track selectedProduct;
    @track selectedSubType1;
    @track selectedSubType2;
    @track selectedSubType3;
    @track selectedMediaDate;
    @track selectedDueDate;
    @track otherAuditsAndTheirFrequenciesValue;
    @track selectedReasonForLateRequestReRun;
    @track selectedAssetId;

    @track mediaDateData = [];

    @track showAdditionalInfo = false;
    @track createAdditionalInfoData = {};

    @track isEditCategorization = false;

    @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    caseRecord;

    @wire(getAssetsForAccount, { accountId: '$caseRecord.data.fields.AccountId.value'})
    assets({ error, data }) {
        if (data) {
            this.assets = data;
            const accountId = this.caseRecord.data.fields.AccountId.value;
            const productIds = data.map(asset => asset.Product2Id);
            const recordTypeId = this.caseRecord.data.fields.RecordTypeId.value;
            const caseType = this.caseRecord.data.fields.Case_Type__c.value;
            this.getCategorizationOptions(productIds, recordTypeId, caseType);

            this.selectedSubType1 = this.caseRecord.data.fields.SubType1__c.value;
            this.selectedSubType2 = this.caseRecord.data.fields.SubType2__c.value;
            this.selectedSubType3= this.caseRecord.data.fields.SubType3__c.value;
            this.selectedMediaDate = this.caseRecord.data.fields.Media_Date__c.value;
            this.selectedDueDate = this.caseRecord.data.fields.DueDate__c.value;
            this.otherAuditsAndTheirFrequenciesValue = this.caseRecord.data.fields.Other_audits_and_their_frequencies__c.value;
            this.selectedReasonForLateRequestReRun = this.caseRecord.data.fields.Reason_for_Late_Request_Re_Run__c.value;
            this.selectedAssetId = this.caseRecord.data.fields.AssetId.value;

            const selectedAsset = this.assets.find(asset => asset.Id === this.selectedAssetId);
            if (selectedAsset) {
                this.selectedProduct = selectedAsset.Product2Id;
            }

            this.updateSubTypeOptions();
            const productName = this.caseRecord.data.fields.ProductName__c.value;
            if (productName && this.selectedSubType1 && this.selectedSubType2) {
                this.getMediaDates(productName, this.selectedSubType1, this.selectedSubType2);
            }

            this.getReasonforLateRequestReRunOptions();
            this.showAdditionalInfo = false;

            if (
                !this.selectedSubType1 || 
                !this.selectedSubType2 || 
                this.selectedSubType1 === 'Please Specify' || 
                this.selectedSubType2 === 'Please Specify' || 
                (this.showSubtype3 && (!this.selectedSubType3 || this.selectedSubType3 === 'Please Specify'))
            ) {
                this.isEditCategorization = true;
            }

        } else if (error) {
            console.error('Error fetching Assets:', error);
        }
    }

    getCategorizationOptions(assetProductIds, recordTypeId, caseType) {
        getCategorizationOptions({ assetProductIds, recordTypeId, caseType })
            .then(data => {
                if (data) {
                    this.products = JSON.parse(JSON.stringify(data.products));
                    this.products.forEach(product => {
                        product.subtypes1 = [...this.sortSubtypes(product.subtypes1)];
                        product.subtypes1.forEach(subtype1 => {
                            subtype1.subtype2 = [...this.sortSubtypes(subtype1.subtype2)];
                            subtype1.subtype2.forEach(subtype2 => {
                                subtype2.subtype3 = [...this.sortSubtypes(subtype2.subtype3)];
                            });
                        });
                    });
                    this.updateSubTypeOptions();
                }
            })
            .catch(error => {
                console.error('Error fetching categorization:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    sortSubtypes(subtypes) {
        if (!subtypes) return [];
        return [...subtypes].sort((a, b) => {
            if (a.label === "Please Specify") return -1;
            if (b.label === "Please Specify") return 1;
            return a.label.localeCompare(b.label);
        });
    }
    
    getMediaDates(productName, subType1, subType2) {
        getMediaDates({ product: productName, subtype1: subType1, subtype2: subType2 })
            .then((data) => {
                let mediaDateArray = [{ label: 'Please Specify', value: 'Please Specify' }];
                if (data.length === 0) {
                    if (subType1 === 'Weekly') {
                        const fridaysThisYear = this.getFridaysForYear(new Date().getFullYear());
                        const fridaysLastYear = this.getFridaysForYear(new Date().getFullYear() - 1);
                        mediaDateArray.push(...fridaysLastYear, ...fridaysThisYear);
                        this.mediaDateData = [...fridaysLastYear, ...fridaysThisYear].map(option => ({
                            Media_Date_Label__c: option.label,
                            Media_Date__c: option.value
                        }));
                    } else if (subType1 === 'Monthly') {
                        const monthlyDatesThisYear = this.getMonthlyDatesForYear(new Date().getFullYear());
                        const monthlyDatesLastYear = this.getMonthlyDatesForYear(new Date().getFullYear() - 1);
                        mediaDateArray.push(...monthlyDatesLastYear, ...monthlyDatesThisYear);
                        this.mediaDateData = [...monthlyDatesLastYear, ...monthlyDatesThisYear].map(option => ({
                            Media_Date_Label__c: option.label,
                            Media_Date__c: option.value
                        }));
                    }
                } else {
                    this.mediaDateData = data;
                    const sortedData = data
                        .map(option => {
                            return {
                                label: option.Media_Date_Label__c,
                                value: option.Media_Date__c,
                            };
                        })
                        .sort((a, b) => {
                            const dateA = new Date(a.value);
                            const dateB = new Date(b.value);
                            return dateB - dateA;
                        });
    
                    mediaDateArray.push(...sortedData);
                }
    
                this.mediaDateOptions = mediaDateArray;
                const mediaDate = this.caseRecord.data.fields.Media_Date__c.value;
                if (mediaDate) {
                    const matchedOption = mediaDateArray.find(option => option.value === mediaDate);
                    if (matchedOption) {
                        this.selectedMediaDate = matchedOption.value;
                    }
                }
            })
            .catch((error) => {
                console.error('Error fetching media dates:', error);
            });
    }
    
    getFridaysForYear(year) {
        const fridays = [];
        let date = new Date(year, 0, 1);
    
        while (date.getDay() !== 5) {
            date.setDate(date.getDate() + 1);
        }
    
        while (date.getFullYear() === year) {
            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const yearStr = date.getFullYear();
    
            fridays.push({
                label: `Wk.#${fridays.length + 1} - ${month}-${day}-${yearStr}`,
                value: date.toISOString().split('T')[0]
            });
    
            date.setDate(date.getDate() + 7);
        }
    
        return fridays;
    }
    
    
    getMonthlyDatesForYear(year) {
        const months = [];
        for (let month = 0; month < 12; month++) {
            let lastDay = new Date(year, month + 1, 0); 
            months.push({
                label: `${lastDay.toLocaleString('default', { month: 'short' })}. ${year}`,
                value: lastDay.toISOString().split('T')[0]
            });
        }
        return months;
    }
    
    
    
    getReasonforLateRequestReRunOptions() {
        getReasonLateList()
            .then((picklistValues) => {
                let options = [{ label: 'Please Specify', value: null }];
                
                picklistValues.forEach((p) => {
                    options.push({
                        label: p.label,
                        value: p.value,
                    });
                });
                this.reasonForLateRequestReRunOptions = options;
                if (this.selectedReasonForLateRequestReRun) {
                    this.selectedReasonForLateRequestReRun = this.selectedReasonForLateRequestReRun;
                } else {
                    this.selectedReasonForLateRequestReRun = null;
                }
            })
            .catch((error) => {
                console.error('Error retrieving reason for late request:', error);
            });
    }


    updateSubTypeOptions() {
        const selectedProduct = this.products.find(product => product.value === this.selectedProduct);
        if (selectedProduct) {
            this.subType1Options = selectedProduct.subtypes1;
            const selectedSubType1 = selectedProduct.subtypes1.find(subtype => subtype.value === this.selectedSubType1);
            if (selectedSubType1) {
                this.subType2Options = selectedSubType1.subtype2;
                const selectedSubType2 = selectedSubType1.subtype2.find(subtype => subtype.value === this.selectedSubType2);
                if (selectedSubType2) {
                    this.subType3Options = selectedSubType2.subtype3;
                }
            }
        }
    }

    getDefaultOption(options) {
        if (options && options.length) {
            const defaultOption = options.find(option => option.value === 'Please Specify');
            return defaultOption ? defaultOption.value : options[0].value;
        }
        return null;
    }
       

    handleProductChange(event) {
        this.selectedProduct = event.target.value;
    
        const selectedProduct = this.products.find(product => product.value === this.selectedProduct);
        this.subType1Options = selectedProduct ? selectedProduct.subtypes1 : [];
        
       
        this.selectedSubType1 = this.getDefaultOption(this.subType1Options);
        
        this.selectedSubType2 = null;
        this.selectedSubType3 = null;
        this.subType2Options = [];
        this.subType3Options = [];
    }
    
    handleSubType1Change(event) {
        this.selectedSubType1 = event.target.value;
    
        const selectedProduct = this.products.find(product => product.value === this.selectedProduct);
        const selectedSubType1 = selectedProduct ? selectedProduct.subtypes1.find(subtype => subtype.value === this.selectedSubType1) : null;
    
        this.subType2Options = selectedSubType1 ? selectedSubType1.subtype2 : [];
        
        this.selectedSubType2 = this.getDefaultOption(this.subType2Options);
    
        this.selectedSubType3 = null;
        this.subType3Options = [];
    }
    
    handleSubType2Change(event) {
        this.selectedSubType2 = event.target.value;
    
        const selectedProduct = this.products.find(product => product.value === this.selectedProduct);
        const selectedSubType1 = selectedProduct ? selectedProduct.subtypes1.find(subtype => subtype.value === this.selectedSubType1) : null;
        const selectedSubType2 = selectedSubType1 ? selectedSubType1.subtype2.find(subtype => subtype.value === this.selectedSubType2) : null;
    
        this.subType3Options = selectedSubType2 ? selectedSubType2.subtype3 : [];
    
        this.selectedSubType3 = this.getDefaultOption(this.subType3Options);
        
        this.selectedMediaDate = this.getDefaultOption(this.mediaDateOptions);

        const productName = this.getProductNameByValue(this.selectedProduct);
        this.getMediaDates(productName, this.selectedSubType1, this.selectedSubType2);
        this.showAdditionalInfo = true;
    }

    handleSubType3Change(event) {
        this.selectedSubType3 = event.target.value;
    }

    handleMediaDateChange(event) {
        this.selectedMediaDate = event.target.value;

        const mediaDateDetail = this.mediaDateData.find(mediaDate => mediaDate.Media_Date__c === this.selectedMediaDate);
        this.selectedDueDate = mediaDateDetail.Maint_Due_Date__c || null;
        this.selectedReasonForLateRequestReRun = null;
    }
    
    handleOtherAuditsAndTheirFrequenciesChange(event) {
        this.otherAuditsAndTheirFrequenciesValue = event.target.value;
    }

    handleReasonForLateRequestReRunChange(event) {
        this.selectedReasonForLateRequestReRun = event.target.value;
    }

    handleAdditionalInfoSubmit(event) {
        const fieldsData = event.detail;
        this.createAdditionalInfoData = fieldsData;
    }

    handleAdditionalInfoCancel(event) {
        this.selectedSubType2 = this.getDefaultOption(this.subType2Options);
    }

    handleSubmit() {
        const form = this.template.querySelector('[data-id="formCategorization"]');
        const invalidFields = [...form.querySelectorAll('lightning-combobox, lightning-input')].filter(field => {
            return field.required && !field.value;
        });
    
        if (invalidFields.length > 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing Required Fields',
                    message: `Please fill out the following fields: ${invalidFields.map(f => f.label).join(', ')}`,
                    variant: 'error'
                })
            );
            return;
        }
        const fields = {};
        fields.Id = this.recordId;
        fields.ProductName__c = this.getProductNameByValue(this.selectedProduct);
        fields.SubType1__c = this.selectedSubType1;
        fields.SubType2__c = this.selectedSubType2;
        fields.SubType3__c = this.selectedSubType3;
        const categorizationId = this.getCategorizationId(this.selectedProduct, this.selectedSubType1, this.selectedSubType2, this.selectedSubType3);
        if (categorizationId) {
            fields.Case_CategorizationId__c = categorizationId;
        }

        const mediaDateDetail = this.mediaDateData.find(mediaDate => mediaDate.Media_Date__c === this.selectedMediaDate);
        if (mediaDateDetail) {
            fields.Media_Date__c = mediaDateDetail.Media_Date__c;
            fields.Media_Date_Label__c = mediaDateDetail.Media_Date_Label__c;
            fields.DueDate__c = mediaDateDetail.Maint_Due_Date__c || null;
            fields.Media_Download_Date__c = mediaDateDetail.Download_Date__c || null;
        }
        fields.Other_audits_and_their_frequencies__c = this.otherAuditsAndTheirFrequenciesValue;
        fields.Reason_for_Late_Request_Re_Run__c = this.selectedReasonForLateRequestReRun;

        try {
            if(this.createAdditionalInfoData.data) {
                const parsedData = JSON.parse(this.createAdditionalInfoData.data);
                parsedData.forEach(item => {
                    if (item.apiName && item.value !== undefined) {
                        fields[item.apiName] = item.value;
                    }
                });
            }
        } catch (error) {
            console.error('Error parsing createAdditionalInfoData:', error);
        }

        const selectedAsset = this.assets.find(asset => asset.Product2Id === this.selectedProduct);
        if (selectedAsset) {
            fields.AssetId = selectedAsset.Id;
        }

        this.isLoading = true;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.showAdditionalInfo = false;
                this.closeModal();
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Categorization updated successfully!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                let errorMessage = 'An unknown error occurred';
                if (error.body && error.body.output && error.body.output.errors && error.body.output.errors.length > 0 && error.body.output.errors[0].errorCode === 'FIELD_CUSTOM_VALIDATION_EXCEPTION') {
                    errorMessage = error.body.output.errors[0].message;
                } else if (error.body.message) {
                    errorMessage = error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `Error updating Categorization: ${errorMessage}`,
                        variant: 'error'
                    })
                );
                console.error('Error updating case:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    getProductNameByValue(value) {
        const selectedProduct = this.products.find(product => product.value === value);
        return selectedProduct ? selectedProduct.label : null; 
    }

    getCategorizationId(selectedProduct, selectedSubType1, selectedSubType2, selectedSubType3) {
        const selectedProductData = this.products.find(product => product.value === selectedProduct);
        if (selectedProductData) {
            const selectedSubType1Data = selectedProductData.subtypes1.find(subtype => subtype.value === selectedSubType1);
            if (selectedSubType1Data) {
                const selectedSubType2Data = selectedSubType1Data.subtype2.find(subtype => subtype.value === selectedSubType2);
                if (selectedSubType2Data) {
                    if (selectedSubType3) {
                        const selectedSubType3Data = selectedSubType2Data.subtype3.find(subtype => subtype.value === selectedSubType3);
                        return selectedSubType3Data ? selectedSubType3Data.id : null;
                    }
                    return selectedSubType2Data.id;
                }
            }
        }
        return null;
    }
    

    handleEdit() {
        this.isEditCategorization = true;
    }

    closeModal() {
        this.isEditCategorization = false;
    }

    get selectedProductName() {
        return this.getProductNameByValue(this.selectedProduct);
    }

    get showSubtype3() {
        return this.caseRecord.data && this.caseRecord.data.fields.Case_Type__c.value === 'Market Definition';
    }

    get showOtherAuditsAndTheirFrequencies() {
        return this.selectedSubType3 === 'Insync' || this.selectedSubType3 === 'Shared';
    }
    
    get showReasonForLateRequestReRun() {
        if (this.caseRecord.data) {
            const dueDate = this.selectedDueDate;
            const createdDate = this.caseRecord.data.fields.CreatedDate.value;
            const caseType = this.caseRecord.data.fields.Case_Type__c.value;
            if (!dueDate || !createdDate || caseType === 'Lead Queue') {
                return false;
            }
            const dueDateOnly = new Date(new Date(dueDate).getFullYear(), new Date(dueDate).getMonth(), new Date(dueDate).getDate());
            const createdDateOnly = new Date(new Date(createdDate).getFullYear(), new Date(createdDate).getMonth(), new Date(createdDate).getDate());
            return dueDateOnly < createdDateOnly;
        }
        return false;
    }
    
    async openNewSubTabPriviewHandler(){
        let compDefination = {
            componentDef: "c:lwc_csm_dataCreatePreview",
            attributes: {
                recordId:this.recordId
            }
        }
        let compBase64 = btoa(JSON.stringify(compDefination));
        let foucedTabInfo = await this.invokeWorkspaceAPI('getFocusedTabInfo');
        if(foucedTabInfo.isSubtab){
            await this.invokeWorkspaceAPI('openSubtab', {
                parentTabId: foucedTabInfo.parentTabId,
                url: `#${compBase64}`,
                focus: true,
                icon:'utility:preview',
                label: 'Preview'
            })
        }else{
            await this.invokeWorkspaceAPI('openSubtab', {
                parentTabId: foucedTabInfo.tabId,
                url: `#${compBase64}`,
                focus: true,
                icon:'utility:preview',
                label: 'Preview'
            })
        }
    }

    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
            const apiEvent = new CustomEvent("internalapievent", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    category: "workspaceAPI",
                    methodName: methodName,
                    methodArgs: methodArgs,
                    callback: (err, response) => {
                        if (err) {
                            return reject(err);
                        } else {
                            return resolve(response);
                        }
                    }
                }
            });

            this.dispatchEvent(apiEvent);
        });
	}
}
