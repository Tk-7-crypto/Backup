import LightningDatatable from 'lightning/datatable';
import customPicklist from './templates/customPicklist';

export default class LwcCpqCustomLightningDatatable extends LightningDatatable {

    
    static customTypes = {
        picklist: {
            template: customPicklist,
            typeAttributes: ['label', 'name', 'value', 'placeholder', 'context', 'variant', 'editable', 'objectApiName', 'fieldApiName']
        }
    };
}