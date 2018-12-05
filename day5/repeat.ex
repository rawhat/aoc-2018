defmodule Repeat do
  def parse_file() do
    File.read!("input.txt")
    |> String.split("")
    |> Enum.filter(&(&1 != "" && &1 != "\n"))
  end

  def are_matching(s1, s2) do
    s1 != s2 && String.upcase(s1) == String.upcase(s2)
  end

  def trim_pairs() do
    answer1 = parse_file()
    |> do_trim_pairs("")
    |> String.split("")
    answer2 = do_trim_pairs(answer1, "")
    retry_if_not_equal(answer1, answer2)
    |> String.length
  end

  def retry_if_not_equal(s1, s1) do
    s1
  end

  def retry_if_not_equal(s1, s2) do
    retry_if_not_equal(s2, do_trim_pairs(String.split(s2, ""), ""))
  end

  defp do_trim_pairs([], str) do
    str
  end

  defp do_trim_pairs([s1], str) do
    str <> s1
  end

  defp do_trim_pairs([s1, s2 | rest], str) do
    case are_matching(s1, s2) do
      true ->
        do_trim_pairs(rest, str)
      false ->
        do_trim_pairs([s2] ++ rest, str <> s1)
    end
  end

  def shortest_polymer() do
    parse_file()
    |> do_shortest_polymer
  end

  def do_shortest_polymer(chars) do
    chars
    |> Enum.filter(&(&1 != ""))
    |> Enum.uniq_by(&(String.upcase(&1)))
    |> Enum.reduce(%{}, fn char, map ->
      trimmed_chars = Enum.filter(chars, &(String.upcase(&1) != String.upcase(char)))
      a1 = do_trim_pairs(trimmed_chars, "")
      a2 = do_trim_pairs(String.split(a1, ""), "")
      s = retry_if_not_equal(a1, a2)
      Map.put(map, char, String.length(s))
    end)
    |> Enum.sort_by(fn {_, v} -> v end)
  end
end
