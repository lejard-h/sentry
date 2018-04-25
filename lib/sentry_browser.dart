// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A pure Dart client for Sentry.io crash reporting.
library sentry_browser;

import 'dart:html' hide Event, Client;

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';

import 'src/base.dart';
import 'src/version.dart';

export 'src/version.dart';
export 'src/base.dart';

/// Logs crash reports and events to the Sentry.io service.
class SentryBrowserClient extends SentryClientBase {
  String get publicKey => _publicKey;
  String _publicKey;

  String get secretKey => null;

  String get projectId => _projectId;
  String _projectId;

  SentryBrowserClient(
      {@required String dsn,
      Event environmentAttributes,
      Client httpClient,
      Clock clock,
      UuidGenerator uuidGenerator})
      : super(
            dsn: dsn,
            uuidGenerator: generateUuidV4WithoutDashes,
            environmentAttributes: environmentAttributes,
            httpClient: httpClient ?? new Client(),
            clock: clock ?? const Clock(getUtcDateTime),
            compressPayload: false,
            platform: jsPlatform);

  @override
  Uri parseDSN(String dsn) {
    final Uri uri = Uri.parse(dsn);
    final List<String> userInfo = uri.userInfo.split(':');

    _publicKey = userInfo.first;
    _projectId = uri.pathSegments.last;

    assert(() {
      if (userInfo.length > 1)
        throw new ArgumentError(
            'Do not specify your secret key in the DSN: $dsn');

      if (uri.pathSegments.isEmpty)
        throw new ArgumentError(
            'Project ID not found in the URI path of the DSN URI: $dsn');

      return true;
    }());
    return uri;
  }

  @override
  Map<String, String> get httpHeaders =>
      {'User-Agent': window.navigator.userAgent};
}
