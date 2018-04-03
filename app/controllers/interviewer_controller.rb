class InterviewerController < ApplicationController
  def create
    # raise params.inspect
    interviewer = Interviewer.new name:params[:name],email:params[:email],title:params[:title],skills:params[:skill_set],languages_set:params[:languages_set],skill_set:params[:skills],languages:params[:languages],expertise:params[:expertise],domain:params[:domain]
    # raise interviewer.inspect
    if interviewer.save

      render json:{success:true}
    else
    end
  end
  def get_title
    titles = Interviewer.get_titles(params[:name])
    render json:{success:true,titles:titles}
  end
  def get_skills
    skills = Interviewer.get_skills(params[:name])
    render json:{success:true,skills:skills}
  end
  def match_interviewers
    # interviewers = Interviewer.match_interviewers(params)get_Interviewers
    interviewers = Interviewer.get_Interviewers(params)
    render json:{success:true,interviewers:interviewers,message:["Interviewers list"],total_interviewers:interviewers.length}
  end
  def domain_based
    interviewers = Interviewer.domain_based(params)
    render json:{success:true,interviewers:interviewers,message:["Interviewers list"]}
  end

  private

  def interviewer_params
    name:params[:name],email:params[:email],title:params[:title],skill_set:params[:skill_set],languages:params[:languages],expertise:params[:expertise]
  end
end
