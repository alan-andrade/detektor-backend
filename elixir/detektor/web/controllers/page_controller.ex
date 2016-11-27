defmodule Detektor.PageController do
  use Detektor.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
