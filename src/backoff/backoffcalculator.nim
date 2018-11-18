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
# date  : 2018-11-18

import random
import jittertype

type
  BackoffCalculator* = ref object of RootObj
    maxWaitMilsecs: int
    waitMilsecs: int
    initialWaitMilsecs: int

  FullBackoffCalculator* = ref object of BackoffCalculator
  EqualBackoffCalculator* = ref object of BackoffCalculator
  DecorrelatedBackoffCalculator* = ref object of BackoffCalculator

proc newBackoffCalculator*(jitterType: JitterType, initialWaitMilsecs: int, maxWaitMilsecs: int): BackoffCalculator =
  case jitterType
  of TypeNo:
    result = BackoffCalculator(maxWaitMilsecs: maxWaitMilsecs, initialWaitMilsecs: initialWaitMilsecs)
  of TypeFull:
    result = FullBackoffCalculator(maxWaitMilsecs: maxWaitMilsecs, initialWaitMilsecs: initialWaitMilsecs)
  of TypeEqual:
    result = EqualBackoffCalculator(maxWaitMilsecs: maxWaitMilsecs, initialWaitMilsecs: initialWaitMilsecs)
  of TypeDecorrelated:
    result = DecorrelatedBackoffCalculator(maxWaitMilsecs: maxWaitMilsecs, initialWaitMilsecs: initialWaitMilsecs)

proc internalCalculate(calc: BackoffCalculator): int =
  if calc.waitMilsecs <= 0:
    result = calc.initialWaitMilsecs
  else:
    result = calc.waitMilsecs * 2
  if calc.maxWaitMilsecs > 0:
    result = min(result, calc.maxWaitMilsecs)
  calc.waitMilsecs = result

method calculate*(calc: BackoffCalculator): int {.base.} =
  result = calc.internalCalculate()

method calculate*(calc: FullBackoffCalculator): int =
  result = calc.internalCalculate()
  result = rand(result)

method calculate*(calc: EqualBackoffCalculator): int =
  result = calc.internalCalculate()
  let divide = int(result / 2)
  result = divide + rand(divide)

method calculate*(calc: DecorrelatedBackoffCalculator): int =
  if calc.waitMilsecs <= 0:
    result = calc.initialWaitMilsecs
  else:
    result = calc.waitMilsecs
  result = rand((result * 3) - calc.initialWaitMilsecs) + calc.initialWaitMilsecs
  if calc.maxWaitMilsecs > 0:
    result = min(result, calc.maxWaitMilsecs)
  calc.waitMilsecs = result
