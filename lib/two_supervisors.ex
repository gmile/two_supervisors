defmodule TwoSupervisors do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(TwoSupervisors.Boss, []),
      worker(TwoSupervisors.Timer, [])
    ]

    opts = [strategy: :one_for_one, name: TwoSupervisors.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
