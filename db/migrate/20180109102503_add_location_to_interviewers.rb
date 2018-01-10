class AddLocationToInterviewers < ActiveRecord::Migration[5.0]
  def change
    add_column :interviewers, :location, :string
    add_column :interviewers, :total_yrs_of_exp, :integer
  end
end
