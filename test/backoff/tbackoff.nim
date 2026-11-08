# Copyright 2018 Yoshihiro Tanaka
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

  # http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Uyuz-ux
# date  : 2026-11-03

import unittest
import asyncdispatch
import ../../src/backoff
import ../../src/backoff/jittertype

suite "Backoff test":
  test "counts retries and raises after exceeding max":
    let b = newBackoff(TypeNo, 2, 1)
    check(not b.exceedsMaxRetries)
    b.wait()
    check(not b.exceedsMaxRetries)
    b.wait()
    check(b.exceedsMaxRetries)
    expect ExceedsMaxRetriesError:
      b.wait()

  test "unlimited retries never exceeds":
    let b = newBackoff(TypeNo, 0, 1)
    for i in 1 .. 5:
      b.wait()
    check(not b.exceedsMaxRetries)

  test "waitAsync counts retries like wait":
    let b = newBackoff(TypeNo, 1, 1)
    waitFor(b.waitAsync())
    check(b.exceedsMaxRetries)
    expect ExceedsMaxRetriesError:
      waitFor(b.waitAsync())
