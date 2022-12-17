module Day16

open System.IO
open FParsec
open Common

type ValveName = string

type Valve =
    { Flow: int
      Neighbours: ValveName list }

let buildGraph input =
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
        let neighbours node = (Map.find node valves).Neighbours

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

    let valveMap = input |> Seq.map parseValve |> Map.ofSeq

    let flows =
        valveMap
        |> Map.map (fun _ v -> v.Flow)
        |> Map.filter (fun v f -> f > 0 || v = "AA")

    let distances =
        valveMap
        |> Map.keys
        |> Seq.collect (distancesFrom valveMap)
        |> Map.ofSeq
        |> Map.filter (fun (f, t) _ ->
            f <> t
            && Map.containsKey f flows
            && Map.containsKey t flows)

    let valves = flows |> Map.keys |> Set.ofSeq

    valves, flows, distances

let solution input =
    let (valves, flows, distances) = buildGraph input

    let findBestFlow time =
        let rec explore current time visited flow results =
            if time <= 0 then
                results
            else
                let visited' = visited |> Set.add current
                let results' = results |> Util.updateMax visited' flow

                Seq.fold
                    (fun acc next ->
                        let time' = time - (distances[(current, next)] + 1)
                        let flow' = flow + flows[next] * time'
                        explore next time' visited' flow' acc)
                    results'
                    (valves - visited')

        explore "AA" time Set.empty 0 Map.empty

    let part1 = findBestFlow 30 |> Map.values |> Seq.max
    let paths = findBestFlow 26

    let part2 =
        Seq.max
        <| seq {
            for selfPath in paths do
                for elephantPath in paths do
                    if Set.intersect selfPath.Key elephantPath.Key = Set.singleton "AA" then
                        yield selfPath.Value + elephantPath.Value
        }

    part1, part2

let test = File.ReadLines("test.txt")
assert (solution test = (1651, 1707))

let input = File.ReadLines("input.txt")
printfn "%A" <| solution input
