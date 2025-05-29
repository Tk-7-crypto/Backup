import { LightningElement, track , wire, api } from 'lwc';
import getPricingDetails from '@salesforce/apex/CNT_CPQ_PricingAdminController.getPricingDetails';
import { ShowToastEvent  } from 'lightning/platformShowToastEvent';
import savePriceMatrixEntries from '@salesforce/apex/CNT_CPQ_PricingAdminController.savePriceMatrixEntries';
import savePartialPricing from '@salesforce/apex/CNT_CPQ_PricingAdminController.savePartialPricing';
import getBatchJobResult from '@salesforce/apex/CNT_CPQ_PricingAdminController.getBatchJobResult';
import getInactivePriceMatrixEntries from '@salesforce/apex/CNT_CPQ_PricingAdminController.getInactivePriceMatrixEntries';
import updatePriceMatrixEntries from '@salesforce/apex/CNT_CPQ_PricingAdminController.updatePriceMatrixEntries';
import activatePriceBookEntries from '@salesforce/apex/CNT_CPQ_PricingAdminController.activatePriceBookEntries';
import getAvailablePricingTool from '@salesforce/apex/CNT_CPQ_PricingAdminController.getAvailablePricingTool';
import processBatchItems from '@salesforce/apex/CNT_CPQ_PricingAdminController.processBatchItems';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT_ATTRIBUTE_VALUE from '@salesforce/schema/Apttus_Config2__ProductAttributeValue__c';
import updateCustomSetting from '@salesforce/apex/CNT_CPQ_PricingAdminController.updateBatchJobIdInCPQAdminSettings';

const columns2 = [
    {
        label: 'Product Name',
        fieldName: 'CPQ_ProductName__c',
        type: 'text',
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Sub Product Name',
        fieldName: 'Product_Name__c',
        type: 'text',
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Country',
        fieldName: 'CountryLabel',
        type: 'text',
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Data Delivery Frequency',
        fieldName: 'Data_Delivery_Frequency__c',
        type: 'text',
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Previous Partial Price',
        fieldName: 'Previous_Partial_Price',
        type: 'currency',
        typeAttributes: { currencyCode: 'CHF' },
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Percentage Difference',
        fieldName: 'percentageChange1',
        type: 'percent',
        typeAttributes: { minimumFractionDigits: '2', maximumFractionDigits: '2' },
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'New Partial Price',
        fieldName: 'Final_Price__c',
        type: 'currency',
        editable: true,
        typeAttributes: { currencyCode: 'CHF' },
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Previous Partial Price with molecule',
        fieldName: 'Previous_Partial_Price_with_molecule',
        type: 'currency',
        typeAttributes: { currencyCode: 'CHF' },
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Percentage Difference',
        fieldName: 'percentageChange2',
        type: 'percent',
        typeAttributes: { minimumFractionDigits: '2', maximumFractionDigits: '2' },
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'New Partial Price with molecule',
        fieldName: 'Final_Price_with_molecule__c',
        type: 'currency',
        editable: true,
        typeAttributes: { currencyCode: 'CHF' },
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Reviewed',
        fieldName: 'reviewCheck',
        type: 'boolean',
        sortable: "true",
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Review',
        type: 'button-icon',
        typeAttributes: {
            title: 'Review',
            name: 'Review',
            iconName: 'utility:check',
            iconClass: 'slds-size_small',
            variant: 'brand'
        },
        cellAttributes: { alignment: 'left' }
    }
];
export default class LWC_CPQ_PricingAdmin extends LightningElement {
    @track countryOptions;
    @track showSpinner = true;
    @track showNewYearPricingSection = false;
    @track showUpdateExistingYearPricingSection = false;
    @track showPercentageInput = false;
    @track showPME = false;
    @track showPartialPricing = false;
    @track showUpdatePME = false;
    @track showUpdatePartial = false;
    @track showPricingOptions = true;
    @track showPricingCategory = false;
    @track isSearched = false;
    @track showPercentageInputWithButton = false;
    @track pricingObj;
    @track pricingYearWithCountryPMEMap = new Map();
    @track partialPricingWithYearandCountryMap = new Map();
    @track existingYearOptions;
    @track newYearOptions;
    @track existingYearPMEOptions;
    @track newYearPMEOptions;
    @track existingYearPartialOptions;
    @track newYearPartialOptions;
    @track pmeListToInsert = [];
    @track pmeListToUpdate = [];
    @track initialUpdateRecords = [];
    @track initialPartialRecords = [];
    @track initialUpdatePartialRecords = [];
    @track sortBy;
    @track sortDirection;
    @track partialSortBy;
    @track partialSortDirection;
    @track showData = [];
    @track showPartialData = [];
    @track showUpdatePartialData = [];
    @track selectedExistingYear;
    @track selectedNewYear;
    @track selectedPricingOption;
    @track selectedCategory;
    @track searchedRecords = [];
    @track firstJobID;
    @track progress = 0;
    selectedPricingTool = 'AMESA';
    reviewButtonTitle = [];
    processedItems = 0;
    currentReviewCountry = '';

    searchedKey;
    searchedCountryKey;
    showCountrySearchBox = false;
	percentChangeForUpdate;
    showProgessBar = false;
    showReviewChanges = false;
    nonActivePricingYears;
    selectedFullExistingYear;
    disableExistingYearPicklist = false;
    disableNewYearPicklist = false;
    showCreatePriceButton = false;
    showReviewAll = false;
    searchedPartialKey;
    groupAttribute;
    groupAttributeLabelList = [];
    attributeLabelMap = new Map();
    attributeFieldDetails = new Map();
    showAttributeList = []
    columns = [];
    cols = [];
    cols2 = [];
    columns2 = columns2;
    saveDraftValues = [];
    savePartialDraftValues = [];
    attributeToPercentInput = new Map();
    attributeToPercentMap = [];
    showActivatePriceListButton = false;
    disablePercentageInput = false;
    showPicklist = false;
    showRadioDisabled = false;
    hasPartialPricing = false;
    showInProgressBatchStatus = false;
    isPreviousBatchResult = true;
    showSuccess = false;
    showPricingOptionDisabled = false;
    roundingOptions = [];
    selectedRound = '';
    disableUpdateButton = true;
    disableSearchButton = true;
    disableUpdateSearchButton = true;
    batchClasses = ['BCH_CPQ_CreatePriceListItem', 'BCH_CPQ_CreatePriceMatrix', 'BCH_CPQ_CreatePriceMatrixEntry'];
    column1 = [
        {
            label: 'Product Name',
            fieldName: 'Product_Name',
            type: 'text',
            sortable: "true",
            cellAttributes: { alignment: 'left' }
        }
    ];
    column2 = [
        {
            label: 'Previous Amount',
            fieldName: 'Previous_Amount',
            type: 'currency',
            typeAttributes: { currencyCode: 'CHF' },
            sortable: "true",
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Percentage Difference',
            fieldName: 'percentageChange',
            type: 'percent',
            typeAttributes: { minimumFractionDigits: '2', maximumFractionDigits: '2' },
            sortable: "true",
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'New Amount',
            fieldName: 'Apttus_Config2__AdjustmentAmount__c',
            type: 'currency',
            editable: true,
            typeAttributes: { currencyCode: 'CHF' },
            sortable: "true",
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Reviewed',
            fieldName: 'reviewCheck',
            type: 'boolean',
            sortable: "true",
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Review',
            type: 'button-icon',
            typeAttributes: {
                title: 'Review',
                name: 'Review',
                iconName: 'utility:check',
                iconClass: 'slds-size_small',
                variant: 'brand'
            },
            cellAttributes: { alignment: 'left' }
        }
    ];
    countryToLocalCurrencyMap = new Map();
    currencyIndex = -1;
    columnsLength = this.column1.length + this.column2.length;
    @track picklist = [];
    defaultCurrency = 'USD';
    groupAttributeObj = [];
    @track showRespctiveChangesBtn = true;
    @track reviewChangeBtnLabel = 'Review Changes';
    @track showReviewAllforNew = false;
    contriesReviewed = new Map();
    currentAttribute = '';
    partialRecords = new Map();
    percentageChange;
    previousIdToPLI = new Map();
    previousIdToPM = new Map();
    currentState = 1;
    chunks = [];
    pmString;
    attributeToPercentString;
    chunkSize = 5000;
    idToPLIMap = new Map();
    idToPMMap = new Map();
    idToPMEMap = new Map();
    oldPricingSetup = true;
    toolToObject = new Map();

    connectedCallback() {
        getAvailablePricingTool()
            .then(result => {
                if (result != '') {
                    let tempRoundingOption = [
                        { label: 'None ( Value would be rounded by 2 decimal values )', value: 'none' },
                        { label: 'Round ( Ex: 10.35 would be 10 & 10.65 would be 11 )', value: 'round' },
                        { label: 'Round Up ( Ex: 10.35 would be 11 & 10.65 would be 11 )', value: 'roundUp' },
                        { label: 'Round Down ( Ex: 10.35 would be 10 & 10.65 would be 10 )', value: 'roundDown' }
                    ]
                    this.roundingOptions = tempRoundingOption;
                    var pricingTools = [];
                    
                    for (var key in result) {
                        this.toolToObject.set(key, result[key]);
                        pricingTools.push(key);
                    }
                    if (pricingTools.length > 1) {
                        this.showPicklist = true;
                        pricingTools.forEach(ele => {
                            this.picklist.push({ label: ele, value: ele });
                        })
                        this.showSpinner = false;
                    } else if (pricingTools.length == 1) {
                        this.selectedPricingTool = pricingTools[0];
                        this.showSpinner = false;
                        if (this.toolToObject.get(this.selectedPricingTool) == 'Quote') {
                            this.oldPricingSetup = false;
                        } else {
                            this.handleSelectPricingTool();
                        }
                    } else {
                        this.showToast("Error", "You do not have permission to access pricing data.", "error", "dismissable");;
                    }
                }
            }).catch(error => {
                var err = error.body.message;
                this.showToast("Error", err, "error", "Failed to Load for the Current User");
            });
    }
    handleSelectPricingTool() {
        if (this.toolToObject.get(this.selectedPricingTool) == 'Quote') {
            this.oldPricingSetup = false;
        } else {
            this.showRadioDisabled = true;
            this.showSpinner = !this.showSpinner;

            getPricingDetails({ pricingTool: this.selectedPricingTool })
            .then(result => {
                this.getBatchStatus();

                this.pricingObj = result;
                this.hasPartialPricing = result.isPartialPricingRequired;
                if (result) {
                    var i = 1;
                    this.columns = [];
                    this.columns = this.columns.concat(this.column1);
                    if (this.columns || this.columnsLength) {
                        if (this.columns.length < this.columnsLength + 1) {
                            for (var key in result.attributeMap) {
                                if (key != 'Country') {   
                                    this.columns.splice(i++, 0,
                                        {
                                            label: key,
                                            fieldName: result.attributeMap[key],
                                            type: 'text',
                                            sortable: "true",
                                            cellAttributes: { alignment: 'left' }
                                        }
                                    );
                                }
                            }
                        }
                    }
                    this.columns = this.columns.concat(this.column2);
                    if (this.columns[i].typeAttributes) {
                        if(this.columns[i].typeAttributes.currencyCode){
                            this.currencyIndex = i;
                        }
                    }
                    this.cols2 = [...this.columns];
                    for (var key in result.yearWithCountryPMEMap) {
                        this.pricingYearWithCountryPMEMap.set(key, result.yearWithCountryPMEMap[key]);
                    }
                    for (var key in result.yearWithCountryPartialPricingMap) {
                        this.partialPricingWithYearandCountryMap.set(key, result.yearWithCountryPartialPricingMap[key]);
                    }
                    for (var key in result.attributeLabelMap) {
                        this.attributeLabelMap.set(key, result.attributeLabelMap[key]);
                    }
                    if (result.countryToLocalCurrencyMap) {
                        for (var key in result.countryToLocalCurrencyMap) {
                            this.countryToLocalCurrencyMap.set(key, result.countryToLocalCurrencyMap[key]);
                        }
                    }
                    this.attributeLabelMap.forEach((key, value) => {
                        this.groupAttributeObj.push({country : key, currency : (this.countryToLocalCurrencyMap.get(value) ? this.countryToLocalCurrencyMap.get(value) : this.defaultCurrency), msg : '', percentageChange : 0});
                        this.attributeToPercentInput.set(key, 0);
                    });
                    if (result.countryToPercentMap != undefined) {
                        for (var key in result.countryToPercentMap) {
                            this.attributeToPercentMap.push({ value: result.countryToPercentMap[key], key: result.attributeLabelMap[key], msg: (result.reviewedStatusMap[key] ? 'Review Completed' : ''), currency: (this.countryToLocalCurrencyMap.get(key) ? this.countryToLocalCurrencyMap.get(key) : this.defaultCurrency)});
                        }
                    }
                    if (result.nonActivePricingYears != undefined && result.nonActivePricingYears.length > 0) {
                        this.nonActivePricingYears = result.nonActivePricingYears[0];
                        this.selectedFullExistingYear = result.existingFullYears;
                    }
                    this.showAttributeList = result.attributeList;
                    this.groupAttribute = this.attributeFieldDetails.get(result.groupAttributeFieldName);
                    let existingOptions = [];
                    let existingPartialOptions = [];
                    let newOptions = [];
                    let newPartialOptions = [];
                    var lastYear;
                    var lastYearPartial;
                    result.existingPricingYears.forEach(item => {
                        existingOptions.push({ label: item.toString(), value: item.toString() });
                        lastYear = item;

                    })
                    this.existingYearPMEOptions = existingOptions;
                    result.existingPartialPricingYears.forEach(item => {
                        existingPartialOptions.push({ label: item.toString(), value: item.toString() });
                        lastYearPartial = item;

                    })
                    this.existingYearPartialOptions = existingPartialOptions;
                    for (let i = 1; i < 5; i++) {
                        let temp = lastYear + i;
                        newOptions.push({ label: temp.toString(), value: temp.toString() });
                    }
                    this.newYearPMEOptions = newOptions;
                    for (let i = 1; i < 5; i++) {
                        let temp = lastYearPartial + i;
                        newPartialOptions.push({ label: temp.toString(), value: temp.toString() });
                    }
                    this.newYearPartialOptions = newPartialOptions;
                    this.showReviewAll = result.isReviewAll;
                    this.showReviewAllforNew = this.showReviewAll;
                } else if (result.error) {
                    this.error = error;
                }
            }).catch(error => {
                var err = error.body.message;
                this.showToast("Error", err, "error", "Something Went Wrong.");
            });
        }
    }

    @wire(getObjectInfo, { objectApiName: PRODUCT_ATTRIBUTE_VALUE })
    attributeInfo({ data, error }) {
        if (data) {
            for (var key in data.fields) {
                this.attributeFieldDetails.set(key, data.fields[key].label);
            }
        }
    }
    get pricingOptions() {
        return [
            { label: 'Update existing year price', value: 'Existing' },
            { label: 'Add new year price', value: 'New' },
        ];
    }
    get categoryOptions() {
        return [
            { label: 'Full', value: 'Full' },
            { label: 'Partial', value: 'Partial' },
        ];
    }
    get pricingToolOptions() {
        return this.picklist;
    }
    handlePricingOption(event) {
        this.showReviewChanges = false;
        this.selectedPricingOption = event.detail.value;
        this.selectedCategory = undefined;
        this.selectedNewYear = undefined;
        this.selectedExistingYear = undefined;
        this.showPercentageInputWithButton = false;
        this.showNewYearPricingSection = false;
        this.showUpdateExistingYearPricingSection = false;
        this.showPercentageInput = false;
        this.showPME = false;
        this.showPartialPricing = false;
        this.disableSearchButton = true;
        this.disableUpdateButton = true;
        this.searchedCountryKey = undefined;
        this.searchedKey = undefined;
        if (this.selectedPricingOption === 'New') {
            this.showReviewAllforNew = true;
        } else {
            this.showReviewAllforNew = false;
        }
        if (!this.hasPartialPricing) {
            this.handlePricingCategory(undefined, 'Full');
        }
        if (this.selectedPricingTool == 'AMESA' && this.selectedPricingOption == 'Existing') {
            this.showCountrySearchBox = true;
        }
        else {
            this.showCountrySearchBox = false;
        }
    }

    handlePricingTool(event) {
        this.selectedPricingTool = event.detail.value;
    }

    handlePricingCategory(event, fullCategory) {
        this.selectedCategory = event ? event.detail.value : fullCategory;
        this.showRespctiveChangesBtn = (this.selectedPricingOption == 'New' && (this.selectedCategory == 'Full' || this.selectedCategory == 'FULL')) ? false : true;
        this.reviewChangeBtnLabel = this.selectedPricingOption == 'New' ? 'Create Price' : 'Review Changes';
        this.showReviewChanges = (this.selectedPricingOption == 'New' && (this.selectedCategory == 'Partial' || this.selectedCategory == 'PARTIAL')) ? true : false;
        if (this.selectedPricingOption == undefined || this.selectedPricingOption == '') {
            this.showToast("Error", "Please select a pricing option.", "error", "dismissable");
        }
        else {
            this.selectedNewYear = undefined;
            this.selectedExistingYear = undefined;
            this.showPercentageInput = false;
            if (this.selectedCategory == 'Full') {
                this.newYearOptions = this.newYearPMEOptions;
                this.existingYearOptions = this.existingYearPMEOptions;
                if (this.selectedPricingOption == 'New' && this.nonActivePricingYears != undefined) {
                    this.selectedNewYear = this.nonActivePricingYears;
                    this.selectedExistingYear = this.selectedFullExistingYear;
                    this.disableExistingYearPicklist = true;
                    this.disableNewYearPicklist = true;
                    this.showPercentageInputWithButton = true;
                    this.showActivatePriceListButton = true;
                }
                else {
                    this.showPercentageInputWithButton = false;
                    this.showActivatePriceListButton = false;
                }
            }
            else {
                this.showActivatePriceListButton = false;
                this.newYearOptions = this.newYearPartialOptions;
                this.existingYearOptions = this.existingYearPartialOptions;
                this.disableExistingYearPicklist = false;
                this.disableNewYearPicklist = false;
                this.showPercentageInputWithButton = false;
            }
            if (this.selectedPricingOption === 'New' && this.selectedCategory != undefined) {
                this.showNewYearPricingSection = true;
                this.showUpdateExistingYearPricingSection = false;
            }
            else if (this.selectedPricingOption === 'Existing' && this.selectedCategory != undefined) {
                this.showNewYearPricingSection = false;
                this.showUpdateExistingYearPricingSection = true;
                this.cols = [...this.cols2];
            }
            if (this.selectedExistingYear != undefined) {
                this.showPercentageInput = true;
            }
            else {
                this.showPercentageInput = false;
            }
        }
    }

    handleExistingYearOption(event) {
        this.selectedExistingYear = event.detail.value;
        this.showPercentageInput = true;
        this.groupAttributeLabelList = this.groupAttributeObj;
        this.showCreatePriceButton = false;
    }

    handleChangeRoundUp(event){
        this.selectedRound = event.detail.value;
    }
	
    handleNewYearOption(event) {
        this.selectedNewYear = event.detail.value;
        this.disableExistingYearPicklist = false;
    }

    handleExistingYearOptionToInherit(event) {
        this.groupAttributeLabelList = this.groupAttributeObj;
        this.selectedExistingYear = event.detail.value;
        this.showPercentageInputWithButton = false;
        if (this.selectedCategory == 'Partial') {
            this.showReviewChanges = true;
            this.showCreatePriceButton = false;
        }
        else {
            this.showCreatePriceButton = true;
            this.showReviewChanges = false;
        }
        this.showPercentageInput = true;
    }

    handleInputChange(event) {
        if (this.attributeToPercentInput.has(event.target.name)) {
            this.attributeToPercentInput.set(event.target.name, event.detail.value);
        }
    }

    handleReviewFullChanges(event) {
        this.showSpinner = true;
        var country;
        for (var key of this.attributeLabelMap.keys()) {
            if (this.attributeLabelMap.get(key) == event.target.name) {
                country = key;
            }
        }
        this.currentReviewCountry = country;
        getInactivePriceMatrixEntries({ selectedPricingYear: this.selectedNewYear, selectedCountry: country, pricingTool: this.selectedPricingTool })
            .then(result => {
                var showAttributes = [];
                let tempPickList = JSON.parse(JSON.stringify(result));
                tempPickList.forEach(record => {
                    this.showAttributeList.forEach(attribute => {
                        if (record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1Id__r.Apttus_Config2__Datasource__c) {
                            record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension1Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension1Value__c) : record.Apttus_Config2__Dimension1Value__c;
                        }
                        else if (record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2Id__r.Apttus_Config2__Datasource__c) {
                            record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension2Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension2Value__c) : record.Apttus_Config2__Dimension2Value__c;
                        }
                        else if (record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3Id__r.Apttus_Config2__Datasource__c) {
                            record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension3Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension3Value__c) : record.Apttus_Config2__Dimension3Value__c;
                        }
                        else if (record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4Id__r.Apttus_Config2__Datasource__c) {
                            record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension4Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension4Value__c) : record.Apttus_Config2__Dimension4Value__c;
                        }
                        else if (record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5Id__r.Apttus_Config2__Datasource__c) {
                            record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension5Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension5Value__c) : record.Apttus_Config2__Dimension5Value__c;
                        }
                        else if (record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension6Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension6Id__r.Apttus_Config2__Datasource__c) {
                            record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension6Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension6Value__c) : record.Apttus_Config2__Dimension6Value__c;
                        }
                        else {
                            record[attribute] = "";
                        }
                        if(!record[attribute] == "" && !showAttributes.includes(attribute)) {
                            showAttributes.push(attribute);
                        }
                    })
                    record.Previous_Amount = record.Previous_Amount__c;
                    record.percentageChange = ((record.Apttus_Config2__AdjustmentAmount__c - record.Previous_Amount) / record.Previous_Amount).toFixed(2);
                    record.reviewCheck = record.Partial_Save__c;
                    record.Product_Name = record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ProductName__c;
                    
                })
                var tempCols = [];
                var emmptyAttributes = [...this.showAttributeList].filter(col => !showAttributes.includes(col));
                tempCols = [...this.columns].filter(col => !emmptyAttributes.includes(col.fieldName));
                this.columns[this.currencyIndex].typeAttributes.currencyCode = (this.countryToLocalCurrencyMap.get(country) ? this.countryToLocalCurrencyMap.get(country) : this.defaultCurrency);
                this.columns[this.currencyIndex + 2].typeAttributes.currencyCode = (this.countryToLocalCurrencyMap.get(country) ? this.countryToLocalCurrencyMap.get(country) : this.defaultCurrency);
                this.cols = tempCols;
                this.pmeListToInsert = tempPickList;
                if (tempPickList.length > 20) {
                    this.showData = tempPickList.slice(0, 20);
                }
                else {
                    this.showData = tempPickList;
                }
                this.showPricingOptions = false;
                this.showNewYearPricingSection = false;
                this.showUpdateExistingYearPricingSection = false;
                this.showPercentageInput = false;
                this.showPME = true;
                this.showSpinner = false;
            })
            .catch(error => {
                var errMessage = error.body.message;
                this.showToast("Error", errMessage, "error", "dismissable");
                this.error = error;
                this.showSpinner = false;
            });
    }

    handleReviewAll(event) {
        if (!this.showUpdatePME) {
            this.pmeListToInsert.forEach((item) => { item.reviewCheck = true; })
            this.pmeListToInsert = [...this.pmeListToInsert];
            this.showData.forEach((item) => { item.reviewCheck = true; })
            this.showData = [...this.showData];
        }
        else {
            this.pmeListToUpdate.forEach((item) => { item.reviewCheck = true; })
            this.pmeListToUpdate = [...this.pmeListToUpdate];
            this.initialUpdateRecords.forEach((item) => { item.reviewCheck = true; })
            this.initialUpdateRecords = [...this.initialUpdateRecords];
        }
    }

    handleReviewChanges(event) {
        this.showSpinner = true;
        var selectedPricingYear = this.selectedExistingYear;
        var updatedRecords = [];
        if (this.selectedRound == '') {
            this.showToast("Error", "Please select price rounding option.", "error", "dismissable");
        }
        else if (Array.from(this.attributeToPercentInput.values()).includes("") || (this.attributeToPercentInput == undefined || this.attributeToPercentInput == '') || !this.attributeToPercentInput.has(event.target.name)){
            this.showToast("Error", "Please fill the respective percentage input.", "error", "dismissable");
        }
        else if(this.selectedPricingOption === 'New' && this.selectedNewYear == undefined){
            this.showToast("Error", "Please select the new year input.", "error", "dismissable");
        }
        else{
            if(this.selectedCategory == 'Full'){
                this.columns[this.currencyIndex].typeAttributes.currencyCode = (this.countryToLocalCurrencyMap.get(this.getByValue(this.attributeLabelMap, event.target.name)) ? this.countryToLocalCurrencyMap.get(this.getByValue(this.attributeLabelMap, event.target.name)) : this.defaultCurrency);
                this.columns[this.currencyIndex + 2].typeAttributes.currencyCode = (this.countryToLocalCurrencyMap.get(this.getByValue(this.attributeLabelMap, event.target.name)) ? this.countryToLocalCurrencyMap.get(this.getByValue(this.attributeLabelMap, event.target.name)) : this.defaultCurrency);
                var pmeList = [];
                for(var key of this.pricingYearWithCountryPMEMap.keys()){
                    var yearCountryKey = key;
                    var arr = yearCountryKey.split(':')
                    var pricingYear = arr[0];
                    var country = this.attributeLabelMap.get(arr[1]);
                    
                    if (key == (selectedPricingYear + ':' + this.getByValue(this.attributeLabelMap, event.target.name))) {
                        let tempPickList  = JSON.parse(JSON.stringify(this.pricingYearWithCountryPMEMap.get(key)));
                        tempPickList.forEach(record => {
                            this.showAttributeList.forEach(attribute => {
                                if(record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1Id__r.Apttus_Config2__Datasource__c){
                                    record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension1Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension1Value__c) : record.Apttus_Config2__Dimension1Value__c;
                                }
                                else if(record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2Id__r.Apttus_Config2__Datasource__c){
                                    record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension2Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension2Value__c) : record.Apttus_Config2__Dimension2Value__c;
                                }
                                else if(record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3Id__r.Apttus_Config2__Datasource__c){
                                    record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension3Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension3Value__c) : record.Apttus_Config2__Dimension3Value__c;
                                }
                                else if(record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4Id__r.Apttus_Config2__Datasource__c){
                                    record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension4Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension4Value__c) : record.Apttus_Config2__Dimension4Value__c;
                                }
                                else if (record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5Id__r.Apttus_Config2__Datasource__c) {
                                    record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension5Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension5Value__c) : record.Apttus_Config2__Dimension5Value__c;
                                }
                                else if (record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension6Id__r != undefined && attribute == record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension6Id__r.Apttus_Config2__Datasource__c) {
                                    record[attribute] = this.attributeLabelMap.get(record.Apttus_Config2__Dimension6Value__c) != undefined ? this.attributeLabelMap.get(record.Apttus_Config2__Dimension6Value__c) : record.Apttus_Config2__Dimension6Value__c;
                                }
                                else{
                                    record[attribute] = "";
                                }
                            })
                            var amount = record.Apttus_Config2__AdjustmentAmount__c;
                            var percentageChange = this.attributeToPercentInput.get(country);
                            amount = amount + amount*percentageChange;
                            record.Previous_Amount = record.Apttus_Config2__AdjustmentAmount__c;
                            if (amount != record.Apttus_Config2__AdjustmentAmount__c) {
                                updatedRecords.push(record);
                            }
                            if (this.selectedRound == 'none') {
                                record.Apttus_Config2__AdjustmentAmount__c = (parseFloat(amount)).toFixed(2);
                            }
                            else  if (this.selectedRound == 'round') {
                                record.Apttus_Config2__AdjustmentAmount__c = Math.round(amount);
                            }
                            else if (this.selectedRound == 'roundUp') {
                                record.Apttus_Config2__AdjustmentAmount__c = Math.ceil(amount);
                            }
                            else if (this.selectedRound == 'roundDown') {
                                record.Apttus_Config2__AdjustmentAmount__c = Math.floor(amount);
                            }
                            record.Apttus_Config2__PriceOverride__c = Math.round(amount);
                            record.percentageChange = percentageChange;
                            record.reviewCheck = false;
                            record.Product_Name = record.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ProductName__c;
                        })
                        pmeList.push(...tempPickList);
                    }
                }
                this.pmeListToUpdate = updatedRecords;
                this.pmeListToInsert = pmeList;
                this.showData = pmeList.slice(0, 20);
                this.showPricingOptions = false;
                this.showNewYearPricingSection = false;
                this.showUpdateExistingYearPricingSection = false;
                this.showPercentageInput = false;
                this.showPME = true;
                this.cols2.forEach((col) =>{col.initialWidth = 160});
            }
            else {
                this.columns2.forEach(element => {
                    if (element.typeAttributes) {
                        if(element.typeAttributes.currencyCode){
                            element.typeAttributes.currencyCode = this.countryToLocalCurrencyMap.get(this.getByValue(this.attributeLabelMap, event.target.name));
                        }
                    }
                })
                this.currentAttribute = this.getByValue(this.attributeLabelMap, event.target.name);
                var partialList = [];
                for (var key of this.partialPricingWithYearandCountryMap.keys()) {
                    var yearCountryKey = key;
                    var arr = yearCountryKey.split(':')
                    var pricingYear = arr[0];
                    var country = this.attributeLabelMap.get(arr[1]);

                    if (key == (selectedPricingYear + ':' + this.getByValue(this.attributeLabelMap, event.target.name))) {
                        let tempPickList = JSON.parse(JSON.stringify(this.partialPricingWithYearandCountryMap.get(key)));
                        tempPickList.forEach(record => {
                            record.CountryLabel = this.attributeLabelMap.get(record.Country__c);
                            var defaultPercentageChange = 0;
                            this.groupAttributeLabelList.forEach(element => {
                                if(element.country == event.target.name) {
                                    defaultPercentageChange = element.percentageChange;
                                }
                            })
                            var percentageChange = this.attributeToPercentInput.get(country) ? this.attributeToPercentInput.get(country) : defaultPercentageChange;
                            var amount1 = record.Final_Price__c;
                            amount1 = amount1 + amount1 * percentageChange;
                            var amount2 = record.Final_Price_with_molecule__c;
                            amount2 = amount2 + amount2 * percentageChange;

                            record.Previous_Partial_Price = record.Final_Price__c;
                            record.Previous_Partial_Price_with_molecule = record.Final_Price_with_molecule__c;
                            record.reviewCheck = false;
                            record.Final_Price__c = Math.round(amount1);
                            record.Final_Price_with_molecule__c = Math.round(amount2);
                            record.percentageChange1 = percentageChange;
                            this.percentageChange = percentageChange;
                            record.percentageChange2 = percentageChange;
                            if (record.Previous_Partial_Price != record.Final_Price__c) {
                                updatedRecords.push(record);
                            }
                        })
                        partialList.push(...tempPickList);
                    }
                }
                this.showUpdatePartialData = updatedRecords;
                this.showPartialData = partialList;
                this.initialPartialRecords = partialList;
                this.showPricingOptions = false;
                this.showNewYearPricingSection = false;
                this.showUpdateExistingYearPricingSection = false;
                this.showPercentageInput = false;
                this.showPartialPricing = true;
            }
        }
        this.showSpinner = false;
    }

    loadMoreData(event) {
        if (this.pmeListToInsert.length > 20) {
            if (!this.isSearched) {
                event.target.isLoading = true;
                var temp = this.showData.length + 20;
                this.showData = this.pmeListToInsert.slice(0, temp);
                event.target.isLoading = false;
            }
            else {
                if (this.searchedRecords.length > 20) {
                    event.target.isLoading = true;
                    var temp = this.showData.length + 20;
                    this.showData = this.searchedRecords.slice(0, temp);
                    event.target.isLoading = false;
                }
            }
        }
    }

    closeModal() {
        this.pmeListToUpdate = this.initialUpdateRecords;
        this.showUpdatePME = false;
        this.showUpdatePartial = false;
    }

    handleInputChangeForUpdate(event) {
        this.percentChangeForUpdate = event.detail.value;
        if (this.percentChangeForUpdate) {
            this.disableUpdateButton = false;
        }
        else {
            this.disableUpdateButton = true;
        }
    }

    updateSelectedRows() {
        if (this.percentChangeForUpdate) {
            this.disableUpdateButton = false;
        }
    }

    getSelectedRec() {
        if(this.percentChangeForUpdate){
            var arr = [];
            var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
            if (selectedRecords.length > 0) {
                selectedRecords.forEach(element => {
                    var arrElement = this.pmeListToInsert.find(item => item.Id === element.Id);
                    if (element.Apttus_Config2__AdjustmentAmount__c != undefined && element.Apttus_Config2__AdjustmentAmount__c != '') {
                        var newAmount = element.Previous_Amount + element.Previous_Amount * this.percentChangeForUpdate;
                        if (this.selectedRound == 'none') {
                            newAmount = newAmount.toFixed(2);
                        }
                        else  if (this.selectedRound == 'round') {
                            newAmount = Math.round(newAmount);
                        }
                        else if (this.selectedRound == 'roundUp') {
                            newAmount = Math.ceil(newAmount);
                        }
                        else if (this.selectedRound == 'roundDown') {
                            newAmount = Math.floor(newAmount);
                        }
                        var newPercent = (newAmount - element.Previous_Amount) / element.Previous_Amount;
                        arrElement.Apttus_Config2__AdjustmentAmount__c = newAmount;
                        arrElement.Apttus_Config2__PriceOverride__c = newAmount;
                        arrElement.percentageChange = newPercent;
                    }
                    arrElement = JSON.parse(JSON.stringify(arrElement));
                    var foundIndex1 = this.pmeListToInsert.findIndex(item => item.Id === element.Id);
                    this.pmeListToInsert[foundIndex1] = arrElement;
                    var foundIndex2 = this.showData.findIndex(item => item.Id === element.Id);
                    this.showData[foundIndex2] = arrElement;
                    this.showData = [...this.showData];
                    var foundIndex3 = this.pmeListToUpdate.findIndex(item => item.Id === element.Id);
                    if (foundIndex3 >= 0) {
                        this.pmeListToUpdate[foundIndex3] = arrElement;
                    }
                    else {
                        arr.push(arrElement);
                    }
                    if (this.searchedRecords.length > 20) {
                        var foundIndex4 = this.searchedRecords.findIndex(item => item.Id === element.Id);
                        this.searchedRecords[foundIndex4] = arrElement;
                    }
                })
                if (arr.length > 0) {
                    this.pmeListToUpdate.push(...arr);
                }
                this.disableUpdateButton = true;
            }
        }
    }

    handleSave(event) {
        this.saveDraftValues = event.detail.draftValues;
        var arr = [];
        this.saveDraftValues.forEach(element => {
            var arrElement = this.pmeListToInsert.find(item => item.Id === element.Id);
            if (element.Apttus_Config2__AdjustmentAmount__c != undefined && element.Apttus_Config2__AdjustmentAmount__c != '') {
                if (this.selectedRound == 'none') {
                    var newAmount = (parseFloat(element.Apttus_Config2__AdjustmentAmount__c)).toFixed(2);
                }
                else  if (this.selectedRound == 'round') {
                    var newAmount = Math.round(element.Apttus_Config2__AdjustmentAmount__c);
                }
                else if (this.selectedRound == 'roundUp') {
                    var newAmount = Math.ceil(element.Apttus_Config2__AdjustmentAmount__c);
                }
                else if (this.selectedRound == 'roundDown') {
                    var newAmount = Math.floor(element.Apttus_Config2__AdjustmentAmount__c);
                }
                
                var newPercent = (newAmount - arrElement.Previous_Amount) / arrElement.Previous_Amount;
                arrElement.Apttus_Config2__AdjustmentAmount__c = newAmount;
                arrElement.Apttus_Config2__PriceOverride__c = newAmount;
                arrElement.percentageChange = newPercent;
            }
            arrElement = JSON.parse(JSON.stringify(arrElement));
            var foundIndex1 = this.pmeListToInsert.findIndex(item => item.Id === element.Id);
            this.pmeListToInsert[foundIndex1] = arrElement;
            var foundIndex2 = this.showData.findIndex(item => item.Id === element.Id);
            this.showData[foundIndex2] = arrElement;
            var foundIndex3 = this.pmeListToUpdate.findIndex(item => item.Id === element.Id);
            if (foundIndex3 >= 0) {
                this.pmeListToUpdate[foundIndex3] = arrElement;
            }
            else {
                arr.push(arrElement);
            }
        });
        if (arr.length > 0) {
            this.pmeListToUpdate.push(...arr);
        }
        this.saveDraftValues = [];
    }

    handlePartialSave(event) {
        this.savePartialDraftValues = event.detail.draftValues;
        var arr = [];
        this.savePartialDraftValues.forEach(element => {
            var arrElement = this.showPartialData.find(item => item.Id === element.Id);
            if (element.Final_Price__c != undefined && element.Final_Price__c != '') {
                var newAmount = Math.round(element.Final_Price__c);
                var newPercent = (newAmount - arrElement.Previous_Partial_Price) / arrElement.Previous_Partial_Price;
                arrElement.Final_Price__c = newAmount;
                arrElement.percentageChange1 = newPercent;
            }
            if (element.Final_Price_with_molecule__c != undefined && element.Final_Price_with_molecule__c != '') {
                var newAmount = Math.round(element.Final_Price_with_molecule__c);
                var newPercent = (newAmount - arrElement.Previous_Partial_Price_with_molecule) / arrElement.Previous_Partial_Price_with_molecule;
                arrElement.Final_Price_with_molecule__c = newAmount;
                arrElement.percentageChange2 = newPercent;
            }
            arrElement = JSON.parse(JSON.stringify(arrElement));

            var foundIndex1 = this.showPartialData.findIndex(item => item.Id === element.Id);
            this.showPartialData[foundIndex1] = arrElement;
            var foundIndex2 = this.showUpdatePartialData.findIndex(item => item.Id === element.Id);
            if (foundIndex2 >= 0) {
                this.showUpdatePartialData[foundIndex2] = arrElement;
            }
            else {
                arr.push(arrElement);
            }
        });
        if (arr.length > 0) {
            this.showUpdatePartialData.push(...arr);
        }
        this.savePartialDraftValues = [];
    }

    handleRowAction(event) {
        var rowId = event.detail.row.Id;
        var actionName = event.detail.action.name;
        if (!this.showUpdatePME) {
            var arrElement = this.pmeListToInsert.find(item => item.Id === rowId);
            arrElement.reviewCheck = true;
            arrElement = JSON.parse(JSON.stringify(arrElement));
            var foundIndex1 = this.pmeListToInsert.findIndex(item => item.Id === rowId);
            this.pmeListToInsert[foundIndex1] = arrElement;
            this.pmeListToInsert = [...this.pmeListToInsert];

            var foundIndex2 = this.showData.findIndex(item => item.Id === rowId);
            this.showData[foundIndex2] = arrElement;
            this.showData = [...this.showData];
        }
        else {
            var arrElement = this.pmeListToUpdate.find(item => item.Id === rowId);
            arrElement.reviewCheck = true;
            arrElement = JSON.parse(JSON.stringify(arrElement));
            var foundIndex1 = this.pmeListToUpdate.findIndex(item => item.Id === rowId);
            this.pmeListToUpdate[foundIndex1] = arrElement;
            this.pmeListToUpdate = [...this.pmeListToUpdate];

            var foundIndex2 = this.initialUpdateRecords.findIndex(item => item.Id === rowId);
            this.initialUpdateRecords[foundIndex2] = arrElement;
            this.initialUpdateRecords = [...this.initialUpdateRecords];
        }
    }

    handlePartialRowAction(event) {
        var rowId = event.detail.row.Id;
        var actionName = event.detail.action.name;
        if (!this.showUpdatePartial) {
            var arrElement = this.showPartialData.find(item => item.Id === rowId);
            arrElement.reviewCheck = true;
            arrElement = JSON.parse(JSON.stringify(arrElement));
            var foundIndex1 = this.showPartialData.findIndex(item => item.Id === rowId);
            this.showPartialData[foundIndex1] = arrElement;
            this.showPartialData = [...this.showPartialData];

            var foundIndex2 = this.initialPartialRecords.findIndex(item => item.Id === rowId);
            this.initialPartialRecords[foundIndex2] = arrElement;
            this.initialPartialRecords = [...this.initialPartialRecords];
        }
        else {
            var arrElement = this.showUpdatePartialData.find(item => item.Id === rowId);
            arrElement.reviewCheck = true;
            arrElement = JSON.parse(JSON.stringify(arrElement));
            var foundIndex1 = this.showUpdatePartialData.findIndex(item => item.Id === rowId);
            this.showUpdatePartialData[foundIndex1] = arrElement;
            this.showUpdatePartialData = [...this.showUpdatePartialData];

            var foundIndex2 = this.initialUpdatePartialRecords.findIndex(item => item.Id === rowId);
            this.initialUpdatePartialRecords[foundIndex2] = arrElement;
            this.initialUpdatePartialRecords = [...this.initialUpdatePartialRecords];
        }
    }
    handleUpdate(event) {
        this.showSpinner = true;
        var insertList = [];
        var temp = false;
		for (var key in this.initialUpdateRecords) {
			if (!this.initialUpdateRecords[key].reviewCheck) {
				this.showToast("Error", "Please review all the price before save", "error", "dismissable");
				temp = true;
				this.showSpinner = false;
				break;
			}
		}
        if(!temp){
            savePriceMatrixEntries({insertPMEList: insertList, updatePMEList : this.pmeListToUpdate, newYear: undefined, existingYear: this.selectedExistingYear, priceMatrixJSON : undefined, attributeToPercentageMap: undefined})
            .then(result => {
                if(result.Status == 'Update'){
                    this.showToast("Success", "Existing year price is updated successfully.", "success", "sticky");
                    this.pmeListToUpdate = [];
                    this.showSpinner = false;
                }
                this.showPME = false;
                this.showPercentageInput = false;
                this.showPricingOptions = true;
                this.selectedPricingOption = undefined;
                this.selectedCategory = undefined;
                this.selectedNewYear = undefined;
                this.selectedExistingYear = undefined;
                location.reload();
            })
            .catch(error => {
                var errMessage = error.body.message;
                this.showToast("Error", errMessage, "error", "dismissable");
                this.error = error;
                this.showSpinner = false;
            });
            this.showUpdatePME = false;
        }
    }

    handlePartialUpdate(event) {
        this.showSpinner = true;
        var temp = false;
        for (var key in this.initialUpdatePartialRecords) {
            if (!this.initialUpdatePartialRecords[key].reviewCheck) {
                this.showToast("Error", "Please review all the price before save.", "error", "dismissable");
                temp = true;
                this.showSpinner = false;
                break;
            }
        }
        if(!temp) {
            savePartialPricing({insertPartialList: undefined, updatePartialList : this.showUpdatePartialData, newYear: undefined, existingYear: this.selectedExistingYear, pricingTool: this.selectedPricingTool})
            .then(result => {
                if(result == 'Update') {
                    this.showToast("Success", "Existing year partial price is updated successfully.", "success", "dismissable");
                    this.showUpdatePartialData = [];
                    location.reload();
                }
                this.showPartialPricing = false;
                this.showPercentageInput = false;
                this.showPricingOptions = true;
                this.selectedPricingOption = undefined;
                this.selectedCategory = undefined;
                this.selectedNewYear = undefined;
                this.selectedExistingYear = undefined;
            })
            .catch(error => {
                var errMessage = error.body.message;
                this.showToast("Error", errMessage, "error", "dismissable");
                this.error = error;
                this.showSpinner = false;
            });
            this.showUpdatePartial = false;
        }
    }

    handleCancelReview(event) {
        this.showPME = false;
        this.showPartialPricing = false;
        this.showPricingOptions = true;
        if (this.selectedPricingOption === 'New') {
            this.showNewYearPricingSection = true;
            this.showUpdateExistingYearPricingSection = false;
        }
        else {
            this.attributeToPercentInput = new Map();
            this.attributeLabelMap.forEach((key, value) => {
                this.attributeToPercentInput.set(key, 0);
            });
            this.showNewYearPricingSection = false;
            this.showUpdateExistingYearPricingSection = true;
        }
        this.showPercentageInput = true;
        this.isSearched = false;
        this.disableSearchButton = true;
        this.disableUpdateButton = true;
    }

    handleFinalSave(event) {
        this.showSpinner = true;
        var isAllReviewed = true;
        if (this.selectedPricingOption === 'New') {
            var tempList = [];
            for (var key in this.pmeListToInsert) {
                if (this.pmeListToInsert[key].reviewCheck) {
                    this.pmeListToInsert[key].Partial_Save__c = true;
                }
                else {
                    this.pmeListToInsert[key].Partial_Save__c = false;
                    isAllReviewed = false;
                }
                tempList.push(this.pmeListToInsert[key]);
            }
            if(isAllReviewed){
                for(let i = 0; i < this.attributeToPercentMap.length; i++){
                    if(this.getByValue(this.attributeLabelMap, this.attributeToPercentMap[i]['key']) == this.currentReviewCountry){
                        this.attributeToPercentMap[i]['msg'] = 'Review Completed';
                    }
                }
            }
            var insertList = tempList.map(({ Id, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PriceOverride__c, Partial_Save__c }) => ({
                Id, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PriceOverride__c, Partial_Save__c
            }));
            updatePriceMatrixEntries({ updatePMEList: insertList})
            .then(result => {
                if (result == 'Updated'){
                    this.showToast("Success", 'Changes are saved successfully.', "success", "dismissable");
                    this.showPME = false;
                    this.showPricingOptions = true;
                    this.showNewYearPricingSection = true;
                    this.showPercentageInput = true;
                    this.showSpinner = false;
                    this.isSearched = false;
                    this.pmeListToUpdate = [];
                    this.disableSearchButton = true;
                    this.disableUpdateButton = true;
                    this.percentChangeForUpdate = undefined;
                }
            })
            .catch(error => {
                var errMessage = error.body.message;
                this.showToast("Error", errMessage, "error", "dismissable");
                this.error = error;
                this.showSpinner = false;
            });
        }
        else {
            this.disableUpdateSearchButton = true;
            this.initialUpdateRecords = this.pmeListToUpdate;
            this.showUpdatePME = true;
            this.showSpinner = false;
        }
    }
    finalSavePartialRecord(event) {
        if (this.partialRecords.size == 0 || this.partialRecords || this.partialRecords == '') {
            for (var key of this.attributeLabelMap.keys()) {
                if (this.partialPricingWithYearandCountryMap.has(this.selectedExistingYear + ':' + key) && this.partialPricingWithYearandCountryMap.get(this.selectedExistingYear + ':' + key)) {
                    this.partialRecords.set(key, this.partialPricingWithYearandCountryMap.get(this.selectedExistingYear + ':' + key));
                }
            }
        }
        if (this.selectedRound == '') {
            this.showToast("Error", "Please select price rounding option.", "error", "dismissable");
        } else {
            this.showSpinner = true;
            var finalpartialData = [];
            for (var key of this.attributeLabelMap.keys()) {
                if (this.contriesReviewed.has(key) && this.contriesReviewed.get(key)) {
                    this.contriesReviewed.get(key).forEach(element => {
                        finalpartialData.push(element);
                    })
                } else if (this.partialRecords.has(key) && this.partialRecords.get(key)) {
                    this.partialRecords.get(key).forEach(element => {
                        finalpartialData.push(element);
                    })
                }
            }
            savePartialPricing({insertPartialList: finalpartialData, updatePartialList : undefined, newYear: this.selectedNewYear, existingYear: this.selectedExistingYear, pricingTool: this.selectedPricingTool})
            .then(result => {
                if(result == 'Insert') {
                    this.showToast("Success", "New year partial price is created successfully.", "success", "dismissable");
                    location.reload();
                }
                this.showPartialPricing = false;
                this.showPercentageInput = false;
                this.showPricingOptions = true;
                this.selectedPricingOption = undefined;
                this.selectedCategory = undefined;
                this.selectedNewYear = undefined;
                this.selectedExistingYear = undefined;
            })
            .catch(error => {
                var errMessage = error.body.message;
                this.showToast("Error", errMessage, "error", "dismissable");
                this.error = error;
                this.showSpinner = false;
            });
            
        }
    }

    handleFinalPartialSave(event) {
        this.showSpinner = true;
        if (this.selectedPricingOption === 'New') {
            var temp = false;
            for (var key in this.showPartialData) {
                if (!this.showPartialData[key].reviewCheck) {
                    this.showToast("Error", "Please review all the price before save.", "error", "dismissable");
                    temp = true;
                    this.showSpinner = false;
                    break;
                }
            }
            if (!temp) {
                if (!this.contriesReviewed.has(this.currentAttribute)) {
                    this.contriesReviewed.set(this.currentAttribute, this.showPartialData);
                    this.groupAttributeLabelList.forEach(element => {
                        if (element.country == this.attributeLabelMap.get(this.currentAttribute)) {
                            element.percentageChange = this.percentageChange;
                            element.msg = 'Review Completed';
                        }
                    })
                }
                this.showToast("Success", "Changes saved successfully.", "success", "dismissable");
                this.showSpinner = false;
                this.handleCancelReview();
            }
        }
        else {
            this.initialUpdatePartialRecords = this.showUpdatePartialData;
            this.showUpdatePartial = true;
            this.showSpinner = false;
        }
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent ({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        if (this.selectedCategory == 'Full') {
            this.sortData(this.sortBy, this.sortDirection);
        }
        else {
            this.sortPartialData(this.sortBy, this.sortDirection);
        }
    }

    sortData(fieldname, direction) {
        if (!this.showUpdatePME) {
            if (!this.isSearched) {
                var tempData = this.sortingMethod(fieldname, direction, this.pmeListToInsert);
                this.pmeListToInsert = tempData;
                this.showData = tempData.slice(0, 20);
            }
            else {
                var tempData2 = this.sortingMethod(fieldname, direction, this.searchedRecords);
                this.searchedRecords = tempData2;
                this.showData = tempData2.slice(0, 20);
            }
        }
        else {
            this.pmeListToUpdate = this.sortingMethod(fieldname, direction, this.pmeListToUpdate);
        }
    }

    sortPartialData(fieldname, direction) {
        if (!this.showUpdatePME) {
            this.showPartialData = this.sortingMethod(fieldname, direction, this.showPartialData);
        }
        else {
            this.showUpdatePartialData = this.sortingMethod(fieldname, direction, this.showUpdatePartialData);
        }
    }
    sortingMethod(fieldname, direction, data) {
        let parseData = JSON.parse(JSON.stringify(data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return parseData;
    }
    setSearchKey(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.searchedKey = event.target.value.toLowerCase();
            if (!this.showUpdatePME) {
                this.disableSearchButton = false;
            }
            this.disableUpdateSearchButton = false;
        }
        else {
            this.searchedKey = undefined;
            if (!this.showUpdatePME) {
                if (this.searchedCountryKey == undefined) {
                    this.isSearched = false;
                    this.disableSearchButton = true;
                    this.disableUpdateButton = true;
                    this.showData = this.pmeListToInsert.slice(0, 20);
                }
            }
            else {
                if (this.searchedCountryKey == undefined) {
                    this.disableUpdateSearchButton = true;
                    this.pmeListToUpdate = this.initialUpdateRecords;
                }
            }
        }
    }

    setCountrySearchKey(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.searchedCountryKey = event.target.value.toLowerCase();
            if (!this.showUpdatePME) {
                this.disableSearchButton = false;
            }
            this.disableUpdateSearchButton = false;
        }
        else {
            this.searchedCountryKey = undefined;
            if (!this.showUpdatePME) {
                if (this.searchedKey == undefined) {
                    this.isSearched = false;
                    this.disableSearchButton = true;
                    this.disableUpdateButton = true;
                    this.showData = this.pmeListToInsert.slice(0, 20);
                }
            }
            else {
                if (this.searchedKey == undefined) {
                    this.disableUpdateSearchButton = true;
                    this.pmeListToUpdate = this.initialUpdateRecords;
                }
            }
        }
    }
    setPartialSearchKey(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.searchedPartialKey = event.target.value.toLowerCase();
        }
        else {
            this.searchedPartialKey = undefined;
            if (!this.showUpdatePartial) {
                this.showPartialData = this.initialPartialRecords;
            }
            else {
                this.showUpdatePartialData = this.initialUpdatePartialRecords;
            }
        }

    }
    handleSearch(event) {
        this.showSpinner = true;
        const searchKey = this.searchedKey;
        const searchKey2 = this.searchedCountryKey;
        if (searchKey || searchKey2) {
            if (!this.showUpdatePME) {
                if (this.pmeListToInsert) {
                    let searchRecords = [];
                    for (let record of this.pmeListToInsert) {
                        let strVal = String(record.Product_Name);
                        let strVal2 = String(record.Eligible_Countries__c);
                        if (searchKey && searchKey2) {
                            if (strVal.toLowerCase().includes(searchKey) && strVal2.toLowerCase().includes(searchKey2)) {
                                searchRecords.push(record);
                            }
                        }
                        else {
                            if (searchKey) {
                                if (strVal.toLowerCase().includes(searchKey)) {
                                    searchRecords.push(record);
                                }
                            }
                            if (searchKey2) {
                                if (strVal2.toLowerCase().includes(searchKey2)) {
                                    searchRecords.push(record);
                                }
                            }
                        }
                    }
                    searchRecords = JSON.parse(JSON.stringify(searchRecords));
                    this.searchedRecords = searchRecords;
                    if (searchRecords.length > 20) {
                        this.showData = searchRecords.slice(0, 20);
                    }
                    else {
                        this.showData = searchRecords;
                    }
                    this.isSearched = true;
                    this.showSpinner = false;
                }
            }
            else {
                if (this.pmeListToUpdate) {
                    let searchRecords = [];
                    for (let record of this.pmeListToUpdate) {
                        let strVal = String(record.Product_Name);
                        let strVal2 = String(record.Eligible_Countries__c);
                        if (searchKey && searchKey2) {
                            if (strVal.toLowerCase().includes(searchKey) && strVal2.toLowerCase().includes(searchKey2)) {
                                searchRecords.push(record);
                            }
                        }
                        else {
                            if (searchKey) {
                                if (strVal.toLowerCase().includes(searchKey)) {
                                    searchRecords.push(record);
                                }
                            }
                            if (searchKey2) {
                                if (strVal2.toLowerCase().includes(searchKey2)) {
                                    searchRecords.push(record);
                                }
                            }
                        }
                    }
                    searchRecords = JSON.parse(JSON.stringify(searchRecords));
                    this.pmeListToUpdate = searchRecords;
                    this.showSpinner = false;
                }
            }
        }
        else {
            this.showSpinner = false;
            this.showToast("Error", "Please, Enter some text to search.", "error", "dismissable");
        }
    }

    handlePartialSearch(event) {
        const searchKey = this.searchedPartialKey;
        if (searchKey) {
            if (!this.showUpdatePartial) {
                if (this.showPartialData) {
                    let searchRecords = [];
                    for (let record of this.showPartialData) {
                        let strVal = String(record.CPQ_ProductName__c);
                        if (strVal) {
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                            }
                        }
                    }
                    searchRecords = JSON.parse(JSON.stringify(searchRecords));
                    this.showPartialData = searchRecords;
                    this.showSpinner = false;
                }
            }
            else {
                if (this.showUpdatePartialData) {
                    let searchRecords = [];
                    for (let record of this.showUpdatePartialData) {
                        let strVal = String(record.CPQ_ProductName__c);
                        if (strVal) {
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                            }
                        }
                    }
                    searchRecords = JSON.parse(JSON.stringify(searchRecords));
                    this.showUpdatePartialData = searchRecords;
                    this.showSpinner = false;
                }
            }
        }
        else {
            this.showSpinner = false;
            this.showToast("Error", "Please, Enter some text to search.", "error", "dismissable");
        }
    }

    exportPricingData() {
        var temp;
        if (this.selectedCategory == 'Full') {
            temp = [...this.columns];
            temp.pop();
            temp.pop();
            var columnHeader = [];
            temp.forEach(element => {
                columnHeader.push(element.label);
            });
            
        }
        else {
            var columnHeader = ['Product Name', 'Sub Product Name', 'Country', 'Data Delivery Frequency', 'Previous Partial Price', 'Percentage Difference', 'New Partial Price', 'Previous Partial Price with molecule', 'Percentage Difference', 'New Partial Price with molecule' ]
        }
        let doc = '<table>';
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'           
        });
        doc += '</tr>';
        if (this.selectedCategory == 'Full') {
            this.pmeListToInsert.forEach(record => {
                doc += '<tr>';
                temp.forEach(element => {
                    if (record[element.fieldName] !== undefined) {
                        doc += '<th>' + record[element.fieldName] + '</th>';
                    } else {
                        doc += '<th></th>';
                    }
                });
                doc += '</tr>';
            });
        }
        else {
            this.initialPartialRecords.forEach(record => {
                doc += '<tr>';
                doc += '<th>' + record.CPQ_ProductName__c + '</th>';
                doc += '<th>' + record.Product_Name__c + '</th>';
                doc += '<th>' + record.CountryLabel + '</th>';
                doc += '<th>' + record.Data_Delivery_Frequency__c + '</th>';
                doc += '<th>' + record.Previous_Partial_Price + '</th>';
                doc += '<th>' + record.percentageChange1 + '</th>';
                doc += '<th>' + record.Final_Price__c + '</th>';
                doc += '<th>' + record.Previous_Partial_Price_with_molecule + '</th>';
                doc += '<th>' + record.percentageChange2 + '</th>';
                doc += '<th>' + record.Final_Price_with_molecule__c + '</th>';
                doc += '</tr>';
            });
        }
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'Pricing Data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
    getByValue(map, searchValue) {
        for (let [key, value] of map.entries()) {
          if (value === searchValue)
            return key;
        }
    }
    createPriceBookEntries(event) {
        this.showSpinner = true;
        this.progress = 0;
        var selectedPricingYear = this.selectedExistingYear;
        if (this.selectedRound == '') {
            this.showToast("Error", "Please select price rounding option.", "error", "dismissable");
        }
        else if (Array.from(this.attributeToPercentInput.values()).includes("") || (this.attributeToPercentInput == undefined || this.attributeToPercentInput == '') || this.attributeToPercentInput.size != this.groupAttributeLabelList.length) {
            this.showToast("Error", "Please fill all the percentage inputs.", "error", "dismissable");
        }
        else if (this.selectedPricingOption === 'New' && this.selectedNewYear == undefined) {
            this.showToast("Error", "Please select the new year input.", "error", "dismissable");
        }
        else {
            this.showPricingOptionDisabled = true;  
            this.showProgessBar = true;
            this.showCreatePriceButton = false;
            if (this.selectedCategory == 'Full') {
                this.disablePercentageInput = true;
                this.disableExistingYearPicklist = true;
                this.disableNewYearPicklist = true;
                var pmeList = [];
                for (var key of this.pricingYearWithCountryPMEMap.keys()) {
                    var yearCountryKey = key;
                    var arr = yearCountryKey.split(':')
                    var pricingYear = arr[0];
                    var country = this.attributeLabelMap.get(arr[1]);
                    if (pricingYear == selectedPricingYear) {
                        let tempPickList = JSON.parse(JSON.stringify(this.pricingYearWithCountryPMEMap.get(key)));
                        tempPickList.forEach(record => {
                            var amount = record.Apttus_Config2__AdjustmentAmount__c;
                            record.Apttus_Config2__PriceOverride__c = amount;
                            var percentageChange = this.attributeToPercentInput.get(country);
                            amount = amount + amount * percentageChange;
                            
                            if (this.selectedRound == 'none') {
                                record.Apttus_Config2__AdjustmentAmount__c = (parseFloat(amount)).toFixed(2);
                            }
                            else  if (this.selectedRound == 'round') {
                                record.Apttus_Config2__AdjustmentAmount__c = Math.round(amount);
                            }
                            else if (this.selectedRound == 'roundUp') {
                                record.Apttus_Config2__AdjustmentAmount__c = Math.ceil(amount);
                            }
                            else if (this.selectedRound == 'roundDown') {
                                record.Apttus_Config2__AdjustmentAmount__c = Math.floor(amount);
                            }
                            
                        })
                        pmeList.push(...tempPickList);
                    }
                }
                var insertList = pmeList.map(({ Id, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__AdjustmentType__c, Apttus_Config2__Dimension1Value__c,
                    Apttus_Config2__Dimension2Value__c, Apttus_Config2__Dimension3Value__c, Apttus_Config2__Dimension4Value__c, Apttus_Config2__Dimension5Value__c, Apttus_Config2__Dimension6Value__c, 
                    Apttus_Config2__PriceOverride__c, Apttus_Config2__Sequence__c, Apttus_Config2__PriceMatrixId__c, Apttus_Config2__MatrixType__c, Local_Currency_Code__c }) => ({
                        Id, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__AdjustmentType__c, Apttus_Config2__Dimension1Value__c,
                        Apttus_Config2__Dimension2Value__c, Apttus_Config2__Dimension3Value__c, Apttus_Config2__Dimension4Value__c, Apttus_Config2__Dimension5Value__c, Apttus_Config2__Dimension6Value__c, 
                        Apttus_Config2__PriceOverride__c, Apttus_Config2__Sequence__c, Apttus_Config2__PriceMatrixId__c, Apttus_Config2__MatrixType__c, Local_Currency_Code__c
                    }));
                var pmMap = new Map();
                for (var key in pmeList) {
                    pmMap.set(pmeList[key].Apttus_Config2__PriceMatrixId__c, pmeList[key].Apttus_Config2__PriceMatrixId__r);
                }

                if (this.selectedPricingOption === 'New') {
                    var obj = Object.fromEntries(pmMap);
                    var pmJSONString = JSON.stringify(obj);
                    var apiToPercentInput = new Map();
                    for(let [key, value] of this.attributeToPercentInput.entries()){
                        apiToPercentInput.set(this.getByValue(this.attributeLabelMap, key), value);
                    }
                    var obj1 = Object.fromEntries(apiToPercentInput);
                    var attributeToPercentJSONString = JSON.stringify(obj1);
                    
                    for (let i = 0; i < insertList.length; i += this.chunkSize) {
                        this.chunks.push(insertList.slice(i, i + this.chunkSize));
                    }
                    this.pmString = pmJSONString;
                    this.attributeToPercentString = attributeToPercentJSONString;
                    this.savePriceEntries();
                }
            }
        }
        this.showSpinner = false;
    }
    savePriceEntries() {
        savePriceMatrixEntries({ insertPMEList: this.chunks[this.currentState-1], updatePMEList: this.pmeListToUpdate, newYear: this.selectedNewYear, existingYear: this.selectedExistingYear, priceMatrixJSON: this.pmString, attributeToPercentageMap: this.attributeToPercentString, pricingTool: this.selectedPricingTool, IdToPLI: JSON.stringify(Object.fromEntries(this.previousIdToPLI)),  IdToPM: JSON.stringify(Object.fromEntries(this.previousIdToPM))})
            .then(result => {
                if (result.Status == 'Insert' && this.currentState == this.chunks.length) {
                    this.showToast("Info", "New Year pricing creation is in-progress, please wait while it completes.", "info", "dismissable");
                } else if (this.currentState == 1) {
                    this.showToast("Info", "Hold on, processing new year price data.", "info", "dismissable");
                }
                for (var key in result.IdToPLIMap) {
                    this.previousIdToPLI.set(key, result.IdToPLIMap[key]);
                }
                for (var key in result.IdToPMMap) {
                    this.previousIdToPM.set(key, result.IdToPMMap[key]);
                }
                result.PLIList.forEach(element => {
                    if (!this.idToPLIMap.has(element.Id)) {
                        this.idToPLIMap.set(element.Id, element);
                    }
                })
                result.PMList.forEach(element => {
                    if (!this.idToPMMap.has(element.Id)) {
                        this.idToPMMap.set(element.Id, element);
                    }
                })
                result.PMEList.forEach(element => {
                    this.idToPMEMap.set(element.Id, element);
                })
                this.showSpinner = false;
                this.isPreviousBatchResult = false;
                this.showSuccess = true;
                if (this.currentState < this.chunks.length) {
                    this.currentState++;
                    this.savePriceEntries();
                } else {
                    this.currentState = 1;
                    this.previousIdToPLI = new Map();
                    this.previousIdToPM = new Map();
                    var pliRecords = [];
                    var pmRecords = [];
                    var pmeRecords = [];
                    for (const [key, value] of this.idToPLIMap) {
                        value.Id = null;
                        pliRecords.push(value);
                    }
                    for (const [key, value] of this.idToPMMap) {
                        value.Id = null;
                        pmRecords.push(value);
                    }
                    this.chunks = [];
                    var temp = new Map();
                    var count = 0;
                    for (const [key, value] of this.idToPMEMap) {
                        value.Id = null;
                        pmeRecords.push(value);
                        count++;
                        if (count == this.chunkSize ) {
                            temp.set(key, this.idToPMEMap.get(key));
                            this.chunks.push(temp);
                            temp = new Map();
                            count = 0;
                        } else {
                            temp.set(key, this.idToPMEMap.get(key));
                        }
                    }
                    if (count > 0 && count < this.chunkSize) {
                        this.chunks.push(temp);
                    }
                    this.processItems(Object.fromEntries(this.idToPLIMap), Object.fromEntries(this.idToPMMap), Object.fromEntries(this.chunks[this.currentState - 1]));
                    
                }
            })
            .catch(error => {
                var errMessage = error.body.message;
                this.showToast("Error", errMessage, "error", "dismissable");
                this.error = error;
                this.showSpinner = false;
            });
    }
    processItems(pliRecords, pmRecords, pmeRecords) {
        processBatchItems({PMEList : JSON.stringify(pmeRecords), PMList : JSON.stringify(pmRecords), PLIList : JSON.stringify(pliRecords), newYear : this.selectedNewYear, pricingTool : this.selectedPricingTool, currentState : this.currentState, totalChunks : this.chunks.length})
        .then(respose => {
            this.getBatchStatus();
        }).catch(error => {
            var errMessage = error.body.message;
            this.showToast("Error", errMessage, "error", "dismissable");
            this.error = error;
            this.showSpinner = false;
        })
    }
    getBatchStatus() {
        this._interval = setInterval(() => {
            getBatchJobResult({ pricingTool: this.selectedPricingTool })
                .then(response => {
                    if (this.isPreviousBatchResult) {
                        if (response.batchJobId == undefined){
                            clearInterval(this._interval);
                            this.showSpinner = false;
                        }
                        else if (response.batchJobId != null && (response.status == 'Failed' || response.status == 'Aborted' || response.NumberOfErrors != '0')) {
                            this.showToast("Error", "New year price creation failed.", "error", "dismissable");
                            clearInterval(this._interval);
                            this.showInProgressBatchStatus = false;
                            this.showSpinner = false;
                        } else if (response.status == 'Completed') {
                            this.progress = 100;
                            clearInterval(this._interval);
                            this.showInProgressBatchStatus = false;
                            this.showSpinner = false;
                        } else {
                            this.showInProgressBatchStatus = true;
                            this.showSpinner = false;
                            this.showRadioDisabled = false;
                            this.showPricingOptions = false;
                            this.progress = this.batchClasses.indexOf(response.ApexClassName) > -1 ? 33 * this.batchClasses.indexOf(response.ApexClassName) : this.progress;
                        }
                    } else {
                        if (this.firstJobID != response.batchJobId) {
                            this.processedItems = 0;
                        }
                        if (this.firstJobID && response.TotalJobItems && response.JobItemsProcessed && this.processedItems != parseInt(response.JobItemsProcessed, 10)) {
                            var temp = this.batchClasses.indexOf(response.ApexClassName) > -1 ? 33 * this.batchClasses.indexOf(response.ApexClassName) : 0;
                            this.progress = temp > this.progress ? temp : this.progress;
                            if (parseInt(response.TotalJobItems, 10) > 0 && (this.progress + parseInt((33 / parseInt(response.TotalJobItems, 10)), 10)) < 100) {
                                if (this.progress < 66) {
                                    this.progress += parseInt((33 / (parseInt(response.TotalJobItems, 10))), 10);
                                } else if(this.processedItems % 2 == 0) {
                                    this.progress += Math.ceil((33 / (parseInt(response.TotalJobItems, 10) * this.chunks.length)));
                                } else {
                                    this.progress += Math.floor((33 / (parseInt(response.TotalJobItems, 10) * this.chunks.length)));
                                }
                                this.processedItems = parseInt(response.JobItemsProcessed, 10);
                            }
                        }
                        else if (response.batchJobId != null && (response.status == 'Failed' || response.status == 'Aborted' || response.NumberOfErrors != '0')) {
                            this.showToast("Error", "New year price creation failed.", "error", "dismissable");
                            this.showInProgressBatchStatus = false;
                            this.showSpinner = false;
                            clearInterval(this._interval);
                        }
                        else if (response.status == ('Processed : ' + this.currentState + '/' + this.chunks.length)) {
                            if (this.currentState < this.chunks.length) {
                                this.currentState++;
                                this.idToPLIMap = new Map();
                                this.idToPMMap = new Map();
                                this.processItems(null, null, Object.fromEntries(this.chunks[this.currentState - 1]));
                            }
                        }
                        else if (response.status == 'Completed') {
                            if(this.attributeToPercentInput.size > 0){
                                this.attributeToPercentMap = [];
                            }
                            this.progress = 100;
                            this.showInProgressBatchStatus = false;
                            this.showSpinner = false;
                            this.showRadioDisabled = true;
                            this.showPricingOptions = true;
                            clearInterval(this._interval);
                            for (var key of this.attributeToPercentInput.keys()) {
                                this.attributeToPercentMap.push({ value: this.attributeToPercentInput.get(key), key: key, currency: (this.countryToLocalCurrencyMap.get(this.getByValue(this.attributeLabelMap, key)) ? this.countryToLocalCurrencyMap.get(this.getByValue(this.attributeLabelMap, key)) : this.defaultCurrency)});
                            }
                            this.idToPMEMap = new Map();
                            this.chunks = [];
                            if (this.showSuccess) {
                                this.showToast("Success", "New Year pricing is created, Please review all your changes to activate price", "success", "dismissable");
                                this.showPercentageInputWithButton = true;
                                this.showProgessBar = false;
                                this.showActivatePriceListButton = true;
                                updateCustomSetting({batchJobId: '', pricingTool: this.selectedPricingTool});
                                location.reload();
                            }
                            else {
                                this.showToast("Success", "New Year pricing is created, Please review all your changes to activate price", "success", "dismissable");
                                updateCustomSetting({batchJobId: '', pricingTool: this.selectedPricingTool});
                                location.reload();
                            }
                        }
                        this.firstJobID = response.batchJobId;
                    }
                    this.isPreviousBatchResult = false;
                })
        }, 500);
    }
    activatePLI(event) {
        activatePriceBookEntries({ selectedPricingYear: this.selectedNewYear, pricingTool: this.selectedPricingTool})
        .then(result => {
            if (result == 'Activated') {
                this.showToast("Success", "New Year price is activated successfully.", "success", "dismissable");
                this.showSpinner = false;
                this.showPartialPricing = false;
                this.showPercentageInput = false;
                this.showPricingOptions = true;
                this.selectedPricingOption = undefined;
                this.selectedCategory = undefined;
                this.selectedNewYear = undefined;
                this.selectedExistingYear = undefined;
                this.nonActivePricingYears = undefined;
                this.disablePercentageInput = false;
                this.disableExistingYearPicklist = false;
                this.disableNewYearPicklist = false;
                location.reload();
            }
            else if (result == 'Not Activated') {
                this.showToast("Error", "Please review all the price before activating the new year price.", "error", "dismissable");
            }
        })
        .catch(error => {
            var errMessage = error.body.message;
            this.showToast("Error", errMessage, "error", "dismissable");
            this.error = error;
        });
    }

}
