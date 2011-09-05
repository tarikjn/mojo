class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.string :email
      t.string :location
      t.string :remote_addr

      t.timestamps
    end
  end
end
