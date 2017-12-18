class CreateInterviewers < ActiveRecord::Migration[5.0]
  def change
    create_table :interviewers do |t|
      t.string :name
      t.string :email
      t.string :skill_set
      t.string :title
      t.string :languages
      t.string :expertise

      t.timestamps
    end
  end
end
