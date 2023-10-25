defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> log
    |> route
    |> format_response
  end

  # def log(conv) do
  #   # IO.inspect prints and returns value
  #   IO.inspect(conv)
  # end

  # a more concise version of the above code
  def log(conv), do: IO.inspect(conv)

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

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def route(conv) do
    # conv = %{method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers"}

    # All data is immutable. When transforming a new version is returned.
    # Its is common to just reassign the existing variable with the updated values

    # This is very common so there is a shorthand why to do it. Only works on existing properties
    # conv = Map.put(conv, "resp_body", "Bears, Lions, Tigers")
    # %{conv | resp_body: "Bears, Lions, Tigers"}

    # if conv.path == "/wildthings" do
    #   %{conv | resp_body: "Bears, Lions, Tigers"}
    # else
    #   %{conv | resp_body: "Teddy, smoky, paddington"}
    # end
    route(conv, conv.method, conv.path)
  end

  # This is a function clause.
  # When functions has multiple clauses elixir will
  # try each one until it has a match
  def route(conv, "GET", "/wildthings") do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | status: 200, resp_body: "Teddy, smoky, paddington"}
  end

  # The third argument path, will be pattern matched against the incoming path
  # So /bears/1, the 1 is pattern matched to the id property
  def route(conv, "GET", "/bears/" <> id) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  # defp denotes a private function
  defp status_reason(code) do
    %{
      # Because the keys are numbers and not :atoms we need to use =>
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

# Elixir herdoc
expected_response = """
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 20

Bears, Lions, Tigers
"""

# blank line is needed
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)
