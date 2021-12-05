class CreateAppointments < ActiveRecord::Migration[6.1]
  def change
    create_table :appointments do |t|
      t.datetime :date
      t.string :name
      t.string :surname
      t.integer :phone
      t.string :notes
      t.belongs_to :professional, null: false, foreign_key: true

      t.timestamps
    end
  end
end
