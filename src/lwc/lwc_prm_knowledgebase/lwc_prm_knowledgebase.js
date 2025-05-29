import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import KNOWLEDGE_LABEL from '@salesforce/label/c.Knowlegde';
import EXPLORE_DOCUMENTATION_FOR_LABEL from '@salesforce/label/c.Explore_Documentations_for';
import PRODUCT_LABEL from '@salesforce/label/c.Product';
import DOCUMENTATION_LABEL from '@salesforce/label/c.Documentation';
import FOR_LABEL from '@salesforce/label/c.For';
import ALL_PRODUCTS_LABEL from '@salesforce/label/c.All_Products';
import HOME_LABEL from '@salesforce/label/c.Home';
import isGuest from "@salesforce/user/isGuest";

export default class lwc_prm_knowledgebase extends NavigationMixin(LightningElement) {
    labels = {
        Knowlegde: KNOWLEDGE_LABEL,
        Explore_Documentations_for: EXPLORE_DOCUMENTATION_FOR_LABEL,
        Product: PRODUCT_LABEL,
        All_Products: ALL_PRODUCTS_LABEL,
        Home: HOME_LABEL,
        Documentation: DOCUMENTATION_LABEL,
        For: FOR_LABEL
    };
    @track selectedArticle = '';
    @track panelOpen = true;
    @track currentProduct = '';
    @track currentChapter = '';
    @track articleAllowed = true;

    connectedCallback() {
        this.urlChangeInterval = setInterval(this.checkUrlChange.bind(this), 500);
    }

    disconnectedCallback() {
        clearInterval(this.urlChangeInterval);
    }

    checkUrlChange() {
        const params = new URLSearchParams(window.location.search);
        if (!params || params.toString() === '') {
            document.title = 'Knowledge';
            this.selectedArticle='';
            this.currentProduct ='';
            this.currentChapter ='';
        }
    }

    handleArticleSelect(event) {
        if (event.detail.article != undefined) {
            this.selectedArticle = event.detail.article;
            this.selectedArticle.chapter = (this.selectedArticle.chapter === 'Please Specify') ? 'Others' : this.selectedArticle.chapter;
        } else {
            this.articleAllowed = false;
        }
    }

    handleProductSelect(event) {
        this.currentProduct = event.detail.product;
    }

    navigateTo(event) {
        const url = new URL(document.URL);
        const newUrl = url.toString();
        window.history.pushState({ path: newUrl }, '', newUrl);

        const to = event.target.dataset.to;
        let selectedProduct = this.selectedArticle.topic;
        this.currentProduct = selectedProduct;
        this.selectedArticle = '';

        switch (to) {
            case 'Home':
                pageName = 'Home';
                break;
            case 'Products':
                pageName = 'Partner_resources__c';
                break;
            case 'SelectedProduct':
                window.location.href = '/partner/s/kb?p=' + selectedProduct;
                break;
            default:
                break;
        }

        this.selectedArticle = '';

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            },
            state
        });
    }


    handleOpenClosePanel() {
        this.panelOpen = !this.panelOpen;
        const panelEl = this.template.querySelector('.slds-panel');
        if (this.panelOpen) {
            panelEl.classList.add('slds-is-open');
        } else {
            panelEl.classList.remove('slds-is-open');
        }
    }

    closePanel() {
        this.panelOpen = false;
        const panelEl = this.template.querySelector('.slds-panel');
        panelEl.classList.remove('slds-is-open');
    }

    get isGuest() {
        return isGuest;
    }
}