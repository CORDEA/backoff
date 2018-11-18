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

import unittest
import .. / .. / src / backoff / jittertype
import .. / .. / src / backoff / backoffcalculator

suite "BackoffCalculator test":
  test "no backoff":
    let calc = newBackoffCalculator(TypeNo, 1000, 16000)
    check(calc.calculate() == 1000)
    check(calc.calculate() == 2000)
    check(calc.calculate() == 4000)
    check(calc.calculate() == 8000)
    check(calc.calculate() == 16000)
    check(calc.calculate() == 16000)

  test "full backoff":
    let calc = newBackoffCalculator(TypeFull, 1000, 16000)
    check(calc.calculate() <= 1000)
    check(calc.calculate() <= 2000)
    check(calc.calculate() <= 4000)
    check(calc.calculate() <= 8000)
    check(calc.calculate() <= 16000)
    check(calc.calculate() <= 16000)

  test "equal backoff":
    let calc = newBackoffCalculator(TypeEqual, 1000, 16000)
    var res = calc.calculate()
    check(500 <= res and res <= 1000)
    res = calc.calculate()
    check(1000 <= res and res <= 2000)
    res = calc.calculate()
    check(2000 <= res and res <= 4000)
    res = calc.calculate()
    check(4000 <= res and res <= 8000)
    res = calc.calculate()
    check(8000 <= res and res <= 16000)
    res = calc.calculate()
    check(8000 <= res and res <= 16000)

  test "decorrelated backoff":
    let calc = newBackoffCalculator(TypeDecorrelated, 1000, 16000)
    for i in 0..10:
      let res = calc.calculate()
      check(1000 <= res and res <= 16000)
