/*
 * Copyright (C) 2018  SuperGreenLab <towelie@supergreenlab.com>
 * Author: Constantin Clauzel <constantin.clauzel@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:super_green_app/device_daemon/device_daemon_bloc.dart';
import 'package:super_green_app/l10n.dart';
import 'package:super_green_app/main/main_navigator_bloc.dart';
import 'package:super_green_app/pages/feed_entries/feed_schedule/form/feed_schedule_form_bloc.dart';
import 'package:super_green_app/widgets/feed_form/feed_form_layout.dart';
import 'package:super_green_app/widgets/feed_form/feed_form_param_layout.dart';
import 'package:super_green_app/widgets/fullscreen.dart';
import 'package:super_green_app/widgets/fullscreen_loading.dart';
import 'package:super_green_app/widgets/green_button.dart';

class FeedScheduleFormPage extends StatefulWidget {
  @override
  _FeedScheduleFormPageState createState() => _FeedScheduleFormPageState();
}

class _FeedScheduleFormPageState extends State<FeedScheduleFormPage> {
  TextEditingController onHourEditingController;
  TextEditingController onMinEditingController;
  TextEditingController offHourEditingController;
  TextEditingController offMinEditingController;
  String scheduleChange;
  bool editedSchedule = false;
  bool _reachable = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<FeedScheduleFormBloc>(context),
      listener: (BuildContext context, FeedScheduleFormBlocState state) {
        if (state is FeedScheduleFormBlocStateDone) {
          BlocProvider.of<MainNavigatorBloc>(context)
              .add(MainNavigatorActionPop(mustPop: true));
        }
      },
      child: BlocBuilder<FeedScheduleFormBloc, FeedScheduleFormBlocState>(
          bloc: BlocProvider.of<FeedScheduleFormBloc>(context),
          builder: (BuildContext context, FeedScheduleFormBlocState state) {
            Widget body;
            bool changed = false;
            bool valid = false;
            if (state is FeedScheduleFormBlocStateLoading) {
              body = FullscreenLoading(
                title: 'Saving..',
              );
            } else if (state is FeedScheduleFormBlocStateUnInitialized) {
              body = FullscreenLoading(
                title: 'Loading..',
              );
            } else if (state is FeedScheduleFormBlocStateLoaded) {
              changed = valid =
                  state.schedule != state.initialSchedule || editedSchedule;
              Widget content = _renderSchedules(context, state);
              if (scheduleChange != null) {
                content = Stack(
                  children: <Widget>[
                    content,
                    _renderScheduleChange(context, state),
                  ],
                );
              }
              if (state.box.device == null) {
                body = content;
              } else {
                if (_reachable == false) {
                  content = Stack(
                    children: <Widget>[
                      content,
                      Fullscreen(
                          title: 'Device unreachable!',
                          backgroundColor: Colors.white54,
                          child:
                              Icon(Icons.error, color: Colors.red, size: 100)),
                    ],
                  );
                }
                body = BlocListener<DeviceDaemonBloc, DeviceDaemonBlocState>(
                    listener: (BuildContext context,
                        DeviceDaemonBlocState daemonState) {
                      if (daemonState is DeviceDaemonBlocStateDeviceReachable &&
                          daemonState.device.id == state.box.device) {
                        setState(() {
                          _reachable = daemonState.reachable;
                        });
                      }
                    },
                    child: content);
              }
            }
            return FeedFormLayout(
                title: 'Add schedule',
                changed: changed,
                valid: valid,
                onOK: () => BlocProvider.of<FeedScheduleFormBloc>(context)
                    .add(FeedScheduleFormBlocEventCreate()),
                body: AnimatedSwitcher(
                  child: body,
                  duration: Duration(milliseconds: 200),
                ));
          }),
    );
  }

  Widget _renderSchedules(
      BuildContext context, FeedScheduleFormBlocStateLoaded state) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(children: [
            this._renderSchedule(
                context,
                state.schedules['VEG'],
                'Vegetative schedule',
                'assets/feed_form/icon_veg.svg',
                SGLLocalizations.of(context).instructionsVegScheduleHelper,
                state.schedule == 'VEG', () {
              BlocProvider.of<FeedScheduleFormBloc>(context)
                  .add(FeedScheduleFormBlocEventSetSchedule('VEG'));
            }, () {
              setState(() {
                scheduleChange = 'VEG';
                _setupEditingControllers(state);
              });
            }),
            this._renderSchedule(
                context,
                state.schedules['BLOOM'],
                'Blooming schedule',
                'assets/feed_form/icon_bloom.svg',
                SGLLocalizations.of(context).instructionsBloomScheduleHelper,
                state.schedule == 'BLOOM', () {
              BlocProvider.of<FeedScheduleFormBloc>(context)
                  .add(FeedScheduleFormBlocEventSetSchedule('BLOOM'));
            }, () {
              setState(() {
                scheduleChange = 'BLOOM';
                _setupEditingControllers(state);
              });
            }),
            this._renderSchedule(
                context,
                state.schedules['AUTO'],
                'Auto flower schedule',
                'assets/feed_form/icon_autoflower.svg',
                SGLLocalizations.of(context).instructionsAutoScheduleHelper,
                state.schedule == 'AUTO', () {
              BlocProvider.of<FeedScheduleFormBloc>(context)
                  .add(FeedScheduleFormBlocEventSetSchedule('AUTO'));
            }, () {
              setState(() {
                scheduleChange = 'AUTO';
                _setupEditingControllers(state);
              });
            }),
          ]),
        ),
      ],
    );
  }

  Widget _renderSchedule(
      BuildContext context,
      Map<String, dynamic> schedule,
      String title,
      String icon,
      String helper,
      bool selected,
      Function onPressed,
      Function onEdit) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: FeedFormParamLayout(
        title: title,
        icon: icon,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MarkdownBody(
                data: helper,
                styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: Colors.black, fontSize: 16)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: <Widget>[
                      ButtonTheme(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4.0),
                          minWidth: 0,
                          height: 0,
                          child: RaisedButton(
                            elevation: 0,
                            color: Colors.transparent,
                            child: Icon(Icons.settings),
                            onPressed: onEdit,
                          )),
                      _renderScheduleTimes(context, schedule),
                    ],
                  ),
                  GreenButton(
                    title: selected ? 'SELECTED' : 'SELECT',
                    onPressed: onPressed,
                    color: selected ? 0xff3bb30b : 0xff777777,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderScheduleTimes(
      BuildContext context, Map<String, dynamic> schedule) {
    final pad = (s) => s.toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('ON: '),
            Text('${pad(schedule['ON_HOUR'])}:${pad(schedule['ON_MIN'])}',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: <Widget>[
            Text('OFF: '),
            Text('${pad(schedule['OFF_HOUR'])}:${pad(schedule['OFF_MIN'])}',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _renderScheduleChange(
      BuildContext context, FeedScheduleFormBlocStateLoaded state) {
    return Container(
      color: Colors.white54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey)),
              child: Form(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text('Edit $scheduleChange schedules',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          width: 80,
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'ON hour'),
                            controller: onHourEditingController,
                          ),
                        ),
                        Text(':'),
                        Container(
                          width: 80,
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'ON min'),
                            controller: onMinEditingController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          width: 80,
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'OFF hour'),
                            controller: offHourEditingController,
                          ),
                        ),
                        Text(':'),
                        Container(
                          width: 80,
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'OFF min'),
                            controller: offMinEditingController,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: GreenButton(
                        title: 'SET',
                        onPressed: () {
                          BlocProvider.of<FeedScheduleFormBloc>(context).add(
                              FeedScheduleFormBlocEventUpdatePreset(
                                  scheduleChange, {
                            "ON_HOUR":
                                int.parse(onHourEditingController.value.text),
                            "ON_MIN":
                                int.parse(onMinEditingController.value.text),
                            "OFF_HOUR":
                                int.parse(offHourEditingController.value.text),
                            "OFF_MIN":
                                int.parse(offMinEditingController.value.text),
                          }));
                          setState(() {
                            scheduleChange = null;
                            editedSchedule = true;
                          });
                        },
                      ),
                    )
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setupEditingControllers(FeedScheduleFormBlocStateLoaded state) {
    onHourEditingController = TextEditingController(
        text: state.schedules[scheduleChange]['ON_HOUR'].toString());
    onMinEditingController = TextEditingController(
        text: state.schedules[scheduleChange]['ON_MIN'].toString());
    offHourEditingController = TextEditingController(
        text: state.schedules[scheduleChange]['OFF_HOUR'].toString());
    offMinEditingController = TextEditingController(
        text: state.schedules[scheduleChange]['OFF_MIN'].toString());
  }
}
