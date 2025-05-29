import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getProductsAndBundles from '@salesforce/apex/CNT_CSM_TrainingManagement.getProductsAndBundles';
import getRelatedCatalogs from '@salesforce/apex/CNT_CSM_TrainingManagement.getRelatedCatalogs';
import saveLearningCatalogRelationships from '@salesforce/apex/CNT_CSM_TrainingManagement.saveLearningCatalogRelationships';
import getLearningCatalogRelationships from '@salesforce/apex/CNT_CSM_TrainingManagement.getLearningCatalogRelationships';

export default class Lwc_csm_lms_training_management extends NavigationMixin(LightningElement) {

    @api recordId;
    @track error;
    isTrainingModalOpen = false;
    modalSpinner = true;
    CmpSpinner = true;
    productRelatedBundlesList;
    productList=[];
    isModalDataLoaded;
    @track trainingManagementWrapper;
    @track elementVisibilty; 
    trainingProducts;
    bundlesByTrainingProduct;
    @track catalogs;
    selectedCatalogs;
    relatedRecordsAvailable = false;
    catalogRelationships;
    @track prodcatdata = [];
    account_type;
    account_type_flag = false;

    connectedCallback() {
        this.init();
        this.getLearningCatalogs();
    }

    init() {
        this.elementVisibilty = {showProductsElement: false, showBundles: false, showCatalogs: false, showAddLicenseButton: false,
            showCatalogPage: false, showAddLicensePage: false, showBackButton: false, showCloseModalButton: true};
        this.trainingManagementWrapper = {selectedProduct: 'Please Specify', selectedBundle: 'Please Specify', selectedCatalogs: [], catalogRelationships: []};
    }

    getLearningCatalogs() {
        this.CmpSpinner = true;
        this.prodcatdata = [];
        getLearningCatalogRelationships({trainingManagementId: this.recordId})
            .then(result => {
                this.trainingManagementWrapper.catalogRelationships = result;
                this.catalogRelationships = result;
                this.CmpSpinner = false;
                this.relatedRecordsAvailable = result.length > 0 ? true : false;
                for(var i = 0; i < result.length; i++) {
                    if(this.productList.indexOf(result[i].Catalog__r.Product__r.Name) == -1){
                        this.productList.push(result[i].Catalog__r.Product__r.Name);
                        console.log(result[i].Training_Management__r.Account_Name__r.Type2__c);
                        this.account_type = result[i].Training_Management__r.Account_Name__r.Type2__c;
                    }
                }
                
                for(var i=0;i < this.productList.length; i++){
                    var prd = this.productList[i];
                    var catlog = [];
                    for(var j = 0; j < this.catalogRelationships.length; j++) {
                        if(result[j].Catalog__r.Product__r.Name == prd){
                            catlog.push(result[j]);
                        }
                    }
                    this.prodcatdata.push({key: prd, value:catlog});   
                }
            })
            .catch(error => {
                this.error = error;
                this.showErrorToast();
                this.CmpSpinner = false;
        });
    }

    navigateToCatalogRelationshipRelatedList(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                relationshipApiName: 'Learning_Catalog_Relationships__r',
                actionName: 'view'
            }
        });
    }

    navigateToCatalogRelationshipRecord(event) {
        var catalogRelationshipId = event.currentTarget.dataset.value;
        var viewRecord = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Learning_Catalog_Relationships__r',
                recordId: catalogRelationshipId,
                actionName: 'view'             
            }
        };
        this[NavigationMixin.Navigate](viewRecord);
    }

    getPicklistValues() {
        getProductsAndBundles()
            .then(result => {
                this.productRelatedBundlesList = result;
                this.trainingManagementWrapper.selectedProduct = 'Please Specify';
                var trainingProducts = [{label: 'Please Specify', value: 'Please Specify'}];
                for(var i = 0; i < result.length; i++) {
                    trainingProducts.push({label: result[i].productName, value: result[i].productName});
                }
                this.trainingProducts = trainingProducts;
                this.elementVisibilty.showProductsElement = true;
                this.elementVisibilty.showCatalogPage = true;
                this.modalSpinner = false;
            })
            .catch(error => {
                this.error = error;
                this.showErrorToast();
                this.modalSpinner = false;
        });
    }
    
    findCatalogs() {
        this.modalSpinner = true;
        getRelatedCatalogs({selectedProduct : this.trainingManagementWrapper.selectedProduct, 
            selectedBundle : this.trainingManagementWrapper.selectedBundle,
            account_type : this.account_type})
        .then(result => {
            var catalogs = [];
            for(var i = 0; i < result.length; i++) {
                catalogs.push({label: result[i].Catalog__c, value: result[i].Id});
            }
            if(result.length == 0){
                this.account_type_flag = true;
                this.account_type_flag_message = 'No Catalog is available on '+this.account_type +' account type for '+this.trainingManagementWrapper.selectedProduct+' Product';
            }
            this.catalogs = catalogs;
            this.elementVisibilty.showCatalogs = true;
            this.modalSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.showErrorToast();
            this.modalSpinner = false;
        });
    }

    openTrainingModal() {
        this.isTrainingModalOpen = true;
        this.modalSpinner = true;
        this.init();
        this.getPicklistValues();
    }

    closeModal() {
        this.isTrainingModalOpen = false;
        this.CmpSpinner = true;
        //this.getLearningCatalogs();
    }

    openAddLicensePage() {
        this.elementVisibilty.showAddLicensePage = true;
        this.elementVisibilty.showCatalogPage = false;
        this.elementVisibilty.showAddLicenseButton = false;
        this.elementVisibilty.showBackButton = true;
        this.elementVisibilty.showSaveLearningButton = true;
        this.elementVisibilty.showCloseModalButton = false;
    }

    openCatalogPage() {
        this.elementVisibilty.showAddLicensePage = false;
        this.elementVisibilty.showCatalogPage = true;
        this.elementVisibilty.showAddLicenseButton = false;
        this.elementVisibilty.showBackButton = false;
        this.elementVisibilty.showSaveLearningButton = false;
        this.elementVisibilty.showCloseModalButton = true;
    }

    selectTrainingProduct(event) {
        this.trainingManagementWrapper.selectedProduct = event.detail.value;
        var bundles;
        this.bundlesByTrainingProduct = [{label: 'Please Specify', value: 'Please Specify'}];
        if(event.detail.value == 'Please Specify') {
            this.trainingManagementWrapper.selectedBundle = 'Please Specify';
            this.selectedCatalogs = [];
            this.trainingManagementWrapper.selectedCatalogs = [];
            this.elementVisibilty.showAddLicenseButton = false;
            this.elementVisibilty.showCatalogs = false;
            this.elementVisibilty.showBundles = false;
        } else {
            for(var i = 0; i < this.productRelatedBundlesList.length; i++) {
                if(this.productRelatedBundlesList[i].productName == this.trainingManagementWrapper.selectedProduct) {
                    bundles = this.productRelatedBundlesList[i].bundles;
                    break;
                }
            }
            for(var i = 0; i < bundles.length; i++) {
                this.bundlesByTrainingProduct.push({label: bundles[i], value: bundles[i]});
            }
            this.elementVisibilty.showFindCatalogButton = true;// PRM:827 Do not show the bundle picklist, in order to integrate new LMS(On Point), new LMS does not support bundle
        }
    }

    selectBundle(event) {
        this.trainingManagementWrapper.selectedBundle = event.detail.value;
        if(event.detail.value == 'Please Specify') {
            this.selectedCatalogs = [];
            this.trainingManagementWrapper.selectedCatalogs = [];
            this.elementVisibilty.showAddLicenseButton = false;
            this.elementVisibilty.showCatalogs = false;
        } else {
            this.elementVisibilty.showFindCatalogButton = true;
        }
    }

    selectCatalogs(event) {
        var selectedCatalogs = [];
        for(var i = 0; i < event.detail.value.length; i++) {
            var selectedLabel = event.target.options.find(opt => opt.value === event.detail.value[i]).label;
            var selectedValue = event.detail.value[i];
            var learningCatRelationship = {Training_Management__c: this.recordId, Catalog__c: selectedValue};
            selectedCatalogs.push({label: selectedLabel, value: selectedValue, learningCatalogRelationship: learningCatRelationship});
        }
        this.trainingManagementWrapper.selectedCatalogs.push(Array.from(selectedCatalogs));
        this.trainingManagementWrapper.selectedCatalogs = JSON.parse(JSON.stringify(this.trainingManagementWrapper.selectedCatalogs));
        this.selectedCatalogs = selectedCatalogs;
        this.elementVisibilty.showAddLicenseButton = selectedCatalogs.length > 0 ? true : false;
    }

    selectNumberOfLicenses(event) {
        var currentIndex = event.currentTarget.dataset.index;
        this.selectedCatalogs[currentIndex].learningCatalogRelationship.Licenses__c = event.detail.value;
    }

    saveLearning() {
        var isValid = this.checkValidity();
        if(isValid) {
            for(var i = 0; i < this.selectedCatalogs.length; i ++) {
                this.trainingManagementWrapper.catalogRelationships.push(this.selectedCatalogs[i].learningCatalogRelationship);
            }
            console.log('Json - '+JSON.stringify(this.trainingManagementWrapper.catalogRelationships));
            saveLearningCatalogRelationships({learningCatalogRelationshipsJSON : JSON.stringify(this.trainingManagementWrapper.catalogRelationships)})
            .then(result => {
                var toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'Learning added successfully!!',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                this.closeModal();
                this.getLearningCatalogs();
            })
            .catch(error => {
                this.error = error;
                this.showErrorToast();
                this.modalSpinner = false;
            });
        }
    }

    checkValidity() {
        const isInputsCorrect = [...this.template.querySelectorAll('.catalogForm')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        return isInputsCorrect;
    }

    showErrorToast() {
        var error = this.error;
        if(error != undefined && error != null && error != '' && error.body != undefined && error.body != null && error.body != '') {
            var errorMessage = error.body.message;
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }  
}