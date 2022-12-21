namespace Common

module Util =
    open System.Globalization
    open FParsec
    open FSharpPlus

    let parse parser input =
        match run parser input with
        | Success (result, _, _) -> result
        | _ -> failwith "Invalid input format!"

    let countDistinct xs = xs |> Set |> Set.count

    let countWhere pred = Seq.filter pred >> Seq.length

    let charToInt = CharUnicodeInfo.GetDigitValue

    let cutInHalf xs =
        let half = Seq.length xs / 2
        [ Seq.take half xs; Seq.skip half xs ]

    let splitStringToTuple sep string =
        match Seq.toList <| String.split [ sep ] string with
        | [ x; y ] -> x, y
        | _ -> failwith "Invalid string format!"

    let matrixToString matrix =
        matrix
        |> Seq.map (Seq.map string >> String.concat "")
        |> String.concat "\n"

    let mapEachToSeq mapping matrix =
        seq {
            for row in 0 .. Array2D.length1 matrix - 1 do
                for col in 0 .. Array2D.length2 matrix - 1 -> mapping matrix (Vec2(col, row)) matrix[row, col]
        }

    let mAt matrix (Vec2 (col, row)) = Array2D.get matrix row col

    let rec composition n f x =
        if n = 0 then
            x
        else
            composition (n - 1) f (f x)

    let notIn set element = not <| Set.contains element set

    let updateMax key newValue map =
        map
        |> Map.add key (max newValue (map |> Map.tryFind key |> Option.defaultValue 0))

    let rec insertSorted x =
        function
        | h :: t -> min h x :: (insertSorted (max h x) t)
        | [] -> [ x ]

    let liftList xs =
        match List.forall Option.isSome xs with
        | true -> Some(List.map Option.get xs)
        | false -> None

    let cycle =
        function
        | h :: t -> h, t @ [ h ]
        | [] -> failwith "Empty list!"

    let topN n xs =
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
