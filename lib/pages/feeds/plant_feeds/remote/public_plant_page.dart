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
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:super_green_app/pages/feeds/feed/bloc/feed_bloc.dart';
import 'package:super_green_app/pages/feeds/feed/bloc/remote/remote_feed_provider.dart';
import 'package:super_green_app/pages/feeds/feed/feed_page.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/plant_infos_bloc.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/plant_infos_page.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/remote/plant_infos_bloc_provider.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/remote/public_plant_bloc.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/remote/remote_plant_feed_provider.dart';

class PublicPlantPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PublicPlantBloc, PublicPlantBlocState>(
        bloc: BlocProvider.of<PublicPlantBloc>(context),
        builder: (BuildContext context, PublicPlantBlocState state) {
          return _renderFeed(context, state);
        },
      ),
    );
  }

  Widget _renderFeed(BuildContext context, PublicPlantBlocState state) {
    List<Widget Function(BuildContext, PublicPlantBlocState)> tabs = [
      _renderPlantInfos,
    ];
    return BlocProvider(
      create: (context) => FeedBloc(RemotePlantFeedBlocProvider(state.plantID)),
      child: FeedPage(
        title: 'Plop',
        color: Colors.indigo,
        appBarHeight: 380,
        appBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 45.0),
            child: Expanded(
              child: Swiper(
                itemCount: tabs.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return tabs[index](context, state);
                },
                pagination: SwiperPagination(
                  builder: new DotSwiperPaginationBuilder(
                      color: Colors.white, activeColor: Color(0xff3bb30b)),
                ),
                loop: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderPlantInfos(BuildContext context, PublicPlantBlocState state) {
    return BlocProvider(
        create: (context) =>
            PlantInfosBloc(RemotePlantInfosBlocProvider(state.plantID)),
        child: PlantInfosPage());
  }
}