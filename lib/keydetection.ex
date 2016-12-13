defmodule Detektor.KeyDetection do
  use Supervisor
  require Logger

  def start_link(state, opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      worker(Detektor.Repo, [[name: Detektor.Repo]]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  def queue(job) do
    repo = Process.whereis(Detektor.Repo)

    {:ok, worker} = Detektor.Worker.start_link []

    case Detektor.Repo.get(repo, job[:url]) do
      nil ->
        newJob = Map.merge(%{repo: repo}, job)
        GenServer.cast(worker, {:findKey, newJob})
      {:ok, track} ->
        Logger.debug"> cache #{inspect track}"
        send job[:parent], track
    end
  end
end
