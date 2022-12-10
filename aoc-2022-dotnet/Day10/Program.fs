module Day10

open System.IO
open FParsec
open Common

let initialCpuState = Map.empty |> Map.add 1 1
let screenWidth = 40
let screenHeight = 6

let testScreen =
    "██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░\n\
     ███░░░███░░░███░░░███░░░███░░░███░░░███░\n\
     ████░░░░████░░░░████░░░░████░░░░████░░░░\n\
     █████░░░░░█████░░░░░█████░░░░░█████░░░░░\n\
     ██████░░░░░░██████░░░░░░██████░░░░░░████\n\
     ███████░░░░░░░███████░░░░░░░███████░░░░░"

type Instr =
    | NOOP
    | ADDX of int

    static member parse str =
        let pnoop = pstring "noop" >>% NOOP
        let paddx = pstring "addx " >>. pint32 |>> ADDX
        let pinstr = pnoop <|> paddx
        Util.parse pinstr str

let solution actOnCpuStates =
    Seq.map Instr.parse
    >> Seq.fold
        (fun states instr ->
            let (cycle, X) = Map.maxKeyValue states

            states
            |> Map.add (cycle + 1) X
            |> match instr with
               | NOOP -> id
               | ADDX v -> Map.add (cycle + 2) (X + v))
        initialCpuState
    >> actOnCpuStates

let signalStrengthSum =
    Map.filter (fun cycle _ -> cycle % 40 = 20)
    >> Seq.sumBy (fun kv -> kv.Key * kv.Value)

let drawScreen =
    Map.map (fun cycle X ->
        match abs ((cycle - 1) % 40 - X) <= 1 with
        | true -> '█'
        | false -> '░')
    >> Map.values
    >> Seq.truncate (screenWidth * screenHeight)
    >> Seq.chunkBySize screenWidth
    >> Util.matrixToString

let test = File.ReadLines("test.txt")
assert (solution signalStrengthSum test = 13140)
assert (solution drawScreen test = testScreen)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution signalStrengthSum input
printfn "%s" <| solution drawScreen input
