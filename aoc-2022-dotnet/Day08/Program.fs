module Day08

open System.IO
open Common

let parseMatrix = array2D >> Array2D.map Util.charToInt

let mapEachToSeq mapping m =
    seq {
        for r in 0 .. Array2D.length1 m - 1 do
            for c in 0 .. Array2D.length2 m - 1 -> mapping m r c
    }

let sideViews (m: 'a [,]) r c =
    [ m[0 .. r - 1, c] |> Array.rev
      m[r, c + 1 ..]
      m[r + 1 .., c]
      m[r, 0 .. c - 1] |> Array.rev ]

let isVisible (m: 'a [,]) r c =
    not
    <| List.forall (Array.exists ((<=) m[r, c])) (sideViews m r c)

let scenicScore (m: 'a [,]) r c =
    sideViews m r c
    |> List.map (fun s ->
        s
        |> Seq.tryFindIndex ((<=) m[r, c])
        |> Option.map ((+) 1)
        |> Option.defaultValue (Array.length s))
    |> List.reduce (*)

let solution1 =
    parseMatrix
    >> mapEachToSeq isVisible
    >> Util.countWhere id

let solution2 = parseMatrix >> mapEachToSeq scenicScore >> Seq.max

let test = File.ReadLines("test.txt")
assert (solution1 test = 21)
assert (solution2 test = 8)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution1 input
printfn "%d" <| solution2 input
