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
    Enum.flat_map(x_range, fn x -> Enum.map(y_range, fn y -> {x, y} end) end)
  end

  def overlap?(pattern1, pattern2) do
    p1_x_end = pattern1.left_offset + pattern1.width - 1
    p1_y_end = pattern1.top_offset + pattern1.height - 1
    p2_x_end = pattern2.left_offset + pattern2.width - 1
    p2_y_end = pattern2.top_offset + pattern2.height - 1
    if (p1_x_end < pattern2.left_offset || pattern1.left_offset > p2_x_end) do
      false
    end
    if (p1_y_end < pattern2.top_offset || pattern1.top_offset > p2_y_end) do
      false
    end
    IO.puts "overlap"
    true
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
    index = Enum.take_while(all_patterns, fn item ->
      rest = List.delete_at(all_patterns, Enum.find_index(all_patterns, &(&1 == item)))
      IO.puts "length: #{Enum.count(rest)}"
      Enum.any?(rest, &(overlap?(&1, item)))
    end)
    |> Enum.count
    IO.puts "index: #{index}, length: #{Enum.count(all_patterns)}"
    Enum.at(all_patterns, index)
  end
end