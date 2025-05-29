/* eslint-disable radix */
/* eslint-disable no-else-return */
/* eslint-disable consistent-return */
/* eslint-disable no-alert */
/* eslint-disable vars-on-top */
/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement,api,track,wire } from 'lwc';
import fetchTerritory from '@salesforce/apex/CNT_CRM_ProductHierarchyVisual.fetchTerritory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ProductTerritorySelector extends LightningElement {
    @track deliveryCountries;
    @track recordRows = [];
    @api productId = '';
    @track showSpinner = true;
    @api opportunityRecord;
    @api noOfCountry = 1;
    @api noOfLicense = 1;
    comboBoxDefaultClass = 'select-auto-width lightningComboBoxRemoveError';
    @track isOnlyOneProdcutInList = true;
    @wire(fetchTerritory,{productId:'$productId'})
        wiredMethod({ error, data }) {
            if (data) { 
                this.showSpinner = true;
                this.deliveryCountries = data;
                this.fetchNumberOfCountryRows();
                this.showSpinner = false;
             }else if (error) { 
                this.showSpinner = false;
                this.deliveryCountries = undefined;
            }
        }
    
    addMoreRow(event){
        var previousIndex = this.recordRows[this.recordRows.length-1].rowIndex;
        var nextObj = {};
        nextObj.rowIndex = previousIndex +1;
        nextObj.Number_of_License__c = 1;
        nextObj.Delivery_Country__c = this.deliveryCountries[0];
        nextObj.errorStyle = 'removeError';
        this.recordRows.push(nextObj);
        this.getRowCount();
    }
    removeRow(event){
        var rowIndexToDelete = event.target.name;
        if(this.recordRows.length !== 1){
            this.recordRows.splice(rowIndexToDelete, 1);
        }
        this.getRowCount();
    }
    getRowCount(){
        if(this.recordRows.length === 1){
            this.isOnlyOneProdcutInList = true;
        }else{
            this.isOnlyOneProdcutInList = false;
        }
    }
    fetchCurrentDeliveryCountry(event){
        var rowIndexToUpdate = event.target.name;
        this.recordRows[rowIndexToUpdate].Delivery_Country__c = event.target.value;
    }
    fetchlicenseValue(event){
        var rowIndexToUpdate = event.target.name;
        if(!Number.isNaN(parseInt(event.target.value))) {
            this.recordRows[rowIndexToUpdate].Number_of_License__c = parseInt(event.target.value);
            event.target.value = parseInt(event.target.value);
        } else {
            event.target.value = 1;
        }
        
    }    
    @api fetchcountryList(){
        this.duplicateError = '';
        var ind1 = 0;
        var ind2 = 0;
        var delievryCtrSet = new Set(); 
        var isDuplicateCountryFound = false;
        var isNbrOfLicenseZeroFound = false;
        var nbrOficenseSelected = 0;
        var isInvalidCountryNameFound = false;
        var fetchAllCountryCmp = this.template.querySelectorAll('c-select-box-look-up');
        for(ind1=0; ind1<this.recordRows.length; ind1++ ){
            var eachSelectedCountry = fetchAllCountryCmp[ind1].inputCountryValue;
            this.recordRows[ind1].Delivery_Country__c = eachSelectedCountry;
            if(delievryCtrSet.has(this.recordRows[ind1].Delivery_Country__c)){
                isDuplicateCountryFound = true;
                fetchAllCountryCmp[ind1].errorStyle = 'border:1px solid #C23934;';
            }else{
                fetchAllCountryCmp[ind1].errorStyle = 'border: "";'; 
                delievryCtrSet.add(this.recordRows[ind1].Delivery_Country__c)
            }
            if(parseInt(this.recordRows[ind1].Number_of_License__c) <= 0){
                isNbrOfLicenseZeroFound = true;
            }
            if(!(this.deliveryCountries).includes(this.recordRows[ind1].Delivery_Country__c)){
                isInvalidCountryNameFound = true;
                fetchAllCountryCmp[ind1].errorStyle = 'border:1px solid #C23934;';
            }
            nbrOficenseSelected = nbrOficenseSelected + parseInt(this.recordRows[ind1].Number_of_License__c);
        }
        if(isDuplicateCountryFound || isNbrOfLicenseZeroFound || isInvalidCountryNameFound || nbrOficenseSelected !== parseInt(this.noOfLicense)){
            if(isInvalidCountryNameFound){
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'You entered invalid Country.',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }else if(isDuplicateCountryFound){
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'Duplicate Countries found, please select unique Countries.',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }else if(isNbrOfLicenseZeroFound){
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'Number of license must be greater than 0.',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }else if(nbrOficenseSelected !== parseInt(this.noOfLicense)){
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Number of license does not matched. Total no of license should be ' + this.noOfLicense,
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
            return 'error';
        } else {
            var objSendToAura = {};
            objSendToAura.productId = this.productId;
            objSendToAura.countryAndLicense = this.recordRows;
            objSendToAura.currencyIsoCode = this.opportunityRecord.CurrencyIsoCode;
            console.log(objSendToAura);
            return objSendToAura;
        }
    }
    @api fetchNumberOfCountryRows(){
        var i=0;
        this.recordRows = [];
        for(i=0;i<this.noOfCountry;i++){
            var nextObj = {}; 
            nextObj.rowIndex =  0; 
            nextObj.Number_of_License__c = 1;
            nextObj.Delivery_Country__c = this.deliveryCountries[0];
            nextObj.errorStyle = 'removeError';
            this.recordRows.push(nextObj);
        }
        this.getRowCount();
    }
}