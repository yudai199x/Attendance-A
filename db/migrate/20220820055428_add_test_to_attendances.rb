class AddTestToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :aprv_sup, :string
    add_column :attendances, :af_started_at, :datetime
    add_column :attendances, :af_finished_at, :datetime
  end
end
