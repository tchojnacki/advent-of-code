module Day24

open System.IO
open FSharpPlus
open Common

type Valley =
    { MaxX: int
      MaxY: int
      ExpeditionSuperposition: Set<Vec2>
      Walls: Set<Vec2>
      Blizzards: Map<Vec2, Set<Vec2>> }

    static member private empty =
        { MaxX = 0
          MaxY = 0
          ExpeditionSuperposition = Set.empty
          Walls = Set.empty
          Blizzards =
            Vec2.directions4
            |> Set.map (fun d -> d, Set.empty)
            |> Map }

    static member private withExpeditionAt target valley =
        { valley with ExpeditionSuperposition = Set.singleton <| target valley }

    static member private hasReached target valley =
        Set.contains (target valley) valley.ExpeditionSuperposition

    static member startOf({ MaxY = maxY }) = Vec2(1, maxY)
    static member endOf({ MaxX = maxX }) = Vec2(maxX - 1, 0)

    static member parse input =
        input
        |> Seq.rev
        |> array2D
        |> Array2D.mapi (fun r c char -> Vec2(c, r), char)
        |> Seq.cast
        |> Seq.fold
            (fun valley (pos, char) ->
                match char with
                | '.' -> valley
                | '#' ->
                    { valley with
                        Walls = valley.Walls.Add(pos)
                        MaxX = max valley.MaxX pos.x
                        MaxY = max valley.MaxY pos.y }
                | '^'
                | '>'
                | 'v'
                | '<' ->
                    { valley with Blizzards = valley.Blizzards.Change(Vec2.dirFromChar char, Option.map <| Set.add pos) }
                | c -> failwithf "Invalid valley character: %c" c)
            Valley.empty
        |> Valley.withExpeditionAt Valley.startOf

    member private valley.moveBlizzard offset pos =
        pos + offset
        |> Vec2.mapX (Util.wrapInRangeInc 1 (valley.MaxX - 1))
        |> Vec2.mapY (Util.wrapInRangeInc 1 (valley.MaxY - 1))

    static member private step valley =
        let valley =
            { valley with Blizzards = Map.map (fun dir -> Set.map <| valley.moveBlizzard dir) valley.Blizzards }

        { valley with
            ExpeditionSuperposition =
                valley.ExpeditionSuperposition
                |> Seq.collect Vec2.neighbours5
                |> Seq.filter (fun pos ->
                    pos.y >= 0
                    && pos.y <= valley.MaxY
                    && Util.notIn valley.Walls pos
                    && Seq.forall (not << Set.contains pos) valley.Blizzards.Values)
                |> Set }

    static member moveTo target valley =
        Some(valley, 0)
        |> Seq.unfold (
            Option.map
            <| fun (v, m) ->
                (v, m),
                match Valley.hasReached target v with
                | true -> None
                | false -> Some(Valley.step v, m + 1)
        )
        |> Seq.last
        |> mapItem1 (Valley.withExpeditionAt target)

let solution1 = Valley.parse >> Valley.moveTo Valley.endOf >> snd

let solution2 input =
    let valley = Valley.parse input

    let (valley, minutes1) = Valley.moveTo Valley.endOf valley
    let (valley, minutes2) = Valley.moveTo Valley.startOf valley
    let (_, minutes3) = Valley.moveTo Valley.endOf valley

    minutes1 + minutes2 + minutes3

let test = File.ReadLines("test.txt")
assert (solution1 test = 18)
assert (solution2 test = 54)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution1 input
printfn "%d" <| solution2 input
