defmodule Detektor.KeyDetection do
  use Supervisor
  require Logger

  def start_link(_state, opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      worker(Detektor.Repo, [[name: Detektor.Repo]]),
      supervisor(Task.Supervisor, [[name: Task.Supervisor]])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def queue(url, parent) do
    pid  = Process.whereis(Task.Supervisor)
    repo = Process.whereis(Detektor.Repo)
    Task.Supervisor.async(pid, Detektor.Task, :findKey, [url, parent, repo])
  end
end
