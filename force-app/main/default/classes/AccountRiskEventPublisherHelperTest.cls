@isTest
private class AccountRiskEventPublisherHelperTest {

    @isTest
    static void testPublishHighRiskEvent() {
        Account testAcc = new Account(
            Name = 'TestAccountEvent',
            Risk__c = 'Low',
            OwnerId = UserInfo.getUserId());
        insert testAcc;
        Test.StartTest();
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            testAcc.Risk__c = 'High';
            update testAcc;
        }
        Test.StopTest();
        Account acc = [SELECT Id, Risk__c FROM Account WHERE Id =: testAcc.Id LIMIT 1];
        Assert.areEqual('High', acc.Risk__c, 'Account updated Successfully');
    }
}