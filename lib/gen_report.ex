defmodule GenReport do
  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  def build(filename) do
    parsed_file =
      filename
      |> GenReport.Parser.parse_file()

    all_hours =
      parsed_file
      |> sum_all_hours()

    hours_per_month =
      parsed_file
      |> sum_hours_month()

    hours_per_year =
      parsed_file
      |> sum_hours_year()

    parse_response(all_hours, hours_per_month, hours_per_year)
  end

  def build_many(filenames) when not is_list(filenames), do: {:error, "Insert list file!"}

  def build_many(filenames) do
    filenames
    |> Task.async_stream(&build(&1))
    |> Enum.reduce(
      %{"all_hours" => %{}, "hours_per_month" => %{}, "hours_per_year" => %{}},
      fn {:ok, result}, report ->
        sum_reports(result, report)
      end
    )
  end

  defp sum_reports(result, report) do
    %{
      "all_hours" => all_hours1,
      "hours_per_month" => hours_per_month1,
      "hours_per_year" => hours_per_year1
    } = result

    %{
      "all_hours" => all_hours2,
      "hours_per_month" => hours_per_month2,
      "hours_per_year" => hours_per_year2
    } = report

    all_hours = merge_maps(all_hours1, all_hours2)

    hours_per_month =
      Map.merge(hours_per_month1, hours_per_month2, fn _key, value1, value2 ->
        Map.merge(value1, value2, fn _key, value1, value2 -> value1 + value2 end)
      end)

    hours_per_year =
      Map.merge(hours_per_year1, hours_per_year2, fn _key, value1, value2 ->
        Map.merge(value1, value2, fn _key, value1, value2 -> value1 + value2 end)
      end)

    parse_response(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp sum_all_hours(parsed_file) do
    parsed_file
    |> Enum.reduce(
      %{},
      fn [name, hours, _day, _month, _year], report ->
        map_update(report, name, 0, hours)
      end
    )
  end

  defp sum_hours_month(parsed_file) do
    parsed_file
    |> Enum.reduce(
      %{},
      fn [name, hours, _day, month, _year], report ->
        put_hours(report, name, month, hours)
      end
    )
  end

  defp sum_hours_year(parsed_file) do
    parsed_file
    |> Enum.reduce(
      %{},
      fn [name, hours, _day, _month, year], report ->
        put_hours(report, name, year, hours)
      end
    )
  end

  defp put_hours(report, name, option, hours) do
    Map.put(
      report,
      name,
      Map.put(
        Map.get(report, name, %{}),
        option,
        Map.get(Map.get(report, name, %{}), option, 0) + hours
      )
    )
  end

  defp map_update(font, key, inicial_value, add_value) do
    Map.put(font, key, Map.get(font, key, inicial_value) + add_value)
  end

  defp parse_response(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
