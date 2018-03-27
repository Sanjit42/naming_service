class AddColumnIsPresentTwToIntern < ActiveRecord::Migration[5.1]
  def change
    add_column :interns, :present_in_TW, :boolean
  end
end
