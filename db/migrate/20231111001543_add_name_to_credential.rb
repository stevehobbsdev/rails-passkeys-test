class AddNameToCredential < ActiveRecord::Migration[7.1]
  def change
    add_column :credentials, :name, :string
  end
end
