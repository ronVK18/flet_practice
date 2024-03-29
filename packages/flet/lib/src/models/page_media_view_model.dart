import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:redux/redux.dart';

import '../protocol/page_media_data.dart';
import 'app_state.dart';

class PageMediaViewModel extends Equatable {
  final bool isRegistered;
  final Size size;
  final Brightness displayBrightness;
  final PageMediaData media;
  final Function dispatch;

  const PageMediaViewModel(
      {required this.isRegistered,
      required this.size,
      required this.displayBrightness,
      required this.media,
      required this.dispatch});

  static PageMediaViewModel fromStore(Store<AppState> store) {
    return PageMediaViewModel(
        isRegistered: store.state.isRegistered,
        size: store.state.size,
        displayBrightness: store.state.displayBrightness,
        media: store.state.media,
        dispatch: store.dispatch);
  }

  @override
  List<Object?> get props => [size, displayBrightness, dispatch, isRegistered];
}
