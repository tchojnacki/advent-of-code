import gleam/dict.{type Dict}
import gleam/otp/actor.{type Next, Stop}
import gleam/erlang/process.{type Subject, Normal}

const timeout = 1000

type Message(k, v) {
  Shutdown
  Get(key: k, client: Subject(Result(v, Nil)))
  Set(key: k, value: v)
}

type Server(k, v) =
  Subject(Message(k, v))

fn handle_message(
  message: Message(k, v),
  map: Dict(k, v),
) -> Next(Message(k, v), Dict(k, v)) {
  case message {
    Shutdown -> Stop(Normal)
    Get(key, client) -> {
      process.send(client, dict.get(map, key))

      actor.continue(map)
    }
    Set(key, value) -> actor.continue(dict.insert(map, key, value))
  }
}

pub opaque type Cache(k, v) {
  Cache(server: Server(k, v))
}

pub fn create(apply fun: fn(Cache(k, v)) -> t) -> t {
  let assert Ok(server) = actor.start(dict.new(), handle_message)
  let result = fun(Cache(server))
  process.send(server, Shutdown)
  result
}

pub fn set(in cache: Cache(k, v), for key: k, insert value: v) -> Nil {
  process.send(cache.server, Set(key, value))
}

pub fn get(from cache: Cache(k, v), fetch key: k) -> Result(v, Nil) {
  process.call(cache.server, Get(key, _), timeout)
}

pub fn memoize(with cache: Cache(k, v), this key: k, apply fun: fn() -> v) -> v {
  let result = case get(from: cache, fetch: key) {
    Ok(value) -> value
    Error(Nil) -> fun()
  }
  set(in: cache, for: key, insert: result)
  result
}
