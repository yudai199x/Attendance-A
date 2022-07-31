class AddChkToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_chk, :boolean
    add_column :attendances, :chg_chk, :boolean
    add_column :attendances, :aprv_chk, :boolean
  end
end
