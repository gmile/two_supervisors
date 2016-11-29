defmodule TwoSupervisors.MainUtility do
  def do_work(thing) do
    ms = Enum.random(1500..6000)
    Process.sleep(ms)
    ms
  end
end
