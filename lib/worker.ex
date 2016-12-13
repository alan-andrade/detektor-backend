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

    args = [url, "-x", "--audio-format", "mp3", "--no-playlist", "--output", "%(title)s.%(ext)s", "--exec", "keyfinder-cli -n camelot"]
    Logger.debug"> youtube-dl #{inspect args}"
    case System.cmd("youtube-dl", args, [parallelism: true, stderr_to_stdout: true]) do
      {output, 0} ->
        regex = ~r/^(?:\[ffmpeg\] Destination: )(.+)(?:\.mp3)$/
        split = String.split(output, "\n")
        destination = hd Enum.filter(split, fn(s)-> Regex.match?(regex, s) end)
        key = Enum.at(split, -2)
        title = hd Regex.run(regex, destination, capture: :all_but_first)

        track = %{url: url, title: title, key: key}
        Detektor.Repo.put(repo, url, {:ok, track})
        send parent, track
        {:noreply, state}
      {output, _} ->
        send(parent, %{error: output})
        {:noreply, state}
    end
  end
end
