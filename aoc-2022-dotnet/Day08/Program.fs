module Day08

open System.IO
open Common

let parseMatrix = array2D >> Array2D.map Util.charToInt

let sideViews (m: 'a [,]) (Vec2 (c, r)) =
    [ m[0 .. r - 1, c] |> Array.rev
      m[r, c + 1 ..]
      m[r + 1 .., c]
      m[r, 0 .. c - 1] |> Array.rev ]

let isVisible (matrix: 'a [,]) pos height =
    not
    <| List.forall (Array.exists ((<=) height)) (sideViews matrix pos)

let scenicScore (matrix: 'a [,]) pos height =
    sideViews matrix pos
    |> List.map (fun s ->
        s
        |> Seq.tryFindIndex ((<=) height)
        |> Option.map ((+) 1)
        |> Option.defaultValue (Array.length s))
    |> List.reduce (*)

let solution1 =
    parseMatrix
    >> Util.mapEachToSeq isVisible
    >> Util.countWhere id

let solution2 =
    parseMatrix
    >> Util.mapEachToSeq scenicScore
    >> Seq.max

let test = File.ReadLines("test.txt")
assert (solution1 test = 21)
assert (solution2 test = 8)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution1 input
printfn "%d" <| solution2 input
