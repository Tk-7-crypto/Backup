import { LightningElement, track, api } from 'lwc';

export default class LWC_CLM_CompactLayout extends LightningElement {
    @api recordId;
    @api left;
    @api name;
    @api objectName;
    @api fields;
    fieldSet = [];
    dummy = [1, 2, 3, 4];
    show;
    hasRendered = false;

    connectedCallback() {
        if(this.fields) {
            this.fieldSet = this.fields.split(';');
        }
    }

    renderedCallback() {
        if(this.template.querySelector('.custom-container') && this.template.querySelector('.header') && this.fieldSet && !this.hasRendered) {
            this.template.querySelector('.custom-container').style.left = `${this.left - 10}px`;
            let h = (this.template.querySelector('.header')).getBoundingClientRect().height;
            this.template.querySelector('.custom-container').style.marginTop = this.fieldSet.length <= 4 ? `${-(h + 55)}px` : `${-(h + 75)}px`;
            this.hasRendered = true;
        }
    }

    handleLoad() {
        this.show = true;
    }
}