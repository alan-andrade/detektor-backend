defmodule Detektor.KeyDetection do
  use Supervisor
  require Logger

  def start_link(state, opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      worker(Detektor.Repo, [[name: Detektor.Repo]]),
      worker(Detektor.Worker, [%{}, [name: Detektor.Worker]])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def queue(job) do
    repo = Process.whereis(Detektor.Repo)
    Detektor.Worker.findKey(job, repo)
  end
end
