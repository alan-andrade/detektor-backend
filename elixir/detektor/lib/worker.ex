defmodule Detektor.Worker do
  use GenServer
  require Logger

  def start_link(manager, opts \\ []) do
    GenServer.start_link(__MODULE__, manager, opts)
  end

  def init(opts) do
    {:ok, %{}}
  end

  ## Server Callbacks

  def handle_cast({:findKey, url, parent}, state) do
    case Map.fetch(state, url) do
      {:ok, result} ->
        send(parent, result)
        {:noreply, state}
      :error ->
        args = [url, "-x", "--audio-format", "mp3", "--exec", "~/dev/keyfinder-cli/keyfinder-cli -n camelot"]
        case System.cmd "youtube-dl", args, stderr_to_stdout: true do
          {output, 0} ->
            result = %{key: hd(Enum.take String.split(output, "\n"), -2)}
            stateN = Map.put(state, url, result)
            send parent, result
            {:noreply, stateN}
          {output, _} ->
            send(parent, %{error: output})
            {:noreply, state}
        end
    end
  end
end
