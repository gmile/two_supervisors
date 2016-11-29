defmodule TwoSupervisors.Boss do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_args) do
    state = %{
      queue: [],
      limit: 100,
      working_now: 0
    }

    {:ok, state}
  end

  def handle_call({:work_on, thing}, _from, state) do
    status = "in queue #{inspect length(state.queue)}; working #{inspect state.working_now}"

    {message, new_state} =
      if state.working_now < state.limit do
        %Task{pid: pid} = spawn_worker(thing)

        IO.puts "Boss: #{status}. Worker #{inspect pid} was immediately brought in to work on #{inspect thing}."
        {:executing_right_now, update_in(state, [:working_now], &(&1 + 1))}
      else
        IO.puts "Boss: #{status}. Going to add #{inspect thing} to queue."
        {:added_to_queue, update_in(state, [:queue], &[thing | &1])}
      end

    {:reply, message, new_state}
  end

  def handle_cast(:i_am_done, state) do
    # shut him down?
    
    new_state =
      if length(state.queue) > 0 do
        [thing | things_later_in_queue] = Enum.reverse(state.queue)
        IO.puts "Boss: taking '#{inspect thing}' from the queue, and spawning a worker to work on it."
        spawn_worker(thing)
        put_in(state, [:queue], things_later_in_queue)
      else
        update_in(state, [:working_now], &(&1 - 1))
      end

    {:noreply, new_state}
  end

  defp spawn_worker(thing) do
    Task.async(fn ->
      ms = TwoSupervisors.MainUtility.do_work(thing)
      IO.puts("Worker #{inspect self()}: I've worked with a number #{inspect thing} for #{ms} milliseconds.")
      GenServer.cast(TwoSupervisors.Boss, :i_am_done)
    end)
  end
end
