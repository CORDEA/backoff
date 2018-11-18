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
import backoff / jittertype
import backoff / backoffcalculator

const InitialWaitMilsecs = 1 * 1000

type
  Backoff* = ref object
    currentRetries: int
    maxRetries: int
    calculator: BackoffCalculator
    fake: bool

  ExceedsMaxRetriesError = object of Exception

proc newBackoff(jitterType: JitterType, maxRetries: int, maxWaitMilsecs: int, fake: bool): Backoff =
  result = Backoff(
    currentRetries: 0,
    maxRetries: maxRetries,
    calculator: newBackoffCalculator(jitterType, InitialWaitMilsecs, maxWaitMilsecs),
    fake: fake
  )

proc newBackoff*(jitterType: JitterType, maxRetries: int = 0, maxWaitMilsecs: int = 0): Backoff =
  result = newBackoff(jitterType, maxRetries, maxWaitMilsecs, false)

proc exceedsMaxRetries*(backoff: Backoff): bool =
  if backoff.maxRetries < 1:
    return false
  result = backoff.currentRetries >= backoff.maxRetries

proc retry(backoff: Backoff) =
  backoff.currentRetries += 1

proc wait*(backoff: Backoff) =
  if backoff.exceedsMaxRetries:
    raise newException(ExceedsMaxRetriesError, "Exceeds the max number of retries.")
  let milsecs = backoff.calculator.calculate()
  if milsecs > 0 and not backoff.fake:
    sleep(milsecs)
  backoff.retry()

proc waitAsync*(backoff: Backoff) {.async.} =
  if backoff.exceedsMaxRetries:
    raise newException(ExceedsMaxRetriesError, "Exceeds the max number of retries.")
  let milsecs = backoff.calculator.calculate()
  if milsecs > 0 and not backoff.fake:
    await sleepAsync(milsecs)
  backoff.retry()

when defined(testing):
  let backoff = newBackoff(TypeNo, 3, 0, true)
  assert(not backoff.exceedsMaxRetries)
  backoff.wait()
  assert(not backoff.exceedsMaxRetries)
  backoff.wait()
  assert(not backoff.exceedsMaxRetries)
  backoff.wait()
  assert backoff.exceedsMaxRetries
  var raised = false
  try:
    backoff.wait()
  except ExceedsMaxRetriesError:
    raised = true
  assert raised
