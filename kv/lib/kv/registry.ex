defmodule KV.Registry do
  use GenServer
  @moduledoc """
  Genserver Client + Server
  """

  # client side
  @doc "start the registry"
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc "Look up the bucket pid for 'name' stored in 'server.'"
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc "Ensure there is a bucket associated to the given `name` in `server`"
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  # Server side
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, pid} = KV.Bucket.start_link
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {:noreply, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
