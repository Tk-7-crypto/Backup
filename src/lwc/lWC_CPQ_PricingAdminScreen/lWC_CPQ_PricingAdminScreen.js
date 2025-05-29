import { LightningElement, track, api } from 'lwc';
import getAvailableAccounts from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.getAvailableAccounts';
import getLastStoredMigrationId from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.getLastStoredMigrationId';
import getAvailableSectionsAndOptions from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.getAvailableSectionsAndOptions';
import getBundleProductSectionLabel from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.getBundleProductSectionLabel';
import getServiceLines from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.getServiceLines';
import getColumns from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.getColumns';
import getIqviaPriceMatrices from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.getIqviaPriceMatrices';
import updateIqviaPriceMatrices from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.updateIqviaPriceMatrices';
import updateLastStoredMigrationId from '@salesforce/apex/CNT_CPQ_PricingAdminScreen.updateLastStoredMigrationId';
import { ShowToastEvent  } from 'lightning/platformShowToastEvent';

export default class LWC_CPQ_PricingAdminScreen extends LightningElement {

    @api pricingTool;
    @track roundingValue = null;
    @track account = null;
    @track lastStoredMigrationId;
    @track bundleProductSectionLabel;
    @track selectedValue;
    @track section1Value;
    @track section2Value;
    @track section3Value;
    @track section4Value;
    @track serviceLine = 'All';
    @track totalIqviaPriceMatrices = 0;
    @track totalPaginatedData = 0;
    @track currentSearchKey;
    @track currentPage;
    pageSize = 20;
    totalPages;
    startIndex;
    endIndex;
    @track isLoading = false;
    @track viewConfiguration = true;
    @track disableReConfigure = true;
    @track disableSearch = true;
    @track disableContinue = true;
    @track disablePrevious = false;
    @track previousClicked = false;
    @track disableSectionOptions = true;
    @track enableAccountSection = false;
    @track disableAccountSelection = true;
    @track enableServiceLine = false;
    @track showIqviaPriceMatrices = false;
    @track enableBottomBar = false;
    @track isDataLoading = false;
    @track enablePagination = false;
    @track isFirstDisabled = false;
    @track isPreviousDisabled = false;
    @track isNextDisabled = false;
    @track isLastDisabled = false;
    @track serviceLines = [];
    @track availableSections = [];
    @track accounts = [];
    @track iqviaPriceMatrices = [];
    @track filteredData = [];
    @track paginatedData = [];
    @track clonedValues = [];
    @track draftValues = [];
    lastIqviaPriceMatrices = [];
    columns = [];
    @track selectedValues = {};
    roundingOptions = [
        { label: 'None ( Value would be rounded by 2 decimal values )', value: 'None' },
        { label: 'Round ( Ex: 10.35 would be 10 & 10.65 would be 11 )', value: 'Round' },
        { label: 'Round Up ( Ex: 10.35 would be 11 & 10.65 would be 11 )', value: 'Round Up' },
        { label: 'Round Down ( Ex: 10.35 would be 10 & 10.65 would be 10 )', value: 'Round Down' }
    ];

    connectedCallback() {
        this.disableRounding = this.pricingTool !== null ? false : true;
        this.isLoading = true;
        this.getAvailableAccounts(this.pricingTool);
        this.getAvailableSectionsAndOptions(this.pricingTool);
        this.getLastStoredMigrationId(this.pricingTool);
        this.columns = [];
        this.getColumns(this.pricingTool);
    }

    getAvailableAccounts(pricingTool) {
        getAvailableAccounts({ pricingTool: pricingTool})
        .then(result => {
            this.enableAccountSection = result.length ? true : false;
            this.accounts = [
                { label: 'Base Records', value: '' }, ...result.map(element => ({ label: element.Name, value: element.Id }))
            ];
        }).catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }

    getLastStoredMigrationId(pricingTool) {
        getLastStoredMigrationId({ pricingTool: pricingTool})
        .then(result => {
            this.lastStoredMigrationId = result;
        }).catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }
    
    getAvailableSectionsAndOptions(pricingTool) {
        getAvailableSectionsAndOptions({ pricingTool })
            .then(result => {
                this.availableSections = Object.keys(result).map((key) => {
                    return {
                        key: key,
                        label: key,
                        options: result[key].map((option) => ({ label: option.trim(), value: option.trim() }))
                    };
                });
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Unknown error',
                    variant: 'error'
                }));
            });
    }

    getBundleProductSectionLabel(pricingTool) {
        getBundleProductSectionLabel({ pricingTool: pricingTool })
        .then(result => {
            this.bundleProductSectionLabel = 'Select ' + result;
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }

    getServiceLines(pricingTool, section1Value) {
        getServiceLines({ pricingTool: pricingTool, section1Value: section1Value })
        .then(result => {
            this.serviceLines = Object.keys(result).map(key => ({
                label: key,
                value: result[key]
            }));
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }

    getColumns(pricingTool) {
        getColumns({ pricingTool: pricingTool })
        .then(result => {
            result.sort((a, b) => a.Order_Number__c - b.Order_Number__c);
            result.forEach(element => {
                this.columns.push({ label: element.Field_Label__c, fieldName: element.Field_Api_Name__c, type: element.Field_Type__c, editable: element.Is_Editable__c, cellAttributes: { alignment: 'left', class: { fieldName: 'editedClass' } }});
            });
            this.columns.push({ type: 'action', typeAttributes: { rowActions: this.getRowActions }});
        }).catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }

    getIqviaPriceMatrices(account, pricingTool, section1Value, bundleProductCode) {
        this.isLoading = false;
        getIqviaPriceMatrices({ account: account, pricingTool: pricingTool, section1Value: section1Value, bundleProductCode: bundleProductCode })
        .then(result => {
            result.sort((a, b) => {
                const nameA = a.Name ? a.Name.toLowerCase() : '';
                const nameB = b.Name ? b.Name.toLowerCase() : '';
                return nameA.localeCompare(nameB);
            });
            const lookupFieldSuffix = '__r';
            this.iqviaPriceMatrices = result.map(row => {
                Object.keys(row).forEach(key => {
                    if (key.endsWith(lookupFieldSuffix) && row[key]) {
                        row[key + '.Name'] = row[key].Name;
                    }
                });
                return {...row};
            });
            this.lastIqviaPriceMatrices = JSON.parse(JSON.stringify(this.iqviaPriceMatrices));
            this.filteredData = [...this.iqviaPriceMatrices];
            this.setPaginationValues();
            this.disableSearch = this.filteredData.length ? false : true;
            this.totalIqviaPriceMatrices = this.iqviaPriceMatrices.length;
            this.isDataLoading = false;
        }).catch(error => {
            this.isDataLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }

    updateIqviaPriceMatrices(iqviaPriceMatrices) {
        updateIqviaPriceMatrices({ updatedDetails: iqviaPriceMatrices })
        .then(result => {
            if (result === true) {
                this.draftValues = [];
                this.clonedValues = [];
                this.enableBottomBar = false;
                this.disablePrevious = true;
                this.isDataLoading = true;
                this.disableSearch = true;
                this.getIqviaPriceMatrices(this.account, this.pricingTool, this.section1Value, this.serviceLine);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Pricings updated successfully',
                    variant: 'success'
                }));
            }
        }).catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }

    updateLastStoredMigrationId(pricingTool, migrationId) {
        updateLastStoredMigrationId({ pricingTool: pricingTool, migrationId: migrationId })
        .then(result => {
            
        }).catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
    }

    handleRoundingChange(event) {
        this.roundingValue = event.target.value;
        this.disableReConfigure = false;
        this.disableSectionOptions = this.roundingValue !== null ? false : true;
        this.disableAccountSelection = this.roundingValue !== null ? false : true;
        this.evaluateDisableContinue();
    }

    handleAccountChange(event) {
        this.account = event.target.value;
        this.evaluateDisableContinue();
    }

    handleSectionChange(event) {
        if (this.roundingValue) {
            const sectionKey = event.target.dataset.key;
            this.selectedValue = event.detail.value;
            this.selectedValues[sectionKey] = this.selectedValue;
            const section = this.availableSections.find(sec => sec.key === sectionKey);
            if (section) {
                section.selectedValue = this.selectedValue;
            }
            if (sectionKey === this.availableSections[0].key) {
                this.section1Value = this.selectedValue;
            } else if (sectionKey === this.availableSections[1].key) {
                this.section2Value = this.selectedValue;
            }
            this.evaluateDisableContinue();
        }
    }

    handleServiceLineChange(event) {
        this.serviceLine = event.target.value;
        this.isLoading = true;
        this.isDataLoading = true;
        this.showIqviaPriceMatrices = true;
        this.disableSearch = true;
        this.getIqviaPriceMatrices(this.account, this.pricingTool, this.availableSections.length ? this.section1Value : null, this.serviceLine);
        this.draftValues = [];
        this.clonedValues = [];
        this.enableBottomBar = false;
        this.currentSearchKey = null;
    }

    handleReconfigure() {
        this.resetConfiguration();
        this.viewConfiguration = true;
    }

    handleContinue() {
        this.viewConfiguration = false;
        this.totalIqviaPriceMatrices = 0;
        this.isLoading = true;
        this.getBundleProductSectionLabel(this.pricingTool);
        if (this.section1Value === 'Bioscience') {
            this.enableServiceLine = true;
            this.getServiceLines(this.pricingTool, this.section1Value);
        } else {
            this.enableServiceLine = false;
            this.showIqviaPriceMatrices = true;
            this.isDataLoading = true;
            this.disableSearch = true;
            this.getIqviaPriceMatrices(this.account, this.pricingTool, this.availableSections.length ? this.section1Value : null, this.serviceLine);
        }
    }

    handlePrevious() {
        this.previousClicked = true;
        this.viewConfiguration = true;
        this.serviceLine = 'All';
        this.showIqviaPriceMatrices = false;
        this.iqviaPriceMatrices = [];
        this.filteredData = [];
        this.draftValues = [];
        this.currentSearchKey = null;
        this.enableBottomBar = false;
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'copy_row') {
            this.copyRow(event.detail.row);
        }
    }

    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        draftValues.forEach(newRow => {
            const existingRowIndex = this.draftValues.findIndex(draftRow => draftRow.Id === newRow.Id);
            if (existingRowIndex >= 0) {
                this.draftValues[existingRowIndex] = { ...this.draftValues[existingRowIndex], ...newRow };
            } else {
                this.draftValues.push(newRow);
            }
        });
        if (this.draftValues.length > 0) {
            this.draftValues = this.draftValues.map((row) => {
                let updatedRow = { ...row };
                Object.keys(updatedRow).forEach(key => {
                    if (key === 'Base_Price__c') {
                        updatedRow[key] = this.round(this.roundingValue, updatedRow[key]);
                    }
                })
                return updatedRow;
            });
            this.enableBottomBar = true;
        }
    }

    handleSave(event) {
        this.isLoading = true;
        let migrationId = '';
        let unsavedChanges = this.draftValues.length && this.clonedValues.length ? this.mergeArrays(this.clonedValues, this.draftValues) : this.draftValues.length ? this.draftValues : this.clonedValues.length ? this.clonedValues : [];
        const lookupFieldSuffix = '__r';
        if (unsavedChanges.length > 0) {
            unsavedChanges = unsavedChanges.map((row, i) => {
                let updatedRow = { ...row };
                Object.keys(updatedRow).forEach(key => {
                    if (key === 'Base_Price__c') {
                        updatedRow[key] = this.round(this.roundingValue, updatedRow[key]);
                    }
                    if (updatedRow['Id'] && updatedRow['Id'].startsWith('row-')) {
                        delete updatedRow['Id'];
                        delete updatedRow['Name'];
                        delete updatedRow['editedClass'];
                        delete updatedRow['ProductName'];
                        i = 1;
                        let numericPart = this.lastStoredMigrationId.split("-").pop();
                        let incremented = (parseInt(numericPart) + i).toString().padStart(numericPart.length, '0');
                        migrationId = this.lastStoredMigrationId.slice(0, -numericPart.length) + incremented;
                        updatedRow['Migration_Id__c'] = migrationId;
                        this.lastStoredMigrationId = migrationId;
                        i++;
                    }
                    if (key.includes(lookupFieldSuffix)) {
                        delete updatedRow[key];
                    }
                });
                return updatedRow;
            });
        }
        this.updateIqviaPriceMatrices(unsavedChanges);
        this.currentSearchKey = null;
        if (migrationId !== null && migrationId !== '') {
            this.updateLastStoredMigrationId(this.pricingTool, migrationId);
        }
    }

    handleCancel(event) {
        event.preventDefault();
        this.iqviaPriceMatrices = this.iqviaPriceMatrices.filter(row => {
            if (!row.Id.startsWith('row-')) {
                return row;
            }
        });
        this.filteredData = this.iqviaPriceMatrices;
        this.totalPages = Math.ceil(parseFloat(this.filteredData.length / this.pageSize));
        if (this.currentPage > this.totalPages) {
            this.currentPage = this.currentPage - (this.currentPage - this.totalPages);
            this.startIndex = (this.currentPage - 1) * this.pageSize;
            this.endIndex = this.startIndex + this.pageSize;
        }
        this.retainSearchedData();
        this.draftValues = [];
        this.totalIqviaPriceMatrices = this.filteredData.length;
        this.totalPaginatedData = this.paginatedData.length;
        this.enableBottomBar = false;
    }

    handleSearch(event) {
        let searchKey = event.target.value;
        this.currentSearchKey = searchKey;
        if (searchKey) {
            this.filteredData = this.iqviaPriceMatrices.filter(row => {
                return Object.values(row).some(value =>
                    String(value).toLowerCase().includes(searchKey.toLowerCase())
                );
            });
        } else {
            this.filteredData = [...this.iqviaPriceMatrices];
        }
        this.filteredData = this.filteredData.map(item => ({
            ...item,
            editedClass: item.Id.startsWith('row-') ? "slds-is-edited" : ""
        }));
        this.totalIqviaPriceMatrices = this.filteredData.length;
        this.totalPaginatedData = this.paginatedData.length;
        this.setPaginationValues();
    }

    handleFirstPage(event) {
        this.currentPage = 1;
        this.togglePaginationButtons(this.currentPage, this.totalPages);
        this.startIndex = (this.currentPage - 1) * this.pageSize;
        this.endIndex = this.startIndex + this.pageSize;
        this.paginate(this.startIndex, this.endIndex);
    }

    handlePreviousPage(event) {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.togglePaginationButtons(this.currentPage, this.totalPages);
            this.startIndex = (this.currentPage - 1) * this.pageSize;
            this.endIndex = this.startIndex + this.pageSize;
            this.paginate(this.startIndex, this.endIndex);
        }
    }

    handleNextPage(event) {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.togglePaginationButtons(this.currentPage, this.totalPages);
            this.startIndex = (this.currentPage - 1) * this.pageSize;
            this.endIndex = this.startIndex + this.pageSize;
            this.paginate(this.startIndex, this.endIndex);
        }
    }

    handleLastPage(event) {
        this.currentPage = this.totalPages;
        this.togglePaginationButtons(this.currentPage, this.totalPages);
        this.startIndex = (this.currentPage - 1) * this.pageSize;
        this.endIndex = this.startIndex + this.pageSize;
        this.paginate(this.startIndex, this.endIndex);
    }

    getRowActions(row, doneCallback) {
        const actions = [{ label: 'Copy', name: 'copy_row', iconName: 'utility:copy_to_clipboard' }];
        doneCallback(actions);
    }

    copyRow(row) {
        const newRow = { ...row };
        newRow.Id = 'row-' + String(this.iqviaPriceMatrices.length + 1);
        if (!row.Id.startsWith('row-')) {
            if (row.End_Date__c) {
                let endDate = new Date(row.End_Date__c);
                let nextDay = new Date(endDate);
                nextDay.setDate(endDate.getDate() + 1);
                newRow.Name = newRow.Name + '-copy';
                newRow.Start_Date__c = nextDay.toISOString().split('T')[0];
                newRow.End_Date__c = null;
                const rowIndex = this.iqviaPriceMatrices.findIndex(r => r.Id === row.Id);
                this.iqviaPriceMatrices.splice(rowIndex + 1, 0, newRow);
                this.clonedValues.push(newRow);
                if (this.clonedValues.length > 0) {
                    this.enableBottomBar = true;
                }
                this.retainSearchedData();
                this.totalIqviaPriceMatrices = this.filteredData.length;
                this.filteredData = this.iqviaPriceMatrices.map(item => ({
                    ...item,
                    editedClass: item.Id.startsWith('row-') ? "slds-is-edited" : ""
                }));
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Please provide End Date before copying the pricing.',
                    variant: 'error'
                }));
            }
        } else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'You cannot copy an already copied entry.',
                variant: 'error'
            }));
        }
    }

    resetConfiguration() {
        this.disableReConfigure = true;
        this.disableSectionOptions = true;
        this.disableAccountSelection = true;
        this.enableServiceLine = false;
        this.showIqviaPriceMatrices = false;
        this.totalIqviaPriceMatrices = 0;
        this.totalPaginatedData = 0;
        this.disableSearch = true;
        this.enableBottomBar = false;
        this.enablePagination = false;
        this.disableContinue = true;
        this.disablePrevious = false;
        this.previousClicked = false;
        this.roundingValue = null;
        this.account = null;
        this.serviceLine = 'All';
        this.currentSearchKey = null;
        this.availableSections = this.availableSections.map(section => ({
            ...section,
            selectedValue: ''
        }));
        this.selectedValue = null;
        this.section1Value = '';
        this.section2Value = '';
        this.serviceLines = [];
        this.iqviaPriceMatrices = [];
        this.filteredData = [];
        this.draftValues = [];
    }

    retainSearchedData() {
        if (this.currentSearchKey) {
            this.filteredData = this.iqviaPriceMatrices.filter(row => {
                return Object.values(row).some(value => 
                    String(value).toLowerCase().includes(this.currentSearchKey.toLowerCase())
                );
            });
        } else {
            this.filteredData = [...this.iqviaPriceMatrices];
        }
        this.filteredData = this.filteredData.map(item => ({
            ...item,
            editedClass: item.Id.startsWith('row-') ? "slds-is-edited" : ""
        }));
        this.paginate(this.startIndex, this.endIndex);
        this.totalPages = Math.ceil(parseFloat(this.filteredData.length / this.pageSize));
    }

    mergeArrays(arr1, arr2) {
        const mergedMap = new Map();
        const mergeObjects = (obj1, obj2) => {
            return { ...obj1, ...obj2 };
        };
        arr1.forEach(item => {
            mergedMap.set(item.Id, item);
        });
        arr2.forEach(item => {
            if (mergedMap.has(item.Id)) {
                const existingItem = mergedMap.get(item.Id);
                mergedMap.set(item.Id, mergeObjects(existingItem, item));
            } else {
                mergedMap.set(item.Id, item);
            }
        });
        return Array.from(mergedMap.values());
    }

    round(rounding, value) {
        const fixedValue = (parseFloat(value)).toFixed(2);
        let roundedValue;
        switch (rounding) {
            case 'None':
                roundedValue = parseFloat(fixedValue);
                break;
            case 'Round':
                roundedValue = Math.round(parseFloat(fixedValue));
                break;
            case 'Round Up':
                roundedValue = Math.ceil(parseFloat(fixedValue));
                break;
            case 'Round Down':
                roundedValue = Math.floor(parseFloat(fixedValue));
                break;
        }
        return roundedValue;
    }

    evaluateDisableContinue() {
        if (!this.previousClicked) {
            if (this.accounts.length > 1 && this.availableSections.length === 0) {
                this.disableContinue = (this.roundingValue !== null && this.roundingValue !== undefined) && (this.account !== null && this.account !== undefined) ? false : true;
            } else if (this.accounts.length === 1 && this.availableSections.length !== 0) {
                this.disableContinue = (this.roundingValue !== null && this.roundingValue !== undefined) && (this.selectedValue !== null && this.selectedValue !== undefined) ? false : true;
            } else if (this.accounts.length > 1 && this.availableSections.length !== 0) {
                this.disableContinue = (this.roundingValue !== null && this.roundingValue !== undefined) && (this.account !== null && this.account !== undefined) && (this.selectedValue !== null && this.selectedValue !== undefined) ? false : true;
            } else if (this.accounts.length === 1 && this.availableSections.length === 0) {
                this.disableContinue = this.roundingValue !== null && this.roundingValue !== undefined ? false : true;
            }
        }
    }

    setPaginationValues() {
        this.startIndex = 0;
        this.endIndex = this.pageSize;
        this.currentPage = 1;
        this.totalPages = Math.ceil(parseFloat(this.filteredData.length / this.pageSize));
        this.enablePagination = this.filteredData.length > this.pageSize ? true : false;
        this.togglePaginationButtons(this.currentPage, this.totalPages);
        this.paginate(this.startIndex, this.endIndex);
    }

    togglePaginationButtons(currentPage, totalPages) {
        this.isFirstDisabled = currentPage === 1 ? true : false;
        this.isPreviousDisabled = currentPage === 1 ? true : false;
        this.isNextDisabled = currentPage === totalPages ? true : false;
        this.isLastDisabled = currentPage === totalPages ? true : false;
    }

    paginate(startIndex, endIndex) {
        this.paginatedData = [...this.filteredData];
        this.paginatedData = this.paginatedData.slice(startIndex, endIndex);
        this.totalPaginatedData = this.paginatedData.length;
    }

    get recordStart() {
        return this.totalIqviaPriceMatrices != 0 ? this.startIndex + 1 : 0;
    }
    
    get recordEnd() {
        return this.currentPage == this.totalPages ? this.totalIqviaPriceMatrices : this.totalIqviaPriceMatrices != 0 ? this.endIndex : 0;
    }
}