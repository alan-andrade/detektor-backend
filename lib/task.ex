defmodule Detektor.Task do
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    {:ok, state}
  end

  def findKey(url, parent, repo) do
    case Detektor.Repo.get(repo, url) do
      nil ->
        Detektor.Task._findKey(url, parent, repo)
      {:ok, track} ->
        Logger.debug"> cache #{inspect track}"
        send parent, track
    end
  end

  def _findKey(url, parent, repo) do
    args = [
      url,
     "-x", "--audio-format",
     "mp3",
     "--no-playlist",
     "--output", "%(title)s.%(ext)s",
     "--exec", "keyfinder-cli -n camelot"]

    Logger.debug"> youtube-dl #{Enum.join(args, " ")}"
    case System.cmd("youtube-dl", args, [parallelism: true, stderr_to_stdout: true]) do
      {output, 0} ->
        regex = ~r/^(?:\[ffmpeg\] Destination: )(.+)(?:\.mp3)$/
        split = String.split(output, "\n")
        destination = hd Enum.filter(split, fn(s)-> Regex.match?(regex, s) end)
        key = Enum.at(split, -2)
        title = hd Regex.run(regex, destination, capture: :all_but_first)

        track = %{url: url, title: title, key: key}
        Logger.debug"> reult #{inspect track}"
        Detektor.Repo.put(repo, url, {:ok, track})
        send parent, track
      {output, _} ->
        send(parent, %{error: output})
    end
  end
end
