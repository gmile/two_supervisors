defmodule TwoSupervisors.Timer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    things = imitate_http_response()

    Enum.each(things, fn(thing) ->
      GenServer.call(TwoSupervisors.Boss, {:work_on, thing})
    end)

    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 1 * 1000) # Every second
  end

  # It returns a list of things.
  defp imitate_http_response() do
    for _ <- 1..:rand.uniform(50), do: make_ref()
  end
end
