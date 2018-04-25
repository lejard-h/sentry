// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A pure Dart client for Sentry.io crash reporting.
library sentry;

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';

import 'src/base.dart';

export 'src/base.dart';
export 'src/version.dart';

/// Logs crash reports and events to the Sentry.io service.
class SentryClientIO extends SentryClient {
  factory SentryClientIO(
          {@required String dsn,
          Event environmentAttributes,
          Client httpClient,
          Clock clock,
          UuidGenerator uuidGenerator,
          bool compressPayload}) =>
      new SentryClient(
          dsn: dsn,
          httpClient: httpClient,
          clock: clock,
          uuidGenerator: uuidGenerator,
          environmentAttributes: environmentAttributes,
          compressPayload: compressPayload);
}
