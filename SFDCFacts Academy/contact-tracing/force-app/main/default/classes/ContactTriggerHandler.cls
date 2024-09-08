public with sharing class ContactTriggerHandler {
    public static void afterInsertHandler(List<Contact> newContacts) {
            //we are building a unique accountIds Set
            Set<Id> accountIds = new Set<Id>();
            //we are iterating over contacts that we get inside the Trigger.new(newContacts) and we are bulding the Unique accountIds
            for(Contact con : newContacts){
                if(String.isNotBlank(con.AccountId)){
                    //write automation logic here
                    accountIds.add(con.AccountId);
                }
            }
            AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterUpdateHandler(List<Contact> newContacts, Map<Id, Contact> oldContacts){
        Set<Id> accountIds = new Set<Id>();
            for(Contact con : newContacts){
                //capture the account id, only if the active checkbox is flipped from check to uncheck or uncheck to check
                if(String.isNotBlank(con.AccountId) && oldContacts.get(con.Id).Active__c != con.Active__c){
                    accountIds.add(con.AccountId);
                //capture the old account and new account which can be changed in contact record
                //we are going to add the AccountId and also we are going to add the old AccoundId as well
                }else if(oldContacts.get(con.Id).AccountId != con.AccountId){
                    accountIds.add(con.AccountId);
                    accountIds.add(oldContacts.get(con.Id).AccountId);
                }
            }
            AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterDeleteHandler(List<Contact> oldContacts){
        Set<Id> accountIds = new Set<Id>();
        //Iterating over the old contacts(deleted contacts which are after deleted)
        for(Contact con : oldContacts){
            //if AccountId is not blank then add in our custom accountIds
            if(String.isNotBlank(con.AccountId)){
                accountIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accountIds);
    }

    // we are recovering these records from the recycle bin so we will treat them new contacts
    public static void afterUndeleteHandler(List<Contact> newContacts){
        Set<Id> accountIds = new Set<Id>();
        for(Contact con : newContacts){
            if(String.isNotBlank(con.AccountId)){
                accountIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accountIds);
    }
}