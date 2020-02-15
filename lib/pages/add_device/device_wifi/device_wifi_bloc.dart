import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_green_app/data/api/device_api.dart';
import 'package:super_green_app/data/device_helper.dart';
import 'package:super_green_app/data/rel/rel_db.dart';
import 'package:super_green_app/main/main_navigator_bloc.dart';

class DeviceWifiBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class DeviceWifiBlocEventSetup extends DeviceWifiBlocEvent {
  final String ssid;
  final String pass;

  DeviceWifiBlocEventSetup(this.ssid, this.pass);

  @override
  List<Object> get props => [ssid, pass];
}

class DeviceWifiBlocState extends Equatable {
  @override
  List<Object> get props => [];
}

class DeviceWifiBlocStateLoading extends DeviceWifiBlocState {
  @override
  List<Object> get props => [];
}

class DeviceWifiBlocStateSearching extends DeviceWifiBlocState {
  @override
  List<Object> get props => [];
}

class DeviceWifiBlocStateNotFound extends DeviceWifiBlocState {
  @override
  List<Object> get props => [];
}

class DeviceWifiBlocStateDone extends DeviceWifiBlocState {
  @override
  List<Object> get props => [];
}

class DeviceWifiBloc extends Bloc<DeviceWifiBlocEvent, DeviceWifiBlocState> {
  final MainNavigateToDeviceWifiEvent _args;

  DeviceWifiBloc(this._args);

  @override
  DeviceWifiBlocState get initialState => DeviceWifiBlocState();

  @override
  Stream<DeviceWifiBlocState> mapEventToState(
      DeviceWifiBlocEvent event) async* {
    if (event is DeviceWifiBlocEventSetup) {
      yield DeviceWifiBlocStateLoading();
      var ddb = RelDB.get().devicesDAO;
      Param ssid = await ddb.getParam(_args.device.id, 'WIFI_SSID');
      await DeviceHelper.updateStringParam(_args.device, ssid, event.ssid);
      Param pass = await ddb.getParam(_args.device.id, 'WIFI_PASSWORD');
      try {
        await DeviceHelper.updateStringParam(_args.device, pass, event.pass);
      } catch (e) {
        print(e);
      }

      yield DeviceWifiBlocStateSearching();

      String ip;
      for (int i = 0; i < 4; ++i) {
        await new Future.delayed(const Duration(seconds: 2));
        Param mdns = await ddb.getParam(_args.device.id, 'MDNS_DOMAIN');
        ip = await DeviceAPI.resolveLocalName(mdns.svalue);
        if (ip == "" || ip == null) {
          continue;
        }
        break;
      }
      if (ip == "" || ip == null) {
        yield DeviceWifiBlocStateNotFound();
        return;
      }

      Device device = _args.device.copyWith(ip: ip);
      await RelDB.get().devicesDAO.updateDevice(device);

      Param ipParam = await ddb.getParam(device.id, 'WIFI_IP');
      await ddb.updateParam(ipParam.copyWith(svalue: ip));

      Param wifiStatusParam =
          await ddb.getParam(_args.device.id, 'WIFI_STATUS');
      await DeviceHelper.refreshIntParam(device, wifiStatusParam);

      yield DeviceWifiBlocStateDone();
    }
  }
}
