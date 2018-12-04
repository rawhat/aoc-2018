defmodule Sleep do
  defstruct start: -1, finish: -1
end

defmodule Guards do
  def slice_date_with_range(date, start, last) do
    date
    |> Enum.slice(start..last)
    |> Enum.join("")
  end

  def line_to_struct(line) do
    date = line
    |> String.split("")
    |> Enum.slice(2..17)
    #[y1, y2, y3, y4, _, m1, m2, _, d1, d2, _, h1, h2, _, m1, m2] = date
    {year, _} = Integer.parse(slice_date_with_range(date, 0, 3))
    {month, _} = Integer.parse(slice_date_with_range(date, 5, 6))
    {day, _} = Integer.parse(slice_date_with_range(date, 8, 9))
    {hour, _} = Integer.parse(slice_date_with_range(date, 11, 12))
    {minute, _} = Integer.parse(slice_date_with_range(date, 14, 15))
    date_time = %NaiveDateTime{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: 0
    }
    message = String.slice(line, 19..-1)
    %{date_time: date_time, message: message}
  end

  def parse_and_order_file() do
    File.read!("input.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&line_to_struct/1)
    |> Enum.sort(&(case NaiveDateTime.compare(&1.date_time, &2.date_time) do
      :gt -> false
      :lt -> true
    end))
    |> Enum.reduce([], fn data, lists ->
      case String.contains?(data.message, "Guard") do
        true -> lists ++ [[data]]
        false ->
          new_list = List.last(lists) ++ [data]
          Enum.slice(lists, 0..-2) ++ [new_list]
      end
    end)
    |> Enum.reduce(%{}, fn event_stream, guards ->
      [begin_shift | events] = event_stream
      [_, guard_id, _, _] = String.split(begin_shift.message, " ")
      guard_id = String.slice(guard_id, 1..-1)
      sleep_time = events
      |> Enum.chunk(2)
      |> Enum.reduce(%{sleep_time: 0, minutes_asleep: []}, fn [asleep, awake], mapping ->
        {{_, _, _}, {_, asleep_minute, _}} = NaiveDateTime.to_erl(asleep.date_time)
        {{_, _, _}, {_, awake_minute, _}} = NaiveDateTime.to_erl(awake.date_time)
        %{
          sleep_time: mapping.sleep_time + (NaiveDateTime.diff(awake.date_time, asleep.date_time) / 60),
          minutes_asleep: mapping.minutes_asleep ++ Enum.to_list(asleep_minute..(awake_minute-1))
        }
      end)
      Map.update(
        guards,
        guard_id,
        sleep_time,
        &(%{sleep_time: &1.sleep_time + sleep_time.sleep_time, minutes_asleep: &1.minutes_asleep ++ sleep_time.minutes_asleep})
      )
    end)
    |> Enum.sort_by(fn {_, m} -> m.sleep_time end)
  end

  def highest_minute_count() do
    found = parse_and_order_file()
    |> List.last
    {_, map} = found
    map.minutes_asleep
    |> Enum.reduce(%{}, &(Map.update(&2, &1, 1, fn count -> count + 1 end)))
    |> Enum.sort_by(fn {_, m} -> m end)
    |> List.last
  end

  def get_highest_minute_frequency() do
    parse_and_order_file()
    |> Enum.reduce(%{count: -1}, fn {id, map}, highest ->
      found = map.minutes_asleep
      |> Enum.reduce(%{}, &(Map.update(&2, &1, 1, fn count -> count + 1 end)))
      |> Enum.sort_by(fn {_, m} -> m end)
      |> List.last
      case found do
        {minute, count} ->
          if highest.count < count, do: %{id: id, count: count, minute: minute}, else: highest
        _ ->
          highest
      end
    end)
  end
end
