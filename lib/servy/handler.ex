defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests
  """
  # its also possible to create custom module attributes that act as constants
  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  # This is a module attribute
  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path()
    |> log()
    |> route
    |> track()
    |> format_response
  end

  # def route(conv) do
  #   # conv = %{method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers"}
  #
  #   # All data is immutable. When transforming a new version is returned.
  #   # Its is common to just reassign the existing variable with the updated values
  #
  #   # This is very common so there is a shorthand why to do it. Only works on existing properties
  #   # conv = Map.put(conv, "resp_body", "Bears, Lions, Tigers")
  #   # %{conv | resp_body: "Bears, Lions, Tigers"}
  #
  #   # if conv.path == "/wildthings" do
  #   #   %{conv | resp_body: "Bears, Lions, Tigers"}
  #   # else
  #   #   %{conv | resp_body: "Teddy, smoky, paddington"}
  #   # end
  #   route(conv, conv.method, conv.path)
  # end
  #
  # # This is a function clause.
  # # When functions has multiple clauses elixir will
  # # try each one until it has a match
  # def route(conv, "GET", "/wildthings") do
  #   %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  # end
  #
  # def route(conv, "GET", "/bears") do
  #   %{conv | status: 200, resp_body: "Teddy, smoky, paddington"}
  # end
  #
  # # The third argument path, will be pattern matched against the incoming path
  # # So /bears/1, the 1 is pattern matched to the id property
  # def route(conv, "GET", "/bears/" <> id) do
  #   %{conv | status: 200, resp_body: "Bear #{id}"}
  # end
  #
  # def route(conv, _method, path) do
  #   %{conv | status: 404, resp_body: "No #{path} here!"}
  # end

  # This above can be rewritten to use pattern matching on maps
  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, smoky, paddington"}
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  # The third argument path, will be pattern matched against the incoming path
  # So /bears/1, the 1 is pattern matched to the id property
  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  # def route(%{method: "GET", path: "/about"} = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{ conv | status: 200, resp_body: content }

  #     {:error, :enoent} ->
  #       %{ conv | status: 404, resp_body: "File not found!" }

  #     {:error, reason} ->
  #       %{ conv | status: 500, resp_body: "File error: #{reason}" }
  #   end
  # end

  def route(%{path: path} = conv) do
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
GET /wildlife HTTP/1.1
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
GET /bears?id=2 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/new HTTP/1.1
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

request = """
GET /pages/contact HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)
