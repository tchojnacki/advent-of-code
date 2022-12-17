module Day16

open System.IO
open FParsec
open Common

type ValveName = string

type Valve =
    { Flow: int
      Neighbours: ValveName list }

let parseValve =
    let pSingleOrMulti str = pstring str .>>. opt (pchar 's')
    let pValveName: Parser<ValveName, _> = anyString 2

    let pValve =
        pstring "Valve " >>. pValveName
        .>> pstring " has flow rate="
        .>>. pint32
        .>> pstring "; "
        .>> pSingleOrMulti "tunnel"
        .>> pchar ' '
        .>> pSingleOrMulti "lead"
        .>> pstring " to "
        .>> pSingleOrMulti "valve"
        .>> pchar ' '
        .>>. sepBy1 pValveName (pstring ", ")
        |>> (fun ((name, flow), neighbours) -> (name, { Flow = flow; Neighbours = neighbours }))

    Util.parse pValve

let distancesFrom valves start =
    let neighbours v = (Map.find v valves).Neighbours

    let rec bfsExplore visited acc =
        function
        | (v, depth) :: queue ->
            bfsExplore
                (Set.add v visited)
                (((start, v), depth) :: acc)
                (queue
                 @ (neighbours v
                    |> List.filter (Util.notIn visited)
                    |> List.map (fun n -> (n, depth + 1))))
        | [] -> acc

    bfsExplore Set.empty [] [ (start, 0) ]

let buildGraph input =
    let valves = input |> Seq.map parseValve |> Map.ofSeq

    let flows =
        valves
        |> Map.map (fun _ v -> v.Flow)
        |> Map.filter (fun v f -> f > 0 || v = "AA")

    let distances =
        valves
        |> Map.keys
        |> Seq.collect (distancesFrom valves)
        |> Map.ofSeq
        |> Map.filter (fun (f, t) _ ->
            f <> t
            && Map.containsKey f flows
            && Map.containsKey t flows)

    flows, distances

let solution input =
    let (flows, distances) = buildGraph input

    let rec findMaxPressure current remainingTime closedValves =
        let closedValves = closedValves |> Set.remove current

        closedValves
        |> Seq.choose (fun t ->
            let remainingTime = remainingTime - (distances[(current, t)] + 1)

            if remainingTime > 0 then
                Some(
                    flows[t] * remainingTime
                    + findMaxPressure t remainingTime closedValves
                )
            else
                None)
        |> Util.maxOrZero

    findMaxPressure "AA" 30 (flows |> Map.keys |> Set.ofSeq)

let test = File.ReadLines("test.txt")
assert (solution test = 1651)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution input
