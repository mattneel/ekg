MIX_ENV=prod mix clean && MIX_ENV=prod mix deps.clean --all && MIX_ENV=prod mix deps.get && MIX_ENV=prod mix compile && MIX_ENV=prod mix phoenix.digest && MIX_ENV=prod mix compile && MIX_ENV=prod mix release && MIX_ENV=prod bake firmware
