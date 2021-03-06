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

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/settings/box_settings.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/settings/plant_settings.dart';

class PlantInfos extends Equatable {
  final String name;
  final String filePath;
  final String thumbnailPath;
  final BoxSettings boxSettings;
  final PlantSettings plantSettings;
  final bool editable;

  PlantInfos(this.name, this.filePath, this.thumbnailPath, this.boxSettings,
      this.plantSettings, this.editable);

  @override
  List<Object> get props =>
      [name, filePath, thumbnailPath, boxSettings, plantSettings, editable];

  PlantInfos copyWith({
    String name,
    String filePath,
    String thumbnailPath,
    BoxSettings boxSettings,
    PlantSettings plantSettings,
    bool editable,
  }) =>
      PlantInfos(
        name ?? this.name,
        filePath ?? this.filePath,
        thumbnailPath ?? this.thumbnailPath,
        boxSettings ?? this.boxSettings,
        plantSettings ?? this.plantSettings,
        editable ?? this.editable,
      );
}

abstract class PlantInfosEvent extends Equatable {}

class PlantInfosEventLoad extends PlantInfosEvent {
  @override
  List<Object> get props => [];
}

class PlantInfosEventLoaded extends PlantInfosEvent {
  final PlantInfos plantInfos;

  PlantInfosEventLoaded(this.plantInfos);

  @override
  List<Object> get props => [plantInfos];
}

class PlantInfosEventUpdate extends PlantInfosEvent {
  final PlantInfos plantInfos;

  PlantInfosEventUpdate(this.plantInfos);

  @override
  List<Object> get props => [plantInfos];
}

class PlantInfosEventUpdatePhase extends PlantInfosEvent {
  final PlantPhases phase;
  final DateTime date;

  PlantInfosEventUpdatePhase(this.phase, this.date);

  @override
  List<Object> get props => [phase, date];
}

abstract class PlantInfosState extends Equatable {}

class PlantInfosStateLoading extends PlantInfosState {
  @override
  List<Object> get props => [];
}

class PlantInfosStateLoaded extends PlantInfosState {
  final PlantInfos plantInfos;

  PlantInfosStateLoaded(this.plantInfos);

  @override
  List<Object> get props => [plantInfos];
}

class PlantInfosBloc extends Bloc<PlantInfosEvent, PlantInfosState> {
  final PlantInfosBlocDelegate provider;

  PlantInfosBloc(this.provider) : super(PlantInfosStateLoading()) {
    this.provider.init(add);
    add(PlantInfosEventLoad());
  }

  @override
  Stream<PlantInfosState> mapEventToState(PlantInfosEvent event) async* {
    if (event is PlantInfosEventLoad) {
      provider.loadPlant();
    } else if (event is PlantInfosEventLoaded) {
      yield PlantInfosStateLoaded(event.plantInfos);
    } else if (event is PlantInfosEventUpdate) {
      yield* provider.updateSettings(event.plantInfos);
    } else if (event is PlantInfosEventUpdatePhase) {
      yield* provider.updatePhase(event.phase, event.date);
    }
  }

  @override
  Future<void> close() async {
    await provider.close();
    return super.close();
  }
}

abstract class PlantInfosBlocDelegate {
  PlantInfos plantInfos;
  Function(PlantInfosEvent) add;

  void init(Function(PlantInfosEvent) add) {
    this.add = add;
  }

  void loadPlant();
  Stream<PlantInfosState> updateSettings(PlantInfos plantInfos);
  Stream<PlantInfosState> updatePhase(PlantPhases phase, DateTime date);
  Future<void> close();

  void plantInfosLoaded(PlantInfos plantInfos) {
    this.plantInfos = plantInfos;
    add(PlantInfosEventLoaded(this.plantInfos));
  }
}
