ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Ekg.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Ekg.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Ekg.Repo)

