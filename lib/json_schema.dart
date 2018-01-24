// Copyright 2013-2018 Workiva Inc.
//
// Licensed under the Boost Software License (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.boost.org/LICENSE_1_0.txt
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This software or document includes material copied from or derived
// from JSON-Schema-Test-Suite (https://github.com/json-schema-org/JSON-Schema-Test-Suite),
// Copyright (c) 2012 Julian Berman, which is licensed under the following terms:
//
//     Copyright (c) 2012 Julian Berman
//
//     Permission is hereby granted, free of charge, to any person obtaining a copy
//     of this software and associated documentation files (the "Software"), to deal
//     in the Software without restriction, including without limitation the rights
//     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//     copies of the Software, and to permit persons to whom the Software is
//     furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//     THE SOFTWARE.

/// Support for validating json instances against a json schema
library json_schema.json_schema;

import 'package:logging/logging.dart';
import 'package:w_transport/w_transport.dart';

export 'src/json_schema/schema_type.dart' show SchemaType;

export 'src/json_schema/validator.dart' show JsonSchemaValidator;
export 'src/json_schema/abstract_json_schema.dart' show AbstractJsonSchema;

final Logger _logger = new Logger('json_schema');

/// Used to provide your own uri validator (if default does not suit needs)
set uriValidator(bool validator(String s)) => _uriValidator = validator;

/// Used to provide your own email validator (if default does not suit needs)
set emailValidator(bool validator(String s)) => _emailValidator = validator;

bool logFormatExceptions = false;


/// create a class like this for json schema
abstract class JsonSchema extends AbstractJsonSchema {
  factory JsonSchema({TransportPlatform transportPlatform}) {
    // If a transport platform is not explicitly given, fallback to the globally
    // configured platform.
    transportPlatform ??= globalTransportPlatform;

    if (MockTransportsInternal.isInstalled) {
      // If transports are mocked, return a mock HttpClient instance. This
      // mock instance will construct mock-aware BaseRequest and WebSocket
      // instances that will be able to decide at the time of dispatch
      // whether or not the mock logic should be used.
      return MockAwareTransportPlatform.newHttpClient(transportPlatform);
    } else if (transportPlatform != null) {
      // Otherwise, return a real instance using the given transport platform.
      return transportPlatform.newHttpClient();
    } else {
      // If transports are not mocked and a transport platform is not available
      // (neither explicitly given nor configured globally), then we cannot
      // successfully construct an HttpClient.
      throw new TransportPlatformMissing.httpClientFailed();
    }
  }
}