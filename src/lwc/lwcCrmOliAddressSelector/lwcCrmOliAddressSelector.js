import { LightningElement, api } from 'lwc';
import fetchAllDetails from '@salesforce/apex/CNT_CRM_OliAddressSelector.fetchAllDetails';
import searchAddressByfilter from '@salesforce/apex/CNT_CRM_OliAddressSelector.searchAddressByfilter';

export default class LwcCrmOliAddressSelector extends LightningElement {
    showSpinner = true;
    @api bnfId;
    @api selectedProductIndex;
    @api selectedAddressId;
    @api selectedAddressName;
    @api selectedSapContactId;
    @api selectedSapContactName;

    showError = false;
    errorMsg = new Set();

    bnf;
    accountRegionTerritory = '';
    originalAddressList;
    sapContactOptions = {};
    showAdditionalSearchFilter = false;
    showSearchResult = true;
    serachResultAddressList;
    addressToContactListMap = {};
    countryOptions = {};

    connectedCallback() {
        if (this.bnfId) {
            this.selectedAddressId = this.selectedAddressId ? this.selectedAddressId : '';
            this.selectedSapContactId = this.selectedSapContactId ? this.selectedSapContactId : '';
            this.fetchAllDetailsJS();
        } else {
            console.log('connectedCallback : bnfId not populated');
        }
    }

    fetchAllDetailsJS() {
        console.log('fetching Data...');
        fetchAllDetails({ bnfId: this.bnfId })
            .then(result => {
                if (result) {
                    this.bnf = result.bnf;
                    this.user = result.user;
                    this.countryOptions = result.countryOptions;
                    this.addressToContactListMap = result.addressToContactListMap;
                    this.originalAddressList = JSON.parse(JSON.stringify(result.addressList));
                    this.serachResultAddressList = this.originalAddressList;
                    this.accountRegionTerritory = this.bnf.Opportunity__r.Account.Region_Territory__c ? this.bnf.Opportunity__r.Account.Region_Territory__c : '';
                    this.helperSetAddressField(this.originalAddressList);

                    if (result.errorMsg) {
                        if (Array.isArray(result.errorMsg)) {
                            result.errorMsg.forEach(currentError => {
                                if (currentError === 'There is no Validated address on the account please go to Account and created and validate.') {
                                    window.open(result.returnURL, '_blank').focus();
                                }
                            });
                        }
                        this.handleError(result.errorMsg, 'errorMsg received from Controller');
                    }
                }
            }).catch(error => {
                this.handleError(error, 'error while fetching Oli Data');
            }).finally(() => {
                if (this.selectedAddressId) {
                    this.template.querySelectorAll('[data-type="checkbox"]').forEach(item => {
                        if (item.dataset.id === this.selectedAddressId) {
                            item.checked = true;
                        }
                    });
                    this.helperUpdateSapContactOptions();
                }
                this.showSpinner = false;
            });
    }

    helperSetAddressField(updatedAddress) {
        updatedAddress.forEach(add => {
            add.displayName = (add.International_Name__c && this.user.User_Country__c === add.Country__c) ? add.International_Name__c : add.Name;
            add.displayCity = (add.International_Name__c && this.user.User_Country__c === add.Country__c) ? add.International_City__c : add.City__c;
            add.displayStreet = (add.International_Name__c && this.user.User_Country__c === add.Country__c) ? add.International_Street__c : add.Street__c;

            add.completeLocalAddress = add.International_Name__c ? ('<Strong> ' + add.International_Name__c + '</strong><br/>') : '';
            add.completeLocalAddress += add.International_Street__c ? (add.International_Street__c + ', ') : '';
            add.completeLocalAddress += add.International_City__c ? (add.International_City__c + ', ') : '';
            add.completeLocalAddress += add.International_State__c ? (add.International_State__c + ', ') : '';
            add.completeLocalAddress += add.International_PostalCode__c ? (add.International_PostalCode__c + ', ') : '';
            add.completeLocalAddress += add.International_Country__c ? (add.International_Country__c + ', <br/>') : '';

            add.completeAddress = add.Name ? ('<Strong> ' + add.Name + '</strong><br/>') : '';
            add.completeAddress += add.Street__c ? (add.Street__c + ', ') : '';
            add.completeAddress += add.City__c ? (add.City__c + ', ') : '';
            add.completeAddress += add.State__c ? (add.State__c + ', ') : '';
            add.completeAddress += add.PostalCode__c ? (add.PostalCode__c + ', ') : '';
            add.completeAddress += add.Country__c ? (add.Country__c + '.') : '.';
        });
    }

    helperUpdateSapContactOptions() {
        if (this.selectedAddressId) {
            this.sapContactOptions = this.addressToContactListMap[this.selectedAddressId];
            // to set selected address details in Selected Addresses and Contacts section
            this.serachResultAddressList.forEach(add => {
                if (add.Id === this.selectedAddressId) {
                    this.addressDetails = (add.completeLocalAddress ? (add.completeLocalAddress + '<br/>') : '') + add.completeAddress;
                    this.selectedAddressName = add.displayName;
                }
            });
            if (!this.sapContactOptions) {// address selected is outside search result(1st time open scenario)
                if (this.selectedAddressName) {
                    this.sapContactOptions = [
                        { label: this.selectedSapContactName, value: this.selectedSapContactId },
                        { label: 'No Contact Selected', value: '' }
                    ];
                } else {
                    this.sapContactOptions = [{ label: 'N/A', value: '' }];
                }
            }
        } else {
            this.selectedAddressName = '';
            this.selectedSapContactId = '';
            this.selectedSapContactName = '';
            this.addressDetails = '';
            this.sapContactOptions = [];
        }
    }

    handleAddressChange(event) {
        try {
            this.showSpinner = true;
            let selectedAddress = event.currentTarget.dataset.id;
            if (event.target.checked) { //if address is selected(checkbox gets ticked)
                this.template.querySelectorAll('[data-type="checkbox"]').forEach(item => {
                    if (item.checked && selectedAddress === item.dataset.id) {
                        // address selected was outside search result before (selected same address in the searched result)
                        this.selectedSapContactId = (this.selectedAddressId === item.dataset.id) ? this.selectedSapContactId : '';
                        this.selectedAddressId = item.dataset.id;
                    } else { //unchecked all other addresses
                        item.checked = false;
                    }
                });
            } else {
                this.selectedAddressId = '';
                this.selectedSapContactId = '';
            }
        } catch (error) {
            this.handleError(error, 'error while handling address value Change');
        } finally {
            this.helperUpdateSapContactOptions();
            this.showSpinner = false;
        }
    }

    handleSapContactChange(event) {
        this.selectedSapContactId = event.target.value;
        this.addressToContactListMap[this.selectedAddressId].forEach(sc => {
            if (sc.value === this.selectedSapContactId) {
                this.selectedSapContactName = sc.label;
            }
        });
    }

    switchSearchFilter() {
        if (this.showAdditionalSearchFilter === true) {
            this.serachResultAddressList = this.originalAddressList;
            this.showSearchResult = true;
            this.showAdditionalSearchFilter = false;
        } else {
            this.showSearchResult = false;
            this.showAdditionalSearchFilter = true;
        }
    }

    handleEnter(event) {
        if (event.keyCode === 13) {
            this.handleSearch();
        }
    }

    handleSearch(event) {
        let searchedCountry = this.template.querySelector('[data-id="searchCountry"]').value;
        let searchedName = this.template.querySelector('[data-id="searchName"]').value;
        let searchedCity = this.template.querySelector('[data-id="searchCity"]').value;

        searchAddressByfilter({ accountRegionTerritory: this.accountRegionTerritory, searchedCountry: searchedCountry, searchedName: searchedName, searchedCity: searchedCity })
            .then(result => {
                if (result) {
                    this.addressToContactListMap = result.addressToContactListMap;
                    this.serachResultAddressList = JSON.parse(JSON.stringify(result.addressList));
                    this.helperSetAddressField(this.serachResultAddressList);
                    this.showSearchResult = true;
                }
            }).catch(error => {
                this.handleError(error, 'error while searching Data');
            }).finally(() => {
                if (this.selectedAddressId) {
                    this.template.querySelectorAll('[data-type="checkbox"]').forEach(item => {
                        if (item.dataset.id === this.selectedAddressId) {
                            item.checked = true;
                        }
                    });
                    this.helperUpdateSapContactOptions();
                }
                this.showSpinner = false;
            });
    }

    handleOk(event) {
        try {
            console.log('selectedAddressId : ', this.selectedAddressId + ' selectedAddressName : ', this.selectedAddressName);
            console.log(' selectedSapContactId : ', this.selectedSapContactId + ' selectedSapContactName : ', this.selectedSapContactName);
            const selectedEvent = new CustomEvent("saveevent", {
                detail: {
                    selectedProductIndex: this.selectedProductIndex,
                    selectedAddressId: this.selectedAddressId,
                    selectedSapContactId: this.selectedSapContactId,
                    selectedAddressName: this.selectedAddressName,
                    selectedSapContactName: this.selectedSapContactName
                }
            });
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            this.handleError(error, 'error while ok');
        }
    }

    handleCancel() {
        const cancelEvent = new CustomEvent("cancelevent", {
            detail: {}
        });
        this.dispatchEvent(cancelEvent);
    }

    handleError(error, methodName) {
        console.log(error);
        console.log(methodName + ' : ' + JSON.stringify(error));
        this.errorMsg = new Set();
        if (Array.isArray(error)) {
            error.forEach(currentError => {
                this.errorMsg.add(currentError);
            });
        } else {
            var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
            if (JSON.parse(err).fieldErrors) {
                let fieldError = JSON.parse(err).fieldErrors;
                for (let [key, value] of Object.entries(fieldError)) {
                    this.errorMsg.add(key + ': ' + value[0].message);
                }
            } else {
                this.errorMsg.add(err == "{}" ? 'Unexpected error !!!' : err);
            }
        }
        this.showError = true;
        this.showSpinner = false;
    }

    get disableSapContactSelection() {
        return this.selectedAddressId ? false : true;
    }

    get filterLabel() {
        let accountRegion = (this.bnf && this.bnf.Opportunity__r.Account.Region_Territory__c) ? this.bnf.Opportunity__r.Account.Region_Territory__c : '';
        if (this.showAdditionalSearchFilter) {
            return 'Back to addresses in ' + accountRegion;
        } else {
            return 'Search for addresses outside ' + accountRegion;
        }
    }

}