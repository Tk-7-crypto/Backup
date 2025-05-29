import { LightningElement, wire, track, api } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import getServiceList from "@salesforce/apex/CNT_CLM_CommonController.getServiceList";

export default class LWC_CLM_Flow_Services extends LightningElement {
    @track options = [];
    @track values = [];
    @api services;
    @api defaultService;
    @api pathway;
    @api fieldName;
    @api objName;
    @api recTypeId;
    isLoading;
    
    connectedCallback() {
        const items = [];
        getServiceList({
            objName: this.objName,
            fieldName : this.fieldName,
            recordTypeId : this.recTypeId,
            pathway : this.pathway
        }).then((result) => {
            result.forEach((element) => {
                let obj = {
                    label: `${element}`,
                    value: `${element}`
                };
                items.push(obj);
            });
            this.options.push(...items);
            if(this.defaultService) {
                let preService = this.defaultService.split(";");
                this.values.push(...preService);
            }
            this.isLoading = true;
            this.dispatchEvent(new FlowAttributeChangeEvent('services', this.defaultService));
        });
    }
    
    handleChange(event) {
        let values = event.detail.value;
        let finalService = "";
        values.forEach((element) => {
            finalService += element + ";";
        });
        this.dispatchEvent(
            new FlowAttributeChangeEvent("services", finalService)
        );
    }
}
