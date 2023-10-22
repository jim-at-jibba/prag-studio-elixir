# Namespace for the module
defmodule Servy do
  # all named functions must be in a module
  def hello(name) do
    "Hello, #{name}"
  end
end

IO.puts(Servy.hello("Jim"))
