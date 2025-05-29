public virtual inherited sharing class SLT_PC_GridRateCurrency {
    public static List<SObject> records(List<SObject> records)
    {
        return instance.passThrough(records);
    }

    static SLT_PC_GridRateCurrency instance = new SLT_PC_GridRateCurrency();
    @TestVisible static void setMock(SLT_PC_GridRateCurrency mock) { instance = mock; }

    protected virtual List<SObject> passThrough(List<SObject> records) { return records; }
}