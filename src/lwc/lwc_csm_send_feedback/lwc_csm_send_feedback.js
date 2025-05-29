import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLikeOrDislike from '@salesforce/apex/CNT_CSM_Feedback.getLikeDislike';
import saveFeedback from '@salesforce/apex/CNT_CSM_Feedback.saveFeedback';
import saveLikeDislike from '@salesforce/apex/CNT_CSM_Feedback.saveLikeDislike';
import WAS_THIS_PAGE_HELPFUL_LABEL from '@salesforce/label/c.Was_this_page_helpful';
import SEND_FEEDBACK_LABEL from '@salesforce/label/c.Send_feedback';
import PLEASE_ENTER_FEEDBACK_LABEL from '@salesforce/label/c.Please_enter_feedback';
import HAVE_FEEDBACK_WE_D_LOVE_TO_HEAR_IT_LABEL from '@salesforce/label/c.Have_feedback_We_d_love_to_hear_it';
import THANK_YOU_FOR_YOUR_FEEDBACK_LABEL from '@salesforce/label/c.Thank_you_for_your_feedback';
import CLOSE_LABEL from '@salesforce/label/c.Close';
export default class LwcCsmSendFeedback extends LightningElement {
    @api recordId;
    @track dislikeState = false;
    @track likeState = false;
    @track isLoading = true;
    @track isModalOpen = false;
    @track showError = false;
    @track feedbackValue = '';

    labels = {
        Was_this_page_helpful: WAS_THIS_PAGE_HELPFUL_LABEL,
        Send_feedback: SEND_FEEDBACK_LABEL,
        Please_enter_feedback: PLEASE_ENTER_FEEDBACK_LABEL,
        Have_feedback_We_d_love_to_hear_it: HAVE_FEEDBACK_WE_D_LOVE_TO_HEAR_IT_LABEL,
        Close:CLOSE_LABEL
    };

    closeModal() {
        this.isModalOpen = false;
    }

    openModal() {
        this.isModalOpen = true;
    }

    sendFeedback() {
        this.showError = false;
        const fbValue = this.feedbackValue;
        if (fbValue && fbValue.trim() !== '') {
            this.isLoading = true;
            saveFeedback({ feedback: fbValue, kid: this.recordId, source: 'CSH' })
                .then(() => {
                    this.isModalOpen = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: THANK_YOU_FOR_YOUR_FEEDBACK_LABEL,
                            variant: 'success',
                        })
                    );
                })
                .catch(error => {
                    console.error('Error: ', error);
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } else {
            this.showError = true;
        }
    }

    handleLikeDislike(event) {
        const selectedItem = event.currentTarget;
        const likeOrDislike = selectedItem.dataset.value;
        this.isLoading = true;

        saveLikeDislike({ likeOrDislike, kid: this.recordId, source: 'CSH' })
            .then(() => {
                return refreshApex(this.wiredGetLikeOrDislikeResults);
            })
            .catch(error => {
                console.error('Error: ', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    @wire(getLikeOrDislike, { kid: '$recordId', source: 'CSH' })
    wiredGetLikeOrDislike(result) {
        this.wiredGetLikeOrDislikeResults = result;
        const { error, data } = result;
        this.isLoading = true;
        if (data) {
            if (data.Like_or_Dislike__c !== undefined) {
                this.dislikeState = data.Like_or_Dislike__c.toUpperCase() !== 'LIKE';
                this.likeState = !this.dislikeState;
            } else {
                this.dislikeState = false;
                this.likeState = false;
            }
        } else if (error) {
            console.error('Error: ', error);
        }
        this.isLoading = false;
    }

    handleFeedbackChange(event) {
        this.feedbackValue = event.target.value;
    }
}
