/* TPA Reports UTILITY Module */
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export const SEPARATOR = isIE()  ? '~' : ',';

function isIE() {
    var ua = window.navigator.userAgent;
    return ua.indexOf("MSIE ") > -1 || ua.indexOf("Trident/") > -1;
}

export function csvWrapper(value){
    value = value != null ? value : '';
    return '"' + value + '"';
}

export function csvExport(data, fileName){
    if (isIE()) {
        var oWin = window.open("text/html", "replace");
        oWin.document.write('sep=~\r\n' + data);
        oWin.document.close();
        fileName = (fileName + ".csv");
        oWin.document.execCommand('SaveAs', true, fileName);
        oWin.close();
    }else{
        var blobdata = new Blob(["\uFEFF" + data],{type : 'text/plain'});
        var link = document.createElement("a");
        link.target = '_top';
        link.setAttribute("href", window.URL.createObjectURL(blobdata));
        link.setAttribute("download", fileName + ".csv");
        link.style = "visibility:hidden";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
}

export function showNotification(titleText, messageText, variant) {
    const evt = new ShowToastEvent({
        title: titleText,
        message: messageText,
        variant: variant,
    });
    dispatchEvent(evt);
}

export function dateDuration(date1, date2){
    date1 = (date1 == null) ? new Date() :new Date(date1);
    date2 = (date2 == null) ? new Date() :new Date(date2);
    const diffTime = Math.abs(date2 - date1);
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24)); 
    return diffDays;
}

export function dateFormatter(date){
    date = new Date(date);
    return date?.toLocaleDateString('es-pa')
}