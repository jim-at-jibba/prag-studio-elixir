defmodule Servy.Parser do
  # alias syntax
  # alias Servy.Conv, as: Conv
  # shorthand - takes the last part as the alias
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    # | in a pattern returns the head (first line) and tail (remaining items as a list). tail will always return a list (last on will be empty)
    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    params = parse_params(params_string)
    # key/value pair
    # key is an atom - a constant whos name is its value
    # first_line = request |> String.split("\n") |> List.first()
    # [method, path, _] = String.split(first_line, " ")
    # [method, path, _] =
    #   request
    #   |> String.split("\n")
    #   |> List.first()
    #   |> String.split(" ")

    %Conv{method: method, path: path, params: params}
  end

  def parse_params(params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end
end
