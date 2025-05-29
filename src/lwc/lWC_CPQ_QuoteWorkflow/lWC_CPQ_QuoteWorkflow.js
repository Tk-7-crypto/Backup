import { LightningElement, api, wire, track} from 'lwc';
import getQuoteDetails from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.getQuoteDetails';
import getPriorityUserDetails from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.getPriorityUserDetails';
import updateApprovers from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.updateApprovers';
import attachDocumentToFiles from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.attachDocumentToFiles';
import isLaunchFiles from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.isLaunchFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from "lightning/uiRecordApi";
import QUOTE_CURRENCY_FIELD from "@salesforce/schema/Quote__c.CurrencyIsoCode";
import RELATED_OPPORTUNITY_CURRENCY_FIELD from "@salesforce/schema/Quote__c.Related_Opportunity__r.CurrencyIsoCode";
import QUOTE_STAGE_FIELD from "@salesforce/schema/Quote__c.Approval_Stage__c";
import QUOTE_PRICING_TOOL_FIELD from "@salesforce/schema/Quote__c.Pricing_Tools__c";
import QUOTE_CONTRACTING_COUNTRY_FIELD from "@salesforce/schema/Quote__c.Contracting_Country__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import GLOBALMC from "@salesforce/messageChannel/CPQ_GlobalChevron__c";
import finalizeQuote from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.finalizeQuote';
import syncQLIWithOpportunity from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.syncQLIWithOpportunity';
import getLanguagesByCountry from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.getLanguagesByCountry';
import updateLanguages from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.updateLanguages';
import getBatchStatus from '@salesforce/apex/CPQ_QuoteUtility.getBatchStatus';
import LightningConfirm from "lightning/confirm";
import markQuoteAsPrimary from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.markQuoteAsPrimary';
import updateQuoteStage from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.updateQuoteStage';
import getGuidanceFileURL from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.getGuidanceFileURL';
import getQuoteLineItems from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.getQuoteLineItems';
import addBundleProductInCart from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.addBundleProductInCart';
import cloneQuoteWithDetails from '@salesforce/apex/CNT_CPQ_QuoteClone.cloneQuoteWithDetails';
import { NavigationMixin } from 'lightning/navigation';
import getNumberOfScenario from "@salesforce/apex/CNT_CPQ_QuoteCreation.getNumberOfScenario";
import { loadStyle } from 'lightning/platformResourceLoader';
import customCSS from '@salesforce/resourceUrl/toastMessageCSS';
import rejectRestQuotes from "@salesforce/apex/CNT_CPQ_QuoteWorkflow.rejectRestQuotes";
import getProcessInstance from "@salesforce/apex/CNT_CPQ_QuoteWorkflow.getProcessInstance";
import recallApprovalProcess from "@salesforce/apex/CNT_CPQ_QuoteWorkflow.recallApprovalProcess";
import checkAlreadyAccepted from "@salesforce/apex/CNT_CPQ_QuoteWorkflow.checkAlreadyAccepted";
import checkCurrentQuoteApproved from "@salesforce/apex/CNT_CPQ_QuoteWorkflow.checkCurrentQuoteApproved";
import updateProposal from "@salesforce/apex/CNT_CPQ_QuoteWorkflow.updateProposal";
import checkTechSolutionProducts from "@salesforce/apex/CNT_CPQ_QuoteWorkflow.checkTechSolutionProducts";
import updateMsaDiscountReasonOnQuote from "@salesforce/apex/CNT_CPQ_DynamicApprovalProcess.updateMsaDiscountReasonOnQuote";
import deleteUploadedFiles from "@salesforce/apex/CNT_CPQ_DynamicApprovalProcess.deleteUploadedFiles";

const quoteFields = [QUOTE_CURRENCY_FIELD, RELATED_OPPORTUNITY_CURRENCY_FIELD, QUOTE_STAGE_FIELD, QUOTE_PRICING_TOOL_FIELD, QUOTE_CONTRACTING_COUNTRY_FIELD];

let XLS = {};
export default class LWC_CPQ_QuoteWorkflow extends NavigationMixin (LightningElement) {
    @api recordId;
    @api objectApiName;
    showSpinner = false;
    proposalStage;
    quoteRecord;
    pricingToolSelected;
    gbu;
    quotePricingTools = '';
    isLaunch = true;
    showLaunchIcon = false;
    selectedPricingTools;
    opportunityId;
    wiredData;
    pricingToolSelection = true;
    isStageFinalized = false;
    isStagePendingApproval = false;
    isStageDraft = false;
    haveApprovalItems = false;
    isApprover = false;
    approverDetails;
    enableConfigButton = false;
    pricingTools = [];
    configProduct = false;
    isReassign = false;
    isSyncEnabled = false;
    isFinalized = true;
    enableUpdatePricingTool = false;
    hasDPS = false;
    enableUpdateLanguage = false;
    isUpdateLanguage = false;
    selectedLanguages;
    selectedLanguagesTemp;
    lanaguageOptions = [];
    enableAcceptAndReject = false;
    enableReject = false;
    showModalClone = false;
    isFrehsData = false;
    isPrimary = false;
    isSubmitted = true;
    @api bidScenarios = '';
    @track sectionLabel = 'Please select bid scenario to proceed.';
    @track options = [];
    generateProposal = false;
    enableGenerate = false;
    @track record;
    @track error;
    showCloneIcon = false;
    @wire(MessageContext) messageContext;
    recallButtonLabel = 'Recall';
    enableRecall = false;
    @track rejectCancelButtonText = 'Reject';
    @track cancelRejectQuoteMessage = 'Are you sure the client has rejected this quote?';
    @track stageNameCancelReject = 'Rejected';
    @track successfullyCancelRejectMessage = 'Quote rejected successfully.';
    hasTechSolutionGbu = false;
    @track selectedTechSolutionOption = ''; 
    showGenerateDocument = false;
    hasContractingCountry = false;
    @track IqviaQuotePricingTools = [];
    hasEMEA = false;
    @track quotePricingTools = '';
    @track 
    showMSAConfirmationBox = false;
    @track 
    showLightningUploader= false;
    @track 
    uploadedFiles =[];
    @track
    fileUploaded = false;
    hasReassignAccess = false;
    @track
    showReassignButton = false;
    @track
    quoteTier;
    @track
    highPriorityErrorMessage = false;
    @track
    userData = [];
    acceptedFormats = [".avi", ".doc", ".dot", ".docx", ".exe", ".msg", ".wrf", ".html", ".acgi", ".htm", ".htx", ".shtm", ".shtml", ".htt", ".json", ".mht", ".mhtm", ".mhtml", ".mov", ".mp3", ".mp4", ".mpeg", ".mpg", ".pdf", ".ppt", ".pot", ".pps", ".pptx", ".svg", ".svgz", ".swf", ".txml", ".unknown", ".wav", ".wma", ".wmv", ".xhtml", ".xls", ".xlt", ".xlsx", ".xml"];
    isShowCreateEditPricingAssistanceIconVisible = false;
    isShowCreateEditPricingAssistanceIconEnable = false;
    wrapperData;
    showUpdatePricingAndDiscount = false;
    showUpdateQLI = false;
    isSpecial = true;
    @track
    contentDocumentIds = [];
	
	connectedCallback() {
        setTimeout(() => {
            this.showSpinner = true;
            this.getProcessInstance(this.recordId);
            isLaunchFiles({'parentRecord' : this.recordId})
            .then(result => {
                this.isLaunch = result;
            }).catch (error => {
            })
        }, 0.0005);
    }

    renderedCallback() {
        loadStyle(this, customCSS);
    }

    @wire(getRecord, { recordId: "$recordId", fields: quoteFields })
    wiredQuote({ error, data }) {
        if (data) {
            this.record = JSON.parse(JSON.stringify(data));
            const quoteCurrency = this.record.fields.CurrencyIsoCode.value;
            const oppCurrency = this.record.fields.Related_Opportunity__r.value.fields.CurrencyIsoCode.value;
            const quoteStage = this.record.fields.Approval_Stage__c.value;
            this.quotePricingTools = data.fields.Pricing_Tools__c.value;
            const quoteContractingCountry = this.record.fields.Contracting_Country__c.value;
            if (this.quotePricingTools.includes('Q2 Solutions') && quoteStage === 'Draft' && (oppCurrency !== quoteCurrency)) {
                this.toast('Warning', 'Opportunity currency does not match with IQVIA quote currency, Please check the currency before proceeding.', 'warning');
            }
            this.hasContractingCountry = (quoteContractingCountry) ? false : true;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    @wire(getQuoteDetails, {recordId: '$recordId'})
    getData(result) {
        this.wiredData = result;
        if (result.data) {
            this.quoteRecord = result.data;
            this.resetData();
            this.isSpecial = this.quoteRecord.isSpecial;
            this.hasDPS = this.quoteRecord.selectedPricingTools.includes('Complete Consent') ? true : false;
            this.hasEMEA = this.quoteRecord.selectedPricingTools.includes('EMEA') ? true : false; 
            this.quoteTier = parseInt((this.quoteRecord.priority + 1) / 2);
            this.selectedLanguages = this.quoteRecord.selectedLanguages;
            if (this.quoteRecord.gbu == 'RDS SF') {
                this.showLaunchIcon = true;
            }
            if (this.proposalStage != null && this.proposalStage != undefined) {
                this.setStages(this.proposalStage);
                if (this.isStagePendingApproval) {    
                    this.haveApprovalItems = this.quoteRecord.haveApprovalItems;
                    this.isApprover = this.quoteRecord.isApprover;  
                    this.hasReassignAccess = this.quoteRecord.hasReassignAccess; 
                    if (this.haveApprovalItems) {
                        this.approverDetails = JSON.parse(this.quoteRecord.approverDetails);
                        this.approverDetails.sort((a, b) => (a.approverField > b.approverField) ? 1 : -1);
                    }
                    if ((this.hasEMEA && this.hasReassignAccess) || (this.haveApprovalItems && !this.hasEMEA && this.isApprover)) {
                        this.showReassignButton = true;
                    }  
                }
            }
		    if (this.quoteRecord.hasPermissionForSalesWithPSA && this.quotePricingTools == 'EMEA') {
                this.isShowCreateEditPricingAssistanceIconVisible = true;
            }
            if (this.proposalStage == 'In-Progress' || this.proposalStage == 'Draft') {
                this.showUpdatePricingAndDiscount = true;
                this.enableConfigButton = true;
                this.enableUpdateLanguage = true;
                this.isSyncEnabled = this.proposalStage == 'Draft' || this.quoteRecord.selectedPricingTools === 'Q2 Solutions' ? false : true;
                this.enableUpdatePricingTool = this.proposalStage == 'Draft' ? true : false;
                this.isFinalized = this.enableUpdatePricingTool;
            } else if (this.proposalStage == 'Finalized' || this.proposalStage == 'Approved' || this.proposalStage == 'Accepted') {
                this.isSyncEnabled = true;
                this.showUpdatePricingAndDiscount = false;
            } else {
                this.isSyncEnabled = false;
                this.showUpdatePricingAndDiscount = false;
            }
		    if (this.proposalStage != 'Accepted' && this.proposalStage != 'Rejected' && this.proposalStage != 'Cancelled') {
                if (this.quoteRecord.isPrimary == true) {
                    this.isShowCreateEditPricingAssistanceIconEnable = true;
                }
            }
			
            if ((this.proposalStage == 'Finalized' || (this.proposalStage == 'Pending Approval' && this.quoteRecord.isStep1 == true))
                && (this.quoteRecord.selectedPricingTools == 'Complete Consent' || this.quoteRecord.selectedPricingTools == 'EMEA')) {
                this.enableRecall = true;
                if (this.proposalStage == 'Finalized' && this.quoteRecord.selectedPricingTools == 'Complete Consent') {
                    this.recallButtonLabel = 'Unfinalize';
                }
            } else {
                this.enableRecall = false;
            }

            this.showCloneIcon = true;
            this.enableAcceptAndReject = this.proposalStage === 'Approved' ? true : false;
            this.enableReject = this.proposalStage === 'Approved' ? true : false;
            if (this.hasDPS && this.proposalStage === 'Accepted' && this.quoteRecord.quoteHasChildQuote == false) {
                this.enableReject = true;
            }
            this.enableGenerate = (this.proposalStage === 'In-Progress' && this.quoteRecord.quoteLineItems != null && this.quoteRecord.quoteLineItems.length > 0) || this.proposalStage === 'Approved' || this.proposalStage === 'Accepted' ? true : false;
            if (this.quoteRecord.pricingTools != undefined) {
                this.quoteRecord.pricingTools.split('&&').sort().forEach(element => {
                    this.pricingTools.push({label: element, value: element});
                    if (!this.pricingToolSelected) {
                        this.pricingToolSelected = element;
                    }
                });
            }
            this.quoteRecord.selectedPricingTools.split(';').sort().forEach(element => {
                this.IqviaQuotePricingTools.push({label: element, value: element});
                if (!this.pricingToolSelected) {
                    this.pricingToolSelected = element;
                }
            });
            if (this.pricingTools.length == 0 && this.quoteRecord.toolToPathway[this.quoteRecord.selectedPricingTools] == 'Conga') {
                this.enableConfigButton = false;
                this.showCloneIcon = false;
            }
            if (this.quoteRecord.selectedPricingTools.split(';')?.length == 1 && this.quoteRecord.toolToPathway[this.quoteRecord.selectedPricingTools] == 'Conga') {
                this.isFinalized = true;
            } else {
                this.isFinalized = false;
            }
            if (this.quoteRecord.quoteType ==  'Change Order') {
                this.isSyncEnabled = false;
            }
            if (this.quoteRecord.gbu == 'Tech Solution') {
                this.rejectCancelButtonText = 'Cancel';
                this.cancelRejectQuoteMessage = 'Are you sure the client has cancelled this quote?';
                this.stageNameCancelReject = 'Cancelled';
                this.successfullyCancelRejectMessage = 'Quote cancelled successfully.';
                this.isFinalized = this.proposalStage !== 'In-Progress';
                this.enableReject = !(this.proposalStage === 'Rejected' || this.proposalStage === 'Cancelled');
                this.isSyncEnabled = (this.proposalStage === 'Rejected' || this.proposalStage === 'Cancelled' || this.proposalStage === 'Draft' || (this.proposalStage === 'In-Progress' && (this.quoteRecord.quoteLineItems == null || !(this.quoteRecord.quoteLineItems.length > 0))) ? false : true);
                this.isPrimary = !(this.proposalStage === 'Rejected' || this.proposalStage === 'Cancelled' || this.quoteRecord.isPrimary);
                this.recallButtonLabel = this.proposalStage === 'Finalized' ? 'Unfinalize' : this.proposalStage === 'Cancelled' ? 'Reopen' : 'Recall';
                this.hasTechSolutionGbu = true;
                if (this.proposalStage === 'Cancelled') {
                    this.handleTechSolutionLogic();
                }
            } else {
                this.showGenerateDocument = true;
            }
        } else if (result.error) {
            console.log('error = ' + JSON.stringify(result.error));
        }
    }

    async handleTechSolutionLogic() {
        this.enableAcceptAndReject  = await checkCurrentQuoteApproved({ recordId: this.recordId });  
        this.isPrimary = this.quoteRecord.isPrimary === true ? false : this.enableAcceptAndReject;
    }

    resetData() {
        this.pricingToolSelected = undefined;
        this.proposalStage = this.quoteRecord.approvalStage;
        this.gbu = this.quoteRecord.gbu;
        this.selectedPricingTools = this.quoteRecord.selectedPricingTools.split(';');
        this.opportunityId = this.quoteRecord.opportunityId;
        this.isStageFinalized = false;
        this.isStageDraft = false;
        this.isStagePendingApproval = false;
        this.haveApprovalItems = false;
        this.enableConfigButton = false;
        this.isApprover = false;
        this.hasDPS = false;
        this.enableUpdateLanguage = false;
        this.isUpdateLanguage = false;
        this.pricingTools = [];
        this.enableAcceptAndReject = false;
        this.enableReject = false;
        this.isFrehsData = this.quoteRecord.selectedPricingTools === 'Q2 Solutions' ? true : false;
        this.showModalClone = false;
        this.enableGenerate = false;
        this.isPrimary = this.quoteRecord.isPrimary === false ? true : false;
        this.showCloneIcon = false;
        this.enableRecall = false;
        this.recallButtonLabel = 'Recall';
        this.IqviaQuotePricingTools = [];
        this.hasEMEA = false;
    }

    setStages(proposalStage) {
        switch (proposalStage) {
            case 'Draft':
                this.isStageDraft = true;
                break;
            case 'Finalized':
                this.isStageFinalized = true;
                break;
            case 'Pending Approval':
                this.isStagePendingApproval = true;
                break;
            default:
                break;
        }
    }

    get enableApprovalProcess() {
        return this.isStageFinalized || this.isStagePendingApproval;
    }

    handleApprovers(event) {
        var approvalMatrixByPriorityByLevel = JSON.parse(JSON.stringify(event.detail.approvalMatrix));
        var level = 'Level 1';
        var approvalMatrixByPriority = approvalMatrixByPriorityByLevel[level];
        let priorityWithApproverIdsMap = new Map();
        priorityWithApproverIdsMap = this.preparePriorityWithApproverIdsMap(approvalMatrixByPriority);
        const keys = Object.keys(approvalMatrixByPriority);
        const maxPriority = keys[keys.length - 1];
        if (this.quoteTier >= maxPriority && priorityWithApproverIdsMap.size == 0 || (maxPriority > this.quoteTier && priorityWithApproverIdsMap.size == 0)) {
            this.highPriorityErrorMessage = true;
        } else {
            let priorityWithApproverIdsJson = JSON.stringify(Object.fromEntries(priorityWithApproverIdsMap));
            getPriorityUserDetails({ priorityWithApproverIdsJson: priorityWithApproverIdsJson })
                .then(result => {
                    this.userData = result;
                    this.userData = result.map(user => ({
                        label: user.userNameWithTier,
                        value: user.Id
                    }));
                })
                .catch(error => {
            });
        }
    }
    
    preparePriorityWithApproverIdsMap(approvalMatrixByPriority) {
        let priorityWithApproverIdsMap = new Map();
        Object.entries(approvalMatrixByPriority).forEach(([key, value]) => {
            const approverIdSet = new Set();
            value.approverIds.forEach(item => approverIdSet.add(item));
            if (this.approverDetails && this.approverDetails != undefined) {
                this.approverDetails.forEach((item) => {
                    if (approverIdSet.has(item.currentAppprover)) {
                        if ((key >= this.quoteTier && !(item.userName.includes('Tier')))) {
                            item.userName = item.userName + ' ' + '(Tier' + '' + key + ')';
                        }
                        approverIdSet.delete(item.currentAppprover);
                    }
                });
            }
            if (key > this.quoteTier) {
                if (approverIdSet.size > 0) {
                    priorityWithApproverIdsMap.set(key, Array.from(approverIdSet));
                }
            }
        });
        return priorityWithApproverIdsMap;
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

    refreshPage() {
        this.showSpinner = true;
        var temp = refreshApex(this.wiredData).then(() => {
            this.showSpinner = false;
            return true;
        }).catch(err => {
            this.showSpinner = false;
            return false;
        });
        updateRecord({ fields: { Id: this.recordId } }).then(r=> {

        });
        this.handleStageUpdate();
        return temp;
    }

    async handleAccept() {
        if (this.quoteRecord.isPrimary === true) {
            const result = await LightningConfirm.open({
                message: 'Are you sure the client has accepted this quote?',
                variant: 'default',
                label: 'Please Confirm',
                theme: 'info'
            });    
            if (result) {
                this.showSpinner = true;
                const alreadyAccepted = this.quoteRecord.gbu === 'Tech Solution' ? await checkAlreadyAccepted({ relatedOpportunity: this.opportunityId }) : false;
                if (alreadyAccepted) {
                    const confirmCancelPrevious = await LightningConfirm.open({
                        message: 'An opportunity can only have 1 accepted quote by client, if you accept this quote, all other quotes on this opportunity will be moved Cancelled including previously Accepted quote. Do you want to proceed?',
                        variant: 'default',
                        label: 'Please Confirm',
                        theme: 'info'
                    });
                    if (!confirmCancelPrevious) {
                        this.showSpinner = false;
                        return;
                    } 
                }
                updateQuoteStage({'recordId': this.recordId, 'stageName':'Accepted'})
                .then(res => {
                    if (res == 'Success') {
                        if (this.quoteRecord.quoteType !=  'Change Order') {
                            this.syncToOpp();
                        }
                        rejectRestQuotes({'relatedOpportunity': this.quoteRecord.opportunityId, 'recordId': this.recordId, gbu: this.gbu})
                        .then(res => {
                        if (res != 'Success') {
                                this.toast('Error', res, 'error');
                            }
                        }).catch(err => {
                            this.toast('Error', err.body.message, 'error');
                        });
                        this.showSpinner = false;
                        this.refreshPage();
                        this.toast('SUCCESS', 'Quote accepted successfully.', 'success');
                    } else {
                        this.toast('Error', res, 'error');
                        this.showSpinner = false;
                    }
                }).catch(err => {
                    this.showSpinner = false;
                    this.toast('Error', err, 'error');
                });
            } else {
                return false;
            }
        } else {
            this.toast('Error', 'Quote should be primary.', 'error');
        }
    }

    async handleRejectQuote() {
        const result = await LightningConfirm.open({
            message: this.cancelRejectQuoteMessage,
            variant: 'default', 
            label: 'Please Confirm',
            theme: 'info'
        });    
        if (result) {
            this.showSpinner =true;
            updateQuoteStage({'recordId': this.recordId, 'stageName':this.stageNameCancelReject})
            .then(res => {
                if (res == 'Success') {
                    this.showSpinner = false;
                    this.refreshPage();
                    this.toast('SUCCESS', this.successfullyCancelRejectMessage, 'success');
                } else {
                    this.toast('Error', res, 'error');
                    this.showSpinner = false;
                }
            }).catch(err => {
                this.showSpinner = false;
                this.toast('Error', err, 'error');
            });
        } else {
            return false;
        }
    }

    async markAsPrimary() {
        const result = await LightningConfirm.open({
            message: ' Do you want to mark this quote as primary?',
            variant: 'default',
            label: 'Primary Quote',
            theme: 'info'
        });
        if (result) {
            this.showSpinner =true;
            markQuoteAsPrimary({'recordId': this.recordId, 'relatedOpportunity': this.opportunityId})
            .then(result => {
                if (result === true) {
                    this.refreshPage();
                    this.isPrimary = false;
                    this.showSpinner = false;
                    this.toast('SUCCESS', 'Quote marked as primary.', 'success');
                }
            }
            ).catch(error => {
                    this.showSpinner = false;
                    this.toast('Error', error.body ? error.body.message : 'Quote should be primary.', 'error');
                }
            );
        }
    }
	
    handleUploadFinished(event) {
        const contentDocumentIds = [];
        this.fileUploaded = true
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach(file => {
            contentDocumentIds.push(file.documentId);
            const baseUrl = window.location.origin;
            let fileUrl = baseUrl + '/sfc/servlet.shepherd/document/download/' + file.documentId;
            this.uploadedFiles = [...this.uploadedFiles, {
                name: file.name,
                documentId: file.documentId,
                url: fileUrl
            }]
        })
        this.contentDocumentIds = contentDocumentIds;
    }
	
    closeUploader() {
        this.closeModal();
        this.showSpinner = true;
        if (this.uploadedFiles) {
            deleteUploadedFiles({ fileIds: this.contentDocumentIds }).then((res => {
                this.showSpinner = false;
            })).catch(err => {
                this.showSpinner = false;
                this.showToast("Error", err, "error");
            })
        }
    }

    submitApproval() {
        this.refreshPage().then(() => {
            if (this.hasDPS || this.hasEMEA) {
                if ((this.quoteRecord.discountReason == null || this.quoteRecord.discountReason == '') && (this.quoteRecord.aggregateDiscount > 0)) {
                    this.toast('Error', 'Please fill the "Discount Reason" field before submitting quote for approval.', 'error');
                    return;
                }
            }
            if (this.hasEMEA) {
                this.showMSAConfirmationBox = true;
            }
            else {
                const childComponent = this.template.querySelector('c-l-w-c_-c-p-q_-dynamic-approval-process');
                updateMsaDiscountReasonOnQuote({
                    recordId: this.recordId,
                    isMsaOrHistoricalDiscountReason: false,
                    urlLink: null
                }).then(() => {
                    childComponent.submitForStandardApproval();
                });
            }
        });
    }

    onMsaOrHistoricalApprovalClick() {
        this.closeModal();
        this.showLightningUploader = true;
    }

    async submitForStandardApproval() {
        this.closeModal();
        const childComponent = this.template.querySelector('c-l-w-c_-c-p-q_-dynamic-approval-process');
        updateMsaDiscountReasonOnQuote({
            recordId: this.recordId,
            isMsaOrHistoricalDiscountReason: false,
            urlLink: null
        }).then(() => {
            childComponent.submitForStandardApproval();
        });
    }

    submitForMsaOrHistoricalApprovals() {
        if (this.uploadedFiles == '' || this.uploadedFiles == undefined) {
            this.toast('Error', 'Please select file to submit request for Approval', 'Error');
        }
        else {
            const childComponent = this.template.querySelector('c-l-w-c_-c-p-q_-dynamic-approval-process');
            this.showLightningUploader = false;
            childComponent.submitForMSAApprovals(this.uploadedFiles);
        }
    }

    onApprovalProcess(event) {
        if (event.detail == 'Success') {
            this.refreshPage().then(()=> {
                this.refreshPage();
            });
        }
    }

    handleApprove() {
        this.template.querySelector('c-l-w-c_-c-p-q_-dynamic-approval-process').handleApprove();
    }
    
    handleReject() {
        this.template.querySelector('c-l-w-c_-c-p-q_-dynamic-approval-process').handelReject();
    }

    handleReassign() {
        this.isReassign = !this.isReassign;
    }

    handleStageUpdate() {
        const payload = {
            isStageUpdated: 'true',
        };
        publish(this.messageContext, GLOBALMC, payload);
    }

    handleApproverChange(event) {
        let approverId = event.target.value;
        let approverField = event.target.name;
        if (approverId != null && approverId != '') {
            this.approverDetails.forEach(element => {
                if (element.approverField == approverField) {
                    element.newApprover = approverId;
                }
            });
        }
    }

    finalizationQuote() {
        this.showSpinner = true;
        if (this.quoteRecord.gbu === 'Tech Solution') {
            if (!this.quoteRecord.quoteLineItems) {
                this.toast('Error', 'Please add product and pricing information before finalizing the Quote.', 'error');
                this.showSpinner = false;
                return;
            }
            if (this.hasContractingCountry) {
                this.toast('Error', 'Please select the contracting country before finalizing this quote, contracting country is the country approving this quote.', 'error');
                this.showSpinner = false;
                return;
            }
            checkTechSolutionProducts({quoteId : this.recordId}).then(res => {
                if (res != 'Success') {
                    var error = res.split(':');
                    if (error[0] == 'ERROR_1') {
                        this.toast('ERROR', error[1], 'error');
                        this.showSpinner = false;
                    } 
                    if (error[0] == 'ERROR_2') {
                        this.showSpinner = false;
                        this.confirmFinalization(error[1]);
                    }
                } else {
                    this.finalizeIQVIAQuote();
                }
            }).catch(error => {
                this.showSpinner = false;
                this.toast('ERROR', error, 'error')
            });
        } else {
            this.finalizeIQVIAQuote();
        }
    }

    async confirmFinalization(err) {
        const result = await LightningConfirm.open({
            message: err,
            variant: 'default',
            label: 'Finalize Quote',
            theme: 'warning'
        });
        if (result) {
            this.finalizeIQVIAQuote();
        }
    }

    finalizeIQVIAQuote() {
        this.showSpinner = true;
        finalizeQuote({numberOfCongaQuoteIds : this.quoteRecord.availableCongaToolList.length, numberOfExcelTool : this.quoteRecord.availableOutsideToolList.length, recordId : this.recordId, congaTools : this.quoteRecord.availableCongaToolList, CurrencyIsoCode: this.quoteRecord.currencyIsoCode}).then(result => {
            if (result == 'Fail') {
                this.toast('ERROR', 'Please finalize all related tools prior to finalizing this Quote.', 'error');
            } else if (result.includes('Error')) {
                this.toast('ERROR', result, 'error');
            } else {
                this.isFinalized = true;
                this.toast('SUCCESS', 'Quote finalized successfully.', 'success');
                this.refreshPage();
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.toast('ERROR', error, 'error');
        });
    }

    updateApproversOnQuote() {
        var eligibleForUpdate = false;
        this.approverDetails.forEach(element => {
            if (element.newApprover != null && element.newApprover != undefined) {
                if (element.newApprover != element.currentAppprover) {
                    eligibleForUpdate = true;
                }
            }
        });
        if (eligibleForUpdate) {
            this.isReassign = !this.isReassign;
            this.showSpinner = !this.showSpinner;
            updateApprovers({"jsonData": JSON.stringify(this.approverDetails), "quoteId": this.recordId})
            .then(res => {
                if (res == 'Success') {
                    this.toast(res, 'Reassigned successfully.', 'success');
                     setTimeout(() => {
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.recordId,
                                    objectApiName: this.objectApiName,
                                    actionName: 'view'
                                }

                            }, true);
                        }, 1000);
                } else {
                    this.toast('error', res, 'error');
                }
                this.showSpinner = !this.showSpinner;
                this.refreshPage();
            }).catch(err => {
                console.log('error = ' + err);
                this.showSpinner = !this.showSpinner;
            })
        } else {
            this.toast('Error', 'Please change atleast one Approver', 'error');
        }
    }

    closeModal() {
        this.isReassign = false;
        this.configProduct = false;
        this.isUpdateLanguage = false;
        this.showModalClone = false;
        this.isFrehsData = this.quoteRecord.selectedPricingTools === 'Q2 Solutions' ? true : false;
        this.bidScenarios = '';
        this.selectedTechSolutionOption = '';
        this.showMSAConfirmationBox = false;
        this.showLightningUploader = false;
        this.uploadedFiles =[];
        this.fileUploaded = false;
    }
	
	handleConfigureProducts() {
        this.refreshPage().then(()=> {
            
            if (this.hasDPS) {
                if (this.quoteRecord.DocumentType == '' || this.quoteRecord.DocumentType == null) {
                    this.toast('Error', 'Please select a value for the following mandatory field in the "Complete Consent Section" before clicking the "Configure Products" icon: \nDocument Type', 'error');
                    return;
                }
            } else {
                if (this.quoteRecord.Scenario == null || this.quoteRecord.Scenario == undefined) {
                    this.toast('Error', 'Scenario field is mandatory before configuring products', 'error');
                    return;
                }
                if (this.pricingToolSelected == 'Q2 Solutions' && this.quoteRecord.quoteType ==  'Change Order' && this.quoteRecord.currencyIsoCode != 'USD' && (this.quoteRecord.conversionRate == null || this.quoteRecord.conversionRate == undefined || this.quoteRecord.conversionRate == 0)) {
                    this.toast('Error', 'Please enter the conversion rate.', 'error');
                    return;
                }
            }
            this.moveStageToInProgress().then(() => {
                if (this.IqviaQuotePricingTools.length > 1) {
                    this.configProduct = !this.configProduct;
                } else {
                    if (this.pricingTools.length == 1) {
                        if (this.quoteRecord.hasProductConfiguration === true) {
                            this.updateProposal(this.quoteRecord.congaQuoteIdByPricingToolMap[this.pricingToolSelected]);
                        }
                        this.moveToCart(this.pricingToolSelected);
                        return;
                    } else if (this.quoteRecord.selectedPricingTools.split(';')?.length == 1 && this.quoteRecord.toolToPathway[this.quoteRecord.selectedPricingTools] == 'Manual') {
                        var address = '/apex/apex/VFP_CRM_NavigateToAddProductsQuote?id=' + this.recordId + '&source=' + this.objectApiName + '&pricingtool=' + this.quoteRecord.selectedPricingTools;
                        this.redirectToAddMoreProduct(address);
                        return;
                    }
                }
            }).catch(error => {
                console.error(error);
            });
        });
    }

    moveStageToInProgress() {
        if (this.proposalStage == 'Draft') {
            return updateQuoteStage({"recordId": this.recordId, stageName: 'In-Progress'}).then(res => {
                if (res == 'Success') {
                    this.refreshPage().then(()=>{this.showSpinner = true;});
                }
            }).catch(err => {
                console.log(err);
            })
        } else {
            return Promise.resolve();
        }
    }
    
    redirectToAddMoreProduct (address) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: address
            }
        });
    }

    moveToCart(pricingToolSelected) {
        var quoteId = this.recordId;
        var pricingTool = pricingToolSelected;
        if ((this.quoteRecord.flowNameByPricingToolMap == undefined || this.quoteRecord.flowNameByPricingToolMap == null) && this.quoteRecord.toolToPathway[pricingTool] != 'Manual' ) {
            this.toast('Error', 'You need conga license/permission for configure product.', 'error');
            this.showSpinner = false;
            return;
        }
        
        if (this.quoteRecord.toolToPathway[pricingTool] != 'Manual') {
            var flowName = this.quoteRecord.flowNameByPricingToolMap[pricingTool];
            var congaQuoteId = this.quoteRecord.congaQuoteIdByPricingToolMap[pricingTool];
            var stage = this.quoteRecord.idToStageMap[congaQuoteId];
            if (flowName != null && flowName != undefined && congaQuoteId != null && congaQuoteId != undefined) {
                this.showSpinner = true;
                if (this.proposalStage == 'Draft' || this.proposalStage == 'In-Progress') {
                    if (pricingTool == 'Q2 Solutions' && this.proposalStage == 'Draft') {
                        addBundleProductInCart({recordId: quoteId, congaQuoteId: congaQuoteId, relatedQuote: this.quoteRecord.relatedQuote})
                        .then(res => {
                            if (res == 'Success') {
                                window.open("/apex/Apttus_QPConfig__ProposalConfiguration?flow=" + flowName + "&id=" + congaQuoteId + "&useAdvancedCurrency=true", "_self");
                            } else if (res == 'Failed') {
                                window.open("/apex/Apttus_QPConfig__ProposalConfiguration?flow=" + flowName + "&id=" + congaQuoteId + "&useAdvancedCurrency=true", "_self");
                            } else {
                                this.toast('ERROR', res, 'error');
                                this.showSpinner = false;
                            }
                        }).catch(err => {
                            this.showSpinner = false;
                            this.toast('ERROR', err, 'error');
                        })
                    } else {
                        window.open("/apex/Apttus_QPConfig__ProposalConfiguration?flow=" + flowName + "&id=" + congaQuoteId + "&useAdvancedCurrency=true", "_self");
                    }
                } else {
                    window.open("/apex/Apttus_QPConfig__ProposalConfiguration?flow=" + flowName + "&mode=readOnly" + "&id=" + congaQuoteId + "&useAdvancedCurrency=true", "_self");
                }
                
            } else {
                this.showSpinner = false;
            }     
        } else {
            var address = '/apex/apex/VFP_CRM_NavigateToAddProductsQuote?id=' + this.recordId + '&source=' + this.objectApiName + '&pricingtool=' + pricingTool;
            this.redirectToAddMoreProduct(address);
            return;
        }
    }
    
    syncToOpp() {
        
        if (this.quoteRecord.isPrimary === true) {
            this.showSpinner = true;
            syncQLIWithOpportunity({recordId: this.recordId, pricingTool: this.quoteRecord.selectedPricingTools, stageName: this.proposalStage})
            .then(result => {
                this.toast('WARNING', 'Syncing from IQVIA Quote to Opportunity is in progress, Please wait until it completes and do not close this screen.', 'warning');
                if (result == 'In-Progress') {
                    this.showSpinner = false;
                } else {
                    this.checkStatus(result);
                }
            }).catch(error => {
                this.toast('ERROR', error.body ? error.body.message : 'Synchronization With Opportunity Failed!!', 'error');
                this.showSpinner = false;
            })
        } else {
            this.toast('Error', 'Quote should be primary.', 'error');
        }
    }

    async checkStatus(jobRef) {
        let jobCompleted = false;
        while (!jobCompleted) {
            const result = await getBatchStatus({ jobId: jobRef });
            if (result !== null) {
                if (result === 'Completed') {
                    this.toast('SUCCESS', 'Line Items are synced with Opportunity Line Items.', 'success');
                    jobCompleted = true;
                } else {
                    this.toast('Sync Failed', result, 'error');
                    jobCompleted = true;
                }
            }
            if (!jobCompleted) {
                await this.delay(5000);
            }
        }
        this.showSpinner = false;
        this.refreshPage();
    }

    delay(milliseconds) {
        return new Promise(resolve => setTimeout(resolve, milliseconds));
    }

    getSelectedPricingTool(event) { 
        this.pricingToolSelected = event.detail.value;
    }

    handleConfigure() {
        this.showSpinner = true;
        this.configProduct = !this.configProduct;
        this.moveToCart(this.pricingToolSelected);
    }

    handleLanguageUpdate() {
        this.showSpinner = true;
        this.selectedLanguagesTemp = null;
        if (this.selectedLanguages) {
            this.selectedLanguagesTemp = this.selectedLanguages.split(';');
        }
        this.lanaguageOptions = [];
        getLanguagesByCountry({'recordId': this.recordId})
        .then(res => {
            res.forEach(element => {
                this.lanaguageOptions.push({value: element, label: element});
            });
            this.showSpinner = false;
            this.isUpdateLanguage = true;
        }).catch(err => {
            this.toast('Error', err, 'error');
            this.showSpinner = false;
        });
    }

    get Options() {
        var lanaguageOptionsTemp = this.lanaguageOptions;
        return lanaguageOptionsTemp.sort((a, b) => (a.value > b.value) ? 1 : -1);
    }

    handleLanguageChange(e) {
        var languages = e.detail.value;
        languages.sort((a, b) => (a > b) ? 1 : -1);
        this.selectedLanguagesTemp = languages;
    }

    handleSaveLanguages() {
        this.showSpinner = true;
        this.isUpdateLanguage = false;
        updateLanguages({'recordId': this.recordId, 'languageList': this.selectedLanguagesTemp})
        .then(res => {
            if (res == 'Success') {
                this.toast(res, 'Languages updated successfully.', 'success');
                window.location.reload();
            } else {
                this.toast('Error', res, 'error');
            }
            this.showSpinner = false;
            this.refreshPage();
        }).catch(err => {
            this.toast('Error', err, 'error');
            this.showSpinner = false;
        })
    }
    generateFile() {
        this.showSpinner = true;
        if (this.quoteRecord.selectedPricingTools.includes('Complete Consent')) {
            getGuidanceFileURL()
            .then(result => {
                if (result) {
                    window.open(result);
                }
                this.showSpinner = false; 
            }).catch(err => {
                this.toast('Error', err, 'error');
                this.showSpinner = false; 
            })
        }
    }
    launchTool(event){
        let templateName = '';
        if (this.quotePricingTools === 'Unit Pricing Tool') {																		   
            templateName = 'UPT Template Quote';
        } else if (this.quotePricingTools === 'LCS UPT') {
            templateName = 'LCS UPT Template';
        }
        if (templateName) {
            this.showSpinner =true;
            attachDocumentToFiles({'Name': templateName, 'parentRecord' : this.recordId})
            .then(result => {
                this.showSpinner = false;
                this.isLaunch = false;
                let res = result; 
                let baseUrl = window.location.origin;
                let fileDownloadurl = `${baseUrl}/sfc/servlet.shepherd/document/download/${res}?operationContext=S1`;
                window.location = fileDownloadurl;
                setTimeout(() => {
                    window.location.reload();
                }, 4000);
            }).catch (error => {
                this.toast("Error", error.body ? error.body.message : null, "error");
                this.showSpinner = false;
            })       
        } else {
            this.toast(Error, "No document found for this pricing tool "+this.quotePricingTools, "error");
        }
    }
    showModalForClone(event) {
        if (this.quoteRecord.selectedPricingTools === 'Q2 Solutions') {
            this.showModalClone = false;
            this.handleClone(event);
        } else {
            this.showModalClone = true;
        }
    }
    handleClone(event) {
        if (this.isFrehsData && this.hasDPS && (this.bidScenarios == '' || this.bidScenarios == undefined)) {
            this.toast("Error", 'Please select at least one scenario to create quote.', "error");
            return;
        }
        if (this.selectedTechSolutionOption == '' && this.hasTechSolutionGbu) {
            this.toast("Error", 'Please select at least one option.', "error");
            return;
        }
        this.showSpinner =true;
        this.showModalClone = false;
        cloneQuoteWithDetails({'quoteRecordId': this.recordId, 'isFreshData': this.isFrehsData, 'bidScenario': this.bidScenarios, 'bidId': null, 'isGbu' : this.gbu, 'isTSOption' : this.selectedTechSolutionOption})
        .then(res => {
            if (res.isSuccess == true) {
                this.showSpinner = false;
                this.toast('SUCCESS', res.message, 'success');
                this.refreshPage();
                this.NavigatedToRecord(res.clonedQuote.Id,'Quote__c', 'view');
            } else {
                this.toast('Error', res.message, 'error');
                this.showSpinner = false;
            }
        }).catch(err => {
            this.showSpinner = false;
            this.toast('Error', err.body.message, 'error');
        });
    }
    handleCheckboxForClonQuote(event) {
        this.isFrehsData = event.target.checked;
        this.bidScenarios = '';
        if (this.isFrehsData && this.hasDPS) {
            getNumberOfScenario({'recordId': this.quoteRecord.bidHistoryId})
            .then(res => {
                if (res) {
                    var numberOfScenarios = res;
                    this.options = [];
                    for (let i = 1; i <= numberOfScenarios; i++) {
                        this.options.push({label: ('Scenario ' + i),  value: i});
                    }
                } else { 
                    this.showToast("Error", 'Bid Scenario not found. Please create at least one scenario from collection tool.', "error");
                }
            }).catch(err => {
                this.showSpinner = false;
                this.toast('Error', err.body.message, 'error');
            });
        }
    }
    getSelectedScenario(event) {
        this.bidScenarios = parseInt(event.detail.value);
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
    
    handleGenerate() {
        if (this.quoteRecord.haveCongaCLMPermission === false) {
            this.toast('Error', 'You need conga license/permission to generate the document.', 'error');
            return;
        }
        this.generateProposal = true;
    }
    handleGenerateClosure() {
        this.generateProposal = false;
    }

    getProcessInstance(quoteId) {
        getProcessInstance({targetObjectId: quoteId})
        .then(res => {
            if (res.length > 0) {
                this.isSubmitted = false;
            }
            this.showSpinner = false;
        }).catch(err => {
            this.showSpinner = false;
        })
    }

    updateProposal(proposalId) {
        updateProposal({recordId: proposalId})
        .then(res => {
        }).catch(err => {
            this.showSpinner = false;
        })
    }

    get isSubmittedAndisStageFinalized() {
        return this.isStageFinalized;
    }

    async handleRecall() {
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to return this quote to the In-Progress stage?',
            variant: 'default',
            label: this.recallButtonLabel,
            theme: 'info'
        });
        if (result) {
            this.showSpinner = true;
            let successMsg = this.recallButtonLabel == 'Recall' ? 'Quote recalled successfully.' : 'Quote unfinalized successfully.';
            if (this.proposalStage == 'Pending Approval') {
                recallApprovalProcess({"recordId": this.recordId}).then(res => {
                    if (res == 'Success') {
                        this.showReassignButton = false;
                        this.toast('Success', successMsg, 'success');
                        this.refreshPage();
                    } else {
                        this.toast('Error', res, 'error')
                    }
                }).catch(err => {
                    this.toast('Error', err, 'error')
                })
            } else {
                updateQuoteStage({"recordId": this.recordId, stageName: 'In-Progress'}).then(res => {
                    if (res == 'Success') {
                        this.showReassignButton = false;
                        this.toast('Success', successMsg, 'success');
                        this.refreshPage();
                    } else {
                        this.showSpinner = false;
                    }
                }).catch(err => {
                    this.toast('Error', err, 'error')
                })
            }
            if (this.quoteRecord.selectedPricingTools != 'EMEA') {
                this.updateProposal(this.quoteRecord.congaQuoteIdByPricingToolMap[this.pricingToolSelected]);
            }
        }
    }

    get quoteCloneOptionsTechSolution() {
        return [
            { label: 'Cancel the current quote to work on a new quote', value: 'Cancelled' },
            { label: 'Keep the current quote and work on a new quote at the same time', value: 'Keep' },
        ];
    }
    handleTechSolutionSelection(event) {
        this.selectedTechSolutionOption = event.detail.value; 
    }
    handleUpdatePricingAndDiscount() {
        this.showUpdateQLI = true;
    }
	handleCreateEditPricingAssistence() {
        getQuoteLineItems({ quoteId: this.recordId }).then((qliWrapper) => {
            this.wrapperData = qliWrapper;
            if (qliWrapper.showError) {
                this.toast('', qliWrapper.message, 'error');
                return;
            }
            window.open(this.wrapperData.url, '_self');
        }).catch(err => {
            console.log('Error in fetching QLI =>' + err);
        });
    }
}
