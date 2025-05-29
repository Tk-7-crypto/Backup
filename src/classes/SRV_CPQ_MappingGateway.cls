/*
* Version       : 0.0.1
* Description   : This Apex class is DML layer for SObject
* Created By    : Danish khan
* Created For   : Mapping layer API
*/

public class SRV_CPQ_MappingGateway {

    public static WPR_CPQ_UowDmlResult insertRecords(List<SObject> records) {
        return performOperation(records, 'INSERT');
    }

    public static WPR_CPQ_UowDmlResult updateRecords(List<SObject> records) {
        return performOperation(records, 'UPDATE');
    }

    public static WPR_CPQ_UowDmlResult deleteRecords(List<SObject> records) {
        return performOperation(records, 'DELETE');
    }

    private static WPR_CPQ_UowDmlResult performOperation(List<SObject> records, String operation) {
        List<String> errors = new List<String>();
        if (records == null || records.isEmpty()) return new WPR_CPQ_UowDmlResult(true, errors, new List<SObject>());

        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                (new Map<String, Schema.SObjectType>(Schema.getGlobalDescribe())).values()
            );

            for (SObject rec : records) {
                if (operation == 'INSERT')
                    uow.registerNew(rec);
                else if (operation == 'UPDATE')
                    uow.registerDirty(rec);
                else if (operation == 'DELETE')
                    uow.registerDeleted(rec);
            }

            uow.commitWork();
            return new WPR_CPQ_UowDmlResult(true, errors, records);
        } catch (Exception ex) {
            errors.add('Error: ' + ex.getMessage());
            return new WPR_CPQ_UowDmlResult(false, errors, new List<SObject>());
        }
    }

    public class WPR_CPQ_UowDmlResult {
        public Boolean success;
        public List<String> errors = new List<String>();
        public List<SObject> records = new List<SObject>();

        public WPR_CPQ_UowDmlResult(Boolean success, List<String> errors, List<SObject> records) {
            this.success = success;
            this.errors = errors;
            this.records = records;
        }
    }
}