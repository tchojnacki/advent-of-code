module Day21

open System.IO
open FSharpPlus
open FParsec
open Common

type MonkeyName = string
type Operator = int64 -> int64 -> int64

type MonkeyJob =
    | Number of int64
    | Operation of MonkeyName * Operator * MonkeyName

    static member dependencies =
        function
        | Number _ -> []
        | Operation (l, _, r) -> [ l; r ]

type Monkey = MonkeyName * MonkeyJob

let charToOperator =
    function
    | '+' -> (+)
    | '-' -> (-)
    | '*' -> (*)
    | '/' -> (/)
    | c -> failwithf "Invalid operator: %c" c

let parseMonkey =
    let pspc = pchar ' '
    let pname = anyString 4 |>> MonkeyName
    let poper = pspc >>. anyChar .>> pspc |>> charToOperator
    let pnumber = pint64 |>> Number
    let poperation = tuple3 pname poper pname |>> Operation
    let pjob = pnumber <|> poperation
    let pmonkey = pname .>> pstring ": " .>>. pjob |>> Monkey
    Util.parse pmonkey

let solution input =
    let monkeys = input |> Seq.map parseMonkey |> Map.ofSeq

    monkeys
    |> Map.mapValues MonkeyJob.dependencies
    |> Util.tsort
    |> List.fold
        (fun values name ->
            Map.add
                name
                (match monkeys[name] with
                 | Number num -> num
                 | Operation (left, operator, right) -> operator values[left] values[right])
                values)
        Map.empty
    |> Map.find "root"

let test = File.ReadLines("test.txt")
assert (solution test = 152)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution input
