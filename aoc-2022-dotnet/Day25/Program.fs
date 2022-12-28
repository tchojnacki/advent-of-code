module Day25

open System
open System.IO

module Number =
    module private Digit =
        let private values =
            [ ('=', -2L)
              ('-', -1L)
              ('0', 0L)
              ('1', 1L)
              ('2', 2L) ]

        let snafuTuLong c = List.find (fst >> (=) c) values |> snd
        let longToSnafu d = List.find (snd >> (=) d) values |> fst

    let snafuToLong =
        let rec helper =
            function
            | [] -> 0L
            | digit :: rest -> Digit.snafuTuLong digit + 5L * helper rest

        Seq.rev >> List.ofSeq >> helper

    let rec longToSnafu =
        function
        | 0L -> ""
        | digit ->
            let (div, rem) = Math.DivRem(digit + 2L, 5L)
            sprintf "%s%c" (longToSnafu div) (Digit.longToSnafu <| rem - 2L)

let solution = Seq.sumBy Number.snafuToLong >> Number.longToSnafu

let test = File.ReadLines("test.txt")
assert (solution test = "2=-1=0")

let input = File.ReadLines("input.txt")
printfn "%s" <| solution input
