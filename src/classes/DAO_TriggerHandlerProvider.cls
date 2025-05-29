/**
 * @author Vlad Tyazhov
 * Apex Framework for unifying trigger logic based on Trigger_Handler__mdt custom metadata.
 */
public without sharing class DAO_TriggerHandlerProvider {
    private static Set<System.Type> bypassHandlerTypes;
    private static Set<SObjectType> bypassSObjectTypes;
    private static Map<System.Type, Set<TriggerOperation>> bypassHandlerTypesByEvent;
    private static Boolean debugMode;
    private static Map<SObjectType, List<Trigger_Handler__mdt>> triggerHandlersBySObject;
    @TestVisible private static TriggerContext mockTriggerContext;

    /**
     * init handler
     */
    static {
        setDebugMode(false);
        bypassHandlerTypes = new Set<System.Type>();
        bypassSObjectTypes = new Set<SObjectType>();
        bypassHandlerTypesByEvent = new Map<System.Type, Set<TriggerOperation>>();

        List<Trigger_Handler__mdt> triggerHandlers = [
                SELECT sObjectName__c, HandlerName__c
                FROM Trigger_Handler__mdt
                WHERE IsActive__c = TRUE
                ORDER BY sObjectName__c, ExecutionOrder__c ASC NULLS LAST
        ];
        initHandlersMap(triggerHandlers);
    }

    public static void execute() {
        TriggerContext triggerContext = mockTriggerContext != null ? mockTriggerContext : new TriggerContext();

        try {
            List<Trigger_Handler__mdt> triggerHandlers = triggerHandlersBySObject.get(triggerContext.sObjectType);
            if (triggerHandlers == null || bypassSObjectTypes.contains(triggerContext.sObjectType)) return;
            new HandlersExecutor(triggerHandlers).execute(triggerContext);

        } catch (Exception e) {
            throw new ApexLogException(e, triggerContext);
        }
    }

    public static void bypassHandler(System.Type handlerType) {
        bypassHandlerTypes.add(handlerType);
    }

    public static void bypassSObjectType(SObjectType sObjectType) {
        bypassSObjectTypes.add(sObjectType);
    }

    public static void bypassHandler(System.Type handlerType, TriggerOperation event) {
        if (!bypassHandlerTypesByEvent.containsKey(handlerType)) {
            Set<TriggerOperation > eventSet = new Set<TriggerOperation>{
                    event
            };
            bypassHandlerTypesByEvent.put(handlerType, eventSet);
        } else {
            Set<TriggerOperation > eventSet = bypassHandlerTypesByEvent.get(handlerType);
            if (!eventSet.contains(event)) eventSet.add(event);
            bypassHandlerTypesByEvent.put(handlerType, eventSet);
        }
    }

    public static void setDebugMode(Boolean debugMode) {
        System.debug('Debug Mode: ' + debugMode + ' time: ' + Datetime.now().time());
        DAO_TriggerHandlerProvider.debugMode = debugMode;
    }

    public static void setMockMetadata(Trigger_Handler__mdt triggerHandler) {
        initHandlersMap(new List<Trigger_Handler__mdt>{
                triggerHandler
        });
    }

    public static void setMockTriggerContext(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap, TriggerOperation operationType) {
        mockTriggerContext = new TriggerContext(newList, newMap, oldList, oldMap, operationType);
    }

    public static Boolean isDebugMode() {
        return DAO_TriggerHandlerProvider.debugMode;
    }

    public static void clearBypass(System.Type handlerType) {
        bypassHandlerTypes.remove(handlerType);
    }

    public static void clearBypass(SObjectType sObjectType) {
        bypassSObjectTypes.remove(sObjectType);
    }

    public static void clearBypass(System.Type handlerType, TriggerOperation event) {
        bypassHandlerTypesByEvent.get(handlerType).remove(event);
    }

    private static void initHandlersMap(List<Trigger_Handler__mdt> triggerHandlers) {
        triggerHandlersBySObject = new Map<SObjectType, List<Trigger_Handler__mdt>>();
        Map<String, SObjectType> schemaDescribe = Schema.getGlobalDescribe();
        for (Trigger_Handler__mdt triggerHandler : triggerHandlers) {
            SObjectType currentSObjectType = schemaDescribe.get(triggerHandler.sObjectName__c);
            if (currentSObjectType == null) continue;
            if (!triggerHandlersBySObject.containsKey(currentSObjectType)) {
                triggerHandlersBySObject.put(currentSObjectType, new List<Trigger_Handler__mdt>());
            }
            triggerHandlersBySObject.get(currentSObjectType).add(triggerHandler);
        }
    }

    private static void contextExecuteHandler(TriggerContext triggerContext, DAO_TriggerHandler handler, System.Type handlerType) {
        if (!triggerContext.isMocked && !triggerContext.isExecuting) return;

        if (triggerContext.isBefore) {
            if (triggerContext.isInsert) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.BEFORE_INSERT)) {
                    handler.beforeInsert(triggerContext.newList);
                }
            }
            if (triggerContext.isUpdate) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.BEFORE_UPDATE)) {
                    handler.beforeUpdate(triggerContext.newList, triggerContext.oldMap);
                }
            }
            if (triggerContext.isDelete) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.BEFORE_DELETE)) {
                    handler.beforeDelete(triggerContext.oldList);
                }
            }
        }
        if (triggerContext.isAfter) {
            if (triggerContext.isInsert) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.AFTER_INSERT)) {
                    handler.afterInsert(triggerContext.newList);
                }
            }
            if (triggerContext.isUpdate) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.AFTER_UPDATE)) {
                    handler.afterUpdate(triggerContext.newList, triggerContext.oldMap);
                }
            }
            if (triggerContext.isDelete) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.AFTER_DELETE)) {
                    handler.afterDelete(triggerContext.oldList);
                }
            }
            if (triggerContext.isUndelete) {
                if (!bypassHandlerTypesByEvent.containsKey(handlerType)
                        || !bypassHandlerTypesByEvent.get(handlerType).contains(TriggerOperation.AFTER_UNDELETE)) {
                    handler.afterUnDelete(triggerContext.newList);
                }
            }
        }
    }

    public class HandlersExecutor {
        private List<Trigger_Handler__mdt> triggerHandlers;

        public HandlersExecutor(List<Trigger_Handler__mdt> triggerHandlers) {
            this.triggerHandlers = triggerHandlers;
        }

        public void execute(TriggerContext triggerContext) {
            for (Trigger_Handler__mdt triggerHandler : triggerHandlers) {
                Type handlerType = Type.forName(triggerHandler.HandlerName__c);
                if (handlerType == null) {
                    throw new DAO_TriggerHandlerException('Unknown handler type: "' + triggerHandler.HandlerName__c + '"');
                }
                if (bypassHandlerTypes.contains(handlerType)) return;

                DAO_TriggerHandler handlerInstance = (DAO_TriggerHandler) handlerType.newInstance();
                handlerInstance.init(handlerType);
                contextExecuteHandler(triggerContext, handlerInstance, handlerType);
            }
        }
    }

    public class TriggerContext {
        public Boolean isBefore;
        public Boolean isAfter;
        public Boolean isInsert;
        public Boolean isUpdate;
        public Boolean isDelete;
        public Boolean isUndelete;
        public List<SObject> newList;
        public Map<Id, SObject> newMap;
        public List<SObject> oldList;
        public Map<Id, SObject> oldMap;
        public TriggerOperation operationType;
        public Boolean isExecuting = false;
        public Boolean isMocked = false;
        public SObjectType sObjectType;
        public String sObjectName;

        public TriggerContext() {
            this(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType, Trigger.isExecuting, false);
        }

        public TriggerContext(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap, TriggerOperation operationType) {
            this(newList, newMap, oldList, oldMap, operationType, false, true);
        }

        private TriggerContext(List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap,
                TriggerOperation operationType, Boolean isExecuting, Boolean isMocked) {
            this.newList = newList;
            this.newMap = newMap;
            this.oldList = oldList;
            this.oldMap = oldMap;
            this.operationType = operationType;
            this.isExecuting = isExecuting;
            this.isMocked = isMocked;
            this.sObjectType = getSObjectType();
            this.sObjectName = this.sObjectType.getDescribe().getName();
            initMarkers();
        }

        public SObjectType getSObjectType() {
            return operationType.name().containsIgnoreCase('_delete') ? oldList.getSObjectType() : newList.getSObjectType();
        }

        public List<SObject> getRecords() {
            return operationType.name().containsIgnoreCase('_delete') ? oldList : newList;
        }

        private void initMarkers() {
            isBefore = operationType.name().containsIgnoreCase('before');
            isAfter = operationType.name().containsIgnoreCase('after');
            isInsert = operationType.name().containsIgnoreCase('insert');
            isUpdate = operationType.name().containsIgnoreCase('update');
            isDelete = operationType.name().containsIgnoreCase('delete');
            isUndelete = operationType.name().containsIgnoreCase('undelete');
        }
    }

    public class DAO_TriggerHandlerException extends Exception {}

    public class ApexLogException extends Exception {
        public Id recordId;
        public String errorDescription;
        public String sObjectName;
        public String sourceModule = 'Copado';

        public ApexLogException(Exception e, TriggerContext triggerContext) {
            if (e instanceof DmlException) {
                this.recordId = ((DmlException) e).getDmlId(0);
            }
            if (triggerContext != null) {
                this.sObjectName = triggerContext.sObjectName;
            }
            this.errorDescription = e.getMessage() + '\n' + e.getStackTraceString();

            this.setMessage(this.errorDescription);
            this.insertLog();  // insert log record using Platform event
        }

        // Insert ApexLog record using Platform Event (for successful process if transaction fails)
        private void insertLog() {
            EventBus.publish(new Apex_Error_Log_Event__e(
                    Object__c = this.sObjectName,
                    Error_Message__c = this.errorDescription,
                    Record_Id__c = this.recordId,
                    Running_User__c = UserInfo.getUserId(),
                    Source_Module__c = this.sourceModule
            ));
        }
    }
}