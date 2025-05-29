import LightningDatatable from 'lightning/datatable';
import customPicklistTemplate from './template/customPicklist';
import customPicklistEditTemplate from './template/customPicklistEdit';

export default class LWC_CPQ_Custom_Data_Table extends LightningDatatable {
    static customTypes = {
        customPicklist: {
            template: customPicklistTemplate,
            editTemplate: customPicklistEditTemplate,
            standardCellLayout: true,
            typeAttributes: ["label", "options", "value", "context", "isPickList", "isString"]
        }
    }
}