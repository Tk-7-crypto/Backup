import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getDetail from "@salesforce/apex/CNT_CPQ_QuoteCreation.getDetails";
import createQuoteAccToLicense from "@salesforce/apex/CNT_CPQ_QuoteCreation.createQuoteAccToLicense";
import getNumberOfScenario from "@salesforce/apex/CNT_CPQ_QuoteCreation.getNumberOfScenario";
import collectionToolRecordsErrorMessage from "@salesforce/apex/CNT_CPQ_QuoteCreation.collectionToolRecordsErrorMessage";
import createRDSQuote from '@salesforce/apex/CNT_CPQ_QuoteCreation.createRDSQuote';
import { loadStyle } from 'lightning/platformResourceLoader';
import customCSS from '@salesforce/resourceUrl/toastMessageCSS';
import { NavigationMixin } from 'lightning/navigation';
import getQuotesList from "@salesforce/apex/CNT_CPQ_QuoteClone.getQuotesList";
import cloneQuoteWithDetails from '@salesforce/apex/CNT_CPQ_QuoteClone.cloneQuoteWithDetails';
import getValidateData from '@salesforce/apex/CNT_CPQ_QuoteClone.getValidateData';
import checkPricingAssistant from '@salesforce/apex/CNT_CPQ_QuoteCreation.checkPricingAssistant';
const columns = [
    { label: 'Pricing tool', fieldName: 'pricingTool' },
    { label: 'Pathway', fieldName: 'pathway' },
    { label: 'Access(user has access)', fieldName: 'hasAccess' },
];
const columnsForQuoteList = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Primary', fieldName: 'Primary__c' },
    { label: 'Quote type', fieldName: 'Quote_Type__c' },
    { label: 'Stage', fieldName: 'Approval_Stage__c' },
];

export default class LWC_CPQ_QuoteCreation extends NavigationMixin (LightningElement) {
    @api recordId;
    @api objectApiName;
    value = '';
    error;
    @track spinner = true;
    @track options = [];
    @track successLabel = 'Next';
    @track optionType = 'Please select pricing tool to proceed.';
    @api gbu = '';
    @api pricingTools = [];
    selectedPricingTools;
    createCongaQuote;
    selectGBU = true;
    selectPricingTools = false;
    resultData = {};
    bidRecordTypeByPricingTools = new Map();
    pricingToolsByGBU = new Map();
    gbuByPricingTools = new Map();
    pricingToolsByPathways = new Map();
    resultMapByPricingTool = new Map();
    confirmScreen = false;
    confirmedData = [];
    columns = columns;
    @api header = 'Create New Quote';
    @api isUpdateQuote = false;
    @api createButton = 'Create';
    @api continueButton = 'Continue';
    @api opportunityId;
    isCreateQuote = true;
    tempGBUList = [];
    selectScenario = false;
    @api bidScenarios = '';
    @track sectionLabel = 'Please select bid scenario to proceed.';
    tempPricingToolList = [];
    @track bypassConfiguration = false;
    @track checkScenario = false;
    @track isPricingToolSelected = true;
    @track isScenarioSelected = true;
    @track noConfigReq = false;
    @track enableRadio = false;
    @track isClone = false;
    @track isCreate = false;
    @track continueCreate = false;
    completeConsentPT = 'Complete Consent';
    q2SolutionPT = 'Q2 Solutions';
    pathways = [];
    bypassConfigurationForObjects = ['Bid_History__c'];
    confirmationText = 'Please verify selected pricing tool access for Quote creation. Do you still want to continue?';
    actionOptions = [
        { label: 'Create', value: 'create' },
        { label: 'Clone', value: 'clone' },
    ];
    actionName = '';
    showQuoteList = false;
    columnsForQuoteList = columnsForQuoteList;
    showFreshDataOption = false;
    isFrehsData = false;
    showScenarioSelection = false;
    scenarioOptionsForClone =[];
    bidScenariosForClone ='';
    btnName = 'Next';
    @api listOfQuotes = [];
    selectedQuote = [];
    rdsNonSF = false;
    selectedPricingToolForNonSF = '';
    pricingToolForNonSF = [];
    selectedQuoteTypeForNonSF = '';
    quoteTypeForNonSF = [];
    selectedRequestTypeForNonSF = '';
    requestTypeForNonSF = [];
    oppName;
    upsellingOptionType = 'Please select upselling to proceed.';
    upsellingOptions = [];
    scenarioNumberForNonSF = '';
    scenarioDescription = '';
    quoteTypeToScenario;
    isRocheUser = false;
    hideUpdatedBidHistoryCheckBox = true;

    connectedCallback() {
        setTimeout(() => {
            this.getDetail(this.recordId);
            if (this.bypassConfigurationForObjects.includes(this.objectApiName)) {
                this.bypassConfigurationSelection();
            }
        }, 0.0005);
        this.isCreateQuote = !this.isUpdateQuote;
        this.selectedPricingTools = this.pricingTools;
    }

    renderedCallback() {
        loadStyle(this, customCSS);
    }
    
    getDetail(recordId){
        getDetail({recordId: recordId})
        .then(result => {
            if(result) {
                let strData1 = JSON.parse(result);
                let strData2 = [];
                if (this.bypassConfiguration === true) {
                    strData1.forEach(element => {
                        if (element.bidHistoryRecordType != null || element.bidHistoryRecordType != '') {
                            strData2.push(element);
                        }
                    });
                    if (strData2.length > 1) {
                        this.selectGBU = false;
                        this.selectPricingTools = true;
                        this.optionType = 'Please select pricing tool to proceed.';
                        strData2.forEach(element => {
                            this.pricingToolsByGBU.set(element.pricingTool, element.GBU);
                            this.pricingToolsByPathways.set(element.pricingTool, element.pathway);
                            let tempPricingTools = [];
                            if (!this.bidRecordTypeByPricingTools.has(element.bidHistoryRecordType)) {
                                this.bidRecordTypeByPricingTools.set(element.bidHistoryRecordType, tempPricingTools);
                            }
                            tempPricingTools = this.bidRecordTypeByPricingTools.get(element.bidHistoryRecordType);
                            tempPricingTools.push(element.pricingTool);
                            this.bidRecordTypeByPricingTools.set(element.bidHistoryRecordType, tempPricingTools);
                        });
                        this.bidRecordTypeByPricingTools.forEach( (val, key) => {
                            val.forEach(element => {
                                this.options.push({label: element, value: element});
                            });
                        });
                        this.options = [...this.options].sort((a, b) => this.sortDataByKey(a, b, 'label'));
                    } else {
                        strData2.forEach(element => {
                            this.gbu = element.GBU;
                            this.pricingTools.push(element.pricingTool);
                            this.pathways.push(element.pathway);
                            if (element.pricingTool === this.q2SolutionPT) {
                                this.noConfigReq = true;
                            }
                        });
                    }
                    this.getQuoteListForClone();
                } else {
                    strData1.forEach(data1 => {
                        this.resultMapByPricingTool.set(data1.pricingTool, data1);
                        let tempList = [];
                        if (data1.hasAccess == 'Yes') {
                            if (!this.gbuByPricingTools.has(data1.GBU)) {
                                this.gbuByPricingTools.set(data1.GBU, tempList);
                            }
                        }
                        if (this.gbuByPricingTools.has(data1.GBU)) {
                            tempList = this.gbuByPricingTools.get(data1.GBU);
                            tempList.push(data1.pricingTool);
                            this.gbuByPricingTools.set(data1.GBU, tempList);
                        }
                        if (data1.GBU == 'RDS Non-SF WRF') {
                            this.oppName = data1.oppName;
                            this.isRocheUser = data1.isRocheUser;
                            this.pricingToolForNonSF = [];
                            this.quoteTypeToScenario = data1.NonSFScenario;
                            data1.NonSFTools.forEach(element => {
                                this.pricingToolForNonSF.push({label : element, value : element});
                            })
                            this.quoteTypeForNonSF = [];
                            if (!this.isRocheUser) {
                                data1.NonSFBudgetTypes.forEach(element => {
                                    this.quoteTypeForNonSF.push({label: element, value: element});
                                })
                            } else {
                                this.quoteTypeForNonSF.push({label: 'CNF', value: 'CNF'});
                                this.selectedQuoteTypeForNonSF = 'CNF';
                                this.handleRequestedTypeValues();
                            }
                        }
                        this.pricingToolsByPathways.set(data1.pricingTool, data1.pathway);
                    });
                    this.gbuByPricingTools.forEach( (val, key) => {
                        this.upsellingOptions.push({label: key, value: key});
                    });
                    this.upsellingOptions = [...this.upsellingOptions].sort((a, b) => this.sortDataByKey(a, b, 'label'));
                    if (this.upsellingOptions.length == 1) {
                        this.gbu = this.upsellingOptions[0].value;
                        if (this.upsellingOptions[0].value == 'RDS Non-SF WRF') {
                            this.rdsNonSF = true;
                            this.gbu = this.upsellingOptions[0].value;
                        }
                        if (this.gbuByPricingTools.get(this.upsellingOptions[0].value).length == 1) {
                            this.selectPricingTools = false;
                            this.pricingTools.push(this.gbuByPricingTools.get(this.upsellingOptions[0].value));
                            this.getPathways();
                            if (!this.checkScenario) {
                                this.createQuoteAccToLicense();
                            }
                        } else {
                            this.selectPricingTools = true;
                        }
                        this.selectGBU = false;
                    }
                    this.spinner = false;
                }
                this.error = undefined;
            }
        }).catch(error => {
            this.spinner = !this.spinner;
            this.handleCancel();
            this.showToast("Error", error.body ? error.body.message : null , "Error");
        });
    }
    
    handleChangeForNonSFPricing(event) {
        this.pathways.push(this.pricingToolsByPathways.size !== 0 ? this.pricingToolsByPathways.get(event.detail.value) : null);
        this.selectedPricingToolForNonSF = event.detail.value;
    }

    handleChangeForNonSFQuoteType(event) {
        this.selectedQuoteTypeForNonSF = event.detail.value;
        this.handleRequestedTypeValues();
    }

    handleChangeForNonSFRequestType(event) {
        this.selectedRequestTypeForNonSF = event.detail.value;
    }

    handleDescription(event) {
        this.scenarioDescription = event.detail.value;
    }

    handleScenarioNumber(event) {
        this.scenarioNumberForNonSF = event.detail.value;
    }

    handleRequestedTypeValues() {
        this.requestTypeForNonSF = [];
        if (this.quoteTypeToScenario[this.selectedQuoteTypeForNonSF]) {
            this.quoteTypeToScenario[this.selectedQuoteTypeForNonSF].forEach(element => {
                if (this.selectedQuoteTypeForNonSF == 'CNF') {
                    if (this.isRocheUser && !element.includes('CNF')) {
                        this.requestTypeForNonSF.push({label : element, value : element});
                    } else if (!this.isRocheUser && element != 'WRF' && element != 'SSWRF') {
                        this.requestTypeForNonSF.push({label : element, value : element});
                    }
                } else {
                    this.requestTypeForNonSF.push({label : element, value : element});
                }
            })
        }
    }

    openAccessScreen() {
        this.selectGBU = false;
        this.selectPricingTools = false;
        var temp = [...this.pricingTools];
        temp.sort();
        temp.forEach( element => {
            this.confirmedData.push(this.resultMapByPricingTool.get(element));
        });
        if (this.confirmedData.length == 1) {
            this.createQuoteAccToLicense();
        } else {
            this.confirmScreen = true;
        }
    }

    createQuoteAccToLicense(event) {
        this.spinner = true;
        if (this.gbu == 'RDS Non-SF WRF') {
            this.spinner = false;
            this.rdsNonSF = true;
            this.selectPricingTools = false;
            this.selectGBU = false;
        } else {
            if (this.isCreateQuote) {
                this.selectScenario = false;
                if (this.gbu == 'Tech Solution'){
                    this.checkPricingAssistantJS(this.recordId);
                } else {
                    this.createIqviaQuote();
                }
                
            } else {
                this.showToast("Error", "Something went wrong!!!", "error");
            }
        }
    }

    cloneQuote() {
        if (this.actionName == 'clone') {
            if (this.selectedQuote.length != 1) {
                this.showToast('Error', 'Please select at least one Quote.', 'error');  
                return;
            }
            if (this.selectedQuote[0].Pricing_Tools__c.includes(this.completeConsentPT)) {
                if (this.isFrehsData) {
                    if (this.bidScenariosForClone == '' || this.bidScenariosForClone == undefined) {
                        this.showToast('Error', 'Please select at least one scenario to create quote.', 'error');  
                        return;
                    } else if (this.bidScenariosForClone != '' || this.bidScenariosForClone != undefined) {
                        this.spinner = true;
                        collectionToolRecordsErrorMessage({recordId: this.recordId, bidScenarios: this.bidScenariosForClone}) 
                        .then(result => {
                            if (result == 'Success') {
                                this.calApexForClone();
                            } else {  
                                this.spinner = false;
                                this.showToast("Error", "Before clonning the Quote, ensure the following fields/records are filled:" + result, "error");
                            }
                        }).catch(error => {
                            this.spinner = false;
                            this.showToast("Error", error.body ? error.body.message : null, "error");
                        });
                    }
                } else {
                    this.calApexForClone();
                }
            } else if (this.selectedQuote[0].Pricing_Tools__c.includes(this.q2SolutionPT)) {
                getValidateData({'quoteRecord': this.selectedQuote[0]})
                .then(res => {
                    if (res == 'Success') {
                        this.calApexForClone();
                    } else {
                        this.showToast('Error', 'Please select correct \'line of business\' and \'identified business\' on opportunity.', 'error');
                        this.spinner = false;
                    }
                }).catch(err => {
                    this.spinner = false;
                    this.showToast('Error', err.body.message, 'error');
                });
            }
        }
    }

    calApexForClone() {
        this.spinner = true;
        cloneQuoteWithDetails({'quoteRecordId': this.selectedQuote[0].Id, 'isFreshData': this.isFrehsData, 'bidScenario': this.bidScenariosForClone, 'bidId': this.recordId, 'isGbu' : this.gbu, 'isTSOption' : null})
        .then(res => {
            if (res.isSuccess == true) {
                this.spinner = false;
                this.showToast('SUCCESS', res.message, 'success');
                this.NavigatedToRecord(res.clonedQuote.Id, 'Quote__c', 'view');
            } else {
                this.showToast('Error', res.message, 'error');
                this.spinner = false;
            }
        }).catch(err => {
            this.spinner = false;
            this.showToast('Error', err.body.message, 'error');
        });
    }
    
    getQuoteListForClone() {
        getQuotesList({'bidRecordId': this.recordId})
        .then(res => {
            if (res.isSuccess == true) {
                this.listOfQuotes = res.listOfQuotes;
                if (this.listOfQuotes.length > 0) {
                    this.enableRadio = true;
                } else {
                    this.enableRadio = false;
                    this.isCreate = true;
                    this.handleContinue();
                }
                this.spinner = false;
            } else {
                this.spinner = false;
                this.showToast('Error', res.message, 'error');
            }
        }).catch(err => {
            this.spinner = false;
            this.showToast('Error', err.body.message, 'error');
        });
    }

    getSelectedGBU(event) {
        this.gbu = event.detail.value;
        this.pricingTools = [];
        this.isPricingToolSelected = false;
        this.handleContinue();
    }

    getSelectedPricingTool(event) {
        this.pricingTools = event.detail.value;
        this.getPathways();
    }

    getPathways() {
        this.isPricingToolSelected = this.pricingTools.length !== 0 ? false : true;
        this.pathways = [];
        if (this.bypassConfiguration === true) {
            this.gbu = this.pricingToolsByGBU.size !== 0 ? this.pricingToolsByGBU.get(this.pricingTools[0]) : null;
            this.pricingTools.forEach(element => {
                if (!this.pathways.includes(this.pricingToolsByPathways.get(element))) {
                    this.pathways.push(this.pricingToolsByPathways.size !== 0 ? this.pricingToolsByPathways.get(element) : null);
                }
            });
            if (this.pricingTools.includes(this.completeConsentPT)) {
                this.checkScenario = true;
            } else {
                this.checkScenario = false;
            }
        } else {
            this.pricingTools.forEach(element => {
                if (!this.pathways.includes(this.pricingToolsByPathways.get(element))) {
                    this.pathways.push(this.pricingToolsByPathways.size !== 0 ? this.pricingToolsByPathways.get(element) : null);
                }
            });
        }
    }
    
    getSelectedScenario(event) {
        this.bidScenarios = parseInt(event.detail.value);
        if (this.bidScenarios !== null || this.bidScenarios !== '') {
            this.isScenarioSelected = false;
        } else {
            this.isScenarioSelected = true;
        }
    }

    getSelectedActionName(event) {
        this.actionName = event.detail.value;
        this.isFrehsData = false;
        this.showScenarioSelection = false;
        this.showFreshDataOption = false;
        this.bidScenariosForClone = '';
        if (this.actionName == 'clone') {
            this.isClone = true;
            this.isCreate = false;
        }
        if (this.actionName == 'create') {
            this.isCreate = true;
            this.isClone = false;
            this.selectedQuote = [];
            this.btnName = 'Next';
            this.continueCreate = true;
        }
    }

    getSelectedScenarioForClone(event) {
        this.bidScenariosForClone = parseInt(event.detail.value);
    }

    createRDSQuote() {
        if (!this.recordId || this.recordId == '') {
            this.showToast("Error", 'Something went wrong', "error");
        } else if (!this.gbu || this.gbu == '') {
            this.showToast("Error", 'Unable to Identify upselling.', "error");
        } else if (!this.oppName || this.oppName == '') {
            this.showToast("Error", 'This quote name is invalid.', "error");
        } else if (!this.selectedPricingToolForNonSF || this.selectedPricingToolForNonSF == '') {
            this.showToast("Error", 'Please select pricing tool.', "error");
        } else if (!this.selectedQuoteTypeForNonSF || this.selectedQuoteTypeForNonSF == '') {
            this.showToast("Error", 'Please select quote type.', "error");
        } else if (!this.selectedRequestTypeForNonSF || this.selectedRequestTypeForNonSF == '') {
            this.showToast("Error", 'Please select scenario.', "error");
        } else if (!this.scenarioNumberForNonSF || this.scenarioNumberForNonSF == '') {
            this.showToast("Error", 'Please select scenario number.', "error");
        } else if (!this.scenarioDescription || this.scenarioDescription == '') {
            this.showToast("Error", 'Please select scenario description.', "error");
        } else {
            this.spinner = true;
            createRDSQuote({recordId : this.recordId, gbu : this.gbu, name : this.oppName, tool : this.selectedPricingToolForNonSF, quoteType : this.selectedQuoteTypeForNonSF, requestedType : this.selectedRequestTypeForNonSF, scenario : this.scenarioNumberForNonSF,  description : this.scenarioDescription})
            .then(result => {
                this.spinner = false;
                this.handleCancel();
                this.showToast("Success", "Quote created successfully.", "success");
                window.open(window.location.origin + '/' + result, "_self");
            }).catch(error => {
                this.spinner = false;
                this.showToast("Error", error.body.message, "error");
            })
        }
    }

    handleContinue() {
        if (this.gbu) {
            if (this.selectGBU) {
                if (this.gbu == 'RDS Non-SF WRF') {
                    this.createButton = 'Next';
                } else {
                    this.createButton = 'Create';
                }
                this.selectPricingTools = true;
                this.selectGBU = true;
                if(this.gbuByPricingTools.has(this.gbu)){
                    this.tempGBUList = this.options;
                    this.options = [];  
                    var temp = this.gbuByPricingTools.get(this.gbu);
                    temp.sort();
                    temp.forEach(element => {
                        this.options.push({label: element, value: element});
                    });
                    this.tempPricingToolList = this.options;
                }
                if (this.options.length == 1) {
                    this.pricingTools.push(this.options[0].value);
                }
                this.isPricingToolSelected = this.pricingTools.length !== 0 ? false : true;
            } else if (this.pricingTools && this.pricingTools != '') {
                var temp = [...this.pricingTools];
                temp.sort();
                temp.forEach( element => {
                    this.confirmedData.push(this.resultMapByPricingTool.get(element));
                });
                this.selectGBU = false;
                this.selectPricingTools = false;
                this.confirmScreen = false;
                if (this.pricingTools.includes(this.completeConsentPT) && this.objectApiName == 'Bid_History__c'){
                    this.spinner = true;
                    let numberOfScenarios;
                    getNumberOfScenario({recordId: this.recordId}).
                    then(result =>{
                        if (result) {
                            this.enableRadio = false;
                            this.selectScenario = true;
                            numberOfScenarios = result;
                            this.options = [];
                            for (let i = 1; i <= numberOfScenarios; i++) {
                                this.options.push({label: ('Scenario ' + i),  value: i});
                            }
                            this.spinner = false;
                        } else { 
                            this.showToast("Error", 'Bid Scenario not found. Please create at least one scenario from collection tool.', "error");
                            this.dispatchEvent(new CloseActionScreenEvent());
                            this.spinner = false;
                        }
                        
                    }).
                    catch(error=>{
                        this.spinner = false;
                    })
                }
            } else {
                this.showToast("Error", 'Please select pricing tool.', "error");
            }
        } else {
            this.showToast("Error", 'Please select upselling.', "error");
        }
    }

    handleNext() {
        if (this.bidScenarios == '' || this.bidScenarios == undefined) {
            this.showToast("Error", 'Please select at least one scenario to create quote.', "error");
        } else {
                collectionToolRecordsErrorMessage({recordId: this.recordId, bidScenarios: this.bidScenarios}) 
            .then(result => {
                    if (result == 'Success') {
                    this.selectGBU = false;
                    this.selectPricingTools = false;
                    this.selectScenario = false;
                    } else {  
                    this.showToast("Error", "Before creating the Quote, ensure the following fields/records are filled:" + result, "error");
                    }
            }).catch(error => {
                this.spinner = !this.spinner;
            });
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
        const closeWindow = new CustomEvent("close");
        this.dispatchEvent(closeWindow);
    }

    handleBack() {
        if (this.selectPricingTools) {
            this.selectGBU = this.bypassConfiguration === true ? false : true;
            this.selectPricingTools = false;
            this.pricingTools = [];
            this.isPricingToolSelected = this.pricingTools.length === 0 ? true : false;
            this.selectScenario = false;
            this.options = this.tempGBUList;
            this.optionType = 'Please select upselling to proceed.';
        }
        if (this.selectScenario) {
            this.selectGBU = false;
            this.selectPricingTools = true;
            this.selectScenario = false;
            this.confirmScreen = false;
            this.options = this.tempPricingToolList;
            this.confirmedData = [];
        }
        if (this.confirmScreen) {
            this.confirmScreen = false;
            if (this.pricingTools.includes(this.completeConsentPT) && this.objectApiName == 'Bid_History__c'){
                this.selectPricingTools = false;
                this.selectGBU = false;
                this.selectScenario = true;
            } else {
                this.selectGBU = true;
                this.selectPricingTools = true;
                this.selectScenario = false;
                this.confirmedData = [];
            }
        }
    }

    handleContinueClone() {
        this.enableRadio = false;
        this.showQuoteList = true;
        this.showFreshDataOption = true;
        this.hideUpdatedBidHistoryCheckBox = this.pricingTools.includes(this.q2SolutionPT) ? false : true;
        this.header = 'Clone Quote';
        this.btnName = 'Clone';
    }

    handleContinueCreate() {
        this.continueCreate = false;
        if (this.gbu) {
            this.handleContinue();
        }
    }

    handleRowSelection(event) {
        var selectedRows= event.detail.selectedRows;
        this.bidScenariosForClone = '';
        this.isFrehsData = this.pricingTools.includes(this.q2SolutionPT) ? true : false;
        this.showScenarioSelection = false;
        if (selectedRows.length == 1) {
            this.selectedQuote[0] = selectedRows[0];
        }
    }

    handleCheckboxForQuoteClone(event) {
        if (event.target.checked) {
            if (this.selectedQuote.length == 1) {
                this.isFrehsData = event.target.checked;
                if (this.selectedQuote[0].Pricing_Tools__c.includes(this.completeConsentPT) &&  this.isFrehsData) {
                    this.spinner = true;
                    let numberOfScenarios;
                    getNumberOfScenario({recordId: this.recordId})
                    .then(result =>{
                        if (result) {
                            numberOfScenarios = result;
                            this.scenarioOptionsForClone = [];
                            for (let i = 1; i <= numberOfScenarios; i++) {
                                this.scenarioOptionsForClone.push({label: ('Scenario ' + i),  value: i});
                            }
                            this.spinner = false;
                            this.showScenarioSelection = true;
                        } else { 
                            this.showToast("Error", 'Bid Scenario not found. Please create at least one scenario from collection tool.', "error");
                            this.spinner = false;
                        }    
                    }).catch(error=>{
                        this.spinner = false;
                    })
                }
            } else {
                this.showToast('Error', 'Please select at least one Quote.', 'error'); 
                event.target.checked = false;
            }   
        } else {
            this.showScenarioSelection = false;
            this.isFrehsData = false;
            this.bidScenariosForClone = '';
        }  
    }
       
    NavigatedToRecord(recordId,objectName, actionName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectName,
                actionName: actionName
            },
        });
    }

    showToast(title, message, variant) {
        var toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    bypassConfigurationSelection() {
        this.selectGBU = false;
        this.bypassConfiguration = true;
    }

    sortDataByKey(a, b, key) {
        if (a[key] < b[key])
            return -1;
        if (a[key] > b[key])
            return 1;
        return 0;
    }

    checkPricingAssistantJS(recordId){ 
        checkPricingAssistant({'recordId': recordId})
        .then(result => {
               if(result === true){
                   this.showToast('Error', 'Quote cannot be created as Pricing Assistant record already exists. Either remove the Pricing Assistant or proceed through Pricing Assistant.', 'error');
                   this.spinner = false;
                   this.handleCancel();
               } else {
                   this.createIqviaQuote();
               }
           }).catch(error => {
               this.spinner = false;
               this.showToast('Error', err.body.message, 'error');
               this.handleCancel();
               
           });
    }

    createIqviaQuote() {
        createQuoteAccToLicense({pricingTools: this.pricingTools.join(';'), gbu: this.gbu, recordId: this.recordId, objectApiName: this.objectApiName, bidScenarios: this.bidScenarios, pathway: this.pathways.join(',')})
                .then(result => {
                    this.spinner = false;
                    this.handleCancel();
                    this.showToast("Success", "Quote created successfully.", "success");
                    window.history.replaceState(null, null, `/${result}`);
                    window.open(window.location.origin + '/' + result, "_self");
                }).catch(error => {
                    this.spinner = !this.spinner;
                    this.selectScenario = this.pricingTools.includes(this.completeConsentPT) && this.objectApiName == 'Bid_History__c' ? true : false;
                    this.showToast("Error", error.body.message , "Error");
                });
    }
}
