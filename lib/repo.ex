defmodule Detektor.Repo do
  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end

  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end
