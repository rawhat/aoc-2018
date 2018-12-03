defmodule Checksum do
  def read_input() do
    File.read!("input.txt")
    |> String.split("\n")
  end

  def two_or_three_count(id) do
    id
    |> String.split("")
    |> Enum.filter(&(&1 != ""))
    |> Enum.reduce(%{}, fn item, map ->
      Map.put(map, item, Map.get(map, item, 0) + 1)
    end)
    |> Enum.reduce(%{two: false, three: false}, fn {_, count}, m ->
      %{two: count == 2 || m[:two], three: count == 3 || m[:three]}
    end)
  end

  def get_checksum() do
    read_input()
    |> Enum.map(&two_or_three_count/1)
    |> Enum.reduce(%{two: 0, three: 0}, fn %{two: has_twos, three: has_threes}, %{two: twos, three: threes} ->
      new_twos = (if has_twos, do: 1, else: 0)
      new_threes = (if has_threes, do: 1, else: 0)
      %{two: twos + new_twos, three: threes + new_threes}
    end)
    |> Enum.reduce(1, fn {_, val}, acc ->
      (val || 1) * acc
    end)
  end

  def split_and_strip(str) do
    str |> String.split("") |> Enum.filter(&(&1 != ""))
  end

  def find_ids() do
    ids = read_input()
    {match, id} = ids
      |> Enum.map(fn id ->
        {id, Enum.slice(ids, Enum.find_index(ids, fn candidate -> candidate == id end) + 1, Enum.count(ids))}
      end)
      |> Enum.filter(fn {_, l} -> Enum.count(l) > 0 end)
      |> Enum.reduce_while({}, fn {id, rest}, matches ->
        split = split_and_strip(id)
        rest
        |> Enum.map(fn candidate ->
          zipped =  Enum.zip(split_and_strip(candidate), split)
          found = zipped
          |> Enum.reduce(0, fn {first, second}, same ->
            cond do
              first != second -> same + 1
              true -> same
            end
          end)
          if found == 1, do: {:halt, {id, candidate}}, else: {}
        end)
        |> Enum.find({:cont, matches}, fn count ->
          case count do
            {_, _} -> true
            _ -> false
          end
        end)
      end)
      split_match = split_and_strip(match)
      id
        |> split_and_strip
        |> Enum.filter(&(Enum.member?(split_match, &1)))
        |> Enum.join("")
  end
end