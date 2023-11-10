class AddCredentialsToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :credentials, :user, index: true, foreign_key: true
  end
end
