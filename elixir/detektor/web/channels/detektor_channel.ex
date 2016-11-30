defmodule Detektor.DetektorChannel do
  use Phoenix.Channel
  require Logger

  def join("detektor:main", _message, socket) do
    Process.flag(:trap_exit, true)
    {:ok, socket}
  end

  def handle_in("getKeyForUrl", url, socket) do
    Logger.debug"> request received: #{inspect url}"
    worker = :erlang.whereis(Detektor.Worker)
    # TODO: Broadcasting to 1 worker is making the worker stop listening
    # until it frees up. The messages are stored in a mailbox anyway, but this
    # reduces the speed in which it will analyze a batch of tracks.
    GenServer.cast(worker, {:findKey, url, self()})
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    Logger.debug"> handle_info after:  #{inspect msg}"
    push socket, "keyFound", msg
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end
end
