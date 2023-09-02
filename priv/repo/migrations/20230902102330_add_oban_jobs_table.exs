defmodule MyApp.Repo.Migrations.AddObanJobsTable do
  @moduledoc false
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 11)
  end

  # specify `version: 1` in `down` to ensure that we'll roll all the way back down if necessary,
  # regardless of which version we've migrated `up` to.
  def down do
    Oban.Migration.down(version: 1)
  end
end
