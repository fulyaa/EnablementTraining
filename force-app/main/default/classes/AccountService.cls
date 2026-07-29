public with sharing class AccountService {
    // Returns the number of Contacts related to an Account.
    public static Integer getRelatedCount(Id accountId) {
        return [SELECT COUNT() FROM Contact WHERE AccountId = :accountId];
    }
}
