defmodule Parser do
  def get_number_stream() do
    File.stream!("pt1-input.txt")
    |> Stream.map(&(Integer.parse(&1)))
    |> Stream.filter(&(&1))
    |> Stream.map(fn {num, _} -> num end)
  end

  def parse() do
    get_number_stream()
    |> Enum.reduce(&(&1 + &2))
  end

  def find_cycle() do
    get_number_stream()
    |> Stream.cycle
    |> Stream.transform([], fn item, list ->
      next_item = [((List.last(list) || 0) +item)]
      # if Enum.member?(list, next_item), do: {:halt, list ++ next_item}, else: {:cont, list ++ next_item}
      if Enum.member?(list, next_item), do: {:halt, list ++ next_item}, else: {[next_item], list ++ next_item}
    end)
    |> Enum.flat_map(fn item ->
      IO.inspect item
      item
    end)
    |> Enum.to_list
    |> List.last
  end
end