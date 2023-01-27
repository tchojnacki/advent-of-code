import gleam/string

pub fn is_not_empty(str: String) -> Bool {
  !string.is_empty(str)
}
