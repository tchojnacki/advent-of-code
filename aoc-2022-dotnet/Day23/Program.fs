module Day23

open System.IO
open Common

type Grove =
    { Elves: Set<Vec2>
      Intents: (Vec2 * (Vec2 -> Set<Vec2>)) list }

    static member private initialIntents =
        [ Vec2.up, Vec2.neighboursUp
          Vec2.down, Vec2.neighboursDown
          Vec2.left, Vec2.neighboursLeft
          Vec2.right, Vec2.neighboursRight ]

    static member private cycleIntents = Util.cycle >> snd

    static member private positionsFree elves = Set.forall (Util.notIn elves)

    static member private isElfUnsettled elves =
        Vec2.neighbours8
        >> Grove.positionsFree elves
        >> not

    static member isUnsettled({ Elves = elves }) =
        Set.exists (Grove.isElfUnsettled elves) elves

    static member parse input =
        { Elves =
            input
            |> Seq.rev // bottom left should be (0, 0)
            |> array2D
            |> Util.mapEachToSeq (fun _ pos char -> if char = '#' then Some(pos) else None)
            |> Seq.choose id
            |> Set
          Intents = Grove.initialIntents }

    static member private proposeNextPos ({ Elves = elves; Intents = intents }) elfPos =
        if Grove.isElfUnsettled elves elfPos then
            intents
            |> List.tryPick (fun (offset, neighbours) ->
                match elfPos |> neighbours |> Grove.positionsFree elves with
                | true -> Some(elfPos + offset)
                | false -> None)
            |> Option.defaultValue elfPos
        else
            elfPos

    static member doRound grove =
        { Elves =
            grove.Elves
            |> Set.fold
                (fun map oldPos ->
                    Map.change
                        (Grove.proposeNextPos grove oldPos) // destination position
                        (fun ps -> Some(oldPos :: Option.defaultValue [] ps)) // list of source positions
                        map)
                Map.empty
            |> Seq.collect (fun kv ->
                match kv.Value with
                | [ _ ] -> [ kv.Key ] // only one elf proposes the position, keep new position
                | ps -> ps) // many elves propose the position, revert to old positions
            |> Set
          Intents = Grove.cycleIntents grove.Intents }

let solution1 input =
    let grove =
        input
        |> Grove.parse
        |> Util.composition 10 Grove.doRound

    let (Vec2 (minX, minY), Vec2 (maxX, maxY)) = Vec2.boundingRectangle grove.Elves
    let area = (maxX - minX + 1) * (maxY - minY + 1)
    area - Set.count grove.Elves

let solution2 =
    Grove.parse
    >> Seq.unfold (fun grove -> Some(grove, Grove.doRound grove))
    >> Seq.takeWhile Grove.isUnsettled
    >> Seq.length
    >> (+) 1

let test = File.ReadLines("test.txt")
assert (solution1 test = 110)
assert (solution2 test = 20)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution1 input
printfn "%d" <| solution2 input
