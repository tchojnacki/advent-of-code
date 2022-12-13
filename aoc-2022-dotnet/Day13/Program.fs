module Day13

#nowarn "0342"

open System
open System.IO
open FParsec
open Common

[<StructuralEquality; CustomComparison>]
type Packet =
    | Integer of int
    | List of Packet list

    static member dividers =
        [ Packet.parse "[[2]]"
          Packet.parse "[[6]]" ]

    interface IComparable with
        member this.CompareTo other =
            match other with
            | :? Packet as p -> (this :> IComparable<_>).CompareTo p
            | _ -> failwith "Can only compare packets with other packets!"

    interface IComparable<Packet> with
        member this.CompareTo other =
            match (this, other) with
            | Integer l, Integer r -> compare l r
            | List l, List r -> compare l r
            | (Integer _ as l), (List _ as r) -> compare (List [ l ]) r
            | (List _ as l), (Integer _ as r) -> compare l (List [ r ])

    static member parse =
        let ppacket, ppacketImpl = createParserForwardedToRef ()
        let pinteger = pint32 |>> Integer

        let plist =
            between (pchar '[') (pchar ']') (sepBy ppacket (pchar ','))
            |>> List

        ppacketImpl.Value <- pinteger <|> plist

        Util.parse ppacket

let solution (transform, predicate, reducer) =
    Seq.filter (not << String.IsNullOrWhiteSpace)
    >> Seq.map Packet.parse
    >> transform
    >> Seq.indexed
    >> Seq.choose (fun (i, p) ->
        match predicate p with
        | true -> Some(i + 1)
        | false -> None)
    >> Seq.reduce reducer

let part1 =
    (Seq.chunkBySize 2
     >> Seq.map (function
         | [| l; r |] -> compare l r
         | _ -> failwith "Invalid packet groupings!"),
     (>=) 0,
     (+))

let part2 =
    (Seq.append Packet.dividers >> Seq.sort, (fun p -> List.contains p Packet.dividers), (*))

let test = File.ReadLines("test.txt")
assert (solution part1 test = 13)
assert (solution part2 test = 140)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution part1 input
printfn "%d" <| solution part2 input
