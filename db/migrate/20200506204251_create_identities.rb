class CreateIdentities < ActiveRecord::Migration[6.0]
  def change
    create_table :identities do |t|
      t.string :provider, null: false, default: "github"
      t.string :uid, null: false
      t.string :login
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :identities, %i[provider uid]
  end
end
