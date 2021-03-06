// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_nfc/src/bloc.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/nfc/fake_nfc.dart';
import 'package:treasure_nfc/src/resources/memory_structures.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

import 'test_structures.dart';

void main() {
  test('emit scanning state', () async {
    final bloc = Bloc(Repo(TestTreasureSource(), InMemoryRecorder(), TestCompletion()), FakeNfc());

    bloc.scanStatus.listen((scanStatus) {
      expect(scanStatus, ScanStatus('id', 'message', true, false));
    });

    bloc.changeNfcData(NfcData.fromMap({"nfcId":"id", "nfcContent": "message", "nfcStatus": "reading"}));
  });

  test('emit not scanning state', () async {
    final bloc = Bloc(Repo(TestTreasureSource(), InMemoryRecorder(), TestCompletion()), FakeNfc());

    bloc.scanStatus.listen((scanStatus) {
      expect(scanStatus, ScanStatus('', 'Error', false, true));
    });

    bloc.changeNfcData(NfcData.fromMap({"nfcId":"id", "nfcContent": "message", "nfcStatus": "error"}));
  });

  test('prompt for name', () async {
    final bloc = Bloc(Repo(TestTreasureSource(), InMemoryRecorder(), TestCompletion()), FakeNfc());

    await bloc.recordFound('red');
    await bloc.recordFound('green');
    await bloc.recordFound('blue');

    bloc.showCompletePrompt.listen((show) {
      expect(show, true);
    });
  });

  test('not prompt for name', () async {
    final bloc = Bloc(Repo(TestTreasureSource(), InMemoryRecorder(), TestCompletion()), FakeNfc());

    await bloc.markNameSubmitted();
    await bloc.recordFound('red');
    await bloc.recordFound('green');
    await bloc.recordFound('blue');

    bloc.showCompletePrompt.listen((show) {
      expect(show, false);
    });
  });
}
