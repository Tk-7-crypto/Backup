export const COLUMNS = [
    { label: 'Vendor Account Name', fieldName: 'accountName' , type :'text',sortable:'true' ,hideDefaultActions: 'true', actions:[
        { label: 'Ascending', checked: true, name: 'ASC' },
        { label: 'Descending', checked: false, name: 'DESC' },
    ]},
    { label: 'Vendor Account Compliance Name', fieldName: 'accountComplianceURL', type :'url', typeAttributes: {
        label: { fieldName: 'accountComplianceName' }
    }},
    { label: 'Vendor Account Hold Flag', fieldName: 'status', type: 'boolean'},
    { label: 'Vendor Account on Hold Reason', fieldName: 'reason', type: 'text'},
    { label: 'Vendor Account Hold date', fieldName: 'onHoldDate', type: 'text'},
    { label: 'Vendor Account Release date', fieldName: 'onReleaseDate', type: 'text'},
    { label: 'Hold Duration', fieldName: 'duration', type: 'text'}
];

export function recordsWrapper(TaskRecord, task){
    if(task.Description){
        var description = task.Description.split('\n');

        if(description?.length > 3){
            TaskRecord.onHoldDate = description[0].split(':')[1];
            TaskRecord.onReleaseDate = description[1].split(':')[1];
            TaskRecord.duration = description[2].split(':')[1];
            if(description[3].split(':')[1] != null && description[3].split(':')[1].trim() != 'null')
                TaskRecord.reason = description[3].split(':')[1] ;
        }
    }
    return TaskRecord
}

