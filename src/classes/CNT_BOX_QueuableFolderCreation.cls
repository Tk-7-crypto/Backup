public with sharing class CNT_BOX_QueuableFolderCreation implements Queueable{
    public Id recId;
    public Id oppId;
    public String ObjectName;
    public CNT_BOX_QueuableFolderCreation(id recId, id oppId, String ObjectName) {
        this.recId = recId;
        this.oppId = oppId;
        this.ObjectName = ObjectName;
    }
    public void execute(QueueableContext qc){
        CNT_BOX_NestedFoldersCreation.creatingNestedFolders(recId, oppId, ObjectName);
    }
}