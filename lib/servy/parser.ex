defmodule Servy.Parser do
  # alias syntax
  # alias Servy.Conv, as: Conv
  # shorthand - takes the last part as the alias
  alias Servy.Conv
  def parse(request) do
    # key/value pair
    # key is an atom - a constant whos name is its value
    # first_line = request |> String.split("\n") |> List.first()
    # [method, path, _] = String.split(first_line, " ")
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %Conv{method: method, path: path}
  end
end
