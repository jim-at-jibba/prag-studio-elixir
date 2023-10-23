defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> route
    |> format_response
  end

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

    %{method: method, path: path, resp_body: ""}
  end

  def route(conv) do
    # conv = %{method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers"}

    # All data is immutable. When transforming a new version is returned.
    # Its is common to just reassign the existing variable with the updated values

    # This is very common so there is a shorthand why to do it. Only works on existing properties
    # conv = Map.put(conv, "resp_body", "Bears, Lions, Tigers")
    %{conv | resp_body: "Bears, Lions, Tigers"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

# Elixir herdoc
# blank line is needed
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

expected_response = """
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 20

Bears, Lions, Tigers
"""

response = Servy.Handler.handle(request)
IO.puts(response)
