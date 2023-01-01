module Day21

open System.IO
open System.Numerics
open FSharpPlus
open FParsec
open Common

type MonkeyName = string

module MonkeyName =
    let root = "root"
    let human = "humn"

type Operator = Complex -> Complex -> Complex

module Operator =
    let fromChar =
        function
        | '+' -> (+)
        | '-' -> (-)
        | '*' -> (*)
        | '/' -> (/)
        | c -> failwithf "Invalid operator: %c" c

    let unknownExtractor l r =
        let eq: Complex = l - r
        Complex(round <| -eq.Real / eq.Imaginary, 0)

type MonkeyJob =
    | Number of Complex
    | Operation of MonkeyName * Operator * MonkeyName

    static member unknownVariable = Number(Complex(0, 1))

    static member eval(cache: Map<MonkeyName, Complex>) =
        function
        | Number num -> num
        | Operation (left, operator, right) -> operator cache[left] cache[right]

    static member withOperator op =
        function
        | Operation (l, _, r) -> Operation(l, op, r)
        | other -> other

    static member dependencies =
        function
        | Operation (l, _, r) -> [ l; r ]
        | _ -> []

type Monkey = MonkeyName * MonkeyJob

module Monkey =
    let parse =
        let pws = pchar ' '
        let pname = anyString 4 |>> MonkeyName
        let pop = pws >>. anyChar .>> pws |>> Operator.fromChar
        let pnumber = pfloat |>> (fun n -> Number(Complex(n, 0)))
        let poperation = tuple3 pname pop pname |>> Operation
        let pjob = pnumber <|> poperation
        let pmonkey = pname .>> pstring ": " .>>. pjob |>> Monkey
        Util.parse pmonkey

let solution modification input =
    let monkeys =
        input
        |> Seq.map Monkey.parse
        |> Map
        |> modification

    let nodeValues =
        monkeys
        |> Map.mapValues MonkeyJob.dependencies
        |> Util.tsort
        |> List.fold (fun cache name -> Map.add name (MonkeyJob.eval cache monkeys[name]) cache) Map.empty

    int64 nodeValues[MonkeyName.root].Real

let part1 = id

let part2 =
    Map.add MonkeyName.human MonkeyJob.unknownVariable
    >> Map.change MonkeyName.root (Option.map (MonkeyJob.withOperator Operator.unknownExtractor))

let test = File.ReadLines("test.txt")
assert (solution part1 test = 152)
assert (solution part2 test = 301)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution part1 input
printfn "%d" <| solution part2 input
