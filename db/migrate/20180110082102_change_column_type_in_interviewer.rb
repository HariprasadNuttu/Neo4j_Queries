class ChangeColumnTypeInInterviewer < ActiveRecord::Migration[5.0]
  def change
    change_column :interviewers, :skill_set, :text
    change_column :interviewers, :skills, :text
    change_column :interviewers, :languages_set, :text
    change_column :interviewers, :languages, :text
    change_column :interviewers, :domain, :text
  end
end
