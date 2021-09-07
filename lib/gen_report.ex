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
