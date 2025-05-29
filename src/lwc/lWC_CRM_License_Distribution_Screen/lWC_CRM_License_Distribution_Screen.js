/* eslint-disable vars-on-top */
/* eslint-disable radix */
/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import getProductDetails from '@salesforce/apex/CNT_CRM_ProductHierarchyVisual.getProductDetails';
import fetchTerritory from '@salesforce/apex/CNT_CRM_ProductHierarchyVisual.fetchTerritory';

export default class LWC_CRM_License_Distribution_Screen extends LightningElement { 
    @api showModal = false;
    @api productRecord;
    @api opportunityRecord;
    @track showSpinner = true;
    @track selectTerritory = false;
    @track productId;
    @track disableSave = true;
    @api hidemodal = 'slds-modal__container';
    @track noOfLicense = 1;
    @track noOfCountry = 1;
    @track selectCountries = false;
    @track globalProductName = undefined;
    @track regionalProductName = undefined;
    @track localProductName = undefined;
    @track selectedTerritory = undefined;
    @track territories = [];
    @api territory;
    currentLocalHierarchyChain = '';
    materialLayer = false;
    connectedCallback() {
        this.getproductRecordList(this.productRecord.Hierarchy_Chain__c, 0, null, false);
        this.globalProductName = this.productRecord.Name;
        this.selectedTerritory = this.territory;
    }


    @wire(fetchTerritory)
    wiredTerritory({data}) {
        if (data) {
            this.territories = data;
        }
    }

    getproductRecordList(currentChain, currentLayer, territory, isMaterialLevel) {
        this.showSpinner = true;
        getProductDetails({ currentChain : currentChain + '->' , 'territory' : territory, 'isLWCScreen' : true, 'isMaterialLevel' : isMaterialLevel})
            .then(result => {
                var verticalList = this.template.querySelectorAll("c-vertical-list");
                var index = currentLayer;
                while(index < verticalList.length) {
                    if(index === currentLayer) {
                        verticalList[currentLayer].productList = result;
                        this.showSpinner = false;
                    } else {
                        verticalList[index].productList = undefined;
                    }
                    index++;
                }
                this.error = undefined;
            })
            .catch(error => {
                console.log(error);       
            });
    }
    openModal() {    
        this.showModal = true;
    }
    closeModal() {   
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('closeLDSModal'));
    }

    getNextLayerProducts(event) {
        this.productId = event.detail.productId;
        this.selectTerritory = false;
        this.disableSave = true;
        if(parseInt(event.detail.currentLayer) === 1) {
            this.regionalProductName = event.detail.productName;
            this.localProductName = undefined;
            this.materialLayer = false;
        } else if(parseInt(event.detail.currentLayer) === 2) {
            this.localProductName = event.detail.productName;
            this.currentLocalHierarchyChain = event.detail.hierarchyChain;
            this.materialLayer = true;
        }
        if(parseInt(event.detail.currentLayer) === 3) {
            this.selectCountries = true;
            this.materialLayer = true;
        } else {
            this.selectCountries = false;
            this.noOfCountry = 1;
            this.noOfLicense = 1;
            if(parseInt(event.detail.currentLayer) !== 2) {
                this.getproductRecordList(event.detail.hierarchyChain, event.detail.currentLayer, null, false);
            } else {
                this.getproductRecordList(event.detail.hierarchyChain, event.detail.currentLayer, this.selectedTerritory, true);
            }
            
        }
    }

    handleSave() {
        var countryList = this.template.querySelector("c-product-territory-selector").fetchcountryList();
        console.log('--------countryList-----popup closing----');
        console.log('A' + countryList + 'B');
        if(countryList !== undefined && countryList !== '' && countryList !== 'error' && countryList !== null) {
            this.hidemodal = 'slds-modal__container slds-hide';
            this.dispatchEvent(new CustomEvent('save', {'detail' : countryList}));
        }
    }

    handleChange(event) {
        if(!Number.isNaN(parseInt(event.target.value))) {
            if(event.target.name === 'noOfCountry') {
                this.noOfCountry = parseInt(event.target.value);
            } else if(event.target.name === 'noOfLicense') {
                this.noOfLicense = parseInt(event.target.value);
            }
            event.target.value = parseInt(event.target.value);
        } else {
            event.target.value = 1;
        }
    }
    handleApply() {
        var inputCmpList = this.template.querySelectorAll(".inputCmp");
        var isValid = true;
        if(inputCmpList[0].value === '' || parseInt(inputCmpList[0].value) <= 0 || parseInt(inputCmpList[0].value) > 99) {
            inputCmpList[0].setCustomValidity("Please enter positive value up to 99");
            inputCmpList[0].reportValidity();
            isValid = false;
        } else {
            inputCmpList[0].setCustomValidity("");
            inputCmpList[0].reportValidity();
        }
        if(inputCmpList[1].value === '' || parseInt(inputCmpList[1].value) <= 0 || parseInt(inputCmpList[1].value) > 999) {
            inputCmpList[1].setCustomValidity("Please enter positive value up to 999");
            inputCmpList[1].reportValidity();
            isValid = false;
        } else {
            inputCmpList[1].setCustomValidity("");
            inputCmpList[1].reportValidity();
        }
        if(parseInt(inputCmpList[0].value) > parseInt(inputCmpList[1].value)) {
            inputCmpList[0].setCustomValidity("Number of countries should be less than or equal to number of Licences.");
            inputCmpList[0].reportValidity();
            isValid = false;
        }
        if(isValid) {
            this.selectTerritory = true;
            this.disableSave = false;
            var ptsCmp = this.template.querySelector("c-product-territory-selector");
            if(ptsCmp !== null){
                this.template.querySelector("c-product-territory-selector").fetchNumberOfCountryRows();
            }
        } else {
            this.disableSave = true;
            this.selectTerritory = false;
        }
    }

    handleTerritoryChange(event) {
        this.selectedTerritory = event.detail;
        if(this.selectedTerritory === '--None--') {
            this.selectedTerritory = null;
        }
        if(this.materialLayer) {
            this.selectCountries = false;
            this.selectTerritory = false;
            this.disableSave = true;
            this.noOfCountry = 1;
            this.noOfLicense = 1;
            this.getproductRecordList(this.currentLocalHierarchyChain, 2, this.selectedTerritory, true);
        }
        
    }
}