import 'package:dart_frog/dart_frog.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

Handler middleware(Handler handler) {
  return (context) {
    final uuid = const Uuid().v4();
    final newHanler = handler.use(
      requestLogger(
        logger: (message, isError) {
          final logger = context.read<Logger>();
          if (isError) {
            logger.e(message);
          } else {
            logger.i('$uuid: $message');
          }
        },
      ),
    ).use(provider<String>((context) => uuid));

    return newHanler(context);
  };
}
