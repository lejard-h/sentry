// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A pure Dart client for Sentry.io crash reporting.
library sentry;

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';

import 'src/base.dart';
import 'src/version.dart';

export 'src/version.dart';
export 'src/base.dart';

/// Logs crash reports and events to the Sentry.io service.
class SentryClient extends SentryClientBase {
  String get publicKey => _publicKey;
  String _publicKey;

  /// The Sentry.io secret key for the project.
  String get secretKey => _secretKey;

  String _secretKey;

  String get projectId => _projectId;
  String _projectId;

  SentryClient(
      {@required String dsn,
      Event environmentAttributes,
      bool compressPayload,
      Client httpClient,
      Clock clock,
      UuidGenerator uuidGenerator})
      : super(
            dsn: dsn,
            uuidGenerator: generateUuidV4WithoutDashes,
            environmentAttributes: environmentAttributes,
            httpClient: httpClient ?? new Client(),
            clock: clock ?? const Clock(getUtcDateTime),
            compressPayload: compressPayload ?? true);

  @override
  Uri parseDSN(String dsn) {
    final Uri uri = Uri.parse(dsn);
    final List<String> userInfo = uri.userInfo.split(':');

    _publicKey = userInfo.first;
    _secretKey = userInfo.last;
    _projectId = uri.pathSegments.last;

    assert(() {
      if (userInfo.length != 2)
        throw new ArgumentError(
            'Colon-separated publicKey:secretKey pair not found in the user info field of the DSN URI: $dsn');

      if (uri.pathSegments.isEmpty)
        throw new ArgumentError(
            'Project ID not found in the URI path of the DSN URI: $dsn');

      return true;
    }());
    return uri;
  }

  @override
  Map<String, String> get httpHeaders {
    final DateTime now = clock.now();
    return <String, String>{
      'Content-Type': 'application/json',
      'X-Sentry-Auth': 'Sentry sentry_version=$sentryVersion, '
          'sentry_client=${SentryClientBase.sentryClient}, '
          'sentry_timestamp=${now.millisecondsSinceEpoch}, '
          'sentry_key=$publicKey, '
          'sentry_secret=$secretKey',
    };
  }
}
