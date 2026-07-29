@isTest
private class AccountServiceTest {
    @isTest
    static void countsRelatedContacts() {
        Account acc = new Account(Name = 'Acme');
        insert acc;
        insert new List<Contact>{
            new Contact(LastName = 'One', AccountId = acc.Id),
            new Contact(LastName = 'Two', AccountId = acc.Id)
        };

        Test.startTest();
        Integer result = AccountService.getRelatedCount(acc.Id);
        Test.stopTest();

        System.assertEquals(2, result, 'Expected two related contacts for the account');
    }
}
