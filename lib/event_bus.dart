import 'package:event_bus/event_bus.dart';

//Bus初始化
EventBus eventBus = EventBus();

class LocalRefreshEvent {
  LocalRefreshEvent();
}

class RemoteRefreshEvent {
  RemoteRefreshEvent();
}
