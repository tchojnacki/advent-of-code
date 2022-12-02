open System.IO
open FSharpPlus

type Move = R | P | S
type Result = Win | Draw | Lose
exception ParseError

let parseEnemyMove = function "A" -> R | "B" -> P | "C" -> S | _ -> raise ParseError
let parseAllyMove = function "X" -> R | "Y" -> P | "Z" -> S | _ -> raise ParseError
let parseOutcome = function "X" -> Lose | "Y" -> Draw | "Z" -> Win | _ -> raise ParseError

let roundScore round =
    let selectionScore = function R -> 1 | P -> 2 | S -> 3

    let outcomeScore = function
        | (R, S) | (S, P) | (P, R) -> 0
        | (R, R) | (P, P) | (S, S) -> 3
        | (R, P) | (P, S) | (S, R) -> 6

    selectionScore (snd round) + outcomeScore round

let lineToTuple line =
    match String.split [" "] line |> Seq.toList with
    | [first; second] -> first, second
    | _ -> raise ParseError

let selectMove outcome enemyMove =
    match (outcome, enemyMove) with
    | (Win, R) -> P | (Draw, R) -> R | (Lose, R) -> S
    | (Win, P) -> S | (Draw, P) -> P | (Lose, P) -> R
    | (Win, S) -> R | (Draw, S) -> S | (Lose, S) -> P

let parseRoundV1 roundStr =
    let (firstStr, secondStr) = lineToTuple roundStr
    parseEnemyMove firstStr, parseAllyMove secondStr

let parseRoundV2 roundStr =
    let (firstStr, secondStr) = lineToTuple roundStr
    let enemyMove = parseEnemyMove firstStr
    let outcome = parseOutcome secondStr
    let allyMove = selectMove outcome enemyMove
    enemyMove, allyMove

let rateStrategyGuideV1 input = input |> Seq.map parseRoundV1 |> Seq.sumBy roundScore
let rateStrategyGuideV2 input = input |> Seq.map parseRoundV2 |> Seq.sumBy roundScore

let test = File.ReadLines "test.txt"
assert (rateStrategyGuideV1 test = 15)
assert (rateStrategyGuideV2 test = 12)

let input = File.ReadLines "input.txt"
printfn "%d" (rateStrategyGuideV1 input)
printfn "%d" (rateStrategyGuideV2 input)
