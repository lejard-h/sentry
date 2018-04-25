// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A pure Dart client for Sentry.io crash reporting.
library sentry_browser;

import 'dart:async';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';

import 'src/version.dart';
import 'src/base.dart';

export 'src/version.dart';

/// Logs crash reports and events to the Sentry.io service.
class SentryClientBrowser extends SentryClient {
  factory SentryClientBrowser({
    @required String dsn,
    Event environmentAttributes,
    Client httpClient,
    Clock clock,
    UuidGenerator uuidGenerator,
  }) =>
      new SentryClient(
          dsn: dsn,
          httpClient: httpClient,
          clock: clock,
          uuidGenerator: uuidGenerator,
          environmentAttributes: environmentAttributes);

  @override
  Map<String, String> get sentryHeaders {
    final headers = super.sentryHeaders;
    headers.remove('User-Agent');
    return headers;
  }

  /// Reports the [exception] and optionally its [stackTrace] to Sentry.io.
  @override
  Future<SentryResponse> captureException({
    @required dynamic exception,
    dynamic stackTrace,
  }) {
    final Event event = new Event(
        exception: exception, stackTrace: stackTrace, platform: jsPlatform);
    return capture(event: event);
  }
}
