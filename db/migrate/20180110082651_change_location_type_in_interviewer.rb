class ChangeLocationTypeInInterviewer < ActiveRecord::Migration[5.0]
  def change
    change_column :interviewers, :location, :text
  end
end
