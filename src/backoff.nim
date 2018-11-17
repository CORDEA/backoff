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

# Author: Yoshihiro Tanaka <contact@cordea.jp>
# date  : 2018-11-17

import os
import math
import asyncdispatch

type
  Backoff* = ref object
    currentRetries: int
    maxRetries: int
    maxWaitMilsecs: int

  ExceedsMaxRetriesError = object of Exception

proc newBackoff*(maxRetries: int = 0, maxWaitMilsecs: int = 0): Backoff =
  return Backoff(
    currentRetries: 1,
    maxRetries: maxRetries,
    maxWaitMilsecs: maxWaitMilsecs
  )

proc exceedsMaxRetries*(backoff: Backoff): bool =
  result = backoff.currentRetries > backoff.maxRetries

proc waitMilsecs*(backoff: Backoff): int =
  result = (backoff.currentRetries ^ 2) * 1000
  if backoff.maxWaitMilsecs > 0:
    result = min(result, backoff.maxWaitMilsecs)

proc wait*(backoff: Backoff) =
  if backoff.exceedsMaxRetries:
    raise newException(ExceedsMaxRetriesError, "")
  let milsecs = backoff.waitMilsecs
  if milsecs > 0:
    sleep(milsecs)
  backoff.currentRetries += 1

proc waitAsync*(backoff: Backoff) {.async.} =
  if backoff.exceedsMaxRetries:
    raise newException(ExceedsMaxRetriesError, "")
  let milsecs = backoff.waitMilsecs
  if milsecs > 0:
    await sleepAsync(milsecs)
  backoff.currentRetries += 1
