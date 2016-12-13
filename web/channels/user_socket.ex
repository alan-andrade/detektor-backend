defmodule Detektor.UserSocket do
  use Phoenix.Socket

  channel "detektor:*", Detektor.DetektorChannel

  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
