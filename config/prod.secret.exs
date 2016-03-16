use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :ekg, Ekg.Endpoint,
  secret_key_base: "kHj6kH2BtdiyVWfS76FyOTmn5IZHoLulPK7JVq7hwhIGdwgUf67eTiRCSBphFN0r"

# Configure your database
config :ekg, Ekg.Repo,
  adapter: Sqlite.Ecto,
  database: "db/ekg_prod.sqlite",
  pool_size: 20
