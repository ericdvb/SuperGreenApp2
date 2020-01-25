import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:super_green_app/data/rel/rel_db.dart';

class MainNavigatorEvent extends Equatable {
  final void Function(Future<Object> future) futureFn;

  MainNavigatorEvent({this.futureFn});

  @override
  List<Object> get props => [];
}

class MainNavigateToHomeEvent extends MainNavigatorEvent {
  MainNavigateToHomeEvent();

  @override
  List<Object> get props => [];
}

class MainNavigateToHomeBoxEvent extends MainNavigateToHomeEvent {
  final Box box;

  MainNavigateToHomeBoxEvent(this.box);

  @override
  List<Object> get props => [box];
}

class MainNavigateToNewBoxInfosEvent extends MainNavigatorEvent {
  @override
  List<Object> get props => [];
}

class MainNavigateToSelectBoxDeviceEvent extends MainNavigatorEvent {
  final Box box;

  MainNavigateToSelectBoxDeviceEvent(this.box);

  @override
  List<Object> get props => [box];
}

class MainNavigateToSelectBoxDeviceBoxEvent extends MainNavigatorEvent {
  final Box box;

  MainNavigateToSelectBoxDeviceBoxEvent(this.box);

  @override
  List<Object> get props => [box];
}

class MainNavigateToNewDeviceEvent extends MainNavigatorEvent {
  final Box box;

  MainNavigateToNewDeviceEvent(this.box);

  @override
  List<Object> get props => [box];
}

class MainNavigateToExistingDeviceEvent extends MainNavigatorEvent {
  final Box box;

  MainNavigateToExistingDeviceEvent(this.box);

  @override
  List<Object> get props => [box];
}

class MainNavigateToDeviceSetupEvent extends MainNavigatorEvent {
  final ip;
  final Box box;

  MainNavigateToDeviceSetupEvent(this.box, this.ip);

  @override
  List<Object> get props => [ip];
}

class MainNavigateToDeviceNameEvent extends MainNavigatorEvent {
  final Box box;
  final Device device;
  MainNavigateToDeviceNameEvent(this.box, this.device);

  @override
  List<Object> get props => [box, device];
}

class MainNavigateToDeviceDoneEvent extends MainNavigatorEvent {
  final Box box;
  final Device device;
  MainNavigateToDeviceDoneEvent(this.box, this.device);

  @override
  List<Object> get props => [box, device];
}

class MainNavigateToFeedFormEvent extends MainNavigatorEvent {
  final bool pushAsReplacement;

  MainNavigateToFeedFormEvent(this.pushAsReplacement);

  @override
  List<Object> get props => [pushAsReplacement];
}

class MainNavigateToFeedLightFormEvent extends MainNavigateToFeedFormEvent {
  final Box box;

  MainNavigateToFeedLightFormEvent(this.box, {pushAsReplacement = false})
      : super(pushAsReplacement);

  @override
  List<Object> get props => [];
}

class MainNavigateToFeedWaterFormEvent extends MainNavigateToFeedFormEvent {
  final Box box;

  MainNavigateToFeedWaterFormEvent(this.box, {pushAsReplacement = false})
      : super(pushAsReplacement);

  @override
  List<Object> get props => [];
}

class MainNavigateToFeedVentilationFormEvent
    extends MainNavigateToFeedFormEvent {
  final Box box;

  MainNavigateToFeedVentilationFormEvent(this.box, {pushAsReplacement = false})
      : super(pushAsReplacement);

  @override
  List<Object> get props => [];
}

class MainNavigateToFeedMediaFormEvent extends MainNavigateToFeedFormEvent
    with ImageCaptureNextRouteEvent {
  final Box box;
  final String fp;

  MainNavigateToFeedMediaFormEvent(this.box,
      {pushAsReplacement = false, this.fp})
      : super(pushAsReplacement);

  @override
  List<Object> get props => [box, fp];

  @override
  ImageCaptureNextRouteEvent copyWith(String filePath) {
    return MainNavigateToFeedMediaFormEvent(box,
        pushAsReplacement: pushAsReplacement, fp: filePath);
  }

  @override
  String get filePath => fp;
}

class MainNavigateToFeedDefoliationFormEvent
    extends MainNavigateToFeedFormEvent {
  final Box box;

  MainNavigateToFeedDefoliationFormEvent(this.box, {pushAsReplacement = false})
      : super(pushAsReplacement);

  @override
  List<Object> get props => [];
}

class MainNavigateToFeedScheduleFormEvent extends MainNavigateToFeedFormEvent {
  final Box box;

  MainNavigateToFeedScheduleFormEvent(this.box, {pushAsReplacement = false})
      : super(pushAsReplacement);

  @override
  List<Object> get props => [];
}

class MainNavigateToFeedToppingFormEvent extends MainNavigateToFeedFormEvent {
  final Box box;

  MainNavigateToFeedToppingFormEvent(this.box, {pushAsReplacement = false})
      : super(pushAsReplacement);

  @override
  List<Object> get props => [];
}

class MainNavigateToTipEvent extends MainNavigatorEvent {
  final MainNavigateToFeedFormEvent nextRoute;

  MainNavigateToTipEvent(this.nextRoute);

  @override
  List<Object> get props => [];
}

class MainNavigateToImageCaptureEvent extends MainNavigateToFeedFormEvent {
  final ImageCaptureNextRouteEvent nextRoute;

  MainNavigateToImageCaptureEvent({this.nextRoute, pushAsReplacement = false})
      : super(pushAsReplacement);

  @override
  List<Object> get props => [];
}

class MainNavigateToImageCapturePlaybackEvent extends MainNavigatorEvent {
  final String filePath;
  final ImageCaptureNextRouteEvent nextRoute;

  MainNavigateToImageCapturePlaybackEvent(this.filePath, {this.nextRoute, Function(Future<Object> f) futureFn})
      : super(futureFn: futureFn);

  @override
  List<Object> get props => [];
}

abstract class ImageCaptureNextRouteEvent {
  String get filePath;
  ImageCaptureNextRouteEvent copyWith(String filePath);
}

class MainNavigatorActionPop extends MainNavigatorEvent {
  final dynamic param;

  MainNavigatorActionPop({this.param});

  @override
  List<Object> get props => [];
}

class MainNavigatorBloc extends Bloc<MainNavigatorEvent, dynamic> {
  final GlobalKey<NavigatorState> _navigatorKey;
  MainNavigatorBloc(this._navigatorKey);

  @override
  dynamic get initialState => 0;

  @override
  Stream<dynamic> mapEventToState(MainNavigatorEvent event) async* {
    Future future;
    if (event is MainNavigatorActionPop) {
      _navigatorKey.currentState.maybePop(event.param);
    } else if (event is MainNavigateToHomeEvent) {
      future = _navigatorKey.currentState
          .pushReplacementNamed('/home', arguments: event);
    } else if (event is MainNavigateToNewBoxInfosEvent) {
      future =
          _navigatorKey.currentState.pushNamed('/box/new', arguments: event);
    } else if (event is MainNavigateToSelectBoxDeviceEvent) {
      future = _navigatorKey.currentState
          .pushReplacementNamed('/box/device', arguments: event);
    } else if (event is MainNavigateToSelectBoxDeviceBoxEvent) {
      future = _navigatorKey.currentState
          .pushReplacementNamed('/box/device/box', arguments: event);
    } else if (event is MainNavigateToNewDeviceEvent) {
      future =
          _navigatorKey.currentState.pushNamed('/device/new', arguments: event);
    } else if (event is MainNavigateToExistingDeviceEvent) {
      future =
          _navigatorKey.currentState.pushNamed('/device/add', arguments: event);
    } else if (event is MainNavigateToDeviceSetupEvent) {
      future = _navigatorKey.currentState
          .pushReplacementNamed('/device/load', arguments: event);
    } else if (event is MainNavigateToDeviceNameEvent) {
      future = _navigatorKey.currentState
          .pushReplacementNamed('/device/name', arguments: event);
    } else if (event is MainNavigateToDeviceDoneEvent) {
      future = _navigatorKey.currentState
          .pushReplacementNamed('/device/done', arguments: event);
    } else if (event is MainNavigateToFeedDefoliationFormEvent) {
      future = _pushOrReplace('/feed/form/defoliation', event);
    } else if (event is MainNavigateToFeedLightFormEvent) {
      future = _pushOrReplace('/feed/form/light', event);
    } else if (event is MainNavigateToFeedMediaFormEvent) {
      future = _pushOrReplace('/feed/form/media', event);
    } else if (event is MainNavigateToFeedScheduleFormEvent) {
      future = _pushOrReplace('/feed/form/schedule', event);
    } else if (event is MainNavigateToFeedToppingFormEvent) {
      future = _pushOrReplace('/feed/form/topping', event);
    } else if (event is MainNavigateToFeedVentilationFormEvent) {
      future = _pushOrReplace('/feed/form/ventilation', event);
    } else if (event is MainNavigateToFeedWaterFormEvent) {
      future = _pushOrReplace('/feed/form/water', event);
    } else if (event is MainNavigateToTipEvent) {
      future = _navigatorKey.currentState.pushNamed('/tip', arguments: event);
    } else if (event is MainNavigateToImageCaptureEvent) {
      future = _pushOrReplace('/capture', event);
    } else if (event is MainNavigateToImageCapturePlaybackEvent) {
      future = _navigatorKey.currentState.pushNamed('/capture/playback', arguments: event);
    }
    if (event.futureFn != null) {
      event.futureFn(future);
    }
  }

  Future _pushOrReplace(String url, MainNavigateToFeedFormEvent event) {
    if (event.pushAsReplacement) {
      return _navigatorKey.currentState
          .pushReplacementNamed(url, arguments: event);
    }
    return _navigatorKey.currentState.pushNamed(url, arguments: event);
  }
}
