Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/interviewer/freelancer_domains' , to:'interviewer#freelancer_domains'
  get '/interviewer/get_title' , to:'interviewer#get_title'
  get '/interviewer/get_skills' , to:'interviewer#get_skills'
  # match 'freelancer_domains', to: 'interviewer#freelancer_domains', via: post

end
