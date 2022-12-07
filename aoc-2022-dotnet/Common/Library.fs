module Common

open FParsec

let parse parser input =
    match run parser input with
    | Success (result, _, _) -> result
    | _ -> failwith "Invalid input format!"
