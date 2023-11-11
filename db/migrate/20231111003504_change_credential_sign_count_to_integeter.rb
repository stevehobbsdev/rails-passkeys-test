class ChangeCredentialSignCountToIntegeter < ActiveRecord::Migration[7.1]
  def change
    change_column :credentials, :sign_count, :integer
  end
end
