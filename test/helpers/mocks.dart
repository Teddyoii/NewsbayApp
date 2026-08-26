import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_posts_app/core/network/api_client.dart';
import 'package:flutter_posts_app/data/datasources/auth_local_data_source.dart';
import 'package:flutter_posts_app/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_posts_app/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_posts_app/domain/repositories/auth_repository.dart';
import 'package:flutter_posts_app/domain/repositories/posts_repository.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockPostsRemoteDataSource extends Mock implements PostsRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockPostsRepository extends Mock implements PostsRepository {}

class MockApiClient extends Mock implements ApiClient {}

class MockBox extends Mock implements Box {}
