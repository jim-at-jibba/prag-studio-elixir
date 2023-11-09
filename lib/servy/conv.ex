# Structs take the name of the module hence having to be in there own module
# Only one struct per module
# A struct is a special kijd of map with fixed properties and defaults
defmodule Servy.Conv do
  # fieldnames followed by default value
  defstruct [method: "", path: "", resp_body: "", status: nil]

  def full_status(conv) do
   "#{conv.status} #{status_reason(conv.status)}"
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
