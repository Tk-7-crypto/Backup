import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getBidHistoryRelatedToOpportunity from '@salesforce/apex/CNT_OWF_AwardBidHistory.getBidHistoryRelatedToOpportunity';
import awardBidHistoryRecord from '@salesforce/apex/CNT_OWF_AwardBidHistory.awardBidHistoryRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

const AWARD_BID_HISTORY_COLUMNS = [
    { label: 'Awarded', fieldName: 'awarded' },
    { label: 'Related Quote Status', fieldName: 'relatedQuoteStatus' },
    { label: 'Bid Type', fieldName: 'bidType' },
    { label: 'Name', fieldName: 'bidHistoryRecordUrl' },
    { label: 'Total Value', fieldName: 'totalValue' },
    { label: 'Bid Number', fieldName: 'bidNumber' },
    { label: 'Scenario Number', fieldName: 'scenarioNumber' },
    { label: 'Scenario', fieldName: 'scenario' },
    { label: 'Number of Scenarios', fieldName: 'numberOfScenarios' },
    { label: 'Bid Due Date', fieldName: 'bidDueDate' },
    { label: 'Bid Sent Date', fieldName: 'bidSentDate' },
    { label: 'Comments', fieldName: 'comments' }
];

export default class Lwc_owf_awardbidhistoryDev extends LightningElement {
    headingName;
    columns = AWARD_BID_HISTORY_COLUMNS;
    @api recordId;
    error = false;
    @track bidHistoryRecordsForDataTable = [];
    wiredBidHistoryRecords = [];
    errorMessage = 'Unexpected error !';
    showSpinner = true;
    @track selectedBidHistoryRow = [];
    isAnyBidHistoryAwarded = false;
    awardedBidHistoryNumber = '';
    disableButtonWhileAwardingBidHistory = false;
    noBidHistoryRelatedToOpportunity = false;
    isAnyBidHistoriesRelatedToOpportunity = false;
    isSelectedRowCommentsUpdated = false;
    previouslySelectedRowIndex;
    previouslySelectedRowComments;
    updatedCommentsForAwardedBid;
    selectedRowCommentBeforeUpdate;
    isRelatedQuoteStatusInvalidForAwarded = false;

    connectedCallback() {
        this.columns = AWARD_BID_HISTORY_COLUMNS;
    }

    renderedCallback() {
        refreshApex(this.wiredBidHistoryRecords);
    }

    @wire(getBidHistoryRelatedToOpportunity, { opportunityId: '$recordId' })
    wiredBidHistoryRelatedToOpportunity(result) {
        this.wiredBidHistoryRecords = result;
        if (result.data) {
            this.bidHistoryRecordsForDataTable = JSON.parse(JSON.stringify(result.data));
            if (!this.bidHistoryRecordsForDataTable.length) {
                this.noBidHistoryRelatedToOpportunity = true;
            }
            this.isAnyBidHistoriesRelatedToOpportunity = !this.noBidHistoryRelatedToOpportunity;
            this.isAnyBidHistoryAwarded = false;
            for (let index = 0; index < this.bidHistoryRecordsForDataTable.length; index++) {
                const bidHistoryRecord = this.bidHistoryRecordsForDataTable[index];
                if (bidHistoryRecord.awarded === 'Yes') {
                    this.isAnyBidHistoryAwarded = true;
                    this.awardedBidHistoryNumber = bidHistoryRecord.bidNumber;
                    break;
                }
            }
            this.showSpinner = false;
        }
        else if (result.error) {
            this.showSpinner = false;
            this.error = true;
            this.errorMessage = result.error.body ? (result.error.body.message ? result.error.body.message : JSON.stringify(result.error.body)) : JSON.stringify(result.error);
            this.showToast('Error fetching Bid Histories!', this.errorMessage, 'Error', 'sticky');
        }
    }

    get isAllBidHistoriesNotAwarded() {
        return !this.isAnyBidHistoryAwarded;
    }

    get disableMarkAsAwardedButton() {
        return !this.selectedBidHistoryRow.length || this.disableButtonWhileAwardingBidHistory || this.isAnyBidHistoryAwarded || this.isRelatedQuoteStatusInvalidForAwarded;
    }

    // handle 'comment' cell editable on row selection
    handleRowSelection(event) {
        this.selectedBidHistoryRow = []
        this.selectedBidHistoryRow.push(this.bidHistoryRecordsForDataTable[event.target.dataset.index]);

        if (this.previouslySelectedRowIndex) {
            this.bidHistoryRecordsForDataTable[this.previouslySelectedRowIndex].isCommentsEditable = false;

            // to reset comment of last selected row
            if (this.isSelectedRowCommentsUpdated) {
                this.bidHistoryRecordsForDataTable[this.previouslySelectedRowIndex].comments = this.previouslySelectedRowComments;
                this.isSelectedRowCommentsUpdated = false;
            }
        }

        if (this.selectedBidHistoryRow[0].relatedQuoteStatus === 'No Quote Created' || this.selectedBidHistoryRow[0].relatedQuoteStatus === '') {
            this.isRelatedQuoteStatusInvalidForAwarded = true;
        } else {
            this.isRelatedQuoteStatusInvalidForAwarded = false;
            this.bidHistoryRecordsForDataTable[event.target.dataset.index].isCommentsEditable = true;
        }
        this.previouslySelectedRowIndex = event.target.dataset.index;
    }

    handleCommentChange(event) {
        const updatedComment = event.target.value;
        const commentBefore = this.bidHistoryRecordsForDataTable[event.target.dataset.index].comments;

        //to store selected row comment, used to reset comment of last selected row when new row is selected
        if (!this.isSelectedRowCommentsUpdated) {
            this.previouslySelectedRowComments = this.bidHistoryRecordsForDataTable[event.target.dataset.index].comments;
        }

        if (commentBefore !== updatedComment) {
            this.isSelectedRowCommentsUpdated = true;
            this.bidHistoryRecordsForDataTable[event.target.dataset.index].comments = updatedComment;
            this.updatedCommentsForAwardedBid = updatedComment;
        }
    }

    handleMarkAsAwarded() {
        this.showSpinner = true;
        if (this.selectedBidHistoryRow.length) {
            for (let index = 0; index < this.bidHistoryRecordsForDataTable.length; index++) {
                let bidHistoryRecord = this.bidHistoryRecordsForDataTable[index];
                if (bidHistoryRecord.id === this.selectedBidHistoryRow[0].id) {
                    this.disableButtonWhileAwardingBidHistory = true;
                    awardBidHistoryRecord({
                        bidHistoryIdToAward: bidHistoryRecord.id,
                        isCommentsUpdated: this.isSelectedRowCommentsUpdated,
                        updatedComments: this.updatedCommentsForAwardedBid
                    })
                        .then(() => {
                            this.showSpinner = false;
                            this.awardedBidHistoryNumber = bidHistoryRecord.bidNumber;
                            this.isAnyBidHistoryAwarded = true;
                            this.bidHistoryRecordsForDataTable[index].awarded = 'Yes';
                            this.showToast('Success', 'Bid History awarded.', 'Success', 'pester');
                            refreshApex(this.wiredBidHistoryRecords);
                        })
                        .catch((error) => {
                            this.showSpinner = false;
                            this.disableButtonWhileAwardingBidHistory = false;
                            this.error = true;
                            this.errorMessage = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
                            this.showToast('Error awarding Bid History!', this.errorMessage, 'Error', 'sticky');
                        });
                    break;
                }
            }
        }
    }

    async confirmMarkAsAwarded() {
        const result = await LightningConfirm.open({
            message: `You have a selected Bid Number ${this.selectedBidHistoryRow[0].bidNumber} as Awarded is this correct ?`,
            variant: "header",
            theme: "warning",
            label: 'Please Confirm'
        });
        if (result) {
            this.handleMarkAsAwarded();
        }
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    disconnectedCallback() {
        this.bidHistoryRecordsForDataTable = [];
    }
}
