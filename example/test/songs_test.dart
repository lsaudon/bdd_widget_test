// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_following_songs.dart';

void main() {
  group('''Songs''', () {
    testWidgets('''Available songs''', (tester) async {
      await theFollowingSongs(
          tester,
          'Good',
          const bdd.DataTable([
            ['artist', 'title'],
            ['The Beatles', 'Let It Be'],
            ['Camel', 'Slow yourself down']
          ]));
    });
  });
}
