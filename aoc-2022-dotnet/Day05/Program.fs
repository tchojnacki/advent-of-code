open System
open System.IO
open FParsec

type Move =
    | Move of int * int * int

    static member parse str =
        let dec n = n - 1
        let pPart str = pstring str >>. pint32
        let pMove = tuple3 (pPart "move ") (pPart " from " |>> dec) (pPart " to " |>> dec)

        match run pMove str with
        | Success (result, _, _) -> Move result
        | _ -> failwith "Invalid move format!"

    static member execute order stacks (Move (n, fi, ti)) =
        List.mapi
            (fun i x ->
                if i = fi then
                    List.item fi stacks |> List.skip n
                elif i = ti then
                    (List.item fi stacks |> List.take n |> order)
                    @ List.item ti stacks
                else
                    x)
            stacks

let parseStacks str =
    let pFullCrate = pchar '[' >>. anyChar .>> pchar ']' |>> Some
    let pEmptyCrate = pstring "   " >>% None
    let pCrate = pFullCrate <|> pEmptyCrate
    let pCrateLine = sepBy pCrate (pchar ' ') .>> skipNewline
    let pHeader = many pCrateLine

    let parsed =
        match run pHeader str with
        | Success (result, _, _) -> result
        | _ -> failwith "Invalid header format!"

    parsed
    |> List.transpose
    |> List.map (List.choose id)

let solve order input =
    let headerList =
        input
        |> Seq.takeWhile (not << String.IsNullOrEmpty)
        |> Seq.toList

    let stacks = parseStacks <| String.Join("\n", headerList)

    String.Concat(
        input
        |> Seq.skip (headerList.Length + 1)
        |> Seq.map Move.parse
        |> Seq.fold (Move.execute order) stacks
        |> List.map List.head
    )

let test = File.ReadLines "test.txt"
assert (solve List.rev test = "CMZ")
assert (solve id test = "MCD")

let input = File.ReadLines "input.txt"
printfn "%s" <| solve List.rev input
printfn "%s" <| solve id input
