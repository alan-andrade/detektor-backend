defmodule Detektor.Worker do
  use GenServer
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    {:ok, state}
  end

  ## Server Callbacks
  # args = [url, "-x", "--audio-format", "mp3", "--no-playlist", "--exec", "~/dev/keyfinder-cli/keyfinder-cli -n camelot"]
  # youtube-dl --get-duration url
  def handle_cast({:findKey, job}, state) do
    url = job[:url]
    parent = job[:parent]
    repo = job[:repo]

    args = [url, "-x", "--audio-format", "mp3", "--no-playlist", "--exec", "~/dev/keyfinder-cli/keyfinder-cli -n camelot"]
    Logger.debug"> youtube-dl #{inspect args}"
    case System.cmd("youtube-dl", args, [parallelism: true, stderr_to_stdout: true]) do
      {output, 0} ->
        key = %{key: hd(Enum.take String.split(output, "\n"), -2)}
        track = Map.merge(key, %{url: url})
        Detektor.Repo.put(repo, url, {:ok, track})
        send parent, track
        {:noreply, state}
      {output, _} ->
        send(parent, %{error: output})
        {:noreply, state}
    end
  end
end
