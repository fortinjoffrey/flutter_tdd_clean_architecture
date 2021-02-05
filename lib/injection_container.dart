import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app/data/repositories/number_trivia_repository_impl.dart';
import 'app/data/sources/local/contracts/number_trivia_local_source.dart';
import 'app/data/sources/local/shared_preferences_number_trivia_local_source.dart';
import 'app/data/sources/remote/contracts/number_trivia_remote_source.dart';
import 'app/data/sources/remote/number_trivia_remote_source_impl.dart';
import 'app/domain/contracts/number_trivia/number_trivia_repository.dart';
import 'app/domain/usecases/number_trivia/get_concrete_number_trivia.dart';
import 'app/domain/usecases/number_trivia/get_random_number_trivia.dart';
import 'app/presentation/bloc/number_trivia_bloc.dart';
import 'app/presentation/state/number_trivia_store.dart';
import 'core/network/network_info.dart';
import 'core/utils/input_converter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Number Trivia

  // Bloc
  sl.registerFactory<NumberTriviaBloc>(
    () => NumberTriviaBloc(
        getConcreteNumberTrivia: sl<GetConcreteNumberTrivia>(),
        getRandomNumberTrivia: sl<GetRandomNumberTrivia>(),
        inputConverter: sl<InputConverter>()),
  );

  // ---------------------------------------------------------------------------
  // Stores (MobX)
  // ---------------------------------------------------------------------------

  // Number trivia store
  sl.registerLazySingleton<NumberTriviaStore>(
    () => NumberTriviaStore(
      sl<GetConcreteNumberTrivia>(),
      sl<GetRandomNumberTrivia>(),
      sl<InputConverter>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Use cases
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<GetConcreteNumberTrivia>(
    () => GetConcreteNumberTrivia(
        numberTriviaRepository: sl<NumberTriviaRepository>()),
  );
  sl.registerLazySingleton<GetRandomNumberTrivia>(
    () => GetRandomNumberTrivia(
        numberTriviaRepository: sl<NumberTriviaRepository>()),
  );

  // Repositories
  sl.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteSource: sl<NumberTriviaRemoteSource>(),
      localSource: sl<NumberTriviaLocalSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<NumberTriviaRemoteSource>(
    () => NumberTriviaRemoteSourceImpl(client: sl<http.Client>()),
  );

  sl.registerLazySingleton<NumberTriviaLocalSource>(
    () => SharedPreferencesNumberTriviaLocalSource(
        sharedPreferences: sl<SharedPreferences>()),
  );

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<DataConnectionChecker>()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<http.Client>(() => http.Client());

  sl.registerLazySingleton<DataConnectionChecker>(
    () => DataConnectionChecker(),
  );
}
