defmodule Detektor.DetektorChannel do
  use Phoenix.Channel
  require Logger

  def join("detektor:main", message, socket) do
    Process.flag(:trap_exit, true)
    {:ok, socket}
  end

  def handle_in("findKey", msg, socket) do
    Logger.debug"> request received: #{inspect msg}"
    url = msg["url"]
    worker = :erlang.whereis(Detektor.Worker)
    res = GenServer.cast(worker, {:findKey, url, self()})
    {:noreply, socket}
  end

  def handle_info :findKey, {output, status, socket}  do
    Logger.debug"> handleinfo #{inspect output}"
    if status != 0 do
      push socket, "findKey", %{error: output}
    else
      key = hd(Enum.take String.split(output, "\n"), -2)
      push socket, "findKey", %{key: key}
    end
  end

  def handle_info(msg, socket) do
    Logger.debug"> handle_info after:  #{inspect msg}"
    push socket, "findKey", msg
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end
end
