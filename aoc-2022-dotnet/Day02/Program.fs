open System.IO
open FSharpPlus

type Move =
    | Rock
    | Paper
    | Scissors

    static member parse =
        function
        | "A" -> Rock
        | "B" -> Paper
        | "C" -> Scissors
        | s -> failwithf "Invalid move: %s" s

    static member choices = [ Rock; Paper; Scissors ]

    member first.beats second =
        match (first, second) with
        | (Rock, Scissors)
        | (Scissors, Paper)
        | (Paper, Rock) -> true
        | _ -> false

type Strategy =
    | X
    | Y
    | Z

    static member parse =
        function
        | "X" -> X
        | "Y" -> Y
        | "Z" -> Z
        | s -> failwithf "Invalid strategy: %s" s

let splitToTuple sep str =
    match Seq.toList <| String.split [ sep ] str with
    | [ x; y ] -> x, y
    | _ -> failwith "Invalid string format!"

let scoreRound (enemy, player) =
    let selectionScore =
        match player with
        | Rock -> 1
        | Paper -> 2
        | Scissors -> 3

    let outcomeScore =
        if player.beats enemy then 6
        elif player = enemy then 3
        else 0

    selectionScore + outcomeScore

let guide1 _ =
    function
    | X -> Rock
    | Y -> Paper
    | Z -> Scissors

let guide2 (enemy: Move) =
    function
    | X -> Seq.find (fun player -> enemy.beats player) Move.choices
    | Y -> enemy
    | Z -> Seq.find (fun player -> player.beats enemy) Move.choices

let parseRound guide roundStr =
    let (enemy, strategy) =
        roundStr
        |> splitToTuple " "
        |> mapItem1 Move.parse
        |> mapItem2 Strategy.parse

    enemy, guide enemy strategy

let solution guide =
    Seq.map (parseRound guide) >> Seq.sumBy scoreRound

let test = File.ReadLines "test.txt"
assert (solution guide1 test = 15)
assert (solution guide2 test = 12)

let input = File.ReadLines "input.txt"
printfn "%d" <| solution guide1 input
printfn "%d" <| solution guide2 input
