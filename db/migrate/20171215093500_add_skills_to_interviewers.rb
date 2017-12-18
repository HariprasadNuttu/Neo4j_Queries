class AddSkillsToInterviewers < ActiveRecord::Migration[5.0]
  def change
    add_column :interviewers, :languages_set, :string
    add_column :interviewers, :skills, :string
  end
end
