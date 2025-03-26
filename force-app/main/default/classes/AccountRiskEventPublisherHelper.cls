/**
 * Class Name         : AccountRiskEventPublisherHelper
 * @description This class checks if an account's risk level has changed to "High." 
 * If it has, it creates and sends a platform event (CreateCaseOnAccountRisk__e) with details about the account and its owner.
 * These events help automate actions like creating cases for high-risk accounts.
 * @Created By        : Raghavendra
 * @last modified on  : 24-03-2025
 * @last modified by  : Raghavendra
 **/
public with sharing class AccountRiskEventPublisherHelper {
    /**
     * @description Publishes platform events for accounts where the risk level is updated to 'High'.
     * @param updatedAccounts The list of updated Account records.
     * @param oldAccountMap A map of old Account records, keyed by Account ID.
     */
    public void publishHighRiskEvents(List<Account> updatedAccounts, Map<Id, Account> oldAccountMap) {
        List<AccessPro__HighRiskAccountEvent__e> highRiskEvents = new List<AccessPro__HighRiskAccountEvent__e>();
        
        // Iterate through updated accounts and compare with old values
        for (Account updatedAcc : updatedAccounts) {
            Account oldAcc = oldAccountMap.get(updatedAcc.Id);
			
            // Check if Risk__c transitioned to 'High'
            if (updatedAcc.Risk__c == 'High' && (oldAcc == null || oldAcc.Risk__c != 'High')) {
                highRiskEvents.add(new AccessPro__HighRiskAccountEvent__e(
                    AccessPro__AccountId__c = updatedAcc.Id,
                    AccessPro__AccountOwnerId__c = updatedAcc.OwnerId
                ));
            }
        }
        
        // Publish platform events if any are created
        if (!highRiskEvents.isEmpty()) {
            EventBus.publish(highRiskEvents);
        }
    }
}