module Day06

open System.IO
open Common

let solution n =
    Seq.windowed n
    >> Seq.findIndex (Util.countDistinct >> (=) n)
    >> (+) n

assert
    [ ("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 7, 19)
      ("bvwbjplbgvbhsrlpgdmjqwftvncz", 5, 23)
      ("nppdvjthqldpwncqszvftbrmjlhg", 6, 23)
      ("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10, 29)
      ("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11, 26) ]
    |> List.forall (fun (test, s4, s14) -> solution 4 test = s4 && solution 14 test = s14)

let input = File.ReadAllText "input.txt"
printfn "%d" <| solution 4 input
printfn "%d" <| solution 14 input
