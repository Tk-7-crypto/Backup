/**
 * @author Vlad Tyazhov
 * Apex Framework for unifying trigger logic based on Trigger_Handler__mdt custom metadata.
 */
public abstract without sharing class DAO_TriggerHandler {
    private TriggerOperation currentTriggerEvent;
    private RunCounter counter;
    private DebugModeStats debugStats;

    public void init(Type handlerType) {
        counter = new RunCounter(handlerType);
        debugStats = new DebugModeStats(handlerType);
    }

    public void beforeInsert(List<SObject> newList) {
        setTriggerEvent(TriggerOperation.BEFORE_INSERT);
        debugStart();
        runBeforeHandle();
        onBeforeInsert(newList);
        runAfterHandle();
        debugFinish();
    }

    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        setTriggerEvent(TriggerOperation.BEFORE_UPDATE);
        debugStart();
        runBeforeHandle();
        onBeforeUpdate(newList, oldMap);
        runAfterHandle();
        debugFinish();
    }

    public void beforeDelete(List<SObject> oldList) {
        setTriggerEvent(TriggerOperation.BEFORE_DELETE);
        runBeforeHandle();
        onBeforeDelete(oldList);
        runAfterHandle();
        debugFinish();
    }

    public void afterInsert(List<SObject> newList) {
        setTriggerEvent(TriggerOperation.AFTER_INSERT);
        debugStart();
        runBeforeHandle();
        onAfterInsert(newList);
        runAfterHandle();
        debugFinish();
    }

    public void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        setTriggerEvent(TriggerOperation.AFTER_UPDATE);
        debugStart();
        runBeforeHandle();
        onAfterUpdate(newList, oldMap);
        runAfterHandle();
        debugFinish();
    }

    public void afterDelete(List<SObject> oldList) {
        setTriggerEvent(TriggerOperation.AFTER_DELETE);
        debugStart();
        runBeforeHandle();
        onAfterDelete(oldList);
        runAfterHandle();
        debugFinish();
    }

    public void afterUnDelete(List<SObject> oldList) {
        setTriggerEvent(TriggerOperation.AFTER_UNDELETE);
        onAfterUnDelete(oldList);
        runAfterHandle();
        debugFinish();
    }

    protected virtual void runBeforeHandle() {}
    protected virtual void runAfterHandle() {}

    protected virtual void onBeforeInsert(List<SObject> newList) {}
    protected virtual void onBeforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    protected virtual void onBeforeDelete(List<SObject> oldList) {}

    protected virtual void onAfterInsert(List<SObject> newList) {}
    protected virtual void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    protected virtual void onAfterDelete(List<SObject> oldList) {}
    protected virtual void onAfterUnDelete(List<SObject> oldList) {}

    //private methods:
    private void setTriggerEvent(TriggerOperation event) {
        this.currentTriggerEvent = event;
    }

    private void debugStart() {
        if (DAO_TriggerHandlerProvider.isDebugMode()) {
            counter.run(currentTriggerEvent);
            debugStats.logStart();
        }
    }

    private void debugFinish() {
        if (DAO_TriggerHandlerProvider.isDebugMode()) {
            debugStats.logFinish();
            debugStats.previewStats(currentTriggerEvent);
            counter.runPreview(currentTriggerEvent);
        }
    }

    //sub classes:
    private class RunCounter {

        private Map<TriggerOperation, Integer> runCount;
        private System.Type handlerType;

        public RunCounter(System.Type handlerType) {
            runCount = new Map<TriggerOperation, Integer>{
                    TriggerOperation.BEFORE_INSERT => 0,
                    TriggerOperation.BEFORE_UPDATE => 0,
                    TriggerOperation.BEFORE_DELETE => 0,
                    TriggerOperation.AFTER_INSERT => 0,
                    TriggerOperation.AFTER_UPDATE => 0,
                    TriggerOperation.AFTER_DELETE => 0,
                    TriggerOperation.AFTER_UNDELETE => 0
            };
            this.handlerType = handlerType;
        }

        public void run(TriggerOperation event) {
            runCount.put(event, runCount.get(event) + 1);
            System.debug('>> ' + handlerType.getName() + ' executing ' + event);
        }

        public void runPreview(TriggerOperation event) {
            System.debug('\n>> ' + handlerType.getName() + ':' + event + ' finished.\nTotals: ' + runCount);
        }
    }

    private class DebugModeStats {

        private System.Type handlerType;
        private Map<String, Decimal> statsBefore;
        private Map<String, Decimal> statsAfter;

        public DebugModeStats(System.Type handlerType) {
            this.handlerType = handlerType;
            statsBefore = new Map<String, Decimal>();
            statsAfter = new Map<String, Decimal>();
        }

        public void logStart() {
            statsBefore.put('Queries', Limits.getQueries());
            statsBefore.put('Query rows', Limits.getQueryRows());
            statsBefore.put('Dml statements', Limits.getDmlStatements());
            statsBefore.put('Dml rows', Limits.getDmlRows());
        }

        public void logFinish() {
            statsAfter.put('Queries', Limits.getQueries());
            statsAfter.put('Query rows', Limits.getQueryRows());
            statsAfter.put('Dml statements', Limits.getDmlStatements());
            statsAfter.put('Dml rows', Limits.getDmlRows());
        }

        public void previewStats(TriggerOperation event) {
            System.debug('\n?> Stats for ' + handlerType.getName() + ':' + event);
            for (String key : this.statsBefore.keySet()) {
                System.debug(key + ' used ' + (statsAfter.get(key) - statsBefore.get(key)));
            }
        }
    }
}