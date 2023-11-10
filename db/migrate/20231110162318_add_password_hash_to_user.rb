class AddPasswordHashToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_hash, :string
  end
end
