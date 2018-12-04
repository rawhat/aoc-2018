defmodule Pattern do
  defstruct id: "", left_offset: 0, top_offset: 0, width: 0, height: 0

  def parse_file() do
    File.read!("input.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
  end

  def parse_int(str) do
    {num, _} = Integer.parse(str)
    num
  end

  def input_to_pattern(input) do
    [id_str, _, offsets, dimensions] = String.split(input, " ")
    id = String.slice(id_str, 1..-1)
    [left_offset, top_offset] = String.split(offsets, ",")
    top_offset = String.slice(top_offset, 0..-2)
    [width, height] = String.split(dimensions, "x")
    %Pattern{
      height: parse_int(height),
      id: id,
      left_offset: parse_int(left_offset),
      top_offset: parse_int(top_offset),
      width: parse_int(width),
    }
  end

  def get_pairs_from_pattern(%Pattern{} = %{:left_offset => left_offset, :top_offset => top_offset, :width => width, :height => height}) do
    x_range = left_offset..(left_offset+width-1)
    y_range = top_offset..(top_offset+height-1)
    MapSet.new(Enum.flat_map(x_range, fn x -> Enum.map(y_range, fn y -> {x, y} end) end))
  end

  def find_overlaps() do
    parse_file()
    |> Enum.map(&input_to_pattern/1)
    |> Enum.map(&get_pairs_from_pattern/1)
    |> List.flatten
    |> Enum.reduce(%{}, &(Map.update(&2, &1, 1, fn count -> count + 1 end)))
    |> Enum.filter(fn {_, count} -> count >= 2 end)
    |> Enum.count
  end

  def find_non_overlapping() do
    all_patterns = parse_file()
    |> Enum.map(&input_to_pattern/1)
    Enum.filter(all_patterns, fn item ->
      item_pairs = get_pairs_from_pattern(item)
      !(List.delete_at(all_patterns, Enum.find_index(all_patterns, &(&1 == item)))
      |> Enum.map(&get_pairs_from_pattern/1)
      |> Enum.any?(fn candidate ->
        dupes = candidate
        |> MapSet.intersection(item_pairs)
        |> MapSet.size
        if dupes != 0, do: true, else: false
      end))
    end)
    |> List.first
  end
end
