class AddWebAuthn < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :public_key, :string
    add_column :users, :sign_count, :integer
  end
end
