@isTest
public with sharing class ContactTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        //we can define our common code for all test classes this can be used for many other test classes
    }
    @isTest
    public static void afterInsertHandler1(){
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test 1'));
        testAccounts.add(new Account(Name = 'Test 2'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(LastName = 'Test Contact 1', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 2', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 3', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 4', AccountId = testAccounts[1].Id));

        insert testContacts;

        List<Account> accs = [SELECT Id, Active_Contacts__c FROM Account];
        System.assertEquals(2, accs.size());
        System.assertEquals(0, Integer.valueOf(accs[0].Active_Contacts__c));
        System.assertEquals(0, Integer.valueOf(accs[1].Active_Contacts__c));
    }



    @isTest
    public static void afterInsertHandler2(){
        List<Account> testAccounts = new  List<Account>();
        testAccounts.add(new Account(Name = 'Test 1'));
        testAccounts.add(new Account(Name = 'Test 2'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(LastName = 'Test Contact 1', AccountId = testAccounts[0].Id, Active__c = true));
        testContacts.add(new Contact(LastName = 'Test Contact 2', AccountId = testAccounts[0].Id, Active__c = true));
        testContacts.add(new Contact(LastName = 'Test Contact 3', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 4', AccountId = testAccounts[1].Id));

        insert testContacts;

        List<Account> accs = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accs.size());
        for(Account acc : accs){
            if(acc.Name == 'Test 1'){
                System.assertEquals(2, acc.Active_Contacts__c);
            }
            if(acc.Name == 'Test 2'){
                System.assertEquals(0, Integer.valueOf(acc.Active_Contacts__c));
            }
        }

        List<Contact> allContacts = [SELECT Id FROM Contact];
        System.assertEquals(4, allContacts.size());
    }



    @isTest
    public static void afterInsertHandlerBulk(){
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test 1'));
        testAccounts.add(new Account(Name = 'Test 2'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0; i<1000; i++){
            testContacts.add(new Contact(LastName = 'Test Contact' + i, AccountId = testAccounts[0].Id, Active__c = true));
        }

        testContacts.add(new Contact(LastName = 'Test Contact Inactive 1', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact Inactive 2', AccountId = testAccounts[1].Id));
        testContacts.add(new Contact(LastName = 'Test Contact Inactive 3', AccountId = testAccounts[1].Id));

        insert testContacts;

        List<Account> accs = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accs.size());
        for(Account acc : accs){
            if(acc.Name == 'Test 1'){
                System.assertEquals(1000, acc.Active_Contacts__c);
            }
            if(acc.Name == 'Test 2'){
                System.assertEquals(0, acc.Active_Contacts__c);
            }
        }
        List<Contact> allContacts = [SELECT Id FROM Contact];
        System.assertEquals(1003, allContacts.size());
    }



    @isTest
    public static void afterUpdateHandler1(){
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test 1'));
        testAccounts.add(new Account(Name = 'Test 2'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(LastName = 'Test Contact 1', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 2', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 3', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 4', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 5', AccountId = testAccounts[1].Id));

        insert testContacts;

        List<Contact> allContacts = [SELECT Id, LastName FROM Contact];
        for(Contact con : allContacts){
            if(con.LastName == 'Test Contact 1' || con.LastName == 'Test Contact 2'){
                con.Active__c = true;
            }
        }
        //allocate new set of governor limits
        test.startTest();
        update allContacts;
        test.stopTest();

        List<Account> accs = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accs.size());

        for(Account acc : accs){
            if(acc.Name == 'Test 1'){
                System.assertEquals(2, acc.Active_Contacts__c);
            }
            if(acc.Name == 'Test 2'){
                System.assertEquals(0, acc.Active_Contacts__c);
            }
        }

        List<Contact> allContact = [SELECT Id FROM Contact];
        System.assertEquals(5, allContact.size());
    }

     @isTest
    public static void afterUpdateHandler2(){
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test 1'));
        testAccounts.add(new Account(Name = 'Test 2'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(LastName = 'Test Contact 1', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 2', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 3', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 4', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 5', AccountId = testAccounts[1].Id));

        insert testContacts;

        List<Contact> allContacts = [SELECT Id, AccountId, LastName FROM Contact];
        for(Contact con : allContacts){
            if(con.LastName == 'Test Contact 1' || con.LastName == 'test Contact 2'){
                con.Active__c = true;
                con.AccountId = testAccounts[1].Id;
            }
        }
        //Generating new set of governor limits
        test.startTest();
        update allContacts;
        test.stopTest();

        List<Account> accs = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accs.size());
        for(Account acc : accs){
            if(acc.Name == 'Test 1'){
                System.assertEquals(0, acc.Active_Contacts__c);
            }
            if(acc.Name == 'Test 2'){
                System.assertEquals(2, Integer.valueOf(acc.Active_Contacts__c));
            }
        }

        List<Contact> allCons = [SELECT Id FROM Contact];
        System.assertEquals(5, allCons.size());
    }

    @isTest
    public static void afterDeleteHandlerTest() {
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test 1'));
        testAccounts.add(new Account(Name = 'Test 2'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(LastName = 'Test Contact 1', AccountId = testAccounts[0].Id, Active__c = true));
        testContacts.add(new Contact(LastName = 'Test Contact 2', AccountId = testAccounts[0].Id, Active__c = true));
        testContacts.add(new Contact(LastName = 'Test Contact 3', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 4', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 5', AccountId = testAccounts[1].Id));

        insert testContacts;

        List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE LastName IN ('Test Contact 1', 'Test Contact 5')];

        test.startTest();
        delete contacts;
        test.stopTest();

        List<Account> accounts = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accounts.size());
        for(Account acc : accounts){
            if(acc.Name == 'Test 1'){
                System.assertEquals(1, acc.Active_Contacts__c);
            }
            if(acc.Name == 'Test 2'){
                System.assertEquals(0, acc.Active_Contacts__c);
            }
        }

        List<Contact> con = [SELECT Id FROM Contact];
        System.assertEquals(3, con.size());
    }

/*
    @isTest
    public static void afterUndeleteHandlerTest() {
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test 1'));
        testAccounts.add(new Account(Name = 'Test 2'));

        insert testAccounts;

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(LastName = 'Test Contact 1', AccountId = testAccounts[0].Id, Active__c = true));
        testContacts.add(new Contact(LastName = 'Test Contact 2', AccountId = testAccounts[0].Id, Active__c = true));
        testContacts.add(new Contact(LastName = 'Test Contact 3', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 4', AccountId = testAccounts[0].Id));
        testContacts.add(new Contact(LastName = 'Test Contact 5', AccountId = testAccounts[1].Id, Active__c = true));

        insert testContacts;

        List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE LastName IN ('Test Contact 1', 'Test Contact 5')];

        test.startTest();
        undelete contacts;
        test.stopTest();

        List<Account> accounts = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accounts.size());
        for(Account acc : accounts){
            if(acc.Name == 'Test 1'){
                System.assertEquals(2, acc.Active_Contacts__c);
            }
            if(acc.Name == 'Test 2'){
                System.assertEquals(1, acc.Active_Contacts__c);
            }
        }

        List<Contact> con = [SELECT Id FROM Contact];
        System.assertEquals(5, con.size());
    }
*/
}