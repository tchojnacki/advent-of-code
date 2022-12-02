open System.IO

let parseLine = function "" -> None | l -> Some(int l)
let readInput path = File.ReadLines path |> Seq.map parseLine

let splitOnNone xs =
    let (lastGroup, result) = Seq.fold (fun (groupAcc, resultAcc) x ->
        match x with
        | Some(value) -> (value :: groupAcc, resultAcc)
        | None -> (List.empty, (List.rev groupAcc) :: resultAcc)) (List.empty, List.empty) xs
    in List.rev (if List.isEmpty lastGroup then result else lastGroup :: result)

let groupCalorySums data = data |> splitOnNone |> List.map List.sum

let mostTotalCalories data = data |> groupCalorySums |> List.max

let rec insert x xs =
  match xs with
    | [] -> [x]
    | y::ys -> if x < y then x::y::ys else y::insert x ys

let topN n data =
    Seq.fold (fun acc elem ->
        if List.length acc < n then insert elem acc
        elif List.head acc < elem then insert elem (List.tail acc)
        else acc
    ) List.empty data

let top3TotalCaloriesSum data = data |> groupCalorySums |> topN 3 |> List.sum

let test = readInput "test.txt"
assert (mostTotalCalories test = 24000)
assert (top3TotalCaloriesSum test = 45000)

let input = readInput "input.txt"
printfn "%d" (mostTotalCalories input)
printfn "%d" (top3TotalCaloriesSum input)
