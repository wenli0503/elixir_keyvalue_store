defmodule KV.Bucket do
  @moduledoc """
  Key value pair storage system
  """

  @doc "Start the storage"
  def start_link do
    Agent.start_link(fn-> %{} end)
  end

  @doc "Put value into bucket"
  def put(agent, key, value) do
    Agent.update(agent, &Map.put(&1, key, value) )
  end

  @doc "Get value from bucket"
  def get(agent, key) do
    Agent.get(agent, &Map.get(&1, key) )
  end

  @doc "Pop the value from bucket and return it"
  def delete(agent, key) do
    Agent.get_and_update(agent, &Map.pop(&1, key))
  end

end
