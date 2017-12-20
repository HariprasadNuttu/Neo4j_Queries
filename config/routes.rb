Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  match "/create_interviewer" => "interviewer#create", via: :post
  match "/get_titles" => "interviewer#get_title", via: :get
  match "/get_skills" => "interviewer#get_skills", via: :get
  match "/match_interviewers" => "interviewer#match_interviewers", via: :get
    match "/domain_based" => "interviewer#domain_based", via: :get

end
