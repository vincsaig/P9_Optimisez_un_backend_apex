trigger TriggerOrder on Order (before update, after update) {
    new TH_Order().run();
}