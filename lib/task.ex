defmodule Detektor.Task do
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    {:ok, state}
  end

  def fetchPlaylist(url, parent, _) do
    cmd = "youtube-dl"
    args = [ url, "--flat-playlist", "-J"]

    Logger.debug"> youtube-dl #{Enum.join(args, " ")}"
    case System.cmd(cmd, args, [parallelism: true, stderr_to_stdout: true]) do
      {output, 0} ->
        {:ok, youtubeHash}  = output |> String.split("\n") |> hd |> Poison.decode

        constructYoutubeURL = fn(id) -> "https://www.youtube.com/watch?v=#{id}" end

        youtubeHash["entries"] |> Enum.each(fn entry ->
          entry["id"] |> constructYoutubeURL.() |> Detektor.KeyDetection.queue(:findKey, parent)
        end)

      {output, _} ->
        Logger.error "> failed youtube-dl #{output}"
        send(parent, %{error: output})
    end
  end

  def findKey(url, parent, repo) do
    case Detektor.Repo.get(repo, url) do
      nil ->
        Detektor.Task._findKey(url, parent, repo)
      {:ok, track} ->
        Logger.debug"> cache #{inspect track}"
        send parent, {:keyFound, track}
    end
  end

  def _findKey(url, parent, repo) do
    args = [
      url,
     "-x", "--audio-format",
     "mp3",
     "--no-playlist",
     "--output", "downloads/%(title)s.%(ext)s",
     "--exec", "keyfinder-cli -n camelot"]

    Logger.debug"> youtube-dl #{Enum.join(args, " ")}"
    case System.cmd("youtube-dl", args, [parallelism: true, stderr_to_stdout: true]) do
      {output, 0} ->
        regex = ~r/^(?:\[ffmpeg\] Destination: downloads\/)(.+)(?:\.mp3)$/
        split = String.split(output, "\n")
        destination = split |> Enum.filter(fn(s)-> Regex.match?(regex, s) end) |> hd
        key = split |> Enum.at(-2)
        title = regex |> Regex.run(destination, capture: :all_but_first) |> hd

        track = %{url: url, title: title, key: key}
        Logger.debug"> Result: #{inspect track}"
        Detektor.Repo.put(repo, url, {:ok, track})
        send parent, {:keyFound, track}
      {output, _} ->
        Logger.error "> youtube-dl error: #{output}"
        send(parent, %{error: output})
    end
  end
end
