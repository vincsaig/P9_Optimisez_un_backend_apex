public without sharing class OrderHelper {
    public static void setNetAmount(Map<Id,Order> newOrdersMap, Map<Id,Order> oldOrdersMap){
        for(Order newOrder : newOrdersMap.values()){
            Order oldOrder = oldOrdersMap.get(newOrder.Id);
            if(newOrder.ShipmentCost__c != oldOrder.ShipmentCost__c){
                newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
            }
        }
    }
}
