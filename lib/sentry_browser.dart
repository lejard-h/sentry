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

  String get secretKey => _secretKey;
  String _secretKey;

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
            platform: jsPlatform,
            origin: '${window.location.origin}/');

  @override
  Uri parseDSN(String dsn) {
    final Uri uri = Uri.parse(dsn);
    final List<String> userInfo = uri.userInfo.split(':');

    _publicKey = userInfo.first;
    if (userInfo.length == 2) {
      _secretKey = userInfo.last;
    }

    _projectId = uri.pathSegments.last;

    assert(() {
      if (uri.pathSegments.isEmpty)
        throw new ArgumentError(
            'Project ID not found in the URI path of the DSN URI: $dsn');

      return true;
    }());
    return uri;
  }

  @override
  Map<String, String> get httpHeaders => {};

  @override
  String get postUri {
    final url = super.postUri;

    final auth = {
      'sentry_version': sentryVersion,
      'sentry_client': SentryClientBase.sentryClient,
      'sentry_key': publicKey
    };

    if (secretKey != null) {
      auth['sentry_secret'] = secretKey;
    }

    // Auth is intentionally sent as part of query string (NOT as custom HTTP header) to avoid preflight CORS requests (from Raven-js src)
    return '$url?${_urlencode(auth)}';
  }

  String _urlencode(Map<String, String> params) {
    var pairs = [];
    params.forEach((key, value) {
      pairs.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}');
    });
    return pairs.join('&');
  }
}
