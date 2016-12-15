defmodule Detektor.DetektorChannel do
  use Phoenix.Channel
  require Logger

  def join("detektor:main", _message, socket) do
    Process.flag(:trap_exit, true)
    {:ok, socket}
  end

  def handle_in("getKeyForUrl", url, socket) do
    Detektor.KeyDetection.queue(url, self())
    {:noreply, socket}
  end

  def handle_info({_, msg}, socket) do
    push socket, "keyFound", msg
    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end
end
