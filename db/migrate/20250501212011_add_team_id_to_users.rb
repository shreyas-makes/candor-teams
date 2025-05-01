class AddTeamIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :team, type: :uuid, index: true
  end
end
