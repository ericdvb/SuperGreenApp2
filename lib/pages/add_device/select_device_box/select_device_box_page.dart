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
import 'package:flutter_svg/svg.dart';
import 'package:super_green_app/main/main_navigator_bloc.dart';
import 'package:super_green_app/pages/add_device/select_device_box/select_device_box_bloc.dart';
import 'package:super_green_app/widgets/appbar.dart';
import 'package:super_green_app/widgets/fullscreen.dart';
import 'package:super_green_app/widgets/fullscreen_loading.dart';
import 'package:super_green_app/widgets/section_title.dart';

class SelectDeviceBoxPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SelectDeviceBoxPageState();
}

class SelectDeviceBoxPageState extends State<SelectDeviceBoxPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectDeviceBoxBloc, SelectDeviceBoxBlocState>(
      cubit: BlocProvider.of<SelectDeviceBoxBloc>(context),
      listener: (context, state) {
        if (state is SelectDeviceBoxBlocStateDone) {
          BlocProvider.of<MainNavigatorBloc>(context)
              .add(MainNavigatorActionPop(param: state.box));
        }
      },
      child: BlocBuilder<SelectDeviceBoxBloc, SelectDeviceBoxBlocState>(
          cubit: BlocProvider.of<SelectDeviceBoxBloc>(context),
          builder: (context, state) {
            Widget body;
            if (state is SelectDeviceBoxBlocStateInit) {
              body = FullscreenLoading(title: 'Loading..');
            } else if (state is SelectDeviceBoxBlocStateLoading) {
              body = FullscreenLoading(title: 'Setting up..');
            } else if (state is SelectDeviceBoxBlocStateDone) {
              body = Fullscreen(
                  title: 'Done!',
                  child: Icon(Icons.done, color: Color(0xff3bb30b), size: 100));
            } else {
              body = _renderBoxSelection(context, state);
            }
            return Scaffold(
                appBar: SGLAppBar(
                  '🤖🔌',
                  fontSize: 40,
                  backgroundColor: Color(0xff0b6ab3),
                  titleColor: Colors.white,
                  iconColor: Colors.white,
                ),
                body: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200), child: body));
          }),
    );
  }

  Widget _renderBoxSelection(
      BuildContext context, SelectDeviceBoxBlocStateLoaded state) {
    return Column(
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 100),
          height: 20,
          color: Color(0xff0b6ab3),
        ),
        SectionTitle(
          title: 'Select controller\'s box slot',
          icon: 'assets/box_setup/icon_controller.svg',
          backgroundColor: Color(0xff0b6ab3),
          titleColor: Colors.white,
          elevation: 5,
          large: true,
        ),
        _renderBoxes(state),
      ],
    );
  }

  Widget _renderBoxes(SelectDeviceBoxBlocStateLoaded state) {
    int selectedLeds =
        state.boxes.map<int>((b) => b.leds.length).reduce((acc, b) => acc + b);
    bool hasAvailableLeds = selectedLeds < state.nLeds;
    return Expanded(
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (index == state.boxes.length) {
              return null;
            }
            Widget title;
            if (state.boxes[index].enabled) {
              title = Text('Already running',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w300));
            } else {
              title = Text(
                  hasAvailableLeds ? 'Available' : 'No more free led channels',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w300));
            }
            return ListTile(
              onTap: () {
                if (state.boxes[index].enabled == false) {
                  BlocProvider.of<MainNavigatorBloc>(context).add(
                      MainNavigateToSelectNewDeviceBoxEvent(state.device, index,
                          futureFn: (future) async {
                    dynamic done = await future;
                    if (done == true) {
                      BlocProvider.of<SelectDeviceBoxBloc>(context)
                          .add(SelectDeviceBoxBlocEventSelectBox(index));
                    }
                  }));
                } else {
                  BlocProvider.of<SelectDeviceBoxBloc>(context).add(
                      SelectDeviceBoxBlocEventSelectBox(
                          state.boxes[index].box));
                }
              },
              onLongPress: () {
                _deleteBox(state, index);
              },
              title: title,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset('assets/box_setup/icon_box.svg'),
                  Text('Box #${state.boxes[index].box + 1}',
                      style: TextStyle(fontWeight: FontWeight.w300)),
                ],
              ),
              subtitle: Text(state.boxes[index].leds.length > 0
                  ? 'Led channels: ${state.boxes[index].leds.map((l) => l + 1).join(', ')}'
                  : 'No led channels assigned'),
            );
          },
        ),
      ),
    );
  }

  void _deleteBox(SelectDeviceBoxBlocStateLoaded state, int index) async {
    bool confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text('Reset box #${index+1} on controller ${state.device.name}?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('NO'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('YES'),
              ),
            ],
          );
        });
    if (confirm) {
      BlocProvider.of<SelectDeviceBoxBloc>(context)
          .add(SelectDeviceBoxBlocEventDelete(index));
    }
  }
}
