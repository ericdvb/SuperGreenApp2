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

import 'dart:convert';

import 'package:moor/moor.dart';
import 'package:super_green_app/data/rel/rel_db.dart';
import 'package:super_green_app/towelie/towelie_bloc.dart';

abstract class TowelieButton {
  Stream<TowelieBlocState> buttonPressed(TowelieBlocEventCardButtonPressed event);

  Future removeButtons(FeedEntry feedEntry) async {
    final fdb = RelDB.get().feedsDAO;
    final Map<String, dynamic> params = JsonDecoder().convert(feedEntry.params);
    params['buttons'] = [];
    await fdb.updateFeedEntry(feedEntry
        .createCompanion(true)
        .copyWith(params: Value(JsonEncoder().convert(params))));
  }
}
