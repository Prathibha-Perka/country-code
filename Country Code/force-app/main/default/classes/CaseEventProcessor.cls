/**
 * Class Name         : CaseEventProcessor
 * @description This class handles processing of the HighRiskAccountEvent__e platform event.
 * It creates a case for accounts marked as "High Risk," ensuring that cases are assigned to eligible users while excluding the current account owner.
 * @Created By        : Raghavendra
 * @last modified on  : 24-03-2025
 * @last modified by  : Raghavendra
 **/
public with sharing class CaseEventProcessor {

    // List of eligible users for case ownership
    @TestVisible
    private List<User> eligibleUsers = new List<User>();

    /**
     * @description Processes AccessPro__HighRiskAccountEvent__e events to create cases for high-risk accounts.
     * @param highRiskEvents List of AccessPro__HighRiskAccountEvent__e platform events.
     */
    public void handleHighRiskEvents(List<AccessPro__HighRiskAccountEvent__e> highRiskEvents) {
        // Collect Account Owner IDs from the events
        Set<Id> accountOwnerIds = new Set<Id>();
        for (AccessPro__HighRiskAccountEvent__e event : highRiskEvents) {
            accountOwnerIds.add(event.AccessPro__AccountOwnerId__c);
        }

        // Query users who own the accounts
        Map<Id, User> accountOwnerToUserMap = getAccountOwners(accountOwnerIds);

        // Load eligible users for case ownership
        populateEligibleUsers();

        // Prepare cases for creation
        List<Case> casesToInsert = new List<Case>();
        for (AccessPro__HighRiskAccountEvent__e event : highRiskEvents) {
            User assignedUser = getEligibleUserExcludingOwner(accountOwnerToUserMap.get(event.AccessPro__AccountOwnerId__c));
            if (assignedUser != null) {
                casesToInsert.add(new Case(
                    AccountId = event.AccessPro__AccountId__c,
                    Subject = 'High Risk Identified',
                    Description = 'A high-risk value has been set on the account.',
                    OwnerId = assignedUser.Id,
                    Origin = 'Web'
                ));
            }
        }

        // Insert cases if there are any to create
        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
    }

    /**
     * @description Retrieves users who own the accounts mentioned in the events.
     * @param ownerIds Set of account owner IDs.
     * @return Map of Account Owner IDs to User records.
     */
    private Map<Id, User> getAccountOwners(Set<Id> ownerIds) {
        List<User> accountOwners = [SELECT Id FROM User WHERE Id IN :ownerIds];
        return new Map<Id, User>(accountOwners);
    }

    /**
     * @description Filters eligible users by excluding the current account owner.
     * @param accountOwner The User record of the current account owner.
     * @return An eligible user for case ownership.
     */
    private User getEligibleUserExcludingOwner(User accountOwner) {
        if (eligibleUsers.contains(accountOwner)) {
            List<User> filteredUsers = new List<User>(eligibleUsers);
            Integer index = filteredUsers.indexOf(accountOwner);
            filteredUsers.remove(index);
            return filteredUsers.isEmpty() ? null : filteredUsers[0];
        }
        return eligibleUsers.isEmpty() ? null : eligibleUsers[0];
    }

    /**
     * @description Loads users who are eligible to own cases based on profile permissions.
     */
    private void populateEligibleUsers() {
        Set<Id> caseProfiles = new Set<Id>();

        // Query profiles with 'Create' permissions on the Case object
        List<ObjectPermissions> objectPermissions = [SELECT Id, Parent.ProfileId 
                                                      FROM ObjectPermissions 
                                                      WHERE PermissionsRead = true AND SobjectType = 'Case'];
        for (ObjectPermissions permission : objectPermissions) {
            if (permission.Parent.ProfileId != null) {
                caseProfiles.add(permission.Parent.ProfileId);
            }
        }

        // Query active users with the eligible profiles
        eligibleUsers = [SELECT Id FROM User WHERE IsActive = true AND ProfileId IN :caseProfiles];
    }
}