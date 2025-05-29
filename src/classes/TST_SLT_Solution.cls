@isTest
private class TST_SLT_Solution {
    testmethod static void testselectField(){
        Solution sol=new Solution(SolutionName='Solution Test');
        new SLT_Solution().selectBySolutionId(new Set<ID>{sol.Id}, new Set<String>{'Id','SolutionName'});
        
    }
}