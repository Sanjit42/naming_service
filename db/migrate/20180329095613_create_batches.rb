class CreateBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :batches do |t|
      t.string :batch_name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
