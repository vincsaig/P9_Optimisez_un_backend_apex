@isTest
private class Order_Test {
    @TestSetup
    static void createData(){
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        insert pd1;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;

        List<Order> ordersList = new List<Order>();
        for(Integer i = 0; i < 201; i++){
            Order order = new Order(AccountId = acc1.Id, EffectiveDate = Date.today(), Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId());
            ordersList.add(order);
        }
        insert ordersList;

        List<OrderItem> ois = new List<OrderItem>();
        for(Order order : ordersList){
            OrderItem oi1 = new OrderItem (OrderId = order.Id, PricebookEntryId = pbe.Id, Quantity=10, UnitPrice = 150);
            OrderItem oi2 = new OrderItem (OrderId = order.Id, PricebookEntryId = pbe.Id, Quantity=20, UnitPrice = 1000);
            ois.add(oi1);
            ois.add(oi2);
        }

        insert ois;
    }

    @isTest 
    static void testSetNetAmount() {
        Order order = [SELECT ShipmentCost__c FROM Order LIMIT 1];
        order.ShipmentCost__c = 500;

        test.startTest();
        update order;
        test.stopTest();

        Order updatedOrder = [SELECT ShipmentCost__c, TotalAmount, NetAmount__c FROM Order WHERE ShipmentCost__c = :order.ShipmentCost__c LIMIT 1];
        Decimal expectedNetAmount = updatedOrder.TotalAmount - updatedOrder.ShipmentCost__c;
        System.assertEquals(expectedNetAmount, updatedOrder.NetAmount__c, 'The NetAmount is wrong');
    }

    @isTest
    static void testSetAccountRevenue(){
        Order order = [SELECT ShipmentCost__c, Status, TotalAmount FROM Order LIMIT 1];
        order.ShipmentCost__c = 500;
        order.Status = 'Ordered';

        test.startTest();
        update order;
        test.stopTest();

        Account acc = [SELECT Chiffre_d_affaire__c FROM Account LIMIT 1];
        System.assertEquals(order.TotalAmount, acc.Chiffre_d_affaire__c, 'The Account revenue is wrong');
    }

    @isTest
    static void testSetAccountRevenueWithMoreThan200Orders(){
        Decimal expectedAccountRevenue = 0;
        List<Order> listOfOrders = [SELECT Status, TotalAmount FROM Order];
        for(Order order : listOfOrders){
            order.Status = 'Ordered';
            expectedAccountRevenue += order.TotalAmount;
        }
        
        test.startTest();
        update listofOrders;
        test.stopTest();

        Account acc1 = [SELECT Chiffre_d_affaire__c FROM Account LIMIT 1];
        System.assertEquals(expectedAccountRevenue, acc1.Chiffre_d_affaire__c, 'The accounts "Chiffre d\'affaire" is not correct');
    }

    @isTest
    static void testBatch01AccountChiffreAffaire(){
        Decimal expectedAccountRevenue = 0;
        List<Order> listOfOrders = [SELECT Status, TotalAmount FROM Order LIMIT 200];
        for(Order order : listOfOrders){
            order.Status = 'Ordered';
            expectedAccountRevenue += order.TotalAmount;
        }
        update listofOrders;

        Account acc1 = [SELECT Chiffre_d_affaire__c FROM Account LIMIT 1];
        acc1.Chiffre_d_affaire__c = 0;
        update acc1;

        test.startTest();
        Database.executeBatch(new Batch01AccountChiffreAffaire());
        test.stopTest();

        acc1 = [SELECT Chiffre_d_affaire__c FROM Account LIMIT 1];
        System.assertEquals(expectedAccountRevenue, acc1.Chiffre_d_affaire__c, 'The accounts "Chiffre d\'affaire" is not correct');
    }
}
