import { LightningElement, api, track } from 'lwc';
import defaultTemplate from './defaultCollectionToolRow.html';
import multipleRowTemplate from './multipleCollectionToolRow.html';
export default class LwcOwfGenericCollectionToolRow extends LightningElement {
    @api enableDeleteButton = false;
    @api displayDeleteFirstRow = false;
    @api columns;
    @api row;
    @api templateName;
    @api tableNumber;
    @api enableClearRow = false;
    @api showRowNumber= false;
    @track multipleRows =[];

    connectedCallback() {
        this.prepareDataMultipleRowTemplate();
    }

    prepareDataMultipleRowTemplate() {
        let maxRowNumber = this.columns.length > 0 ? 
            Math.max(...this.columns.map(c => c.displayRowNumber)) : 1; 
        this.multipleRows = [];
        for(let i=1;i <= maxRowNumber;i++) {
            this.multipleRows.push({
                innerTableNumber : i,
                displayAction : i==1 ? true : false,
                columns : this.columns.filter((col) => (col.displayRowNumber == i)),
            })
        }
    } 

    get notFirstRow() {
        return (this.row.rowNumber !== 1 || (this.displayDeleteFirstRow !== undefined && this.displayDeleteFirstRow));
    } 

    get showcell(){
        return this.row.rowNumber === 0;
    }

    handleDeleteRowAction() {
        const deleteEvent = new CustomEvent("deleteaction", {detail : { 
            tableNumber: this.tableNumber,
            row: this.row 
        }});
        this.dispatchEvent(deleteEvent);
    }
    handleClearRowAction() {
        const clearEvent = new CustomEvent("clearaction", {
            detail: {
                tableNumber: this.tableNumber,
                row: this.row,
            }
        });
        this.dispatchEvent(clearEvent);
        this.clearSelection();


    }
    @api
    clearSelection() {
        [...this.template.querySelectorAll("c-lwc-owf-generic-collection-tool-cell")].forEach((element) => {
            if (element.column.type === 'record-picker') {
                element.clearRecordPickerData();
            }
        });
    }

    handleUpdateAction(event) {
        const updateEvent = new CustomEvent("updateaction", {detail : event.detail});
        this.dispatchEvent(updateEvent);
    }

    @api
    checkValidity() {
        let isChildValidated = true;
        [...this.template.querySelectorAll("c-lwc-owf-generic-collection-tool-cell")].forEach((element) => {
            if (element.checkValidity() === false) {
                isChildValidated = false;
            }
        }); 
        return isChildValidated;
    }
    get displayActionColumn() {
        return this.enableClearRow || this.enableDeleteButton;
    }

    get actionColumnWidth() {
        let w = 0;
        if(this.enableDeleteButton) w += 50;
        if(this.enableClearRow) w += 50;
        return "width:" + w + "px";
    }

    render() {
        return this.templateName ? multipleRowTemplate : defaultTemplate;
    }
}
