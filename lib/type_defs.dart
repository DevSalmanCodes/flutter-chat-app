import 'package:chat_app/repositories/failure.dart';
import 'package:fpdart/fpdart.dart';

typedef FutureEither<T> =Future<Either<Failure,T>>;
typedef FutureEitherVoid=FutureEither<void>;
typedef FutureVoid=Future<void>;