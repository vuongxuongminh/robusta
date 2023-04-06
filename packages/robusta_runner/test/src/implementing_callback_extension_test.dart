import 'package:logger/logger.dart';
import 'package:robusta_runner/robusta_runner.dart';
import 'package:test/test.dart';

import 'stub.dart';

void main() {
  group('implementing callback extension', () {
    test('can initialize', () async {
      expect(ImplementingCallbackExtension.new, returnsNormally);
    });

    test('can trigger callbacks added', () async {
      var counter = 0;
      var num = 0;

      final runner = Runner(
        extensions: [
          ImplementingCallbackExtension(
            definition: (define) {
              define<Test>((_, __) => counter++);
            },
          ),
          TestDependenceExtension(),
        ],
        boots: {
          (c) => num = c.read(testProvider).num: 0,
        },
      );

      await runner.run();

      expect(counter, equals(1));
      expect(num, equals(1));
    });

    test('can opt in/out default callbacks', () async {
      Test? test;

      final optOutRunner = Runner(
        extensions: [
          ImplementingCallbackExtension(
            enabledEventManagerAwareCallback: false,
            enabledLoggerAwareCallback: false,
          ),
          TestDependenceExtension(),
        ],
        boots: {
          (c) {
            test = c.read(testProvider);
          }: 0,
        },
      );

      await expectLater(optOutRunner.run(), completes);

      expect(test, isNotNull);
      expect(test!.em, isNull);
      expect(test!.logger, isNull);

      test = null;

      final optInRunner = Runner(
        extensions: [
          ImplementingCallbackExtension(),
          TestDependenceExtension(),
        ],
        boots: {
          (c) {
            test = c.read(testProvider);
          }: 0,
        },
      );

      await expectLater(optInRunner.run(), completes);

      expect(test, isNotNull);
      expect(test!.em, isA<EventManager>());
      expect(test!.logger, isA<Logger>());
    });
  });
}
