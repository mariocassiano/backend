ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Backend.Repo, :manual)

Mox.defmock(Backend.ViaCep.ClientMock, for: Backend.ViaCep.ClientApi)
