namespace Common

module Util =
    open System.Globalization
    open FParsec
    open FSharpPlus

    let parse parser input =
        match run parser input with
        | Success (result, _, _) -> result
        | _ -> failwith "Invalid input format!"

    let countDistinct seq = seq |> Set |> Set.count

    let countWhere pred = Seq.filter pred >> Seq.length

    let charToInt = CharUnicodeInfo.GetDigitValue

    let cutInHalf xs =
        let half = Seq.length xs / 2
        [ Seq.take half xs; Seq.skip half xs ]

    let splitStringToTuple sep str =
        match Seq.toList <| String.split [ sep ] str with
        | [ x; y ] -> x, y
        | _ -> failwith "Invalid string format!"

    let matrixToString m =
        m
        |> Seq.map (Seq.map string >> String.concat "")
        |> String.concat "\n"

    let topN n xs =
        let rec insertSorted x =
            function
            | h :: t -> min h x :: (insertSorted (max h x) t)
            | _ -> [ x ]

        Seq.fold
            (fun acc x ->
                if List.length acc < n then
                    insertSorted x acc
                elif List.head acc < x then
                    insertSorted x <| List.tail acc
                else
                    acc)
            List.empty
            xs
