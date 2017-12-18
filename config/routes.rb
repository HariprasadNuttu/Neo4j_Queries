Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/interviewer/freelancer_domains' , to:'interviewer#freelancer_domains'
  # match 'freelancer_domains', to: 'interviewer#freelancer_domains', via: post

end
