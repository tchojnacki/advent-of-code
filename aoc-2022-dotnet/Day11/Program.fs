module Day11

open System.IO
open FParsec
open Common

type Item = int64
type MonkeyId = int32
type Throw = { To: MonkeyId; Item: Item }

type Monkey =
    { Id: MonkeyId
      Items: Item list
      Operation: Item -> Item
      Condition: Item
      IfTrue: MonkeyId
      IfFalse: MonkeyId
      Inspections: int64 }

    static member condition m = m.Condition
    static member inspections m = m.Inspections

    member m.throwItem i =
        { Item = i
          To =
            match i % m.Condition with
            | 0L -> m.IfTrue
            | _ -> m.IfFalse }

    static member receiveThrows ts m =
        { m with
            Items =
                m.Items
                @ List.choose (fun ({ To = ti; Item = item }) -> if ti = m.Id then Some(item) else None) ts }

    static member throwAllAway worryReducer m =
        let throws = List.map (m.Operation >> worryReducer >> m.throwItem) m.Items

        { m with
            Items = []
            Inspections = m.Inspections + int64 (List.length throws) },
        throws

    static member parseList input =
        let pid =
            pstring "Monkey " >>. pint32
            .>> pchar ':'
            .>> newline

        let pitems =
            pstring "  Starting items: "
            >>. sepBy1 pint64 (pstring ", ")
            .>> newline

        let padd = attempt (pstring "+ " >>. pint64 |>> (+))
        let pmul = attempt (pstring "* " >>. pint64 |>> (*))
        let psqr = attempt (pstring "* old" >>% fun n -> n * n)

        let poperation =
            pstring "  Operation: new = old "
            >>. choice [ padd; pmul; psqr ]
            .>> newline

        let pcondition =
            pstring "  Test: divisible by " >>. pint64
            .>> newline

        let piftrue =
            pstring "    If true: throw to monkey " >>. pint32
            .>> newline

        let piffalse =
            pstring "    If false: throw to monkey "
            >>. pint32
            .>> newline

        let ptest = tuple3 pcondition piftrue piffalse

        let pmonkey =
            tuple4 pid pitems poperation ptest
            |>> fun (id, items, operation, (condition, iftrue, iffalse)) ->
                    { Id = id
                      Items = items
                      Operation = operation
                      Condition = condition
                      IfTrue = iftrue
                      IfFalse = iffalse
                      Inspections = 0 }

        let pmonkeys = sepBy1 pmonkey newline
        Util.parse pmonkeys input

let monkeyBusiness =
    List.map Monkey.inspections
    >> Util.topN 2
    >> List.reduce (*)

let solution (worryManager, n) input =
    let monkeys = Monkey.parseList input
    let reduceWorry = worryManager monkeys

    let processRound monkeys =
        let rec helper ms i =
            let (current', throws) = List.item i ms |> Monkey.throwAllAway reduceWorry

            let ms' =
                ms
                |> List.updateAt i current'
                |> List.map (Monkey.receiveThrows throws)

            match List.tryItem (i + 1) ms' with
            | Some (_) -> helper ms' (i + 1)
            | None -> ms'

        helper monkeys 0

    monkeys
    |> Util.composition n processRound
    |> monkeyBusiness

let part1 = (fun _ n -> n / 3L), 20

let part2 =
    (fun ms n ->
        let lcm = ms |> List.map Monkey.condition |> List.reduce (*)
        n % lcm),
    10_000

let test = File.ReadAllText("test.txt")
assert (solution part1 test = 10605)
assert (solution part2 test = 2713310158L)

let input = File.ReadAllText("input.txt")
printfn "%d" <| solution part1 input
printfn "%d" <| solution part2 input
