public without sharing class OrderHelper {
    public static void setNetAmount(Map<Id,Order> newOrdersMap, Map<Id,Order> oldOrdersMap){
        for(Order newOrder : newOrdersMap.values()){
            Order oldOrder = oldOrdersMap.get(newOrder.Id);
            if(newOrder.ShipmentCost__c != oldOrder.ShipmentCost__c){
                newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
            }
        }
    }

    public static void setAccountRevenue(Map<Id,Order> newOrdersMap, Map<Id,Order> oldOrdersMap){
        Map<Id, List<Order>> mapAccountIdListOfOrder = new Map<Id, List<Order>>();
        for(Order newOrder : newOrdersMap.values()){
            Order oldOrder = oldOrdersMap.get(newOrder.Id);
            if(newOrder.Status == 'Ordered' && oldOrder.Status != 'Ordered'){
                if(mapAccountIdListOfOrder.get(newOrder.AccountId) != null){
                    mapAccountIdListOfOrder.get(newOrder.AccountId).add(newOrder);
                } 
                else{
                    mapAccountIdListOfOrder.put(newOrder.AccountId,new List<Order>{newOrder});
                }
            }
        }
        if(mapAccountIdListOfOrder.size() > 0){
            List<Account> accountsList = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :mapAccountIdListOfOrder.keySet()];
            for(Account account : accountsList){
                for(Order accountOrder : mapAccountIdListOfOrder.get(account.Id)){
                    if(account.Chiffre_d_affaire__c == null){
                        account.Chiffre_d_affaire__c = 0;
                    }
                    account.Chiffre_d_affaire__c += accountOrder.TotalAmount;
                }
            }

            if(accountsList.size() > 0){
                update accountsList;
            }
        }
    }
}
