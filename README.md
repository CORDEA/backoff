# backoff

Exponential Backoff library for nim.

## Jitter

Support three jitter algorithms.

- Full Jitter
- Equal Jitter
- Decorrlated Jitter

And of course, without Jitter.
I referred to [Exponential Backoff And Jitter - AWS Architecture Blog](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/).

## Usage

```nim
let
  client = ApiClient()
  # Full Jitter
  waiter = newBackoff(TypeFull, 10, 16000)
while true:
  let response = client.request()
  if response.code.is2xx:
    break
  waiter.wait() # or await waiter.waitAsync()
```
