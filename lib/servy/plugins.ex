require Logger

defmodule Servy.Plugins do

  alias Servy.Conv

  def track(%Conv{status: 404, path: path} = conv) do
    IO.puts("Warning: #{path} is on the loose")
    conv
  end

  # We dont mind what is in conv but we do care if it is a
  # Conv struct so matching it into Conv struct
  def track(%Conv{} = conv), do: conv

  # when pattern matching maps, you dont need to match all values
  # but the left handside map must not contain anything the right
  # hand side does not
  # conv = %{method: "GET", path: "/wildlife"}
  # %{path: "/wildlife"} = conv (MATCH)
  # %{name: "nope", path: "/wildlife"} = conv (NOT MATCH)
  # %{method: method, path: "/wildlife"} = conv (bind method to method from the conv)
  # This will only be called if the path pattern matches, we are rewriting the path from
  # /wildlife to wildthings
  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/#{id}"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  # def log(conv) do
  #   # IO.inspect prints and returns value
  #   IO.inspect(conv)
  # end

  # a more concise version of the above code
  def log(%Conv{} = conv) do
    Logger.info(conv)
    conv
  end
end
