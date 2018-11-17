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

const InitialWaitMilsecs = 1 * 1000

type
  Backoff* = ref object
    currentRetries: int
    waitMilsecs: int
    maxRetries: int
    maxWaitMilsecs: int
    fake: bool

  ExceedsMaxRetriesError = object of Exception

proc newBackoff(maxRetries: int, maxWaitMilsecs: int, fake: bool): Backoff =
  result = Backoff(
    currentRetries: 1,
    waitMilsecs: InitialWaitMilsecs,
    maxRetries: maxRetries,
    maxWaitMilsecs: maxWaitMilsecs,
    fake: fake
  )

proc newBackoff*(maxRetries: int = 0, maxWaitMilsecs: int = 0): Backoff =
  result = newBackoff(maxRetries, maxWaitMilsecs, false)

proc exceedsMaxRetries*(backoff: Backoff): bool =
  if backoff.maxRetries < 1:
    return false
  result = backoff.currentRetries > backoff.maxRetries

proc updateWaitMilsecs(backoff: Backoff) =
  var milsecs = backoff.waitMilsecs * 2
  if backoff.maxWaitMilsecs > 0:
    milsecs = min(milsecs, backoff.maxWaitMilsecs)
  backoff.waitMilsecs = milsecs

proc wait*(backoff: Backoff) =
  if backoff.exceedsMaxRetries:
    raise newException(ExceedsMaxRetriesError, "")
  let milsecs = backoff.waitMilsecs
  if milsecs > 0 and not backoff.fake:
    sleep(milsecs)
  backoff.currentRetries += 1
  backoff.updateWaitMilsecs()

proc waitAsync*(backoff: Backoff) {.async.} =
  if backoff.exceedsMaxRetries:
    raise newException(ExceedsMaxRetriesError, "")
  let milsecs = backoff.waitMilsecs
  if milsecs > 0 and not backoff.fake:
    await sleepAsync(milsecs)
  backoff.currentRetries += 1
  backoff.updateWaitMilsecs()

when defined(testing):
  let backoff = newBackoff(0, 0, true)
  assert backoff.waitMilsecs == 1000
  backoff.wait()
  assert backoff.waitMilsecs == 2000
  backoff.wait()
  assert backoff.waitMilsecs == 4000
  waitFor backoff.waitAsync()
  assert backoff.waitMilsecs == 8000
  waitFor backoff.waitAsync()
  assert backoff.waitMilsecs == 16000
