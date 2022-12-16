module Day15

open System.IO
open FSharp.Collections.ParallelSeq
open FParsec
open Common

let tuner = 4_000_000

type Sensor =
    { Pos: Vec2
      Radius: int
      NearestBeacon: Vec2 }

let rangeCount (first, last) = max 0 (last - first + 1)

type RangeSet =
    | RangeSet of (int * int) list

    static member empty = RangeSet []

    static member private merge =
        function
        | ((_, l1) as r1) :: ((f2, _) as r2) :: t when l1 + 1 < f2 -> r1 :: RangeSet.merge (r2 :: t)
        | (f1, l1) :: (_, l2) :: t -> RangeSet.merge <| (f1, max l1 l2) :: t
        | other -> other

    static member add set range =
        if rangeCount range = 0 then
            set
        else
            let (RangeSet list) = set
            RangeSet(RangeSet.merge (Util.insertSorted range list))

    static member count(RangeSet list) = List.map rangeCount list |> List.sum

    static member gap =
        function
        | (RangeSet ([ (_, x); _ ])) -> Some(x + 1)
        | _ -> None

let sensorList =
    let parseSensor line =
        let ppos =
            tuple2 (pstring "x=" >>. pint32) (pstring ", y=" >>. pint32)
            |>> Vec2

        let pline =
            pstring "Sensor at " >>. ppos
            .>> pstring ": closest beacon is at "
            .>>. ppos

        let (sensorPos, beaconPos) = Util.parse pline line

        { Pos = sensorPos
          Radius = Vec2.mahattanDist sensorPos beaconPos
          NearestBeacon = beaconPos }

    Seq.map parseSensor >> List.ofSeq

let rowCoverages y sensors =
    let coverage ({ Radius = radius; Pos = pos }) =
        let offset = radius - abs (Vec2.y pos - y)
        (Vec2.x pos - offset, Vec2.x pos + offset)

    sensors
    |> Seq.map coverage
    |> Seq.fold RangeSet.add RangeSet.empty

let solution1 y input =
    let sensors = sensorList input

    let beaconsInRow =
        sensors
        |> Seq.choose (fun ({ NearestBeacon = b }) ->
            if Vec2.y b = y then
                Some(Vec2.x b)
            else
                None)
        |> Util.countDistinct

    sensors
    |> rowCoverages y
    |> RangeSet.count
    |> (fun count -> count - beaconsInRow)

let solution2 input =
    let sensors = sensorList input

    seq { 0..tuner }
    |> PSeq.pick (fun y ->
        sensors
        |> rowCoverages y
        |> RangeSet.gap
        |> Option.map (fun x -> int64 x * int64 tuner + int64 y))

let test = File.ReadLines("test.txt")
assert (solution1 10 test = 26)
assert (solution2 test = 56000011)

let input = File.ReadLines("input.txt")
printfn "%A" <| solution1 2_000_000 input
printfn "%A" <| solution2 input
