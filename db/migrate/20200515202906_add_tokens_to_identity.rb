class AddTokensToIdentity < ActiveRecord::Migration[6.0]
  def change
    add_column :identities, :encrypted_access_token, :string
    add_column :identities, :encrypted_access_token_iv, :string
    add_column :identities, :encrypted_refresh_token, :string
    add_column :identities, :encrypted_refresh_token_iv, :string

    # Normally 8 hours
    add_column :identities, :access_token_expires_at, :datetime

    # 6 Months
    add_column :identities, :refresh_token_expires_at, :datetime
  end
end
