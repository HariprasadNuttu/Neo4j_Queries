class AddDomainToInterviewer < ActiveRecord::Migration[5.0]
  def change
    add_column :interviewers, :domain, :string
  end
end
