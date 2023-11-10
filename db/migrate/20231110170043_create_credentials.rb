class CreateCredentials < ActiveRecord::Migration[7.1]
  def change
    create_table :credentials do |t|
      t.string :webauthn_id
      t.string :sign_count
      t.string :public_key

      t.timestamps
    end
  end
end
